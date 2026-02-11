import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/push_notification_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/chat/providers/stream_chat_provider.dart';
import '../../features/chat/services/chat_service.dart';
import '../../features/video/providers/stream_video_provider.dart';

/// Wraps app with StreamChat widget and handles user connection
class StreamChatWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const StreamChatWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<StreamChatWrapper> createState() => _StreamChatWrapperState();
}

class _StreamChatWrapperState extends ConsumerState<StreamChatWrapper> {
  bool _isConnecting = false;

  Future<void> _connectToStreamChat(AuthState authState) async {
    // Extract variables at method level so they're accessible to both try-catch blocks
    final firebaseUser = authState.firebaseUser!;
    final user = authState.user!;

    // Calculate display name once (used by both Stream Chat and Stream Video)
    final displayName = (user.username != null && user.username!.trim().isNotEmpty)
        ? user.username!
        : (user.email != null && user.email!.trim().isNotEmpty)
            ? user.email!
            : (user.phone != null && user.phone!.trim().isNotEmpty)
                ? user.phone!
                : 'User';

    // Connect to Stream Chat
    try {
      debugPrint('🔌 [STREAM WRAPPER] Connecting to Stream Chat...');
      debugPrint('   User ID: ${firebaseUser.uid}');
      debugPrint('   Display Name: $displayName');

      // Get Stream Chat token from backend
      final chatService = ChatService();
      final streamToken = await chatService.getChatToken();
      
      await ref.read(streamChatNotifierProvider.notifier).connectUser(
            firebaseUid: firebaseUser.uid,
            username: displayName,
            avatarUrl: user.avatar,
            streamToken: streamToken,
          );

      debugPrint('✅ [STREAM WRAPPER] Stream Chat connected');

      // Register FCM device for push notifications
      final currentClient = ref.read(streamChatNotifierProvider);
      if (currentClient != null) {
        await PushNotificationService().initialize(currentClient);
      }
    } catch (e) {
      debugPrint('❌ [STREAM WRAPPER] Failed to connect to Stream Chat: $e');
      // Don't block app if Stream Chat fails
    }

    // Initialize Stream Video
    try {
      debugPrint('🎥 [STREAM WRAPPER] Initializing Stream Video...');
      
      await ref.read(streamVideoProvider.notifier).initialize(
        userId: firebaseUser.uid,
        userName: displayName,
        userImage: user.avatar,
      );

      debugPrint('✅ [STREAM WRAPPER] Stream Video initialized');
    } catch (e) {
      debugPrint('❌ [STREAM WRAPPER] Failed to initialize Stream Video: $e');
      // Don't block app if Stream Video fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final streamClient = ref.watch(streamChatNotifierProvider);

    // React to auth state changes (using ref.listen in build - this is the correct place)
    ref.listen<AuthState>(authProvider, (prev, next) {
      // If user is authenticated but Stream Chat is not connected
      if (next.isAuthenticated && !_isConnecting) {
        // Check if user is already connected (read fresh value inside callback)
        final currentClient = ref.read(streamChatNotifierProvider);
        if (currentClient?.state.currentUser == null) {
          _isConnecting = true;
          _connectToStreamChat(next).whenComplete(() {
            if (mounted) {
              _isConnecting = false;
            }
          });
        }
      }

      // If user logged out, disconnect Stream Chat and Stream Video
      if (!next.isAuthenticated) {
        // Remove FCM device from Stream before disconnecting
        PushNotificationService().dispose();

        final currentClient = ref.read(streamChatNotifierProvider);
        if (currentClient?.state.currentUser != null) {
          ref.read(streamChatNotifierProvider.notifier).disconnectUser();
        }
        
        // Disconnect Stream Video
        final videoClient = ref.read(streamVideoProvider);
        if (videoClient != null) {
          ref.read(streamVideoProvider.notifier).disconnect();
        }
      }
    });

    // Handle initial state: if user is already authenticated on first build
    if (authState.isAuthenticated && streamClient?.state.currentUser == null && !_isConnecting) {
      // Use post-frame callback to avoid calling async in build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && 
            ref.read(authProvider).isAuthenticated && 
            ref.read(streamChatNotifierProvider)?.state.currentUser == null && 
            !_isConnecting) {
          _isConnecting = true;
          _connectToStreamChat(ref.read(authProvider)).whenComplete(() {
            if (mounted) {
              _isConnecting = false;
            }
          });
        }
      });
    }

    // Just return child - StreamChat wrapping happens in MaterialApp.router builder
    return widget.child;
  }
}
