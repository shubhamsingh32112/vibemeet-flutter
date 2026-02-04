import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String channelId;

  const ChatScreen({
    super.key,
    required this.channelId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  Channel? _channel;
  String? _otherUserId;
  String? _otherUserName;

  @override
  void initState() {
    super.initState();
    _initializeChannel();
  }

  Future<void> _initializeChannel() async {
    try {
      // StreamChat must be in widget tree (wrapped at app root)
      // If it's not, that's a fatal wiring bug, not a runtime state
      final client = StreamChat.of(context).client;
      
      // Get channel by ID
      final channel = client.channel('messaging', id: widget.channelId);
      
      // Watch channel to get latest state
      await channel.watch();
      
      // Extract other user ID and name from channel members
      // FIX: members is a Map<String, Member>, not a List - must convert to list
      final currentUserId = client.state.currentUser!.id;
      // Cast to Map and get values as list
      final members = (channel.state!.members as Map<String, Member>).values.toList();
      
      final otherMember = members.firstWhere(
        (m) => m.userId != currentUserId,
      );
      final otherUserId = otherMember.userId;
      
      // Get other user's display name - use username from extraData (single source of truth)
      // This is guaranteed to be the username from MongoDB, never an email
      final otherUserName = otherMember.user?.extraData['username'] as String? ??
          otherMember.user?.name ??
          'User';
      
      if (mounted) {
        setState(() {
          _channel = channel;
          _otherUserId = otherUserId;
          _otherUserName = otherUserName;
        });
        
        // Set up message validation listener
        _setupMessageValidation(channel);
      }
    } catch (e) {
      debugPrint('❌ [CHAT] Failed to initialize channel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }


  /// Set up message validation listener on channel
  void _setupMessageValidation(Channel channel) {
    // Listen for new messages and validate them
    // Note: Backend webhook is the authoritative layer - this is for UX feedback
    channel.on(EventType.messageNew).listen((event) {
      if (event.message?.text != null) {
        final text = event.message!.text!;
        final allowedPattern = RegExp(r'^[0-5\s]*$');
        
        // If message has invalid text, show error (backend will reject it anyway)
        if (text.isNotEmpty && !allowedPattern.hasMatch(text)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message rejected: Only numbers 0 to 5 are allowed'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    });
  }

  /// Build message input with validation and role-based permissions
  Widget _buildMessageInput() {
    final client = StreamChat.of(context).client;
    final currentUser = client.state.currentUser;
    
    if (currentUser == null) {
      return const SizedBox.shrink();
    }
    
    // Get app role from user metadata
    final appRole = currentUser.extraData['appRole'] as String?;
    final canSendMedia = appRole == 'creator' || appRole == 'admin';
    
    return StreamMessageInput(
      // Enable voice recording for all users
      enableVoiceRecording: true,
      sendVoiceRecordingAutomatically: true,
      
      // Disable attachments for users (only creators can send media)
      disableAttachments: !canSendMedia,
      
      // Note: Backend webhook enforces text validation (0-5 only) and attachment rules
      // Frontend validation above provides UX feedback when messages are rejected
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_channel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamChatTheme(
      data: StreamChatThemeData(
        colorTheme: StreamColorTheme.dark(
          accentPrimary: colorScheme.primary,
          accentError: colorScheme.error,
          accentInfo: colorScheme.primary,
          textHighEmphasis: colorScheme.onSurface,
          textLowEmphasis: colorScheme.onSurface.withOpacity(0.6),
          inputBg: colorScheme.surfaceContainerHigh,
        ),
        ownMessageTheme: StreamMessageThemeData(
          messageBackgroundColor: colorScheme.primary,
          messageTextStyle: TextStyle(color: colorScheme.onPrimary),
        ),
        otherMessageTheme: StreamMessageThemeData(
          messageBackgroundColor: colorScheme.surfaceContainerHigh,
          messageTextStyle: TextStyle(color: colorScheme.onSurface),
        ),
      ),
        child: StreamChannel(
          channel: _channel!,
          child: Scaffold(
            // FIX: Use AppBar instead of StreamChannelHeader for full control
            // StreamChannelHeader ignores custom titles and uses its own logic
            appBar: AppBar(
              title: Text(
                _otherUserName ?? 'User',
                overflow: TextOverflow.ellipsis,
              ),
              actions: [],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamMessageListView(
                    threadBuilder: (_, parentMessage) {
                      // Thread support can be added later
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                // Message input with validation and role-based permissions
                _buildMessageInput(),
              ],
            ),
          ),
        ),
    );
  }
}
