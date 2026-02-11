import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Top-level notification tap handler.
/// Used by main.dart when initializing the plugin globally.
void onLocalNotificationTap(NotificationResponse response) {
  debugPrint('👆 [PUSH] Notification tapped: ${response.payload}');
}

/// Service that handles push notifications for Stream Chat.
///
/// Two notification paths:
///
/// **Path 1 – Real-time (WebSocket):**
///   Listens to BOTH `message.new` AND `notification.message_new` events on
///   the Stream Chat client. Shows a local notification instantly unless the
///   user is currently viewing that channel.
///
///   - `message.new` fires when a channel is being actively watched.
///   - `notification.message_new` fires when the user is a member but NOT
///     watching (e.g. on home screen).
///
/// **Path 2 – FCM (Firebase Cloud Messaging):**
///   Handles push notifications sent by Stream when the app is completely
///   terminated or the WebSocket is disconnected.
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// The single shared plugin instance — injected once from main.dart.
  /// MUST call [setNotificationsPlugin] before [initialize].
  late final FlutterLocalNotificationsPlugin _localNotifications;

  /// Inject the globally-initialized [FlutterLocalNotificationsPlugin].
  /// Call this exactly once from main.dart after initializing the plugin.
  void setNotificationsPlugin(FlutterLocalNotificationsPlugin plugin) {
    _localNotifications = plugin;
    debugPrint('🔔 [PUSH] Notifications plugin injected');
  }

  bool _initialized = false;
  StreamChatClient? _streamClient;
  StreamSubscription<Event>? _messageSubscription;

  /// The channel ID the user is currently viewing.
  /// Set by ChatScreen on open, cleared on dispose.
  /// When set, notifications for this channel are suppressed.
  static String? activeChannelId;

  // ─── Android notification channel ──────────────────────────────────
  static const String _channelId = 'chat_messages';
  static const String _channelName = 'Chat Messages';
  static const String _channelDescription =
      'Notifications for new chat messages';

  // ─── Public API ────────────────────────────────────────────────────

  /// Initialize the push notification service and register with Stream.
  ///
  /// Call this **after** `client.connectUser()` succeeds.
  /// Safe to call multiple times — will re-attach event listeners.
  Future<void> initialize(StreamChatClient client) async {
    debugPrint('🔔 [PUSH] initialize() called, _initialized=$_initialized');

    // Always update client reference and re-attach WebSocket listener
    _streamClient = client;

    // Cancel any previous WebSocket subscription before re-attaching
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    // Attach WebSocket event listener (always, even if FCM part is done)
    // Listen to BOTH event types:
    //   - message.new: fires on channels the client is actively watching
    //   - notification.message_new: fires for channels the user is a member
    //     of but NOT currently watching (this is the main one!)
    _messageSubscription = client
        .on(
          EventType.messageNew,
          EventType.notificationMessageNew,
        )
        .listen(_handleStreamMessageEvent);
    debugPrint('🔔 [PUSH] Stream event listener attached '
        '(message.new + notification.message_new)');

    // Only do the FCM + local notifications init once
    if (_initialized) {
      debugPrint('🔔 [PUSH] FCM already initialized — skipping FCM setup');
      return;
    }

    try {
      // 1. Request permission (iOS will prompt; Android 13+ will prompt)
      await _requestPermission();

      // 2. (Local notifications plugin is already initialized in main.dart)

      // 3. Get FCM token and register with Stream
      final token = await _firebaseMessaging.getToken();
      debugPrint('🔔 [PUSH] FCM token: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}');
      if (token != null) {
        await _registerDeviceToken(token);
      }

      // 4. Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen(_registerDeviceToken);

      // 5. Listen for foreground FCM messages (fallback for when WS is down)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Handle notification taps (when app is in background / terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      _initialized = true;
      debugPrint('✅ [PUSH] Push notification service fully initialized');
    } catch (e, stack) {
      debugPrint('❌ [PUSH] Error initializing push notifications: $e');
      debugPrint('❌ [PUSH] Stack: $stack');
    }
  }

  /// Remove the device from Stream and reset state.
  /// Call this when the user disconnects / logs out.
  Future<void> dispose() async {
    // Cancel the WebSocket event subscription
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    try {
      if (_streamClient != null) {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _streamClient!.removeDevice(token);
          debugPrint('🗑️ [PUSH] Device token removed from Stream');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PUSH] Error removing device token: $e');
    }
    _initialized = false;
    _streamClient = null;
  }

  // ─── Stream WebSocket event handler ─────────────────────────────────

  /// Called instantly when a `message.new` or `notification.message_new`
  /// event arrives over the WebSocket.
  void _handleStreamMessageEvent(Event event) {
    debugPrint('📨 [PUSH] Stream event: type=${event.type}, cid=${event.cid}');

    final message = event.message;
    if (message == null) {
      debugPrint('📨 [PUSH] Event has no message — ignoring');
      return;
    }

    final currentUserId = _streamClient?.state.currentUser?.id;

    // Don't notify for our own messages
    if (message.user?.id == currentUserId) {
      debugPrint('📨 [PUSH] Own message — ignoring');
      return;
    }

    // Don't notify if the user is currently viewing this channel
    final channelCid = event.cid; // format: "messaging:channelId"
    final rawChannelId = channelCid?.split(':').last;
    if (rawChannelId != null && rawChannelId == activeChannelId) {
      debugPrint(
        '🔕 [PUSH] Suppressed — user is viewing channel $rawChannelId',
      );
      return;
    }

    // Extract sender name and message text
    final senderName = message.user?.name ?? 'Someone';
    final messageText = message.text ?? 'Sent a message';

    debugPrint('📨 [PUSH] Showing notification: $senderName → $messageText');

    _showLocalNotification(
      id: message.id.hashCode,
      title: senderName,
      body: messageText,
      payload: jsonEncode({
        'channel_id': rawChannelId,
        'channel_cid': channelCid,
        'message_id': message.id,
      }),
    );
  }

  // ─── Private helpers ───────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      '🔔 [PUSH] Permission status: ${settings.authorizationStatus}',
    );
  }

  /// Register FCM token with Stream Chat backend.
  Future<void> _registerDeviceToken(String token) async {
    try {
      if (_streamClient == null || _streamClient!.state.currentUser == null) {
        debugPrint('⚠️ [PUSH] Cannot register token — client not connected');
        return;
      }

      await _streamClient!.addDevice(token, PushProvider.firebase);
      debugPrint('✅ [PUSH] Device token registered with Stream');
    } catch (e) {
      debugPrint('❌ [PUSH] Error registering device token: $e');
    }
  }

  /// Handle FCM messages received while the app is in the **foreground**.
  /// This is a fallback — the WebSocket listener is the primary path.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 [PUSH/FCM] Foreground message received');
    debugPrint('   Data: ${message.data}');

    final data = message.data;

    final sender = data['sender'] as String?;
    if (sender == 'stream.chat') {
      _showFcmChatNotification(message);
      return;
    }

    if (message.notification != null) {
      _showNotificationFromPayload(message);
    }
  }

  void _showFcmChatNotification(RemoteMessage message) {
    final data = message.data;
    final messageId = data['id'] as String? ?? '';
    final type = data['type'] as String?;

    if (type != 'message.new') return;

    final channelId = data['channel_id'] as String?;
    if (channelId != null && channelId == activeChannelId) return;

    String title = 'New Message';
    String body = 'You have a new message';

    if (data.containsKey('channel_name')) {
      title = data['channel_name'] as String? ?? title;
    }
    if (data.containsKey('message_text')) {
      body = data['message_text'] as String? ?? body;
    }

    if (message.notification != null) {
      title = message.notification!.title ?? title;
      body = message.notification!.body ?? body;
    }

    _showLocalNotification(
      id: messageId.hashCode,
      title: title,
      body: body,
      payload: jsonEncode(data),
    );
  }

  void _showNotificationFromPayload(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _showLocalNotification(
      id: notification.hashCode,
      title: notification.title ?? 'New Message',
      body: notification.body ?? 'You have a new message',
      payload: jsonEncode(message.data),
    );
  }

  /// Display a local notification.
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
    debugPrint('🔔 [PUSH] Local notification shown: "$title" — "$body"');
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 [PUSH] Background notification tapped: ${message.data}');
  }
}

/// Top-level background message handler.
///
/// MUST be a top-level function (not a class method).
/// Called when a message arrives and the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 [PUSH] Background message received: ${message.data}');

  final localNotifications = FlutterLocalNotificationsPlugin();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await localNotifications.initialize(initSettings);

  final data = message.data;
  final sender = data['sender'] as String?;
  final type = data['type'] as String?;

  if (sender == 'stream.chat' && type == 'message.new') {
    String title = 'New Message';
    String body = 'You have a new message';

    if (data.containsKey('channel_name')) {
      title = data['channel_name'] as String? ?? title;
    }
    if (data.containsKey('message_text')) {
      body = data['message_text'] as String? ?? body;
    }

    final messageId = data['id'] as String? ?? '';

    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await localNotifications.show(
      messageId.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  if (message.notification != null) {
    debugPrint(
      '📨 [PUSH] Background notification payload: '
      '${message.notification?.title} - ${message.notification?.body}',
    );
  }
}
