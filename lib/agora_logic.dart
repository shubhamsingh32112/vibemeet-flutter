import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// TASK 6: Flutter – Create agora_logic.dart
// Encapsulates everything Agora-related
// Responsibilities:
// - Permission handling
// - Engine lifecycle
// - Join / leave channel
// - Expose widgets for video
// Do NOT mix business logic here.

class AgoraLogic {
  static RtcEngine? _engine;
  static bool _isInitialized = false;
  static bool _isInChannel = false;
  static int? _remoteUid;
  static bool _localUserJoined = false;
  static bool _localVideoEnabled = true; // Track local video state
  static bool _remoteVideoEnabled = true; // Track remote video state
  static final StreamController<int?> _remoteUidController = StreamController<int?>.broadcast();
  static final StreamController<bool> _localUserJoinedController = StreamController<bool>.broadcast();
  static final StreamController<bool> _remoteVideoEnabledController = StreamController<bool>.broadcast();

  // Streams for UI updates
  static Stream<int?> get remoteUidStream => _remoteUidController.stream;
  static Stream<bool> get localUserJoinedStream => _localUserJoinedController.stream;
  static Stream<bool> get remoteVideoEnabledStream => _remoteVideoEnabledController.stream;

  // Get current state
  static bool get isInitialized => _isInitialized;
  static bool get isInChannel => _isInChannel;
  static int? get remoteUid => _remoteUid;
  static bool get localUserJoined => _localUserJoined;
  static bool get localVideoEnabled => _localVideoEnabled;
  static bool get remoteVideoEnabled => _remoteVideoEnabled;

  // Check permissions without requesting
  static Future<bool> checkPermissions() async {
    try {
      final micStatus = await Permission.microphone.status;
      final cameraStatus = await Permission.camera.status;

      final micGranted = micStatus.isGranted;
      final cameraGranted = cameraStatus.isGranted;

      debugPrint('📋 [AGORA] Permission check');
      debugPrint('   Microphone: $micStatus (${micGranted ? "granted" : "not granted"})');
      debugPrint('   Camera: $cameraStatus (${cameraGranted ? "granted" : "not granted"})');

      return micGranted && cameraGranted;
    } catch (e) {
      debugPrint('❌ [AGORA] Permission check error: $e');
      return false;
    }
  }

  // Check and request permissions if needed
  static Future<bool> checkAndRequestPermissionsIfNeeded() async {
    try {
      // First check if permissions are already granted
      final hasPermissions = await checkPermissions();
      if (hasPermissions) {
        debugPrint('✅ [AGORA] Permissions already granted, no need to request');
        return true;
      }

      // Permissions not granted, request them
      debugPrint('📋 [AGORA] Permissions not granted, requesting...');
      return await requestPermissions();
    } catch (e) {
      debugPrint('❌ [AGORA] Check and request permissions error: $e');
      return false;
    }
  }

  // TASK 7: Request permissions
  static Future<bool> requestPermissions() async {
    try {
      final statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();

      final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
      final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;

      if (!micGranted || !cameraGranted) {
        debugPrint('❌ [AGORA] Permissions not granted');
        debugPrint('   Microphone: ${statuses[Permission.microphone]}');
        debugPrint('   Camera: ${statuses[Permission.camera]}');
        return false;
      }

      debugPrint('✅ [AGORA] Permissions granted');
      return true;
    } catch (e) {
      debugPrint('❌ [AGORA] Permission request error: $e');
      return false;
    }
  }

  // TASK 7: Initialize Agora Engine
  static Future<bool> initializeAgora(String appId) async {
    try {
      if (_isInitialized && _engine != null) {
        debugPrint('⚠️  [AGORA] Engine already initialized');
        return true;
      }

      debugPrint('🔄 [AGORA] Initializing engine...');
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _isInitialized = true;
      debugPrint('✅ [AGORA] Engine initialized');
      return true;
    } catch (e) {
      debugPrint('❌ [AGORA] Initialize error: $e');
      _isInitialized = false;
      return false;
    }
  }

  // TASK 7: Setup event handlers
  static void setupEventHandlers() {
    if (_engine == null) {
      debugPrint('❌ [AGORA] Engine not initialized. Call initializeAgora() first.');
      return;
    }

    debugPrint('🔄 [AGORA] Setting up event handlers...');

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('✅ [AGORA] Local user joined channel successfully');
          debugPrint('   UID: ${connection.localUid}');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   Elapsed: ${elapsed}ms');
          _localUserJoined = true;
          _isInChannel = true;
          _localUserJoinedController.add(true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('✅ [AGORA] Remote user joined channel');
          debugPrint('   Remote UID: $remoteUid');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   Elapsed: ${elapsed}ms');
          _remoteUid = remoteUid;
          _remoteVideoEnabled = true; // Assume video is enabled when user joins
          _remoteUidController.add(remoteUid);
          _remoteVideoEnabledController.add(true);
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          debugPrint('📹 [AGORA] Remote video state changed');
          debugPrint('   Remote UID: $remoteUid');
          debugPrint('   State: $state');
          debugPrint('   Reason: $reason');
          // Check if video is enabled based on state
          final isEnabled = state == RemoteVideoState.remoteVideoStateStarting ||
              state == RemoteVideoState.remoteVideoStateDecoding;
          _remoteVideoEnabled = isEnabled;
          _remoteVideoEnabledController.add(isEnabled);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [AGORA] Remote user left channel');
          debugPrint('   Remote UID: $remoteUid');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   Reason: $reason');
          _remoteUid = null;
          _remoteVideoEnabled = true; // Reset to default
          _remoteUidController.add(null);
          _remoteVideoEnabledController.add(true);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('❌ [AGORA] Error occurred');
          debugPrint('   Error Code: $err');
          debugPrint('   Message: $msg');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('👋 [AGORA] Left channel');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   Duration: ${stats.duration}s');
          debugPrint('   TxBytes: ${stats.txBytes}');
          debugPrint('   RxBytes: ${stats.rxBytes}');
          _isInChannel = false;
          _localUserJoined = false;
          _remoteUid = null;
          _localVideoEnabled = true; // Reset to default
          _remoteVideoEnabled = true; // Reset to default
          _localUserJoinedController.add(false);
          _remoteUidController.add(null);
          _remoteVideoEnabledController.add(true);
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('⚠️  [AGORA] Token will expire soon');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   Token: ${token.substring(0, 20)}...');
          debugPrint('   ⚠️  Should refresh token in production');
          // In production, refresh token here
          // For now, notify via stream
          _remoteUidController.add(null); // Signal connection issue
        },
        onConnectionLost: (RtcConnection connection) {
          debugPrint('❌ [AGORA] Connection lost');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   UID: ${connection.localUid}');
          _remoteUidController.add(null); // Signal connection lost
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('🔄 [AGORA] Connection state changed');
          debugPrint('   Channel: ${connection.channelId}');
          debugPrint('   State: $state');
          debugPrint('   Reason: $reason');
          if (state == ConnectionStateType.connectionStateDisconnected || 
              state == ConnectionStateType.connectionStateFailed) {
            debugPrint('   ⚠️  Connection disconnected/failed, signaling disconnection');
            _remoteUidController.add(null); // Signal disconnection
          }
        },
      ),
    );

    debugPrint('✅ [AGORA] Event handlers registered');
  }

  // TASK 7: Enable video and start preview
  static Future<bool> enableVideoAndPreview() async {
    if (_engine == null) {
      debugPrint('❌ [AGORA] Engine not initialized');
      return false;
    }

    try {
      debugPrint('🔄 [AGORA] Enabling video...');
      await _engine!.enableVideo();
      await _engine!.startPreview();
      debugPrint('✅ [AGORA] Video enabled and preview started');
      return true;
    } catch (e) {
      debugPrint('❌ [AGORA] Enable video error: $e');
      return false;
    }
  }

  // TASK 7: Join channel
  static Future<bool> joinChannel({
    required String channelName,
    required String token,
    int uid = 0, // 0 for auto-assign
  }) async {
    if (_engine == null) {
      debugPrint('❌ [AGORA] Engine not initialized, cannot join channel');
      return false;
    }

    if (_isInChannel) {
      debugPrint('⚠️  [AGORA] Already in channel, need to leave first');
      // Don't return true - we need to leave first
      // The caller should handle leaving before calling join
      return false;
    }

    try {
      debugPrint('🔄 [AGORA] Joining channel...');
      debugPrint('   Channel: $channelName');
      debugPrint('   UID: $uid');
      debugPrint('   Token: ${token.substring(0, 20)}...');
      
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        options: const ChannelMediaOptions(
          autoSubscribeVideo: true, // Automatically subscribe to all video streams
          autoSubscribeAudio: true, // Automatically subscribe to all audio streams
          publishCameraTrack: true, // Publish camera-captured video
          publishMicrophoneTrack: true, // Publish microphone-captured audio
          clientRoleType: ClientRoleType.clientRoleBroadcaster, // Both users are broadcasters
        ),
        uid: uid,
      );

      debugPrint('✅ [AGORA] Join channel request sent successfully');
      debugPrint('   Waiting for onJoinChannelSuccess callback...');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ [AGORA] Join channel error: $e');
      debugPrint('   Stack: $stackTrace');
      return false;
    }
  }

  // TASK 9: Leave channel
  static Future<void> leaveChannel() async {
    if (_engine == null) {
      debugPrint('⚠️  [AGORA] Engine not initialized, nothing to leave');
      return;
    }

    if (!_isInChannel) {
      debugPrint('⚠️  [AGORA] Not in channel, nothing to leave');
      return;
    }

    try {
      debugPrint('🔄 [AGORA] Leaving channel...');
      debugPrint('   Current remote UID: $_remoteUid');
      await _engine!.leaveChannel();
      _isInChannel = false;
      _localUserJoined = false;
      _remoteUid = null;
      _localVideoEnabled = true; // Reset to default
      _remoteVideoEnabled = true; // Reset to default
      debugPrint('✅ [AGORA] Left channel successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [AGORA] Leave channel error: $e');
      debugPrint('   Stack: $stackTrace');
    }
  }

  // TASK 9: Release engine
  static Future<void> release() async {
    debugPrint('🔄 [AGORA] Releasing engine...');
    try {
      await leaveChannel();

      if (_engine != null) {
        debugPrint('🔄 [AGORA] Calling engine.release()...');
        await _engine!.release();
        _engine = null;
        _isInitialized = false;
        _isInChannel = false;
        _localUserJoined = false;
        _remoteUid = null;
        _localVideoEnabled = true; // Reset to default
        _remoteVideoEnabled = true; // Reset to default
        debugPrint('✅ [AGORA] Engine released successfully');
        debugPrint('   All state cleared');
      } else {
        debugPrint('⚠️  [AGORA] Engine was already null');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [AGORA] Release error: $e');
      debugPrint('   Stack: $stackTrace');
    }
  }

  // TASK 8: Get local video widget
  static Widget getLocalVideoWidget() {
    if (_engine == null) {
      return const Center(
        child: Text('Engine not initialized'),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(
          uid: 0, // 0 for local user
          renderMode: RenderModeType.renderModeHidden,
        ),
      ),
    );
  }

  // TASK 8: Get remote video widget
  static Widget getRemoteVideoWidget(String channelName) {
    if (_engine == null) {
      return const Center(
        child: Text('Engine not initialized'),
      );
    }

    if (_remoteUid == null) {
      return const Center(
        child: Text(
          'Waiting for remote user to join...',
          textAlign: TextAlign.center,
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid!),
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }

  // Toggle mute/unmute microphone
  static Future<bool> toggleMute(bool mute) async {
    if (_engine == null) return false;
    try {
      await _engine!.muteLocalAudioStream(mute);
      return mute;
    } catch (e) {
      debugPrint('❌ [AGORA] Toggle mute error: $e');
      return false;
    }
  }

  // Toggle camera on/off
  static Future<bool> toggleCamera({bool? enable}) async {
    if (_engine == null) return false;
    try {
      // If enable is not provided, toggle based on current state
      final shouldEnable = enable ?? !_localVideoEnabled;
      await _engine!.enableLocalVideo(shouldEnable);
      _localVideoEnabled = shouldEnable;
      debugPrint('${shouldEnable ? "📹" : "📷"} [AGORA] Camera ${shouldEnable ? "enabled" : "disabled"}');
      return true;
    } catch (e) {
      debugPrint('❌ [AGORA] Toggle camera error: $e');
      return false;
    }
  }

  // Switch camera (front/back)
  static Future<bool> switchCamera() async {
    if (_engine == null) return false;
    try {
      await _engine!.switchCamera();
      return true;
    } catch (e) {
      debugPrint('❌ [AGORA] Switch camera error: $e');
      return false;
    }
  }

  // Cleanup (call this when done)
  static Future<void> cleanup() async {
    await release();
    await _remoteUidController.close();
    await _localUserJoinedController.close();
    await _remoteVideoEnabledController.close();
  }
}
