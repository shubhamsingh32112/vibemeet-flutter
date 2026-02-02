import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/call_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../shared/models/call_model.dart';

final callServiceProvider = Provider<CallService>((ref) => CallService());

/// Tracks call IDs that this device has already treated as terminal (ended/rejected/accepted).
/// Once a callId is in here, creator-side UI should never resurrect it as an incoming call.
final deadCallIdsProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Phase R3: Socket connection state provider
/// Tracks whether socket is connected to gate polling behavior
final socketConnectionProvider = StreamProvider<bool>((ref) async* {
  final socketService = SocketService();
  
  // Initial state
  yield socketService.isConnected;
  
  // Watch for connection changes
  final controller = StreamController<bool>.broadcast();
  
  // Note: SocketService doesn't expose connection state stream yet
  // For now, we'll check on each provider access
  // In a full implementation, SocketService would emit connection state changes
  
  ref.onDispose(() {
    controller.close();
  });
  
  // Poll connection state periodically (lightweight check)
  Timer.periodic(const Duration(seconds: 2), (timer) {
    if (!controller.isClosed) {
      controller.add(socketService.isConnected);
    } else {
      timer.cancel();
    }
  });
  
  yield* controller.stream;
});

// Provider for initiating a call
final initiateCallProvider = FutureProvider.family<CallModel, String>((ref, creatorUserId) async {
  debugPrint('📞 [CALL PROVIDER] Initiating call via provider');
  debugPrint('   Creator User ID: $creatorUserId');
  final callService = ref.read(callServiceProvider);
  final call = await callService.initiateCall(creatorUserId);
  debugPrint('✅ [CALL PROVIDER] Call initiated via provider');
  debugPrint('   CallId: ${call.callId}');
  return call;
});

// Provider for getting call status (now uses Socket.IO + fallback polling)
// Phase R1: Sockets authoritative - update state directly from socket events
// Phase R2: Provider owns all polling - screens only read from provider
// Phase R3: Socket health-aware polling - only poll when disconnected
final callStatusProvider = StreamProvider.family<CallModel, String>((ref, callId) async* {
  debugPrint('📊 [CALL PROVIDER] Starting call status stream');
  debugPrint('   CallId: $callId');
  debugPrint('   Method: Socket.IO (authoritative) + HTTP fallback');
  
  final callService = ref.read(callServiceProvider);
  final socketService = SocketService();
  
  // Get initial status via HTTP
  CallModel? currentCall;
  try {
    currentCall = await callService.getCallStatus(callId);
    yield currentCall;
    debugPrint('📊 [CALL PROVIDER] Initial status: ${currentCall.status.name}');
    
    // If already in terminal state, don't set up socket listener
    if (currentCall.status == CallStatus.ended || 
        currentCall.status == CallStatus.rejected) {
      debugPrint('⏸️  [CALL PROVIDER] Terminal state reached, no socket listener needed');
      return;
    }
  } catch (e) {
    debugPrint('❌ [CALL PROVIDER] Failed to get initial status: $e');
    // Continue with socket listener anyway
  }
  
  // Set up socket listeners for real-time updates
  final controller = StreamController<CallModel>.broadcast();
  Timer? pollTimer;
  bool _pollingActive = false;
  
  // Phase R2: Poll for token if accepted but token missing
  // Declared early to be available in socket callbacks
  void _startTokenPollingForCall(
    String callIdParam,
    CallService callServiceParam,
    StreamController<CallModel> controllerParam,
    Function(CallModel) onComplete,
  ) {
    if (_pollingActive) return;
    _pollingActive = true;
    
    pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final call = await callServiceParam.getCallStatus(callIdParam);
        currentCall = call;
        controllerParam.add(call);
        
        if (call.token != null) {
          debugPrint('✅ [CALL PROVIDER] Token received, stopping token polling');
          timer.cancel();
          _pollingActive = false;
          onComplete(call);
        } else if (call.status != CallStatus.accepted) {
          debugPrint('⚠️  [CALL PROVIDER] Call no longer accepted, stopping token polling');
          timer.cancel();
          _pollingActive = false;
        }
      } catch (e) {
        debugPrint('⚠️  [CALL PROVIDER] Token poll error: $e');
      }
    });
  }
  
  // Phase R1: Socket events are authoritative - update state directly
  // Listen for call_accepted (for callers)
  socketService.onCallAccepted((data) {
    if (data['callId'] == callId) {
      debugPrint('✅ [CALL PROVIDER] Call accepted via socket (Phase R1: authoritative)');
      
      // Phase R1: Update state directly from socket event
      // Only fetch if token/uid is missing
      final token = data['token'] as String?;
      final uid = data['uid'] as int?;
      
      if (currentCall != null) {
        final updatedCall = currentCall!.copyWith(
          status: CallStatus.accepted,
          token: token ?? currentCall!.token,
          uid: uid ?? currentCall!.uid,
        );
        currentCall = updatedCall;
        controller.add(updatedCall);
        
        // Phase R2: If token is missing, poll for it (provider owns polling)
        if (token == null && updatedCall.token == null) {
          debugPrint('🔄 [CALL PROVIDER] Token missing, starting token polling...');
          _startTokenPollingForCall(callId, callService, controller, (call) {
            currentCall = call;
            _pollingActive = false;
            pollTimer?.cancel();
          });
        } else {
          // Token present - stop any polling
          _pollingActive = false;
          pollTimer?.cancel();
        }
      } else {
        // No current call - fetch once to get full state
        callService.getCallStatus(callId).then((call) {
          currentCall = call;
          controller.add(call);
        }).catchError((e) {
          debugPrint('❌ [CALL PROVIDER] Error fetching call after accept: $e');
        });
      }
    }
  });
  
  // Phase R1: Socket events are authoritative - update state directly
  // Listen for call_rejected (for callers)
  socketService.onCallRejected((data) {
    if (data['callId'] == callId) {
      debugPrint('❌ [CALL PROVIDER] Call rejected via socket (Phase R1: authoritative)');
      
      // Phase R1: Update state directly - no HTTP fetch
      if (currentCall != null) {
        final updatedCall = currentCall!.copyWith(status: CallStatus.rejected);
        currentCall = updatedCall;
        controller.add(updatedCall);
      } else {
        // No current call - create minimal state
        final rejectedCall = CallModel(
          callId: callId,
          channelName: '',
          callerUserId: '',
          creatorUserId: '',
          status: CallStatus.rejected,
        );
        currentCall = rejectedCall;
        controller.add(rejectedCall);
      }
      
      // Stop polling immediately
      _pollingActive = false;
      pollTimer?.cancel();
    }
  });
  
  // Phase R1: Socket events are authoritative - update state directly
  // Listen for call_ended (for both parties)
  socketService.onCallEnded((data) {
    if (data['callId'] == callId) {
      debugPrint('🔚 [CALL PROVIDER] Call ended via socket (Phase R1: authoritative)');
      
      // Phase R1: Update state directly - no HTTP fetch
      final duration = data['duration'] as int?;
      final durationFormatted = data['durationFormatted'] as String?;
      
      if (currentCall != null) {
        final updatedCall = currentCall!.copyWith(
          status: CallStatus.ended,
          duration: duration ?? currentCall!.duration,
          durationFormatted: durationFormatted ?? currentCall!.durationFormatted,
        );
        currentCall = updatedCall;
        controller.add(updatedCall);
      } else {
        // No current call - create minimal state
        final endedCall = CallModel(
          callId: callId,
          channelName: '',
          callerUserId: '',
          creatorUserId: '',
          status: CallStatus.ended,
          duration: duration,
          durationFormatted: durationFormatted,
        );
        currentCall = endedCall;
        controller.add(endedCall);
      }
      
      // Stop polling immediately
      _pollingActive = false;
      pollTimer?.cancel();
    }
  });
  
  // Phase R3: Socket health-aware polling
  // Only poll when socket is disconnected OR when waiting for token
  void _startPollingIfNeeded() {
    if (_pollingActive) return;
    
    final isSocketConnected = socketService.isConnected;
    final needsToken = currentCall?.status == CallStatus.accepted && currentCall?.token == null;
    
    // Phase R3: Only poll if socket disconnected OR waiting for token
    if (!isSocketConnected || needsToken) {
      _pollingActive = true;
      final pollInterval = needsToken ? const Duration(seconds: 2) : const Duration(seconds: 10);
      
      debugPrint('🔄 [CALL PROVIDER] Starting polling (socket: ${isSocketConnected ? "connected" : "disconnected"}, needsToken: $needsToken)');
      pollTimer = Timer.periodic(pollInterval, (timer) async {
        // Phase R3: Check socket state - stop if reconnected (unless waiting for token)
        if (socketService.isConnected && !needsToken) {
          debugPrint('✅ [CALL PROVIDER] Socket reconnected, stopping polling');
          timer.cancel();
          _pollingActive = false;
          return;
        }
        
        try {
          final call = await callService.getCallStatus(callId);
          currentCall = call;
          controller.add(call);
          
          // Stop polling if in terminal state OR token received
          if (call.status == CallStatus.ended || 
              call.status == CallStatus.rejected ||
              (call.status == CallStatus.accepted && call.token != null)) {
            timer.cancel();
            _pollingActive = false;
            if (call.status == CallStatus.ended || call.status == CallStatus.rejected) {
              controller.close();
            }
          }
        } catch (e) {
          debugPrint('⚠️  [CALL PROVIDER] Fallback poll error: $e');
        }
      });
    }
  }
  
  // Phase R3: Start polling if socket is disconnected
  if (!socketService.isConnected) {
    _startPollingIfNeeded();
  }
  
  // Phase R2: If accepted but token missing, poll for token
  if (currentCall?.status == CallStatus.accepted && currentCall?.token == null) {
    _startTokenPollingForCall(callId, callService, controller, (call) {
      currentCall = call;
    });
  }
  
  // Cleanup on dispose
  ref.onDispose(() {
    pollTimer?.cancel();
    // Phase R5: Use removeListener instead of off() to avoid clobbering
    // Note: We can't easily remove specific callbacks, so we'll keep them
    // The provider will be disposed anyway, so listeners will be cleaned up
    controller.close();
  });
  
  // Yield from controller
  yield* controller.stream;
});

// Provider for getting incoming calls (creator) - now uses Socket.IO
final incomingCallsProvider = StreamProvider<List<CallModel>>((ref) async* {
  debugPrint('📞 [CALL PROVIDER] Starting incoming calls stream');
  debugPrint('   Method: Socket.IO (with HTTP fallback)');
  
  final callService = ref.read(callServiceProvider);
  final socketService = SocketService();
  final deadCallIdsNotifier = ref.read(deadCallIdsProvider.notifier);
  
  // ⚠️ CRITICAL: Ensure socket is connected before registering listeners
  if (!socketService.isConnected) {
    debugPrint('🔌 [CALL PROVIDER] Socket not connected, attempting to connect...');
    try {
      await socketService.connect();
      // Wait for connection to establish (poll up to 3 seconds)
      int attempts = 0;
      while (!socketService.isConnected && attempts < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      if (socketService.isConnected) {
        debugPrint('✅ [CALL PROVIDER] Socket connected successfully');
      } else {
        debugPrint('⚠️  [CALL PROVIDER] Socket connection timeout, will use HTTP fallback');
      }
    } catch (e) {
      debugPrint('⚠️  [CALL PROVIDER] Failed to connect socket: $e');
      // Continue anyway - will use HTTP fallback
    }
  } else {
    debugPrint('✅ [CALL PROVIDER] Socket already connected');
  }
  
  // Initialize current calls list
  List<CallModel> currentCalls = [];
  
  // ⚠️ CRITICAL: Set up socket listener FIRST, before HTTP fetch
  // This ensures we catch replay events that happen during socket connection
  final controller = StreamController<List<CallModel>>.broadcast();
  
  // Listen for incoming_call event (for creators) - MUST be registered early
  socketService.onIncomingCall((data) async {
    debugPrint('📞 [CALL PROVIDER] Incoming call received via socket');
    final callId = data['callId'] as String?;
    debugPrint('   CallId: $callId');

    // ✅ FIX #3 — Ignore socket incoming_call if dead (local terminal guard)
    final deadIdsSnapshot = deadCallIdsNotifier.state;
    if (callId != null && deadIdsSnapshot.contains(callId)) {
      debugPrint('🧟 [CALL PROVIDER] Ignoring dead call $callId from socket incoming_call');
      return;
    }
    
    // 🔥 CRITICAL: Always verify call status via API to prevent stale calls
    // This ensures we only show calls that are actually ringing on the backend
    try {
      final calls = await callService.getIncomingCalls();
      // 🔒 GOLDEN RULE: Filter to ONLY ringing calls - if status !== ringing, it must not exist
      var ringingCalls = calls.where((call) => call.status == CallStatus.ringing).toList();
      // 🔒 LOCAL GUARD: Never resurrect locally-dead calls (terminal on this device)
      final deadIds = deadCallIdsNotifier.state;
      ringingCalls = ringingCalls.where((c) => !deadIds.contains(c.callId)).toList();
      
      // 🔒 ONE-CALL-ONLY INVARIANT: Creator can have at most 1 ringing call
      // If provider ever has more than one → clear all and resync
      if (ringingCalls.length > 1) {
        debugPrint('🚨 [CALL PROVIDER] VIOLATION: More than 1 ringing call detected!');
        debugPrint('   Found ${ringingCalls.length} ringing calls - clearing all and resyncing');
        currentCalls = [];
        controller.add(currentCalls);
        // Force resync from backend
        final resyncedCalls = await callService.getIncomingCalls();
        final validRingingCalls = resyncedCalls.where((call) => call.status == CallStatus.ringing).toList();
        if (validRingingCalls.length <= 1) {
          currentCalls = validRingingCalls;
          controller.add(currentCalls);
          debugPrint('✅ [CALL PROVIDER] Resynced: ${validRingingCalls.length} ringing call(s)');
        }
        return;
      }
      
      currentCalls = ringingCalls;
      controller.add(ringingCalls);
      debugPrint('✅ [CALL PROVIDER] Verified incoming call via API');
      debugPrint('   Active ringing calls: ${ringingCalls.length}');
    } catch (e) {
      debugPrint('⚠️  [CALL PROVIDER] Failed to verify call via API: $e');
      // Don't add call if API verification fails - prevents stale calls
      debugPrint('   ⚠️  Skipping call addition - API verification failed');
    }
  });
  
  // 🔒 GOLDEN RULE: If call status !== ringing, it must not exist in memory
  // This means: No lingering provider entries, no cached call IDs, no "handled" flags
  // Dead calls should be garbage-collected instantly.

  // 🔥 TERMINAL EVENT HANDLER: call_rejected
  // This event means: This call will never be ringing again. Ever.
  // Do ALL of this synchronously: Kill memory, cancel timers, force-close UI
  socketService.onCallRejected((data) {
    final callId = data['callId'] as String?;
    
    if (callId != null) {
      debugPrint('❌ [CALL PROVIDER] TERMINAL EVENT: call_rejected received');
      debugPrint('   CallId: $callId');
      debugPrint('   🚨 HARD TEARDOWN: No conditions, no checks, terminal means terminal');
      // Mark this call as locally dead so it can never resurrect
      deadCallIdsNotifier.state = {
        ...deadCallIdsNotifier.state,
        callId,
      };
      
      // 1. Kill all call memory (synchronously - no async/await)
      currentCalls = [];
      controller.add(currentCalls);
      debugPrint('✅ [CALL PROVIDER] Provider cleared - all calls removed from memory');
    }
  });
  
  // 🔥 TERMINAL EVENT HANDLER: call_accepted (for creators)
  // When creator accepts, the incoming call screen should close immediately
  socketService.onCallAccepted((data) {
    final callId = data['callId'] as String?;
    
    if (callId != null) {
      debugPrint('✅ [CALL PROVIDER] TERMINAL EVENT: call_accepted received (for creator)');
      debugPrint('   CallId: $callId');
      debugPrint('   🚨 HARD TEARDOWN: Call accepted, incoming call screen should close');
      // Mark this call as locally dead so it can never resurrect
      deadCallIdsNotifier.state = {
        ...deadCallIdsNotifier.state,
        callId,
      };
      
      // 1. Kill all call memory (synchronously - no async/await)
      currentCalls = [];
      controller.add(currentCalls);
      debugPrint('✅ [CALL PROVIDER] Provider cleared - call accepted, moving to video call');
    }
  });

  // 🔥 TERMINAL EVENT HANDLER: call_ended
  // This event means: This call will never be ringing again. Ever.
  // Do ALL of this synchronously: Kill memory, cancel timers, force-close UI
  socketService.onCallEnded((data) {
    final callId = data['callId'] as String?;
    final reason = data['reason'] as String?;
    
    if (callId != null) {
      debugPrint('🔚 [CALL PROVIDER] TERMINAL EVENT: call_ended received');
      debugPrint('   CallId: $callId');
      debugPrint('   Reason: $reason');
      debugPrint('   🚨 HARD TEARDOWN: No conditions, no checks, terminal means terminal');
      // Mark this call as locally dead so it can never resurrect
      deadCallIdsNotifier.state = {
        ...deadCallIdsNotifier.state,
        callId,
      };
      
      // 1. Kill all call memory (synchronously - no async/await)
      currentCalls = [];
      controller.add(currentCalls);
      debugPrint('✅ [CALL PROVIDER] Provider cleared - all calls removed from memory');
    }
  });
  
  // Initialize with HTTP fetch to get current state
  // This prevents stale calls from appearing after navigation
  try {
    final initialCalls = await callService.getIncomingCalls();
    // Only include ringing calls in the initial list
    var ringingCalls = initialCalls.where((call) => call.status == CallStatus.ringing).toList();
    // 🔒 LOCAL GUARD: Never resurrect locally-dead calls
    final deadIds = deadCallIdsNotifier.state;
    ringingCalls = ringingCalls.where((c) => !deadIds.contains(c.callId)).toList();
    currentCalls = ringingCalls;
    controller.add(currentCalls);
    debugPrint('📋 [CALL PROVIDER] Initial calls fetched: ${currentCalls.length} ringing call(s)');
  } catch (e) {
    debugPrint('⚠️  [CALL PROVIDER] Failed to fetch initial calls: $e');
    currentCalls = [];
    controller.add(currentCalls);
  }
  yield currentCalls;
  
  // 🔥 OPTIONAL FALLBACK: One-time sync on socket reconnect (not periodic polling)
  // Polling is now OPTIONAL fallback only, not default behavior
  // Use only for: App resume from background, Socket reconnect, Debug / safety net
  bool _hasSyncedOnReconnect = false;
  
  // Listen for socket reconnect to do ONE sync
  socketService.socket?.on('reconnect', (_) {
    if (!_hasSyncedOnReconnect) {
      debugPrint('🔄 [CALL PROVIDER] Socket reconnected - doing ONE sync with backend');
      _hasSyncedOnReconnect = true;
      
      // ONE call to sync with backend
      callService.getIncomingCalls().then((calls) {
        final ringingCalls = calls.where((call) => call.status == CallStatus.ringing).toList();
        currentCalls = ringingCalls;
        controller.add(ringingCalls);
        debugPrint('✅ [CALL PROVIDER] Synced once after reconnect: ${ringingCalls.length} ringing call(s)');
        _hasSyncedOnReconnect = false; // Reset for next reconnect
      }).catchError((e) {
        debugPrint('⚠️  [CALL PROVIDER] Sync on reconnect error: $e');
        _hasSyncedOnReconnect = false;
      });
    }
  });
  
  // Note: Removed periodic polling - socket events are the primary source of truth
  // If backend never sends ghosts, frontend doesn't need polling
  
  
  // Cleanup on dispose
  ref.onDispose(() {
    socketService.off('incoming_call');
    socketService.off('call_rejected');
    socketService.off('call_ended');
    socketService.off('call_accepted');
    controller.close();
  });
  
  // Yield from controller
  yield* controller.stream;
});
