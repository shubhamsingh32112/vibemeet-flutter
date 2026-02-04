import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../providers/stream_video_provider.dart';
import 'incoming_call_widget.dart';

/// Widget that listens for incoming calls and shows UI when call arrives
/// 
/// Should be placed high in the widget tree (e.g., in main app scaffold)
/// 
/// CRITICAL: Listens for CallRingingEvent to detect incoming calls
/// Stream Video does NOT auto-show incoming calls - you must explicitly listen
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
  Call? _incomingCall;
  StreamSubscription? _ringingSubscription;
  StreamSubscription? _incomingCallSubscription;
  StreamSubscription? _callStateSubscription;

  @override
  void initState() {
    super.initState();
    // Set up listener after first frame (when providers are ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupIncomingCallListener();
    });
  }

  void _setupIncomingCallListener() {
    final streamVideo = ref.read(streamVideoProvider);
    if (streamVideo == null) {
      debugPrint('⏳ [INCOMING CALL] Stream Video not initialized yet, will retry on next build');
      return;
    }

    // Cancel existing subscriptions if any
    _ringingSubscription?.cancel();
    _incomingCallSubscription?.cancel();

    debugPrint('📞 [INCOMING CALL] Setting up incoming call listener');

    // Method 1: Listen for CoordinatorCallRingingEvent via events stream
    // This fires when a call starts ringing
    // CRITICAL: Without this listener, incoming calls are received but never shown
    _ringingSubscription = streamVideo.events.listen((event) {
      if (event is CoordinatorCallRingingEvent) {
        debugPrint('📞 [INCOMING CALL] CoordinatorCallRingingEvent received');
        debugPrint('   Call CID: ${event.callCid}');
        debugPrint('   Call Type: ${event.callCid.type}, ID: ${event.callCid.id}');
        debugPrint('   Video: ${event.video}');
        
        // Get the call object using makeCall (this retrieves existing call)
        // We use defaultType() since all our calls use 'default' type
        final call = streamVideo.makeCall(
          callType: StreamCallType.defaultType(),
          id: event.callCid.id,
        );
        
        debugPrint('✅ [INCOMING CALL] Call object retrieved: ${call.id}');
        if (mounted) {
          setState(() {
            _incomingCall = call;
          });
        }
      }
    });

    // Method 2: Also listen to state.incomingCall (recommended - simpler approach)
    // This is a StateEmitter that updates when incoming call changes
    // This automatically provides the Call object when a call is ringing
    _incomingCallSubscription = streamVideo.state.incomingCall.listen((call) {
      // Cancel previous call state subscription if any
      _callStateSubscription?.cancel();
      
      if (call != null) {
        debugPrint('📞 [INCOMING CALL] Incoming call detected via state: ${call.id}');
        if (mounted) {
          setState(() {
            _incomingCall = call;
          });
        }
        
        // 🔥 CRITICAL FIX: Listen to call state changes to clear incoming call overlay
        // When call is joined/connected, clear the incoming call state
        // This ensures the overlay disappears when call is accepted
        _callStateSubscription = call.state.listen((callState) {
          final status = callState.status;
          if (status.isJoined || status.isConnected) {
            debugPrint('✅ [INCOMING CALL] Call joined/connected - clearing incoming call overlay');
            if (mounted) {
              setState(() {
                _incomingCall = null;
              });
            }
            // Cancel subscription once call is joined (no longer incoming)
            _callStateSubscription?.cancel();
            _callStateSubscription = null;
          }
        });
      } else {
        debugPrint('📞 [INCOMING CALL] Incoming call cleared');
        if (mounted) {
          setState(() {
            _incomingCall = null;
          });
        }
      }
    });

    debugPrint('✅ [INCOMING CALL] Listener set up successfully');
  }

  @override
  void didUpdateWidget(IncomingCallListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-setup listener if Stream Video becomes available
    final streamVideo = ref.read(streamVideoProvider);
    if (streamVideo != null && _ringingSubscription == null) {
      _setupIncomingCallListener();
    }
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    _incomingCallSubscription?.cancel();
    _callStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch Stream Video provider - set up listener when it becomes available
    final streamVideo = ref.watch(streamVideoProvider);
    
    // Set up listener if Stream Video is available but listener isn't set up yet
    if (streamVideo != null && _ringingSubscription == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setupIncomingCallListener();
        }
      });
    }
    
    // Also check state.incomingCall as fallback (in case event listener missed it)
    // CRITICAL: Use valueOrNull instead of .value - ValueStream doesn't always have a value
    // Accessing .value when hasValue == false causes runtime exception
    final stateIncomingCall = streamVideo?.state.incomingCall.valueOrNull;
    
    // Use either the event-based call or the state-based call
    final incomingCall = _incomingCall ?? stateIncomingCall;

    // 🔥 CRITICAL FIX: Only show overlay if call is actually incoming (ringing)
    // If call is already joined/connected, don't show overlay (it was accepted)
    if (incomingCall != null) {
      // Check call state - if already joined/connected, don't show overlay
      final callState = incomingCall.state.valueOrNull;
      final status = callState?.status;
      if (status != null && (status.isJoined || status.isConnected)) {
        // Call is already joined - clear incoming call state and don't show overlay
        if (_incomingCall != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _incomingCall = null;
              });
            }
          });
        }
        return widget.child;
      }
      
      // Call is still ringing - show overlay
      return Stack(
        children: [
          widget.child,
          // Full-screen overlay for incoming call
          Material(
            color: Colors.black54,
            child: IncomingCallWidget(incomingCall: incomingCall),
          ),
        ],
      );
    }

    // No incoming call, show normal UI
    return widget.child;
  }
}
