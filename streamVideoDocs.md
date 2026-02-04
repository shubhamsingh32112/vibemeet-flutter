Introduction
Welcome to the Stream Video Flutter SDK - a comprehensive toolkit designed to help you swiftly implement features such as video calling, audio calling, audio rooms, and livestreaming within your app.

Our goal is to ensure an optimal developer experience that enables your application to go live within days.

Our Flutter SDK is furnished with user-friendly UI components and versatile state objects, making your development process seamless. Moreover, all calls are routed through Stream's global edge network, thereby ensuring lower latency and higher reliability due to proximity to end users.

If you're new to Stream Video SDK, we recommend starting with the following three tutorials:

Video & Audio Calling Tutorial
Audio Room Tutorial
Livestream Tutorial
Ringing Tutorial
After the tutorials, the documentation explains how to use the

Core concepts such as initiating a call, switching the camera view, and more
Effective utilization of our UI components
Insights on building your own UI with our UI Cookbook
It also explains advanced features such as:

Picture-in-Picture support
Ringing
Recording
Broadcasting
Requesting & Granting permissions
Audio & Video Filters
If you feel like anything is missing or could be improved, please don't hesitate to contact us. We're happy to help.


Installation
The Flutter SDK for Stream Video is distributed through pub.dev. The SDK contains four different packages: stream_video_flutter, stream_video, stream_video_push_notification and stream_video_screen_sharing. Releases and changes are published on the GitHub releases page.

Adding the SDK to your project
To add the Flutter SDK, you can add the latest dependencies for the SDK to your pubspec.yaml file:


dependencies:
stream_video: ^latest
stream_video_flutter: ^latest
stream_video_push_notification: ^latest
stream_video_screen_sharing: ^latest
Additionally, you can also run the flutter pub add command in the terminal to do this:


flutter pub add stream_video_flutter
flutter pub add stream_video
flutter pub add stream_video_push_notification
flutter pub add stream_video_screen_sharing
This command will automatically install the latest versions of the Stream SDK packages from pub.dev to the dependencies section of your pubspec.yaml.

Permissions
Making video calls requires the usage of the device's camera and microphone. Therefore, before you can make and answer calls, you need to request permission to use them within your application.

The following permissions must be granted for both Android and iOS:

Internet Connectivity
Camera
Microphone (+ control audio settings to adjust audio level & switch between speaker & earpiece)
Bluetooth (wireless headset)
iOS
Xcode Permission configuration
For iOS, we recommend you add the following keys and values to your Info.plist file at a minimum:


<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your camera for video calls.</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your microphone for voice and video calls.</string>
<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
	 <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
	<string>fetch</string>
	<string>processing</string>
	<string>remote-notification</string>
	<string>voip</string>
</array>
Android
For Android, similar permissions are needed in <project root>/android/app/src/main/AndroidManifest.xml


<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
With Android specifically, you will also need to add additional permission if you would like to use Bluetooth devices:


<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
VoIP Calling
We also ship the stream_video_push_notification package to allow you to add integrations with native calling interfaces such as CallKit. Please check out our ringing guide for additional setup needed for integration.

Quickstart
The Flutter Video for Stream Video is a highly customizable SDK that facilitates adding calling (audio and video) support to your apps.

The SDK consists of four parts:

Low-level client (stream_video): Responsible for establishing calls, built on top of WebRTC.
UI SDK (stream_video_flutter): Flutter widgets for different types of call flows.
VoIP SDK (stream_video_push_notification): Adds native calling interface support for Android and iOS (CallKit).
Screen sharing SDK (stream_video_screen_sharing): Includes a native Swift implementation of BroadcastSampleHandler, essential for the broadcast screen sharing mode on iOS.
In this guide, we will build a video calling app that shows how you can integrate the SDK in few simple steps.

If you haven't already, we recommend starting with the introduction and installation steps first, as this guide will build on the material covered in those sections.

Client Setup
Before we can create a new video client, we must first import the Stream Video package into our application.


import 'package:stream_video_flutter/stream_video_flutter.dart';
Next, in our application’s main function, let’s add the following:


Future<void> main() async {
  // Ensure Flutter is able to communicate with Plugins
  WidgetsFlutterBinding.ensureInitialized();
	// Initialize Stream video and set the API key along with the user for our app.
  final client = StreamVideo(
    'REPLACE_WITH_API_KEY',
     user: User.regular(userId: 'REPLACE_WITH_USER_ID', name: 'Test User'),
     userToken: 'REPLACE_WITH_TOKEN',
  );
  // Set up our call object and pass it the call type and ID. The most common call type is `default`, which enables full audio and video transmission
  final call = client.makeCall(callType: StreamCallType.defaultType(), id: 'REPLACE_WITH_CALL_ID');
  // Connect to the call we created
  await call.join();
  runApp(
    DemoAppHome(
      call: call,
    ),
  );
}
In the code above, we are performing a few key steps:

Initializing our SDK with the API key for our application.
Defining the user we would like to connect as to participate in a call.
Creating an object for our call, giving it the "default" call type and unique ID.
Connecting to the call we defined.
Although it is not shown in the example above, users can choose to customize many different aspects of the SDK during initialization. Here are a few of the parameters which can be overridden during initialization:

Parameter	Description
apiKey	Stream Video API key obtained from the Dashboard of your project.
latencySettings	Controls the number of rounds and timeout duration for measuring latency when first connecting to a call.
retryPolicy	Allows for custom handling of retries such as override the default number of max retries, passing in a custom backoff function and more.
sdpPolicy	Controls whether SDP Munging is enabled and gives access to functions supporting SDP Munging.
logPriority	Allows for customizing the level of logs displayed while developing or running your application.
logHandlerFunction	Can be overridden to intercept logs and perform custom actions such as sending device logs to a capture service.
muteVideoWhenInBackground	Indicates whether the SDK should disable the video track when the app moves from the foreground to background. We highly recommend you set this to true if your app does not support picture-in-picture mode.
muteAudioWhenInBackground	Indicates whether the SDK should disable the audio track when the app moves from the foreground to background. We highly recommend you set this to true if your app does not support picture-in-picture mode.
Call UI
Stream ships with many pre-made components to make building your call UI as simple as possible. All of our UI components are designed to be flexible and customizable, meaning as a developer, you can control exactly how much (or how little) of Stream’s stock components you would like to have in your app.

With our Call object defined, let’s create the UI for our application. Since this is meant to be a quick-start guide, we can simply pass down the call defined earlier to our UI widget, but in a production scenario, you can define these calls in a repository or any other state layer of your choice.


class DemoAppHome extends StatelessWidget {
  const DemoAppHome({Key? key, required this.call}) : super(key: key);
  final Call call;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer( // Stream's pre-made component
        call: call,
      ),
    );
  }
}
Using our default StreamCallContainer along with the call created earlier, we can compile our sample application and examine the result.

Completed application
In just a few lines of code, we can have a fully functional call screen in our application. Out of the box, StreamCallContainer ships with an AppBar, Participant view, and Call Controls. These components can be themed to fit your app's style or be overridden entirely using a builder to allow for custom UIs and interactions.

Taking it one step further
For fun, let's take a look at customizing the UI of our application to include a custom icon in the control area.

Call control area
Looking at our current UI code, we can make use of Flutter’s composition and builder pattern to override the default UI with our own.


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: call,
        callContentWidgetBuilder: (context, call) {
        },
      ),
    );
  }
StreamCallContainer ships with many different builders that can be implemented to override the default UI and behavior. Since we are interested in changing the content/UI of our call, we can override the callContentWidgetBuilder as a starting point.

Please take a minute to explore and look at the other parameters you can customize. There are many options for changing colors, layouts, behaviour, etc.

Next, we can use another Stream UI component, StreamCallContent to access the control area and add our custom button.


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: call,
        callContentWidgetBuilder: (context, call) {
          return StreamCallContent(
            call: call,
            callControlsWidgetBuilder: (context, call) {
						    // Override the controls builder in StreamCallContent
            },
          );
        },
      ),
    );
  }
Finally, we can return the controls and options we would like to display to the user


return StreamCallContent(
    call: call,
    callControlsWidgetBuilder: (context, call) {
      return StreamCallControls(
        options: [
          CallControlOption(
            icon: const Text('👋'),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hello'),
              ),
            ),
          ),
          FlipCameraOption(
            call: call,
          ),
          LeaveCallOption(call: call, onLeaveCallTap: call.leave),
        ],
      );
    },
  );
Modified Call UI
When tapped:

Display banner

Architecture & Benchmark
Stream's video API is designed to scale WebRTC-based video calling to massive audiences while maintaining low latency and high quality. Here we explain the architecture that allows the video API to scale to 100k participants with excellent performance.

Benchmark at a glance
Benchmark Results
As you can see in the graph above, Stream's video scales to 100k users without any degradation in video quality. The full benchmark for 100k participants is included below. The team is working on our first 1M concurrent user livestream.

Scaling WebRTC
Why WebRTC has a reputation for not scaling
WebRTC was originally designed for peer-to-peer communication. In a naive implementation, each participant would need to send their video to every other participant, creating an O(n²) scaling problem. For example, with just 10 participants, you'd need 90 direct connections. This approach quickly becomes impractical.

Additionally, WebRTC's real-time nature means you can't rely on buffering to hide network issues, making it challenging to maintain quality at scale.

How we scale to 100k participants
We've overcome these limitations through a combination of architectural decisions and optimizations:

SFU + SFU Cascading
Instead of peer-to-peer connections, we use Selective Forwarding Units (SFUs). An SFU receives media from each participant and selectively forwards it to others, reducing the connection complexity from O(n²) to O(n).

For very large calls, we cascade multiple SFUs together. This allows us to distribute participants across multiple servers while maintaining real-time communication between them. The cascading layer handles:

Forwarding video and audio streams between SFUs
Synchronizing call state across all instances
Optimizing routing to minimize latency
Automatic subscription management
Our SDKs automatically handle subscribing to the right video streams. If a participant isn't visible on screen, we don't download their video. This dramatically reduces bandwidth usage in large calls where you might only see a grid of several participants at a time.

Go for performance
Like our chat and feeds infrastructure, our video backend is written in Go. Go's excellent concurrency primitives and low memory footprint make it ideal for handling thousands of simultaneous WebRTC connections per server.

Auto-scaling and performance
Video traffic can spike at a moment's notice. Our video SFU infrastructure can scale very quickly to adjust to the needed capacity. Stepped scaling is used to scale SFU capacity based on how quickly capacity is required. For example: a large spike on SFU saturation metric can expand the number of SFU running by 2x or 3x.

SFU cascading deep dive
Streaming high quality video is very bandwidth intensive and the total throughput grows linearly with the amount of users. Hosting a call with 100k participants requires more than 200 Gbps on a 1080p stream.

It is not viable to always host a call on a single SFU for two reasons: the required bandwidth can be more than a single server can handle; there can be participants connecting from different countries.

For this reason, we cascade multiple SFUs together and as load increases we build in a hierarchy of SFUs.

For example a small call might have 1,000 users connected to an SFU. For a larger livestream the video is sent to an SFU, which broadcasts to another 100 SFUs, which each serve 1,000 end users.

Cascading could be a blogpost topic on its own. Many optimizations are necessary to make sure that SFUs can forward packets to each other at high rates (>100k per second).

Batched system calls using sendmmsg and recvmmsg
Generic Segmentation Offload (GSO)
Generic Receive Offload (GRO)
Zero-Allocation Hot Paths
Per-Core Parallelization
Direct syscalls (syscall.Syscall6 instead of Go's net package)
Performing a sendmsg syscall for each packet received and SFU does not perform well and the OS networking stack quickly becomes the bottleneck. With this setup, SFU performs approximately 1 syscall every 8 RTP packets received regardless of how many cascading SFU.

Video and state forwarding
The cascading layer efficiently forwards:

Video streams: Only the streams that are needed on each SFU are forwarded
Audio streams: Mixed or selectively forwarded based on who's speaking
Call state: Participant lists, reactions, and other state are synchronized across all SFUs in real-time
Thundering herd prevention
When a large event starts, thousands of users may join simultaneously. We've built protections against thundering herd problems that could overwhelm the system during these spikes.

Hotspot prevention
Similar to our activity feeds architecture, we prevent database hotspots when updating timestamps and other frequently-changing data. This ensures that high-traffic calls don't create performance bottlenecks.

Redundancy and reliability
Infrastructure as code
All infrastructure is defined in code, ensuring consistent deployments and easy disaster recovery. This approach allows us to:

Quickly spin up new capacity when needed
Maintain identical configurations across environments
Audit and version control all infrastructure changes
Multi-datacenter and multi-provider
We run across multiple datacenters and hosting providers. This provides:

Geographic redundancy for disaster recovery
Lower latency by routing users to nearby servers
Protection against provider-specific outages
Ensuring high quality audio/video
Audio optimization
DTX (Discontinuous Transmission): Reduces bandwidth by not transmitting during silence
Opus RED (Redundant Encoding): Adds redundancy to audio packets, making audio more resilient to packet loss
Simulcast + automatic codec and resolution selection
When it's needed, participants upload high, medium and low quality. The system automatically selects the optimal codec and resolution based on:

Network conditions
Screen size
Device capabilities
Available bandwidth
AV1 codec
We always select the optimal codec based on the participants. In the case of a large livestream we support several codecs at once. This enables Stream to use newer AV1 codecs in addition to older systems like VP8.

Connectivity and TURN
Not all users can connect directly to our SFUs; some can only connect on specific ports, cannot use UDP or can only connect to well-known IP addresses.

We run TURN on our SFU servers
We support port TCP/443
We operate a dedicated TURN network with static IP
UI best practices for quality
Our SDKs include UI components that follow best practices for video quality:

Bad network indicator: Shows users when their connection quality is poor
Speaking while muted detection: Alerts users when they're trying to speak with their microphone muted
Mic input volume indicator: Visual feedback showing microphone input levels while talking
Speaker test button: Allows users to test their speaker selection before joining a call
Benchmark results
The graph below shows the results of our 100k participant benchmark. The team is currently working on a 1M participant benchmark. Be sure to reach out to support if you need even higher numbers.

100k participants consuming a 1080p video using webRTC
10k participants joining per minute and 600/s joining at peak
Six different locations (North Virginia, Ohio, Oregon, London, Frankfurt, Milan)
Benchmark Results
Results

225Gbps peak traffic
132 SFU in cascading mode
0 API call failures, no crashes
FPS stable at 30fps during the entire duration of the benchmark
0% packet loss
Jitter 4ms


Client and Authentication
StreamVideo is the main class used for creating class, performing authentication and listening to core events dispatched by Stream’s servers.

Before joining a call, it is necessary to set up the video client. Here's a basic example:


final client = StreamVideo(
  'REPLACE_WITH_API_KEY',
  user: User.regular(
    userId: 'REPLACE_WITH_USER_ID',
    name: 'John Doe',
  ),
  userToken: 'REPLACE_WITH_TOKEN',
);
The API Key can be found in your Stream dashboard.
The User can be either authenticated, anonymous or guest.
Note: You can store custom data on the user object, if required.
StreamVideo is the main class used for creating class, performing authentication and listening to core events dispatched by Stream’s servers.

The initialization constructor for StreamVideo also exposes many customization options which can be overridden based on the project needs such as the logging level, SDP policy, retry policy, etc.


factory StreamVideo(
  String apiKey, {
  StreamVideoOptions options = StreamVideoOptions(
    coordinatorRpcUrl: _defaultCoordinatorRpcUrl,
    coordinatorWsUrl: _defaultCoordinatorWsUrl,
    latencySettings: const LatencySettings(),
    sdpPolicy: const SdpPolicy(),
    retryPolicy: const RetryPolicy(),
    logPriority: Priority.none,
    logHandlerFunction: _defaultLogHandler,
    muteVideoWhenInBackground: false,
    muteAudioWhenInBackground: false,
    autoConnect: true,
    includeUserDetailsForAutoConnect: true,
    keepConnectionsAliveWhenInBackground: false,
  ),
  required User user,
  String? userToken,
  TokenLoader? tokenLoader,
  OnTokenUpdated? onTokenUpdated,
  bool failIfSingletonExists = true,
  PNManagerProvider? pushNotificationManagerProvider,
});
The SDK tries to connect to Stream's backend automatically by default. You can set autoConnect to false in StreamVideoOptions to change this behaviour.

If you choose to connect later, you can use the connect() method to connect to Stream Video:


StreamVideo.instance.connect();
The connection passes the user info by default to the backend. To change this, you can set the includeUserDetailsForAutoConnect parameter in StreamVideoOptions when auto-connecting or use the includeUserDetails parameter when using the connect() method:


StreamVideo.instance.connect(
        includeUserDetails: false,
    );
Working with Tokens
All tokens must be generated via a backend SDK and cannot be created from a frontend client. This step is typically included whenever a new user is registered on your backend.

Here's a valid user and token to help you get started on the client side, before integrating with your backend API.


Here are credentials to try out the app with:

Property	Value
API Key	
Token	Copy
User ID	
Call ID	
For testing you can join the call on our web-app: Join Call

There are a few ways in which users can connect using our SDK. We support both long lived tokens and dynamic tokens via two parameters accessible on the StreamVideo class:

StreamVideo(apiKey, user: User, userToken: String)
StreamVideo(apiKey, user: User, tokenLoader: TokenLoader)
For situations where your backend does not require tokens to be refreshed, the first variant of the two above can be used by simply passing in a User object and the userToken as a String.

Using the second variant, a Token Loader can be used to dynamically load a token from a server. On expiration, the SDK automatically calls the Token Loader to obtain a new token.

As long as your handler returns a String it will satisfy the contract of TokenLoader. Here is an example of how you could write the token loader


Future<String> _tokenLoader(String userId) async {
  final token = await backend.loadToken(
    apiKey: Env.apiKey,
    userId: userId,
  );
  return token;
}

StreamVideo(
  apiKey,
  user: user,
  tokenLoader: _tokenLoader,
  onTokenUpdated: (token) async {
    // Callback function with the token.
    // Called when the token is updated.
  },
);
Guest / Anonymous users
For use-cases like live streaming or guest meeting, you may want to allow users to join a call without creating an account.

Guest Users
For these use-cases, the SDK has a guest endpoint which can be used to create a temporary user


final guest = User.guest(userId: guestId, name: guestName, image: guestImage);
final client = StreamVideo(
  apiKey,
  user: guest,
);
final result = await client.connect();
// if result wasn't successful, then result will return null
final userToken = result.getDataOrNull();
final userInfo = client.currentUser;
userInfo.id will be slightly different from what you passed in. This is because the SDK will generate a unique ID for the user. Please use the generated ID across your app.

Anonymous Users

final anonymous = User.anonymous();
final client = StreamVideo(
  apiKey,
  user: anonymous,
);
Anonymous users don't establish an active web socket connection, therefore they won't receive any events. They are just able to watch a livestream or join a call.

The token for an anonymous user should contain the call_cids field, which is an array of the call cid's that the user is allowed to join.

Here's an example JWT token payload for an anonymous user:


{
  "iss": "@stream-io/dashboard",
  "iat": 1726406693,
  "exp": 1726493093,
  "user_id": "!anon",
  "role": "viewer",
  "call_cids": [
    "livestream:123"
  ]
}

Joining and Creating Calls
Creating Calls
To create a call, we first call the makeCall function on the StreamVideo class and pass it the call type and ID. The most common call type is default, which enables full audio and video transmission. However, there are multiple call types (and even custom types) from which you can choose based on your use case.

Call type	Name	Short overview
default	Default	simple 1-1 calls for larger group video calling with sensible defaults
audio_room	Audio	pre-configured for a workflow around requesting permissions in audio settings (speaking, etc.)
livestream	Livestream	access to calls is granted to all authenticated users, useful in one-to-many settings (such as livestreaming)
development	Development	should only be used for testing, permissions are open and everything is enabled (use carefully)
You can read more about call types here.


final call = StreamVideo.instance.makeCall(callType: StreamCallType.defaultType(), id: 'Your-call-ID');
await call.getOrCreate();
Calling makeCall returns a Call object for us to work with. However, it neither connects nor starts transmitting data automatically. To create and join the call, we must then invoke getOrCreate on the returned object which creates the call if it doesn't exist and returns the existing call if it does.

For the call ID there are a few things to note:

You can reuse the same call multiple times.
If you have a unique id for the call we recommend passing that as the id.
If you don't have a unique id you can leave it empty and we'll generate one for you.
As an example, if you're building a telemedicine app, calls will be connected to an appointment. Using your own appointment id as the Call ID makes it easy to find the call later.

Managing Members and Ringing Calls
You can pass certain arguments to the call.getOrCreate() method used in the previous example:

members: Upon creation, we can supply a list of user IDs we would like to immediately add to the call.
ringing: If ringing is set to true, Stream will send a VoIP notification to the users on the call, triggering the platform call screen on iOS and Android.
video: When ringing, the notification will indicate whether it's a video call or an audio-only call, depending on whether you set the video parameter to true or false.
custom: Any custom data associated with the call.
team: A team is a part of Stream Video multi-tenancy support. You can separate different groups of videos and calls using this argument.
notify If notify is set to true, Stream will send a standard non-VoIP push notification to all the users in the call.
By default, calling getOrCreate() assigns admin permission to each user who is supplied during creation. Depending on call permissions settings, call member may have different permissions than other users joining the call. For example, call can be configured so only members can join. See here for more information.

When call is already active you can still manage members:


final call = client.makeCall(callType: StreamCallType.defaultType(), id: 'my-call-id');
call.getOrCreate(memberIds: ['alice', 'bob']);
// grant access to more users
await call.updateCallMembers(updateMembers: [const UserInfo(id: 'charlie', role: 'call_member')]);
// or
await call.addMembers([const UserInfo(id: 'charlie', role: 'call_member')]);
// remove access from some users
await call.updateCallMembers(removeIds: ['charlie']);
// or
await call.removeMembers(['charlie']);
Call CRUD Operations
With calls, we make it easy to perform basic create, read, update, and delete (CRUD) operations on calls providing the user has sufficient permissions.

For example, once a call is created a user can call.update the information on the call by adding custom metadata such as a name, description, or any other arbitrary Map<String, Object> to the call before getOrCreate is invoked.


call.update(custom: {'name': 'My first Call'});
await call.getOrCreate();
Using the update method, a variety of settings can also be applied before the call is created such as:

Ring
Audio
Video
ScreenShare
Recording
Transcription
Backstage
Geofencing
Joining Calls
To join a call that already exists, you must first know two things:

The callType of the existing call
The ID of the existing call
Similar to the flow of creating a call, we can use makeCall to construct a Call class for us to perform operations on.


final call = StreamVideo.instance.makeCall(callType: StreamCallType.defaultType(), id: 'My-existing-call-ID');
await call.getOrCreate();
Next, with our class instantiated, we can connect to the call and SFU by invoking join.


await call.join();
Unlike the call creation flow and functions, the user must have sufficient permissions to join the call or a VideoError will be returned. All users connected via the join() function have the permission type of user by default and are limited in the actions they can perform.

Backstage setup
The backstage feature makes it easy to build a use-case where you and your co-hosts can setup your camera before going live. Only after you call call.goLive() the regular users be allowed to join the livestream.

However, you can also specify a joinAheadTimeSeconds, which allows regular users to join the livestream before it is live, in the specified join time before the stream starts.

Here's an example how to do that:


final call = StreamVideo.instance.makeCall(callType: StreamCallType.livestream(), id: 'my-call-id');
const backstageSetting = StreamBackstageSettings(
  enabled: true,
  joinAheadTimeSeconds: 300,
);
await call.getOrCreate(
  memberIds: ['alice', 'bob'],
  startsAt: DateTime.now().add(const Duration(seconds: 500)),
  backstage: backstageSetting,
);
await call.join();
In the code snippet above, we are creating a call that starts 500 seconds from now. We are also enabling backstage mode, with a joinAheadTimeSeconds of 300 seconds. That means that regular users will be able to join the call 200 seconds from now.

Restricting access
You can restrict access to a call by tweaking the Call Type permissions and roles. A typical use case is to restrict access to a call to a specific set of users -> call members.

Step 1: Set up the roles and permissions
​On our dashboard, navigate to the Video & Audio -> Roles & Permissions section and select the appropriate role and scope. In this example, we will use my-call-type scope.

By default, all users unless specified otherwise, have the user role.

We start by removing the JoinCall permission from the user role for the my-call-type scope. It will prevent regular users from joining a call of this type.

Revoke JoinCall
Next, let's ensure that the call_member role has the JoinCall permission for the my-call-type scope. It will allow users with the call_member role to join a call of this type.

Grant JoinCall
Once this is set, we can proceed with setting up a call instance.


Call and Participant State
When you join a call, we'll automatically expose state in 3 different places: the Stream Video Client, the Call, and the participants.


var clientState = streamVideo.state;
var callState = call.state;
var participants = call.state.value.callParticipants;
Call State
When a Call is created, users can subscribe to receive notifications about any changes that may occur during the call's lifecycle. To access the state of a call, use call.state.value to obtain the latest CallState snapshot, or use valueStream to listen for real-time changes to the CallState.

This functionality is particularly useful for determining which parts of the UI or application to render based on the current state or lifecycle of the ongoing call.

For example, you may want to display an indicator to users when a call is being recorded:


StreamBuilder<CallState>(
  stream: call.state.valueStream, // Subscribe to state changes
  builder: (context, snapshot) {
    final state = snapshot.data;
    if (state.isRecording) {
      return CallRecordingUI();
    } else {
      return RegularCallUI();
    }
  },
),
Optimizing State Updates with Partial State
The call state contains a lot of different fields, and therefore updates often. In the example above we are only interested in isRecording, but the builder will still be called every time anything in the state changes. To improve this the Call object also contains a property for partialState. The partialState requires a selector callback which you can use to filter the data needed.

For example, you can get a Stream that indicates if the call is being recorded or not:


Stream<bool> isRecordingStream = call.partialState((state) => state.isRecording);
You can also use records to return multiple values, for example for a livestream:


Stream<({bool isBackstage, DateTime? endedAt})> partialStateStream =
    call.partialState((state) => (isBackstage: state.isBackstage, endedAt: state.endedAt));
If you use a custom class to filter the data, make sure that class implements equality correctly, for example by using equatable. If you create a new object without equality checks the Stream might be updated on every state change.

Using PartialCallStateBuilder Widget
To use the partialState in your widgets you can use the regular StreamBuilder or the PartialCallStateBuilder to make your life a bit easier.


PartialCallStateBuilder(
  call: call,
  selector: (state) => state.isRecording,
  builder: (context, isRecording) =>
      isRecording ? CallRecordingUI() : RegularCallUI(),
);
Call State Properties
The following fields are available on the call state:

Attribute	Description
callCid	The type and id of the call.
currentUserId	The user ID of the local user.
createdByUser	The user that created the call.
createdByUserId	The id of a user that created the call.
isRingingFlow	If this call has ringing set to true.
sessionId	The current session ID for the call.
status	The current call state - see next section for more information.
settings	The settings for this call.
preferences	The call preferences - see below for more information.
egress	Contains URL for playlist of recording.
rtmpIngress	Contains the RTMP ingest URL used for live streaming.
isRecording	If the call is being recorded or not.
isBroadcasting	If a call is broadcasting (to HLS) or not.
isTranscribing	If transcriptions are active or not for this call.
isCaptioning	If closed captions are active or not for this call.
isBackstage	If a call is in backstage mode or not.
isAudioProcessing	If audio processing (e.g., noise cancellation) is active.
videoInputDevice	Video input device currently set for the call.
audioInputDevice	Audio input device currently set for the call.
audioOutputDevice	Audio output device currently set for the call.
ownCapabilities	Which actions current user have permission to do.
callParticipants	The list of call participants.
callMembers	The list of call members (including those not currently in the call).
createdAt	When the call was created.
startsAt	When the call is scheduled to start.
endedAt	When the call ended.
updatedAt	When the call was updated.
startedAt	When the call session was started.
liveStartedAt	When call was set as live.
liveEndedAt	When call was set as not live.
timerEndsAt	Timestamp when the call will end, if maxDuration was set for the call.
blockedUserIds	Ids of blocked users for this call.
participantCount	Current participants count on this call.
anonymousParticipantCount	Current anonymous participants count on this call.
iOSMultitaskingCameraAccessEnabled	Whether multitasking camera access is enabled on iOS.
capabilitiesByRole	What different roles (user, admin, moderator etc.) are allowed to do.
custom	Custom data provided for this call.
Call Preferences
Call preferences configure various aspects of call behavior and performance including timeouts, reaction behavior, statistics reporting, and video publishing options. For comprehensive information about configuring and using call preferences, see the Call Preferences Configuration guide.

Computed Properties
Some properties are computed from the state for convenience:


// Get the local participant
var localParticipant = call.state.value.localParticipant;
// Get all participants except yourself
var otherParticipants = call.state.value.otherParticipants;
// Get participants who are currently speaking
var activeSpeakers = call.state.value.activeSpeakers;
// Get members who are being called but haven't answered
var ringingMembers = call.state.value.ringingMembers;
// Check if you created the call
var createdByMe = call.state.value.createdByMe;
Understanding Call Status
The status property of the CallState object indicates the current state of the call. Depending on where you are in the call lifecycle, CallStatus can have one of the following possible values.

Call Status	Description
CallStatusIdle	Indicates that there is no active call at the moment.
CallStatusIncoming	Indicates that there's an incoming call, and you need to display an incoming call screen.
CallStatusOutgoing	Indicates that the user is making an outgoing call, and you need to display an outgoing call screen.
CallStatusConnecting	Indicates that the SDK is attempting to connect to the call.
CallStatusReconnecting	Indicates that the SDK is attempting to reconnect to the call. The number of attempts can be set via the attempt property.
CallStatusReconnectionFailed	Indicates that the SDK failed to reconnect.
CallStatusMigrating	Indicates that the SDK is attempting to migrate from one SFU to another.
CallStatusConnected	Indicates that the user is connected to the call and is ready to send and receive tracks.
CallStatusDisconnected	Indicates that the call has ended, failed, or has been canceled. The exact reason can be accessed via the DisconnectedReason property.
CallStatusJoining	Indicates that the user is in the process of joining the call.
CallStatusJoined	Indicates that the user has successfully joined the call.
By checking the CallStatus value in the CallState object, you can determine the current state of the call and adjust your UI accordingly.


// Example of using call status
PartialCallStateBuilder(
  call: call,
  selector: (state) => state.status,
  builder: (context, status) {
    if (status.isConnecting) {
      return ConnectingUI();
    } else if (status.isConnected) {
      return ConnectedCallUI();
    } else if (status.isReconnecting) {
      return ReconnectingUI(attempt: status.attempt);
    }
    return DefaultCallUI();
  },
);
Understanding CallStatusDisconnected Reasons
When a call becomes disconnected, the CallStatusDisconnected status contains a DisconnectReason that explains why the disconnection occurred. Understanding these reasons allows you to handle different scenarios appropriately in your application.

Available Disconnect Reasons
Disconnect Reason	Description
DisconnectReasonTimeout	The call timed out.
DisconnectReasonFailure	A general failure occurred during the call.
DisconnectReasonSfuError	An SFU server error occurred.
DisconnectReasonRejected	Can happen when the ringing call is triggered and the last participant rejects the call.
DisconnectReasonBlocked	The user was blocked from the call.
DisconnectReasonCancelled	The call was cancelled by the caller.
DisconnectReasonEnded	The call was ended.
DisconnectReasonReplaced	The call was replaced by another call.
DisconnectReasonLastParticipantLeft	The last participant left the call and the dropIfAloneInRingingFlow was set to true.
DisconnectReasonReconnectionFailed	Failed to reconnect to the call after network issues.
Listening to Call Disconnection
You can listen to call state changes and handle disconnection using partial state:


// Listen to call status changes and handle disconnection
PartialCallStateBuilder(
  call: call,
  selector: (state) => state.status,
  builder: (context, status) {
    if (status.isDisconnected) {
      final disconnectedStatus = status as CallStatusDisconnected;
      final reason = disconnectedStatus.reason;
      return DisconnectedCallUI(reason: reason);
    }
    // Handle other statuses...
    return RegularCallUI();
  },
);
Using onCallDisconnected Callback
Both StreamCallContainer and LivestreamPlayer provide an onCallDisconnected callback that you can use to handle disconnection events:


// In StreamCallContainer
StreamCallContainer(
  call: call,
  onCallDisconnected: (CallDisconnectedProperties properties) {
    final reason = properties.reason;
    final call = properties.call;
    // Handle the disconnection
    _handleCallDisconnected(reason);
    // Navigate away or show appropriate UI
    Navigator.of(context).pushReplacementNamed('/home');
  },
);
// In LivestreamPlayer
LivestreamPlayer(
  call: call,
  onCallDisconnected: (CallDisconnectedProperties properties) {
    final reason = properties.reason;
    // Handle livestream disconnection
    if (reason is DisconnectReasonEnded) {
      _showStreamEndedDialog();
    } else {
      // Handle other disconnection reasons
    }
  },
);
Handling Participant Limit Reached
When a call has a maximum participant limit configured, you can specifically handle the participant limit reached scenario:


// Complete example with pattern matching
void _handleCallDisconnected(DisconnectReason reason) {
  switch (reason) {
    case DisconnectReasonSfuError(error: final sfuError):
      if (sfuError.code == SfuErrorCode.callParticipantLimitReached) {
        // Handle participant limit reached
        _showDialog(
          title: 'Call Full',
          message: 'This call has reached its participant limit. Please try again later.',
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      }
      break;
    // Handle other disconnect reasons...
  }
}
Participant State

var participants = call.state.value.callParticipants;
var localParticipant = call.state.value.localParticipant;
In the call state, you can find the parameter callParticipants. This parameter allows you to access and manipulate the participants present on the call. By using callParticipants, you can easily map over the participants and observe changes in their configuration. For instance, you can keep track of which participant is currently speaking, which participant is the dominant speaker, and which participant is pinned to the call. Additionally, callParticipants allows you to monitor other changes to the call's configuration as well.

Overall, callParticipants is a powerful tool that provides you with a lot of control and insight into the call's current state and configuration. By leveraging this parameter effectively, you can create more advanced and robust call applications.


for (final participant in call.state.value.callParticipants) {
  if (participant.isDominantSpeaker) {
    setState(() => dominantSpeaker = participant);
  }
}
Caveat: In a call with many participants, the value of the callParticipants is truncated to 250 participants.

The participants who are publishing video, audio, or screen sharing have priority over the other participants in the list. This means, for example, that in a livestream with one host and many viewers, the host is guaranteed to be in the list.

Participant State Properties
The following fields are available on each participant:

Attribute	Description
userId	The unique user ID of the participant.
roles	The user's roles in the call.
name	The participant's display name.
image	The participant's profile image URL.
custom	Any custom data added to the user.
sessionId	The session ID of the participant.
trackIdPrefix	Returns the user's track ID prefix.
publishedTracks	Returns the participant's published tracks (video, audio, screen).
isSpeaking	Returns whether the participant is speaking.
isDominantSpeaker	Returns whether the participant is a dominant speaker.
isPinned	Returns whether the participant is pinned.
pin	The pin information if the participant is pinned (is it a local or global pin).
isLocal	Returns whether the participant is the local user.
isOnline	Returns whether the participant is online.
pausedTracks	The tracks that are currently server-side paused for the local participant.
connectionQuality	The participant's connection quality.
audioLevel	The current audio level for the user.
audioLevels	List of the last 10 audio levels.
reaction	The current reaction added by the user.
viewportVisibility	The user's visibility on the screen.
participantSource	The participant source: WebRTC (default), RTMP (OBS), WHIP, SIP, RTSP, SRT...
Track Information
Participants have track information for different media types:


// Access specific tracks
var videoTrack = participant.videoTrack;
var audioTrack = participant.audioTrack;
var screenShareTrack = participant.screenShareTrack;
// Check if tracks are enabled
var isVideoEnabled = participant.isVideoEnabled;
var isAudioEnabled = participant.isAudioEnabled;
var isScreenShareEnabled = participant.isScreenShareEnabled;
Detecting participant source
Participants can be created from different sources (WebRTC, RTMP/OBS, WHIP, SIP, etc...). The participantSource property of the CallParticipantState object indicates the source of the participant.


// participants joining thrugh OBS have RTMP source
final obsParticipants = call.state.value.callParticipants.where((p) => p.participantSource == SfuParticipantSource.rtmp);
Listening to Participant Changes
You can listen to changes in participants using partial state:


// Listen to changes in speaking participants
PartialCallStateBuilder(
  call: call,
  selector: (state) => state.activeSpeakers,
  builder: (context, activeSpeakers) {
    return Column(
      children: activeSpeakers.map((participant) =>
        Text('${participant.name} is speaking')
      ).toList(),
    );
  },
);
// Listen to dominant speaker changes
PartialCallStateBuilder(
  call: call,
  selector: (state) => state.callParticipants
      .where((p) => p.isDominantSpeaker)
      .firstOrNull,
  builder: (context, dominantSpeaker) {
    return dominantSpeaker != null
        ? Text('Dominant speaker: ${dominantSpeaker.name}')
        : const SizedBox.shrink();
  },
);
Combining CallState and CallParticipantState makes building custom UIs and integrations a breeze. If there is a property or API that is not exposed for your specific use case, feel free to reach out to us. We are constantly iterating and exposing APIs based on your feedback.

Client State

// Client state is available in the client object
var clientState = StreamVideo.instance.state;
Attribute	Description
user	The user you're currently authenticated as.
connection	The connection state of Stream Video.
activeCalls	The calls you've currently joined (when multiple calls are enabled).
activeCall	The call you've currently joined (when single call mode is enabled).
incomingCall	Contains the incoming call if ringing is set to true.
outgoingCall	Contains the outgoing call if ringing is set to true.


Call Types
The Video SDK provides pre-defined call types with different default permissions and feature configurations. You can extend these or create custom types via the dashboard.

Best Practices
Use the development call type only for testing, never in production
Configure call types in the dashboard before deploying to production
Set up proper user roles to simplify permission management
Use backstage mode for scheduled calls or livestreams that need preparation time
Review default capabilities and customize them based on your security requirements
Key Concepts
Call Type - Pre-defined configurations with associated user roles and capabilities. Four default types are available, or create custom types via the dashboard.
User Role - Defines what actions a user can perform. Users can have multiple roles. Use existing roles or define custom ones via the dashboard.
Call Capabilities - Specific actions a participant can perform (such as send-video or end-call). Associated with user roles and customizable via the dashboard.
Call Types
Four pre-defined call types are available:

default - 1-1 or group video calls with sensible defaults
audio_room - Pre-configured for audio-only experiences with permission request workflows (like Clubhouse or Twitter Spaces)
livestream - All authenticated users can access calls; ideal for one-to-many broadcasting
development - All permissions enabled; use only for testing
Each call type includes specific settings. The backstage concept allows calls to be created but not directly joined until goLive() is called, useful for scheduled calls.

Development
The development call type has all permissions enabled for testing purposes. Do not use in production since all participants can perform any action (blocking, muting, etc).

Backstage is disabled, so calls start immediately without requiring goLive().

Default
The default call type supports 1-1 calls, group calls, and meetings. Video and audio are enabled, backstage is disabled, and admins/hosts have elevated permissions.

The default type can be used in apps that use regular video calling. To learn more try our tutorial on building a video calling app.

Audio Room
The audio_room call type suits apps like Clubhouse or Twitter Spaces. It includes a pre-configured workflow for requesting speaking permissions. Backstage is enabled by default; call goLive() to make the call active for all participants.

See the Audio Room tutorial for implementation details.

Livestream
The livestream call type is configured for live streaming apps. All authenticated users can access calls, and backstage is enabled by default.

See the live streaming tutorial for implementation details.

Call type settings
Each call type has configurable settings. See the defaults table for a comparison of settings across call types.

Audio
Setting Name	Type	Description
access_request_enabled	Boolean	When true users that do not have permission to this feature can request access for it
opus_dtx_enabled	Boolean	When true OPUS DTX is enabled
redundant_coding_enabled	Boolean	When true redundant audio transmission is enabled
mic_default_on	Boolean	When true the user will join with the microphone enabled by default
speaker_default_on	Boolean	When true the user will join with the audio turned on by default
default_device	String speaker or earpiece	The default audio device to use
Backstage
Setting Name	Type	Description
enabled	Boolean	When backstage is enabled, calls will be in backstage mode when created and can be joined by users only after goLive is called
Video
Setting Name	Type	Description
enabled	Boolean	Defines whether video is enabled for the call
access_request_enabled	Boolean	When true users that do not have permission to this feature can request access for it
camera_default_on	Boolean	When true, the camera will be turned on when joining the call
camera_facing	String front, back or external	When applicable, the camera that should be used by default
target_resolution	Target Resolution Object	The ideal resolution that video publishers should send
The target resolution is an advanced setting. Modifying defaults can degrade performance. Structure:

Setting Name	Type	Description
width	Number	The width in pixels
height	Number	The height in pixels
bitrate	Number	The bitrate
Screensharing
Setting Name	Type	Description
enabled	Boolean	Defines whether screensharing is enabled
access_request_enabled	Boolean	When true users that do not have permission to this feature can request access for it
Recording
Setting Name	Type	Description
mode	String available, disabled or auto-on	available → recording can be requested
disabled → recording is disabled
auto-on → recording starts and stops automatically when one or multiple users join the call
quality	String audio-only, 360p, 480p, 720p, 1080p, 1440p	Defines the resolution of the recording
audio_only	boolean	If true the recordings will only contain audio
layout	object, for more information see the API docs	Configuration options for the recording application
Broadcasting
Setting Name	Type	Description
enabled	Boolean	Defines whether broadcasting is enabled
hls	HLS Settings (object)	Settings for HLS broadcasting
HLS Settings
Setting Name	Type	Description
enabled	Boolean	Defines whether HLS is enabled or not
auto_on	Boolean	When true HLS streaming will start as soon as users join the call
quality_tracks	String audio-only, 360p, 480p, 720p, 1080p, 1440p	The tracks to publish for the HLS stream (up to three tracks)
Geofencing
Setting Name	Type	Description
names	List of one or more of these strings european_union, iran_north_korea_syria_exclusion, china_exclusion, russia_exclusion, belarus_exclusion, india, united_states, canada	The list of geofences that are used for the calls of these type
See the API docs for details.

Transcription
Setting Name	Type	Description
mode	String available, disabled or auto-on	Not implemented yet
closed_caption_mode	String	Not implemented yet
Ringing
Setting Name	Type	Description
incoming_call_timeout_ms	Number	Defines how long the SDK should display the incoming call screen before discarding the call (in ms)
auto_cancel_timeout_ms	Number	Defines how long the caller should wait for others to accept the call before canceling (in ms)
Push Notifications Settings
Setting Name	Type	Description
enabled	Boolean	
call_live_started	Event Notification Settings Object	The notification settings used for call_live_started events
session_started	Event Notification Settings Object	The notification settings used for session_started events
call_notification	Event Notification Settings Object	The notification settings used for call_notification events
call_ring	Event Notification Settings Object	The notification settings used for call_ring events
Event notification settings object structure:

Setting Name	Type	Description
enabled	Boolean	Whether this object is enabled
apns	APNS Settings Object	The settings for APN notifications
APNS Settings Object
Customize remote notifications by implementing a Notification Service Extension. For simple customizations, modify the title and body fields at the call type level. Both fields are handlebars templates with call and user objects in scope.

Setting Name	Type	Description
title	Template	The string template for the title field of the notification
body	Template	The string template for the body field of the notification
Defaults for call type settings
audio-room	default	livestream	development
Audio				
access_request_enabled	✅	✅	❌	✅
opus_dtx_enabled	✅	✅	✅	✅
redundant_coding_enabled	✅	✅	✅	✅
mic_default_on	❌	✅	❌	✅
speaker_default_on	✅	✅	✅	✅
default_device	speaker	earpiece	speaker	earpiece
Backstage				
enabled	✅	❌	✅	❌
Video				
enabled	❌	✅	✅	✅
access_request_enabled	❌	✅	❌	✅
target_resolution	N/A	Width: 2560
Height 1440
Bitrate 5000000	Width: 1920
Height: 1080
Bitrate 3000000	Width: 1920
Height 1080
Bitrate 3000000
camera_default_on	❌	✅	✅	✅
camera_facing	front	front	front	front
Screensharing				
enabled	❌	✅	✅	✅
access_request_enabled	❌	✅	❌	✅
Recording				
mode	available	available	available	available
quality	720p	720p	720p	720p
Broadcasting				
enabled	✅	✅	✅	✅
hls.auto_on	❌	❌	❌	❌
hls.enabled	available	available	available	available
hls.quality_tracks	[720p]	[720p]	[720p]	[720p]
Geofencing				
names	[]	[]	[]	[]
Transcriptions				
mode	available	available	available	available
Ringing				
incoming_call_timeout_ms	0	15000	0	15000
auto_cancel_timeout_ms	0	15000	0	15000
User roles
Five pre-defined user roles are available:

user - Standard participant
moderator - Can moderate calls
host - Call host with elevated permissions
admin - Full administrative access
call-member - Basic call membership
Each role has associated capabilities. Access default roles and capabilities in the Stream Dashboard. A well-defined role setup simplifies permission management.

Call Capabilities
A capability defines actions a user can perform on a call. Each user has capabilities attached based on their role. Modify default capabilities in the dashboard or change them dynamically at runtime.

Users with permission to assign capabilities can grant them to other users, enabling flexible permission management.

If you want to learn more about doing this, head over to the Permissions and Capabilities chapter.

Default call capabilities
When fetching a call from the API, the response includes the user's allowed actions:

join-call
read-call
create-call
join-ended-call
join-backstage
update-call
update-call-settings
screenshare
send-video
send-audio
start-record-call
stop-record-call
start-broadcast-call
stop-broadcast-call
end-call
mute-users
update-call-permissions
block-users
create-reaction
pin-for-everyone
remove-call-member
start-transcription-call
stop-transcription-call

Camera Configuration
The Stream Video SDK provides comprehensive camera configuration capabilities, allowing you to control various aspects of the camera during video calls. From basic operations like enabling/disabling the camera to advanced features like zoom and focus control, the SDK offers an intuitive interface for managing camera functionality.

Before attempting to access the user's camera, ensure the appropriate permissions are set in both the iOS plist file and Android Manifest. You can read more about permissions in installation section.

Basic Camera Operations
Enable/Disable Camera
Control whether the camera is active during a call:


// Enable camera
await call.setCameraEnabled(enabled: true);
// Disable camera
await call.setCameraEnabled(enabled: false);
// Enable camera with specific constraints
await call.setCameraEnabled(
  enabled: true,
  constraints: const CameraConstraints(
    facingMode: FacingMode.environment,
    mirrorMode: MirrorMode.off,
  ),
);
Camera Position Control
Switch between front and rear cameras:


// Set to front camera
await call.setCameraPosition(CameraPosition.front);
// Set to back camera
await call.setCameraPosition(CameraPosition.back);
// Flip camera (toggles between front and back)
await call.flipCamera();
Video Input Device Management
Select and configure specific camera devices:


// Set a specific video input device
await call.setVideoInputDevice(device);
// Get current camera device
var currentCamera = call.state.value.videoInputDevice;
Advanced Camera Features
Zoom Control
Adjust the camera zoom level programmatically:


// Set zoom level (1.0 = no zoom, higher values = more zoom)
await call.setZoom(zoomLevel: 2.0);
Focus and Exposure Control
Control camera focus and exposure points:


// Set focus to a specific point on the screen
// Point coordinates are relative to the video view (0.0 to 1.0)
await call.focus(focusPoint: Point(0.5, 0.5)); // Center of the screen
// Auto focus (no specific point)
await call.focus();
Platform-Specific Features
iOS Multitasking Camera Access
For iOS devices, you can control whether the camera remains accessible during multitasking:


// Enable multitasking camera access (iOS only)
await call.setMultitaskingCameraAccessEnabled(true);
// Disable multitasking camera access (iOS only)
await call.setMultitaskingCameraAccessEnabled(false);
You don't need to explicitly call this method, as the SDK will handle it automatically when the muteVideoWhenInBackground option is set to false in StreamVideoOptions.

Camera State Management
Accessing Camera State
You can access the current camera state through the call state:


// Get current camera device
var camera = call.state.value.videoInputDevice;
// Check if camera is enabled
var isCameraEnabled = call.state.value.localParticipant?.isVideoEnabled ?? false;
Error Handling
All camera methods return a Result type for proper error handling:


final result = await call.setCameraEnabled(enabled: true);
result.fold(
  success: (success) {
    print('Camera enabled successfully');
  },
  failure: (failure) {
    print('Failed to enable camera: ${failure.error.message}');
  },
);


Microphone and Audio Configuration
The Stream Video SDK provides comprehensive audio configuration capabilities, allowing you to control microphone input, audio output devices, and manage audio routing during video calls. The SDK abstracts the complexities of audio device management while providing platform-specific optimizations.

Before attempting to access the user's audio devices, ensure the appropriate permissions are set in both the iOS plist file and Android Manifest. You can read more about permissions in installation section.

Basic Audio Operations
Microphone Control
Enable or disable the microphone during a call:


// Enable microphone
await call.setMicrophoneEnabled(enabled: true);
// Disable microphone (mute)
await call.setMicrophoneEnabled(enabled: false);
Audio Input Device Management
Select and configure specific microphone devices:


// Set a specific audio input device
await call.setAudioInputDevice(device);
// Get current microphone device
var currentInput = call.state.value.audioInputDevice;
Audio Output Device Management
Control where audio is played back:


// Set a specific audio output device
await call.setAudioOutputDevice(device);
// Get current audio output device
var currentOutput = call.state.value.audioOutputDevice;
Platform-Specific Audio Routing
iOS Audio Route Selection
On iOS, the preferred way to handle external audio device selection is through the native audio route picker, as iOS doesn't allow apps to implicitly set external device output:


// Trigger the native iOS audio route selection UI
await RtcMediaDeviceNotifier.instance.triggeriOSAudioRouteSelectionUI();
On iOS, use triggeriOSAudioRouteSelectionUI() instead of setAudioOutputDevice() for external audio devices like AirPods, Bluetooth headphones, or external speakers. This provides the native iOS experience users expect and respects iOS audio routing policies.

Device Discovery and Management
Listing Connected Devices
Query all connected audio devices:


// Get all audio input devices (microphones)
final audioInputDevices = RtcMediaDeviceNotifier.instance.audioInputs();
// Get all audio output devices (speakers/headphones)
final audioOutputDevices = RtcMediaDeviceNotifier.instance.audioOutputs();
Enumerating Devices
For more comprehensive device querying, use the enumerateDevices method:


// Get all available devices
final allDevicesResult = await RtcMediaDeviceNotifier.instance.enumerateDevices();
allDevicesResult.fold(
  success: (success) {
    // Process all devices
    for (final device in success.data) {
      print('Device: ${device.label}, Kind: ${device.kind}');
    }
  },
  failure: (failure) {
    print('Failed to enumerate devices: ${failure.error.message}');
  },
);
// Get devices filtered by kind
final audioInputResult = await RtcMediaDeviceNotifier.instance.enumerateDevices(
  kind: RtcMediaDeviceKind.audioInput,
);
final audioOutputResult = await RtcMediaDeviceNotifier.instance.enumerateDevices(
  kind: RtcMediaDeviceKind.audioOutput,
);
Listening to Device Changes
Monitor when audio devices are connected or disconnected:


// Listen for device changes
RtcMediaDeviceNotifier.instance.onDeviceChange.listen((devices) {
  // Filter for audio input devices
  final audioInputDevices = devices.where(
    (device) => device.kind == RtcMediaDeviceKind.audioInput
  );
  // Filter for audio output devices
  final audioOutputDevices = devices.where(
    (device) => device.kind == RtcMediaDeviceKind.audioOutput
  );
  // Automatically switch to the first available microphone
  if (audioInputDevices.isNotEmpty) {
    call.setAudioInputDevice(audioInputDevices.first);
  }
});
Muting Audio Playout
Temporarily mute or resume all audio output on the device. This silences playout only and does not change the microphone state or alter remote track subscriptions.


import 'package:stream_webrtc_flutter/stream_webrtc_flutter.dart' as rtc;
// To mute
rtc.Helper.pauseAudioPlayout();
// To unmute
rtc.Helper.resumeAudioPlayout();
This is a global playout toggle for the app's audio session. Use it for UX flows like a "mute all sounds" switch or when the app goes to the background. It does not stop remote participants from sending audio and does not affect per‑participant mute state.

If you want to mute audio playout altogether when the app is backgrounded and resume it when the app returns to the foreground, wire it to app lifecycle changes:


import 'package:stream_webrtc_flutter/stream_webrtc_flutter.dart' as rtc;
import 'package:flutter/widgets.dart';
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      rtc.Helper.resumeAudioPlayout();
      break;
    case AppLifecycleState.inactive:
    case AppLifecycleState.paused:
    case AppLifecycleState.detached:
      rtc.Helper.pauseAudioPlayout();
      break;
  }
}
For a complete example inside a StatefulWidget, remember to register and unregister the lifecycle observer:


class CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed) {
      rtc.Helper.resumeAudioPlayout();
    } else {
      rtc.Helper.pauseAudioPlayout();
    }
  }
}
Error Handling
Implement proper error handling for audio operations:


final result = await call.setMicrophoneEnabled(enabled: true);
result.fold(
  success: (success) {
    print('Microphone enabled successfully');
  },
  failure: (failure) {
    print('Failed to enable microphone: ${failure.error.message}');
  },
);


Initial Call Configuration
There are two ways to configure the initial call setup:

Using the Stream Dashboard to setup the initial configuration per call type
Passing the initial configuration in by CallConnectOptions parameter
Stream Dashboard
You can configure the initial call setup using the Stream Dashboard. This is useful when you want to set up the initial configuration for a specific call type. Find the call type you want to configure on the list of call types: https://dashboard.getstream.io/app/{YOUR-APP-ID}/video/call-types. Then under Video, Audio and Advanced settings sections you can set things like:

Turn camera on/off by default
Turn microphone on/off by default
Set default camera facing
Set default audio output device
Advanced settings dashboard
Default Device Selection Logic
The Stream Dashboard settings control device selection through a priority-based system:

Audio Output Priority:

External devices (headphones, Bluetooth) - Always preferred when available

Speaker - Used when video camera is on, speaker setting is enabled, or explicitly set as default device

Earpiece - Fallback for mobile devices

Audio Input:

Matches the output device when possible (e.g., Bluetooth headset for both input/output)
Uses first available microphone as fallback
Video Input:

Selects camera based on Dashboard camera_facing setting (front/back/external)
Chooses external camera when multiple devices available
Defaults to any available camera if preferred facing unavailable
CallConnectOptions parameter
​Using the CallConnectOptions class you can configure the initial call setup programmatically. It provides the following options:

Enabling or disabling the camera
Enabling or disabling the microphone
Enabling or disabling the screen sharing
Setting the camera facing mode
Setting the audio output device
Setting the audio input device
You can provide this class as a parameter when joining a call:


final call = client.makeCall(callType: StreamCallType.defaultType(), id: '345');
  await call.join(connectOptions: connectOptions);
Or by passing it to the StreamCallContainer widget


StreamCallContainer(
          call: widget.call,
          callConnectOptions: connectOptions,
          ...
);
You can access current options by calling call.connectOptions on the Call object.


final call = client.makeCall(callType: StreamCallType.defaultType(), id: '345');
  await call.getOrCreate();
  final callOptions = call.connectOptions;
When getOrCreate method is called, the default options will be created based on the Stream Dashboard settings. You can then leverage the call.connectOptions to modify the default settings and pass them to the join method at the end.

call.connectOptions also has a setter but it should be used carefully. Depending on the moment in the call lifecycle, it might be overwritten by default configuration or it might be too late to apply the changes.

Noise Cancellation
The Noise Cancellation feature in our Flutter Video SDK can be enabled by adding the stream_video_noise_cancellation package to your project and by having it enabled in the Stream dashboard. This package leverages noise cancellation technology developed by krisp.ai.

Installation
Adding the SDK to Your Project
To add the stream_video_noise_cancellation dependency, update your pubspec.yaml file:


dependencies:
  stream_video_noise_cancellation: ^latest
Alternatively, you can add it via the command line:


flutter pub add stream_video_noise_cancellation
Integration
To enable noise cancellation in your app, set the NoiseCancellationAudioProcessor instance from the stream_video_noise_cancellation package as the audioProcessor in StreamVideoOptions when initializing StreamVideo:


import 'package:stream_video_push_notification/stream_video_push_notification.dart';
StreamVideo(
  apiKey,
  user: user,
  options: StreamVideoOptions(
    audioProcessor: NoiseCancellationAudioProcessor(),
  ),
  ...
);
Once integrated, you can use the Call API to toggle the filter and monitor feature availability.

Feature availability
Noise cancellation settings can be accessed within CallState. The noiseCancellation configuration contains a mode property that indicates availability:


final noiseCancellationMode = call.state.value.settings.audio.noiseCancellation?.mode;
//or listen for state changes
final subscription = _call!.state.listen((state) {
  final mode = state.settings.audio.noiseCancellation?.mode;
});
subscription.cancel();
.available The featue has been enabled on the dashboard and it's available for the call. In this case, you are free to present any noise cancellation toggle UI in your application.

.disabled The feature hasn't been enabled on the dashboard or the feature isn't available for the call. In this case, you should hide any noise cancellation toggle UI in your application.

.autoOn Similar to .available with the difference that if possible, the StreamVideo SDK will enable the filter automatically, when the user join the call.

While noise cancellation may be enabled, it is a resource-intensive process. It is recommended to enable it only on devices that support advanced audio processing.

You can check if a device supports advanced audio processing with deviceSupportsAdvancedAudioProcessing() method on your StreamVideo instance.

This method returns true if the iOS device supports Apple's Neural Engine or if an Android device has the FEATURE_AUDIO_PRO feature enabled. Devices with this capability are better suited for handling noise cancellation efficiently.

For optimal performance, consider testing different device models or implementing a benchmarking mechanism.

For .autoOn mode to function properly:

A NoiseCancellationAudioProcessor must be set as the audioProcessor in your StreamVideo instance.
The device must support advanced audio processing.
Activate/Deactivate the filter
To enable noise cancellation during a call, use:


call.startAudioProcessing();
To disable noise cancellation, call:


call.stopAudioProcessing();
You can always check if noise cancellation is enabled or not by:


final isNoiseCancellationActive = call.state.value.isAudioProcessing;


Querying Calls
For many different use cases, such as video calls, livestreams, or audio rooms, you may want to search and filter calls based on different criteria, such as:

Upcoming calls
Calls that are currently live
Popular livestreams or audio rooms with a link to the recording.
To facilitate these, the SDK provides methods which allows users to quickly perform sorting and filtering using the queryCalls() method on StreamVideo:


var calls = StreamVideo.instance.queryCalls(filterConditions: {});
Filtering
To filter calls, a map containing the fields and conditions must be supplied to queryCalls via the filterConditions parameter.


final result = await video.queryCalls(
  filterConditions: {
    "custom.flutterAudioRoomCall": true,
  },
);
In the above example, we filter all calls that contain the custom field flutterAudioRoomCall. Other filtering options include call type, members, and start times.

For instance, to find all livestreams on our application, we can set the type filter to livestream.


final result = await video.queryCalls(
  filterConditions: {
    "type": 'livestream',
  },
);
Filter expressions support multiple matching criteria, and it is also possible to combine filters. For more information, please visit the filter operators guide. The full list of options that you can filter by is listed in the table below.

Option	Description
type	The call type. Typically default, livestream etc
id	The id for this call
cid	The cid for this call. IE default:123
created_by_user_id	The user id who created the call
created_at	When the call was created
updated_at	When the call was updated
starts_at	When the call starts at
ended_at	When the call ended
backstage	If the call is in backstage mode or not
members	Check if you are a member of this call
custom	You can query custom data using the "custom.myfield" syntax
Sorting
Similar to filtering, the SDK offers robust support for sorting, enabling sorting on the following fields:

starts_at
created_at
updated_at
ended_at
type
id
cid
To add a sort, it is simple as specifying a list of sorts to the queryCalls function:


final result = await video.queryCalls(
  // ...
  sorts: [
    SortParamRequest(field: 'starts_at', direction: -1),
  ],
);
The queryCalls function can take multiple sort parameters, which can be combined with filtering to give you powerful control over the data in your application.

Watching calls
​If you specify watch parameter as true, the SDK will create a subscription to the call data on the server and you'll be able to receive updates in real-time.

The server will send updates to the client when the call data changes (for example, members are updated, a call session has started, etc...). This is useful for showing a live preview of who is in the call or building a call dashboard.

You can listen to call events via the StreamVideo.instance.events stream.


Querying Call Members
When you create or join a call you get a list of call members, however this can return at most 100 members:


// The maximum limit is 100
// The default limit is 25
await call.getOrCreate(membersLimit: 100)
//or
await call.join(membersLimit: 100)
To get the complete list of call members the Stream API allows you to query, filter and sort members of a call using a paginated list.

Examples
Below are a few examples of how to use this API:


// sorting and pagination
final sortParam = SortParamRequest(direction: 1, field: 'user_id');
final result = await call.queryMembers(sorts: [sortParam], limit: 10);
// loading the next page
if(result.isSuccess) {
    final next = result.getDataOrNull()?.next;
    final result2 = await call.queryMembers(sorts: [sortParam], limit: 10, next: next);
}
// filtering
final result = await call.queryMembers(filterConditions: {'role': {'eq': 'admin'}});
Sort options
Sorting is supported on these fields:

user_id
created_at
Filter options
Name	Type	Description	Supported operators
user_id	string	User ID	$in, $eq, $gt, $gte, $lt, $lte, $exists
role	string	The role of the user	$in, $eq, $gt, $gte, $lt, $lte, $exists
custom	Object	Search in custom membership data, example syntax: {'custom.color': {$eq: 'red'}}	$in, $eq, $gt, $gte, $lt, $lte, $exists
created_at	string, must be formatted as an RFC3339 timestamp (for example 2021-01-15T09:30:20.45Z)	Creation time of the user	$in, $eq, $gt, $gte, $lt, $lte, $exists
updated_at	string, must be formatted as an RFC3339 timestamp (for example 2021-01-15T09:30:20.45Z)	The time of the last update of the user	$in, $eq, $gt, $gte, $lt, $lte, $exists
The Stream API allows you to specify filters and ordering for several endpoints. The query syntax is similar to that of Mongoose, however we do not run MongoDB on the backend. Only a subset of the MongoDB operations are supported.

Name	Description	Example
$eq	Matches values that are equal to a specified value.	{ "key": { "$eq": "value" } } or the simplest form { "key": "value" }
$q	Full text search (matches values where the whole text value matches the specified value)	{ "key": { "$q": "value } }
$gt	Matches values that are greater than a specified value.	{ "key": { "$gt": 4 } }
$gte	Matches values that are greater than or equal to a specified value.	{ "key": { "$gte": 4 } }
$lt	Matches values that are less than a specified value.	{ "key": { "$lt": 4 } }
$lte	Matches values that are less than or equal to a specified value.	{ "key": { "$lte": 4 } }
$in	Matches any of the values specified in an array.	{ "key": { "$in": [ 1, 2, 4 ] } }
$exists	Mathces values that either have (when set to true) or not have (when set to false) certain attributes	{ "key": { "$exists": true } }
$autocomplete	Mathces values that start with the specified string value	{ "key": { "$autocomplete": "value" } }
It's also possible to combine filter expressions with the following operators:

Name	Description	Example
$and	Matches all the values specified in an array.	{ "$and": [ { "key": { "$in": [ 1, 2, 4 ] } }, { "some_other_key": 10 } ] }
$or	Matches at least one of the values specified in an array.	{ "$or": [ { "key": { "$in": [ 1, 2, 4 ] } }, { "key2": 10 } ] }

Permission and Moderation
In some types of calls, there's a requirement to moderate the behaviour of the participants.

Examples include muting a participant, or ending the call for everyone. Those capabilities are usually reserved for the hosts of the call (users with elevated capabilities). They usually have additional moderation controls in their UI, that allow them to achieve these actions.

The Flutter SDK for Stream Video has support for such capabilities, with the usage of the permissions features for the Call class.

Current Permissions
To check if a user has certain permissions, such as transmitting audio, video, or screen sharing, you can use the hasPermission method on the Call class:


final canScreenShare = call.hasPermission(CallPermission.screenshare);
Requesting and Granting Permissions
If a user does not have permission for an action, it can be requested by calling requestPermissions() on the current Call object.

This method accepts a list of CallPermission allowing for multiple permission requests to be batched into a single call:


call.requestPermissions([CallPermission.screenshare, CallPermission.sendVideo]);
As a call admin, you can grant permission to other users by calling call.grantPermissions along with the user’s id and the list of permissions you would like to grant:


call.grantPermissions(userId: 'nash', permissions: [CallPermission.screenshare, CallPermission.sendVideo]);
During a call, it is advised to set up a handler to listen and react to permission requests as they arrive. This can be done by passing a callback function to the onPermissionRequest property present on the Call object:


@override
void initState() {
  super.initState();
  widget.call.onPermissionRequest = (StreamCallPermissionRequestEvent request) {
    // TODO Handle Permission requests
    // For example: widget.call.grantPermissions(userId: request.user.id, permissions: request.permissions);
  };
}
The StreamCallPermissionRequestEvent includes the following attributes which can be used to either grant or reject permission requests:

Call Cid
Created At
Permissions
User
Moderation Capabilities
As with all calls, there may be times when user permissions need to be revoked, or the user needs to be banned, muted, or subjected to other actions to limit their interaction.

To facilitate these requests, the SDK provides several methods for limiting user interaction during the call lifecycle.

Revoke Permissions

Similar to its sister method grantPermissions, the revokePermissions method exists on the current Call object. It enables users to easily remove permissions assigned to a specific user by providing their user ID and the list of permissions to be revoked..


call.revokePermissions(userId: 'nash', permissions: [CallPermission.screenshare, CallPermission.sendVideo]);
Mute Users

To disable the audio tracks of all users on a call or a specific user in a call, the muteOthers and muteUser functions can be called, respectively.


call.muteAllUsers();

call.muteUsers(userIds: ['thierry']);
In the above example, we are only muting a single user. However, muteUsers does allow us to mute multiple users since it accepts a list of user IDs.

Blocking and Unblocking

In some cases, a moderator or host may want to block a participant from joining the call. Blocking and unblocking users can be done by calling blockUser or unblockUser on the current Call object.


call.blockUser('deven');
call.unblockUser('deven');
Kicking

Kicking a participant is a softer version of blocking. The participant will be disconnected from the call, but they will be able to re-join the call.


call.kickUser('deven');
As a shortcut you can also set block to true to also block the user from rejoining.


call.kickUser('deven', block: true);
Ending the Call for everyone

As a host, you are able to end the current call for everyone using the call.end method.


await call.end();
This operation will emit call.ended event to every participant in the call. Ended calls can't be re-joined.

Call Statistics
There are two sources of statistics you can use to monitor the performance of your calls:

Call.stats stream that provides real-time webRTC statistics
CallState properties that contain some of the webRTC statistics processed and more useful for display purposes
Stats stream
If you want to tap in directly into the stream of webRTC stats you can do this with stats stream inside Call object. It provides a stream of CallStats objects for publisher and subscriber connections. We provide those statistics in three ways for ease of use:

raw - Raw stats as they come from WebRTC.
printable - Representation of the stats that can be easily printed to the console or as a block of text.
stats - WebRTC stats but in a structured form.
CallState properties
You can also access more processed data with useful information about the call. This data is available in CallState object. Here are some of the properties that you can use:

publisherStats and subscriberStats - objects that contain the following data:

latency - The time it takes to deliver the data between the server and the app.
jitterInMs - The variation in the delay of receiving packets of data over a network.
bitrateKbps - The rate at which data is transmitted from the app to the server (publisher) or from the server to the app (subscriber).
localStats - An object that contains the following data:

sfu - The server to which the device is connected.
sdkVersion - The version of the Stream SDK.
webRtcVersion - The version of WebRTC.
latencyHistory - Array of latency values for the last 10 seconds.

Example usage
You can check the example of the stats screen in our demo app

Sample Call Stats screen


Call Events
There are multiple events that you can listen to during a call. You can use them to update the UI, show notifications, or log the call events. You can listen to them via callEvents stream in the Call object.

Here are some of the events you can listen to:

Call Event	Description
General Call Events	
StreamCallCreatedEvent	Triggered when a call is created.
StreamCallJoinedEvent	Triggered when a user joins a call.
StreamCallEndedEvent	Triggered when the call ends.
StreamCallUpdatedEvent	Triggered when the call metadata are updated.
StreamCallMissedEvent	Triggered when a call is missed.
StreamCallLiveStartedEvent	Triggered when a call goes live.
Participant Events	
StreamCallParticipantJoinedEvent	Triggered when a participant joins the call.
StreamCallParticipantLeftEvent	Triggered when a participant leaves the call.
StreamCallDominantSpeakerChangedEvent	Triggered when the dominant speaker changes.
Quality and Control Events	
StreamCallConnectionQualityChangedEvent	Triggered when connection quality changes for participants.
StreamCallAudioLevelChangedEvent	Triggered when audio levels change for participants.
StreamCallPermissionRequestEvent	Triggered when there is a permission request for a call.
StreamCallPermissionsUpdatedEvent	Triggered when permissions for a call are updated.
Call Ringing Events	
StreamCallRingingEvent	Triggered when the call is ringing.
StreamCallAcceptedEvent	Triggered when the call is accepted.
StreamCallRejectedEvent	Triggered when the call is rejected.
Recording Events	
StreamCallRecordingStartedEvent	Triggered when recording starts for a call.
StreamCallRecordingStoppedEvent	Triggered when recording stops for a call.
StreamCallRecordingFailedEvent	Triggered when recording fails for a call.
StreamCallRecordingReadyEvent	Triggered when a recording is ready for download.
Broadcasting Events	
StreamCallBroadcastingStartedEvent	Triggered when broadcasting starts for a call.
StreamCallBroadcastingStoppedEvent	Triggered when broadcasting stops for a call.
StreamCallBroadcastingFailedEvent	Triggered when broadcasting fails for a call.
Transcription Events	
StreamCallTranscriptionStartedEvent	Triggered when transcription starts for a call.
StreamCallTranscriptionStoppedEvent	Triggered when transcription stops for a call.
StreamCallTranscriptionFailedEvent	Triggered when transcription fails for a call.
Closed Caption Events	
StreamCallClosedCaptionsStartedEvent	Triggered when closed captions start for a call.
StreamCallClosedCaptionsStoppedEvent	Triggered when closed captions stop for a call.
StreamCallClosedCaptionsFailedEvent	Triggered when closed captions fail for a call.
StreamCallClosedCaptionsEvent	Triggered when a closed caption is received.
Session Events	
StreamCallSessionStartedEvent	Triggered when a new session starts for a call.
StreamCallSessionEndedEvent	Triggered when a session ends for a call.
StreamCallSessionParticipantJoinedEvent	Triggered when a participant joins the call session.
StreamCallSessionParticipantLeftEvent	Triggered when a participant leaves the call session.
StreamCallSessionParticipantCountUpdatedEvent	Triggered when session participant count is updated.
Member Events	
StreamCallMemberAddedEvent	Triggered when members are added to a call.
StreamCallMemberRemovedEvent	Triggered when members are removed from a call.
StreamCallMemberUpdatedEvent	Triggered when members are updated in a call.
StreamCallMemberUpdatedPermissionEvent	Triggered when member permissions are updated.
Other Events	
StreamCallUserBlockedEvent	Triggered when a user is blocked in a call.
StreamCallUserUnblockedEvent	Triggered when a user is unblocked in a call.
StreamCallReactionEvent	Triggered when someone sends a reaction during a call.
StreamCallUserMutedEvent	Triggered when users are muted in a call.
StreamCallCustomEvent	Triggered for custom events.
Custom event
Stream Video also supports custom events. This is a real-time layer that you can broadcast your own events to.

Sending custom events
You can use the sendCustomEvent method of the Call instance to send custom events:


call.sendCustomEvent(
    eventType: 'my-custom-event',
    custom: {
      'key': 'value',
    },
);
Receiving custom events
​You can listen to custom events by listening to the StreamCallCustomEvent event via the same callEvents stream:


call.callEvents.on<StreamCallCustomEvent>((event) { });

Reactions
Reactions in video calling let participants express emotions and non‑verbal cues without interrupting the conversation. They also make meetings feel more interactive and responsive.

Send a reaction

await call.sendReaction(reactionType: 'fireworks');
Send a reaction with custom data
You can attach custom data and optionally override the emoji used for the reaction:


await call.sendReaction(
        reactionType: 'raise-hand',
        emojiCode: ':smile:',
        custom: {'mycustomfield': 'mycustomvalue'},
    );
Default behavior
When a reaction event is received, the SDK updates the CallParticipantState. The default UI components render the reaction as an overlay on the participant’s video. After a configurable duration, the reaction is reset and disappears from the UI.

You can configure the auto‑dismiss timeout via reactionAutoDismissTime in CallPreferences:


final preferences = DefaultCallPreferences(
  reactionAutoDismissTime: const Duration(seconds: 30),
);
final streamVideo = StreamVideo(
  'api_key',
  user: user,
  userToken: token,
  options: StreamVideoOptions(
    defaultCallPreferences: preferences,
  ),
);
See more about Call preferences here. Refer to the cookbook for information on built-in reaction components and customization.

Listen for reaction events
If you want to handle reactions yourself, listen for the event and apply custom logic:


call.callEvents.on<StreamCallReactionEvent>((event) {
    debugPrint(
    'Reaction received: ${event.emojiCode} from ${event.user.id}',
    );


Participant Sorting
The Participant Sorting API is a powerful tool built on top of the internal Comparator<T> API, providing developers with the ability to sort participants in various scenarios. This API offers common comparators and built-in presets that can be easily customized or used out-of-the-box, making participant sorting a seamless experience.

When dealing with real-time communication applications, it is often necessary to sort participants based on specific criteria. Whether you need to adjust the sorting in existing view layouts or define new sorting presets, the Participant Sorting API is here to simplify the process.

By utilizing the Comparator<T> API and the provided built-in comparators and presets, developers can effortlessly sort participants according to their requirements.

Comparator<T> API overview
​

The Comparator<T> API serves as the foundation for the Participant Sorting API. It defines the function type Comparator<T>, which takes two arguments a and b of type T and returns -1, 0, or 1, depending on the comparison between the two values. This allows developers to create custom comparators tailored to their specific requirements.

This API can be seamlessly used with Dart's List.sort method to sort any type of data.


class Participant {
  Participant(this.id, this.name, this.age);
  final int id;
  final String name;
  final int age;
}
// Comparator that sorts by name in ascending order
int byName(Participant a, Participant b) {
  return a.name.compareTo(b.name);
}
// Comparator that sorts by id in ascending order
int byId(Participant a, Participant b) {
  return a.id.compareTo(b.id);
}
// Comparator that sorts by age in ascending order
int byAge(Participant a, Participant b) {
  return a.age.compareTo(b.age);
}
// Creates a new comparator that sorts by name in descending order
Comparator<Participant> byNameDescending = (a, b) => byName(b, a);
// Conditional comparator for sorting by age if enabled
Comparator<Participant> byAgeIfEnabled(bool isSortByAgeEnabled) {
  return (a, b) => isSortByAgeEnabled ? byAge(b, a) : 0;
}
// Combines multiple comparators into one
Comparator<Participant> combineComparators(List<Comparator<Participant>> comparators) {
  return (a, b) {
    for (final comparator in comparators) {
      final result = comparator(a, b);
      if (result != 0) return result;
    }
    return 0;
  };
}
// Sorting criteria combining multiple comparators
Comparator<Participant> sortingCriteria = combineComparators([
  byNameDescending,
  byAgeIfEnabled(true), // You can toggle this flag for conditional sorting
  byId,
]);
void main() {
  // Example participants
  final p1 = Participant(2, 'Alice', 25);
  final p2 = Participant(1, 'Bob', 30);
  final p3 = Participant(3, 'Charlie', 22);
  // Participants array
  final participants = [p1, p2, p3];
  // Sorting the array based on the defined criteria
  participants.sort(sortingCriteria);
  // Output sorted participants
  for (final p in participants) {
    print('${p.name} (${p.id}) - Age: ${p.age}');
  }
}
Built-in common comparators
​The Participant Sorting API provides a set of common comparators that cover common sorting scenarios. These comparators are specifically designed for participant sorting and offer convenience when defining sorting criteria.

The built-in common comparators include:

dominantSpeaker: Sorts participants based on their dominance in the call.
speaking: Sorts participants based on whether they are currently speaking.
screenSharing: Sorts participants based on whether they are currently screen sharing.
publishingVideo: Sorts participants based on whether they are currently publishing video.
publishingAudio: Sorts participants based on whether they are currently publishing audio.
pinned: Sorts participants based on whether they are pinned in the user interface.
reactionType(type): Sorts participants based on the type of reaction they have.
byRole(...roles): Sorts participants based on their assigned role.
byName: Sorts participants based on their names.
byParticipantSource: Sorts participants based on their participant source.
All of these comparators are available in the stream_video package and can be imported as follows:


import 'package:stream_video/stream_video.dart';
These built-in comparators serve as a starting point for sorting participants and can be used individually or combined to create more complex sorting criteria.

Built-in sorting presets
​To further simplify participant sorting, the Participant Sorting API offers built-in presets. These presets are pre-configured sorting criteria linked to specific call types, reducing the effort required to define sorting rules.

The following presets are available:

regular: The default sorting preset applicable to general call scenarios.
speaker: A preset specifically designed for the 'default' call type, optimizing participant sorting for speaker layout view.
livestreamOrAudioRoom: A preset tailored for the 'livestream' and 'audio_room' call types, ensuring optimal participant sorting in livestream or audio room scenarios.
All of these presets are available in the stream_video package and can be imported as follows:


import 'package:stream_video/stream_video.dart';
Sorting customization
By default participant sorting is set depending on the participants layout mode set in the StreamCallContent widget:


Comparator<CallParticipantState> get sorting {
  switch (this) {
    case ParticipantLayoutMode.grid:
      return CallParticipantSortingPresets.regular;
    case ParticipantLayoutMode.spotlight:
      return CallParticipantSortingPresets.speaker;
    case ParticipantLayoutMode.pictureInPicture:
      return CallParticipantSortingPresets.speaker;
  }
}
If you want to customize it, providing different preset or even your own custom sorting comparator, you can do it by providing sort parameter to StreamCallParticipants widget and using it in the StreamCallContent's callParticipantsWidgetBuilder:


StreamCallContainer(
  ...,
  callContentWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallContent(
      call: call,
      callState: callState,
      callParticipantsWidgetBuilder: (context, call) {
        return StreamCallParticipants(
              call: call,
              sort: screenSharing,
          );
      },
    );
  },
);



User Ratings
Introduction
Asking your users to rate their experience at the end of a call is a best practice that allows you to capture important feedback and helps you improve your product. It is highly recommended to use the feedback API to collect this information.

The ratings are also rendered inside the dashboard stats screen, allowing you to see the average rating of your calls and the feedback provided by your users.

User ratings are also used by Stream to improve the quality of our services. We use this feedback to identify issues and improve the overall quality of our video calls.

In this guide, we are going to show how one can build a user rating form on top of our Flutter Video SDK.

Here is a preview of the component we are going to build:

Feedback Dialog
Submit Feedback API
Our Flutter Video SDK provides an API for collecting this feedback which later can be seen in the call stats section of our dashboard.


await call.collectUserFeedback(
    rating: // a rating from 1 to 5,
    reason: // optional reason message,
    custom: {
      'role': 'patient', // ... any extra properties that you wish to collect
    },
);
Example
One way to ask for feedback is to show a dialog with a rating scale and an optional text field for the user to provide additional comments when they disconnect from the call:


StreamCallContainer(
    call: widget.call,
    onCallDisconnected: (reason) {
      // Pop the call screen
      Navigator.of(context).pop();
      if (reason is DisconnectReasonCancelled ||
          reason is DisconnectReasonEnded ||
          reason is DisconnectReasonLastParticipantLeft) {
        // Show the feedback dialog
        await showDialog<void>(
            context: context,
            builder: (BuildContext context) {
                return FeedbackWidget(call);
            },
        );
      }
    },
    ...
);
Lets implement a simple widget that will show the feedback form:


class FeedbackWidget extends StatefulWidget {
  FeedbackWidget(
    this.call, {
    super.key,
  });
  Call call;
  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}
class _FeedbackWidgetState extends State<FeedbackWidget> {
  int value = 0;
  TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      streamVideoIconAsset,
                      width: 250,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We Value Your Feedback!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tell us about your video call experience',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[1, 2, 3, 4, 5].map((rating) {
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              size: 40,
                              color: rating <= value
                                  ? AppColorPalette.appGreen
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                value = rating;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: 'Tell us more about your experience',
                        hintStyle:
                            TextStyle(color: AppColorPalette.secondaryText),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                        onPressed: value > 0
                            ? () async {
                                final result =
                                    await widget.call.collectUserFeedback(
                                  rating: value,
                                  reason: textController.text,
                                );
                                result.fold(success: (_) {
                                  context.pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Thank you for your feedback!'),
                                    ),
                                  );
                                }, failure: (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to submit feedback: $error'),
                                    ),
                                  );
                                });
                              }
                            : null,
                        child: const Text('Submit Feedback'))
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
This widget will show a dialog with a rating scale and a text field for the user to provide additional comments. When the user submits the feedback, we call the collectUserFeedback method on the call object and show a success or error message accordingly.

That's it. You have successfully implemented a user rating dialog using our Flutter Video SDK. You can now ask your users to rate their call experience and collect valuable feedback that can help you improve your video calling experience.


Closed Captions
The Stream API supports adding real-time closed captions (subtitles for participants) to your calls. This guide shows you how to implement this feature on the client side.

Prerequisites
Make sure that the closed caption feature is enabled in your app's dashboard. The closed caption feature can be set on the call type level, and the available options are:

available: the feature is available for your call and can be enabled.
disabled: the feature is not available for your call. In this case, it's a good idea to "hide" any UI element you have related to closed captions.
auto-on: the feature is available and will be enabled automatically once the user is connected to the call.
It's also possible to override the call type's default when creating a call:


await call.getOrCreate(
  transcription: const StreamTranscriptionSettings(
    transcriptionMode: TranscriptionSettingsMode.available,
    closedCaptionMode: ClosedCaptionSettingsMode.available,
  ),
);
You can check the current value like this:


print(call.state.value.settings.transcription.closedCaptionMode);
Enabling, disabling and tweaking closed captions
If you set closedCaptionMode to available you need to enable closed caption events when you want to see captions:


await call.startClosedCaptions(); // enable closed captions
await call.stopClosedCaptions(); // disable closed captions
You can adjust the settings that control when closed captions appear by changing the Call Preferences.


streamVideo.makeCall(
  callType: StreamCallType.defaultType(),
  id: 'my-call-id',
  preferences: DefaultCallPreferences(
    closedCaptionsVisibleCaptions: 2, // number of captions that can be stored in the queue
    closedCaptionsVisibilityDurationMs: 2700, // the duration a caption can stay in the queue
  ),
);
Check if closed captions are enabled

final isCaptioningInProgress = call.state.value.isCaptioning;
Displaying the captions
You can access the most recent captions by accessing the closed captions stream in Call:


final subscription = call.closedCaptions.listen((captions) {
  updateDisplayedCaptions(captions);
});
void updateDisplayedCaptions(List<StreamClosedCaption> captions) {
  final captionsText = captions
      .map((caption) => '${caption.user.name}: ${caption.text}')
      .join('\n');
}
subscription.cancel();
This is how an example closed caption looks like:


{
  "text": "Thank you, guys, for listening.",
  "// When did the speaker start speaking": "",
  "start_time": "2024-09-25T12:22:21.310735726Z",
  "// When did the speaker finish saying the caption": "",
  "end_time": "2024-09-25T12:22:24.310735726Z",
  "speaker_id": "zitaszuperagetstreamio",
  "user": {
    "id": "zitaszuperagetstreamio",
    "name": "Zita",
    "role": "host",
    "// other user properties": ""
  }
}





Localization
The stream_video_flutter package with UI elements also includes some localizable strings. By default, these strings are in English. To use other available languages you need to add the corresponding localization delegates to your app. If you use MaterialApp that would look like this:


import 'package:stream_video_flutter/stream_video_flutter_l10n.dart';
//...
return MaterialApp.router(
  supportedLocales: const [Locale('en'), Locale('nl')],
  localizationsDelegates: StreamVideoFlutterLocalizations.localizationsDelegates,
);
In this example our app only supports English and Dutch and we add the localizationsDelegates from StreamVideo which are imported from stream_video_flutter_l10n.

The localizationsDelegates list includes StreamVideoFlutterLocalizations, as well as GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, and GlobalWidgetsLocalizations.delegate. If your app also has its own localizations, you only have to include StreamVideoFlutterLocalizations.delegate and your MaterialApp will look like this:


return MaterialApp.router(
      supportedLocales: const [Locale('en'), Locale('nl')],
      localizationsDelegates: [
        StreamVideoFlutterLocalizations.delegate,
        ...MyAppLocalizations.localizationsDelegates,
      ],
    );
Customizing localizations
You can customize existing localizations by extending them. This way, you only change what you want while still benefiting from new sentences added to the Stream Video SDK.

You can do so by extending one of the existing localization files, such as StreamVideoFlutterLocalizationsNl. You can directly override one of the localizable strings.


class CustomVideoLocalizationsNL extends StreamVideoFlutterLocalizationsNl {
  @override
  String get desktopScreenShareEntireScreen => 'Scherm';
}
Localizations also require a delegate. We made this easy with a CustomVideoLocalizationsDelegate, which always supports only 1 language. You can add this as a static property in your custom localizations class:


class CustomVideoLocalizationsNL extends StreamVideoFlutterLocalizationsNl {
  static LocalizationsDelegate<StreamVideoFlutterLocalizations> get delegate =>
      CustomVideoLocalizationsDelegate('nl', CustomVideoLocalizationsNL());
//...
}
You can use this in your MaterialApp like this:


return MaterialApp.router(
      localizationsDelegates: [
        CustomVideoLocalizationsNL.delegate,
        ...StreamVideoFlutterLocalizations.localizationsDelegates,
      ],
    );
Flutter checks a list of localizationDelegates from top to bottom. If you use a text from StreamVideoFlutterLocalizations in Dutch (nl), Flutter will go through each delegate to see if it matches the required type and supports the given language. The first delegate that matches both the type and the language will be returned. Therefore, you should always put your custom delegate before the StreamVideoFlutterLocalizations delegate.

Adding localizations
Adding a new language works similarly to customizing an existing one. You can choose to extend StreamVideoFlutterLocalizations directly, which requires you to define texts for all available keys. However, we recommend extending an existing language, so you are not forced to add localizations for features you might not use.

For example if you would add the language nn with fallbacks on English, you could do this:


class NewVideoLocalization extends StreamVideoFlutterLocalizationsEn {
  NewVideoLocalization() : super('nn');
  static LocalizationsDelegate<StreamVideoFlutterLocalizations> get delegate =>
      CustomVideoLocalizationsDelegate('nn', NewVideoLocalization());
}
Notice that in the CustomVideoLocalizationsNL where we extend an existing language we did not add a constructor, because the language was already set. In the case of NewVideoLocalization we want to override the language code in the super or parent constructor.

You can add the delegate to your MaterialApp in the same way as mentioned earlier.

Contributing localizations
Instead of adding a new language to your app you can also contribute by submitting a pull request to our repository and adding your language of preference. We will do our best to maintain it effectively. Our localizations are generated based on arb files using standard Flutter localizations.

Using melos run gen-l10n you can update localizations and directly format the resulting code.




Low Bandwidth
Our servers can detect if you are on a low-bandwidth connection and will automatically adjust the video quality to ensure smooth playback.

However, sometimes even reduced quality may not be enough for a good experience, and our system may decide to opt the local user out from consuming some or all remote videos. The video pause feature improves call quality by automatically turning off incoming video streams, resulting in an audio-only mode in response to deteriorating network conditions on the subscriber side.

In such cases, you will see an icon in the participant's label indicating that the video is being paused due to bandwidth constraints.

Low bandwidth indicator
Low Bandwidth Optimization toggling
The Low Bandwidth optimization is enabled by default on an SDK level. However, integrators can decide to opt out of this feature accordingly to their use case:


call.disableClientCapabilities(
    [
        SfuClientCapability.subscriberVideoPause,
    ],
);
// use call.enableClientCapabilities(...) to re-enable the feature
Remmber to configure these before calling call.join(). Any changes made after joining the call will not take effect until the next join or reconnect.

This signals to the backend that the client supports dynamic video pausing, allowing the system to optimize media delivery under limited network conditions.

Observing Paused Tracks
The information about server-side paused tracks lives on the participant.pausedTracks property. You can observe changes to this property to customize the UI further, such as showing a message or changing the participant's label.


final subscriptions = call
    .partialState((state) => state.callParticipants)
    .map(
        (participants) => participants
            .where((p) => p.pausedTracks.contains(SfuTrackType.video))
            .toList(),
    )
    .listen(
    (pausedTrackParticipants) {
    print(
        'Participants with paused video track: ${pausedTrackParticipants.map((e) => e.userId).join(', ')}',
    );
    },
);
//Remember to cancel the subscription when not needed
subscriptions.cancel();



Built-in Types
The Video SDK provides pre-defined call types with different default permissions and feature configurations. You can extend these or create custom types via the dashboard.

Best Practices
Use the development call type only for testing, never in production
Configure call types in the dashboard before deploying to production
Set up proper user roles to simplify permission management
Use backstage mode for scheduled calls or livestreams that need preparation time
Review default capabilities and customize them based on your security requirements
Key Concepts
Call Type - Pre-defined configurations with associated user roles and capabilities. Four default types are available, or create custom types via the dashboard.
User Role - Defines what actions a user can perform. Users can have multiple roles. Use existing roles or define custom ones via the dashboard.
Call Capabilities - Specific actions a participant can perform (such as send-video or end-call). Associated with user roles and customizable via the dashboard.
Call Types
Four pre-defined call types are available:

default - 1-1 or group video calls with sensible defaults
audio_room - Pre-configured for audio-only experiences with permission request workflows (like Clubhouse or Twitter Spaces)
livestream - All authenticated users can access calls; ideal for one-to-many broadcasting
development - All permissions enabled; use only for testing
Each call type includes specific settings. The backstage concept allows calls to be created but not directly joined until goLive() is called, useful for scheduled calls.

Development
The development call type has all permissions enabled for testing purposes. Do not use in production since all participants can perform any action (blocking, muting, etc).

Backstage is disabled, so calls start immediately without requiring goLive().

Default
The default call type supports 1-1 calls, group calls, and meetings. Video and audio are enabled, backstage is disabled, and admins/hosts have elevated permissions.

The default type can be used in apps that use regular video calling. To learn more try our tutorial on building a video calling app.

Audio Room
The audio_room call type suits apps like Clubhouse or Twitter Spaces. It includes a pre-configured workflow for requesting speaking permissions. Backstage is enabled by default; call goLive() to make the call active for all participants.

See the Audio Room tutorial for implementation details.

Livestream
The livestream call type is configured for live streaming apps. All authenticated users can access calls, and backstage is enabled by default.

See the live streaming tutorial for implementation details.

Call type settings
Each call type has configurable settings. See the defaults table for a comparison of settings across call types.

Audio
Setting Name	Type	Description
access_request_enabled	Boolean	When true users that do not have permission to this feature can request access for it
opus_dtx_enabled	Boolean	When true OPUS DTX is enabled
redundant_coding_enabled	Boolean	When true redundant audio transmission is enabled
mic_default_on	Boolean	When true the user will join with the microphone enabled by default
speaker_default_on	Boolean	When true the user will join with the audio turned on by default
default_device	String speaker or earpiece	The default audio device to use
Backstage
Setting Name	Type	Description
enabled	Boolean	When backstage is enabled, calls will be in backstage mode when created and can be joined by users only after goLive is called
Video
Setting Name	Type	Description
enabled	Boolean	Defines whether video is enabled for the call
access_request_enabled	Boolean	When true users that do not have permission to this feature can request access for it
camera_default_on	Boolean	When true, the camera will be turned on when joining the call
camera_facing	String front, back or external	When applicable, the camera that should be used by default
target_resolution	Target Resolution Object	The ideal resolution that video publishers should send
The target resolution is an advanced setting. Modifying defaults can degrade performance. Structure:

Setting Name	Type	Description
width	Number	The width in pixels
height	Number	The height in pixels
bitrate	Number	The bitrate
Screensharing
Setting Name	Type	Description
enabled	Boolean	Defines whether screensharing is enabled
access_request_enabled	Boolean	When true users that do not have permission to this feature can request access for it
Recording
Setting Name	Type	Description
mode	String available, disabled or auto-on	available → recording can be requested
disabled → recording is disabled
auto-on → recording starts and stops automatically when one or multiple users join the call
quality	String audio-only, 360p, 480p, 720p, 1080p, 1440p	Defines the resolution of the recording
audio_only	boolean	If true the recordings will only contain audio
layout	object, for more information see the API docs	Configuration options for the recording application
Broadcasting
Setting Name	Type	Description
enabled	Boolean	Defines whether broadcasting is enabled
hls	HLS Settings (object)	Settings for HLS broadcasting
HLS Settings
Setting Name	Type	Description
enabled	Boolean	Defines whether HLS is enabled or not
auto_on	Boolean	When true HLS streaming will start as soon as users join the call
quality_tracks	String audio-only, 360p, 480p, 720p, 1080p, 1440p	The tracks to publish for the HLS stream (up to three tracks)
Geofencing
Setting Name	Type	Description
names	List of one or more of these strings european_union, iran_north_korea_syria_exclusion, china_exclusion, russia_exclusion, belarus_exclusion, india, united_states, canada	The list of geofences that are used for the calls of these type
See the API docs for details.

Transcription
Setting Name	Type	Description
mode	String available, disabled or auto-on	Not implemented yet
closed_caption_mode	String	Not implemented yet
Ringing
Setting Name	Type	Description
incoming_call_timeout_ms	Number	Defines how long the SDK should display the incoming call screen before discarding the call (in ms)
auto_cancel_timeout_ms	Number	Defines how long the caller should wait for others to accept the call before canceling (in ms)
Push Notifications Settings
Setting Name	Type	Description
enabled	Boolean	
call_live_started	Event Notification Settings Object	The notification settings used for call_live_started events
session_started	Event Notification Settings Object	The notification settings used for session_started events
call_notification	Event Notification Settings Object	The notification settings used for call_notification events
call_ring	Event Notification Settings Object	The notification settings used for call_ring events
Event notification settings object structure:

Setting Name	Type	Description
enabled	Boolean	Whether this object is enabled
apns	APNS Settings Object	The settings for APN notifications
APNS Settings Object
Customize remote notifications by implementing a Notification Service Extension. For simple customizations, modify the title and body fields at the call type level. Both fields are handlebars templates with call and user objects in scope.

Setting Name	Type	Description
title	Template	The string template for the title field of the notification
body	Template	The string template for the body field of the notification
Defaults for call type settings
audio-room	default	livestream	development
Audio				
access_request_enabled	✅	✅	❌	✅
opus_dtx_enabled	✅	✅	✅	✅
redundant_coding_enabled	✅	✅	✅	✅
mic_default_on	❌	✅	❌	✅
speaker_default_on	✅	✅	✅	✅
default_device	speaker	earpiece	speaker	earpiece
Backstage				
enabled	✅	❌	✅	❌
Video				
enabled	❌	✅	✅	✅
access_request_enabled	❌	✅	❌	✅
target_resolution	N/A	Width: 2560
Height 1440
Bitrate 5000000	Width: 1920
Height: 1080
Bitrate 3000000	Width: 1920
Height 1080
Bitrate 3000000
camera_default_on	❌	✅	✅	✅
camera_facing	front	front	front	front
Screensharing				
enabled	❌	✅	✅	✅
access_request_enabled	❌	✅	❌	✅
Recording				
mode	available	available	available	available
quality	720p	720p	720p	720p
Broadcasting				
enabled	✅	✅	✅	✅
hls.auto_on	❌	❌	❌	❌
hls.enabled	available	available	available	available
hls.quality_tracks	[720p]	[720p]	[720p]	[720p]
Geofencing				
names	[]	[]	[]	[]
Transcriptions				
mode	available	available	available	available
Ringing				
incoming_call_timeout_ms	0	15000	0	15000
auto_cancel_timeout_ms	0	15000	0	15000
User roles
Five pre-defined user roles are available:

user - Standard participant
moderator - Can moderate calls
host - Call host with elevated permissions
admin - Full administrative access
call-member - Basic call membership
Each role has associated capabilities. Access default roles and capabilities in the Stream Dashboard. A well-defined role setup simplifies permission management.

Call Capabilities
A capability defines actions a user can perform on a call. Each user has capabilities attached based on their role. Modify default capabilities in the dashboard or change them dynamically at runtime.

Users with permission to assign capabilities can grant them to other users, enabling flexible permission management.

If you want to learn more about doing this, head over to the Permissions and Capabilities chapter.

Default call capabilities
When fetching a call from the API, the response includes the user's allowed actions:

join-call
read-call
create-call
join-ended-call
join-backstage
update-call
update-call-settings
screenshare
send-video
send-audio
start-record-call
stop-record-call
start-broadcast-call
stop-broadcast-call
end-call
mute-users
update-call-permissions
block-users
create-reaction
pin-for-everyone
remove-call-member
start-transcription-call
stop-transcription-call




Manage Types
Read call types

JavaScript

Python

Golang

cURL

client.video.listCallTypes();
//or
client.video.getCallType({ name: "livestream" });
Create call type

JavaScript

Python

Golang

cURL

client.video.createCallType({
  name: "allhands",
  settings: {
    audio: {
      mic_default_on: true,
      default_device: "speaker",
    },
  },
  grants: {
    admin: [
      VideoOwnCapability.SEND_AUDIO,
      VideoOwnCapability.SEND_VIDEO,
      VideoOwnCapability.MUTE_USERS,
    ],
    user: [VideoOwnCapability.SEND_AUDIO, VideoOwnCapability.SEND_VIDEO],
  },
});
Update call type

JavaScript

Python

Golang

cURL

client.video.updateCallType({
  name: "allhands",
  settings: {
    audio: {
      mic_default_on: false,
      default_device: "earpiece",
    },
  },
});
Delete call type

JavaScript

Python

Golang

cURL

client.video.deleteCallType({ name: "allhands" });




Geofencing
With geofencing, you can define which edge nodes are utilized for video calls within specific geo-fenced areas. You can set geofences to a call type or specify when creating a new call. Multiple geo-fences can be used at the same time.

At this present, you can only select from a predefined list of geofences:

Inclusion Geofences
Name	Description	Countries Included
european_union	The list of countries that are part of european union	Austria, Belgium, Croatia, Cyprus, Czech Republic, Denmark, Estonia, Finland, France, Germany, Greece, Hungary, Ireland, Italy, Latvia, Lithuania, Luxembourg, Malta, Netherlands, Poland, Portugal, Romania, Slovakia, Slovenia, Spain, Sweden
united_states	Only selects edges in US	United States
canada	Only selects edges in Canada	Canada
united_kingdom	Only selects edges in the United Kingdom	United Kingdom
india	Only selects edges in India	India
Exclusion Geofences
Name	Description	Countries Excluded
china_exclusion	Excludes edges running in mainland China (currently, Stream edge infrastructure does not have any edge in China)	China
russia_exclusion	Excludes edges running in Russia	Russia
belarus_exclusion	Excludes edges running in Belarus	Belarus
iran_north_korea_syria_exclusion	Excludes edges running in Iran, North Korea and Syria	Iran, North Korea, Syria

JavaScript

Python

Golang

cURL

client.video.createCallType({
  name: "<call type name>",
  settings: {
    geofencing: {
      names: ["european_union"],
    },
  },
});
//override settings on call level
call.create({
  data: {
    created_by_id: "john",
    settings_override: {
      geofencing: {
        names: ["european_union", "united_states"],
      },
    },
  },
});
Region Restrictions
With geofencing you can restrict the edges that are used in your calls based on their location. If you want to restrict access to calls for users in some regions, please reach out to our support team. This is currently possible but not configurable via API or Dashboard.

UAE VoIP Service Notice
The Telecommunications and Digital Government Regulatory Authority (TDRA) regulates the provision of real-time voice and video communication services within the United Arab Emirates (UAE).

To align with these regulatory requirements, Stream currently does not enable video functionality by default for users connecting from within the UAE.

Organizations that are authorized or licensed to provide VoIP services in the UAE may contact our team at support@getstream.io to request an evaluation for enabling access.

Each request will be assessed on a case-by-case basis to ensure compliance with all applicable TDRA requirements and local laws.



Permissions
Introduction
This page shows how you can create or update roles for a call type.

Stream has a role-based permission system. Each user has an application-level role, and also channel (chat product) and call (video product) level roles. Every role (be it application or call/channel level) contains a list of permissions. A permissions is an action (for example, create a call). The list of permissions assigned to a role defines what a user is allowed to do. Call roles are defined on the call type level.

Configuring roles
When you create a call type, you can specify your role configurations. A role configuration consists of a role name and the list of permissions that are enabled for that role.

When you create a call type, it comes with a default set of configurations. You can override or extend that.

The following example overrides the permissions of the built-in admin role and defines the customrole.

Please note that for the below code to work, you need to create the customrole beforehand. You can do that in your Stream Dashboard.


JavaScript

Python

Golang

Java

cURL

client.video.createCallType({
  name: "<call type name>",
  grants: {
    admin: ["send-audio", "send-video", "mute-users"],
    ["customrole"]: ["send-audio", "send-video"],
  },
});
// or edit a built-in call type
client.video.updateCallType({
  name: "default",
  grants: {
    /* ... */
  },
});
See how you can list permissions below.

Built-in roles
There are 5 pre-defined call roles, these are:

user
moderator
host
admin
call-member
You can access the default roles and their permissions in your Stream Dashboard.

You can also list roles and their permissions using the Stream API:


JavaScript

Python

Golang

cURL

client.video.listCallTypes();
//or
client.video.getCallType({ name: "livestream" });
Permissions
The list of call permissions that you can include in your role configurations:


JavaScript

Python

Golang

Java

cURL

const response = await client.listPermissions();
console.log(response.permissions);
Capabilities
When users access calls they'll receive an own_capabilities field in the call object, which contains all call related capabilities a user is allowed to do. This can be used by client-side SDKs to do permission checks for hiding/showing UI elements (for code examples checkout SDK documentations). Capabilities are not the same as permissions. Permissions are the list of actions the Stream API supports. Capabilities are the list of actions a given user is allowed to do in the scope of a given call taking into account:

application-level and call-level role of the user
call type settings
call-level settings




Settings
The Stream API provides multiple configuration options on the call type level.

You can provide the settings when creating or updating a call type
For maximum flexibility, you can override the settings on the call level when creating or updating a call
Code examples
Settings

JavaScript

Python

Golang

cURL

client.video.createCallType({
  name: "<call type name>",
  settings: {
    screensharing: {
      access_request_enabled: false,
      enabled: true,
    },
  },
});
// override settings on call level
call.create({
  data: {
    created_by_id: "john",
    settings_override: {
      screensharing: {
        enabled: false,
      },
    },
  },
});
Notification settings
Notification settings can't be overridden on the call level, you can only set these on the call type level.


JavaScript

Python

Golang

cURL

client.video.createCallType({
  name: "<call type name>",
  notification_settings: {
    enabled: true,
    call_notification: {
      apns: {
        title: "{{ user.display_name }} calls you",
        body: "{{ user.display_name }} calls you",
      },
      enabled: true,
    },
    call_ring: {
      apns: {
        title: "{{ user.display_name }} calls you",
        body: "{{ user.display_name }} calls you",
      },
      enabled: true,
    },
    call_live_started: {
      enabled: true,
      apns: {
        title: "{{ call.display_name }} started",
        body: "{{ user.display_name }} started",
      },
    },
    call_missed: {
      enabled: true,
      apns: {
        title: "missed call from {{ user.display_name }}",
        body: "missed call from {{ user.display_name }}",
      },
    },
    session_started: {
      enabled: true,
      apns: {
        title: "{{ call.display_name }} started",
        body: "{{ call.display_name }} started",
      },
    },
  },
});
Configuration options
Settings
CallSettingsRequest
Name	Type	Description	Constraints
audio	AudioSettingsRequest	-	-
backstage	BackstageSettingsRequest	-	-
broadcasting	BroadcastSettingsRequest	-	-
frame_recording	FrameRecordingSettingsRequest	-	-
geofencing	GeofenceSettingsRequest	-	-
individual_recording	IndividualRecordingSettingsRequest	-	-
ingress	IngressSettingsRequest	-	-
limits	LimitsSettingsRequest	-	-
raw_recording	RawRecordingSettingsRequest	-	-
recording	RecordSettingsRequest	-	-
ring	RingSettingsRequest	-	-
screensharing	ScreensharingSettingsRequest	-	-
session	SessionSettingsRequest	-	-
thumbnails	ThumbnailsSettingsRequest	-	-
transcription	TranscriptionSettingsRequest	-	-
video	VideoSettingsRequest	-	-
AudioSettingsRequest
Name	Type	Description	Constraints
access_request_enabled	boolean	-	-
default_device	string (speaker, earpiece)	-	Required
hifi_audio_enabled	boolean	-	-
mic_default_on	boolean	-	-
noise_cancellation	NoiseCancellationSettings	-	-
opus_dtx_enabled	boolean	-	-
redundant_coding_enabled	boolean	-	-
speaker_default_on	boolean	-	-
BackstageSettingsRequest
Name	Type	Description	Constraints
enabled	boolean	-	-
join_ahead_time_seconds	integer	-	-
BroadcastSettingsRequest
Name	Type	Description	Constraints
enabled	boolean	-	-
hls	HLSSettingsRequest	-	-
rtmp	RTMPSettingsRequest	-	-
FrameRecordingSettingsRequest
Name	Type	Description	Constraints
capture_interval_in_seconds	integer	-	Required, Minimum: 2, Maximum: 60
mode	string (available, disabled, auto-on)	-	Required
quality	string (360p, 480p, 720p, 1080p, 1440p)	-	-
GeofenceSettingsRequest
Name	Type	Description	Constraints
names	string[]	-	-
IndividualRecordingSettingsRequest
Name	Type	Description	Constraints
mode	string (available, disabled, auto-on)	-	Required
IngressSettingsRequest
Name	Type	Description	Constraints
audio_encoding_options	IngressAudioEncodingOptionsRequest	-	-
enabled	boolean	-	-
video_encoding_options	object	-	-
LimitsSettingsRequest
Name	Type	Description	Constraints
max_duration_seconds	integer	-	Minimum: 0
max_participants	integer	-	-
max_participants_exclude_owner	boolean	-	-
max_participants_exclude_roles	string[]	-	-
RawRecordingSettingsRequest
Name	Type	Description	Constraints
mode	string (available, disabled, auto-on)	-	Required
RecordSettingsRequest
Name	Type	Description	Constraints
audio_only	boolean	-	-
layout	LayoutSettingsRequest	-	-
mode	string (available, disabled, auto-on)	-	Required
quality	string (360p, 480p, 720p, 1080p, 1440p, portrait-360x640, portrait-480x854, portrait-720x1280, portrait-1080x1920, portrait-1440x2560)	-	-
RingSettingsRequest
Name	Type	Description	Constraints
auto_cancel_timeout_ms	integer	When none of the callees accept a ring call in this time a rejection will be sent by the caller with reason 'timeout' by the SDKs	Required, Minimum: 5000, Maximum: 180000
incoming_call_timeout_ms	integer	When a callee is online but doesn't answer a ring call in this time a rejection will be sent with reason 'timeout' by the SDKs	Required, Minimum: 5000, Maximum: 180000
missed_call_timeout_ms	integer	When a callee doesn't accept or reject a ring call in this time a missed call event will be sent	Minimum: 5000, Maximum: 180000
ScreensharingSettingsRequest
Name	Type	Description	Constraints
access_request_enabled	boolean	-	-
enabled	boolean	-	-
target_resolution	TargetResolution	-	-
SessionSettingsRequest
Name	Type	Description	Constraints
inactivity_timeout_seconds	integer	-	Required, Minimum: 5, Maximum: 900
ThumbnailsSettingsRequest
Name	Type	Description	Constraints
enabled	boolean	-	-
TranscriptionSettingsRequest
Name	Type	Description	Constraints
closed_caption_mode	string (available, disabled, auto-on)	-	-
language	string (auto, en, fr, es, de, it, nl, pt, pl, ca, cs, da, el, fi, id, ja, ru, sv, ta, th, tr, hu, ro, zh, ar, tl, he, hi, hr, ko, ms, no, uk, bg, et, sl, sk)	-	-
mode	string (available, disabled, auto-on)	-	-
speech_segment_config	SpeechSegmentConfig	-	-
translation	TranslationSettings	-	-
VideoSettingsRequest
Name	Type	Description	Constraints
access_request_enabled	boolean	-	-
camera_default_on	boolean	-	-
camera_facing	string (front, back, external)	-	-
enabled	boolean	-	-
target_resolution	TargetResolution	-	-
NoiseCancellationSettings
Name	Type	Description	Constraints
mode	string (available, disabled, auto-on)	-	Required
HLSSettingsRequest
Name	Type	Description	Constraints
auto_on	boolean	-	-
enabled	boolean	-	-
layout	LayoutSettingsRequest	-	-
quality_tracks	string[]	-	Required, Minimum: 1, Maximum: 3
RTMPSettingsRequest
Name	Type	Description	Constraints
enabled	boolean	-	-
layout	LayoutSettingsRequest	Layout for the composed RTMP stream	-
quality	string (360p, 480p, 720p, 1080p, 1440p, portrait-360x640, portrait-480x854, portrait-720x1280, portrait-1080x1920, portrait-1440x2560)	Resolution to set for the RTMP stream	-
IngressAudioEncodingOptionsRequest
Name	Type	Description	Constraints
bitrate	integer	-	Required, Minimum: 16000, Maximum: 128000
channels	integer (1, 2)	-	Required
enable_dtx	boolean	-	-
LayoutSettingsRequest
Name	Type	Description	Constraints
detect_orientation	boolean	-	-
external_app_url	string	-	-
external_css_url	string	-	-
name	string (spotlight, grid, single-participant, mobile, custom)	-	Required
options	object	-	-
TargetResolution
Name	Type	Description	Constraints
bitrate	integer	-	Required, Maximum: 6000000
height	integer	-	Required, Minimum: 240, Maximum: 3840
width	integer	-	Required, Minimum: 240, Maximum: 3840
SpeechSegmentConfig
Name	Type	Description	Constraints
max_speech_caption_ms	integer	-	-
silence_duration_ms	integer	-	-
TranslationSettings
Name	Type	Description	Constraints
enabled	boolean	-	Required
languages	string[]	-	Required
Notification settings
NotificationSettings
Name	Type	Description	Constraints
call_live_started	EventNotificationSettings	-	Required
call_missed	EventNotificationSettings	-	Required
call_notification	EventNotificationSettings	-	Required
call_ring	EventNotificationSettings	-	Required
enabled	boolean	-	Required
session_started	EventNotificationSettings	-	Required
EventNotificationSettings
Name	Type	Description	Constraints
apns	APNS	-	Required
enabled	boolean	-	Required
fcm	FCM	-	Required
APNS
Name	Type	Description	Constraints
body	string	-	Required
content-available	integer	-	-
data	object	-	-
mutable-content	integer	-	-
sound	string	-	-
title	string	-	Required
FCM
Name	Type	Description	Constraints
data	object	-	-




Quality and Latency Guide
Stream provides a detailed analytics report for all calls. If you encounter any issues with latency, quality of the video, or lag, be sure to reach out to support. Contact support and send them your API key and call ID together with a description of your issue.

Stream Call Stats
This guide will go into more detail about how to optimize quality and latency of your video. To start, let's recap how Stream provides a high-quality video service.

How Stream Ensures Quality Video
Video Edge Network: We run an edge network of servers around the world. By having your users closer to our infrastructure, we reduce lag and, more importantly, reduce packet loss. This improves the quality of video.

Dynascale: Stream will automatically tell SDKs to start uploading different codecs or different resolutions of video depending on how the video is used. If you're showing the video in a small thumbnail screen, it will automatically select the lower quality. And if you switch back to displaying it full screen, it will switch back to high quality.

Codecs: We dynamically switch between AV1, VP9, H.264, and VP8 based on the hardware that's connected to the call.

SDKs & Reconnects: We implement a fast failover and reconnect protocol. So if your connection breaks, the reconnect should happen very quickly.

Video Quality and Resolution
The max target quality is configured at the call type level. You can edit this in the dashboard. Typically you want to target 720p or 1080p. It is possible to target higher resolutions, but often the camera, CPU for encoding, and/or bandwidth are not ready for more than 1080p.

The max target defines the ideal maximum video resolution. There are several reasons why users can receive video at lower resolutions. Let's say you're aiming at 1080p.

Video quality target → 1080p

Publisher: Is the publisher able to publish at 1080p? The camera, the CPU, and the network can all cause the quality to go down on the publisher side of things.

Subscriber target resolution: For the subscriber, the target changes based on what resolution the video is shown at. If the video is displayed in a small area, we will often subscribe to 25% or 50% of the full video quality.

Subscriber degradation: If the network or device CPU are not able to keep up with the current quality of video, the subscriber will ask for a lower quality video. As network or CPU conditions improve, it will try to recover to higher quality.

Codecs: Video codecs play a key role in video quality. AV1 is by far the most advanced video codec widely available and can deliver much higher video quality with the same bitrate as older codecs such as H.264 and VP8. Unfortunately, not all devices support AV1 efficiently. This means that in some cases, less efficient codecs will be used to publish video. The good news is that encoding AV1 is far more expensive than decoding AV1. We automatically allow more powerful devices to publish video using AV1 and have publishers on older devices send video in a codec that's better supported like H.264 or VP9.

Default target resolutions
Default target resolutions by call type:

Livestream: 1080p
Default: 720p
Development: 720p
AV1 Support Explained
AV1 codec is selected automatically on calls with any of these devices:

iPhone 15 and up supports AV1 well
Galaxy S23 and up
Chrome supports AV1, Firefox 136 added support recently. Safari 17 and up supports AV1 decoding and encoding.
Min SDK versions needed for using AV1:

Android 1.3.0
iOS 1.15.0
React 1.10.0
React Native 1.8.0
Flutter 0.7.0
Video Latency and Lag
The video edge network is great at providing low latency. Often the delay is 50-150ms on receiving the video. But many customers have a livestreaming setup which goes through several steps. For instance, you can have OBS publish to RTMP, which goes to our RTMP ingress and then is published to users. Additional steps can cause delay to the video.

Configuring OBS for Low Latency
Output Settings

You can find these settings under the output section, make sure to use the Advanced mode:

Select a hardware-based encoder if possible (Typically NVIDIA NVENC)
Make sure to use an H.264 encoder
Configure your encoder for low latency
Set Rate Control to "CBR" (Constant Bitrate)
Set keyframe interval to 2s
Disable B-frames
Pick an appropriate bitrate based on your internet connection and the resolution you want to use
Advanced Settings

Network

Set Bind to IP if you have multiple network interfaces
Enable Dynamically change bitrate when dropping frames
Set Network Buffer to 0ms (minimizes buffering)
Disable Optimize Network Usage
Video

Lower your output resolution if needed (1080p is often a good balance)
Use 30 or 60 FPS depending on your needs (if unsure, pick 30fps)
Set Common FPS Values instead of using fractional FPS
If possible, use the same resolution for the canvas and the output
Bitrate Selection

As a rule of thumb, you want your internet connection to have at least twice the upload speed that you configure on OBS as the bitrate.

When streaming content with frequent scene changes, fast motion (like sports, action games, or FPS games), you should aim for the higher end of these ranges or even exceed them slightly if your connection allows.

720p 30fps

Standard content: 2,500-4,000 Kbps
High motion content: 4,000-5,000 Kbps
1080p 30fps

Standard content: 4,500-6,000 Kbps
High motion content: 6,000-8,000 Kbps
If you use 60fps, you will need to increase the bitrate 1.5x to 2x higher than the one needed for 30fps.

RTMP Delay Explained

Our RTMP ingress is configured for low latency. It typically adds between 1 and 2 seconds of delay to convert the video. If you can use a WebRTC or WHIP type of ingress, this will remove one step from the publishing pipeline and reduce latency. WHIP is going to be generally available in March 2025.

SRT Ingress

Similar to RTMP, using SRT can cause a delay of 1 or 2 seconds. Using WebRTC or WHIP reduces these delays. Note: SRT ingress is going to be generally available in March 2025.

Video at 4K
Publishing at 4K video resolution is heavy in terms of encoding the video and requires a camera that can capture at this resolution. Most consumer cameras do not support capturing video above 2K resolution.

Recommended Specs:

GPU: NVIDIA RTX 4080 and up are typically great at low latency AV1 encoding with 4K resolution.
Network: 50Mbps upload is recommended to support an AV1 upload.
In general, the configuration is more complex, so if you are interested in using 4K for your calls, we recommend reaching out to our support team to get more guidance.

Video bandwidth requirements
Many video applications, from video conferencing to live sports broadcasts, need to adapt to varying network conditions while maintaining acceptable visual quality. Estimating the required bandwidth for different resolutions, codecs, and levels of motion is essential for content producers, developers and network engineers to provision capacity, set encoder parameters, and avoid stalls or excessive compression artifacts.

For use cases requiring 60 fps, bandwidth requirements will be roughly double those listed below for 30 fps. In practice, encoding efficiency at higher frame rates may vary slightly, so you can generally scale the numbers by a factor of 1.8–2× to estimate 60 fps bitrates.

Static (low-motion)

Resolution	H.264	VP8	VP9	AV1
360p	150 kbps	110 kbps	90 kbps	70 kbps
480p	200 kbps	150 kbps	120 kbps	90 kbps
720p	600 kbps	450 kbps	350 kbps	280 kbps
1080p	1400 kbps	1000 kbps	790 kbps	630 kbps
1440p	2400 kbps	1800 kbps	1400 kbps	1100 kbps
4K	5400 kbps	4000 kbps	3100 kbps	2500 kbps
Conference (medium-motion)

Resolution	H.264	VP8	VP9	AV1
360p	320 kbps	280 kbps	230 kbps	190 kbps
480p	430 kbps	370 kbps	310 kbps	260 kbps
720p	1300 kbps	1100 kbps	930 kbps	770 kbps
1080p	2900 kbps	2500 kbps	2100 kbps	1700 kbps
1440p	5200 kbps	4400 kbps	3700 kbps	3100 kbps
4K	11600 kbps	10000 kbps	8400 kbps	7000 kbps
Sports (high-motion)

Resolution	H.264	VP8	VP9	AV1
360p	690 kbps	560 kbps	430 kbps	350 kbps
480p	930 kbps	740 kbps	580 kbps	460 kbps
720p	2800 kbps	2200 kbps	1700 kbps	1400 kbps
1080p	6200 kbps	5000 kbps	3900 kbps	3100 kbps
1440p	11100 kbps	8900 kbps	6900 kbps	5600 kbps
4K	25000 kbps	20000 kbps	15600 kbps	12500 kbps




Networking and Firewall
Stream Video leverages a combination of UDP and TCP protocols to deliver real-time video streams. By default, Stream uses UDP, which is the preferred protocol for real-time video transmission via WebRTC. However, some users may encounter restrictions on UDP due to firewall rules or networking configurations. If UDP is unavailable, the system automatically falls back to TCP. Although TCP provides a viable alternative, it is less ideal for real-time video, as it may result in decreased video quality.

For optimal performance, we recommend configuring firewalls to allow UDP and NAT as explained below.

Network and Port Requirements
Stream Video operates on an edge infrastructure with a dynamically managed list of servers for video call routing. For audio/video to work correctly, your network firewall must allow access to servers under the subdomains stream-io-video.com, stream-io-api.com and getstream.io (eg. video.stream-io-api.com, sfu-5a2a819a93e3-aws-sao1.stream-io-video.com).

Port Ranges Used by Stream Video
Signaling (HTTP and WebSocket over TLS):

Access to signaling is required for all clients to establish a connection. Signaling uses a combination of WSS and HTTPs (TCP/433). Without this, clients will not be able to connect to the server. You can test this by opening this link in your browser: https://video.stream-io-api.com/, this should show a JSON error response. If the page does not load or return some sort of HTML message, it is likely that your firewall is blocking access to the signaling server.

WebRTC

For audio/video to work you need clients to be able to connect to one of our video servers. The best connection is achieved when clients can connect to the server via UDP and NAT is configured correctly on your network. There are several fallback options available if UDP is blocked or unavailable, if NAT is not configured correctly, or if traffic is only allowed on specific ports.

Here is the list of ports used by Stream Video, for video to work correctly, your firewall must allow traffic for at least one of these ports:

UDP 32768 - 46883 (Best)
UDP 3478
UDP(DTLS) 443
TCP 3478
TCP(TLS) 443 (Slowest)
WebRTC - STUN (Session Traversal Utilities for NAT):

STUN is used to discover the public IP address of the client. This is required for clients to connect to the server via UDP. Your firewall must allow traffic for the following ports:

UDP 46884 - 60999
Firewall and NAT Considerations
Real-time video experiences the best quality when using STUN over UDP. This setup requires allowing the designated UDP port range and configuring NAT (Network Address Translation) to work correctly on the user’s network. If a client cannot connect via STUN/UDP, the SDK automatically switches to TURN, using either UDP or TCP as needed. This allows clients to connect directly to the server via TCP if UDP is blocked or unavailable. TURN is also available over TCP for clients that are restricted from using UDP.

Recommended Firewall Rules
To ensure compatibility and quality, configure the following rules:

Ensure NAT is configured correctly on your network
Ensure that HTTPS/WSS traffic is allowed, at least for addresses resolved by *.stream-io-video.com, *.stream-io-api.com and *.getstream.io
Ensure that at least one of the port ranges used by WebRTC is allowed, at least for addresses resolved by *.stream-io-video.com, *.stream-io-api.com and *.getstream.io
Allow TCP/443 and UDP/443 for all IPs listed by this DNS record pool.turn.stream-io-video.com (use dig pool.turn.stream-io-video.com to get the list)
This configuration ensures robust connectivity for all clients, maintaining the highest possible video quality across varying network environments.


Connection Test
Stream provides a dedicated connectivity test page that you can use to check the quality of your and your customers' connection. This page is useful for debugging and testing your network connection, and allows collecting a detailed report our team can analyze later.

The connection test page is available here: Connection Test.

Connection test
Available information
On this page, you can see the following information:

Video encoding support, Video decoding support, Audio encoding support, Audio decoding support: Lists the codecs that your device and browser support for video encoding. These can be different depending on your device, operating system and browser.
Video input devices, Audio input devices: Cameras and microphones that are currently connected and accessible by the browser. Make sure that the page has permissions to access your camera and microphone, and your browser is not affected by the operating system's privacy settings.
Connectivity: Shows the connection parameters
Your approximate location
The SFU node you are connected to (usually the closest one to your approximate location)
The protocol used for the connection (UDP or TCP)
The network type (LAN, Wi-Fi, or Cellular)
Liveness of the connection
Codecs in use: Shows the codecs that will be used by default for your device. These codecs may change depending on network conditions and the capabilities of other participants' devices.
Raw Call Stats: Shows the raw call stats
Understanding connectivity
Our systems deliver optimal video quality when UDP is used as the transport protocol. UDP is faster and more efficient than TCP. It is ideal for real-time applications like video and audio calls.

However, in some cases, UDP traffic might be blocked by firewalls or routers, and the call will fall back to the TCP protocol. In this case, the call quality might be degraded, but the call will still work.

If you often encounter issues with call quality, please check the Quality and Latency Guide.

Ideal network conditions
UDP protocol, connected to a datacenter close to your approximate location
LAN or Wi-Fi network with ~3Mbps per participant bandwidth and less than 50ms latency
Very low or no packet loss and jitter
Healthy connection to the Coordinator and the SFU node
Capturing a connection test report
A snapshot of the connection test report can be captured by clicking the Copy Report button on the top. This will copy the report to your clipboard, and you can paste it into an email or a support ticket.

Copy Report
Using Media Inspector bookmarklet
Media Inspector is a tool designed for web developers - it's not intended to be shared with your customers.

Media Inspector bookmarklet
Active media streams captured with the Media Capture API cause browsers and systems to display usage indicators, and not cleaning them up properly can be considered a privacy issue. Media Inspector bookmarklet helps you find active media streams in your application and answers the question "Why are my camera and microphone being used?"

We suggest the following workflow:

Drag the bookmarklet to your favorites bar.
Go to your application.
Click the bookmarklet before you join the call.
Join the call, enable your camera or microphone, and use your application as usual.
Open your browser console and execute the following code:

_inspectMedia();
_inspectMedia() call output
This function returns a list of tuples, each tuple representing a separate navigator.mediaDevices.getUserMedia() call in your application. The most important information here is media stream status: live or ended. Live media streams use your camera or microphone. You also have access to the MediaStream instance, and to the MediaStreamContraints object.

Let's say you found your live media stream. To find out why it was created, call the trace() method:


_inspectMedia()[1].trace();
You'll get a stack trace pointing the line of code where getUserMedia() API was called in the first place.

Did you find this page helpful?






Stats
In this document you can find more information about metrics that are important for audio/video quality and stability. These metrics are used to determine quality scores and are also exposed via API and on the Dashboard stats screen.

For video to be stable and high quality, it is necessary for Jitter, RTT, FPS and packet loss metrics to be stable and within acceptable values. Stream Video global edge infrastructure and Dynascale ensures high quality and stability for your calls by reducing the distance between users and servers and optimizing the audio/video to match each user's connectivity.

For more information about how Stream Video ensures quality video, see our Video Quality, Latency and Lag Guide.

Jitter
Jitter measures the variation in packet-arrival intervals; high jitter shows the connection is delivering media at uneven pacing. When jitter is too high, audio and video quality will degrade.

Jitter Range	Call Health	Description
< 40 ms	Good	Smooth audio and stable video with optimal real-time communication
40 – 50 ms	Fair	Occasional audio cracks and minor motion judder, acceptable for most use cases
> 50 ms	Poor	Robot-like voices, video stutter/freezes with significant quality issues
Common causes for high jitter

Poor Wi-Fi / Cellular connection
Network congestion
VPN
Round-Trip Time (RTT)
RTT measures the full out-and-back network latency between the user and the video edge; higher RTT lengthens echo-cancellation windows and slows loss recovery.

RTT Range	Call Health	Description
< 150 ms	Good	"Real-time" feel with excellent responsiveness for interactive communication
150 – 300 ms	Fair	Noticeable delay when taking turns, may affect natural conversation flow
> 300 ms	Poor	Participants talk over each other, harder lip-sync with significant delays
Common causes for high RTT

Poor Wi-Fi / Cellular connection
Congested internet connection
Geographical distance or using a TURN relay
Enterprise firewalls forcing TCP relay or deep-packet inspection
DDoS-mitigation appliances injecting extra hops
VPN
For more information about network requirements and firewall configurations, see our Networking and Firewall guide.

Frames Per Second (FPS)
FPS tracks how many video frames are actually sent (outbound) or rendered (inbound) per second; drops usually indicate CPU or bandwidth adaptation kicking in.

Effective FPS Range	Call Health	Description
24 – 30 fps	Good	Smooth motion with optimal video quality and fluid motion
15 – 23 fps	Fair	Slight choppiness, acceptable for most business applications
< 15 fps	Poor	Jerky motion, unreadable screen-share with significant quality degradation
Common causes for low FPS

The user publishing video has CPU issues encoding video fast enough (see encoding time later)
The user receiving video has CPU issues decoding video
Congested internet connection
Camera does not send stable 30fps
Power-saver limiting CPU usage for encoding or decoding (e.g., laptops, mobile devices)
Frame encoding time
Frame encoding time is how long the sender's encoder spends compressing each video frame; spikes mean the device can't keep up. Stream Video automatically detects slow encoding times and switches devices to lower resolutions and codecs that require less computation (e.g., AV1 → VP8).

Average Encode Time	Health	Description
< 25 ms	Good	Optimal encoding performance with head-room for spikes
25 – 33 ms	Warning	Approaching limits, risk of frame-drops below 30 fps
> 33 ms	Bad	Performance bottleneck causing visible quality degradation and stutter
Common causes for high encoding time

High CPU utilization by other processes
Thermal throttling reducing CPU/GPU frequency
Target resolution is set too high
The device cannot encode efficiently the selected video codec (e.g., AV1)
For information about configuring target resolutions and video quality settings, see our Call Types Settings guide.

Frame decoding time
Frame decoding time shows how long the receiver needs to turn compressed video back into pixels.

Average Decode Time	Health	Description
< 20 ms	Good	Optimal decoding performance with playback in lock-step
20 – 33 ms	Warning	Approaching performance limits, may start skipping frames
> 33 ms	Bad	Severe performance issues causing frozen or black video until next key-frame
Common causes

High CPU utilization by other processes
High-profile H.264/AV1 streams on low-end mobiles
Thermal throttling reducing CPU/GPU frequency
Packet loss
Packet loss is the fraction of packets never received. Please note that both audio and video can sustain some packet loss without any noticeable issue to the user. Some tolerance to packet loss is possible for these reasons:

Stream Video transport layer supports packet retransmission (NACK)
Redundant Audio Data (RED) is used to minimize impact of packet loss in audio stream
Forward error correction (FEC) in the opus codec can correct small packet loss with no or minimal impact to the playback
Loss Percentage (1-way)	Health	Description
< 5 %	Good	Rare glitches, error correction handles most issues
5 – 10 %	Fair	Audible pops, macro-blocks with moderate impact
> 10 %	Poor	Words drop, video blocks or freezes with significant impact
Common causes

Poor Wi-Fi / Cellular connection
Geographical distance
Audio concealment %
Audio concealment is the share of audio samples synthesized by the opus codec to account for lost packets compared to the total amount of audio samples.

Concealed Samples	Health	Description
< 5 %	Good	Minimal audio artifacts with natural sound
5 – 10 %	Fair	Small pops, slight "tin can" effect but acceptable quality
> 10 %	Poor	Words drop, robotic sound with significant audio degradation
Common causes

Packet loss
High jitter
Dealing with high jitter, RTT, audio concealment and packet loss
Users experiencing high values for these metrics for long enough periods will have a poor experience. These are major causes for high jitter, RTT, audio concealment or packet loss. Keep in mind that in some cases the same problem can cause multiple metrics to look unhealthy.

The user's connection is unstable (e.g., low signal on Wi-Fi or 4G, limited bandwidth, high latency, packet loss, etc.)
The user is very far from the video server
The user connection is congested
The user connects from a network
The user connects using a VPN
The user connection requires the use of TURN relay
The user connection does not allow UDP traffic
Stream Video edge infrastructure has a world-wide coverage, ensuring that users are close to a video server. You can see where users connect from and to which edge server they are connected from the Dashboard stats. Please reach out to support if your users do not have a nearby edge server.

For testing and debugging connection issues, use our Connection Test tool.

Best practices
Include connection status information in your application UI - Implement network quality indicators to help users understand their connection status. See our guides for React, React Native, iOS, Android, and Flutter.

Configure appropriate target resolutions and bitrates - Do not configure very high target resolutions or bitrates in your call type configuration (e.g., 1080p or 720p work great for most conferencing use-cases). See our Call Types Settings guide for configuration options.

Educate users about VPN impact - Explain to your users that use of VPN can have a negative impact on the call experience.

Ensure UDP traffic is allowed - If applicable, share our Connection Test tool with your users' network administrators and ensure that UDP traffic is allowed. See our Networking and Firewall guide for detailed requirements.

Use modern browsers - Minimize usage of old browser versions or usage of "exotic" browsers. WebRTC best implementation lives on Google Chrome.

Prefer native mobile apps - Prefer native mobile apps to browsers on mobile devices for better performance and reliability.

Keep SDKs updated - Keep your application up-to-date to the latest Stream Video SDK version. Check our installation guides for your platform to ensure you're using the latest version.

Active calls status endpoint
The get_active_calls_status endpoint returns a status overview for all calls that are currently running on your application. The endpoint includes summary information such as how many calls are running, how many users are connected, and a section about important health metrics such as jitter, round-trip latency, and FPS.

You can use this endpoint to get an overview of the overall status of your calls running on Stream Video, define alarms based on health metrics, and troubleshoot problems on specific calls. To make things simpler, data is organized by multiple dimensions.


Python

JavaScript

Golang

Java

cURL

response = client.video.get_active_calls_status()
print(
    f"There are {response.data.summary.active_calls} calls "
    f"currently running and {response.data.summary.participants} "
    f"connected users"
)
Example response

{
  "end_time": "2025-07-11T08:21:56.262333+00:00",
  "start_time": "2025-07-11T08:20:56.262333+00:00",
  "metrics": {
    "join_call_api": {
      "failures": 0.0,
      "total": 152.0,
      "latency": {
        "p50": 12.0,
        "p90": 37.2
      }
    },
    "publishers": {
      "all": {
        "audio": {
          "jitter_ms": {
            "p50": 9.215125775890233,
            "p90": 19.033705357142857
          }
        },
        "rtt_ms": {
          "p50": 52.849790316431566,
          "p90": 99.49866565001908
        },
        "video": {
          "fps_30": {
            "p05": 15.315719360568384,
            "p10": 16.652753108348135,
            "p50": 27.99822852081488,
            "p90": 28.729197080291968
          },
          "frame_encoding_time_ms": {
            "p50": 18.487886382623223,
            "p90": 20.75667311411993
          },
          "jitter_ms": {
            "p50": 12.747152619589977,
            "p90": 40.856304985337246
          },
          {
            "resolution": {
              "p10": 1080.0,
              "p50": 720.0
            }
          },
          {
            "bitrate": {
              "p10": 971.0,
              "p50": 1122.0
            }
          }
        }
      }
    },
    "subscribers": {
      "all": {
        "audio": {
          "concealment_pct": {
            "p50": 0.6185230518155854,
            "p90": 2.14135021097047
          },
          "jitter_ms": {
            "p50": 9.76944395306327,
            "p90": 19.254517952392327
          },
          "packets_lost_pct": {
            "p50": 0.06575754202382277,
            "p90": 0.5857954545454549
          }
        },
        "rtt_ms": {
          "p50": 22.0022869523351,
          "p90": 89.84574826116226
        },
        "video": {
          "fps_30": {
            "p05": 15.643523143523144,
            "p10": 16.914751914751915,
            "p50": 27.749330655957163,
            "p90": 28.458518712378957
          },
          "jitter_ms": {
            "p50": 23.52590771558245,
            "p90": 77.41462509279881
          },
          "packets_lost_pct": {
            "p50": 0.06737431427068462,
            "p90": 0.8301212938005396
          }
        }
      }
    }
  },
  "summary": {
    "active_calls": 143,
    "active_publishers": 2648,
    "active_subscribers": 4748,
    "participants": 5560
  }
}
Metrics
The response includes detailed metrics for both publishers (users sending audio/video) and subscribers (users receiving audio/video). These metrics help you understand the quality and performance of your calls.

API metrics
Important metrics for API call performance and reliability.

Metric	Description
join_call_api.failures	The rate of failed API calls (calls per second)
join_call_api.total	The total rate of API calls (calls per second)
join_call_api.latency.p50	The median latency for API calls (in seconds)
join_call_api.latency.p90	The 90th percentile latency for API calls (in seconds)
Publisher metrics
Important audio and video metrics for users publishing audio/video content.

Metric	Description
audio.rtt_ms	The elapsed time (in milliseconds) for an audio packet to travel from the sender to the receiver and back again
audio.jitter_ms	The variation in audio packet arrival time
video.rtt_ms	The elapsed time (in milliseconds) for a video packet to travel from the sender to the receiver and back again
video.jitter_ms	The variation in video packet arrival time
video.fps_30	The video frame rate being published
video.frame_encoding_time_ms	The time spent encoding individual video frames
video.resolution	The video resolution published in pixels, this metrics returns the minimum / height (eg. 1080 for both 1920x1080 and 1080x1920 resolutions)
video.bitrate	The video publishing bitrate measure in kbps
Subscriber metrics
Important audio and video metrics for users receiving audio/video content.

Metric	Description
audio.rtt_ms	The elapsed time (in milliseconds) for an audio packet to travel from the sender to the receiver and back again
audio.jitter_ms	The variation in audio packet arrival time
audio.concealment_pct	The percentage of audio with degraded quality due to audio packet loss (1.0 = 100%)
audio.packets_lost_pct	The percentage of audio packets lost during transmission (1.0 = 100%)
video.rtt_ms	The elapsed time (in milliseconds) for a video packet to travel from the sender to the receiver and back again
video.jitter_ms	The variation in video packet arrival time
video.fps_30	The video frame rate being rendered
video.frame_decoding_time_ms	The time spent decoding individual video frames
video.packets_lost_pct	The percentage of video packets lost during transmission (1.0 = 100%)
Thresholds and alarms
If you plan to use this endpoint to create alerts, we recommend following the information at the beginning of this document and set alerts for p90 metrics. The p90 values represent the 90th percentile, meaning 90% of measurements are below this threshold, making them good indicators for alerting on performance issues.

Note: Percentage fields (those ending with _pct) are returned as decimal values where 1.0 represents 100%. For example, a value of 0.05 means 5% and a value of 1.5 means 150%.


Overview
When running calls with a larger audience, you’ll often need moderation features to prevent abuse. Participants can share inappropriate content via

The video feed
Audio
Screen share
Chat messages
Username
Stream has tools to help you manage these issues while on a call.

Kicking & Blocking a member from a call
Call can be configured to only be accessible to their members. To remove a user from a call and prevent from accessing again:


JavaScript

Python

Golang

cURL

// Block user
call.blockUser({ user_id: "sara" });
// kick
call.kickUser({ user_id: "sara" });
// Unblock user
call.unblockUser({ user_id: "sara" });
Call permissions
You can configure if a screen share is enabled, disabled or requires requesting permission


JavaScript

Python

Golang

cURL

call.update({
  settings_override: {
    screensharing: { enabled: true, access_request_enabled: true },
  },
});
Muting everyone
You can also mute every other participant’s video or audio.


JavaScript

Python

Golang

cURL

// You can specify which kind of stream(s) to mute
call.muteUsers({
  mute_all_users: true,
  audio: true,
  muted_by_id: "john",
});
Muting one participant's video or audio (or both)

JavaScript

Python

Golang

cURL

call.muteUsers({
  user_ids: ["sara"],
  audio: true,
  video: true,
  screenshare: true,
  screenshare_audio: true,
  muted_by_id: "john",
});
Granting and revoking permissions
It's possible for users to ask for any of the following permissions:

Sending audio
Sending video
Sharing their screen
This feature is very common in audio rooms where users usually have to request permission to speak, but it can be useful in other call types and scenarios as well.

These requests will trigger the call.permission_request webhook.

This is how these requests can be accepted:


JavaScript

Python

Golang

cURL

call.updateUserPermissions({
  user_id: "sara",
  grant_permissions: [VideoOwnCapability.SEND_AUDIO],
});
For moderation purposes any user's permission to

send audio
send video
share their screen
can be revoked at any time. This is how it can be done:


JavaScript

Python

Golang

cURL

call.updateUserPermissions({
  user_id: "sara",
  revoke_permissions: [VideoOwnCapability.SEND_AUDIO],
});
Banning users
Users can be banned, when doing that they are not allowed to join or create calls. Banned users also cannot ring or notify other users.


JavaScript

Python

cURL

client.moderation.ban({
  target_user_id: "<bad user id>",
  banned_by_id: "<moderator id>",
  reason: "<reason>",
});
// remove the ban for a user
client.moderation.unban({
  target_user_id: "<user id>",
});
// ban a user for 30 minutes
client.moderation.ban({
  target_user_id: "<bad user id>",
  banned_by_id: "<moderator id>",
  timeout: 30,
});
// ban a user and all users sharing the same IP
client.moderation.ban({
  target_user_id: "<bad user id>",
  banned_by_id: "<moderator id>",
  reason: "<reason>",
  ip_ban: true,
});
Deactivating users
Deactivated users are no longer able to make any API call or connect to websockets (and receive updates on event of any kind).


JavaScript

Python

Golang

Java

cURL

client.deactivateUser({
  user_id: '<id>',
});
// reactivate
client.reactivateUsers({
  user_ids: ['<id>'],
});
// deactivating users in bulk is performed asynchronously
const deactivateResponse = client.deactivateUsers({
  user_ids: ['<id1>', '<id2>'...],
});
Deactivating users in bulk can take some time, this is how you can check the progress:


JavaScript

Python

Golang

Java

cURL

// Example of monitoring the status of an async task
// The logic is same for all async tasks
const response = await client.exportUsers({
  user_ids: ["<user id1>", "<user id1>"],
});
// you need to poll this endpoint
const taskResponse = await client.getTask({ id: response.task_id });
console.log(taskResponse.status === "completed");
For more information, please refer to the async operations guide

User blocking
Users can block other users using the API, when a user blocks another it will no longer receive ringing calls or notification from the blocked user.


JavaScript

Python

Golang

cURL

client.blockUsers({
  blocked_user_id: "bob",
  user_id: "alice",
});
client.getBlockedUsers({ user_id: "alice" });
client.unblockUsers({
  blocked_user_id: "bob",
  user_id: "alice",
});






Audio and Video
Stream Video includes an API that allows you to take moderation actions—such as flagging, blocking, muting, banning, and deleting users—when necessary. These API endpoints can be used by moderators and automated content systems. This section explains how you can capture audio and video and send them to your own moderation models or external tools.

Moderating Speech
You can capture speech from your calls and analyze it with moderation tools in three ways:

Audio recordings: Create recordings of your calls.
Call transcriptions: Generate text transcriptions after your calls.
Live captions: Use real-time captions for immediate moderation.
The first two methods provide a recording or transcription after the call is finished. For real-time moderation, use live captions and handle the corresponding caption events.

In all cases, set up a webhook handler on your backend to listen for events. Depending on your chosen approach, listen to the appropriate event type:

call.recording_ready
call.transcription_ready
call.closed_caption
Moderating Video
You can also use moderation tools for video, which is useful for enforcing content policies in your calls. There are three ways to moderate video for calls running on Stream:

Keyframe events: Use the built-in keyframe recorder to receive keyframe events every few seconds during a call.
Video recordings: Create recordings of calls for moderation after the session.
RTMP-out broadcasting: Connect to an external provider using RTMP-out broadcasting.
The simplest and most cost-effective approach for live video moderation is using keyframe events. Each event contains the most recent keyframe (still image) from each participant in the call. You can find more information on how frame recording works here.

Alternatively, you can use call recordings to perform video moderation after the call. To do this, set up a webhook handler on your server to process the call.recording_ready event.

The RTMP-out broadcasting approach relies on RTMP to integrate with some content moderation providers (e.g., Hive Moderation) by forwarding the video stream to their platform. Note that this method is usually more expensive.

Integrating with Stream Moderation
Stream offers a moderation product that allows you to detect content, submit flagged content and provides a moderation dashboard for moderators to review all content flagged by users or by API integrations. More information and documentation about this can be found here.





Recording calls
Calls can be recorded for later use. Calls recording can be started/stopped via API calls or configured to start automatically when the first user joins the call. Call recording is done by Stream server-side and later stored on AWS S3. There is no charge for storage of recordings. You can also configure your Stream application to have files stored on your own S3 bucket.

By default, calls will be recorded as mp4 video files. You can configure recording to only capture the audio.

Note: by default, recordings contain all tracks mixed in a single file. You can follow the discussion here if you are interested in different ways to record calls.

Start and stop call recording

JavaScript

Python

Golang

cURL

// starts recording
call.startRecording();
// stops the recording for the call
call.stopRecording();
List call recording
This endpoint returns the list of recordings for a call. When using Stream S3 as storage (default) all links are signed and expire after 2-weeks.


JavaScript

Python

Golang

cURL

call.listRecordings();
Delete call recording
This endpoint allows to delete call recording. Please note that recordings will be deleted only if they are stored on Stream side (default).

An error will be returned if the recording doesn't exist.


JavaScript

Python

Golang

cURL

call.deleteRecording({ session: "<session id>", filename: "<filename>" });
Events
These events are sent to users connected to the call and your webhook/SQS:

call.recording_started when the call recording has started
call.recording_stopped when the call recording has stopped
call.recording_ready when the recording is available for download
call.recording_failed when recording fails for any reason
User Permissions
The following permissions are checked when users interact with the call recording API.

StartRecording required to start the recording
StopRecording required to stop the recording
ListRecordings required to retrieve the list of recordings
DeleteRecording required to delete an existing recording (including its files if stored using Stream S3 storage)
Enabling / Disabling call recording
Recording can be configured from the Dashboard (see call type screen) or directly via the API. It is also possible to change the recording settings for a call and override the default settings coming from the its call type.


JavaScript

Python

Golang

cURL

// Disable on call level
call.update({
  settings_override: {
    recording: {
      mode: "disabled",
    },
  },
});
// Disable on call type level
client.video.updateCallType({
  name: "<call type name>",
  settings: {
    recording: {
      mode: "disabled",
    },
  },
});
// Automatically record calls
client.video.updateCallType({
  name: "<call type name>",
  settings: {
    recording: {
      mode: "auto-on",
      quality: "720p",
    },
  },
});
// Enable
call.update({
  settings_override: {
    recording: {
      mode: "available",
    },
  },
});
// Other settings
call.update({
  settings_override: {
    recording: {
      mode: "available",
      audio_only: false,
      quality: "1080p",
    },
  },
});
Audio only recording
You can configure your calls to only record the audio tracks and exclude the video. You can do this from the dashboard (Call Types sections) or set it for individual calls.


JavaScript

Python

Golang

cURL

// Enable
call.update({
  settings_override: {
    recording: {
      mode: "available",
      audio_only: true,
    },
  },
});
Recording layouts
Recording can be customized in several ways:

You can pick one of the built-in layouts and pass some options to it
You can further customize the style of the call by providing your own CSS file
You can use your own recording application
There are three available layouts you can use for your calls: "single_participant", "grid" and "spotlight"

Single Participant
This layout shows only one participant video at a time, other video tracks are hidden.

Layout Single Participant
The visible video is selected based on this priority:

Participant is pinned
Participant is screen-sharing
Participant is the dominant speaker
Participant has a video track
Grid
This layout shows a configurable number of tracks in an equally sized grid.

Layout Grid
Spotlight
This layout shows a video in a spotlight and the rest of the participants in a separate list or grid.

Layout Spotlight
Layout options
Each layout has a number of options that you can configure. Here is an example:

Layout Custom Options

JavaScript

Python

Golang

cURL

const layoutOptions = {
  "logo.image_url":
    "https://theme.zdassets.com/theme_assets/9442057/efc3820e436f9150bc8cf34267fff4df052a1f9c.png",
  "logo.horizontal_position": "center",
  "title.text": "Building Stream Video Q&A",
  "title.horizontal_position": "center",
  "title.color": "black",
  "participant_label.border_radius": "0px",
  "participant.border_radius": "0px",
  "layout.spotlight.participants_bar_position": "top",
  "layout.background_color": "#f2f2f2",
  "participant.placeholder_background_color": "#1f1f1f",
  "layout.single-participant.padding_inline": "20%",
  "participant_label.background_color": "transparent",
};
client.video.updateCallType({
  name: callTypeName,
  settings: {
    recording: {
      mode: "available",
      audio_only: false,
      quality: "1080p",
      layout: {
        name: "spotlight",
        options: layoutOptions,
      },
    },
  },
});
Here you can find the complete list of options available to each layout.

Single Participant
Option	Type	Default	Allowed Values	Description
video.background_color	color	#000000		The background color
video.screenshare_scale_mode	string	fit	[fit fill]	How source video is displayed inside a box when aspect ratio does not match. 'fill' crops the video to fill the entire box, 'fit' ensures the video fits inside the box by padding necessary padding
participant.label_horizontal_position	string	left	[center left right]	horizontal position for the participant label
participant.video_border_radius	number	1.2		The corner radius used for the participant video border
logo.horizontal_position	string	center	[center left right]	horizontal position of the logo
participant.label_display	boolean	true		Show the participant label
participant.label_text_color	color	#000000		Text color of the participant label
participant.label_background_color	color	#00000000		Background color of the participant label
participant.label_border_radius	number	1.2		The corner radius used for the label border
logo.vertical_position	string	top	[top bottom center]	vertical position of the logo
participant.label_display_border	boolean	true		Render label border
participant.label_vertical_position	string	bottom	[top bottom center]	vertical position for the participant label
participant.video_highlight_border_color	color	#7CFC00		The color used for highlighted participants video border
participant.video_border_rounded	boolean	true		Render the participant video border rounded
participant.video_border_width	boolean	true		The stroke width used to render a participant border
participant.placeholder_background_color	color	#000000		Sets the background color for video placeholder tile
video.scale_mode	string	fill	[fit fill]	How source video is displayed inside a box when aspect ratio does not match. 'fill' crops the video to fill the entire box, 'fit' ensures the video fits inside the box by padding necessary padding
logo.image_url	string			add a logo image to the video layout
participant.label_border_color	color	#CCCCCC		Label border color
participant.label_border_rounded	boolean	true		Render the label border rounded
participant.video_border_color	color	#CCCCCC		The color used for the participant video border
participant.aspect_ratio	string		"9/16", "4/3", "1/1", ...	The aspect ratio of the participant
custom_actions	array		See Custom actions	Optional array of custom actions that should be executed when pre-defined condition is met
presenter_visible	boolean	true	true or false	Enables or disables presenter's camera video in the recording during screen sharing.
Spotlight
Option	Type	Default	Allowed Values	Description
participant.video_border_width	boolean	true		The stroke width used to render a participant border
grid.position	string	bottom	[top bottom left right]	position of the grid in relation to the spotlight
participant.label_display_border	boolean	true		Render label border
participant.label_horizontal_position	string	left	[center left right]	horizontal position for the participant label
participant.video_border_color	color	#CCCCCC		The color used for the participant video border
grid.columns	number	5		how many column to use in grid mode
video.background_color	color	#000000		The background color
logo.horizontal_position	string	center	[center left right]	horizontal position of the logo
participant.label_border_color	color	#CCCCCC		Label border color
participant.label_background_color	color	#00000000		Background color of the participant label
grid.cell_padding	size	10		padding between cells
screenshare_layout	string	spotlight	[grid spotlight single-participant]	The layout to use when entering screenshare mode
grid.size_percentage	number	20		The percentage of the screen the grid should take up
participant.label_border_radius	number	1.2		The corner radius used for the label border
participant.video_highlight_border_color	color	#7CFC00		The color used for highlighted participants video border
participant.placeholder_background_color	color	#000000		Sets the background color for video placeholder tile
participant.video_border_radius	number	1.2		The corner radius used for the participant video border
participant.label_display	boolean	true		Show the participant label
participant.label_border_rounded	boolean	true		Render the label border rounded
participant.video_border_rounded	boolean	true		Render the participant video border rounded
grid.rows	number	1		how many rows to use in grid mode
grid.margin	size	10		the margin between grid and spotlight
video.scale_mode	string	fill	[fit fill]	How source video is displayed inside a box when aspect ratio does not match. 'fill' crops the video to fill the entire box, 'fit' ensures the video fits inside the box by padding necessary padding
logo.image_url	string			add a logo image to the video layout
logo.vertical_position	string	top	[top bottom center]	vertical position of the logo
video.screenshare_scale_mode	string	fit	[fit fill]	How source video is displayed inside a box when aspect ratio does not match. 'fill' crops the video to fill the entire box, 'fit' ensures the video fits inside the box by padding necessary padding
participant.label_text_color	color	#000000		Text color of the participant label
participant.label_vertical_position	string	bottom	[top bottom center]	vertical position for the participant label
participant.aspect_ratio	string		"9/16", "4/3", "1/1", ...	The aspect ratio of the participant
participant.filter	object		See Filtering participants	Optional filter object to determine which participants should be displayed
custom_actions	array		See Custom actions	Optional array of custom actions that should be executed when pre-defined condition is met
Grid
Option	Type	Default	Allowed Values	Description
logo.image_url	string	``		add a logo image to the video layout
logo.vertical_position	string	top	[top bottom center]	vertical position of the logo
participant.label_horizontal_position	string	left	[center left right]	horizontal position for the participant label
participant.placeholder_background_color	color	#000000		Sets the background color for video placeholder tile
video.scale_mode	string	fill	[fit fill]	How source video is displayed inside a box when the aspect ratio does not match. 'fill' crops the video to fill the entire box, 'fit' ensures the video fits inside the box by padding necessary padding
logo.horizontal_position	string	center	[center left right]	horizontal position of the logo
participant.video_border_rounded	boolean	true		Render the participant video border rounded
participant.label_display_border	boolean	true		Render label border
participant.label_border_color	color	#CCCCCC		Label border color
grid.cell_padding	size	10		padding between cells
video.screenshare_scale_mode	string	fit	[fit fill]	How source video is displayed inside a box when the aspect ratio does not match. 'fill' crops the video to fill the entire box, 'fit' ensures the video fits inside the box by padding necessary padding
video.background_color	color	#000000		The background color
participant.label_border_radius	number	1.2		The corner radius used for the label border
grid.size_percentage	number	90		The percentage of the screen the grid should take up
grid.margin	size	10		the margin between grid and spotlight
grid.columns	number	5		how many column to use in grid mode
participant.label_vertical_position	string	bottom	[top bottom center]	vertical position for the participant label
participant.label_display	boolean	true		Show the participant label
participant.video_border_color	color	#CCCCCC		The color used for the participant video border
participant.video_border_width	boolean	true		The stroke width used to render a participant border
screenshare_layout	string	spotlight	[grid spotlight single-participant]	The layout to use when entering screen share mode
participant.label_text_color	color	#000000		Text color of the participant label
participant.label_background_color	color	#00000000		Background color of the participant label
participant.label_border_rounded	boolean	true		Render the label border rounded
participant.video_border_radius	number	1.2		The corner radius used for the participant video border
participant.video_highlight_border_color	color	#7CFC00		The color used for highlighted participants video border
grid.rows	number	4		how many rows to use in grid mode
participant.aspect_ratio	string		"9/16", "4/3", "1/1", ...	The aspect ratio of the participant
participant.filter	object		See Filtering participants	Optional filter object to determine which participants should be displayed in the grid
custom_actions	array		See Custom actions	Optional array of custom actions that should be executed when pre-defined condition is met
Recording resolution and portrait mode
Calls can be recorded in different resolutions and modes (landscape and portrait). On the dashboard, you can configure the default settings for all calls of a specific call type.

Recording Resolution And Orientation
While this can be configured from the dashboard, you can also set it for individual calls:


JavaScript

Python

cURL

client.video.updateCallType({
  name: callTypeName,
  settings: {
    recording: {
      mode: "available",
      quality: "portrait-1080x1920",
    },
  },
});
Filtering participants
The participant.filter option allows you to choose which participants are visible in the recording. Its value is a special filter object.

The following properties are allowed to be used in the filter object:

Property	Type	Description
userId	string	Participant's user id
isSpeaking	boolean	Indicates wheather the participant is currently speaking
isDominantSpeaker	boolean	Indicates wheather the participant is a dominant speaker (only one participant can be a dominant speaker at the time)
name	string	Participant's user name
roles	string[]	List of participant's roles in the current call
isPinned	boolean	Indicates wheather the participant is pinned
hasVideo	boolean	Indicates whether the participant has video
hasAudio	boolean	Indicates whether the participant has audio
hasScreenShare	boolean	Indicates whether the participant has screen share video
For example, to include only pinned participants in the recording, you can provide the following filter:


{
  "participant.filter": {
    "isPinned": true
  }
}
If you want to filter participants based on their role, keep in mind that a participant can have more than one role within a call. Because the roles property is an array, you must use the $contains operator to build your filter. For example, this filter will only match participants with the role "admin":


{
  "participant.filter": {
    "roles": { "$contains": "admin" }
  }
}
When recording livestreams, including only participants with video is an easy way to exclude viewers from the recording:


{
  "participant.filter": {
    "hasVideo": true
  }
}
Other operators you can use are $neq ("not equal to") and $in ("equal to one of the listed values"). For example, this filter will only match participants with one of the three names:


{
  "participant.filter": {
    "name": { "$in": ["Moe", "Larry", "Curly"] }
  }
}
You can also use the $eq ("equals") operator, but its effect is the same as not using any operator at all, as in the first example.

You can combine multiple conditions using the $and, $or, and $not operators:


// Hide participants with the role "guest", unless they have been pinned:
{
  "participant.filter": {
    "$or": [
      { "$not": { "roles": { "$contains": "guest" } } },
      { "isPinned": true }
    ]
  }
}
// Show participants that either have video or screen share
{
  "participant.filter": {
    "$or": [
      { "hasVideo": true },
      { "hasScreenShare": true }
    ]
  }
}
Custom actions
Custom actions let you dynamically adjust the recording setup during the runtime based on the conditions you define under options.custom_actions configuration option. The function that evaluates the conditions is the same as in Filtering participants (participant.filter option) and allows using the same operators.

Available actions
layout_override
Override the current layout when a condition matches. The first matching layout_override action wins (checked top-to-bottom).

Property	Type	Allowed Values	Description
action_type	layout_override		
layout	string	[grid spotlight single-participant]	One of the supported layouts
ignore_screenshare	boolean		When true, keeps the override even during screen sharing; otherwise screenshare_layout takes precedence
condition	object		
options_override
Override any supported options.* values when a condition matches. All matching options_override actions are merged in order; later actions overwrite earlier ones for the same option keys.

Property	Type	Allowed Values	Description
action_type	options_override		
options	object	Refer to Single Participant, Spotlight and Grid	A partial of the supported options keys (anything you normally set under options.*), custom_actions are omitted
condition	object		
Target values & supported operators
You can target these values in conditions:

Property	Type	Description
participant_count	number	Number of participants in the call
pinned_participant_count	number	Number of pinned participants in the call (evaluated client-side)
Logical operators:

$and, $or, $not
Scalar operators:

$eq, $neq, $in, $gt, $gte, $lt, $lte
The number of target values is currently limited but if you need other properties available feel free to reach out to our support.

Examples
Switch to a dominant-spearker layout when pinned_participant_count is greater or equal to one:


{
  // other options
  "custom_actions": [
    {
      "action_type": "layout_override",
      "condition": {
        "pinned_participant_count": { "$gte": 1 }
      },
      "layout": "dominant-speaker"
    }
  ]
}
Apply different background color to the recording setup when second participant joins the call:


{
  // other options
  "custom_actions": [
    {
      "action_type": "options_override",
      "condition": {
        "participant_count": { "$gt": 1 }
      },
      "options": {
        "layout.background_color": "hotpink"
      }
    }
  ]
}
Custom recording styling using external CSS
You can customize how recorded calls look by providing an external CSS file. The CSS file needs to be publicly available and ideally hosted on a CDN to ensure the best performance. The best way to find the right CSS setup is by running the layout app directly. The application is publicly available on Github here and contains instructions on how to be used.


JavaScript

Python

Golang

cURL

client.video.updateCallType({
  name: callTypeName,
  settings: {
    recording: {
      mode: "available",
      audio_only: false,
      quality: "1080p",
      layout: {
        name: "spotlight",
        external_css_url: "https://path/to/custom.css",
      },
    },
  },
});
Advanced - record calls using a custom web application
If needed, you can use your own custom application to record a call. This is the most flexible and complex approach to record calls, make sure to reach out to our customer support before going with this approach.

The layout app used to record calls is available on GitHub and is a good starting point. The repository also includes information on how to build your own.


JavaScript

Python

Golang

cURL

client.video.updateCallType({
  name: callTypeName,
  settings: {
    recording: {
      mode: "available",
      audio_only: false,
      quality: "1080p",
      layout: {
        name: "custom",
        external_app_url: "https://path/to/layout/app",
      },
    },
  },
});
Client-side recording
Unfortunately, there is no direct support for client-side recording at the moment. Call recording at the moment is done by Stream server-side. If client-side recording is important for you please make sure to follow the conversation here.


Frame Recording
Frame recording is a lightweight alternative to traditional call recordings that focuses on capturing periodic still images (or “frames”) from your video calls. When enabled, events with key frames are delivered periodically to your backend via webhooks/SQS.

Common use-cases for this feature include:

Quickly Spot Inappropriate Behavior: By reviewing periodically captured frames, moderators can rapidly identify any visual signs of misconduct or potential issues in real time.
Empower AI Moderation: Seamlessly integrate with AI-driven moderation tools that analyze the visual content automatically, flagging suspicious activities based on the still images received.
Enhance Post-Call Analysis: Utilize the still images as reference points during investigations of reported incidents or for performing detailed compliance checks.
Reduce Storage Overhead: Focus on capturing key moments without the data-heavy requirements of full video recordings, resulting in efficient data management.
Frame recording can be started/stopped for specific calls using the API or can be configured to automatically start for all calls.


JavaScript

Python

Golang

cURL

// starts frame recording
call.startFrameRecording();
// stops the frame recording for the call
call.stopFrameRecording();
Keyframe event
A call.frame_recording_ready event is delivered to your webhook/SQS handler periodically, by default a key-frame event is sent every two seconds for each participant. For example, on a call with 3 participants you will receive 3 events every 2 seconds.

Here's an example of the event payload:


{
  "call_cid": "default:e6fd0221-c926-40a6-80d4-9aa386937cae",
  "captured_at": "2025-02-10T09:15:37.95784985Z",
  "created_at": "2025-02-10T09:15:44.252969252Z",
  "session_id": "e48dd421-6281-457e-8995-0ccc463da252",
  "track_type": "TRACK_TYPE_VIDEO",
  "type": "call.frame_recording_ready",
  "url": "https://path/to/captured/image",
  "users": {
    "$user_id": {
      "banned": false,
      "blocked_user_ids": [],
      "created_at": "2023-11-24T15:32:08.327662Z",
      "id": "$user_id",
      "image": "...",
      "invisible": false,
      "language": "",
      "last_active": "2025-02-10T09:15:39.515802276Z",
      "name": "Tommaso Barbugli",
      "online": true,
      "role": "user",
      "shadow_banned": false,
      "teams": [],
      "updated_at": "2024-05-10T14:11:48.986736Z"
    }
  }
}
Your backend can use this events to perform image moderation on a live call and then use the moderation APIs to take necessary actions.

Adjusting events frequency and quality
You can adjust how often frames are captured to to anything between 2 and 60 seconds (by default frames are captured every three seconds). It is also possible to change the resolution for the image to any of these values: 360p, 420p, 720p, 1080p and 1440p. By default 720p is used.

Running frame recorder automatically for all calls
You can configure your call type to automatically start a frame recorder for every new call, this can be done via API or from the dashboard:


JavaScript

Python

Golang

cURL

await client.video.updateCallType({
  name: "default",
  settings: {
    frame_recording: {
      mode: "auto-on",
      capture_interval_in_seconds: 5,
      quality: "720p",
    },
  },
});
External storage
By default, keyframe images are stored on Stream CDN and retained for 2-weeks. The image URLs are all signed. If your call type is configured to use a different storage, then the images will be uploaded to that storage.

Events
These events are sent to your webhook/SQS when using frame recording:

call.frame_recording_started when frame recording has started
call.frame_recording_stopped when frame recording stopped
call.frame_recording_failed when frame recording failed to start
User Permissions
You can start/stop frame recording server-side or client-side. There are two permissions that can be granted to users: StartFrameRecording and StopFrameRecording.


Storage
By default, call recordings are stored in an AWS S3 bucket managed by Stream, located in the same region as your application. Recording files are retained for two weeks before being automatically deleted. If you need to keep recordings longer or prefer not to store this data with Stream, you can opt to use your own storage solution.

Use your own storage
Stream supports the following external storage providers:

Amazon S3
Google Cloud Storage
Azure Blob Storage
If you need support for a different storage provider, you can participate in the conversation here.

To use your own storage you need to:

Configure a new external storage for your Stream application. Stream supports up to 10 storage configurations per application.
(Optional) Check storage configuration for correctness. Calling check endpoint will create a test markdown file in the storage to verify the configuration. It will return an error if the file is not created. In case of success, the file withstream-<uuid>.md will be uploaded to the storage. Every time you call this endpoint, a new file will be created.
Configure your call type(s) to use the new storage
Once the setup is complete, call recordings and transcription files will be automatically stored in your own storage.


JavaScript

Python

Golang

cURL

// 1. create a new storage with all the required parameters
await client.createExternalStorage({
  bucket: "my-bucket",
  name: "my-s3",
  storage_type: "s3",
  path: "directory_name/",
  aws_s3: {
    s3_region: "us-east-1",
    s3_api_key: "my-access-key",
    s3_secret: "my-secret",
  },
});
// 2. (Optional) Check storage configuration for correctness
// In case of any errors, this will throw a ResponseError.
await client.checkExternalStorage({
  name: "my-s3",
});
// 3. update the call type to use the new storage
await client.video.updateCallType({
  name: "my-call-type",
  external_storage: "my-s3",
});
Multiple storage providers and default storage
You can configure multiple storage providers for your application. Maximum of 10 storage providers can be configured. When starting a transcription or recording, you can specify which storage provider to use for that particular call. If none is specified, the default storage provider will be used.

When transcribing or recording a call, the storage provider is selected in this order:

If specified at the call level, the storage provider chosen for that particular call will be used.
If specified at the call type level, the storage provider designated for that call type will be used.
If neither applies, Stream S3 storage will be used.
Note: All Stream applications have Stream S3 storage enabled by default, which you can refer to as "stream-s3" in the configuration.


JavaScript

Python

Golang

cURL

// update the call type to use Stream S3 storage for recordings
await client.video.updateCallType({
  name: "my-call-type",
  external_storage: "stream-s3",
});
// specify my-storage storage when starting call transcribing
await call.startTranscription({
  transcription_external_storage: "my-storage",
});
// specify my-storage storage for recording
await call.startRecording({ recording_external_storage: "my-storage" });
Storage configuration
Request model
All storage providers have 4 shared parameters, other parameters are dependant on what kind of storage you want to create (below you can find examples for all supported storage types):

CreateExternalStorageRequest
Name	Type	Description	Constraints
aws_s3	S3Request	Only required if you want to create an Amazon S3 storage	-
azure_blob	AzureRequest	Only required if you want to create an Azure Blob Storage	-
bucket	string	The name of the bucket on the service provider	Required
gcs_credentials	string	-	-
name	string	The name of the provider, this must be unique	Required
path	string	The path prefix to use for storing files	-
storage_type	string (s3, gcs, abs)	The type of storage to use	Required
Amazon S3
Request model
This is how you can configure S3 stroage in the Stream API:

S3Request
Name	Type	Description	Constraints
s3_api_key	string	The AWS API key. To use Amazon S3 as your storage provider, you have two authentication options: IAM role or API key. If you do not specify the `s3_api_key` parameter, Stream will use IAM role authentication. In that case make sure to have the correct IAM role configured for your application.	-
s3_custom_endpoint_url	string	The custom endpoint for S3. If you want to use a custom endpoint, you must also provide the `s3_api_key` and `s3_secret` parameters.	-
s3_region	string	The AWS region where the bucket is hosted	Required
s3_secret	string	The AWS API Secret	-
Code example

JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  name: "my-s3",
  storage_type: "s3",
  bucket: "my-bucket",
  path: "directory_name/",
  aws_s3: {
    s3_api_key: "us-east-1",
    s3_region: "my-access-key",
    s3_secret: "my-secret",
  },
});
Example S3 policy
With this option you omit the key and secret, but instead you set up a resource-based policy to grant Stream SendMessage permission on your S3 bucket. The following policy needs to be attached to your queue (replace the value of Resource with the fully qualified ARN of you S3 bucket):


{
  "Version": "2012-10-17",
  "Id": "StreamExternalStoragePolicy",
  "Statement": [
    {
      "Sid": "ExampleStatement01",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::185583345998:root"
      },
      "Action": ["s3:PutObject"],
      "Resource": ["arn:aws:s3:::bucket_name/*", "arn:aws:s3:::bucket_name"]
    }
  ]
}
S3 Compatible Storage (Minio)
To use Minio or other S3 compatible storage you can specify custom endpoint. In this case API key and secret are required.


JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  name: "my-s3",
  storage_type: "s3",
  bucket: "my-bucket",
  path: "directory_name/",
  aws_s3: {
    s3_api_key: "us-east-1",
    s3_region: "my-access-key",
    s3_secret: "my-secret",
    s3_custom_endpoint_url: "https://s3.us-east-1.amazonaws.com",
  },
});
Google Cloud Storage
To use Google Cloud Storage as your storage provider, you need to send your service account credentials as they are stored in your JSON file. Stream only needs permission to write new files, it is not necessary to grant any other permission.

Note: We recommend reading the credentials from the file to avoid issues with copying and pasting errors.

Code example

JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  bucket: "my-bucket",
  name: "my-gcs",
  storage_type: "gcs",
  path: "directory_name/",
  gcs_credentials: "content of the service account file",
});
Example policy

{
  "bindings": [
    {
      "role": "roles/storage.objectCreator",
      "members": ["service_account_principal_identifier"]
    }
  ]
}
Azure Blob Storage
To use Azure Blob Storage as your storage provider, you need to create a container and a service principal with the following parameters:

Request model
AzureRequest
Name	Type	Description	Constraints
abs_account_name	string	The account name	Required
abs_client_id	string	The client id	Required
abs_client_secret	string	The client secret	Required
abs_tenant_id	string	The tenant id	Required
Stream only needs permission to write new files, it is not necessary to grant any other permission.

Code example

JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  name: "my-abs",
  storage_type: "abs",
  bucket: "my-bucket",
  path: "directory_name/",
  azure_blob: {
    abs_account_name: "...",
    abs_client_id: "...",
    abs_client_secret: "...",
    abs_tenant_id: "...",
  },
});
Uploading times
Call recordings are uploaded immediately under the following conditions:

The call has ended.
Call recording is manually stopped.
The call recording exceeds 2 hours in duration.
For lengthy calls, multiple files will be uploaded. Each file will contain up to 2 hours of video.

Upload times vary based on the storage method used. Below is a table providing a conservative estimation of upload times:

<=5 minutes	<=1 hour	<=2 hours
Audio	< 10s	< 10s	< 10s
HD Video	< 10s	< 30s	< 60s
FHD Video	< 10s	< 60s	< 120s
Please refer to this table to estimate the upload times based on your specific storage setup.


Transcriptions & Captions
Stream supports transcriptions and live closed captions for audio and video calls. Both can be configured to run automatically or can be started and stopped with API calls. Closed captions are delivered to clients with WebSocket events, and transcriptions are uploaded after the call has ended or the process is stopped. If transcription is enabled automatically, the transcription process will start when the first user joins the call, and stop when all participants have left the call.

Quick Start

JavaScript

Python

Golang

cURL

// start transcription with language
await call.startTranscription({ language: "en" });
// start closed captions with language
await call.startClosedCaptions({ language: "en" });
// stop transcription
await call.stopTranscription();
// stop closed captions
await call.stopClosedCaptions();
// you can also start or stop with a single API call
await call.startTranscription({ enable_closed_captions: true });
await call.stopTranscription({ stop_closed_captions: true });
By default, transcriptions are stored in Stream’s S3 bucket and retained for two weeks. You can also configure your application to store transcriptions on your own external storage, see the Storage section for more detail.

Note: While transcription occurs continuously during the call, and chunks of conversations are saved continuously, the complete transcription file is uploaded only once at the end of the call. This approach is used to avoid requiring additional permissions (such as delete permissions) when using external storage.

Transcription language
For best speech-to-text performance, it is recommended that you specify the language you are using. By default, the language is set to English (en) for all call types.

Alternatively, you can use automatic language detection, which is easier to set up but has some drawbacks:

Speech-to-text accuracy is lower
Closed caption events will have an additional latency
There are three ways to set the transcription language:

call type level: this is the default language for all calls of the same type
call level: when provided, it overrides the language set for its call type
when starting closed captions or transcriptions using the API
Note: If you change the language for an active call, we will propagate the new language to the already running transcription/closed-caption process.


JavaScript

Python

Golang

cURL

// 1. set the language for all calls of the default type to "fr"
await client.video.updateCallType("default", {
  settings: {
    transcription: {
      language: "fr",
    },
  },
});
// 2. create a call and set its language to "fr"
await call.getOrCreate({
  settings_override: {
    transcription: {
      language: "fr",
    },
  },
});
// 3. update an existing call and set its language to "fr"
await call.update({
  settings_override: {
    transcription: {
      language: "fr",
    },
  },
});
// 4. start transcription and set language to "fr"
await call.startTranscription({ language: "fr" });
Closed captions: Speech segment settings
These settings control how live captions are segmented into on-screen chunks.

max_speech_caption_ms (default 9000, range 5000–10000): Maximum duration of a single caption segment during continuous speech.
silence_duration_ms (default 700, range 300–2000): Minimum silence to finalize the current caption and start a new one.
Why use it
To keep captions smaller on mobile, use shorter values. Example: max_speech_caption_ms=5000, silence_duration_ms=500–800.
How it works
A caption finalizes when detected silence exceeds silence_duration_ms, or when continuous speech reaches max_speech_caption_ms.
Configuration
Configure per call type (default for all calls of that type) or per call (override) under transcription settings.

JavaScript

Python

Golang

cURL

// Per call type (default)
await client.video.updateCallType("default", {
  settings: {
    transcription: {
      speech_segment_config: {
        max_speech_caption_ms: 9000,
        silence_duration_ms: 700,
      },
    },
  },
});
// Per call (override)
await call.update({
  settings_override: {
    transcription: {
      speech_segment_config: {
        max_speech_caption_ms: 5000,
        silence_duration_ms: 600,
      },
    },
  },
});
List call transcriptions
Note: transcriptions stored on Stream’s S3 bucket (the default) will be returned with a signed URL.


JavaScript

Python

Golang

cURL

call.listTranscriptions();
Delete call transcription
This endpoint allows to delete call transcription. Please note that transcriptions will be deleted only if they are stored on Stream side (default).

An error will be returned if the transcription doesn't exist.


JavaScript

Python

Golang

cURL

call.deleteTranscription({ session: "<session ID>", filename: "<filename>" });
Events
These events are sent to users connected to the call and your webhook/SQS:

call.transcription_started sent when the transcription of the call has started
call.transcription_stopped this event is sent only when the transcription is explicitly stopped through an API call, not in cases where the transcription process encounters an error.
call.transcription_ready dispatched when the transcription is completed and available for download. An example payload of this event is detailed below.
call.transcription_failed sent if the transcription process encounters any issue
call.closed_captions_started sent when captioning has started
call.closed_caption an event containing transcribed speech from a participant
call.closed_captions_stopped sent when captioning is stopped
call.closed_captions_failed sent when the captioning process encounters any issue
Transcription JSONL file format
The transcription file is a JSONL, where each line is a JSON object containing a speech fragment, and each speech fragment contains timing and user information. It is trivial to convert this JSONL format to other simpler formats such as SRT.


{"type":"speech", "start_time": "2024-02-28T08:18:18.061031795Z", "stop_time":"2024-02-28T08:18:22.401031795Z", "speaker_id": "Sacha_Arbonel", "text": "hello"}
{"type":"speech", "start_time": "2024-02-28T08:18:22.401031795Z", "stop_time":"2024-02-28T08:18:26.741031795Z", "speaker_id": "Sacha_Arbonel", "text": "how are you"}
{"type":"speech", "start_time": "2024-02-28T08:18:26.741031795Z", "stop_time":"2024-02-28T08:18:31.081031795Z", "speaker_id": "Tommaso_Barbugli", "text": "I'm good"}
{"type":"speech", "start_time": "2024-02-28T08:18:31.081031795Z", "stop_time":"2024-02-28T08:18:35.421031795Z", "speaker_id": "Tommaso_Barbugli", "text": "how about you"}
{"type":"speech", "start_time": "2024-02-28T08:18:35.421031795Z", "stop_time":"2024-02-28T08:18:39.761031795Z", "speaker_id": "Sacha_Arbonel", "text": "I'm good too"}
{"type":"speech", "start_time": "2024-02-28T08:18:39.761031795Z", "stop_time":"2024-02-28T08:18:44.101031795Z", "speaker_id": "Tommaso_Barbugli", "text": "that's great"}
{"type":"speech", "start_time": "2024-02-28T08:18:44.101031795Z", "stop_time":"2024-02-28T08:18:48.441031795Z", "speaker_id": "Tommaso_Barbugli", "text": "I'm glad to hear that"}
User Permissions
The following permissions are available to grant/restrict access to this functionality when used client-side.

StartTranscription required to start the transcription
StopTranscription required to stop the transcription
ListTranscriptions required to retrieve the list of transcriptions
StartClosedCaptions required to start closed captions
StopClosedCaptions required to stop closed captions
Enabling, disabling, automatically start
Transcriptions and closed captions can be configured from the Dashboard (see the call type settings) or directly via the API. It is also possible to change the transcription settings for a call and override the default settings that come from its call type.


JavaScript

Python

Golang

cURL

// Disable on call level
call.update({
  settings_override: {
    transcription: {
      mode: "disabled",
      closed_caption_mode: "disabled",
    },
  },
});
// Disable on call type level
client.video.updateCallType({
  name: "<call type name>",
  settings: {
    transcription: {
      language: "en",
      mode: "disabled",
      closed_caption_mode: "disabled",
    },
  },
});
// Enable
call.update({
  settings_override: {
    transcription: {
      language: "en",
      mode: "available",
      closed_caption_mode: "available",
    },
  },
});
// Other settings
call.update({
  settings_override: {
    transcription: {
      language: "en",
      quality: "auto-on",
      closed_caption_mode: "auto-on",
    },
  },
});
Supported languages
English (en) - default
French (fr)
Spanish (es)
German (de)
Italian (it)
Dutch (nl)
Portuguese (pt)
Polish (pl)
Catalan (ca)
Czech (cs)
Danish (da)
Greek (el)
Finnish (fi)
Indonesian (id)
Japanese (ja)
Russian (ru)
Swedish (sv)
Tamil (ta)
Thai (th)
Turkish (tr)
Hungarian (hu)
Romanian (to)
Chinese (zh)
Arabic (ar)
Tagalog (tl)
Hebrew (he)
Hindi (hi)
Croatian (hr)
Korean (ko)
Malay (ms)
Norwegian (no)
Ukrainian (uk)


Storage
By default, transcriptions are stored in an AWS S3 bucket managed by Stream, located in the same region as your application. Transcription files are retained for two weeks before being automatically deleted. If you need to keep transcriptions longer or prefer not to store this data with Stream, you can opt to use your own storage solution.

Use your own storage
Stream supports the following external storage providers:

Amazon S3
Google Cloud Storage
Azure Blob Storage
If you need support for a different storage provider, you can participate in the conversation here.

To use your own storage you need to:

Configure a new external storage for your Stream application. Stream supports up to 10 storage configurations per application.
(Optional) Check storage configuration for correctness. Calling check endpoint will create a test markdown file in the storage to verify the configuration. It will return an error if the file is not created. In case of success, the file withstream-<uuid>.md will be uploaded to the storage. Every time you call this endpoint, a new file will be created.
Configure your call type(s) to use the new storage
Once the setup is complete, call recordings and transcription files will be automatically stored in your own storage.


JavaScript

Python

Golang

cURL

// 1. create a new storage with all the required parameters
await client.createExternalStorage({
  bucket: "my-bucket",
  name: "my-s3",
  storage_type: "s3",
  path: "directory_name/",
  aws_s3: {
    s3_region: "us-east-1",
    s3_api_key: "my-access-key",
    s3_secret: "my-secret",
  },
});
// 2. (Optional) Check storage configuration for correctness
// In case of any errors, this will throw a ResponseError.
await client.checkExternalStorage({
  name: "my-s3",
});
// 3. update the call type to use the new storage
await client.video.updateCallType({
  name: "my-call-type",
  external_storage: "my-s3",
});
Multiple storage providers and default storage
You can configure multiple storage providers for your application. Maximum of 10 storage providers can be configured. When starting a transcription or recording, you can specify which storage provider to use for that particular call. If none is specified, the default storage provider will be used.

When transcribing or recording a call, the storage provider is selected in this order:

If specified at the call level, the storage provider chosen for that particular call will be used.
If specified at the call type level, the storage provider designated for that call type will be used.
If neither applies, Stream S3 storage will be used.
Note: All Stream applications have Stream S3 storage enabled by default, which you can refer to as "stream-s3" in the configuration.


JavaScript

Python

Golang

cURL

// update the call type to use Stream S3 storage for recordings
await client.video.updateCallType({
  name: "my-call-type",
  external_storage: "stream-s3",
});
// specify my-storage storage when starting call transcribing
await call.startTranscription({
  transcription_external_storage: "my-storage",
});
// specify my-storage storage for recording
await call.startRecording({ recording_external_storage: "my-storage" });
Storage configuration
Request model
All storage providers have 4 shared parameters, other parameters are dependant on what kind of storage you want to create (below you can find examples for all supported storage types):

CreateExternalStorageRequest
Name	Type	Description	Constraints
aws_s3	S3Request	Only required if you want to create an Amazon S3 storage	-
azure_blob	AzureRequest	Only required if you want to create an Azure Blob Storage	-
bucket	string	The name of the bucket on the service provider	Required
gcs_credentials	string	-	-
name	string	The name of the provider, this must be unique	Required
path	string	The path prefix to use for storing files	-
storage_type	string (s3, gcs, abs)	The type of storage to use	Required
Amazon S3
Request model
This is how you can configure S3 stroage in the Stream API:

S3Request
Name	Type	Description	Constraints
s3_api_key	string	The AWS API key. To use Amazon S3 as your storage provider, you have two authentication options: IAM role or API key. If you do not specify the `s3_api_key` parameter, Stream will use IAM role authentication. In that case make sure to have the correct IAM role configured for your application.	-
s3_custom_endpoint_url	string	The custom endpoint for S3. If you want to use a custom endpoint, you must also provide the `s3_api_key` and `s3_secret` parameters.	-
s3_region	string	The AWS region where the bucket is hosted	Required
s3_secret	string	The AWS API Secret	-
Code example

JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  name: "my-s3",
  storage_type: "s3",
  bucket: "my-bucket",
  path: "directory_name/",
  aws_s3: {
    s3_api_key: "us-east-1",
    s3_region: "my-access-key",
    s3_secret: "my-secret",
  },
});
Example S3 policy
With this option you omit the key and secret, but instead you set up a resource-based policy to grant Stream SendMessage permission on your S3 bucket. The following policy needs to be attached to your queue (replace the value of Resource with the fully qualified ARN of you S3 bucket):


{
  "Version": "2012-10-17",
  "Id": "StreamExternalStoragePolicy",
  "Statement": [
    {
      "Sid": "ExampleStatement01",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::185583345998:root"
      },
      "Action": ["s3:PutObject"],
      "Resource": ["arn:aws:s3:::bucket_name/*", "arn:aws:s3:::bucket_name"]
    }
  ]
}
S3 Compatible Storage (Minio)
To use Minio or other S3 compatible storage you can specify custom endpoint. In this case API key and secret are required.


JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  name: "my-s3",
  storage_type: "s3",
  bucket: "my-bucket",
  path: "directory_name/",
  aws_s3: {
    s3_api_key: "us-east-1",
    s3_region: "my-access-key",
    s3_secret: "my-secret",
    s3_custom_endpoint_url: "https://s3.us-east-1.amazonaws.com",
  },
});
Google Cloud Storage
To use Google Cloud Storage as your storage provider, you need to send your service account credentials as they are stored in your JSON file. Stream only needs permission to write new files, it is not necessary to grant any other permission.

Note: We recommend reading the credentials from the file to avoid issues with copying and pasting errors.

Code example

JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  bucket: "my-bucket",
  name: "my-gcs",
  storage_type: "gcs",
  path: "directory_name/",
  gcs_credentials: "content of the service account file",
});
Example policy

{
  "bindings": [
    {
      "role": "roles/storage.objectCreator",
      "members": ["service_account_principal_identifier"]
    }
  ]
}
Azure Blob Storage
To use Azure Blob Storage as your storage provider, you need to create a container and a service principal with the following parameters:

Request model
AzureRequest
Name	Type	Description	Constraints
abs_account_name	string	The account name	Required
abs_client_id	string	The client id	Required
abs_client_secret	string	The client secret	Required
abs_tenant_id	string	The tenant id	Required
Stream only needs permission to write new files, it is not necessary to grant any other permission.

Code example

JavaScript

Python

Golang

cURL

await client.createExternalStorage({
  name: "my-abs",
  storage_type: "abs",
  bucket: "my-bucket",
  path: "directory_name/",
  azure_blob: {
    abs_account_name: "...",
    abs_client_id: "...",
    abs_client_secret: "...",
    abs_tenant_id: "...",
  },
});


Overview
Companies conducting business within the European Union are legally required to comply with the General Data Protection Regulation (GDPR).

While many aspects of this regulation may not significantly affect your integration with Stream, the GDPR provisions regarding the right to data access and the right to erasure are directly pertinent.

These provisions relate to data that is stored and managed on Stream's servers.

The Right to Access Data
GDPR gives EU citizens the right to request access to their information and the right to have access to this information in a portable format. Stream covers this requirement with the user export method.

This method can only be used with server-side authentication.

Check user export documentation to see how to use it.

The Right to Erasure
The GDPR also grants EU citizens the right to request the deletion of their personal information.

Stream offers mechanisms to delete users and calls in accordance with various use cases, ensuring compliance with these regulations.

Delete calls
Calls can be deleted in two different ways: "soft" or "hard", each with distinct implications.

Soft-delete: the call details and all related data remain stored on Stream's servers but will no longer be accessible via the API.
Hard-delete: all data is completely removed from Stream's servers, making it impossible to export.
Check calls deletion documentation for more information.

PDPB
The same API endpoints documented here can also be used to comply with India's Personal Data Protection Bill (PDPB) requirements.


Users
Users export
Stream allows you to export users with their data, including the calls they participated in.


JavaScript

Python

Golang

// request data export for multiple users at once
await client.exportUsers({ user_ids: ["<user id1>", "<user id1>"] });
Exporting users is an async operation, this is how you can check the progress and retrieve the result:


JavaScript

Python

Golang

Java

cURL

// Example of monitoring the status of an async task
// The logic is same for all async tasks
const response = await client.exportUsers({
  user_ids: ["<user id1>", "<user id1>"],
});
// you need to poll this endpoint
const taskResponse = await client.getTask({ id: response.task_id });
console.log(taskResponse.status === "completed");
For more information, please refer to the async operations guide.

Users deletion
Stream allows you to delete users and optionally the calls they were part of.
Note that this apply only to 1:1 calls, not group calls.


JavaScript

Python

Golang

Java

cURL

client.deleteUsers({ user_ids: ["<id>"] });
//restore
client.restoreUsers({ user_ids: ["<id>"] });
The delete users endpoints supports the following parameters to control which data needs to be deleted and how. By default users and their data are soft-deleted.

Name	Type	Description	Optional
user	Enum (soft, pruning, hard)	- Soft: marks user as deleted and retains all user data.
- Pruning: marks user as deleted and nullifies user information.
- Hard: deletes user completely - this requires hard option for messages and conversation as well.	Yes
conversations	Enum (soft, hard)	- Soft: marks all conversation channels as deleted (same effect as Delete Channels with 'hard' option disabled).
- Hard: deletes channel and all its data completely including messages (same effect as Delete Channels with 'hard' option enabled).	Yes
messages	Enum (soft, pruning, hard)	- Soft: marks all user messages as deleted without removing any related message data.
- Pruning: marks all user messages as deleted, nullifies message information and removes some message data such as reactions and flags.
- Hard: deletes messages completely with all related information.	Yes
new_channel_owner_id	string	Channels owned by hard-deleted users will be transferred to this userID. If you doesn't provide a value, the channel owner will have a system generated ID like delete-user-8219f6578a7395g	Yes
calls	Enum (soft, hard)	- Soft: marks calls and related data as deleted.
- Hard: deletes calls and related data completely
Note that this applies only to 1:1 calls, not group calls	Yes
Deleting users is done asynchronously and and can take some time to complete. You can find more information on how to work with API endpoints performing async work in the async operations guide.



Calls
Calls deletion
You can either soft-delete or hard-delete a call and all its related data (members, sessions, recordings, transcriptions).

Soft delete
Soft-delete a call means that the call and all its related data will not be completely removed from our system but will no longer be accessible via the API.


JavaScript

cURL

// soft-delete a call
const resp = await call.delete({
  hard: false,
});
// resp.call contains call information
Hard delete
This endpoint requires a server-side authentication.

Hard-delete a call means that the call and all its related data will be completely wiped out from our system. This action is irrevocable, and the data cannot be recovered.

This operation is done asynchronously and you can use the returned task_id to monitor its progress.
See how to monitor an async task.


JavaScript

cURL

// hard-delete a call
const resp = await call.delete({
  hard: true,
});
// resp.call contains call information
// resp.task_id is the ID to be used for monitoring the task


Overview
You can configure your Stream app to receive webhook events as well as AWS SNS and AWS SQS. Webhooks are usually the simplest way to receive events from your app and to perform additional action based on what happens to your application.

The configuration can be done using the API or from the Dashboard. By default, all events are sent to your webhook/sqs/sns endpoint, you can also configure the events you want to receive in the dashboard.

Some important points to consider:

The selection of events you want to receive applies to all the endpoints you have configured.
You can configure multiple endpoints for the same app (eg. AWS SNS and HTTP Webhook).
If your app is configured to receive all events, you can still filter the events you want to receive in your webhook handler.
If your app is configured to receive all events, newly introduced event types will be sent to your webhook handler by default.
If you pick specific events, newly introduced event types will not be sent to your webhook handler by default (you can still manually add them later on).
How to implement a webhook handler
Your webhook handler needs to follow these rules:

accept HTTP POST requests with JSON payload
be reachable from the public internet. Tunneling services like Ngrok are supported
respond with response codes from 200 to 299 as fast as possible
Your webhook handler can use the type field to handle events based correctly based on their type and payload.

All webhook requests contain these headers:

Name	Description
X-WEBHOOK-ID	Unique ID of the webhook call. This value is consistent between retries and could be used to deduplicate retry calls
X-WEBHOOK-ATTEMPT	Number of webhook request attempt starting from 1
X-API-KEY	Your application’s API key. Should be used to validate request signature
X-SIGNATURE	HMAC signature of the request body. See Signature section
Best Practices
We highly recommend following common security guidelines to make your webhook integration safe and fast:

Use HTTPS with a certificate from a trusted authority
Verify the "X-Signature" header to ensure the request is coming from Stream
Support HTTP Keep-Alive
Use a highly available infrastructure such as AWS Elastic Load Balancer, Google Cloud Load Balancer, or similar
Offload the processing of the message if possible (read, store, and forget)
When decoding JSON into objects, ensure that your webhook can handle new fields being added to the JSON payload as well as new event types (eg. log unknown fields and event types instead of failing)
Error Handling
In case of the request failure Stream Chat attempts to retry a request. The amount of maximum attempts depends on the kind of the error it receives:

Response code is 408, 429 or >=500: 3 attempts
Network error: 2 attempts
Request timeout: 3 attempts
The timeout of one request is 6 seconds, and the request with all retries cannot exceed the duration of 15 seconds.


Events
Here you can find the list of call events dispatched by the Stream Video API.

Event types
client-side events
These are delivered to client connections using WebSocket, for more information on how to handle them, please visit the SDK specific documentations.

server-side events
You can configure your Stream app to receive webhook events as well as AWS SNS and AWS SQS. Webhooks are usually the simplest way to receive events from your app and to perform additional action based on what happens to your application. For more information on configuration, please visit the Overview and SQS and SNS pages.

Event groups
Call events
Name	Description	Availability
call.blocked_user	This event is sent to call participants to notify when a user is blocked on a call, clients can use this event to show a notification. If the user is the current user, the client should leave the call screen as well	client-side, server-side
call.created	This event is sent when a call is created. Clients receiving this event should check if the ringing field is set to true and if so, show the call screen	client-side, server-side
call.deleted	This event is sent when a call is deleted. Clients receiving this event should leave the call screen	client-side, server-side
call.ended	This event is sent when a call is mark as ended for all its participants. Clients receiving this event should leave the call screen	client-side, server-side
call.kicked_user	This event is sent to call participants to notify when a user is kicked from a call. Clients should make the kicked user leave the call UI.	client-side, server-side
call.member_added	This event is sent when one or more members are added to a call	client-side, server-side
call.member_removed	This event is sent when one or more members are removed from a call	client-side, server-side
call.member_updated	This event is sent when one or more members are updated	client-side, server-side
call.member_updated_permission	This event is sent when one or more members get its role updated	client-side, server-side
call.moderation_blur	This event is sent when a moderation blur action is applied to a user's video stream	client-side, server-side
call.moderation_warning	This event is sent when a moderation warning is issued to a user	client-side, server-side
call.permission_request	This event is sent when a user requests access to a feature on a call, clients receiving this event should display a permission request to the user	client-side, server-side
call.permissions_updated	This event is sent to notify about permission changes for a user, clients receiving this event should update their UI accordingly	client-side, server-side
call.reaction_new	This event is sent when a reaction is sent in a call, clients should use this to show the reaction in the call screen	client-side, server-side
call.unblocked_user	This event is sent when a user is unblocked on a call, this can be useful to notify the user that they can now join the call again	client-side, server-side
call.updated	This event is sent when a call is updated, clients should use this update the local state of the call. This event also contains the capabilities by role for the call, clients should update the own_capability for the current.	client-side, server-side
call.user_muted	This event is sent when a call member is muted	client-side, server-side
ingress.error	This event is sent when a critical error occurs that breaks the streaming pipeline	client-side, server-side
ingress.started	This event is sent when a user begins streaming into a call	client-side, server-side
ingress.stopped	This event is sent when streaming stops due to user action or call ended	client-side, server-side
Session events
Name	Description	Availability
call.session_ended	This event is sent when a call session ends	client-side, server-side
call.session_participant_count_updated	This event is sent when the participant counts in a call session are updated	client-side, server-side
call.session_participant_joined	This event is sent when a participant joins a call session	client-side, server-side
call.session_participant_left	This event is sent when a participant leaves a call session	client-side, server-side
call.session_started	This event is sent when a call session starts	client-side, server-side
Ring events
Name	Description	Availability
call.accepted	This event is sent when a user accepts a notification to join a call.	client-side, server-side
call.missed	This event is sent to call members who did not accept/reject/join the call to notify they missed the call	client-side, server-side
call.notification	This event is sent to all call members to notify they are getting called	client-side, server-side
call.rejected	This event is sent when a user rejects a notification to join a call.	client-side, server-side
call.ring	This event is sent to all call members to notify they are getting called	client-side, server-side
Streaming events
Name	Description	Availability
call.hls_broadcasting_failed	This event is sent when HLS broadcasting has failed	client-side, server-side
call.hls_broadcasting_started	This event is sent when HLS broadcasting has started	client-side, server-side
call.hls_broadcasting_stopped	This event is sent when HLS broadcasting has stopped	client-side, server-side
call.live_started	This event is sent when a call is started. Clients receiving this event should start the call.	client-side, server-side
call.rtmp_broadcast_failed	This event is sent when a call RTMP broadcast has failed	client-side, server-side
call.rtmp_broadcast_started	This event is sent when RTMP broadcast has started	client-side, server-side
call.rtmp_broadcast_stopped	This event is sent when RTMP broadcast has stopped	client-side, server-side
Recording events
Name	Description	Availability
call.frame_recording_failed	This event is sent when frame recording has failed	client-side, server-side
call.frame_recording_ready	This event is sent when a frame is captured from a call	client-side, server-side
call.frame_recording_started	This event is sent when frame recording has started	client-side, server-side
call.frame_recording_stopped	This event is sent when frame recording has stopped	client-side, server-side
call.recording_failed	This event is sent when call recording has failed	client-side, server-side
call.recording_ready	This event is sent when call recording is ready	client-side, server-side
call.recording_started	This event is sent when call recording has started	client-side, server-side
call.recording_stopped	This event is sent when call recording has stopped	client-side, server-side
Transcription and closed caption events
Name	Description	Availability
call.closed_caption	This event is sent when closed captions are being sent in a call, clients should use this to show the closed captions in the call screen	client-side, server-side
call.closed_captions_failed	This event is sent when call closed captions has failed	client-side, server-side
call.closed_captions_started	This event is sent when call closed caption has started	client-side, server-side
call.closed_captions_stopped	This event is sent when call closed captions has stopped	client-side, server-side
call.transcription_failed	This event is sent when call transcription has failed	client-side, server-side
call.transcription_ready	This event is sent when call transcription is ready	client-side, server-side
call.transcription_started	This event is sent when call transcription has started	client-side, server-side
call.transcription_stopped	This event is sent when call transcription has stopped	client-side, server-side
Other events
Name	Description	Availability
call.stats_report_ready	This event is sent when the insights report is ready	client-side, server-side
call.user_feedback_submitted	This event is sent when a user submits feedback for a call.	client-side, server-side
custom	A custom event, this event is used to send custom events to other participants in the call.	client-side, server-side
Event model defintions
BlockedUserEvent
Name	Type	Description	Constraints
blocked_by_user	UserResponse	The user that blocked the user, null if the user was blocked by server-side	-
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.blocked_user" in this case	Required
user	UserResponse	The user that was blocked	Required
CallAcceptedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.accepted" in this case	Required
user	UserResponse	The user who accepted the call	Required
CallClosedCaptionsFailedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.closed_captions_failed" in this case	Required
CallClosedCaptionsStartedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.closed_captions_started" in this case	Required
CallClosedCaptionsStoppedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.transcription_stopped" in this case	Required
CallCreatedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	MemberResponse[]	the members added to this call	Required
type	string	The type of event: "call.created" in this case	Required
CallDeletedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.deleted" in this case	Required
CallEndedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
reason	string	The reason why the call ended, if available	-
type	string	The type of event: "call.ended" in this case	Required
user	UserResponse	The user who ended the call, null if the call was ended by the server	-
CallFrameRecordingFailedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
type	string	The type of event: "call.frame_recording_failed" in this case	Required
CallFrameRecordingFrameReadyEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
captured_at	string	The time the frame was captured	Required
created_at	string	-	Required
egress_id	string	-	Required
session_id	string	Call session ID	Required
track_type	string	The type of the track frame was captured from (TRACK_TYPE_VIDEO|TRACK_TYPE_SCREEN_SHARE)	Required
type	string	The type of event: "call.frame_recording_ready" in this case	Required
url	string	The URL of the frame	Required
users	object	The users in the frame	Required
CallFrameRecordingStartedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
type	string	The type of event: "call.frame_recording_started" in this case	Required
CallFrameRecordingStoppedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
type	string	The type of event: "call.frame_recording_stopped" in this case	Required
CallHLSBroadcastingFailedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.hls_broadcasting_failed" in this case	Required
CallHLSBroadcastingStartedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
hls_playlist_url	string	-	Required
type	string	The type of event: "call.hls_broadcasting_started" in this case	Required
CallHLSBroadcastingStoppedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.hls_broadcasting_stopped" in this case	Required
CallLiveStartedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.live_started" in this case	Required
CallMemberAddedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	MemberResponse[]	the members added to this call	Required
type	string	The type of event: "call.member_added" in this case	Required
CallMemberRemovedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	string[]	the list of member IDs removed from the call	Required
type	string	The type of event: "call.member_removed" in this case	Required
CallMemberUpdatedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	MemberResponse[]	The list of members that were updated	Required
type	string	The type of event: "call.member_updated" in this case	Required
CallMemberUpdatedPermissionEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
capabilities_by_role	object	The capabilities by role for this call	Required
created_at	string	-	Required
members	MemberResponse[]	The list of members that were updated	Required
type	string	The type of event: "call.member_added" in this case	Required
CallMissedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	MemberResponse[]	List of members who missed the call	Required
notify_user	boolean	-	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.notification" in this case	Required
user	UserResponse	The caller from whom the call was missed	Required
CallModerationBlurEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
custom	object	Custom data associated with the moderation action	Required
type	string	The type of event: "call.moderation_blur" in this case	Required
user_id	string	The user ID whose video stream is being blurred	Required
CallModerationWarningEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
custom	object	Custom data associated with the moderation action	Required
message	string	The warning message	Required
type	string	The type of event: "call.moderation_warning" in this case	Required
user_id	string	The user ID who is receiving the warning	Required
CallNotificationEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	MemberResponse[]	Call members	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.notification" in this case	Required
user	UserResponse	The user that sent the call notification	Required
CallReactionEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
reaction	ReactionResponse	the reaction object sent by the user on the call	Required
type	string	The type of event: "call.reaction_new" in this case	Required
CallRecordingFailedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
recording_type	string (composite, individual, raw)	The type of recording	Required
type	string	The type of event: "call.recording_failed" in this case	Required
CallRecordingReadyEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
call_recording	CallRecording	The call recording object	Required
created_at	string	-	Required
egress_id	string	-	Required
recording_type	string (composite, individual, raw)	The type of recording	Required
type	string	The type of event: "call.recording_ready" in this case	Required
CallRecordingStartedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
recording_type	string (composite, individual, raw)	The type of recording	Required
type	string	The type of event: "call.recording_started" in this case	Required
CallRecordingStoppedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
recording_type	string (composite, individual, raw)	The type of recording	Required
type	string	The type of event: "call.recording_stopped" in this case	Required
CallRejectedEvent
Name	Type	Description	Constraints
call	CallResponse	-	Required
call_cid	string	-	Required
created_at	string	-	Required
reason	string	Provides information about why the call was rejected. You can provide any value, but the Stream API and SDKs use these default values: rejected, cancel, timeout and busy	-
type	string	The type of event: "call.rejected" in this case	Required
user	UserResponse	The user who rejected the call	Required
CallRingEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
members	MemberResponse[]	Call members	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.notification" in this case	Required
user	UserResponse	The user that sent the call notification	Required
video	boolean	-	Required
CallRtmpBroadcastFailedEvent
Name	Type	Description	Constraints
call_cid	string	The unique identifier for a call (<type>:<id>)	Required
created_at	string	Date/time of creation	Required
name	string	Name of the given RTMP broadcast	Required
type	string	The type of event: "call.rtmp_broadcast_failed" in this case	Required
CallRtmpBroadcastStartedEvent
Name	Type	Description	Constraints
call_cid	string	The unique identifier for a call (<type>:<id>)	Required
created_at	string	Date/time of creation	Required
name	string	Name of the given RTMP broadcast	Required
type	string	The type of event: "call.rtmp_broadcast_started" in this case	Required
CallRtmpBroadcastStoppedEvent
Name	Type	Description	Constraints
call_cid	string	The unique identifier for a call (<type>:<id>)	Required
created_at	string	Date/time of creation	Required
name	string	Name of the given RTMP broadcast	Required
type	string	The type of event: "call.rtmp_broadcast_stopped" in this case	Required
CallSessionEndedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.session_ended" in this case	Required
CallSessionParticipantCountsUpdatedEvent
Name	Type	Description	Constraints
anonymous_participant_count	integer	-	Required
call_cid	string	-	Required
created_at	string	-	Required
participants_count_by_role	object	-	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.session_participant_count_updated" in this case	Required
CallSessionParticipantJoinedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
participant	CallParticipantResponse	The participant that joined the session	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.session_participant_joined" in this case	Required
CallSessionParticipantLeftEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
duration_seconds	integer	The duration participant was in the session in seconds	Required
participant	CallParticipantResponse	The participant that left the session	Required
reason	string	The reason why the participant left the session	-
session_id	string	Call session ID	Required
type	string	The type of event: "call.session_participant_left" in this case	Required
CallSessionStartedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
created_at	string	-	Required
session_id	string	Call session ID	Required
type	string	The type of event: "call.session_started" in this case	Required
CallStatsReportReadyEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
session_id	string	Call session ID	Required
type	string	The type of event, "call.report_ready" in this case	Required
CallTranscriptionFailedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
error	string	The error message detailing why transcription failed.	-
type	string	The type of event: "call.transcription_failed" in this case	Required
CallTranscriptionReadyEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
call_transcription	CallTranscription	The call transcription object	Required
created_at	string	-	Required
egress_id	string	-	Required
type	string	The type of event: "call.transcription_ready" in this case	Required
CallTranscriptionStartedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
type	string	The type of event: "call.transcription_started" in this case	Required
CallTranscriptionStoppedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
egress_id	string	-	Required
type	string	The type of event: "call.transcription_stopped" in this case	Required
CallUpdatedEvent
Name	Type	Description	Constraints
call	CallResponse	Call object	Required
call_cid	string	-	Required
capabilities_by_role	object	The capabilities by role for this call	Required
created_at	string	-	Required
type	string	The type of event: "call.updated" in this case	Required
CallUserFeedbackSubmittedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
custom	object	Custom data provided by the user	-
rating	integer	The rating given by the user (1-5)	Required
reason	string	The reason provided by the user for the rating	-
sdk	string	-	-
sdk_version	string	-	-
session_id	string	Call session ID	Required
type	string	The type of event, "call.user_feedback" in this case	Required
user	UserResponse	The user who submitted the feedback	Required
CallUserMutedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
from_user_id	string	-	Required
muted_user_ids	string[]	-	Required
reason	string	-	Required
type	string	The type of event: "call.user_muted" in this case	Required
ClosedCaptionEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
closed_caption	CallClosedCaption	The closed caption object	Required
created_at	string	-	Required
type	string	The type of event: "call.closed_caption" in this case	Required
CustomVideoEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
custom	object	Custom data for this object	Required
type	string	The type of event, "custom" in this case	Required
user	UserResponse	-	Required
IngressErrorEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
code	string	Error code	-
created_at	string	-	Required
error	string	Human-readable error message	Required
ingress_stream_id	string	Unique identifier for the stream	Required
type	string	The type of event: "ingress.error" in this case	Required
user_id	string	User who was streaming	Required
IngressStartedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
client_ip	string	Client IP address	-
client_name	string	Streaming client software name (e.g., 'OBS Studio')	-
created_at	string	-	Required
ingress_stream_id	string	Unique identifier for this stream	Required
publisher_type	string	Streaming protocol (e.g., 'rtmps', 'srt', 'rtmp', 'rtsp')	Required
type	string	The type of event: "ingress.started" in this case	Required
user_id	string	User who started the stream	Required
version	string	Client software version	-
IngressStoppedEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
ingress_stream_id	string	Unique identifier for the stream	Required
type	string	The type of event: "ingress.stopped" in this case	Required
user_id	string	User who was streaming	Required
KickedUserEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
kicked_by_user	UserResponse	The user that kicked the participant, null if server-side	-
type	string	The type of event: "call.kicked_user" in this case	Required
user	UserResponse	The user that was kicked	Required
PermissionRequestEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
permissions	string[]	The list of permissions requested by the user	Required
type	string	The type of event: "call.permission_request" in this case	Required
user	UserResponse	The user who sent the permission request	Required
UnblockedUserEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
type	string	The type of event: "call.unblocked_user" in this case	Required
user	UserResponse	The user that was unblocked	Required
UpdatedCallPermissionsEvent
Name	Type	Description	Constraints
call_cid	string	-	Required
created_at	string	-	Required
own_capabilities	OwnCapability[]	The capabilities of the current user	Required
type	string	The type of event: "call.permissions_updated" in this case	Required
user	UserResponse	The user who received the new permissions	Required
AudioSettingsResponse
Name	Type	Description	Constraints
access_request_enabled	boolean	-	Required
default_device	string (speaker, earpiece)	-	Required
hifi_audio_enabled	boolean	-	Required
mic_default_on	boolean	-	Required
noise_cancellation	NoiseCancellationSettings	-	-
opus_dtx_enabled	boolean	-	Required
redundant_coding_enabled	boolean	-	Required
speaker_default_on	boolean	-	Required
BackstageSettingsResponse
Name	Type	Description	Constraints
enabled	boolean	-	Required
join_ahead_time_seconds	integer	-	-
BroadcastSettingsResponse
Name	Type	Description	Constraints
enabled	boolean	-	Required
hls	HLSSettingsResponse	-	Required
rtmp	RTMPSettingsResponse	-	Required
CallClosedCaption
Name	Type	Description	Constraints
end_time	string	-	Required
id	string	-	Required
language	string	-	Required
service	string	-	-
speaker_id	string	-	Required
start_time	string	-	Required
text	string	-	Required
translated	boolean	-	Required
user	UserResponse	-	Required
CallIngressResponse
Name	Type	Description	Constraints
rtmp	RTMPIngress	-	Required
srt	SRTIngress	-	Required
whip	WHIPIngress	-	Required
CallParticipantResponse
Name	Type	Description	Constraints
joined_at	string	-	Required
role	string	-	Required
user	UserResponse	-	Required
user_session_id	string	-	Required
CallRecording
Name	Type	Description	Constraints
end_time	string	-	Required
filename	string	-	Required
recording_type	string	-	Required
session_id	string	-	Required
start_time	string	-	Required
url	string	-	Required
CallResponse
Name	Type	Description	Constraints
backstage	boolean	-	Required
blocked_user_ids	string[]	-	Required
captioning	boolean	-	Required
channel_cid	string	-	-
cid	string	The unique identifier for a call (<type>:<id>)	Required
created_at	string	Date/time of creation	Required
created_by	UserResponse	The user that created the call	Required
current_session_id	string	-	Required
custom	object	Custom data for this object	Required
egress	EgressResponse	-	Required
ended_at	string	Date/time when the call ended	-
id	string	Call ID	Required
ingress	CallIngressResponse	-	Required
join_ahead_time_seconds	integer	-	-
recording	boolean	-	Required
routing_number	string	10-digit routing number for SIP routing	-
session	CallSessionResponse	-	-
settings	CallSettingsResponse	-	Required
starts_at	string	Date/time when the call will start	-
team	string	-	-
thumbnails	ThumbnailResponse	-	-
transcribing	boolean	-	Required
translating	boolean	-	Required
type	string	The type of call	Required
updated_at	string	Date/time of the last update	Required
CallSessionResponse
Name	Type	Description	Constraints
accepted_by	object	-	Required
anonymous_participant_count	integer	-	Required
ended_at	string	-	-
id	string	-	Required
live_ended_at	string	-	-
live_started_at	string	-	-
missed_by	object	-	Required
participants	CallParticipantResponse[]	-	Required
participants_count_by_role	object	-	Required
rejected_by	object	-	Required
started_at	string	-	-
timer_ends_at	string	-	-
CallSettingsResponse
Name	Type	Description	Constraints
audio	AudioSettingsResponse	-	Required
backstage	BackstageSettingsResponse	-	Required
broadcasting	BroadcastSettingsResponse	-	Required
frame_recording	FrameRecordingSettingsResponse	-	Required
geofencing	GeofenceSettingsResponse	-	Required
individual_recording	IndividualRecordingSettingsResponse	-	Required
ingress	IngressSettingsResponse	-	-
limits	LimitsSettingsResponse	-	Required
raw_recording	RawRecordingSettingsResponse	-	Required
recording	RecordSettingsResponse	-	Required
ring	RingSettingsResponse	-	Required
screensharing	ScreensharingSettingsResponse	-	Required
session	SessionSettingsResponse	-	Required
thumbnails	ThumbnailsSettingsResponse	-	Required
transcription	TranscriptionSettingsResponse	-	Required
video	VideoSettingsResponse	-	Required
CallTranscription
Name	Type	Description	Constraints
end_time	string	-	Required
filename	string	-	Required
session_id	string	-	Required
start_time	string	-	Required
url	string	-	Required
CompositeRecordingResponse
Name	Type	Description	Constraints
status	string	-	Required
DeviceResponse
Name	Type	Description	Constraints
created_at	string	Date/time of creation	Required
disabled	boolean	Whether device is disabled or not	-
disabled_reason	string	Reason explaining why device had been disabled	-
id	string	Device ID	Required
push_provider	string	Push provider	Required
push_provider_name	string	Push provider name	-
user_id	string	User ID	Required
voip	boolean	When true the token is for Apple VoIP push notifications	-
EgressHLSResponse
Name	Type	Description	Constraints
playlist_url	string	-	Required
status	string	-	Required
EgressResponse
Name	Type	Description	Constraints
broadcasting	boolean	-	Required
composite_recording	CompositeRecordingResponse	-	-
frame_recording	FrameRecordingResponse	-	-
hls	EgressHLSResponse	-	-
individual_recording	IndividualRecordingResponse	-	-
raw_recording	RawRecordingResponse	-	-
rtmps	EgressRTMPResponse[]	-	Required
EgressRTMPResponse
Name	Type	Description	Constraints
name	string	-	Required
started_at	string	-	Required
stream_key	string	-	-
stream_url	string	-	-
FrameRecordingResponse
Name	Type	Description	Constraints
status	string	-	Required
FrameRecordingSettingsResponse
Name	Type	Description	Constraints
capture_interval_in_seconds	integer	-	Required, Minimum: 2, Maximum: 60
mode	string (available, disabled, auto-on)	-	Required
quality	string	-	-
GeofenceSettingsResponse
Name	Type	Description	Constraints
names	string[]	-	Required
HLSSettingsResponse
Name	Type	Description	Constraints
auto_on	boolean	-	Required
enabled	boolean	-	Required
layout	LayoutSettingsResponse	-	Required
quality_tracks	string[]	-	Required
IndividualRecordingResponse
Name	Type	Description	Constraints
status	string	-	Required
IndividualRecordingSettingsResponse
Name	Type	Description	Constraints
mode	string (available, disabled, auto-on)	-	Required
IngressAudioEncodingResponse
Name	Type	Description	Constraints
bitrate	integer	-	Required
channels	integer	-	Required
enable_dtx	boolean	-	Required
IngressSettingsResponse
Name	Type	Description	Constraints
audio_encoding_options	IngressAudioEncodingResponse	-	-
enabled	boolean	-	Required
video_encoding_options	object	-	-
LayoutSettingsResponse
Name	Type	Description	Constraints
detect_orientation	boolean	-	-
external_app_url	string	-	Required
external_css_url	string	-	Required
name	string (spotlight, grid, single-participant, mobile, custom)	-	Required
options	object	-	-
LimitsSettingsResponse
Name	Type	Description	Constraints
max_duration_seconds	integer	-	-
max_participants	integer	-	-
max_participants_exclude_owner	boolean	-	-
max_participants_exclude_roles	string[]	-	Required
MemberResponse
Name	Type	Description	Constraints
created_at	string	Date/time of creation	Required
custom	object	Custom member response data	Required
deleted_at	string	Date/time of deletion	-
role	string	-	-
updated_at	string	Date/time of the last update	Required
user	UserResponse	-	Required
user_id	string	-	Required
NoiseCancellationSettings
Name	Type	Description	Constraints
mode	string (available, disabled, auto-on)	-	Required
PushNotificationSettingsResponse
Name	Type	Description	Constraints
disabled	boolean	-	-
disabled_until	string	-	-
RawRecordingResponse
Name	Type	Description	Constraints
status	string	-	Required
RawRecordingSettingsResponse
Name	Type	Description	Constraints
mode	string (available, disabled, auto-on)	-	Required
ReactionResponse
Name	Type	Description	Constraints
custom	object	-	-
emoji_code	string	-	-
type	string	-	Required
user	UserResponse	-	Required
RecordSettingsResponse
Name	Type	Description	Constraints
audio_only	boolean	-	Required
layout	LayoutSettingsResponse	-	Required
mode	string	-	Required
quality	string	-	Required
RingSettingsResponse
Name	Type	Description	Constraints
auto_cancel_timeout_ms	integer	-	Required
incoming_call_timeout_ms	integer	-	Required
missed_call_timeout_ms	integer	-	Required
RTMPIngress
Name	Type	Description	Constraints
address	string	-	Required
RTMPSettingsResponse
Name	Type	Description	Constraints
enabled	boolean	-	Required
layout	LayoutSettingsResponse	-	Required
quality	string	-	Required
ScreensharingSettingsResponse
Name	Type	Description	Constraints
access_request_enabled	boolean	-	Required
enabled	boolean	-	Required
target_resolution	TargetResolution	-	-
SessionSettingsResponse
Name	Type	Description	Constraints
inactivity_timeout_seconds	integer	-	Required, Minimum: 5, Maximum: 900
SpeechSegmentConfig
Name	Type	Description	Constraints
max_speech_caption_ms	integer	-	-
silence_duration_ms	integer	-	-
SRTIngress
Name	Type	Description	Constraints
address	string	-	Required
TargetResolution
Name	Type	Description	Constraints
bitrate	integer	-	Maximum: 6000000
height	integer	-	Required, Minimum: 240, Maximum: 3840
width	integer	-	Required, Minimum: 240, Maximum: 3840
ThumbnailResponse
Name	Type	Description	Constraints
image_url	string	-	Required
ThumbnailsSettingsResponse
Name	Type	Description	Constraints
enabled	boolean	-	Required
TranscriptionSettingsResponse
Name	Type	Description	Constraints
closed_caption_mode	string (available, disabled, auto-on)	-	Required
language	string (auto, en, fr, es, de, it, nl, pt, pl, ca, cs, da, el, fi, id, ja, ru, sv, ta, th, tr, hu, ro, zh, ar, tl, he, hi, hr, ko, ms, no, uk, bg, et, sl, sk)	-	Required
mode	string (available, disabled, auto-on)	-	Required
speech_segment_config	SpeechSegmentConfig	-	-
translation	TranslationSettings	-	-
TranslationSettings
Name	Type	Description	Constraints
enabled	boolean	-	-
languages	string[]	-	-
UserResponse
Name	Type	Description	Constraints
avg_response_time	integer	-	-
ban_expires	string	Date when ban expires	-
blocked_user_ids	string[]	-	Required
created_at	string	Date/time of creation	Required
custom	object	Custom data for this object	Required
deactivated_at	string	Date of deactivation	-
deleted_at	string	Date/time of deletion	-
devices	DeviceResponse[]	List of devices user is using	-
id	string	Unique user identifier	Required
image	string	-	-
invisible	boolean	-	Required
language	string	Preferred language of a user	Required
last_active	string	Date of last activity	-
name	string	Optional name of user	-
privacy_settings	PrivacySettingsResponse	User privacy settings	-
push_notifications	PushNotificationSettingsResponse	User push notification settings	-
revoke_tokens_issued_before	string	Revocation date for tokens	-
role	string	Determines the set of user permissions	Required
shadow_banned	boolean	Whether a user is shadow banned	Required
teams	string[]	List of teams user is a part of	Required
teams_role	object	-	-
updated_at	string	Date/time of the last update	Required
VideoSettingsResponse
Name	Type	Description	Constraints
access_request_enabled	boolean	-	Required
camera_default_on	boolean	-	Required
camera_facing	string (front, back, external)	-	Required
enabled	boolean	-	Required
target_resolution	TargetResolution	-	Required
WHIPIngress
Name	Type	Description	Constraints
address	string	URL for a new whip input, every time a new link is created	Required
Did you find this page helpful?




SQS and SNS
You can have events shipped to an AWS SNS topic or to an AWS SQS queue if you want. Same as webhook, this can be configured directly from the Dashboard.

Authentication
There are 2 ways to configure authentication for SQS and SNS:

Grant Stream's AWS account permission to use your SQS/SNS resources. (recommended)
Provide your AWS key and secret in the Stream Dashboard.
Role based policy example (SQS)
If you decide to use the first approach, you need to attach a policy to your SQS like this one:


{
  "Sid": "AllowStreamProdAccount",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::185583345998:root"
  },
  "Action": "SQS:SendMessage",
  "Resource": "arn:aws:sqs:us-west-2:1111111111:customer-sqs-for-stream"
}
Role based policy example (SNS)
If you decide to use the first approach, you need to attach a policy to your SQS like this one:


{
  "Sid": "AllowStreamProdAccount",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::185583345998:root"
  },
  "Action": "SNS:Publish",
  "Resource": "arn:aws:sns:us-west-2:1111111111:customer-sns-topic"
}
SQS Best Practices
Set the maximum message size set to 256 KB
Set up a dead-letter queue for your main queue
Setup alerts in case the size of the queue is growing too fast



Asynchronous operations
Certain operations, such as deleting a call or deleting a user, require additional time and processing power. As a result, these operations are executed asynchronously.

These tasks will return a task_id in the API response, you can use this id to monitor the task status.

Monitoring tasks
You can monitor these tasks using the GetTask endpoint. Calling this endpoint will provide information such as:

status: Current status of the task (see statuses below for more details)
result: Result of the task, depending on the nature of the task
error: If the task failed, this will contain information about the failure
Task Statuses
The task can have the following statuses:

pending: Task is pending and not running yet
running: Task is running and not completed yet
completed: Task is completed and successfully executed
failed: Task failed during its execution
Example
Asynchronous operations will return an ID, which you can use to monitor the task. Here's an example:


JavaScript

Python

Golang

Java

cURL

// Example of monitoring the status of an async task
// The logic is same for all async tasks
const response = await client.exportUsers({
  user_ids: ["<user id1>", "<user id1>"],
});
// you need to poll this endpoint
const taskResponse = await client.getTask({ id: response.task_id });
console.log(taskResponse.status === "completed");



Rate limits
Stream enforces rate limits to ensure the stability of our service for our customers and to encourage a performant integration. Stream powers user interactions for some of the world's largest apps and has scaling infrastructure to accommodate. Rate limits can be increased at customers’ requests and by upgrading to larger usage plans.

Our default rate limits are below. Rate limits are higher for Enterprise plans depending on capacity and use case. Talk to your Customer Success Manager for increases.

Every Application has rate limits applied based on a combination of API endpoint and platform: these limits are set on a 1-minute time window. For example, creating a call has a different limit than querying calls. Likewise, different platforms such as iOS, Android or your server-side infrastructure have independent counters for each API endpoint's rate limit.

Types of rate limits
There are two kinds of rate limits:

User Rate Limits: Apply to each user and platform combination and help to prevent a single user from consuming your Application rate limits.
App rate limits: App rate limits are calculated per endpoint and platform combination for your application.
User Rate Limits
To avoid individual users consuming your entire quota, every single user is limited to at most 60 requests per minute (per API endpoint and platform). When the limit is exceeded, requests from that user and platform will be rejected.

App Rate Limits
Stream supports four different platforms via our official SDKs:

Server: SDKs that execute on the server including Node, Python, Ruby, Go, C#, PHP, and Java.
Android: SDKs that execute on an Android device including Kotlin, Java, Flutter, and React Native for Android clients.
iOS: SDKs that execute on an iOS device including Swift, Flutter, and React Native for iOS clients.
Web: SDKs that execute in a browser including React, Angular, or vanilla JavaScript clients.
Rate limits quotas are not shared across different platforms. This way if by accident a server-side script hits a rate limit, you will not have any impact on your mobile and web applications. When the limit is hit, all calls from the same app, platform, and endpoint will result in an error with a 429 HTTP status code.

App rate limits are administered both per minute and per second. The per-second limit is equal to the per-minute limit divided by 30 to allow for bursts.

Default rate limits by endpoint
API Endpoint	Rate limit per minute
AcceptCall	1000
BlockUser	1000
CheckExternalStorage	300
CollectUserFeedback	1000
CreateCallType	300
CreateDevice	300
CreateExternalStorage	300
CreateGuest	1000
DeleteCall	60
DeleteCallType	300
DeleteDevice	60
DeleteExternalStorage	300
DeleteRecording	1000
DeleteTranscription	1000
EndCall	1000
GetCall	1000
GetCallStats	60
GetCallType	300
GetEdges	300
GetOrCreateCall	1000
GoLive	300
JoinCall	1000
ListCallTypes	300
ListDevices	60
ListExternalStorage	300
ListRecordings	1000
ListTranscriptions	1000
MuteUsers	1000
QueryAggregateCallStats	60
QueryCallStats	60
QueryCalls	1000
QueryUserFeedback	60
QueryMembers	300
RejectCall	1000
RequestPermission	1000
SendEvent	10000
SendVideoReaction	1000
StartClosedCaptions	300
StartHLSBroadcasting	1000
StartRTMPBroadcasts	1000
StartRecording	300
StartTranscription	300
StopAllRTMPBroadcasts	1000
StopClosedCaptions	300
StopHLSBroadcasting	1000
StopLive	300
StopRTMPBroadcast	1000
StopRecording	300
StopTranscription	300
UnblockUser	1000
UpdateCall	1000
UpdateCallMembers	1000
UpdateCallType	300
UpdateExternalStorage	300
UpdateUserPermissions	1000
VideoConnect	10000
VideoPin	1000
VideoUnpin	1000
What To Do When You've Hit a Rate Limit
You should always review responses from Stream to watch for error conditions. If you receive 429 status, this means your API request was rate-limited and you will need to retry. We recommend implementing an exponential back-off retry mechanism.

Here are a few things to keep in mind to avoid rate limits on server-side:

Slow down your scripts: This is the most common cause of rate limits. You're running a cronjob or script that runs many API calls in succession. Adding a small timeout in between API calls typically solves the issue.

Use batch endpoints: Batch update endpoints exist for many operations. So instead of doing 100 calls to update 1 user each, call the batch endpoint for updating many users.

Query only when needed: Sometimes apps will call a query endpoint to see if an entity exists before creating it. Many of Stream's endpoints have an upsert behaviour, so this isn't necessary in most cases.

If rate limits are still a problem, Stream can set higher limits for certain pricing plans:

For Standard plans, Stream may also raise rate limits in certain instances, an integration review is required to ensure your integration is making optimal use of the default rate limits before any increase will be applied.
For Enterprise plans, Stream will review your architecture, and set higher rate limits for your production application.
Rate limit headers
Header	Description
X-RateLimit-Limit	the total limit allowed for the resource requested (i.e. 5000)
X-RateLimit-Remaining	the remaining limit (i.e. 4999)
X-RateLimit-Reset	when the current limit will reset (Unix timestamp)
This is how you can access rate limit information on server-side SDKs:


JavaScript

const response = client.....;
const rateLimit = response.metadata.rateLimit;
// the total limit allowed for the resource requested
console.log(rateLimit.rateLimit);
// the remaining limit
console.log(rateLimit.rateLimitRemaining);
// when the current limit will reset - Date
console.log(rateLimit.rateLimitReset);
// or
try {
    client....
} catch (error) {
    const rateLimit = response.metadata.rateLimit;
    if (error.metadata.responseCode === 429) {
        // Wait until rate limit resets and then retry
    }
}
Inspecting rate limits
Stream offers the ability to inspect an App's current rate limit quotas and usage in your App's dashboard. Alternatively you can also retrieve the API Limits for your application using the API directly.


JavaScript

cURL

// 1. Get Rate limits, server-side platform
limits = await client.getRateLimits({ server_side: true });
// 2. Get Rate limits, all platforms
limits = await client.getRateLimits();
// 3. Get Rate limits, iOS and Android
limits = await client.getRateLimits({ ios: true, android: true });
// 4. Get Rate limits for specific endpoints
limits = await client.getRateLimits({
  endpoints: "QueryCalls,GetOrCreateCall",
});



UI Components Overview
Introduction
The Stream Video Flutter SDK provides UI components to facilitate the quick integration of voice, video, and streaming use cases in your applications.

As a developer building with Stream, you can either use our out-of-the-box solution, inclusive of theming, views, and state handling, or completely build your own UI while reusing our lower-level components where you see fit.

Component Overview
Name	ClassName	Overview
Video Renderer	StreamVideoRenderer	Widget that renders a single video track for a call participant. StreamVideoRenderer exposes callbacks for handling size changes, video fit types, and more!
Call Container	StreamCallContainer	Call Container automatically subscribes to call events and displays the appropriate UI based on the various call states. For example, Call Container will automatically display an incoming call screen when a ringing call is detected and update the UI to display the call contents if the user chooses to answer.
Incoming Call	StreamIncomingCallContent	Displays a ringing interface to the current user when an incoming call is detected.
Outgoing Call	StreamOutgoingCallContent	Represents the UI of a call when the current user rings another user.
Call Content	StreamCallContent	Represents the UI of an active call. This Widget displays the participants, controls, and call app bar by default.
Call Controls	StreamCallControls	These represent a set of options the user can interact with to control various aspects of the call such as toggling the microphone, camera, etc. For convenience, we provide a withDefaultOptions constructor.
Call Participants	StreamCallParticipants	StreamCallParticipants renders the participants on a call and adjusts itself based on the number of participants, screen-sharing, grid type, etc.
Lobby View	StreamLobbyView	A widget that can be shown before a user joins a meeting or call. It allows the user to configure their microphone, camera, and output device state before joining a call.
These are just a few of our offered components. Each component has many lower-level widgets which can be used independently to create custom UIs and experiences for your application.

Please continue reading on or select a component directly to learn more about how it can be used and customized to fit the needs of your application.

If there is a widget or component you would like to see added to the library, please feel free to contact us, we are always open to feedback and constantly looking to add more widgets.




Call Container
Similar to Flutter’s out-of-the-box Container widget, StreamCallContainer serves as a convenient widget for handling everything related to video and calling. It is the easiest way to setup a screen that shows incoming, outgoing and active call screens which contain the current participants video feeds and the call controls.

CallContainer sets up the following functionality by connecting multiple components:

StreamOutgoingCallContent: When the user is calling other people. Shows other participants avatars and controls for switching audio/video and canceling the call.
StreamIncomingCallContent: When the user is being called by another person. Shows the incoming call screen.
StreamCallContent: When the user is in an active call.
In this section we will cover this higher level component which enables you to quickly implement a video calling app.

At its simplest, you only need to provide a Call object to the StreamCallContainer widget:


import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
// Example method called to create a new call
Future<void> startCall() {
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.defaultType(),
      id: {CALL_ID},
    );
    final result = await call.getOrCreate();
    result.fold(
      success: (success) {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyCallScreen(call)),
            );
        }
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.error.message}'),
          ),
        );
      },
    );
}
class MyCallScreen extends StatelessWidget {
    const MyCallScreen(this.call, {super.key});
    final Call call;
    @override
    Widget build(BuildContext context) {
        return StreamCallContainer(
            call: call,
        );
    }
}
Preview of Call Container
Customizing Call Container

const StreamCallContainer({
  super.key,
  required this.call,
  this.callConnectOptions,
  this.onBackPressed,
  this.onLeaveCallTap,
  this.onAcceptCallTap,
  this.onDeclineCallTap,
  this.onCancelCallTap,
  this.incomingCallWidgetBuilder,
  this.outgoingCallWidgetBuilder,
  this.callContentWidgetBuilder,
  this.pictureInPictureConfiguration = const PictureInPictureConfiguration(),
});
Developers can easily respond to user actions, such as accepting or declining a call, by using exposed callbacks and builders.

To replace default screens, such as the one displayed when an incoming call is detected, developers can use one of the many optional builders available.


@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: widget.call,
        incomingCallWidgetBuilder: (context, call) {
          return CustomIncomingCallScreen(call: call);
        },
      ),
    );
  }
All the builders exposed by StreamCallContainer provide users with an ongoing Call object. This can be used to subscribe to changes and display different UI options depending on the events.

If your use case does not require ringing, incoming, or outgoing capabilities similar to Google Meet, then our CallScreen widget may be a better option. Keep reading to learn how to use it in your application.

Callbacks
Apart from UI customization you can also customize the behaviour of certain built-in actions.

onBackPressed: Called when the back button is pressed.
onLeaveCallTap: Called when the leave call button is tapped.
onAcceptCallTap: Called when the accept call button is tapped.
onDeclineCallTap: Called when the decline call button is tapped.
onCancelCallTap: Called when the cancel call button is tapped.
Call Connect Options
Providing callConnectOptions as a parameter to StreamCallContainer is one way of setting up initial call configuration. You can read more about it and other ways of providing it here.


CallConnectOptions({
    this.camera = TrackDisabled._instance,
    this.microphone = TrackDisabled._instance,
    this.screenShare = TrackDisabled._instance,
    this.audioOutputDevice,
    this.audioInputDevice,
    this.videoInputDevice,
    this.speakerDefaultOn = false,
    this.cameraFacingMode = FacingMode.user,
    this.targetResolution,
    this.screenShareTargetResolution,
  })
Picture-in-Picture Configuration
The pictureInPictureConfiguration property allows you to configure Picture-in-Picture mode. Detailed description of Picture in Picture functionality can be found here.


PictureInPictureConfiguration({
    this.enablePictureInPicture = false,
    this.androidPiPConfiguration = const AndroidPictureInPictureConfiguration(),
    this.iOSPiPConfiguration = const IOSPictureInPictureConfiguration(),
});



Call Content
Similar to StreamCallContainer, StreamCallContent allows for the display of participants on a call, while providing options for customization and custom UI. The widget manages the display of video rendering and call controls.

However, unlike StreamCallContainer, the sole responsibility of StreamCallContent is to render the call participants and controls. StreamCallContent does not monitor or respond to call lifecycle events, such as incoming and outgoing calls.


const StreamCallContent({
    super.key,
    required this.call,
    this.onBackPressed,
    this.onLeaveCallTap,
    this.callAppBarWidgetBuilder,
    this.callParticipantsWidgetBuilder,
    this.callControlsWidgetBuilder,
    this.layoutMode = ParticipantLayoutMode.grid,
    this.enablePictureInPicture = false,
    this.callPictureInPictureBuilder,
  });
Preview of Call Content
If you want full control over how the ongoing call screen appears, you can provide your own widget using the callContentWidgetBuilder:


StreamCallContainer(
    call: widget.call,
    callContentWidgetBuilder: (context, call) {
        return MyOwnCallContent(call: call);
    },
)
If you prefer to use the default UI provided by the SDK but want to customize specific parts, you can use the StreamCallContent widget. It offers the following builders for customization:

callControlsWidgetBuilder: Customize the call controls, such as mute, camera toggle, or end-call buttons.
callParticipantsWidgetBuilder: Define how the participants in the call are displayed.
callAppBarWidgetBuilder: Customize the primary AppBar for the call screen.
These options allow you to retain the functionality of the default UI while tailoring the experience to meet your specific design needs.

To learn more how call controls work in Stream Video, continue reading to the next chapter 😃.



Video Renderer
One of the primary low-level widgets we offer is StreamVideoRenderer. As the name suggests, this widget is specifically designed to render the video track of a call participant. It also exposes callbacks that can be utilized to handle sizing changes, placeholder content, and other related functionalities.

However, since StreamVideoRenderer is relatively basic, we have also introduced StreamCallParticipant as an extended version. It adds several extra features on top of StreamVideoRenderer, such as connection quality indicators, microphone indicators, and more.

Since the SDK is designed to be modular and customizable, developers can choose whether they want to use the raw renderer or the participant widget.

When in doubt, we recommend starting with StreamCallParticipant unless there is an explicit reason not to.

Customizing StreamCallParticipant

const StreamCallParticipant({
    super.key,
    required this.call,
    required this.participant,
    this.videoFit,
    this.backgroundColor,
    this.borderRadius,
    this.userAvatarTheme,
    this.showSpeakerBorder,
    this.speakerBorderThickness,
    this.speakerBorderColor,
    this.showParticipantLabel,
    this.participantLabelTextStyle,
    this.participantLabelAlignment,
    this.audioLevelIndicatorColor,
    this.enabledMicrophoneColor,
    this.disabledMicrophoneColor,
    this.showConnectionQualityIndicator,
    this.connectionLevelActiveColor,
    this.connectionLevelInactiveColor,
    this.connectionLevelAlignment,
    this.videoPlaceholderBuilder,
    this.videoRendererBuilder,
    this.onSizeChanged,
  });
Call Participant allows you to customize everything from the background color and border radius to setting placeholder content and customizing the audio level indicators.

To use the widget, you need to supply two arguments: the current call and participant to render. Both of these parameters can be fetched from either activeCall or callState.


StreamCallContent(
    call: call,
    callParticipantsWidgetBuilder: (context, call) {
      return PartialCallStateBuilder(
        call: call,
        selector: (state) => state.localParticipant,
        builder: (context, localParticipant) =>
          StreamCallParticipant(
            call: call,
            participant: localParticipant!,
          ),
      );
    },
  );
Using StreamVideoRenderer directly

StreamCallContent(
    call: call,
    callState: callState,
    callParticipantsWidgetBuilder: (context, call) {
      return PartialCallStateBuilder(
        call: call,
        selector: (state) => state.localParticipant,
        builder: (context, localParticipant) =>
          StreamVideoRenderer(
            call: call,
            participant: localParticipant!,
            videoTrackType: SfuTrackType.screenShare,
            videoFit: VideoFit.contain,
          ),
      );
    },
  );
Video Render is the lowest level component for displaying a participant's video in Flutter. Unlike StreamCallParticipant, the options exposed by StreamVideoRenderer are minimal and focuses more on video fit and layout, determining which track types to display, and providing callbacks for handling changes to the video rendering.

Both StreamVideoRenderer and StreamCallParticipant can be used as part of other components, such as StreamCallContent, or as standalone widgets in your application, as long as the call and participant parameters are supplied.


Call Controls
By default, StreamCallContent renders controls for the user to interact with, such as leaving a call, controlling their microphone and camera, etc.

However, in cases where developers want to override these controls, they can use the StreamCallControls class.

If left unmodified, Stream Call Content uses the .withDefaultOptions constructor.


List<Widget> defaultCallControlOptions({
  required Call call,
  required CallParticipantState localParticipant,
  VoidCallback? onLeaveCallTap,
}) {
  return [
    ToggleSpeakerphoneOption(call: call),
    ToggleCameraOption(call: call, localParticipant: localParticipant),
    ToggleMicrophoneOption(call: call, localParticipant: localParticipant),
    FlipCameraOption(call: call, localParticipant: localParticipant),
    LeaveCallOption(call: call, onLeaveCallTap: onLeaveCallTap),
  ];
}
Developers can supply a list of custom options for their call using the default constructor. It's common to use a combination of both Stream default options and custom options. For example, you can use Stream's default buttons for leaving the call, controlling the microphone, and camera, while including a custom option to perform an activity specific to your application, such as sending a custom event or reaction.


StreamCallContent(
  call: call,
  callControlsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallControls(
      options: [
        // Custom call option toggles the chat while on a call.
        CallControlOption(
          icon: const Icon(Icons.chat_outlined),
          onPressed: () => showChatDialog(context),
        ),
        ToggleMicrophoneOption(
          call: call,
        ),
        ToggleCameraOption(
          call: call,
        ),
        LeaveCallOption(
          call: call,
          onLeaveCallTap: () => call.leave(),
        ),
      ],
    );
  },
);
As an example, the above snippet demonstrates how a custom CallControlOption can be used to display a chat dialog while a user is on a call.

Custom widgets
The StreamCallControls options allow you to provide any custom widget. If our default toggle options don’t offer the level of customization you're looking for, or if you prefer to use a completely different button, you can easily substitute them with your own widget. Typically, these toggles are simply wrappers around a single Call method call. You can review the logic within our toggle options to replicate it as needed.


class ToggleCameraButton extends StatelessWidget {
  const ToggleCameraButton({required this.call, super.key});
  final Call call;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final localParticipant = call.state.value.localParticipant!;
        await call.setCameraEnabled(enabled: !localParticipant.isVideoEnabled);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.videocam_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
Did you find this page helpful



Call AppBar
The default AppBar provided by the StreamCallContent widget includes essential features such as:

A back button to navigate out of the call.
Call status information.
An action to leave the call.
If you want to customize the AppBar to better fit your app’s design or functionality, you can use the callAppBarBuilder. This allows you to replace or modify the default AppBar while maintaining the core functionality provided by the SDK.

In the following example (from our dogfooding sample app), the default app bar is modified to include ToggleLayoutOption and FlipCameraOption actions on the left. Both of these widgets are part of our SDK and can be used to further personalize your UI.

Additionally, the example below uses a custom CallDurationTitle widget to display the call’s duration.


StreamCallContainer(
      call: widget.call,
      callConnectOptions: widget.connectOptions,
      onCancelCallTap: () async {
        await widget.call.reject(reason: CallRejectReason.cancel());
      },
      callContentWidgetBuilder: (
        BuildContext context,
        Call call,
      ) {
        return StreamCallContent(
          call: call,
          callAppBarWidgetBuilder: (context, call) {
            return CallAppBar(
              call: call,
              leadingWidth: 120,
              leading: Row(
                children: [
                  ToggleLayoutOption(
                    onLayoutModeChanged: (layout) {
                      setState(() {
                        _currentLayoutMode = layout;
                      });
                    },
                  ),
                  PartialCallStateBuilder(
                    call: call,
                    selector: (state) => state.localParticipant != null,
                    builder: (context, hasLocalParticipant) =>
                        hasLocalParticipant
                            ? FlipCameraOption(
                                call: call,
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
              title: CallDurationTitle(call: call),
            );
          },
        );
      },
    )
Preview of Call Content



Outgoing Call
The StreamCallContainer widget offers built-in support for displaying outgoing calls. When you initiate a new ringing-flow call, you can pass it to the StreamCallContainer, and the outgoing call screen will be shown until the first participant joins the call.


import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
// Example method called to create a new call
Future<void> startCall() {
    final call = StreamVideo.instance.makeCall(
      callType: StreamCallType.defaultType(),
      id: {CALL_ID},
    );
    final result = await call.getOrCreate(
      ringing: true,
      video: true,
      memberIds: [
        'user1',
        'user2',
      ],
    );
    result.fold(
      success: (success) {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyCallScreen(call)),
            );
        }
      },
      failure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.error.message}'),
          ),
        );
      },
    );
}
class MyCallScreen extends StatelessWidget {
    const MyCallScreen(this.call, {super.key});
    final Call call;
    @override
    Widget build(BuildContext context) {
        return StreamCallContainer(
            call: call,
        );
    }
}
Preview of Outgoing Call Screen
Customization
You can customize how the outgoing call screen looks by providing you own widget:


StreamCallContainer(
    call: call,
    outgoingCallWidgetBuilder: (context, call) {
        return MyOwnOutgoingCallScreen(call: call);
    },
)


Incoming Call
The StreamCallContainer widget provides built-in support for displaying incoming calls. To handle incoming calls when your app is in the foreground, you can listen for the incoming call event and display the StreamCallContainer with the associated call.


import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
// Example initState method in some top level widget
@override
void initState() {
  super.initState();
  final subscription = StreamVideo.instance.state.incomingCall.listen((call) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyCallScreen(call)),
        );
    });
}
// remember to cancel the subscription when you no longer need it
class MyCallScreen extends StatelessWidget {
    const MyCallScreen(this.call, {super.key});
    final Call call;
    @override
    Widget build(BuildContext context) {
        return StreamCallContainer(
            call: call,
        );
    }
}
Preview of Incoming Call Screen
Customization
You can customize how the incoming call screen looks by providing your own widget:


StreamCallContainer(
    call: call,
    incomingCallWidgetBuilder: (context, call) {
      return MyOwnIncomingCallScreen(call: call);
    },
)


Video Theme
Understanding How To Customize Widgets Using StreamVideoTheme

Find the pub.dev documentation here

Background
Stream's UI SDK makes it easy for you to add custom styles and attributes to our widgets.

Through the use of StreamVideoTheme, you can extensively customize various elements of our UI widgets by applying modifications using StreamVideoTheme.copyWith.

StreamVideoTheme is a theme extension, meaning that it can be applied to your application's theme using ThemeData.extensions:


ThemeData(extensions: <ThemeExtension<dynamic>>[StreamVideoTheme.dark()])
In case of StreamVideoTheme instance is not passed at the root layer either StreamVideoTheme._kLightFallbackTheme or StreamVideoTheme._kDarkFallbackTheme will be used as a fallback based on ThemeData.brightness value.

A closer look at StreamVideoTheme
Looking at the constructor for StreamVideoTheme, we can see the full list of properties and widgets available for customization.

Some high-level properties such as textTheme or colorTheme can be set application-wide directly from this class. In contrast, larger components such as StreamCallParticipant, StreamLobbyView, etc. have been addressed with smaller theme objects.


factory StreamVideoTheme({
    required Brightness brightness,
    StreamTextTheme? textTheme,
    StreamColorTheme? colorTheme,
    StreamCallContentThemeData? callContentTheme,
    StreamCallControlsThemeData? callControlsTheme,
    StreamUserAvatarThemeData? userAvatarTheme,
    StreamLobbyViewThemeData? lobbyViewTheme,
    StreamCallParticipantThemeData? callParticipantTheme,
    StreamLocalVideoThemeData? localVideoTheme,
    StreamIncomingOutgoingCallThemeData? incomingCallTheme,
    StreamIncomingOutgoingCallThemeData? outgoingCallTheme,
    StreamLivestreamThemeData? livestreamTheme,
  });
Stream Video Theme in use
Let's take a look at customizing widgets using StreamVideoTheme. In the example below, we're changing the default accentPrimary color to lightBlue and overriding the typography and colors of StreamCallParticipant labels for the Dark theme.


bool isLightTheme = false;
final darkAppTheme = StreamVideoTheme.dark();
final lightAppTheme = StreamVideoTheme.light();
MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[lightAppTheme],
  ),
  darkTheme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      darkAppTheme.copyWith(
        colorTheme: darkAppTheme.colorTheme.copyWith(
          accentPrimary: Colors.lightBlue,
        ),
        callParticipantTheme: darkAppTheme.callParticipantTheme.copyWith(
          participantLabelTextStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),
  themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
  ...
);



Call Participants
Often in a video call, an app needs the ability to arrange and resize the video feeds of different participants on the screen to suit design needs. Customizing participant layouts is a simple but effective way to improve the quality and experience of video calls. It can help to improve focus and engagement, highlight key speakers or presenters, and accommodate the different needs of participants.

By default, the Flutter SDK for Stream Video displays a grid of participants in a call.

To create your own layout for the user participants instead, use the callParticipantsWidgetBuilder parameter of the StreamCallContent widget.

The default widget used is the StreamCallParticipants widget:


StreamCallContent(
  call: call,
  callState: callState,
  callParticipantsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallParticipants(
      call: call,
    );
  },
);
As a reminder, the StreamCallContent widget above can be supplied to the callContentWidgetBuilder parameter of the StreamCallContainer widget which manages most of the UI components related to a call.

If you need a fully custom widget, you can supply your own widget in place of StreamCallParticipants.

However, the StreamCallParticipants widget also allows you to customise quite a few things.

Change only participant grid elements
To change all participant video elements, you can use the callParticipantsWidgetBuilder parameter. This will be applied to all user video elements:


StreamCallContent(
  call: call,
  callState: callState,
  callParticipantsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallParticipants(
      call: call,
      callParticipantBuilder: (
        BuildContext context,
        Call call,
        CallParticipantState participantState,
      ) {
        // Build call participant video
      },
    );
  },
);
Change local participant video
To only change the local participant video, use the localVideoParticipantBuilder parameter which only changes the local participant video stream:


StreamCallContent(
  call: call,
  callParticipantsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallParticipants(
      call: call,
      localVideoParticipantBuilder: (
        BuildContext context,
        Call call,
        CallParticipantState participantState,
      ) {
        // Build local participant video
      },
    );
  },
);
Change screensharing view
If a user is screensharing, you can also customise the screensharing stream using the screenShareContentBuilder parameter:


StreamCallContent(
  call: call,
  callState: callState,
  callParticipantsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallParticipants(
      call: call,
      screenShareContentBuilder: (
        BuildContext context,
        Call call,
        CallParticipantState participantState,
      ) {
        // Build screensharing content view
      },
    );
  },
);
Change grid layout
There are two grid layouts that stream_video_flutter supports at the moment: grid and spotlight.

You can change these via the layoutMode parameter:


StreamCallContent(
  call: call,
  callState: callState,
  callParticipantsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallParticipants(
      call: call,
      layoutMode: ParticipantLayoutMode.spotlight,
    );
  },
);
Sort and filter participants
Sorting changes the order of participants on the grid while filtering selects participants to display according to the filters given.


StreamCallContent(
  call: call,
  callState: callState,
  callParticipantsWidgetBuilder: (
    BuildContext context,
    Call call,
  ) {
    return StreamCallParticipants(
      call: call,
      filter: (participant) {
        // returning true displays the participant while returning false does not
        return YOUR_CONDITION_HERE;
      },
      sort: (a, b) {
        // Returning an integer > 0 sorts a higher than b
        // Add sorting code here
      },
    );
  },
);



Overview
This guide explains how to add ringing functionality to your Flutter app, enabling an end-to-end call flow experience.

For a hands-on approach, check out our step-by-step tutorial on building an app with full ringing functionality here. You can also explore our sample ringing application, which showcases the final result of the tutorial, here.

Incoming Calls
Stream Video makes it easy to build apps that support ringing calls. When a user initiates a ringing call, the recipient receives an incoming call notification.

For detailed instructions on implementing ringing functionality, visit this page.

Ringing Options
The way an incoming call is presented depends on your app’s configuration and its current state (foreground, background, or terminated).

In-app Incoming Calls
When the app is in the foreground, you can display a custom in-app incoming call screen. This screen is typically triggered by a ringing WebSocket event sent to your app. You have full control over the design and behavior of this screen. For more information on customizing the in-app call screen, check out this section.

This method does not display an incoming call screen if the app is in the background or terminated. To handle such scenarios, proper VoIP push handling is required. Additionally if VoIP push/CallKit is configured, the system displays a ringing notification alongside the in-app incoming screen when the app is in the foreground.
CallKit Integration (iOS)
For iOS apps running in the background or terminated, Apple’s CallKit framework can be integrated. CallKit enables the app to handle system-level incoming call screens by sending a VoIP push notification from the server, which wakes up the app. While CallKit provides limited UI customization, it ensures consistent behavior across iOS devices. Learn more about integrating Stream Video with CallKit in this guide.

Firebase Integration (Android)
For Android apps running in the background or terminated, Firebase push notifications can be used to handle ringing. These notifications let users join or decline the call and can also launch the app if needed. For step-by-step integration instructions, refer to this guide.

Push Notifications
You can also use standard push notifications for ringing. While these notifications are less interactive and do not allow users to directly accept or reject a call, they can trigger actions such as deeplinking into your app. For more details, visit the push notifications guide.




Ringing
Ringing
To create a ringing call, follow the same steps as in the basic call flow, with the addition of the ringing and memberIds parameters in the getOrCreateCall() method.


final call = StreamVideo.instance.makeCall(callType: StreamCallType.defaultType(), id: 'Your-call-ID');
await call.getOrCreate(memberIds: ['user1_id', 'user2_id'], ringing: true, video: true);
Setting ringing to true prompts Stream to send a notification to the call members, triggering the platform's call screen on iOS and Android.
The notification specifies whether the call is a video call or audio-only, based on the video parameter (true for video, false for audio-only).
memberIds is a list of user IDs to be added to the call. When combined with the ringing parameter, it triggers ringing on the devices of these members.
If the call already exists, the method will just get it and sends the notifications.

Notifying users
In some scenarios, you may prefer to notify users about joining a call without triggering ringing. To achieve this, use the notify option:


final call = StreamVideo.instance.makeCall(callType: StreamCallType.defaultType(), id: 'Your-call-ID');
await call.getOrCreate(memberIds: ['user1_id', 'user2_id'], notify: true);
When notify is set to true, Stream sends a regular push notification to all members. This is particularly useful for use cases like livestreams or huddles.

Listening to Ringing Events
When the app is active, a WebSocket event (CoordinatorCallRingingEvent) is sent if someone rings the currently logged-in user. You can listen to this event to display an in-app call screen:


final subscription = StreamVideo.instance.events.listen((event) {
    if (event is CoordinatorCallRingingEvent) {
        print(event);
    }
});
// Remember to cancel the subscription when no longer needed.
subscription.cancel();
The CoordinatorCallRingingEvent includes a video boolean property (provided in getOrCreate() method), indicating whether the call includes video or is audio-only. You can use this information to customize the in-app call screen.

Additionally, you can listen for incomingCall events from the StreamVideo object’s state. This provides a Call object for the incoming call:


final subscription = StreamVideo.instance.state.incomingCall.listen((call) {
    // Replace with navigation flow of your choice
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CallScreen(call)),
    );
});
// Remember to cancel the subscription when no longer needed.
subscription.cancel();
Ringing individual members
In some cases, you may want to ring individual members instead of the whole call, or you want to ring a member into an existing call. You can do this by using the ring method:


final call = StreamVideo.instance.makeCall(callType: StreamCallType.defaultType(), id: 'Your-call-ID');
await call.getOrCreate(memberIds: ['user1_id', 'user2_id'], ringing: true, video: true);
// note: userId needs to be a member of the call
await call.ring(userIds: ['userId'])
// to invite a new member and ring them
await call.addMembers([UserInfo(id: 'userId')]);
await call.ring(userIds: ['userId']);
// to ring everyone
await call.ring();
UI Components
By navigating to a screen containing our StreamCallContainer and passing the incoming call, an incoming call screen is displayed automatically. For outgoing calls, use StreamCallContainer with the call used to initiate ringing to show an outgoing call screen.

Find more details in our UI docs: Incoming Call and Outgoing Call.

This method does not display an incoming call screen if the app is in the background or terminated. To handle such scenarios, proper VoIP push handling is required. Additionally if VoIP push/CallKit is configured, the system displays a ringing notification alongside the in-app incoming screen when the app is in the foreground.
Auto-ending the call
By default, a call initiated with the ringing flow ends automatically when only one participant remains. To disable this behavior, set the dropIfAloneInRingingFlow flag to false in CallPreferences:


final call = streamVideo.makeCall(
    callType: StreamCallType.defaultType(),
    id: 'CALL_ID',
    preferences: DefaultCallPreferences(dropIfAloneInRingingFlow: false),
);




Push Providers Configuration
Configuring Push Notification Manager
To handle push notifications in your Flutter app, configure the pushNotificationManagerProvider in the StreamVideo instance. This manager handles device token registration, incoming call notifications, and listening to call events (e.g., ending a call on the callee's side when the caller ends the call).

When creating a StreamVideo instance, pass a pushNotificationManagerProvider parameter. This parameter is an instance of StreamVideoPushNotificationManager, which is created using the StreamVideoPushNotificationManager.create() method.


StreamVideo(
      // ...
       options: const StreamVideoOptions(
        // It's important to keep connections alive when the app is in the background to properly handle incoming calls while the app is in the background
        keepConnectionsAliveWhenInBackground: true,
      ),
      // Make sure you initialise push notification manager
      pushNotificationManagerProvider: StreamVideoPushNotificationManager.create(
        iosPushProvider: const StreamVideoPushProvider.apn(
          name: 'your-ios-provider-name',
        ),
        androidPushProvider: const StreamVideoPushProvider.firebase(
          name: 'your-fcm-provider',
        ),
        pushConfiguration: const StreamVideoPushConfiguration(
          ios: IOSPushConfiguration(iconName: 'IconMask'),
        ),
      ),
    );
For androidPushProvider use the provider name created in Firebase integration

For iosPushProvider use the provider name created in APN integration

Add app icon asset in Xcode for displaying dedicated app button in CallKit screen (named IconMask in the code below). See details here

Configuring Push Providers
For the best experience, we strongly recommend using **APNs** for **iOS** and **Firebase** for **Android**. While compatibility with both providers on iOS is a goal, Firebase support for iOS is not yet fully available.
Creating Firebase Provider
Get the Firebase Credentials
In order for our backend to send push notifications through Firebase Cloud Messaging (FCM) we need to authenticate it with Firebase. This authentication ensures that only authorized services can send notifications on behalf of your app. To allow us to do this you must manually provide a service account private key.

Follow these steps to generate the private key file:

In the Firebase console, navigate to Settings > Service Accounts.

Click Generate New Private Key, then confirm by clicking Generate Key.

Download the JSON file and store it securely, as it grants access to Firebase resources.

In the next step, you’ll upload this JSON file to Stream’s server to complete the setup.

Upload the Firebase Credentials to Stream
To upload your Firebase credentials to Stream dashboard:

Go to the dashboard of your video project at the Stream website.

Open the Push Notifications tab under Video & Audio.

Select New Configuration and select Firebase.

Firebase Configuration
Provide a name for the push provider in the Name field. This name will be referenced in your code to identify the provider.

Upload the previously generated Firebase credentials JSON file in the Credentials JSON field.

Enable this provider using toggle button.

Click Create to finalize the configuration.

Add dependencies to your app
To integrate push notifications, include the firebase_messaging package in your Flutter app.

Follow the Flutter Firebase documentation for setup instructions for both Android and iOS.

Once set up, FCM will handle push notifications for your devices. Remember to initialize the Firebase when your app starts:


await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
Creating APNs Provider
Get the iOS certificate for push notifications
To generate an iOS certificate for push notifications:

Create a push notification service key via Apple's Developer Portal, ensuring Apple Push Notifications service SSL (Sandbox & Production) is selected.

Create a Certificate Signing Request (CSR) by following these steps.

Convert the .cer file into a .p12 certificate file using Keychain Access:

Add the .cer file to the login keychain.
Find it under the Certificates tab, right-click, and export it as a .p12 file.
Ensure no password is set when exporting.
Upload the certificate and create a push provider
To configure APNs in the Stream dashboard:

Go to the dashboard of your video project at the Stream website.

Open the Push Notifications tab under Video & Audio.

Select New Configuration and select APN.

APNs Configuration
Provide a name for the push provider in the Name field. This name will be used in your code to configure iOS push notifications.

Upload the .p12 file generated in the previous step, along with the necessary Apple details.

Enable this provider using toggle button

Click Create to finalize the configuration.

Now that the providers are configured, the next step is to handle push notifications:

For regular push notifications, refer to this guide.
For VoIP/ringing notifications:
iOS: Follow this guide.
Android: Refer to this guide.



Push Notifications
The StreamVideo SDK supports two types of push notifications: regular and VoIP notifications. You can use either or both depending on your use case.

Push notifications are sent in the following scenarios:

Ringing notifications: Sent when you create a call with the ringing value set to true. This triggers a VoIP notification to display a ringing screen.
Notify notifications: Sent when you create a call with the notify value set to true. These are regular push notifications.
Missed call notifications: Sent as a regular push notification if a call goes unanswered.
The handling of ringing (VoIP) notifications is explained here for Android and here for iOS. In this section, we focus on handling regular push notifications for notify and call.missed cases.

Whenever a notification is sent by the Stream Video backend, its payload will include a sender field set to stream.video. The type field in the payload can have one of the following values:

call.notification: Sent for notify notifications or other regular call notifications.
call.missed: Sent when a call is missed.
call.ring: Sent for ringing calls.
Android and Firebase Cloud Messaging (FCM)
In a high-level widget within your app, add the following code to listen for FCM messages:


@override
void initState() {
  ...
  _observeFcmMessages()
}
Future<bool> _handleRemoteMessage(RemoteMessage message) async {
  final payload = message.data;
  final sender = payload['sender'] as String?;
  final type = payload['type'] as String?;
  if (sender == 'stream.video' && type == 'call.notification') {
    final callCid = payload['call_cid'] as String?;
    // Show notification, for example using `flutter_local_notifications` package
  }
}
_observeFcmMessages() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _fcmSubscription = FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
}
You can handle call.missed notifications similarly to call.notification by showing a local notification. By default, the SDK handles this automatically. You can configure this behavior through the pushConfiguration parameter when initializing StreamVideo:


StreamVideo(
  apiKey,
  user: user,
  pushNotificationManagerProvider: StreamVideoPushNotificationManager.create(
    ...,
    pushConfiguration: const StreamVideoPushConfiguration(
      ios: IOSPushConfiguration(iconName: 'IconMask'),
      // Configure missed call notification here
      android: AndroidPushConfiguration(
        missedCallNotification: MissedCallNotificationParams(
          showNotification: true,
          subtitle: 'Missed Call',
          callbackText: 'Call Back',
        ),
      ),
    ),
  ),
);
iOS and Apple Push Notification Service (APNs)
For iOS, standard push notifications must be handled separately from VoIP notifications. When an APNs push provider is registered for iOS, the SDK sends both VoIP and standard push notifications through APNs.

Registering APN device token
Since the APNs device token is separate from the VoIP token, it must be registered explicitly. Enable this by setting registerApnDeviceToken to true when initializing the StreamVideo instance:


StreamVideo(
  apiKey,
  user: user,
  pushNotificationManagerProvider: StreamVideoPushNotificationManager.create(
    ...,
    registerApnDeviceToken: true, // <--- Add this line
  ),
);
Handling standard push notifications
To handle push notifications in your iOS app, add the following code to your AppDelegate.swift file:


@objc class AppDelegate: FlutterAppDelegate {
  override func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {
          GeneratedPluginRegistrant.register(with: self)
          UNUserNotificationCenter.current().delegate = self // <--- Add this line to handle standard push notifications
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
  // This method will be called when notification is received
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let streamDict = notification.request.content.userInfo["stream"] as? [String: Any]
    if(streamDict?["sender"] as? String != "stream.video") {
        return completionHandler([])
    }
    if #available(iOS 14.0, *) {
        completionHandler([.list, .banner, .sound])
    } else {
        completionHandler([.alert])
    }
  }
}
To handle notification tap events (e.g., navigating to the call screen upon a notify notification), include this code in AppDelegate.swift:


// This method will be called when notification is tapped
override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
    let streamDict = response.notification.request.content.userInfo["stream"] as? [String: Any]
    if(streamDict?["sender"] as? String != "stream.video") {
        return;
    }
    if(streamDict?["type"] as? String == "call.notification") {
        let callCid = streamDict?["call_cid"] as? String
        print("Call notification received with call cid: \(callCid)")
        //Navigate to call, for example implementing method channel
    }
    completionHandler()
}
If you want to customize the content of the push notification, consider implementing a Notification Service Extension.

Push notification permission
Remember, that in order to receive push notifications, you need to ask the user for relevant permission. One way of doing it is using permission_handler plugin.


Permission.notification.request();
Registering Devices
If you want to disable this default behavior and manage device registration yourself, set registerPushDevice to false during connection:

Once you configure a push provider and set it up on the Stream dashboard, a device that is supposed to receive push notifications needs to be registered on the Stream backend.

Device registration is carried out in the SDK every time a user connects and does not need to be implemented in your app. Subscription to token change events is also created and new token is registered when needed. Similarly unregistering token is done automatically when disconnect() method is called on StreamVideo instance.

If you want to disable this default behavior and manage device registration yourself, set registerPushDevice to false during connection:


StreamVideo.instance.connect(registerPushDevice: false);
Registering device manually
If you want to manually register the device you can do it by calling addDevice() method of StreamVideo instance:


StreamVideo.instance.addDevice(
  pushProvider: PushProvider.apn,
  pushProviderName: '{PROVIDER_NAME}',
  pushToken: '{TOKEN}',
  voipToken: true,
);
You can also take advantage of the registerDevice() method of PushNotificationManager, which registers the current device with the correct provider and listens for token changes.


StreamVideo.instance.pushNotificationManager?.registerDevice();
Removing registered device
To remove the already registered device, and stop receiving push notifications to it, simply call removeDevice() method:


StreamVideo.instance.removeDevice(
  pushToken: '{TOKEN}',
);
Or call unregisterDevice() method of PushNotificationManager if you used it's registerDevice() method before.


StreamVideo.instance.pushNotificationManager?.unregisterDevice();
Listing devices
You can list devices registered to the current user with the getDevices() method:


let devices = await StreamVideo.instance.getDevices();
This method returns an list of the PushDevice type, that contains information about the device:


/** Date/time of creation */
DateTime createdAt;
/** Whether device is disabled or not */
bool? disabled;
/** Reason explaining why device had been disabled */
String? disabledReason;
String pushToken;
PushProvider pushProvider;
String? pushProviderName;
Deep linking
When a push notification is tapped, you can provide a deep linking mechanism in your app to join a call. You can find more details how to do that in the following page.



CallKit Integration
Introduction
CallKit allows us to have system-level phone integration on iOS. With that, we can use CallKit to present native incoming call screens, even when the app is closed. CallKit integration also enables the calls made through third-party apps be displayed in the phone's recent call list in the Phone app.

The StreamVideo SDK is compatible with CallKit, enabling a complete calling experience for your users.

Make sure you created APNs provider and configured push notification manager as described in this section.

Add camera and microphone permissions
Add these permissions to Info.plist in order to support video calling:


<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your camera for video calls.</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your microphone for voice and video calls.</string>
Enable background modes capabilities
To maintain connectivity, handle incoming calls, and manage ongoing calls when the app is not in the foreground, you can enable iOS background modes. These modes ensure your app remains responsive to call events without being suspended by the system.

Enabling Background Modes in Xcode
Open your app's project in Xcode.
Select your app's target.
Navigate to the Signing & Capabilities tab.
In the Background Modes section, enable the following options:
"Voice over IP"
"Remote notifications"
"Background processing"
Background modes
Adding Background Modes to Info.plist
Alternatively, you can directly configure the necessary background modes in your app's Info.plist file by adding the following keys:


<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
	 <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
	<string>processing</string>
	<string>remote-notification</string>
	<string>voip</string>
</array>
Ensure Push Notification Capabilities
To properly receive VoIP and remote push notifications, you need to enable the Push Notifications capability in Xcode:

Open your app's project in Xcode.
Select your app's target.
Navigate to the Signing & Capabilities tab.
Click the + Capability button.
Search for Push Notifications and add it.
Make sure your app has Push Notification Capabilities set in Signing & Capabilities.

Handling Ringing events (common for iOS and Android)
Ringing events are exposed by the stream_video_push_notification package to handle incoming calls on both iOS and Android. It is important to handle these events to ensure a seamless calling experience regardless of which provider is used for push.

In a high-level widget in your app, add this code to listen to Ringing events:


import 'package:rxdart/rxdart.dart';
final _compositeSubscription = CompositeSubscription();
@override
void initState() {
  ...
  _observeRingingEvents()
}
void _observeRingingEvents() {
  final streamVideo = StreamVideo.instance;
  // You can use our helper method to observe core Ringing events
  // It will handled call accepted, declined and ended events
  _compositeSubscription.add(
      streamVideo.observeCoreRingingEvents(
        onCallAccepted: (callToJoin) {
            // Replace with navigation flow of your choice
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CallScreen()),
            );
        },
      ),
    );
  // Or you can handle them by yourself, and/or add additional events such as handling mute events from CallKit (iOS)
  // _compositeSubscription.add(streamVideo.onRingingEvent<ActionCallToggleMute>(_onCallToggleMute));
}
@override
void dispose() {
  // ...
  _compositeSubscription.cancelAll();
}
If you need to manage the ringing flow call, you can use the StreamVideo.pushNotificationManager. As an example, let's say you want to end all calls, you can end them this way:


StreamVideo.instance.pushNotificationManager?.endAllCalls();
Add native code to the iOS project
In your iOS project, add the following imports to your AppDelegate.swift:


import UIKit
import Flutter
import stream_video_push_notification
In the same file, add an extra line to your AppDelegate class which registers the app for push notifications:


override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Register for push notifications.
    StreamVideoPKDelegateManager.shared.registerForPushNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
You should now be able to receive a ringing call on iOS.

To test this:

Create a ringing call on another device (as describe in previous section).
Add the ID of a user logged into the iOS device to the memberIds array in the call.getOrCreate(ringing: true, memberIds: [{ID}]) method.
You should see the CallKit ringing notification on the iOS device.
If you encounter any issues, refer to the Troubleshooting section for solutions to common mistakes.




Firebase Integration
Introduction
With FCM integration, we enable the ringing flow by handling push messages and displaying custom notifications.

Make sure you created Firebase provider and configured push notification manager as described in this section.

Add native permissions
Add the following permissions to allow camera, audio, and network access:


<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-feature android:name="android.hardware.camera"/>
    <uses-feature android:name="android.hardware.camera.autofocus"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <!-- Bluetooth permissions for audio routing -->
    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    <!-- Required for displaying call notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
Set android:launchMode to singleInstance
Update your MainActivity declaration in AndroidManifest.xml:


<manifest...>
     ...
   <application ...>
       <activity ...
          android:name=".MainActivity"
          android:launchMode="singleInstance">
        ...
   ...
 </manifest>
This ensures that tapping the push notification does not create a new instance of your app. Instead, it brings the existing instance to the foreground, preventing multiple screens from stacking up when accepting calls.

Handling Ringing events (common for iOS and Android)
Ringing events are exposed by the stream_video_push_notification package to handle incoming calls on both iOS and Android. It is important to handle these events to ensure a seamless calling experience regardless of which provider is used for push.

In a high-level widget in your app, add this code to listen to Ringing events:


import 'package:rxdart/rxdart.dart';
final _compositeSubscription = CompositeSubscription();
@override
void initState() {
  ...
  _observeRingingEvents()
}
void _observeRingingEvents() {
  final streamVideo = StreamVideo.instance;
  // You can use our helper method to observe core Ringing events
  // It will handled call accepted, declined and ended events
  _compositeSubscription.add(
      streamVideo.observeCoreRingingEvents(
        onCallAccepted: (callToJoin) {
            // Replace with navigation flow of your choice
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CallScreen()),
            );
        },
      ),
    );
  // Or you can handle them by yourself, and/or add additional events such as handling mute events from CallKit (iOS)
  // _compositeSubscription.add(streamVideo.onRingingEvent<ActionCallToggleMute>(_onCallToggleMute));
}
@override
void dispose() {
  // ...
  _compositeSubscription.cancelAll();
}
If you need to manage the ringing flow call, you can use the StreamVideo.pushNotificationManager. As an example, let's say you want to end all calls, you can end them this way:


StreamVideo.instance.pushNotificationManager?.endAllCalls();
Listen to push notifications
In a high-level widget in your app, add this code to listen to FCM messages:


import 'package:rxdart/rxdart.dart';
final _compositeSubscription = CompositeSubscription();
@override
void initState() {
  ...
  _observeFcmMessages()
}
_observeFcmMessages() {
  _compositeSubscription.add(
      FirebaseMessaging.onMessage.listen(_handleRemoteMessage),
  );
}
Future<void> _handleRemoteMessage(RemoteMessage message) async {
  await StreamVideo.instance.handleRingingFlowNotifications(message.data);
}
@override
void dispose() {
  // ...
  _compositeSubscription.cancelAll();
}
The handleRingingFlowNotifications() method will show custom notification indicating ringing call. It will also handle call.missed push by showing dedicated notification if you want to handle it by yourself set handleMissedCall parameter to false.

Handle push in background and terminated state
When you app is in the background special handling is required. We need to register a handler method that will be called by system when push is received even when app is not running.

We recommend storing user credentials locally when the user logs in so you can automatically set up the user when a push notification is received in background.

Add the following code as top lever functions (for example on top of your main.dart file):


// As this runs in a separate isolate, we need to setup the app again.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialise Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    // Get stored user credentials
    final tutorialUser = await AppInitializer.getStoredUser();
    if (tutorialUser == null) return;
    // Use the `create` factory to create an instance separate from the `StreamVideo.instance` singleton
    final streamVideo = StreamVideo.create(
      ...,
      // Make sure you initialise push notification manager
      pushNotificationManagerProvider: StreamVideoPushNotificationManager.create(
        iosPushProvider: const StreamVideoPushProvider.apn(
          name: 'your-ios-provider-name',
        ),
        androidPushProvider: const StreamVideoPushProvider.firebase(
          name: 'your-fcm-provider',
        ),
        pushParams: const StreamVideoPushParams(
          appName: kAppName,
          ios: IOSParams(iconName: 'IconMask'),
        ),
      ),
    )..connect();
    // Ensure proper handling of Ringing events during the ringing
    final subscription = streamVideo.observeCoreRingingEventsForBackground();
    // Dispose this instance after ringing is resolved
    streamVideo.disposeAfterResolvingRinging(
      disposingCallback: () => subscription?.cancel(),
    );
    // Handle the push notification
    await streamVideo.handleRingingFlowNotifications(message.data);
  } catch (e, stk) {
    debugPrint('Error handling remote message: $e');
    debugPrint(stk.toString());
  }
}
Now register this handler in FirebaseMessaging instance. You can do it for example inside the _observeFcmMessages() method we created in a previous step:


_observeFcmMessages() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _compositeSubscription.add(
      FirebaseMessaging.onMessage.listen(_handleRemoteMessage),
  );
}
In case the call was accepted when the app was terminated we also need to consume it.

In a high-level widget, add this method and call it from the initState() method:


@override
void initState() {
  //...
  _tryConsumingIncomingCallFromTerminatedState();
}
void _tryConsumingIncomingCallFromTerminatedState() {
  // This is only relevant for Android.
  if (CurrentPlatform.isIos) return;
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    StreamVideo.instance.consumeAndAcceptActiveCall(
      onCallAccepted: (callToJoin) {
        // Replace with navigation flow of your choice
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CallScreen()),
        );
      },
    );
  });
}
Request notification permission from user
For Android 13+ you need to request the POST_NOTIFICATIONS permission. You can do it using the permission_handler package.

Remember to follow official best practices (especially showing prompt before the request).

Make sure permission to send full-screen notifications is granted
For Android 14+ on some devices, the full-screen intent permission might not be granted, preventing the ringing notification from appearing when the screen is locked.

We expose a dedicated method to make sure this permission is granted:


StreamVideoPushNotificationManager.ensureFullScreenIntentPermission();
In case it is not granted, the user will be taken to the app's settings page to enable full-screen notifications.

You should now be able to receive a ringing call on Android.

To test this:

Create a ringing call on another device (as describe in previous section).
Add the ID of a user logged into the Android device to the memberIds array in the call.getOrCreate(ringing: true, memberIds: [{ID}]) method.
You should see the custom ringing notification show on the Android device.
If you encounter any issues, refer to the Troubleshooting section for solutions to common mistakes.

Did you find this page helpful?




Customization
Display Name Customization
The Stream backend populates two key properties in the VoIP push notification payload that determine the call's display name:

call_display_name: This calculated property evaluates the following custom data fields on the Call object in order of priority:
display_name
name
title

final result = await call.getOrCreate(
          memberIds: memberIds,
          ringing: true,
          custom: {'display_name': 'Stream group call'},
        );
If none of these fields are set, the property defaults to an empty string.

created_by_display_name: This property is always populated and contains the name of the user who initiated the call.
By default, the SDK prioritizes call_display_name for the ringing notification display. If this value is empty, it falls back to created_by_display_name.

UI Customization
Android
All Android UI options are configured via AndroidPushConfiguration and passed through pushConfiguration when creating the StreamVideoPushNotificationManager.


StreamVideo(
  ...,
  pushNotificationManagerProvider: StreamVideoPushNotificationManager.create(
    ...,
    pushConfiguration: const StreamVideoPushConfiguration(
      android: AndroidPushConfiguration(
        // Global Android options
        ringtonePath: 'system_ringtone_default',
        defaultAvatar: 'assets/company_logo.png',
        incomingCallNotificationChannelName: 'Incoming Call',
        missedCallNotificationChannelName: 'Missed Call',
        showFullScreenOnLockScreen: true,
        // Incoming call UI
        incomingCallNotification: IncomingCallNotificationParams(
          showCallHandle: true,
          fullScreenShowLogo: false,
          fullScreenBackgroundColor: '#0955fa',
          fullScreenTextColor: '#ffffff',
        ),
        // Missed call notification UI
        missedCallNotification: MissedCallNotificationParams(
          showNotification: true,
          subtitle: 'Missed call',
          showCallbackButton: true,
          callbackText: 'Call back',
        ),
      ),
    ),
  ),
);
Customize Button Text
Use incomingCallNotification.textAccept and incomingCallNotification.textDecline inside AndroidPushConfiguration to set the Accept/Decline labels.

When supported by the device/OS, the SDK renders a system-styled incoming call notification and the OS controls the button labels. Custom button text applies only when we fall back to our custom incoming call notification (older Android versions or certain Samsung devices/cases).

pushConfiguration: const StreamVideoPushConfiguration(
  android: AndroidPushConfiguration(
    incomingCallNotification: IncomingCallNotificationParams(
      textAccept: 'Answer',
      textDecline: 'Reject',
    ),
  ),
),
Customize Full-screen Appearance
When showFullScreenOnLockScreen is set to true the full-screen incoming call activity on the lock screen will be shown while the phone is ringing. On Android 14+ this requires the Full-screen intent permission to be granted at runtime. You can do this by calling ensureFullScreenIntentPermission() method. See the Android Firebase integration guide.


StreamVideoPushNotificationManager.ensureFullScreenIntentPermission();
Use the IncomingCallNotificationParams fields to control the full-screen UI:

fullScreenBackgroundColor
fullScreenBackgroundUrl
fullScreenTextColor
fullScreenLogoUrl
fullScreenShowLogo

pushConfiguration: const StreamVideoPushConfiguration(
  android: AndroidPushConfiguration(
    incomingCallNotification: IncomingCallNotificationParams(
      fullScreenBackgroundColor: '#101828',
      fullScreenTextColor: '#ffffff',
      fullScreenBackgroundUrl: 'https://cdn.example.com/call/bg.jpg',
      fullScreenLogoUrl: 'https://cdn.example.com/brand/logo.png',
      fullScreenShowLogo: true,
    ),
  ),
),
Both fullScreenBackgroundUrl and fullScreenLogoUrl accept either an http(s) URL or a path to a Flutter asset (for example, assets/call/bg.jpg). If using assets, ensure they are declared under assets: in your pubspec.yaml.

Customize Missed Call Notification
Use missedCallNotification to configure the missed call system notification:

subtitle, callbackText, showCallbackButton
showNotification (to enable/disable)

pushConfiguration: const StreamVideoPushConfiguration(
  android: AndroidPushConfiguration(
    missedCallNotification: MissedCallNotificationParams(
      subtitle: 'Missed video call',
      callbackText: 'Call back',
      showCallbackButton: true,
      showNotification: true,
    ),
  ),
),
Customize Ringtone
Set a custom ringtone for incoming calls using ringtonePath. Place the audio file in /android/app/src/main/res/raw/.

If not specified, the system default ringtone is used.


pushConfiguration: const StreamVideoPushConfiguration(
  android: AndroidPushConfiguration(
    // File path: /android/app/src/main/res/raw/ringtone_default.mp3
    ringtonePath: 'ringtone_default',
  ),
),
Place the ringtone audio file at /android/app/src/main/res/raw/ringtone_default.mp3 and set ringtonePath to the file name without extension (ringtone_default). Android resolves sounds in res/raw by resource name. Common formats like .mp3, .wav, or .ogg are supported.

Notification channels
incomingCallNotificationChannelName sets the user-visible name of the notification channel used for incoming call notifications (Android 8.0+). The SDK creates or reuses this channel. Users can change its behavior (sound, vibration, importance) in system settings.
missedCallNotificationChannelName sets the user-visible name of the channel used for missed call notifications.
Changing a channel’s name in code may create a new channel on devices where a channel with the previous name already exists.
iOS CallKit
While Apple's CallKit framework limits customization options, you can still configure these essential aspects:

iconName: Specifies the app icon to display in the CallKit call screen. Ensure your icon is properly prepared and added as described in Apple's documentation
ringtonePath: Adds a custom ringtone by placing your audio file in the root project directory at /ios/Runner/Ringtone.caf. Make sure it's included in the Copy Bundle Resources section of Build Phases in Xcode.
Handle behavior:

The SDK passes the caller’s user id as the CallKit handle by default.
We assume the user id is a GUID/UUID-like identifier, so we use the generic handle type and do not display this value in the incoming call UI (the visible name comes from callerName).
If your app uses an email or phone number as the user id, consider setting handleType to email or number so CallKit treats it accordingly. Alternatively, enable useComplexHandle to obfuscate the raw value.

StreamVideo(
    ...,
    pushNotificationManagerProvider: StreamVideoPushNotificationManager.create(
        ...,
        pushConfiguration: const StreamVideoPushConfiguration(
          ios: IOSPushConfiguration(
            iconName: 'IconMask',
            ringtonePath: 'system_ringtone_default',
            handleType: 'generic', // 'generic' | 'number' | 'email'
            useComplexHandle: false,
          ),
        ),
    ),
  );


  Picture in Picture (PiP)
Picture in picture (PIP) keeps the call running and visible while you navigate to other apps.

Enable Picture-in-Picture
To enable Picture-in-Picture (PiP), set the enablePictureInPicture property to true in the PictureInPictureConfiguration provided to the StreamCallContainer or StreamCallContent widget. Additionally, you can control whether PiP remains enabled when the local device is screen sharing using the disablePictureInPictureWhenScreenSharing parameter (disabled by default).


StreamCallContainer(
    call: widget.call,
    pictureInPictureConfiguration: const PictureInPictureConfiguration(
        enablePictureInPicture: true,
        disablePictureInPictureWhenScreenSharing: true,
    ),
)
Keep the Connection Active in Background
For Picture-in-Picture to function properly while the app is in the background, it is important to keep the connection to Stream backend active. This is controlled by the keepConnectionsAliveWhenInBackground property in StreamVideoOptions, which must be set to true.

Additionally, to ensure the local participant remains visible and audible in PiP mode, ensure muteVideoWhenInBackground and muteAudioWhenInBackground are set to false (false by default).


StreamVideo(
    apiKey,
    user: user,
    token: token,
    options: const StreamVideoOptions(
      muteAudioWhenInBackground: false,
      muteVideoWhenInBackground: false,
      keepConnectionsAliveWhenInBackground: true,
    ),
  );
Android
Quick Setup with StreamFlutterActivity
The easiest way to add PiP support is to extend StreamFlutterActivity instead of FlutterActivity:


// MainActivity.kt
import io.getstream.video.flutter.stream_video_flutter.StreamFlutterActivity
class MainActivity : StreamFlutterActivity() {
    // All PiP functionality is automatically handled!
    // Add your custom logic here if needed
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Your custom Flutter engine configuration
    }
}
What StreamFlutterActivity Does
StreamFlutterActivity automatically handles:

PiP Initialization: Sets up the PictureInPictureHelper with your Flutter engine
Automatic Triggers: Enters PiP mode when:
User presses the home button (onUserLeaveHint)
App is backgrounded during an active call (onPause)
Mode Change Notifications: Notifies Flutter when PiP mode changes
Optimal Aspect Ratios: Automatically sets appropriate aspect ratios
Android Version Compatibility: Works across different Android versions
Advanced: Manual Setup
If you prefer to set up PiP manually or need more control:


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Initialize PiP helper
        PictureInPictureHelper.initializeWithFlutterEngine(flutterEngine) { this }
    }
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        PictureInPictureHelper.handlePipTrigger(this)
    }
    override fun onPause() {
        super.onPause()
        if (!isFinishing) {
            PictureInPictureHelper.handlePipTrigger(this)
        }
    }
    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        PictureInPictureHelper.notifyPictureInPictureModeChanged(this, isInPictureInPictureMode)
    }
}
Configuration Options
PictureInPictureConfiguration

PictureInPictureConfiguration(
  enablePictureInPicture: true,
  disablePictureInPictureWhenScreenSharing: true,
  sort: CallParticipantSortingPresets.speaker, // Custom participant sorting
  androidPiPConfiguration: AndroidPictureInPictureConfiguration(
    callPictureInPictureWidgetBuilder: (context, call) {
      // Custom PiP overlay widget
      return YourCustomPiPWidget(call: call);
    },
  ),
)
Android Permissions
Enable PiP for your activity and update the configChanges in android/app/src/main/AndroidManifest.xml:


<activity
    android:name=".MainActivity"
    android:supportsPictureInPicture="true"
    android:configChanges="screenSize|smallestScreenSize|screenLayout|orientation"
    ... >
Troubleshooting
PiP Not Working?
Check Permissions: Ensure supportsPictureInPicture="true" is set in AndroidManifest.xml
Check Flutter Configuration: Ensure enablePictureInPicture: true in your Flutter code
Check Android Version: PiP requires Android 7.0 (API level 24) or higher
Check Device Support: Some devices/manufacturers may disable PiP
PiP Overlay Not Showing?
Widget Tree: Ensure StreamCallContent or StreamPictureInPictureAndroidView is in your widget tree
Call State: PiP only activates during active calls (connected state)
Screen Sharing: PiP is disabled during screen sharing by default
Migration from Old API
If you're migrating from the old PiP API:

❌ Remove These (Deprecated)

// Remove manual PiP calls
await StreamVideoFlutterBackground.setPictureInPictureEnabled(enable: true);

// Remove manual PiP triggers
override fun onUserLeaveHint() {
    super.onUserLeaveHint()
    PictureInPictureHelper.enterPictureInPictureIfInCall(this) // Deprecated
}
✅ Use This Instead

// Simply extend StreamFlutterActivity
class MainActivity : StreamFlutterActivity()

// Configure in Flutter
StreamCallContent(
  call: call,
  pictureInPictureConfiguration: PictureInPictureConfiguration(
    enablePictureInPicture: true,
  ),
)
iOS
Local camera feed in Picture-in-Picture mode
By default, iOS does not allow access to the user's camera while the app is in the background. To enable it, the multitasking camera access property must be set to true.

For apps linked against iOS 18 or later, this property is automatically true if voip is included in UIBackgroundModes. Additionally, apps with the com.apple.developer.avfoundation.multitasking-camera-access entitlement will also have multitasking camera access enabled.

If the multitasking camera access property is true for your app based on the above conditions, the local camera feed will be visible in PiP mode. However, if you prefer to disable the local feed in PiP mode, set includeLocalParticipantVideo to false:


StreamCallContainer(
    call: widget.call,
    callContentWidgetBuilder: (
        BuildContext context,
        Call call,
        ) {
      return StreamCallContent(
        call: call,
        callState: callState,
        pictureInPictureConfiguration: const PictureInPictureConfiguration(
          enablePictureInPicture: true,
          iOSPiPConfiguration: IOSPictureInPictureConfiguration(
            includeLocalParticipantVideo: false,
          )
        ),
      );
    },
  );
Enabling PiP support with custom call content widget
If you are not using our StreamCallContent and instead building custom call content widget you can still enable Picture in Picture mode by adding StreamPictureInPictureUiKitView anywhere in the widget tree. This widget will handle the Picture in Picture mode in iOS for you.


StreamCallContainer(
    call: widget.call,
    callContentWidgetBuilder: (
        BuildContext context,
        Call call,
        ) {
      return Stack(
        children: [
          StreamPictureInPictureUiKitView(call: call),
          // YOUR CUSTOM WIDGET
        ],
      );
    },
  );
Done. Now after leaving the app, you'll see that the call will be still alive in the background like the one below:

Picture in Picture example
In-App Picture in Picture
The system-level Picture in Picture described above only works when users navigate away from your app to other applications. It does not provide a floating video view within your own app when users navigate between different screens.

If you want to keep the call visible while users navigate within your app (for example, when browsing content, accessing chat, or using other features), you'll need to implement in-app picture-in-picture.

For a complete implementation guide with code examples, see our In-App Picture in Picture cookbook.





Screen Sharing
Introduction
During the duration of a call, participants may want to share either a portion of their screen, application or their entire screen to other users on the call. Stream Video makes it easy to support screensharing to other users natively on both Android and iOS devices.

In this guide, we will look at the steps required to configure screensharing on both platforms. If you are interested in screensharing for just one platform, you can skip to the Android or iOS section using this link.

iOS
Starting with iOS, there are two main options for screensharing from an iOS device. These are:

in-app screensharing - In this mode, the app's screen is only shared while the app is active or in the foreground. If the app is not in the foreground, screensharing is paused.
broadcasting - Using broadcasting mode allows the app to share the contents of the screen even when the application goes into the background.
Both of these options use Apple's framework ReplayKit (via flutter_webrtc) for broadcasting the user's screen.

Screen sharing dashboard
Before a user can share their screen, the call must have the screensharing capability configured via the Dashboard.

In-app sharing
In-app screensharing only shares the application's screens. While in a call, screensharing can be enabled by calling call.setScreenShareEnabled(enabled: true) method.


void startSharing() {
    // Checks to ensure the user can share their screen.
    final canShare = call.hasPermission(CallPermission.screenshare);
    if (canShare) {
      // Set screensharing to enabled
      call.setScreenShareEnabled(enabled: true);
    }
  }
If you use our UI components you can also add ToggleScreenShareOption as one of StreamCallControls option.

When the method is invoked, ReplayKit will ask for the user's consent that their screen will be shared. Only after the permission is granted, the screensharing starts.

Broadcasting
In most cases, you would need to share your screen while the app is in the background, to be able to open other apps. For this, you need to create a Broadcast Upload Extension.

Toggle screen sharing with broadcast mode
If you want to start screen sharing in broadcast mode on iOS you will need to toggle it by setting useiOSBroadcastExtension flag to true in ScreenShareConstraints. You can set the constraints inside ToggleScreenShareOption or when you use call.setScreenShareEnabled() directly.


const constraints = ScreenShareConstraints(
    useiOSBroadcastExtension: true,
);
...
ToggleScreenShareOption(
  ...
  screenShareConstraints: constraints,
),
//or
call.setScreenShareEnabled(enabled: true, constraints: constraints);
Add Broadcast Upload Extension
iOS requires the use of Broadcast Upload Extensions to facilitate screen sharing when your app is in the background. This extension provides the necessary framework to handle capturing and broadcasting the screen content.

Now add the extension, without UI, to your project in Xcode:

Screen sharing dashboard
Screen sharing dashboard
Make sure the deployment target for both your app and broadcast extension is set to iOS 14 or newer.

After you create the extension, there should be a class called SampleHandler, that implements the RPBroadcastSampleHandler protocol. Remove the protocol conformance and the methods, import our stream_video_screen_sharing, and make the SampleHandler a subclass of our class called BroadcastSampleHandler, that internally handles the broadcasting.

Screen sharing dashboard
To have access to our Handler implementation add stream_video_screen_sharing package to your app's pubspec.yaml file:


dependencies:
  stream_video_screen_sharing: ^<latest_version>
Then for native code to see it, add it as a dependency manually for the extension target in the Podfile file:


target 'YOUR_EXTENSION_NAME' do
  use_frameworks!
  pod 'stream_video_screen_sharing', :path => File.join('.symlinks', 'plugins', 'stream_video_screen_sharing', 'ios')
end
Replace YOUR_EXTENSION_NAME with the name of the extension you created.

Setup app groups
Add your extension to an app group by going to your extension's target in the project. In the Signings & Capabilities tab, click the + button in the top left and add App Groups. If you haven't done so already, add App Groups to your main app as well, ensuring that the App Group identifier is the same for both.

Update Info.plist
Finally, you should add a new entries in the Info.plist files. In both the app and the broadcast extension, add a key RTCAppGroupIdentifier with a value of the app group id and RTCScreenSharingExtension key with a value of a bundle id of your extension.

With that, the setup for the broadcast upload extension is done.

Android
The Stream Video SDK has support for screen sharing from an Android device. The SDK is using the Android Media Projection API for the capture. To initiate screen sharing, user consent is mandatory.

When using the ToggleScreenShareOption within thestream_video_flutter package, permission handling is seamlessly integrated. However, if you opt to initiate screen sharing via the setScreenShareEnabled() method on the Call object, you will be responsible for securing the necessary permissions and initiating a foreground service. The foreground service is essential for displaying a notification to the user while screen sharing is active. It is required to start media projection foreground service from Android version 10 onward.

From Android 14 onward, it is also required to actively ask users for a permission to share their screen. You can do this by calling call.requestScreenSharePermission() method. Below is an example snippet that demonstrates how to use our built in StreamBackgroundService class to manage these requirements:


void startScreemSharing() {
    if (CurrentPlatform.isAndroid) {
      // Check if the user has granted permission to share their screen
      if (!await call.requestScreenSharePermission()) {
        return;
      }
      // Start the screen sharing notification service
      await StreamBackgroundService()
          .startScreenSharingNotificationService(call);
    }
    // Enable screen sharing
    final result = await call.setScreenShareEnabled(
      enabled: true,
    );
    // Stop the screen sharing notification service if the operation failed
    if (CurrentPlatform.isAndroid && result.isFailure) {
      await StreamBackgroundService()
          .stopScreenSharingNotificationService();
    }
  }
Remember to stop the foreground service when the screen sharing is disabled:


void stopScreenSharing() async {
    final result = await call.setScreenShareEnabled(
      enabled: false,
    );
    if (CurrentPlatform.isAndroid) {
      await StreamBackgroundService()
          .stopScreenSharingNotificationService();
    }
  }
Customizing the screen sharing notification
You can customize the screen sharing notification content and behavior by initializing StreamBackgroundService. This allows you to handle notification taps and customize button actions:


StreamBackgroundService.init(
  StreamVideo.instance,
  onNotificationClick: (call) async {
    // Add any custom logic here if needed
  },
  onButtonClick: (call, type, serviceType) async {
    switch (serviceType) {
      case ServiceType.call:
        call.end();
      case ServiceType.screenSharing:
        StreamVideoFlutterBackground.stopService(ServiceType.screenSharing);
        call.setScreenShareEnabled(enabled: false);
    }
  },
);
For more details on customizing notifications, handling notification clicks, and required Android manifest configuration, see the Background modes guide.

Desktop (macOS, Windows, Linux)
For the Flutter Video and Audio SDK we don't officially support desktop, but many things already work out of the box and for some features we've made some small improvements to make it work better. On Desktop, users can have multiple screens, making it important to select what to share rather than sharing everything. Most apps allow users to choose between sharing a whole screen or a window of a single app. When running on web a browser will provide a selection screen for this.

When using the ToggleScreenShareOption your app will automatically show a dialog to select a screen or window to your users. However, you can fully customize this screen if you want to by setting the desktopScreenSelectorBuilder option.


ToggleScreenShareOption(
  ...
  desktopScreenSelectorBuilder: _customDesktopScreenShareSelector,
),
For the screen selector we have a helper class called ScreenSelectorStateNotifier which keeps track of the available screens or windows.

In the _customDesktopScreenShareSelector method we first build a state notifier. The _customDesktopScreenShareSelector will return a Future<DesktopCapturerSource?>. It's a nullable DesktopCapturerSource because we will return null if the screen selection is canceled.


Future<DesktopCapturerSource?> _customDesktopScreenShareSelector(
    BuildContext context) {
  final ScreenSelectorStateNotifier stateNotifier =
  ScreenSelectorStateNotifier(sourceTypes: [SourceType.Screen]);
  ...
}
We initialize the ScreenSelectorStateNotifier with a list of sourceTypes. The default is to share a screen, but you could also initialize the notifier with windows or both.

In this example we only give the user the option to share a screen and directly select the screen when we tap on it. For this we create a bottom sheet with a ValueListenableBuilder to listen to our state notifier.


Future<DesktopCapturerSource?> _customDesktopScreenShareSelector(
    BuildContext context) {
  final ScreenSelectorStateNotifier stateNotifier =
      ScreenSelectorStateNotifier(sourceTypes: [SourceType.Screen]);
  return showModalBottomSheet<DesktopCapturerSource?>(
    context: context,
    builder: (BuildContext context) {
      return ValueListenableBuilder(
        valueListenable: stateNotifier,
        builder:
            (BuildContext context, ScreenSelectorState value, Widget? child) => Container(),
      );
    },
  );
}
Lastly we use the prebuild ThumbnailGrid to show the thumbnails from the screens:


return ValueListenableBuilder(
        valueListenable: stateNotifier,
        builder:
            (BuildContext context, ScreenSelectorState value, Widget? child) =>
                Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ThumbnailGrid(
            sources: value.sources.values.toList(),
            selectedSource: value.selectedSource,
            onSelectSource: (source) => Navigator.pop(context, source),
          ),
        ),
      );
The ScreenSelectorState contains the sources, available sourceTypes and the currently selectedSource.

When you add UI to switch between SourceTypes Screen and Window you can use ScreenSelectorStateNotifier.setSourceType() to load other sources. You can also use ScreenSelectorStateNotifier.setSelectedSource(source) to update the notifier with the selected source. This only has impact on the state of the notifier, not on the actual screen sharing.

Screen audio sharing
Screen audio sharing is currently only available on Android. It requires Android 10 (API level 29) or above.

In addition to sharing your screen visually, you can also share audio playing on your device. This feature uses Android's AudioPlaybackCapture API to capture media playback audio, including sound from music players, video apps, games, and other media applications.

Enabling screen audio capture
To include screen audio when sharing your screen, set captureScreenAudio: true in ScreenShareConstraints:


final result = await call.setScreenShareEnabled(
  enabled: true,
  constraints: const ScreenShareConstraints(
    captureScreenAudio: true,
  ),
);
You can also pass these constraints to the ToggleScreenShareOption widget.

How screen audio works
Screen audio is mixed with microphone audio and transmitted together over the same audio track. This means both your voice and the device audio are sent to other participants simultaneously.

Screen audio sharing requires the microphone to be unmuted. When the microphone is muted, neither microphone nor screen audio will be transmitted.

When sharing music or other high-fidelity audio content, consider disabling noise cancellation temporarily to preserve audio quality.

Screen sharing settings
You can customize the screen sharing behavior by providing ScreenShareConstraints to the ToggleScreenShareOption widget or setScreenShareEnabled() method.

You can specify the following settings:

useiOSBroadcastExtension - Set to true to enable broadcast mode on iOS.

captureScreenAudio - Set to true to capture audio from the screen.

sourceId - The device ID of an audio source, if you want to capture audio from a specific source.

maxFrameRate - The maximum frame rate for the screen sharing video.

params - The video parameters for the screen sharing video.

For params you can use one of our predefined presets in RtcVideoParametersPresets.



Troubleshooting
There are several possible integration issues that can lead to calls not being established. This section will cover the most frequent ones.

Connection issues
Connection issues usually happen when you provide an invalid token during the SDK setup. When this happens, a web socket connection can't be established with our backend, resulting in errors when trying to connect to a call.

Ensure the token is valid and generated for the correct user.
Verify that the token matches the user ID specified during the initialization of the StreamVideo instance.
During development, hardcoded tokens often lead to mismatches. Always ensure the token corresponds to the user currently being initialized.

Expired tokens
When you initialize the StreamVideo object, you provide a token, as described here. The tokens generated in the docs have an expiry date, therefore please make sure to always use a token with a valid expiry date. You can check the contents of a JWT token on websites like this one.

Additionally, when expiring tokens are used, you need to provide a tokenLoader when creating StreamVideo, that will be invoked when the existing token expires. This is your chance to update the token by calling your backend.

Wrong secret for token generation
When you start integrating the SDK into your app, you might copy-paste the token from the docs into your project. However, that will not work. Tokens are generated with the help of the app secret (available in your dashboard), and are unique per app id. Your app id is different than the demo apps we have as examples in our docs.

On website like this one, you can verify if the token is signed with the correct signature.

While developing, you can manually generate tokens by providing your secret and the user's ID here. However, note that for production usage, your backend would need to generate these tokens.

Third-party network debuggers
There are network debuggers like Wormholy, that allow you to see all the network requests done with your app. However, some of them can interfere and block our web socket connection, like in this case. In order to prevent this, you need to exclude our hosts from debugger tools, as described on the linked issue.

Members in a call
One common issue is that you only specify one user and try to call the same user on another device. This will not work, if you are the caller, you will not receive a notification that you're being called - you can't call yourself.

As you would do it in the real world, you would need to specify another member (or members) that you want to call. Another important note - that member should also exist in Stream's platform (it must have connected at least once). This is needed because we need to know the user's device and where to send the call notification.

Reusing a call id
Call IDs in general can be reused - you can join a call with the same id many times. However, the ringing is done only once per call ID. Therefore, if you implement calls with ringing, make sure that you provide a unique ID every time, in order for the ring functionality to work. One option is to use a UUID as a call ID.

(iOS) CallKit integration issues
If you followed the CallKit guide, and still have issues, here are some troubleshooting steps:

make sure there are no connection issues (see points above)
make sure you don't have a Do Not Disturb focus turned on (or any other focus that might block CallKit)
check if the generated VoIP certificate matches the bundle id specified in the dashboard
check if the app is using the correct bundle id that also corresponds to the bundle id set for APN provider
make sure you selected Apple Push Notification service SSL (Sandbox & Production) instead of Apple Push Notification service SSL (Sandbox) when creating a Push notification service on developer.apple.com
check if you have created push providers and you specified their correct names when creating the SDK
check the "Webhook & Push Logs" section on the dashboard to see if there are any push notification failures
make sure the app has Push Notifications Capability added in Xcode
check if correct background modes are set in Xcode (processing, remote-notification, voip)
try sending a hardcoded VoIP notification using a third-party service, to make sure your app integration is correct
Note that if you have failed to report a VoIP notification to CallKit, the operating system may stop sending you notifications. In those cases, you need to re-install the app and try again.

Logs
For further debugging, you can turn on more detailed logging. In order to do that, specify a logPriority when creating StreamVideo` instance.


StreamVideo(
    ...,
    options: const StreamVideoOptions(
      logPriority: Priority.verbose,
    ),
  );



  Video filters
A very common use case during a video call is to apply some effect on our backgrounds. Those backgrounds can vary but the most common ones are blurring and adding a static image. Our SDK offers background blurring and virtual backgrounds with static images out of the box and also has support for injecting your custom filter into the calling experience. In this guide, we will show you how to apply video filters to a video stream.

Using the background video filters provided by the SDK
Step 1 - Adding the dependency
Video filters are part of a separate stream_video_filters package so make sure you have it in your app's pubspec.yaml


dependencies:
  stream_video_filters: ^latest
The package adds the required native modules for processing the video stream and manipulating it with your desired video filter.

Step 2 - Use the StreamVideoEffectsManager to control the filters
Background filters are controlled using StreamVideoEffectsManager. It is responsible for making sure relevant processors are registered and for applying and disabling filters to the video track.

A basic usage looks like this:


import 'package:stream_video_filters/video_effects_manager.dart';
final videoEffectsManager = StreamVideoEffectsManager(call);
// Apply blur effect
videoEffectsManager.applyBackgroundBlurFilter(BlurIntensity.light);
videoEffectsManager.applyBackgroundBlurFilter(BlurIntensity.medium);
videoEffectsManager.applyBackgroundBlurFilter(BlurIntensity.heavy);
// Apply virtual background effect
videoEffectsManager.applyBackgroundImageFilter('assets/backgroundImage.jpg')
videoEffectsManager.applyBackgroundImageFilter('https://picsum.photos/id/192/2352/2352')
// Disable all applied filters
videoEffectsManager.disableAllFilters();
In iOS, the background video filters are supported only on iOS 15 and above. However, the iOS platform's minimum level of support for the custom filters that you may add depends on what APIs you would use.

Preview of background blur filter	Preview of background image replacement filter
Preview of the background blur filter
Preview of background image replacement filter
Advanced: adding custom video filters
Step 1 - Add your custom filter natively in Android and iOS

Android

iOS
To create a new video filter, you need to implement the VideoFrameProcessorFactoryInterface from stream_webrtc_flutter package. A simple example that applies rotation to the video filter would be like the following:


import io.getstream.webrtc.flutter.videoEffects.VideoFrameProcessor
import io.getstream.webrtc.flutter.videoEffects.VideoFrameProcessorFactoryInterface
import org.webrtc.VideoFrame
class RotationFilterFactory : VideoFrameProcessorFactoryInterface {
    override fun build(): VideoFrameProcessor {
        return VideoFrameProcessor { frame, textureHelper ->
            VideoFrame(
                frame.buffer.toI420(),
                180, // apply rotation to the video frame
                frame.timestampNs
            )
        }
    }
}
To implement a video filter with Bitmap, create a class by extending a filter that extends from BitmapVideoFilter abstract class. This BitmapVideoFilter abstract class gives you a Bitmap for each video frame, which you can manipulate directly. By returning a new VideoFrameProcessorWithBitmapFilter instance with that filter we can implement a bitmap processing filter.

BitmapVideoFilter is less performant than a normal video filter that does not use bitmaps. It is due to the overhead of certain operations, like YUV <-> ARGB conversions.

Example: grayscale video filter
We can create and set a simple video filter that turns the video frame to grayscale by extending a filter that extends from BitmapVideoFilter abstract class like this:


import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import io.getstream.webrtc.flutter.videoEffects.VideoFrameProcessor
import io.getstream.webrtc.flutter.videoEffects.VideoFrameProcessorFactoryInterface
import io.getstream.video.flutter.stream_video_filters.common.VideoFrameProcessorWithBitmapFilter
import io.getstream.video.flutter.stream_video_filters.common.BitmapVideoFilter
class GrayScaleVideoFilterFactory : VideoFrameProcessorFactoryInterface {
  override fun build(): VideoFrameProcessor {
    return VideoFrameProcessorWithBitmapFilter {
      GrayScaleFilter()
    }
  }
}
private class GrayScaleFilter : BitmapVideoFilter() {
    override fun applyFilter(videoFrameBitmap: Bitmap) {
        val canvas = Canvas(videoFrameBitmap)
        val paint = Paint().apply {
            val colorMatrix = ColorMatrix().apply {
                // map the saturation of the color to grayscale
                setSaturation(0f)
            }
            colorFilter = ColorMatrixColorFilter(colorMatrix)
        }
        canvas.drawBitmap(videoFrameBitmap, 0f, 0f, paint)
    }
}
Step 2 - Register this filter in your native module
Now you have to add a method in your app to register this video filter in the stream_webrtc_flutter library. The registration is done on the native side but it has to be accessed from your app's Dart code. To accomplish this we will use platform channel.

First, create a MethodChannel on the Dart side:


static const platform = MethodChannel('sample.app.channel');
Future<void> registerGreyscaleEffect() async {
  await platform.invokeMethod('registerGreyscaleEffect');
}
Then implement the corresponding methods on the native side. This code will register the previously created grayscale filter into ProcessorProvider and enable its usage later.


Android

iOS

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.getstream.webrtc.flutter.videoEffects.ProcessorProvider
class MainActivity: FlutterActivity() {
    private val CHANNEL = "sample.app.channel"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "registerGreyscaleEffect") {
                ProcessorProvider.addProcessor("grayscale", GrayScaleVideoFilterFactory())
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
NOTE While calling the addProcessor method. We need to provide a name to the filter that we are registering. In the above example, it is grayscale. This name will be later used when appling the filter.

Step 3 - Apply the video filter in Dart
To apply this video filter, simply call the applyCustomEffect() method on the StreamVideoEffectsManager instance, providing the name of the previously registered video processor (in this case, grayscale). Additionally, you need to pass the registerEffectProcessorCallback, which will be invoked to register the processor on the native side. We will use the previously created registerGreyscaleEffect() method that utilizes the method channel for this purpose.


final videoEffectsManager = StreamVideoEffectsManager(call);
// Apply custom video filter
videoEffectsManager.applyCustomEffect(
  'grayscale',
  registerEffectProcessorCallback: () async {
    await registerGreyscaleEffect();
  });
// Disable all applied filters
videoEffectsManager.disableAllFilters();
Below is a preview of the above grayscale video filter:

Preview of the grayscale video filter




Recording
A key feature of modern communication tools is the ability to quickly and easily record calls. This functionality is used for everything from quality assurance and training to legal compliance or simply as a matter of convenience for keeping track of conversations and later reviewing them.

In this guide, we will look at how developers using Stream Video can easily record their calls using our Flutter SDK. We will cover the technical details involved in starting, stopping, and observing the state of the call recording.

Recording
The Call object provides access to the recording API, enabling you to start and stop call recordings. To initiate recording, you can use the call.startRecording method on the active call object. Additionally, you can check the current recording status by accessing the callState.isRecording property. Monitoring this property allows you to update your application's UI to indicate whether the current call is being recorded.


StreamCallContent(
  call: call,
  callState: callState,
  callControlsWidgetBuilder: (context, call) {
    final recording = callState.isRecording; // `isRecording` tells us whether the call is currently being recorded
    return StreamCallControls(options: [
      // We can add a custom call option which can be used to start and stop recording
      CallControlOption(
        icon: recording
            ? const Icon(Icons.emergency_recording,
                color: Colors.red)
            : const Icon(Icons.emergency_recording,
                color: Colors.grey),
        onPressed: () {
          if (!recording) {
            // If we are not recording, we can start recording the current call
            call.startRecording();
          } else {
            // If we are recording, we can stop recording the current call
            call.stopRecording();
          }
        },
      ),
    ]);
  },
);
Permissions
Before the user is allowed to start recording, the user must have the corresponding permissions. As a form of best practice, we encourage integrators to check the permissions before allowing users to execute a given action. Permissions for each app and user role can be found on the Stream dashboard. Please visit https://dashboard.getstream.io/ to view and change the permission scope for your app.

Retrieving the call recordings
The call recording data can be retrieved by calling the listRecordings() method of Call class. By default, this method will use the current call id (CID) to look up the recordings for the current call session. The method returns List<CallRecording> which allows you to loop over the different recording objects.

You can also call the listRecordings() method on the StreamVideo instance and specify the cid of the call you want to retrieve recordings for.

Multiple recordings can be made during a single call session, and a single call CID can also be reused for multiple sessions.



Screenshots
You can take a picture of a VideoTrack at highest possible resolution. This can be useful for example if you want to take a screenshot of a screenshare at full resolution.


final participant = call.state.value.otherParticipants.first;
final screenshot = call.takeScreenshot(participant);
In case you want to take a screenshot of a screen-sharing track, you can specify which track type you want to capture:


final participant = call.state.value.otherParticipants.first;
final screenshot = call.takeScreenshot(participant, trackType: SfuTrackType.screenShare);



Background modes
Ensuring that calls continue seamlessly when the app is in the background is essential for delivering a reliable and smooth user experience. On this page, you will learn how to make sure that calls remain active in the background on both Android and iOS.

Keep Stream's connections open
To ensure that calls work seamlessly in the background, you need to configure Stream's internal connections to stay open. Achieve this by setting the keepConnectionsAliveWhenInBackground flag to true when initializing the StreamVideo instance.


StreamVideo(
    ...,
    options: const StreamVideoOptions(
      muteAudioWhenInBackground: true, //Set to your preference
      muteVideoWhenInBackground: true, //Set to your preference
      keepConnectionsAliveWhenInBackground: true, //Ensure this is set to true
);
Android
The Stream Video Flutter SDK includes a dedicated service to keep calls active in the background, allowing users to multitask seamlessly.

Starting the Android foreground service
The Stream Video Flutter SDK ensures continuous calls by initiating an Android foreground service. This service keeps the process active and the call running, even if the application's UI is no longer visible. The SDK already provides the required declarations in the manifest, all you have to do is to initialize the service somewhere after starting the app.


StreamBackgroundService.init(
      StreamVideo.instance,
);
Our foreground service displays a notification indicating an ongoing call. This notification allows users to either exit the call or seamlessly return to it. It appears during active calls and vanishes when the user leaves the call.

Active call notification
Screen sharing notification
When a user shares their screen, the SDK displays a notification to indicate that the screen is being shared. This notification allows users to either stop sharing their screen or return to the call. It appears during active screen sharing and vanishes when the user stops sharing their screen.

Screen sharing notification
Customizing the notification
You can customize the notification by providing your own notification options. The SDK provides default options for both the call and screen sharing notifications. You can override these options by passing your own NotificationOptionsBuilder to the init method.


StreamBackgroundService.init(
      StreamVideo.instance,
      callNotificationOptionsBuilder: (call) {
        return const NotificationOptions(
          content: NotificationContent(
            title: 'Call Active',
            text: 'You are in a call',
          ),
          avatar: NotificationAvatar(
            url: '{url_to_avatar}',
          ),
        );
      },
);
Handling notification clicks
You can handle notification clicks by providing callbacks to the init method. The callbacks are triggered when the user taps on the notification or on a notification button. You can use these callbacks to bring the call back to the foreground, cancel the call or perform any other action.

Handling notification tap
To handle when a user taps on the notification body (not the action buttons), use the onNotificationClick callback. By default, tapping the notification brings the app to the foreground where the call screen is typically already active. Use this callback if you need to perform any additional custom logic:


StreamBackgroundService.init(
  StreamVideo.instance,
  onNotificationClick: (call) async {
    // Add any custom logic here if needed
  },
);
For the notification tap to bring the app to the foreground on Android, you must add the following intent-filter to your MainActivity in AndroidManifest.xml:


<activity
    android:name=".MainActivity"
    ...>
    <!-- Add this intent filter for Stream notification clicks -->
    <intent-filter>
        <action android:name="${applicationId}.intent.action.STREAM_CALL"/>
        <category android:name="android.intent.category.DEFAULT"/>
    </intent-filter>
</activity>
Without this intent-filter, tapping the notification will not bring the app to the foreground.

Handling notification button tap
By default, the SDK handles button tap by canceling the call when the user taps on the call notification and canceling screen-sharing when tapped on the screen-sharing notification. You can override this behavior by providing your own onButtonClick callback:


StreamBackgroundService.init(
  StreamVideo.instance,
  onButtonClick: (call, type, serviceType) async {
    switch (serviceType) {
      case ServiceType.call:
        // Add or replace with custom behavior
        await call.leave();
        await call.reject(reason: CallRejectReason.cancel());
      case ServiceType.screenSharing:
        // Add or replace with custom behavior
        StreamVideoFlutterBackground.stopService(ServiceType.screenSharing);
        call.setScreenShareEnabled(enabled: false);
    }
  },
);
Required permissions
We require the following permissions to create an appropriate foreground service: FOREGROUND_SERVICE, FOREGROUND_SERVICE_PHONE_CALL, and FOREGROUND_SERVICE_MICROPHONE. Additionally, the FOREGROUND_SERVICE_MEDIA_PROJECTION permission is necessary for the screen sharing functionality. They are added out-of-the-box as part of our stream_video_flutter package.

Because of the foreground service type it requires a microphone (RECORD_AUDIO) permission to be enabled. Make sure the user grants the permission before beginning the call, otherwise the service will not be able to start.

iOS
iOS background modes provide the necessary framework to maintain connectivity, handle incoming calls, and manage ongoing calls even when the app isn't in the foreground. By using the appropriate background modes, your app can stay responsive to call events without being suspended by the system.

Enabling background modes
In Xcode, go to your app's target, select the Signing & Capabilities tab.

Click the + Capability button and add Background Modes.

Check the relevant background modes, specifically:

Audio, AirPlay, and Picture in Picture: For ongoing audio/video calls while the app is in the background.
Voice over IP (VoIP): This mode is critical for managing incoming and ongoing voice calls.
Remote notifications
Background processing
Active call notification
Info.plist
Make sure to add relevant permissions to your Info.plist file as well as the BGTaskSchedulerPermittedIdentifiers to support background tasks.


<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your camera for video calls.</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) needs access to your microphone for voice and video calls.</string>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
	 <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
</array>
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
	<string>processing</string>
	<string>remote-notification</string>
	<string>voip</string>
</array>
Picture in Picture (PiP)
To enhance the user experience even more, consider enabling Picture in Picture (PiP) mode. PiP allows users to continue watching videos or participating in calls while using other apps. The Stream Video Flutter SDK supports PiP mode on both iOS and Android, making it easy to enable this feature in your app. Check out our Picture in Picture guide to learn more.




Custom Data
Custom data is additional information that can be added to the default data of Stream. It is a dictionary of key-value pairs that can be attached to users, events, and pretty much almost every domain model in the Stream SDK.

In the SDK, custom data is represented by the Map<String, Object>. This means that the key must be a string and the value can be any object.

Adding Custom Data
Adding extra data can be done through the Server-Side SDKs or through the Client SDKs. In the Flutter Stream Video SDK, you can add extra data when creating/updating a call, updating a user and sending event or reaction.

Example of updating the call custom data

call.update(custom: {'mycustomfield': 'mycustomvalue'});
Example of sending a reaction with custom data

call.sendReaction(
  reactionType: 'raise-hand',
  emojiCode: ':smile:',
  custom: {'mycustomfield': 'mycustomvalue'},
);
Example of sending a custom event with custom data

call.sendCustomEvent(
  eventType: 'my-custom-event',
  custom: {'mycustomfield': 'mycustomvalue'},
);
Example of updating the user custom data while initializing the StreamVideo

StreamVideo(
  apiKey,
  user: User.regular(userId: 'userId', extraData: {'mycustomfield': 'mycustomvalue'}),
  userToken: token,
);
Reading Custom Data
​Reading the custom data is as simple as accessing the custom field of the object. For example, to read the custom data of a reaction, you can access the custom field of the reaction event object.


call.callEvents.listen((event) {
  if (event is StreamCallReactionEvent) {
    final customData = event.custom;
  }
});
For Call object the custom data is stored in call metadata that can be accessed when calling getOrCreate() or get() method.


final result = await call.getOrCreate();
final customData = result.fold(
   success: (success) => success.data.data.metadata.details.custom,
   failure: (_) => null,
);
//or
final result = await call.get();
final customData = result.fold(
   success: (success) => success.data.metadata.details.custom,
   failure: (_) => null,
);



Manual Video Quality Selection
By default, our SDK chooses the incoming video quality that best matches the size of a video element for a given participant. It makes less sense to waste bandwidth receiving Full HD video when it's going to be displayed in a 320 by 240 pixel rectangle.

However, it's still possible to override this behavior and manually request higher resolution video for better quality, or lower resolution to save bandwidth. It's also possible to disable incoming video altogether for an audio-only experience.

Overriding Preferred Resolution
To override the preferred incoming video resolution, use the call.setPreferredIncomingVideoResolution method:


await call.setPreferredIncomingVideoResolution(VideoDimension(width: 640, height: 480));
Actual incoming video quality depends on a number of factors, such as the quality of the source video, and network conditions. Manual video quality selection allows you to specify your preference, while the actual resolution is automatically selected from the available resolutions to match that preference as closely as possible.

It's also possible to override the incoming video resolution for only a selected subset of call participants. The call.setPreferredIncomingVideoResolution() method optionally takes a list of participant session identifiers as its optional argument. Session identifiers can be obtained from the call participant state:


final [first, second, ..._] = call.state.value.otherParticipants;
// Set preferred incoming video resolution for the first two participants only:
await call.setPreferredIncomingVideoResolution(
  VideoDimension(width: 640, height: 480),
  sessionIds: [first.sessionId, second.sessionId],
);
Calling this method will enable incoming video for the selected participants if it was previously disabled.

To clear a previously set preference, pass null instead of resolution:


// Clear resolution preference for selected participants:
await call.setPreferredIncomingVideoResolution(
  null,
  sessionIds: [
    participant.sessionId,
  ],
);
// Clear resolution preference for all participants:
await call.setPreferredIncomingVideoResolution(null);
Disabling Incoming Video
To completely disable incoming video (either to save data, or for an audio-only experience), use the call.setIncomingVideoEnabled() method:


await call.setIncomingVideoEnabled(false);
To enable incoming video again, pass true as an argument:


await call.setIncomingVideoEnabled(true);
Calling this method will clear the previously set resolution preferences




Session Timers
A session timer allows you to limit the maximum duration of a call. The duration can be configured for all calls of a certain type, or on a per-call basis. When a session timer reaches zero, the call automatically ends.

Creating a call with a session timer
Let's see how to create a single call with a limited duration:


final call = client.makeCall(callType: StreamCallType.defaultType(), id: 'REPLACE_WITH_CALL_ID');
await call.getOrCreate(
  limits: const StreamLimitsSettings(
    maxDurationSeconds: 3600,
  ),
);
This code creates a call with a duration of 3600 seconds (1 hour) from the time the session is starts (a participant joins the call).

After joining the call with the specified maxDurationSeconds, you can examine a call state's timerEndsAt field, which provides the timestamp when the call will end. When a call ends, all participants are removed from the call.


await call.join();
print(call.state.value.timerEndsAt);
Extending a call
​You can also extend the duration of a call, both before or during the call. To do that, you should use the call.update method:


final duration =
    call.state.value.settings.limits.maxDurationSeconds! + 60;
call.update(
  limits: StreamLimitsSettings(
    maxDurationSeconds: duration,
  ),
);
If the call duration is extended, the timerEndsAt is updated to reflect this change. Call participants will receive the call.updated event to notify them about this change.



SDK Size Impact
SDK Size Impact
When developing a mobile app, one crucial performance metric is app size. An app’s size can be difficult to accurately measure with multiple variants and device spreads. Once measured, it’s even more difficult to understand and identify what’s contributing to size bloat.

We regularly track and update the sizes of our packages that are part of our video product. This information is displayed with badges at the top of our GitHub repository.

It's important to note that the actual impact of these packages on your app's size is likely to be significantly smaller than the reported sizes. This is due to two key factors:

Shared Dependencies: You may already be using some of the dependencies included in our packages, reducing additional size overhead.
Tree Shaking Optimization: During compilation, Flutter performs tree shaking, an optimization process that removes unused code. This ensures your app only includes the code you actively use, discarding unnecessary parts and reducing overall size.
For precise insights into how any package impacts your app's size, refer to tthis official Flutter guide.



Multiple Simultaneous Calls Support
The Stream Video Flutter SDK allows users to handle multiple active video calls at the same time. This guide explains how to enable and work with multiple simultaneous calls in your application.

Default Behavior: Single Active Call
By default, the SDK operates in single active call mode (allowMultipleActiveCalls = false):

Only one call can be active at a time
Accepting a new call automatically ends any existing active call
Access the current active call using StreamVideo.activeCall
Monitor active call changes with StreamVideo.listenActiveCall()
Enabling Multiple Active Calls
To support multiple simultaneous calls, set allowMultipleActiveCalls to true when initializing the StreamVideo client:


final streamVideo = StreamVideo(
  apiKey: 'your-api-key',
  user: user,
  userToken: userToken,
  options: const StreamVideoOptions(
    allowMultipleActiveCalls: true,
  ),
);
Working with Multiple Active Calls
When multiple active calls are enabled, the API behavior changes:

Single Call Mode (Default)
Use StreamVideo.activeCall to access the current active call
Use StreamVideo.activeCalls to get a list containing 0 or 1 call
Use StreamVideo.listenActiveCall() to monitor the active call
Multiple Calls Mode
Do not use StreamVideo.activeCall (throws an exception)
Use StreamVideo.activeCalls to get a list of all active calls
Use StreamVideo.listenActiveCalls() to monitor currently active calls
New calls are added to the existing list without terminating others
Platform-Specific Behavior
Android Background Services
When multiple calls are enabled on Android:

Each active call displays its own foreground service notification
Screen sharing services operate independently for each call
When multiple active calls are enabled, you must provide the callCid parameter when managing foreground services to specify which call's service to control:


// Stop service for a specific call
StreamVideoFlutterBackground.stopService(
  ServiceType.call,
  callCid: callCid
);
Without the callCid, the SDK cannot determine which call's service to manage.

Related Features
When managing multiple active calls, consider using In-App Picture-in-Picture to provide a better user experience. PiP mode allows users to minimize calls to a small overlay window while continuing other activities in your app, making it easier to handle multiple simultaneous calls.



Handling System Audio Interruptions
Audio interruptions are a common occurrence on mobile devices that can disrupt ongoing video calls. The Stream Video Flutter SDK provides built-in support for handling these interruptions gracefully, allowing you to maintain a smooth user experience even when external audio events occur.

What are Audio Interruptions?
Audio interruptions happen when the system or other applications take over the audio session, temporarily pausing or stopping your app's audio. Common examples include:

iOS Interruptions
Incoming phone calls
Siri activation
Alarm or timer sounds
Audio from other apps taking over (e.g., voice memo, navigation apps)
Android Interruptions
The interruption sources depend on the configured AndroidInterruptionSource:

With Audio Focus:

Other media apps interrupting (e.g., Spotify, YouTube)
Assistant voice prompts (e.g., Google Assistant)
Alarms and notifications
With Telephony:

Phone calls (requires READ_PHONE_STATE permission)
Basic Implementation
The SDK provides the handleCallInterruptionCallbacks method through RtcMediaDeviceNotifier to manage audio interruptions.

In this example, we disable the microphone during an interruption:


import 'package:stream_video_flutter/stream_video_flutter.dart';
bool? _microphoneEnabledBeforeInterruption;
void _handleMobileAudioInterruptions() {
  if (!CurrentPlatform.isMobile) return;
  RtcMediaDeviceNotifier.instance.handleCallInterruptionCallbacks(
    onInterruptionStart: () {
      // Mute the microphone when the interruption starts
      final call = StreamVideo.instance.activeCall;
      _microphoneEnabledBeforeInterruption =
            call?.state.value.localParticipant?.isAudioEnabled;
      call?.setMicrophoneEnabled(enabled: false);
    },
    onInterruptionEnd: () {
      // Unmute the microphone when the interruption ends
      if (_microphoneEnabledBeforeInterruption == true) {
        StreamVideo.instance.activeCall?.setMicrophoneEnabled(enabled: true);
      }
      _microphoneEnabledBeforeInterruption = null;
    },
    androidInterruptionSource: AndroidInterruptionSource.audioFocusAndTelephony,
  );
}
When multiple active calls are enabled, use StreamVideo.instance.activeCalls instead.

In this example, we mute audio playout during a phone call:


import 'package:stream_webrtc_flutter/stream_webrtc_flutter.dart' as rtc;
import 'package:stream_video_flutter/stream_video_flutter.dart';
void _handleMobileAudioInterruptions() {
  if (!CurrentPlatform.isMobile) return;
  RtcMediaDeviceNotifier.instance.handleCallInterruptionCallbacks(
    onInterruptionStart: () {
      rtc.Helper.pauseAudioPlayout();
    },
    onInterruptionEnd: () {
      rtc.Helper.resumeAudioPlayout();
    },
    androidInterruptionSource: AndroidInterruptionSource.telephonyOnly,
  );
}
On Android, audio focus may not be restored automatically. To ensure you receive onInterruptionEnd, explicitly call rtc.Helper.regainAndroidAudioFocus(); (for example, when the app resumes from background).

Method Parameters
handleCallInterruptionCallbacks

Future<void> handleCallInterruptionCallbacks({
  void Function()? onInterruptionStart,
  void Function()? onInterruptionEnd,
  AndroidInterruptionSource androidInterruptionSource =
      AndroidInterruptionSource.audioFocusAndTelephony,
})
Parameters:

onInterruptionStart: Callback function executed when an audio interruption starts
onInterruptionEnd: Callback function executed when an audio interruption ends
androidInterruptionSource: Specifies which interruption sources to monitor on Android
On Android, you can filter interruptions for audio and/or telephony; on iOS, all interruptions are enabled.

Android Interruption Sources

enum AndroidInterruptionSource {
  audioFocusOnly,           // Monitor audio focus changes only
  telephonyOnly,           // Monitor phone calls only
  audioFocusAndTelephony, // Monitor both (default)
}
Platform Setup
iOS
No additional configuration is required for iOS. The SDK integrates with the system audio session and handles interruption events for you.

Android Permissions
To handle phone call interruptions on Android, add the following permissions to your android/app/src/main/AndroidManifest.xml:


<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
Runtime Permission Request
Request the phone permission at runtime for Android:


import 'package:permission_handler/permission_handler.dart';
void _requestPermissions() async {
  if (CurrentPlatform.isAndroid) {
    await Permission.phone.request();
  }
}
Best Practices
1. Initialize Early
Set up interruption handling as early as possible in your app lifecycle:


@override
void initState() {
  super.initState();
  _handleMobileAudioInterruptions();
}
2. Platform Check
Always check if the platform is mobile before setting up interruption handling:


void _setupInterruptions() {
  if (!CurrentPlatform.isMobile) return;
  // Setup interruption handling
}
3. Graceful Degradation
Handle cases where permissions might not be granted:


void _setupWithPermissionCheck() async {
  if (CurrentPlatform.isAndroid) {
    final phonePermission = await Permission.phone.status;
    if (phonePermission.isDenied) {
      // Handle telephony interruptions only if permission is granted
      await Permission.phone.request();
    }
  }
  _handleMobileAudioInterruptions();
}
4. Explain Permissions
Requesting low‑level permissions such as READ_PHONE_STATE can worry users. Onboard users first and explain why the permission is needed before requesting it.




Call Preferences Configuration
Call preferences allow you to configure various aspects of call behavior and performance. These settings control timeouts, reaction behavior, statistics reporting, and other call-specific functionality that affects the user experience during video calls.

Accessing Call Preferences
You can access the current preferences through the call state:


var preferences = call.state.value.preferences;
Available Preference Properties
Property	Type	Default Value	Description
connectTimeout	Duration	Duration(seconds: 60)	The maximum duration to wait when establishing a connection to the call. If the connection is not established within this timeout, the connection attempt will be cancelled.
reconnectTimeout	Duration	Duration(seconds: 30)	The maximum duration to wait when reconnecting to the call. If the connection is not established within this timeout, the reconnection attempt will be cancelled and the user will disconnect from the call.
networkAvailabilityTimeout	Duration	Duration(seconds: 10)	The maximum duration to wait for network availability before timing out. If the network is not available within this timeout, the call will be considered disconnected.
reactionAutoDismissTime	Duration	Duration(seconds: 5)	The duration after which call reactions (like emoji reactions) automatically disappear from the UI.
callStatsReportingInterval	Duration	Duration(seconds: 2)	The interval at which call statistics are reported and updated. This controls how frequently metrics like bandwidth, latency, and quality statistics are collected and reported.
dropIfAloneInRingingFlow	bool	true	Whether to automatically drop the call if the user is alone in the ringing flow. When true, if all participants leave the call initiated by ringing, the call will be automatically ended.
closedCaptionsVisibilityDurationMs	int	2700	The duration in milliseconds that closed captions remain visible on screen before being automatically hidden.
closedCaptionsVisibleCaptions	int	2	The maximum number of closed caption lines that can be visible simultaneously on screen.
clientPublishOptions	ClientPublishOptions?	null	Configuration options for client-side publishing settings. Manually setting preferred codec can cause call stability/compatibility issues. Use with caution.
Setting Custom Call Preferences
You can customize call preferences when creating a call:


final call = streamVideo.makeCall(
  callType: StreamCallType.defaultType(),
  id: 'my-call-id',
  preferences: DefaultCallPreferences(
    connectTimeout: Duration(seconds: 30),
    reactionAutoDismissTime: Duration(seconds: 3),
    dropIfAloneInRingingFlow: false,
    closedCaptionsVisibleCaptions: 3,
    closedCaptionsVisibilityDurationMs: 5000,
  ),
);
Updating Call Preferences During a Call
You can update call preferences during an active call:


call.updateCallPreferences(
  DefaultCallPreferences(
    reactionAutoDismissTime: Duration(seconds: 10),
    closedCaptionsVisibleCaptions: 4,
  ),
);
Advanced Video Publishing Options
The clientPublishOptions property allows you to control prefered video codec selection. Don't use it unless you know what you are doing. Manually setting preferred codec can cause call stability/compatibility issues. Use with caution.

Client Publish Options
Configure video codec and quality settings:


final call = streamVideo.makeCall(
  callType: StreamCallType.defaultType(),
  id: 'my-call-id',
  preferences: DefaultCallPreferences(
    clientPublishOptions: ClientPublishOptions(
      preferredCodec: PreferredCodec.h264,
      fmtpLine: 'level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f',
      preferredBitrate: 1500000,
      maxSimulcastLayers: 3,
    ),
  ),
);
Client Publish Options Properties
Property	Type	Description
preferredCodec	PreferredCodec?	Preferred video codec for publishing (VP8, H264, VP9, AV1).
fmtpLine	String?	Format parameters line for the video codec.
preferredBitrate	int?	Preferred bitrate in bits per second for video publishing.
maxSimulcastLayers	int?	Maximum number of simulcast layers to publish.
subscriberCodec	PreferredCodec?	Preferred codec for receiving video streams.
subscriberFmtpLine	String?	Format parameters line for the subscriber codec.


Network Disruptions
Connection problems can occur during a call, for example when switching networks or if the signal is poor. In this case the SDK will try to reconnect automatically.

Automatic Reconnection
The Stream Video Flutter SDK provides a reliable reconnection system that automatically handles network disruptions. When connection issues occur, the SDK will:

Detect network changes and connection failures
Automatically attempt to reconnect using the most appropriate strategy
Maintain call quality with minimal disruption to users
Provide status updates throughout the reconnection process
Configuration Options
You can customize the reconnection behavior using CallPreferences:

reconnectTimeout
Controls how long the SDK will attempt to reconnect before giving up. By default, this is set to Duration.zero (unlimited - will retry indefinitely). When this timeout is exceeded, reconnection stops and call status becomes CallStatusReconnectionFailed.

networkAvailabilityTimeout
How long to wait for network connectivity to be restored during a reconnection attempt. This defaults to Duration(minutes: 5) and prevents waiting indefinitely for network in poor coverage areas.

connectTimeout
Maximum time to wait when establishing the initial connection to a call. The default is Duration(seconds: 60) which provides faster feedback in poor network conditions.


final preferences = DefaultCallPreferences(
  reconnectTimeout: const Duration(minutes: 2),
  networkAvailabilityTimeout: const Duration(minutes: 3),
  connectTimeout: const Duration(seconds: 30),
);
final streamVideo = StreamVideo(
  'api_key',
  user: user,
  userToken: token,
  options: StreamVideoOptions(
    defaultCallPreferences: preferences,
  ),
);
Monitoring Reconnection Status
Monitor the reconnection process by observing call status changes using partialState:


call.partialState((state) => state.status).listen((status) {
  switch (status) {
    case CallStatusConnecting():
      // Initial connection
      break;
    case CallStatusReconnecting():
      // Reconnection in progress
      break;
    case CallStatusReconnectionFailed():
      // Reconnection failed - handle accordingly
      break;
    case CallStatusConnected():
      // Successfully connected
      break;
  }
});






