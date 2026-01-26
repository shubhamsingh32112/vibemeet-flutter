import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/call_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/call_model.dart';

/// Global widget that listens for incoming calls and navigates to incoming call screen
/// This should be placed in the widget tree so it's always active when user is authenticated
class IncomingCallListener extends ConsumerStatefulWidget {
  final Widget child;

  const IncomingCallListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends ConsumerState<IncomingCallListener> {
  String? _lastHandledCallId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Only listen for incoming calls if user is authenticated and is a creator
    if (authState.isAuthenticated && 
        (authState.user?.role == 'creator' || authState.user?.role == 'admin')) {
      // Watch incoming calls provider - this will start the stream and register socket listeners
      final incomingCallsAsync = ref.watch(incomingCallsProvider);
      
      incomingCallsAsync.whenData((calls) {
        // Find the most recent ringing call that we haven't handled yet
        CallModel? ringingCall;
        try {
          ringingCall = calls.firstWhere(
            (call) => call.status == CallStatus.ringing && call.callId != _lastHandledCallId,
          );
        } catch (e) {
          // No ringing call found
          ringingCall = null;
        }
        
        if (ringingCall != null && ringingCall.status == CallStatus.ringing) {
          // Mark this call as handled
          _lastHandledCallId = ringingCall.callId;
          
          // Navigate to incoming call screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint('📞 [INCOMING CALL LISTENER] Navigating to incoming call screen');
              debugPrint('   CallId: ${ringingCall!.callId}');
              context.push('/incoming-call', extra: {
                'call': ringingCall,
              });
            }
          });
        }
      });
    }
    
    return widget.child;
  }
}
