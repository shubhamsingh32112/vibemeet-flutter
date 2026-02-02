import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/call_model.dart';
import '../services/call_service.dart';
import '../providers/call_provider.dart';
import '../../../core/services/socket_service.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/ui_primitives.dart';

// TASK 3: Creator – Incoming Call Screen
// 🔒 NAVIGATION GUARD: Auto-pop if provider becomes empty or status != ringing
class IncomingCallScreen extends ConsumerStatefulWidget {
  final CallModel call;

  const IncomingCallScreen({
    super.key,
    required this.call,
  });

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  final CallService _callService = CallService();
  final SocketService _socketService = SocketService();
  Timer? _timeoutTimer;
  int _remainingSeconds = 30; // 30 second timeout
  bool _actionTaken = false; // Track if accept/reject was called
  bool _isEndingCall = false; // Show loader while call is being cleanly disconnected

  @override
  void initState() {
    super.initState();
    debugPrint('📞 [INCOMING CALL] Screen initialized');
    debugPrint('   CallId: ${widget.call.callId}');
    debugPrint('   Channel: ${widget.call.channelName}');
    debugPrint('   Caller: ${widget.call.caller?.username ?? "Unknown"}');
    debugPrint('   Status: ${widget.call.status.name}');
    
    // 🔥 FIX: Set up socket listeners IMMEDIATELY to catch call_ended/rejected events
    // When user cuts call, we need to close this screen instantly
    _setupSocketListeners();
    
    _startTimeout();
  }
  
  // Set up socket listeners for call_ended and call_rejected
  void _setupSocketListeners() {
    debugPrint('🔌 [INCOMING CALL] Setting up socket listeners...');
    
    // Remove any existing listeners first
    _socketService.off('call_ended');
    _socketService.off('call_rejected');
    
    // 🔥 TERMINAL EVENT HANDLER: call_ended
    // This event means: This call will never be ringing again. Ever.
    // Do ALL of this synchronously: Kill memory, cancel timers, force-close UI
    _socketService.onCallEnded((data) {
      final callId = data['callId'] as String?;
      final reason = data['reason'] as String?;
      
      if (callId == widget.call.callId) {
        debugPrint('🔚 [INCOMING CALL] TERMINAL EVENT: call_ended received');
        debugPrint('   CallId: $callId');
        debugPrint('   Reason: $reason');
        debugPrint('   🚨 HARD TEARDOWN: No conditions, no checks, terminal means terminal');
        
        // 1. Kill all call memory (synchronously)
        _timeoutTimer?.cancel();
        _actionTaken = true;
        if (mounted) {
          setState(() {
            _isEndingCall = true;
          });
        }
        
        // 2. Clear provider immediately (no conditions)
        ref.invalidate(incomingCallsProvider);
        debugPrint('✅ [INCOMING CALL] Provider cleared');
        
        // 3. Force-close UI (no conditions)
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.canPop()) {
              Navigator.of(context).popUntil((r) => r.isFirst);
              debugPrint('✅ [INCOMING CALL] Screen force-closed (call_ended)');
            }
          });
        }
      }
    });
    
    // 🔥 TERMINAL EVENT HANDLER: call_rejected
    // This event means: This call will never be ringing again. Ever.
    // Do ALL of this synchronously: Kill memory, cancel timers, force-close UI
    _socketService.onCallRejected((data) {
      final callId = data['callId'] as String?;
      
      if (callId == widget.call.callId) {
        debugPrint('❌ [INCOMING CALL] TERMINAL EVENT: call_rejected received');
        debugPrint('   CallId: $callId');
        debugPrint('   🚨 HARD TEARDOWN: No conditions, no checks, terminal means terminal');
        
        // 1. Kill all call memory (synchronously)
        _timeoutTimer?.cancel();
        _actionTaken = true;
        if (mounted) {
          setState(() {
            _isEndingCall = true;
          });
        }
        
        // 2. Clear provider immediately (no conditions)
        ref.invalidate(incomingCallsProvider);
        debugPrint('✅ [INCOMING CALL] Provider cleared');
        
        // 3. Force-close UI (no conditions)
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.canPop()) {
              Navigator.of(context).popUntil((r) => r.isFirst);
              debugPrint('✅ [INCOMING CALL] Screen force-closed (call_rejected)');
            }
          });
        }
      }
    });
    
    debugPrint('✅ [INCOMING CALL] Socket listeners registered');
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    
    // Remove socket listeners
    _socketService.off('call_ended');
    _socketService.off('call_rejected');
    debugPrint('🔇 [INCOMING CALL] Socket listeners removed');
    
      // 🔥 FIX #1: Auto-reject if creator leaves without taking action
      // This prevents zombie calls that stay in "ringing" state forever
      if (widget.call.status == CallStatus.ringing && !_actionTaken) {
        debugPrint('🚨 [INCOMING CALL] Creator left screen without action - auto-rejecting call');
        debugPrint('   CallId: ${widget.call.callId}');
        // Fire and forget - don't await, just trigger the rejection
        _callService.rejectCall(widget.call.callId).then((_) {
          // 🔥 CRITICAL: Clear provider after reject
          ref.invalidate(incomingCallsProvider);
          debugPrint('✅ [INCOMING CALL] Provider cleared after auto-reject');
        }).catchError((e) {
          debugPrint('⚠️  [INCOMING CALL] Auto-reject error (non-blocking): $e');
        });
      }
    
    super.dispose();
  }

  // TASK 10: Timeout handling
  void _startTimeout() {
    debugPrint('⏱️  [INCOMING CALL] Starting 30-second timeout timer');
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          debugPrint('⏱️  [INCOMING CALL] Timeout reached, auto-rejecting call');
          timer.cancel();
          _rejectCall(); // Auto-reject on timeout
        } else if (_remainingSeconds % 10 == 0) {
          // Log every 10 seconds
          debugPrint('⏱️  [INCOMING CALL] Timeout countdown: $_remainingSeconds seconds remaining');
        }
      }
    });
  }

  // TASK 4: Accept call
  Future<void> _acceptCall() async {
    debugPrint('✅ [INCOMING CALL] Creator accepting call...');
    debugPrint('   CallId: ${widget.call.callId}');
    debugPrint('   Time remaining: $_remainingSeconds seconds');
    
    _actionTaken = true; // Mark action taken to prevent auto-reject in dispose
    if (mounted) {
      setState(() {
        _isEndingCall = true;
      });
    }
    
    try {
      _timeoutTimer?.cancel();
      debugPrint('   Timeout timer cancelled');
      
      // 🔥 CRITICAL: Verify call is still ringing before accepting
      // This prevents accepting calls that were already ended/rejected
      debugPrint('🔄 [INCOMING CALL] Verifying call status before accept...');
      final currentCall = await _callService.getCallStatus(widget.call.callId);
      
      if (currentCall.status != CallStatus.ringing) {
        debugPrint('⚠️  [INCOMING CALL] Call is no longer ringing (status: ${currentCall.status.name})');
        debugPrint('   Closing screen without accepting');
        
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call is already ${currentCall.status.name}'),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // Accept call via API
      debugPrint('🔄 [INCOMING CALL] Calling accept API...');
      final acceptedCall = await _callService.acceptCall(widget.call.callId);
      debugPrint('✅ [INCOMING CALL] Call accepted successfully');
      debugPrint('   Token received: ${acceptedCall.token != null}');
      debugPrint('   UID: ${acceptedCall.uid}');
      
      if (mounted) {
        debugPrint('🔄 [INCOMING CALL] Navigating to video call screen...');
        // Navigate to video call screen
        context.pushReplacement('/video-call', extra: {
          'callId': acceptedCall.callId,
          'channelName': acceptedCall.channelName,
          'token': acceptedCall.token,
          'uid': acceptedCall.uid,
        });
        debugPrint('✅ [INCOMING CALL] Navigation complete');
      }
      // Mark this call ID as locally dead so it can never resurrect as an incoming call
      try {
        ref.read(deadCallIdsProvider.notifier).state = {
          ...ref.read(deadCallIdsProvider.notifier).state,
          widget.call.callId,
        };
        debugPrint('✅ [INCOMING CALL] Marked call as locally dead on accept: ${widget.call.callId}');
      } catch (e) {
        debugPrint('⚠️  [INCOMING CALL] Failed to mark call as locally dead on accept: $e');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [INCOMING CALL] Accept call error: $e');
      debugPrint('   Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept call: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        context.pop();
      }
    }
  }

  // TASK 10: Reject call
  Future<void> _rejectCall() async {
    debugPrint('❌ [INCOMING CALL] Creator rejecting call...');
    debugPrint('   CallId: ${widget.call.callId}');
    debugPrint('   Time remaining: $_remainingSeconds seconds');
    
    _actionTaken = true; // Mark action taken to prevent auto-reject in dispose
    if (mounted) {
      setState(() {
        _isEndingCall = true;
      });
    }
    
    try {
      _timeoutTimer?.cancel();
      debugPrint('   Timeout timer cancelled');
      
      // Immediately pop the screen to prevent any race conditions
      if (mounted) {
        context.pop();
        debugPrint('🔄 [INCOMING CALL] Screen closed immediately');
      }
      
      // 🔥 CRITICAL: Clear provider immediately on reject
      // This ensures single-source-of-truth - dead calls don't linger
      ref.invalidate(incomingCallsProvider);
      debugPrint('✅ [INCOMING CALL] Provider cleared');

      // Mark this call ID as locally dead so it can never resurrect as an incoming call
      try {
        ref.read(deadCallIdsProvider.notifier).state = {
          ...ref.read(deadCallIdsProvider.notifier).state,
          widget.call.callId,
        };
        debugPrint('✅ [INCOMING CALL] Marked call as locally dead on reject: ${widget.call.callId}');
      } catch (e) {
        debugPrint('⚠️  [INCOMING CALL] Failed to mark call as locally dead on reject: $e');
      }
      
      debugPrint('🔄 [INCOMING CALL] Calling reject API...');
      await _callService.rejectCall(widget.call.callId);
      debugPrint('✅ [INCOMING CALL] Call rejected successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [INCOMING CALL] Reject error: $e');
      debugPrint('   Stack: $stackTrace');
      // Screen already popped, no need to pop again
    }
  }

  @override
  Widget build(BuildContext context) {
    final caller = widget.call.caller;
    
    // 🔒 NAVIGATION GUARD: Auto-pop if call is not ringing
    // This ensures page switches, hot reloads, widget rebuilds, and Riverpod invalidations
    // cannot resurrect a dead call.
    final incomingCallsAsync = ref.watch(incomingCallsProvider);
    incomingCallsAsync.whenData((calls) {
      final isRinging = calls.any((call) => 
        call.callId == widget.call.callId && call.status == CallStatus.ringing
      );
      
      if (!isRinging) {
        debugPrint('🚨 [INCOMING CALL] NAVIGATION GUARD: Call is not ringing');
        debugPrint('   CallId: ${widget.call.callId}');
        debugPrint('   🚨 This screen should not exist - auto-popping');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.canPop()) {
            Navigator.of(context).popUntil((r) => r.isFirst);
            debugPrint('✅ [INCOMING CALL] Screen auto-popped (not ringing)');
          }
        });
      }
    });

    final scheme = Theme.of(context).colorScheme;
    
    return AppScaffold(
      padded: false,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Caller avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.onSurface.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: AvatarWidget(
                    callerInfo: caller,
                    size: 120,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Caller name
                Text(
                  caller?.username ?? 'Unknown Caller',
                  style: TextStyle(
                    fontSize: 28,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Incoming call text
                Text(
                  'Incoming Video Call',
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Timeout countdown
                Text(
                  '$_remainingSeconds seconds',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                
                const Spacer(),
                
                // Action buttons
                if (!_isEndingCall)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reject button
                      GestureDetector(
                        onTap: _rejectCall,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: scheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.call_end,
                            color: scheme.onError,
                            size: 36,
                          ),
                        ),
                      ),
                      
                      // Accept button
                      GestureDetector(
                        onTap: _acceptCall,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.call,
                            color: scheme.onPrimary,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 48),
              ],
            ),

            // Ending call loader overlay
            if (_isEndingCall)
              Container(
                color: scheme.surface.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: scheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Ending call...',
                        style: TextStyle(color: scheme.onSurface, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
