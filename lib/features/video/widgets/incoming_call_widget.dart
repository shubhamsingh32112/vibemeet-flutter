import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../services/call_navigation_service.dart';
import '../services/permission_service.dart';

/// Widget to display incoming call notification
/// 
/// Shows when StreamVideo.instance.state.incomingCall is not null
/// Provides Accept and Reject buttons
class IncomingCallWidget extends ConsumerWidget {
  final Call incomingCall;

  const IncomingCallWidget({
    super.key,
    required this.incomingCall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Caller info
              CircleAvatar(
                radius: 60,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Incoming Call',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Video Call',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  _CallActionButton(
                    icon: Icons.call_end,
                    label: 'Reject',
                    color: Colors.red,
                    onPressed: () async {
                      try {
                        // Call reject() to properly reject the incoming call
                        await incomingCall.reject();
                        debugPrint('❌ [CALL] Call rejected by creator');
                      } catch (e) {
                        debugPrint('❌ [CALL] Error rejecting call: $e');
                      }
                    },
                  ),
                  // Accept button
                  _CallActionButton(
                    icon: Icons.call,
                    label: 'Accept',
                    color: Colors.green,
                    onPressed: () async {
                      try {
                        // 🔥 CRITICAL: Request permissions ONLY when user taps Accept
                        // Do NOT request permissions before Accept - Android can background app
                        // during permission dialog, which kills the ringing overlay
                        // 
                        // Strict order: permissions → accept → navigate → join
                        final hasPermissions = await PermissionService.ensurePermissions(video: true);
                        if (!hasPermissions) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera and microphone permissions are required for video calls'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          // No permissions → no accept → no side effects
                          return;
                        }
                        
                        // CRITICAL: Must call accept() AFTER permissions are granted
                        // This tells Stream that the call was accepted
                        await incomingCall.accept();
                        debugPrint('✅ [CALL] Call accepted');
                        
                        // 🔥 CRITICAL FIX: Navigate IMMEDIATELY after accept (BEFORE join)
                        // Navigate first so UI appears immediately
                        // join() will happen in background - call screen will handle state
                        CallNavigationService.navigateToCall(incomingCall);
                        
                        // Join the call in background (non-blocking)
                        // This allows UI to show immediately while connecting
                        incomingCall.join().then((_) {
                          debugPrint('✅ [CALL] Join completed successfully');
                        }).catchError((error) {
                          debugPrint('❌ [CALL] Error joining call: $error');
                          // Error is handled by call screen - user can see the failure state
                        });
                        debugPrint('✅ [CALL] Join initiated in background');
                      } catch (e) {
                        debugPrint('❌ [CALL] Error accepting call: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to accept call: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
