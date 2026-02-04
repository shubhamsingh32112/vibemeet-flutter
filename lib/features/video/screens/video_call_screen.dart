import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../services/security_service.dart';
import '../services/call_service.dart';
import '../providers/stream_video_provider.dart';
import '../services/call_navigation_service.dart';

/// Screen for active video call
/// 
/// 🔥 CRITICAL: Reads call ONLY from StreamVideo.state.activeCall (single source of truth)
/// Router extras are NOT used - Stream state is authoritative
/// 
/// Uses StreamCallContainer with restrictions:
/// - Screen sharing disabled
/// - Recording disabled
/// - Broadcasting disabled
/// - Camera and microphone enabled
/// - Platform-level screenshot/recording blocking (Phase 6)
class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 CRITICAL: Read call ONLY from StreamVideo state (reactive)
    // This ensures buttons control the correct call instance
    // Router extras are NOT used - prevents stale call references
    final streamVideo = ref.watch(streamVideoProvider);
    final call = streamVideo?.state.activeCall.valueOrNull;

    if (call == null) {
      // No call available - show loading and navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'No active call',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return _VideoCallScreenContent(call: call);
  }
}

/// Internal stateful widget for call screen content
class _VideoCallScreenContent extends ConsumerStatefulWidget {
  final Call call;

  const _VideoCallScreenContent({required this.call});

  @override
  ConsumerState<_VideoCallScreenContent> createState() => _VideoCallScreenContentState();
}

class _VideoCallScreenContentState extends ConsumerState<_VideoCallScreenContent> {
  bool _isScreenCaptured = false;

  @override
  void initState() {
    super.initState();
    _setupSecurity();
    _checkMaxParticipants();
    
    // Listen for participant changes
    widget.call.state.listen((state) {
      _checkMaxParticipants();
    });
  }

  @override
  void dispose() {
    // Disable security when leaving call screen
    SecurityService.disableCallSecurity();
    super.dispose();
  }

  /// Phase 4: Max participants enforcement (double lock)
  /// 
  /// Defense in depth: Check participant count client-side
  /// Protects against:
  /// - Misconfigured dashboard permissions
  /// - Accidental future feature creep
  /// 
  /// If participantCount > 2, immediately leave call
  void _checkMaxParticipants() {
    final callStateEmitter = widget.call.state;
    if (!callStateEmitter.hasValue) return;
    
    final callState = callStateEmitter.value;
    final participants = callState.callParticipants;
    final participantCount = participants.length;

    if (participantCount > 2) {
      debugPrint('🚨 [CALL] Max participants exceeded: $participantCount (max: 2)');
      debugPrint('   Leaving call immediately for security');
      
      // Log error for monitoring
      debugPrint('❌ [CALL] SECURITY VIOLATION: More than 2 participants detected');
      
      // Leave call immediately
      _handleMaxParticipantsExceeded();
    }
  }

  /// Handle max participants exceeded
  Future<void> _handleMaxParticipantsExceeded() async {
    try {
      final callService = ref.read(callServiceProvider);
      await callService.leaveCall(widget.call);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call ended: Maximum participants exceeded'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        
        // Navigate back
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('❌ [CALL] Error handling max participants: $e');
    }
  }

  /// Setup platform-level security (Phase 6)
  Future<void> _setupSecurity() async {
    // Enable security (Android: FLAG_SECURE, iOS: screen capture detection)
    await SecurityService.enableCallSecurity();

    // Listen for screen capture changes (iOS)
    SecurityService.setOnScreenCaptureChanged((isCaptured) {
      if (mounted) {
        setState(() {
          _isScreenCaptured = isCaptured;
        });

        if (isCaptured) {
          // Screen recording detected - disconnect call
          debugPrint('🚫 [SECURITY] Screen recording detected - disconnecting call');
          _handleScreenCaptureDetected();
        }
      }
    });
  }

  /// Handle screen capture detection (iOS)
  /// 
  /// Disconnects call when screen recording starts
  Future<void> _handleScreenCaptureDetected() async {
    try {
      final callService = ref.read(callServiceProvider);
      await callService.leaveCall(widget.call);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call ended: Screen recording detected'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Navigate back
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('❌ [SECURITY] Error handling screen capture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamCallContainer(
            call: widget.call,
            callConnectOptions: CallConnectOptions(
              camera: TrackOption.enabled(),
              microphone: TrackOption.enabled(),
              screenShare: TrackOption.disabled(), // Explicitly disabled
            ),
            onCallDisconnected: (CallDisconnectedProperties properties) {
              debugPrint('📞 [CALL] Call disconnected');
              debugPrint('   Reason: ${properties.reason}');
              _handleCallDisconnected(context, properties.reason);
            },
          ),
          // Show overlay if screen capture detected (iOS)
          if (_isScreenCaptured)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Screen recording detected',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Call will be disconnected',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Handle call disconnection (Phase 7)
  /// 
  /// Called when:
  /// - Either participant leaves
  /// - Network drops beyond retry limit
  /// - Creator rejects
  void _handleCallDisconnected(BuildContext context, DisconnectReason reason) {
    // Mark call screen as exited
    CallNavigationService.onCallScreenExited();
    
    // Navigate back when call ends
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
