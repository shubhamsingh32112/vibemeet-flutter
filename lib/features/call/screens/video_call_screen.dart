import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../agora_logic.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/socket_service.dart';
import '../services/call_service.dart';
import '../../../shared/models/call_model.dart';
import '../../../shared/models/user_model.dart';

// TASK 8: Flutter – Video Call Screen
// Single reusable screen for both user and creator
class VideoCallScreen extends StatefulWidget {
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
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with WidgetsBindingObserver {
  final CallService _callService = CallService();
  final SocketService _socketService = SocketService();
  bool _isInitialized = false;
  int? _remoteUid;
  bool _localUserJoined = false;
  Timer? _pollTimer;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _callEnded = false; // Track if call has ended to stop polling
  bool _pollingStopped = false; // Track if polling was stopped (e.g., due to 429)
  bool _hasEnded = false; // 🚨 FIX: Prevent duplicate end call API calls
  bool _isJoiningChannel = false; // Track if we're currently joining to prevent duplicates
  bool _remoteVideoEnabled = true; // Track remote video state
  CallModel? _callData; // Store call data for avatar info
  StreamSubscription<int?>? _remoteUidSubscription;
  StreamSubscription<bool>? _localUserJoinedSubscription;
  StreamSubscription<bool>? _remoteVideoEnabledSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('📞 [VIDEO CALL] Screen initialized');
    debugPrint('   CallId: ${widget.callId}');
    debugPrint('   Channel: ${widget.channelName}');
    debugPrint('   HasToken: ${widget.token != null}');
    _fetchCallData();
    _initializeCall();
  }

  // Fetch call data to get user/creator info for avatars
  Future<void> _fetchCallData() async {
    try {
      final call = await _callService.getCallStatus(widget.callId);
      if (mounted) {
        setState(() {
          _callData = call;
        });
      }
    } catch (e) {
      debugPrint('⚠️  [VIDEO CALL] Failed to fetch call data: $e');
      // Continue anyway, will be fetched during polling
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _remoteUidSubscription?.cancel();
    _localUserJoinedSubscription?.cancel();
    _remoteVideoEnabledSubscription?.cancel();
    _cleanup();
    super.dispose();
  }

  // TASK 10: Handle app backgrounding
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 [VIDEO CALL] App lifecycle changed: $state');
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      debugPrint('   ⚠️  App backgrounded, ending call...');
      // Auto end call when app goes to background
      _endCall();
    }
  }

  // TASK 7: Agora Initialization Flow
  Future<void> _initializeCall() async {
    debugPrint('🔄 [VIDEO CALL] Starting call initialization');
    debugPrint('   CallId: ${widget.callId}');
    debugPrint('   Channel: ${widget.channelName}');
    
    try {
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

      // Step 5: Setup socket listeners for call ended events
      debugPrint('🔄 [VIDEO CALL] Step 5: Setting up socket listeners...');
      _setupSocketListeners();
      debugPrint('✅ [VIDEO CALL] Socket listeners registered');

      // Step 6: Setup stream subscriptions BEFORE joining (to catch immediate events)
      debugPrint('🔄 [VIDEO CALL] Step 6: Setting up stream subscriptions...');
      _setupStreamSubscriptions();
      debugPrint('✅ [VIDEO CALL] Stream subscriptions registered');

      // Step 7: Get token if not provided
      String? token = widget.token;
      if (token == null) {
        debugPrint('🔄 [VIDEO CALL] Step 7: No token provided, starting polling...');
        // Poll for call status until accepted
        _startPolling();
        return;
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

  // Setup socket listeners for call ended events
  void _setupSocketListeners() {
    debugPrint('🔄 [VIDEO CALL] Setting up socket listeners for call events...');
    
    // Listen for call_ended event
    _socketService.onCallEnded((data) {
      if (data['callId'] == widget.callId) {
        debugPrint('🔚 [VIDEO CALL] Call ended event received via socket');
        debugPrint('   Ended by: ${data['endedBy']}');
        if (mounted && !_hasEnded) {
          _handleCallEnded();
        }
      }
    });
    
    debugPrint('✅ [VIDEO CALL] Socket listeners registered');
  }

  // Handle call ended (from socket or polling)
  Future<void> _handleCallEnded() async {
    if (_hasEnded) {
      return;
    }
    
    debugPrint('🔚 [VIDEO CALL] Handling call ended...');
    _callEnded = true;
    _pollingStopped = true;
    _pollTimer?.cancel();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Call ended by other party'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Clean up and navigate back
      await _endCall();
    }
  }

  // Poll for call status until accepted
  // FIX 1: Slow down polling (3 seconds) and handle 429 errors
  void _startPolling() {
    if (_pollingStopped || _callEnded) {
      debugPrint('⚠️  [VIDEO CALL] Polling already stopped or call ended');
      return;
    }

    debugPrint('🔄 [VIDEO CALL] Starting polling for call status');
    debugPrint('   CallId: ${widget.callId}');
    debugPrint('   Interval: 3 seconds');

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Stop if call ended or polling was stopped
      if (_callEnded || _pollingStopped) {
        debugPrint('⏸️  [VIDEO CALL] Polling stopped (callEnded: $_callEnded, pollingStopped: $_pollingStopped)');
        timer.cancel();
        return;
      }

      try {
        debugPrint('🔄 [VIDEO CALL] Polling call status...');
        final call = await _callService.getCallStatus(widget.callId);
        debugPrint('📊 [VIDEO CALL] Call status received: ${call.status.name}');
        
        // Store call data for avatar info
        if (mounted) {
          setState(() {
            _callData = call;
          });
        }
        
        // Handle call status
        if (call.status == CallStatus.accepted && call.token != null && !_localUserJoined && !_isJoiningChannel) {
          debugPrint('✅ [VIDEO CALL] Call accepted! Token received, joining channel...');
          // Join channel if not already joined and not currently joining
          try {
            await _joinChannel(call.token!, uid: call.uid);
          } catch (e) {
            debugPrint('❌ [VIDEO CALL] Join channel failed in polling: $e');
            _isJoiningChannel = false; // Reset flag on error
          }
          // Continue polling to detect when call ends
        } else if (call.status == CallStatus.ended && !_hasEnded) {
          debugPrint('⚠️  [VIDEO CALL] Call ended detected via polling');
          timer.cancel();
          _pollingStopped = true;
          await _handleCallEnded();
        } else if (call.status == CallStatus.rejected) {
          debugPrint('⚠️  [VIDEO CALL] Call ${call.status.name}, stopping polling');
          timer.cancel();
          _pollingStopped = true;
          _callEnded = true;
          if (mounted && !_hasEnded) {
            if (call.status == CallStatus.ended) {
              await _handleCallEnded();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Call ${call.status.name}'),
                  backgroundColor: Colors.orange,
                ),
              );
              context.pop();
            }
          }
        } else {
          debugPrint('⏳ [VIDEO CALL] Call still ${call.status.name}, continuing to poll...');
        }
      } on DioException catch (e) {
        // FIX 2: Handle 429 explicitly - stop polling
        if (e.response?.statusCode == 429) {
          debugPrint('⏸️  [VIDEO CALL] Rate limited (429), stopping poll');
          debugPrint('   Error: ${e.message}');
          timer.cancel();
          _pollingStopped = true;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please wait, connecting...'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        
        // FIX 3: Handle 403 explicitly - user is not part of call, stop polling
        if (e.response?.statusCode == 403) {
          debugPrint('⏸️  [VIDEO CALL] Access denied (403), stopping poll');
          debugPrint('   Error: ${e.message}');
          debugPrint('   Response: ${e.response?.data}');
          timer.cancel();
          _pollingStopped = true;
          _callEnded = true;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Call is no longer available'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
            context.pop();
          }
          return;
        }
        
        // For other errors, log but continue polling (with delay)
        debugPrint('❌ [VIDEO CALL] Poll error (${e.response?.statusCode}): ${e.message}');
      } catch (e) {
        debugPrint('❌ [VIDEO CALL] Poll error: $e');
        // Continue polling on non-429 errors
      }
    });
  }

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
        } else if (_remoteUid != null) {
          debugPrint('👋 [VIDEO CALL] Remote user left (UID was $_remoteUid)');
        }
        
        setState(() {
          _remoteUid = uid;
        });
        
        // TASK 2: Handle connection lost / token expiry
        if (uid == null && _remoteUid != null) {
          // Connection was lost - end call
          debugPrint('⚠️  [VIDEO CALL] Connection lost detected');
          _handleConnectionLost();
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
    
    // Mark as ended immediately to prevent duplicate calls
    _hasEnded = true;
    
    // Stop polling immediately
    _pollTimer?.cancel();
    _pollingStopped = true;
    _callEnded = true;
    debugPrint('   Polling stopped');

    try {
      debugPrint('🔄 [VIDEO CALL] Calling end call API...');
      await _callService.endCall(widget.callId);
      debugPrint('✅ [VIDEO CALL] End call API called successfully');
    } catch (e) {
      debugPrint('❌ [VIDEO CALL] End call API error: $e');
      // Don't reset _hasEnded on error - still prevent duplicate calls
    }

    debugPrint('🔄 [VIDEO CALL] Leaving Agora channel...');
    await AgoraLogic.leaveChannel();
    debugPrint('✅ [VIDEO CALL] Left Agora channel');

    debugPrint('🔄 [VIDEO CALL] Releasing Agora engine...');
    await AgoraLogic.release();
    debugPrint('✅ [VIDEO CALL] Agora engine released');

    if (mounted) {
      debugPrint('🔄 [VIDEO CALL] Navigating back...');
      widget.onEndCall?.call();
      context.pop();
      debugPrint('✅ [VIDEO CALL] Call ended and screen closed');
    }
  }

  // TASK 2: Handle connection lost / token expiry
  Future<void> _handleConnectionLost() async {
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
    _pollTimer?.cancel();
    await _endCall();
  }

  // Helper method to build avatar widget
  Widget _buildAvatarWidget({
    String? avatar,
    String? username,
    String? gender,
    double size = 120,
  }) {
    // If user has selected an avatar, use it
    if (avatar != null && avatar.isNotEmpty) {
      final avatarGender = gender ?? 'male';
      final avatarPath = avatarGender == 'female'
          ? 'lib/assets/female/$avatar'
          : 'lib/assets/male/$avatar';
      
      return ClipOval(
        child: Image.asset(
          avatarPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(username, size);
          },
        ),
      );
    }
    
    // Fallback to initials
    return _buildFallbackAvatar(username, size);
  }

  Widget _buildFallbackAvatar(String? username, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple[400],
      ),
      child: Center(
        child: Text(
          (username?.isNotEmpty ?? false)
              ? username![0].toUpperCase()
              : 'U',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Build black screen with avatar for when video is off
  Widget _buildVideoOffScreen({
    required String? avatar,
    required String? username,
    required String? gender,
    required double size,
  }) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _buildAvatarWidget(
          avatar: avatar,
          username: username,
          gender: gender,
          size: size,
        ),
      ),
    );
  }

  // Get remote user info (caller or creator depending on who is remote)
  Map<String, String?> _getRemoteUserInfo() {
    // Determine if current user is caller or creator
    // If we have currentUser and it matches caller, then remote is creator
    // Otherwise, remote is caller
    final isCurrentUserCaller = widget.currentUser?.id == _callData?.callerUserId ||
        widget.currentUser?.id == widget.caller?.id;
    
    if (isCurrentUserCaller) {
      // Current user is caller, remote is creator
      return {
        'avatar': widget.creator?.avatar ?? _callData?.creator?.avatar,
        'username': widget.creator?.username ?? _callData?.creator?.username,
        'gender': null, // Creator info doesn't have gender in CallModel
      };
    } else {
      // Current user is creator, remote is caller
      return {
        'avatar': widget.caller?.avatar ?? _callData?.caller?.avatar,
        'username': widget.caller?.username ?? _callData?.caller?.username,
        'gender': null, // Caller info doesn't have gender in CallModel
      };
    }
  }

  // Get local user info
  Map<String, String?> _getLocalUserInfo() {
    return {
      'avatar': widget.currentUser?.avatar,
      'username': widget.currentUser?.username,
      'gender': widget.currentUser?.gender,
    };
  }

  @override
  Widget build(BuildContext context) {
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
                    ? _remoteUid != null
                        ? SizedBox.expand(
                            child: _remoteVideoEnabled
                                ? AgoraLogic.getRemoteVideoWidget(widget.channelName)
                                : _buildVideoOffScreen(
                                    avatar: _getRemoteUserInfo()['avatar'],
                                    username: _getRemoteUserInfo()['username'],
                                    gender: _getRemoteUserInfo()['gender'],
                                    size: 200,
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
                                avatar: _getLocalUserInfo()['avatar'],
                                username: _getLocalUserInfo()['username'],
                                gender: _getLocalUserInfo()['gender'],
                                size: 80,
                              ),
                      ),
                    ),
                  ),
                ),

              // Controls (bottom)
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
            ],
          ),
        ),
      ),
    );
  }
}
