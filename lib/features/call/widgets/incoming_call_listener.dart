import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/call_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../creator/providers/creator_status_provider.dart';
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

class _IncomingCallListenerState extends ConsumerState<IncomingCallListener>
    with WidgetsBindingObserver {
  String? _lastHandledCallId;
  final Set<String> _rejectedCallIds = {}; // Track rejected calls to prevent re-navigation

  /// Local guard to ensure we only ever navigate once per app/session.
  /// This kills most resurrection bugs caused by rebuilds / reconnects / provider refreshes.
  bool _hasHandledIncomingCall = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reset navigation guard ONLY when app fully resumes
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 [INCOMING CALL LISTENER] App resumed - resetting navigation guard');
      _hasHandledIncomingCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Only listen for incoming calls if user is authenticated and is a creator
    if (authState.isAuthenticated &&
        (authState.user?.role == 'creator' || authState.user?.role == 'admin')) {
      // Additionally gate on creator availability (online status)
      final creatorStatus = ref.watch(creatorStatusProvider);
      final isCreatorAvailable = creatorStatus == CreatorStatus.online;
      if (!isCreatorAvailable) {
        // Creator is not available for calls – pause listening entirely
        return widget.child;
      }

      // Watch incoming calls provider - this will start the stream and register socket listeners
      final incomingCallsAsync = ref.watch(incomingCallsProvider);

      incomingCallsAsync.whenData((calls) {
        // 🔍 DEBUG: Log full emission for race investigation
        final deadCalls = ref.read(deadCallIdsProvider);
        debugPrint(
          '📞 [INCOMING CALL LISTENER] incomingCallsProvider emitted: ${calls.map((c) => c.callId).toList()}',
        );
        debugPrint('☠️  [INCOMING CALL LISTENER] deadCalls: $deadCalls');

        // ✅ FIX #1 — Hard block inside IncomingCallListener using deadCallIds
        final validCalls = calls
            .where(
              (c) =>
                  c.status == CallStatus.ringing &&
                  !deadCalls.contains(c.callId),
            )
            .toList();

        if (validCalls.isEmpty) {
          debugPrint('🚫 [INCOMING CALL LISTENER] No valid ringing calls after dead-call filter');
          return;
        }

        // 🔒 GOLDEN RULE: If call status !== ringing, it must not exist in memory
        // This means: No lingering provider entries, no cached call IDs, no "handled" flags
        // Dead calls should be garbage-collected instantly.

        // 🔥 CRITICAL: Immediately mark any non-ringing calls to prevent navigation
        // This prevents stale calls from triggering navigation after page changes
        for (final call in validCalls) {
          if (call.status != CallStatus.ringing) {
            // Mark as handled if it's not ringing (rejected/ended/accepted/missed)
            if (!_rejectedCallIds.contains(call.callId)) {
              _rejectedCallIds.add(call.callId);
              debugPrint(
                '📝 [INCOMING CALL LISTENER] Marked call as handled: ${call.callId} (${call.status.name})',
              );
            }
            // Clear last handled if it matches this call
            if (call.callId == _lastHandledCallId) {
              _lastHandledCallId = null;
            }
          }
        }

        // 🔥 CRITICAL: Filter to ONLY ringing calls that haven't been rejected
        // This is the final guard against stale calls
        final activeCalls = validCalls
            .where(
              (call) =>
                  call.status == CallStatus.ringing &&
                  !_rejectedCallIds.contains(call.callId),
            )
            .toList();

        // 🔒 ONE-CALL-ONLY INVARIANT: Creator can have at most 1 ringing call
        // If provider ever has more than one → clear all and resync
        if (activeCalls.length > 1) {
          debugPrint('🚨 [INCOMING CALL LISTENER] VIOLATION: More than 1 ringing call!');
          debugPrint('   Found ${activeCalls.length} ringing calls - clearing provider');
          ref.invalidate(incomingCallsProvider);
          _rejectedCallIds.clear();
          _lastHandledCallId = null;
          return; // Don't navigate - wait for resync
        }

        debugPrint('📋 [INCOMING CALL LISTENER] Active ringing calls: ${activeCalls.length}');

        // Find the most recent ringing call that we haven't handled yet
        CallModel? ringingCall;
        try {
          ringingCall = activeCalls.firstWhere(
            (call) => call.status == CallStatus.ringing && call.callId != _lastHandledCallId,
          );
        } catch (e) {
          // No ringing call found
          ringingCall = null;
        }

        // Check if we're already on the incoming call screen to prevent duplicate navigation
        final currentRoute = GoRouterState.of(context).uri.toString();
        final isOnIncomingCallScreen = currentRoute.contains('/incoming-call');

        // ✅ FIX #2 — Track “already navigated” locally
        if (_hasHandledIncomingCall) {
          debugPrint(
            '🚫 [INCOMING CALL LISTENER] Navigation suppressed - already handled an incoming call in this session',
          );
          return;
        }

        if (ringingCall != null &&
            ringingCall.status == CallStatus.ringing &&
            !isOnIncomingCallScreen &&
            !_rejectedCallIds.contains(ringingCall.callId)) {
          // Mark this call as handled BEFORE navigation
          _lastHandledCallId = ringingCall.callId;
          _hasHandledIncomingCall = true;

          // Navigate to incoming call screen
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final currentRouteCheck = GoRouterState.of(context).uri.toString();
              final isStillOnIncomingCallScreen = currentRouteCheck.contains('/incoming-call');

              // Triple-check: route, rejected set, and call still ringing
              final callStillRinging = validCalls.any(
                (c) => c.callId == ringingCall!.callId && c.status == CallStatus.ringing,
              );

              if (!isStillOnIncomingCallScreen &&
                  !_rejectedCallIds.contains(ringingCall!.callId) &&
                  callStillRinging) {
                debugPrint('🚪 [INCOMING CALL LISTENER] Navigating to IncomingCallScreen');
                debugPrint('   CallId: ${ringingCall.callId}');
                debugPrint('   deadCalls at navigation: $deadCalls');

                context.push('/incoming-call', extra: {
                  'call': ringingCall,
                });
              } else {
                debugPrint('⚠️  [INCOMING CALL LISTENER] Skipping navigation');
                debugPrint('   Already on screen: $isStillOnIncomingCallScreen');
                debugPrint(
                  '   Call rejected: ${_rejectedCallIds.contains(ringingCall!.callId)}',
                );
                debugPrint('   Call still ringing: $callStillRinging');
              }
            }
          });
        }
      });
    }

    return widget.child;
  }
}
