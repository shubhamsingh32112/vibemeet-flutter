import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/call_model.dart';

// Helper functions for initiating and handling calls

/// Initiate a video call to a creator
/// Returns the call model if successful
Future<CallModel?> initiateVideoCall({
  required BuildContext context,
  required String creatorUserId,
  required Future<CallModel> Function(String) initiateCallFn,
}) async {
  debugPrint('📞 [CALL HELPER] Initiating video call');
  debugPrint('   Creator User ID: $creatorUserId');
  
  try {
    // Show loading
    debugPrint('🔄 [CALL HELPER] Showing loading dialog...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Initiate call
    debugPrint('🔄 [CALL HELPER] Calling initiateCallFn...');
    final call = await initiateCallFn(creatorUserId);
    debugPrint('✅ [CALL HELPER] Call initiated successfully');
    debugPrint('   CallId: ${call.callId}');
    debugPrint('   Channel: ${call.channelName}');
    debugPrint('   Status: ${call.status.name}');

    // Close loading
    if (context.mounted) {
      Navigator.of(context).pop();
      debugPrint('✅ [CALL HELPER] Loading dialog closed');

      // Navigate to video call screen (will poll for token)
      debugPrint('🔄 [CALL HELPER] Navigating to video call screen...');
      context.push('/video-call', extra: {
        'callId': call.callId,
        'channelName': call.channelName,
        'token': null, // Will poll for token
      });
      debugPrint('✅ [CALL HELPER] Navigation complete');
    }

    return call;
  } catch (e, stackTrace) {
    debugPrint('❌ [CALL HELPER] Initiate call error: $e');
    debugPrint('   Stack: $stackTrace');
    // Close loading if still open
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return null;
  }
}

/// Show incoming call screen for creator
void showIncomingCall({
  required BuildContext context,
  required CallModel call,
}) {
  debugPrint('📞 [CALL HELPER] Showing incoming call screen');
  debugPrint('   CallId: ${call.callId}');
  debugPrint('   Channel: ${call.channelName}');
  debugPrint('   Status: ${call.status.name}');
  debugPrint('   Caller: ${call.caller?.username ?? "Unknown"}');
  
  context.push('/incoming-call', extra: {
    'call': call,
  });
  
  debugPrint('✅ [CALL HELPER] Incoming call screen navigation triggered');
}
