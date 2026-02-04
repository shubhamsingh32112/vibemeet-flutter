import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../services/video_service.dart';
import '../../../core/constants/app_constants.dart';

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService();
});

/// Stream Video client provider
final streamVideoProvider = StateNotifierProvider<StreamVideoNotifier, StreamVideo?>((ref) {
  return StreamVideoNotifier(ref);
});

/// Stream Video client state notifier
class StreamVideoNotifier extends StateNotifier<StreamVideo?> {
  final Ref _ref;
  StreamVideoNotifier(this._ref) : super(null);

  /// Initialize Stream Video client
  /// 
  /// This should be called after user login
  Future<void> initialize({
    required String userId,
    required String userName,
    String? userImage,
  }) async {
    try {
      debugPrint('🎥 [STREAM VIDEO] Initializing Stream Video client...');
      debugPrint('   User ID: $userId');
      debugPrint('   User Name: $userName');

      final videoService = _ref.read(videoServiceProvider);

      // Token loader function - called by SDK when token is needed or expires
      Future<String> tokenLoader(String userId) async {
        debugPrint('🔄 [STREAM VIDEO] Loading token for user: $userId');
        try {
          // Get token from backend (backend will determine role automatically)
          final token = await videoService.getVideoToken();
          debugPrint('✅ [STREAM VIDEO] Token loaded successfully');
          return token;
        } catch (e) {
          debugPrint('❌ [STREAM VIDEO] Error loading token: $e');
          rethrow;
        }
      }

      // Initialize Stream Video client
      final client = StreamVideo(
        AppConstants.streamApiKey,
        user: User.regular(
          userId: userId,
          name: userName,
        ),
        tokenLoader: tokenLoader,
        options: StreamVideoOptions(
          muteVideoWhenInBackground: true, // Prevent background camera leaks
          muteAudioWhenInBackground: true, // Prevent background audio leaks
          logPriority: Priority.error, // Only log errors (no debug noise)
        ),
      );

      state = client;
      debugPrint('✅ [STREAM VIDEO] Client initialized successfully');
    } catch (e) {
      debugPrint('❌ [STREAM VIDEO] Error initializing client: $e');
      rethrow;
    }
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    try {
      if (state != null) {
        debugPrint('🔌 [STREAM VIDEO] Disconnecting...');
        await state!.disconnect();
        state = null;
        debugPrint('✅ [STREAM VIDEO] Disconnected');
      }
    } catch (e) {
      debugPrint('❌ [STREAM VIDEO] Error disconnecting: $e');
    }
  }
}
