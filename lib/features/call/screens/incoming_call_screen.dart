import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/call_model.dart';
import '../services/call_service.dart';

// TASK 3: Creator – Incoming Call Screen
class IncomingCallScreen extends StatefulWidget {
  final CallModel call;

  const IncomingCallScreen({
    super.key,
    required this.call,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallService _callService = CallService();
  Timer? _timeoutTimer;
  int _remainingSeconds = 30; // 30 second timeout

  @override
  void initState() {
    super.initState();
    debugPrint('📞 [INCOMING CALL] Screen initialized');
    debugPrint('   CallId: ${widget.call.callId}');
    debugPrint('   Channel: ${widget.call.channelName}');
    debugPrint('   Caller: ${widget.call.caller?.username ?? "Unknown"}');
    debugPrint('   Status: ${widget.call.status.name}');
    _startTimeout();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
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
    
    try {
      _timeoutTimer?.cancel();
      debugPrint('   Timeout timer cancelled');
      
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
    } catch (e, stackTrace) {
      debugPrint('❌ [INCOMING CALL] Accept call error: $e');
      debugPrint('   Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept call: $e'),
            backgroundColor: Colors.red,
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
    
    try {
      _timeoutTimer?.cancel();
      debugPrint('   Timeout timer cancelled');
      
      debugPrint('🔄 [INCOMING CALL] Calling reject API...');
      await _callService.rejectCall(widget.call.callId);
      debugPrint('✅ [INCOMING CALL] Call rejected successfully');
      
      if (mounted) {
        debugPrint('🔄 [INCOMING CALL] Navigating back...');
        context.pop();
        debugPrint('✅ [INCOMING CALL] Screen closed');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [INCOMING CALL] Reject error: $e');
      debugPrint('   Stack: $stackTrace');
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final caller = widget.call.caller;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Caller avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              backgroundImage: caller?.avatar != null
                  ? AssetImage('lib/assets/${caller!.avatar}')
                  : null,
              child: caller?.avatar == null
                  ? Text(
                      caller?.username?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: 24),
            
            // Caller name
            Text(
              caller?.username ?? 'Unknown Caller',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Incoming call text
            const Text(
              'Incoming Video Call',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Timeout countdown
            Text(
              '$_remainingSeconds seconds',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            
            const Spacer(),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                GestureDetector(
                  onTap: _rejectCall,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
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
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
