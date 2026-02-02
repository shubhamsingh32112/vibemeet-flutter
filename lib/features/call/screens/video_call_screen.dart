import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../agora_logic.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/socket_service.dart';
import '../services/call_service.dart';
import '../providers/call_provider.dart';
import '../../../shared/models/call_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../user/providers/user_provider.dart';

// TASK 8: Flutter – Video Call Screen
// Single reusable screen for both user and creator
class VideoCallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String channelName;
  final String? token; // If null, will poll for token
  final int? uid; // Agora UID (optional, will be auto-assigned if not provided)
  final VoidCallback? onEndCall;
  final CallerInfo? caller; // Caller info (for avatar)
  final CreatorInfo? creator; // Creator info (for avatar)
  final UserModel? currentUser; // Current user info (for local avatar)

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.channelName,
    this.token,
    this.uid,
    this.onEndCall,
    this.caller,
    this.creator,
    this.currentUser,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> with WidgetsBindingObserver {
  final CallService _callService = CallService();
  final SocketService _socketService = SocketService();
  bool _isInitialized = false;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _hasEnded = false; // 🚨 FIX: Prevent duplicate end call API calls
  bool _isJoiningChannel = false; // Track if we're currently joining to prevent duplicates
  bool _remoteVideoEnabled = true; // Track remote video state
  bool _isEndingCall = false; // Show loader while call is being cleanly disconnected
  bool _ratingPromptShown = false; // Prevent duplicate rating prompts
  Timer? _remoteJoinFallbackTimer; // One-shot safety net if caller ends before remote joins
  StreamSubscription<int?>? _remoteUidSubscription;
  StreamSubscription<bool>? _localUserJoinedSubscription;
  StreamSubscription<bool>? _remoteVideoEnabledSubscription;
  void Function(Map<String, dynamic>)? _callEndedHandler;
  
  // Phase R2: Removed _pollTimer, _pollingStopped, _callEnded, _callData
  // All state now comes from callStatusProvider

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('📞 [VIDEO CALL] Screen initialized');
    debugPrint('   CallId: ${widget.callId}');
    debugPrint('   Channel: ${widget.channelName}');
    debugPrint('   HasToken: ${widget.token != null}');
    debugPrint('   Phase R2: Reading from callStatusProvider only (no polling)');
    debugPrint('   Phase R5: Provider owns primary socket listeners, screen has safety listener for call_ended');

    // Safety net: listen directly for call_ended so BOTH sides always tear down,
    // even if provider stream isn't active for some reason.
    _callEndedHandler = (data) {
      final callId = data['callId'] as String?;
      final endedBy = data['endedBy'] as String?;
      debugPrint('🔚 [VIDEO CALL] call_ended (screen-level) received: $callId endedBy=$endedBy');
      if (callId == widget.callId && mounted && !_hasEnded) {
        _handleCallEnded(endedBy: endedBy);
      } else {
        debugPrint('⚠️  [VIDEO CALL] Ignoring call_ended (screen-level) for different/ended call');
      }
    };
    _socketService.onCallEnded(_callEndedHandler!);

    _initializeCall();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _remoteUidSubscription?.cancel();
    _localUserJoinedSubscription?.cancel();
    _remoteVideoEnabledSubscription?.cancel();
    _remoteJoinFallbackTimer?.cancel();

    // Cleanup screen-level safety listener for call_ended
    if (_callEndedHandler != null) {
      _socketService.removeListener('call_ended', _callEndedHandler!);
      _callEndedHandler = null;
    }
    
    // 🔥 FIX #4: Force Agora cleanup on dispose - no conditions, no mercy
    // Agora lingering = ghost calls
    debugPrint('🚨 [VIDEO CALL] Force cleaning up Agora on dispose...');
    _forceCleanupAgora();
    
    _cleanup();
    super.dispose();
  }
  
  // Force cleanup Agora - called on dispose, route pop, lifecycle, errors
  Future<void> _forceCleanupAgora() async {
    try {
      if (AgoraLogic.isInChannel) {
        await AgoraLogic.leaveChannel();
        debugPrint('✅ [VIDEO CALL] Left Agora channel (force cleanup)');
      }
      if (AgoraLogic.isInitialized) {
        await AgoraLogic.release();
        debugPrint('✅ [VIDEO CALL] Released Agora engine (force cleanup)');
      }
    } catch (e) {
      debugPrint('⚠️  [VIDEO CALL] Force cleanup error (non-blocking): $e');
      // Non-blocking - dispose must complete
    }
  }

  // TASK 10: Handle app backgrounding
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 [VIDEO CALL] App lifecycle changed: $state');
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      debugPrint('   ⚠️  App backgrounded, ending call...');
      // Auto end call when app goes to background
      _endCall();
    } else if (state == AppLifecycleState.detached) {
      // 🔥 FIX #4: Force cleanup on app termination
      debugPrint('   🚨 App detached, force cleaning up Agora...');
      _forceCleanupAgora();
    }
  }

  // TASK 7: Agora Initialization Flow
  Future<void> _initializeCall() async {
    debugPrint('🔄 [VIDEO CALL] Starting call initialization');
    debugPrint('   CallId: ${widget.callId}');
    debugPrint('   Channel: ${widget.channelName}');
    
    try {
      // Step 0: Socket listeners already set up synchronously in initState()
      // This ensures we catch events even during initialization
      debugPrint('✅ [VIDEO CALL] Socket listeners already registered (from initState)');

      // Step 1: Request permissions
      debugPrint('📋 [VIDEO CALL] Step 1: Requesting permissions...');
      final hasPermissions = await AgoraLogic.requestPermissions();
      if (!hasPermissions) {
        debugPrint('❌ [VIDEO CALL] Permissions denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera and microphone permissions are required'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
        return;
      }
      debugPrint('✅ [VIDEO CALL] Permissions granted');

      // Step 2: Initialize Agora
      debugPrint('🔄 [VIDEO CALL] Step 2: Initializing Agora engine...');
      final initialized = await AgoraLogic.initializeAgora(AppConstants.agoraAppId);
      if (!initialized) {
        debugPrint('❌ [VIDEO CALL] Agora initialization failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize video call'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
        return;
      }
      debugPrint('✅ [VIDEO CALL] Agora engine initialized');

      // Step 3: Setup event handlers (BEFORE joining channel)
      debugPrint('🔄 [VIDEO CALL] Step 3: Setting up event handlers...');
      AgoraLogic.setupEventHandlers();
      debugPrint('✅ [VIDEO CALL] Event handlers registered');

      // Step 4: Enable video and preview
      debugPrint('🔄 [VIDEO CALL] Step 4: Enabling video and preview...');
      await AgoraLogic.enableVideoAndPreview();
      debugPrint('✅ [VIDEO CALL] Video enabled and preview started');

      // Step 6: Setup stream subscriptions BEFORE joining (to catch immediate events)
      debugPrint('🔄 [VIDEO CALL] Step 6: Setting up stream subscriptions...');
      _setupStreamSubscriptions();
      debugPrint('✅ [VIDEO CALL] Stream subscriptions registered');

      // Phase R2: Step 7 - Watch provider for token instead of polling
      String? token = widget.token;
      if (token == null) {
        debugPrint('🔄 [VIDEO CALL] Step 7: No token provided, watching provider...');
        // Phase R2: Watch callStatusProvider for token
        final callStatusAsync = ref.read(callStatusProvider(widget.callId));
        callStatusAsync.whenData((call) {
          if (call.status == CallStatus.accepted && call.token != null && !_localUserJoined && !_isJoiningChannel) {
            debugPrint('✅ [VIDEO CALL] Token received from provider, joining channel...');
            _joinChannel(call.token!, uid: call.uid);
          } else if (call.status == CallStatus.ended || call.status == CallStatus.rejected) {
            debugPrint('⚠️  [VIDEO CALL] Call ${call.status.name} detected from provider');
            _handleCallEnded();
          }
        });
        return; // Wait for provider to emit token
      }
      debugPrint('✅ [VIDEO CALL] Token provided, proceeding to join channel');

      // Step 8: Join channel
      debugPrint('🔄 [VIDEO CALL] Step 8: Joining channel...');
      await _joinChannel(token, uid: widget.uid);
    } catch (e, stackTrace) {
      debugPrint('❌ [VIDEO CALL] Initialize error: $e');
      debugPrint('   Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }


  // Phase R2: Handle call ended from provider state change
  // Provider already handled socket event (Phase R1), we just react to state
  Future<void> _handleCallEnded({String? endedBy}) async {
    if (_hasEnded) {
      debugPrint('⚠️  [VIDEO CALL] Call already ended, ignoring duplicate event');
      return;
    }
    
    debugPrint('🔚 [VIDEO CALL] Handling call ended (from provider state)...');
    debugPrint('   Ended by: ${endedBy ?? "unknown"}');
    debugPrint('   Phase R2: Provider already handled socket event, we just react');
    
    // Mark as ended IMMEDIATELY - no conditions, no checks
    _hasEnded = true;
    
    if (mounted) {
      // 🔥 CRITICAL: Update UI state IMMEDIATELY (synchronously) before async cleanup
      // This ensures "Waiting for remote user" message disappears instantly
      // Phase R2: Removed _callEnded (no longer exists)
      setState(() {
        _hasEnded = true;
      });
      
      // Show message if ended by other party
      if (endedBy != null && endedBy != 'system') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Call ended by ${endedBy == 'caller' ? 'user' : 'creator'}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // 🔥 FIX #4: Force Agora cleanup - no conditions, no mercy
      debugPrint('🔄 [VIDEO CALL] Force cleaning up Agora (hard kill)...');
      try {
        await AgoraLogic.leaveChannel();
        await AgoraLogic.release();
        debugPrint('✅ [VIDEO CALL] Agora force cleaned up');
      } catch (e) {
        debugPrint('⚠️  [VIDEO CALL] Agora cleanup error (non-blocking): $e');
        // Continue anyway - navigation is more important
      }
      
      // Phase C3: No refreshUser() here — coins are updated via coins_updated socket event

      // If this is an end-user (caller), prompt for rating before leaving
      await _maybePromptForRating();

      // Navigate back
      if (mounted) {
        debugPrint('🔄 [VIDEO CALL] Navigating back...');
        widget.onEndCall?.call();
        context.pop();
        debugPrint('✅ [VIDEO CALL] Screen closed');
      }
    }
  }

  // Phase R2: Removed _startPolling() - provider owns all polling
  // Screen now watches callStatusProvider and reacts to state changes

  // Setup stream subscriptions (called once before joining)
  void _setupStreamSubscriptions() {
    // Cancel existing subscriptions to prevent duplicates
    _remoteUidSubscription?.cancel();
    _localUserJoinedSubscription?.cancel();
    
    // Get current remote UID value (in case remote user already joined)
    final currentRemoteUid = AgoraLogic.remoteUid;
    if (currentRemoteUid != null) {
      debugPrint('👤 [VIDEO CALL] Remote user already in channel: UID $currentRemoteUid');
      if (mounted) {
        setState(() {
          _remoteUid = currentRemoteUid;
        });
      }
    }
    
    // Listen to remote UID stream
    _remoteUidSubscription = AgoraLogic.remoteUidStream.listen((uid) {
      if (mounted) {
        if (uid != null) {
          debugPrint('👤 [VIDEO CALL] Remote user joined: UID $uid');
          _remoteJoinFallbackTimer?.cancel();
        } else if (_remoteUid != null) {
          debugPrint('👋 [VIDEO CALL] Remote user left (UID was $_remoteUid)');
        }
        
        setState(() {
          _remoteUid = uid;
        });
        
        // TASK 2: Handle connection lost / token expiry
        // 🔥 FIX: Only handle connection lost if call hasn't already ended
        // Phase R2: Provider handles call_ended, we just react to connection loss
        if (uid == null && _remoteUid != null && !_hasEnded) {
          // Connection was lost - end call
          debugPrint('⚠️  [VIDEO CALL] Connection lost detected (call not ended yet)');
          _handleConnectionLost();
        } else if (uid == null && _remoteUid != null && _hasEnded) {
          debugPrint('✅ [VIDEO CALL] Remote user left, but call already ended - ignoring connection lost');
        }
      }
    });

    // Get current local user joined status
    final currentLocalJoined = AgoraLogic.localUserJoined;
    if (currentLocalJoined) {
      debugPrint('✅ [VIDEO CALL] Local user already joined');
      if (mounted) {
        setState(() {
          _localUserJoined = currentLocalJoined;
        });
      }
      _startRemoteJoinFallbackIfNeeded();
    }

    // Listen to local user joined stream
    _localUserJoinedSubscription = AgoraLogic.localUserJoinedStream.listen((joined) {
      if (mounted) {
        debugPrint('${joined ? "✅" : "❌"} [VIDEO CALL] Local user ${joined ? "joined" : "left"} channel');
        setState(() {
          _localUserJoined = joined;
          if (joined) {
            _isJoiningChannel = false; // Reset flag when successfully joined
          }
        });
        if (joined) {
          _startRemoteJoinFallbackIfNeeded();
        } else {
          _remoteJoinFallbackTimer?.cancel();
        }
      }
    });

    // Get current remote video enabled status
    final currentRemoteVideoEnabled = AgoraLogic.remoteVideoEnabled;
    if (mounted) {
      setState(() {
        _remoteVideoEnabled = currentRemoteVideoEnabled;
      });
    }

    // Listen to remote video enabled stream
    _remoteVideoEnabledSubscription = AgoraLogic.remoteVideoEnabledStream.listen((enabled) {
      if (mounted) {
        debugPrint('${enabled ? "📹" : "📷"} [VIDEO CALL] Remote video ${enabled ? "enabled" : "disabled"}');
        setState(() {
          _remoteVideoEnabled = enabled;
        });
      }
    });
  }

  void _startRemoteJoinFallbackIfNeeded() {
    if (_hasEnded || _remoteUid != null) return;
    _remoteJoinFallbackTimer?.cancel();

    _remoteJoinFallbackTimer = Timer(const Duration(seconds: 5), () async {
      if (!mounted || _hasEnded || _remoteUid != null) return;
      try {
        debugPrint('🕒 [VIDEO CALL] Remote still missing - doing one-shot status check...');
        final status = await _callService.getCallStatus(widget.callId);
        if (status.status == CallStatus.ended || status.status == CallStatus.rejected) {
          debugPrint('✅ [VIDEO CALL] Status is terminal (${status.status.name}) - closing call');
          await _handleCallEnded();
        }
      } catch (e) {
        debugPrint('⚠️  [VIDEO CALL] One-shot status check failed (non-fatal): $e');
      }
    });
  }

  Future<void> _joinChannel(String token, {int? uid}) async {
    // Prevent duplicate joins
    if (_localUserJoined) {
      debugPrint('⚠️  [VIDEO CALL] Already joined, skipping duplicate join');
      return;
    }
    
    if (_isJoiningChannel) {
      debugPrint('⚠️  [VIDEO CALL] Already joining, skipping duplicate join');
      return;
    }
    
    // Set flag to prevent duplicate joins
    _isJoiningChannel = true;
    
    debugPrint('🔄 [VIDEO CALL] Joining Agora channel...');
    debugPrint('   Channel: ${widget.channelName}');
    debugPrint('   UID: ${uid ?? 0}');
    debugPrint('   Token: ${token.substring(0, 20)}...');
    
    try {
      // Leave any existing channel first to avoid error -17
      if (AgoraLogic.isInChannel) {
        debugPrint('⚠️  [VIDEO CALL] Already in a channel, leaving first...');
        await AgoraLogic.leaveChannel();
        // Wait a bit for cleanup
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final joined = await AgoraLogic.joinChannel(
        channelName: widget.channelName,
        token: token,
        uid: uid ?? 0, // Use provided UID or auto-assign
      );

      if (joined) {
        debugPrint('✅ [VIDEO CALL] Join channel request sent successfully');
        setState(() {
          _isInitialized = true;
        });
        debugPrint('✅ [VIDEO CALL] Channel join complete, waiting for participants...');
      } else {
        debugPrint('❌ [VIDEO CALL] Join channel request failed');
        _isJoiningChannel = false; // Reset flag on failure
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [VIDEO CALL] Join channel error: $e');
      debugPrint('   Stack: $stackTrace');
      _isJoiningChannel = false; // Reset flag on error
      
      // Handle specific Agora error -17 (already in channel)
      if (e.toString().contains('-17') || e.toString().contains('ERR_JOIN_CHANNEL_REJECTED')) {
        debugPrint('⚠️  [VIDEO CALL] Error -17: Already in channel, attempting to leave and rejoin...');
        try {
          await AgoraLogic.leaveChannel();
          await Future.delayed(const Duration(milliseconds: 500));
          // Retry join once
          final retryJoined = await AgoraLogic.joinChannel(
            channelName: widget.channelName,
            token: token,
            uid: uid ?? 0,
          );
          if (retryJoined) {
            debugPrint('✅ [VIDEO CALL] Successfully joined after retry');
            return;
          }
        } catch (retryError) {
          debugPrint('❌ [VIDEO CALL] Retry join failed: $retryError');
        }
      }
      
      // 🔥 FIX #4: Force cleanup on error
      await _forceCleanupAgora();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join call: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  // TASK 9: End call handling
  Future<void> _endCall() async {
    // 🚨 FIX: Idempotency check - prevent duplicate end calls
    if (_hasEnded) {
      debugPrint('⚠️  [VIDEO CALL] Call already ended, skipping duplicate end call');
      return;
    }
    
    debugPrint('🔚 [VIDEO CALL] Ending call...');
    debugPrint('   CallId: ${widget.callId}');
    if (mounted) {
      setState(() {
        _isEndingCall = true;
      });
    }
    
    // Mark as ended immediately to prevent duplicate calls
    _hasEnded = true;
    
    // Phase R2: No polling to stop - provider owns polling
    debugPrint('   Call ending...');

    // Clean up Agora first (before API call) for instant disconnection
    debugPrint('🔄 [VIDEO CALL] Leaving Agora channel...');
    try {
      await AgoraLogic.leaveChannel();
      debugPrint('✅ [VIDEO CALL] Left Agora channel');
    } catch (e) {
      debugPrint('⚠️  [VIDEO CALL] Error leaving channel: $e');
    }

    // Call API to notify backend and other party
    try {
      debugPrint('🔄 [VIDEO CALL] Calling end call API...');
      await _callService.endCall(widget.callId);
      debugPrint('✅ [VIDEO CALL] End call API called successfully');
      
      // Phase C3: No refreshUser() here — coins are updated via coins_updated socket event
    } catch (e) {
      debugPrint('❌ [VIDEO CALL] End call API error: $e');
      // Don't reset _hasEnded on error - still prevent duplicate calls
      // Agora is already cleaned up, so call is effectively ended
    }

    // Release Agora engine
    debugPrint('🔄 [VIDEO CALL] Releasing Agora engine...');
    try {
      await AgoraLogic.release();
      debugPrint('✅ [VIDEO CALL] Agora engine released');
    } catch (e) {
      debugPrint('⚠️  [VIDEO CALL] Error releasing engine: $e');
    }

    // Navigate back
    if (mounted) {
      debugPrint('🔄 [VIDEO CALL] Navigating back...');
      // If this is an end-user (caller), prompt for rating before leaving
      await _maybePromptForRating();
      widget.onEndCall?.call();
      context.pop();
      debugPrint('✅ [VIDEO CALL] Call ended and screen closed');
    }

    // Mark this call ID as locally dead so it can never resurrect as an incoming call
    try {
      ref.read(deadCallIdsProvider.notifier).state = {
        ...ref.read(deadCallIdsProvider.notifier).state,
        widget.callId,
      };
      debugPrint('✅ [VIDEO CALL] Marked call as locally dead: ${widget.callId}');
    } catch (e) {
      debugPrint('⚠️  [VIDEO CALL] Failed to mark call as locally dead: $e');
    }
  }

  Future<void> _maybePromptForRating() async {
    if (_ratingPromptShown) return;
    if (!mounted) return;

    _ratingPromptShown = true;

    // Resolve current user (route doesn't always pass currentUser into VideoCallScreen)
    UserModel? currentUser = widget.currentUser;
    currentUser ??= await ref.read(userProvider.future);

    if (!mounted || currentUser == null) return;

    // Only end-users can rate (creators/admins must never see this dialog)
    if (currentUser.role == 'creator' || currentUser.role == 'admin') return;

    // Check if this user is the caller and if already rated (caller-only visibility from backend)
    try {
      final status = await _callService.getCallStatus(widget.callId);
      final callerUserId = (status.callerUserId).isNotEmpty ? status.callerUserId : (status.caller?.id ?? '');
      final isCaller = callerUserId.isNotEmpty && callerUserId == currentUser.id;
      if (!isCaller) return;

      if (status.rating != null) {
        debugPrint('⭐ [VIDEO CALL] Call already rated (${status.rating}), skipping prompt');
        return;
      }
    } catch (e) {
      // Non-fatal: still allow rating attempt; backend will enforce correctness
      debugPrint('⚠️  [VIDEO CALL] Failed to fetch status before rating prompt (non-fatal): $e');
      return; // Without call status we can't safely know caller; don't show dialog.
    }

    final selectedRating = await _showRatingDialog();
    if (selectedRating == null) {
      debugPrint('⭐ [VIDEO CALL] User skipped rating');
      return;
    }

    try {
      await _callService.rateCall(callId: widget.callId, rating: selectedRating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks for rating!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [VIDEO CALL] Rating submission failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<int?> _showRatingDialog() async {
    if (!mounted) return null;

    int tempRating = 0;
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildStar(int index) {
              final filled = index <= tempRating;
              return IconButton(
                onPressed: () => setDialogState(() => tempRating = index),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }

            return AlertDialog(
              title: const Text('Rate this creator'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How was your call?'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildStar(1),
                      buildStar(2),
                      buildStar(3),
                      buildStar(4),
                      buildStar(5),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Skip'),
                ),
                FilledButton(
                  onPressed: tempRating >= 1 ? () => Navigator.of(context).pop(tempRating) : null,
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // TASK 2: Handle connection lost / token expiry
  Future<void> _handleConnectionLost() async {
    // 🔥 FIX: Don't handle connection lost if call already ended
    // Phase R2: Removed _callEnded check (no longer exists)
    if (_hasEnded) {
      debugPrint('⚠️  [VIDEO CALL] Connection lost, but call already ended - ignoring');
      return;
    }
    
    debugPrint('⚠️  [VIDEO CALL] Connection lost handler triggered');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection lost. Ending call...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      
      debugPrint('   Waiting 1 second before ending call...');
      // Auto-end call when connection is lost
      await Future.delayed(const Duration(seconds: 1));
      await _endCall();
    }
  }

  Future<void> _cleanup() async {
    // Phase R2: No polling to cancel
    await _endCall();
  }

  // Build black screen with avatar for when video is off
  Widget _buildVideoOffScreen({
    required double size,
    required bool isRemote,
  }) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _buildAvatarForVideoOff(size: size, isRemote: isRemote),
      ),
    );
  }

  // Build avatar widget for video off screen
  Widget _buildAvatarForVideoOff({
    required double size,
    required bool isRemote,
  }) {
    // Phase R2: Get call data from provider instead of _callData
    final callStatusAsync = ref.read(callStatusProvider(widget.callId));
    final callData = callStatusAsync.valueOrNull;
    
    // Determine if current user is caller or creator
    final isCurrentUserCaller = widget.currentUser?.id == callData?.callerUserId ||
        widget.currentUser?.id == widget.caller?.id;
    
    if (isRemote) {
      // Remote user (opposite of current user)
      if (isCurrentUserCaller) {
        // Current user is caller, remote is creator
        return AvatarWidget(
          creatorInfo: widget.creator ?? callData?.creator,
          size: size,
        );
      } else {
        // Current user is creator, remote is caller
        return AvatarWidget(
          callerInfo: widget.caller ?? callData?.caller,
          size: size,
        );
      }
    } else {
      // Local user
      return AvatarWidget(
        user: widget.currentUser,
        size: size,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phase R2: Watch callStatusProvider for state changes
    final callStatusAsync = ref.watch(callStatusProvider(widget.callId));
    
    // React to provider state changes
    callStatusAsync.whenData((call) {
      // Phase R2: Provider handles socket events, we react to state
      if (call.status == CallStatus.ended || call.status == CallStatus.rejected) {
        if (!_hasEnded) {
          _handleCallEnded();
        }
      } else if (call.status == CallStatus.accepted && call.token != null && !_localUserJoined && !_isJoiningChannel) {
        // Token received from provider - join channel
        _joinChannel(call.token!, uid: call.uid);
      }
    });
    
    // TASK 9: Handle back press
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _endCall();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Remote video (full screen)
              Center(
                child: _isInitialized && _localUserJoined
                    ? _hasEnded
                        ? const Center(
                            child: Text(
                              'Call ended',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : _remoteUid != null
                            ? SizedBox.expand(
                                child: _remoteVideoEnabled
                                    ? AgoraLogic.getRemoteVideoWidget(widget.channelName)
                                    : _buildVideoOffScreen(
                                        size: 200,
                                        isRemote: true,
                                      ),
                              )
                            : const Center(
                                child: Text(
                                  'Waiting for remote user to join...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
              ),

              // Local video (small overlay)
              if (_isInitialized && _localUserJoined)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox.expand(
                        child: !_isCameraOff
                            ? AgoraLogic.getLocalVideoWidget()
                            : _buildVideoOffScreen(
                                size: 80,
                                isRemote: false,
                              ),
                      ),
                    ),
                  ),
                ),

              // Controls (bottom)
              if (!_isEndingCall)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute button
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                          await AgoraLogic.toggleMute(_isMuted);
                          debugPrint('${_isMuted ? "🔇" : "🔊"} [VIDEO CALL] Microphone ${_isMuted ? "muted" : "unmuted"}');
                        },
                        icon: Icon(
                          _isMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),

                      // End call button
                      IconButton(
                        onPressed: _endCall,
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),

                      // Camera switch button
                      IconButton(
                        onPressed: () async {
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                          });
                          await AgoraLogic.toggleCamera(enable: !_isCameraOff);
                          debugPrint('${_isCameraOff ? "📷" : "📹"} [VIDEO CALL] Camera ${_isCameraOff ? "off" : "on"}');
                        },
                        icon: Icon(
                          _isCameraOff ? Icons.videocam_off : Icons.videocam,
                          color: Colors.white,
                          size: 32,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),

              // Ending call loader overlay
              if (_isEndingCall)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Ending call...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
