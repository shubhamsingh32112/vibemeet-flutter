Quickstart
This page provides a step-by-step guide on how to create a basic Video Calling app using the Agora Video SDK.

Understand the tech
To start a Video Calling session, implement the following steps in your app:

Initialize the Agora Engine: Before calling other APIs, create and initialize an Agora Engine instance.

Join a channel: Call methods to create and join a channel.

Send and receive audio and video: All users can publish streams to the channel and subscribe to audio and video streams published by other users in the channel.

To add Video Calling to your existing project:

Open your Flutter project and navigate to the lib folder.
Add a new file to the lib folder and name it agora_logic.dart.
Install the SDK
Install the Agora Video SDK and other dependencies.

Add the latest version of Agora Video SDK to your Flutter project:

flutter pub add agora_rtc_engine
Add the permission processing package:

flutter pub add permission_handler
The dependencies in your pubspec.yaml file should should look like the following:

dependencies:
  flutter:
    sdk: flutter 
  agora_rtc_engine: ^6.5.0  # Agora Flutter SDK, please use the latest version
  permission_handler: ^11.3.1  # Package for managing runtime permissions
  cupertino_icons: ^1.0.8 
Install the dependencies.

Execute the following command in the project path:

flutter pub get
Implement Video Calling
This section guides you through the implementation of basic real-time audio and video interaction in your app.

The following figure illustrates the essential steps:

Import package​s
Import the following package​s in your dart file.

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
Initialize the engine
For real-time communication, initialize an RtcEngine instance. Use RtcEngineContext to specify the App ID, and other configuration parameters. In your dart file, add the following code:

// Set up the Agora RTC engine instance
Future<void> _initializeAgoraVoiceSDK() async {
  _engine = createAgoraRtcEngine();
  await _engine.initialize(const RtcEngineContext(
    appId: "<-- Insert app Id -->",
    channelProfile: ChannelProfileType.channelProfileCommunication,
  ));
}
Join a channel
To join a channel, call joinChannel with the following parameters:

Channel name: The name of the channel to join. Clients that pass the same channel name join the same channel. If a channel with the specified name does not exist, it is created when the first user joins.

Authentication token: A dynamic key that authenticates a user when the client joins a channel. In a production environment, you obtain a token from a token server in your security infrastructure. For the purpose of this guide Generate a temporary token.

User ID: A 32-bit signed integer that identifies a user in the channel. You can specify a unique user ID for each user yourself. If you set the user ID to 0 when joining a channel, the SDK generates a random number for the user ID and returns the value in the onJoinChannelSuccess callback.

Channel media options: Configure ChannelMediaOptions to define publishing and subscription settings, optimize performance for your specific use-case, and set optional parameters.

For Video Calling, set the clientRoleType to clientRoleBroadcaster.

// Join a channel
Future<void> _joinChannel() async {
  await _engine.joinChannel(
    token: token,
    channelId: channel,
    options: const ChannelMediaOptions(
      autoSubscribeVideo: true, // Automatically subscribe to all video streams
      autoSubscribeAudio: true, // Automatically subscribe to all audio streams
      publishCameraTrack: true, // Publish camera-captured video
      publishMicrophoneTrack: true, // Publish microphone-captured audio
      // Use clientRoleBroadcaster to act as a host or clientRoleAudience for audience
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
    ),
    uid: 0,
  );
}
Subscribe to Video SDK events
The SDK provides the RtcEngineEventHandler for subscribing to channel events. To use it, pass an instance of RtcEngineEventHandler to registerEventHandler and implement the event methods you want to handle.

Call registerEventHandler to bind the event handler to the SDK.

// Register an event handler for Agora RTC
void _setupEventHandlers() {
  _engine.registerEventHandler(
    RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("Local user ${connection.localUid} joined");
        setState(() => _localUserJoined = true);
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("Remote user $remoteUid joined");
        setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint("Remote user $remoteUid left");
        setState(() => _remoteUid = null);
      },
    ),
  );
}
When a remote user joins the channel, the onUserJoined callback is triggered. Use the remote user's uid returned in the callback, to create an AgoraVideoView control for displaying the video stream from the remote user.

info
To ensure that you receive all Video SDK events, register the event handler before joining a channel.

Display the local video
To display the local video, enable the video module by calling enableVideo, then start the local video preview with startPreview.

Future<void> _setupLocalVideo() async {
  // The video module and preview are disabled by default.
  await _engine.enableVideo();
  await _engine.startPreview();
}
To render the local video, add the following widget inside your UI’s widget tree, such as in the build method of your StatefulWidget:

// Displays the local user's video view using the Agora engine.
Widget _localVideo() {
  return AgoraVideoView(
    controller: VideoViewController(
      rtcEngine: _engine, // Uses the Agora engine instance
      canvas: const VideoCanvas(
        uid: 0, // Specifies the local user
        renderMode: RenderModeType.renderModeHidden, // Sets the video rendering mode
      ),
    ),
  );
}
Display remote video
To render a remote video, add the following widget inside your UI’s widget tree, such as in the build method of your StatefulWidget:

// If a remote user has joined, render their video, else display a waiting message
Widget _remoteVideo() {
  if (_remoteUid != null) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine, // Uses the Agora engine instance
        canvas: VideoCanvas(uid: _remoteUid), // Binds the remote user's video
        connection: const RtcConnection(channelId: channel), // Specifies the channel
      ),
    );
  } else {
    return const Text(
      'Waiting for remote user to join...',
      textAlign: TextAlign.center,
    );
  }
}
Handle permissions​
Request microphone and camera permissions for Video Calling.

Future<void> _requestPermissions() async {
  await [Permission.microphone, Permission.camera].request();
}

Start and close the app
To start Video Calling, request microphone and camera permissions, initialize the Agora SDK instance, set up event handlers, join a channel, and display the local video.

await _requestPermissions();
await _initializeAgoraVideoSDK();
await _setupLocalVideo();
_setupEventHandlers();
await _joinChannel();
To stop Video Calling, leave the channel and release the engine instance.

// Leaves the channel and releases resources
Future<void> _cleanupAgoraEngine() async {
  await _engine.leaveChannel();
  await _engine.release();
}
Warning
After you call release, you no longer have access to the methods and callbacks of the SDK. To use Video Calling features again, create a new engine instance.

Complete sample code:
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

// Fill in the app ID obtained from Agora Console
const appId = "<-- Insert app Id -->";
// Fill in the temporary token generated from Agora Console
const token = "<-- Insert token -->";
// Fill in the channel name you used to generate the token
const channel = "<-- Insert channel name -->";


// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

// Video Call Screen Widget
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenScreenState createState() => _MainScreenScreenState();
}

class _MainScreenScreenState extends State<MainScreen> {
  int? _remoteUid; // Stores remote user ID
  bool _localUserJoined = false; // Indicates if local user has joined the channel
  late RtcEngine _engine; // Stores Agora RTC Engine instance

  @override
  void initState() {
    super.initState();
    _startVideoCalling();
  }

  // Initializes Agora SDK
  Future<void> _startVideoCalling() async {
    await _requestPermissions();
    await _initializeAgoraVideoSDK();
    await _setupLocalVideo();
    _setupEventHandlers();
    await _joinChannel();
  }

  // Requests microphone and camera permissions
  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  // Set up the Agora RTC engine instance
  Future<void> _initializeAgoraVideoSDK() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
  }

  // Enables and starts local video preview
  Future<void> _setupLocalVideo() async {
    await _engine.enableVideo();
    await _engine.startPreview();
  }

  // Register an event handler for Agora RTC
  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          setState(() => _remoteUid = null);
        },
      ),
    );
  }

  // Join a channel
  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  @override
  void dispose() {
    _cleanupAgoraEngine();
    super.dispose();
  }

  // Leaves the channel and releases resources
  Future<void> _cleanupAgoraEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Video Calling')),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? _localVideo()
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

    // Displays remote video view
  Widget _localVideo() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(
          uid: 0,
          renderMode: RenderModeType.renderModeHidden,
        ),
      ),
    );
  } 

  // Displays remote video view
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Waiting for remote user to join...',
        textAlign: TextAlign.center,
      );
    }
  }
}

Information
In the appId and token fields, enter the corresponding values you obtained from Agora Console. Use the same channel name you filled in when generating the temporary token.

Create a user interface
To connect the sample code to your existing UI, ensure that your widget tree includes the _remoteVideo and _localVideo widgets used to Display the local video and Display remote video.

Alternatively, use the following sample code to generate a basic user interface:
// Build UI to display local video and remote video
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Agora Video Call')),
    body: Stack(
      children: [
        Center(child: _remoteVideo()),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100,
            height: 150,
            child: Center(
              child: _localUserJoined
                  ? _localVideo()
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    ),
  );
}

