import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/call_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../shared/models/call_model.dart';

final callServiceProvider = Provider<CallService>((ref) => CallService());

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
final callStatusProvider = StreamProvider.family<CallModel, String>((ref, callId) async* {
  debugPrint('📊 [CALL PROVIDER] Starting call status stream');
  debugPrint('   CallId: $callId');
  debugPrint('   Method: Socket.IO (with HTTP fallback)');
  
  final callService = ref.read(callServiceProvider);
  final socketService = SocketService();
  
  // Get initial status via HTTP
  try {
    final initialCall = await callService.getCallStatus(callId);
    yield initialCall;
    debugPrint('📊 [CALL PROVIDER] Initial status: ${initialCall.status.name}');
    
    // If already in terminal state, don't set up socket listener
    if (initialCall.status == CallStatus.ended || 
        initialCall.status == CallStatus.rejected ||
        initialCall.status == CallStatus.accepted) {
      debugPrint('⏸️  [CALL PROVIDER] Terminal state reached, no socket listener needed');
      return;
    }
  } catch (e) {
    debugPrint('❌ [CALL PROVIDER] Failed to get initial status: $e');
    // Continue with socket listener anyway
  }
  
  // Set up socket listeners for real-time updates
  final controller = StreamController<CallModel>.broadcast();
  
  // Listen for call_accepted (for callers)
  socketService.onCallAccepted((data) {
    if (data['callId'] == callId) {
      debugPrint('✅ [CALL PROVIDER] Call accepted via socket');
      // Fetch updated call status
      callService.getCallStatus(callId).then((call) {
        controller.add(call);
      }).catchError((e) {
        debugPrint('❌ [CALL PROVIDER] Error fetching call after accept: $e');
      });
    }
  });
  
  // Listen for call_rejected (for callers)
  socketService.onCallRejected((data) {
    if (data['callId'] == callId) {
      debugPrint('❌ [CALL PROVIDER] Call rejected via socket');
      // Fetch updated call status
      callService.getCallStatus(callId).then((call) {
        controller.add(call);
      }).catchError((e) {
        debugPrint('❌ [CALL PROVIDER] Error fetching call after reject: $e');
      });
    }
  });
  
  // Listen for call_ended (for both parties)
  socketService.onCallEnded((data) {
    if (data['callId'] == callId) {
      debugPrint('🔚 [CALL PROVIDER] Call ended via socket');
      // Fetch updated call status
      callService.getCallStatus(callId).then((call) {
        controller.add(call);
      }).catchError((e) {
        debugPrint('❌ [CALL PROVIDER] Error fetching call after end: $e');
      });
    }
  });
  
  // Fallback: Poll every 10 seconds as backup (much slower than before)
  Timer? pollTimer;
  pollTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
    try {
      final call = await callService.getCallStatus(callId);
      controller.add(call);
      
      // Stop polling if in terminal state
      if (call.status == CallStatus.ended || 
          call.status == CallStatus.rejected ||
          call.status == CallStatus.accepted) {
        timer.cancel();
        controller.close();
      }
    } catch (e) {
      debugPrint('⚠️  [CALL PROVIDER] Fallback poll error: $e');
    }
  });
  
  // Cleanup on dispose
  ref.onDispose(() {
    pollTimer?.cancel();
    socketService.off('call_accepted');
    socketService.off('call_rejected');
    socketService.off('call_ended');
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
    debugPrint('   CallId: ${data['callId']}');
    
    // Optionally verify call via API (ONCE per incoming call event)
    try {
      final calls = await callService.getIncomingCalls();
      currentCalls = calls;
      controller.add(calls);
      debugPrint('✅ [CALL PROVIDER] Verified incoming call via API');
    } catch (e) {
      debugPrint('⚠️  [CALL PROVIDER] Failed to verify call via API: $e');
      // Fallback: Create CallModel from socket data if API fails
      try {
        final callerData = data['caller'] as Map<String, dynamic>?;
        final newCall = CallModel(
          callId: data['callId'] as String,
          channelName: data['channelName'] as String,
          callerUserId: callerData?['id'] as String? ?? '',
          creatorUserId: '', // Will be set when we fetch from backend
          status: CallStatus.ringing,
          caller: callerData != null ? CallerInfo(
            id: callerData['id'] as String,
            username: callerData['username'] as String?,
            avatar: callerData['avatar'] as String?,
          ) : null,
        );
        
        // Add to current calls if not already present
        if (!currentCalls.any((c) => c.callId == newCall.callId)) {
          currentCalls = [newCall, ...currentCalls];
          controller.add(currentCalls);
          debugPrint('✅ [CALL PROVIDER] Added new incoming call to list (from socket data)');
        }
      } catch (parseError) {
        debugPrint('❌ [CALL PROVIDER] Error parsing incoming call: $parseError');
      }
    }
  });
  
  // Initialize with empty list - wait for socket events
  currentCalls = [];
  controller.add(currentCalls);
  yield currentCalls;
  
  // Cleanup on dispose
  ref.onDispose(() {
    socketService.off('incoming_call');
    controller.close();
  });
  
  // Yield from controller
  yield* controller.stream;
});
