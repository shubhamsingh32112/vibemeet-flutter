import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../app/widgets/main_layout.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  StreamChannelListController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Initialize controller after first frame to ensure StreamChat is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final streamChat = StreamChat.maybeOf(context);
      if (streamChat != null && streamChat.client.state.currentUser != null) {
        setState(() {
          _controller = StreamChannelListController(
            client: streamChat.client,
            // Filter: Only show messaging channels where user is a member and has messages
            filter: Filter.and([
              Filter.equal('type', 'messaging'),
              Filter.in_(
                'members',
                [streamChat.client.state.currentUser!.id],
              ),
              Filter.exists('last_message_at'), // Only channels with messages
            ]),
            channelStateSort: const [SortOption('last_message_at')],
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onChannelTap(Channel channel) {
    // Extract channel ID from channel.cid (format: "messaging:channelId")
    final channelId = channel.id;
    context.push('/chat/$channelId');
  }

  @override
  Widget build(BuildContext context) {
    final streamChat = StreamChat.maybeOf(context);
    
    // Wait for StreamChat to be ready
    if (streamChat == null || streamChat.client.state.currentUser == null) {
      return MainLayout(
        selectedIndex: 2,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Initialize controller if not already done
    if (_controller == null) {
      _initializeController();
      return MainLayout(
        selectedIndex: 2,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MainLayout(
      selectedIndex: 2,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _controller!.refresh(),
          child: StreamChannelListView(
            controller: _controller!,
            onChannelTap: _onChannelTap,
            emptyBuilder: (context) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a conversation after a video call',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
