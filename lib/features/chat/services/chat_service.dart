import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// Get Stream Chat token from backend
  Future<String> getChatToken() async {
    try {
      debugPrint('📞 [CHAT] Requesting Stream Chat token...');
      
      final response = await _apiClient.post(
        '/chat/token',
        data: {},
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'] as String;
        debugPrint('✅ [CHAT] Token received (length: ${token.length})');
        return token;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get chat token');
      }
    } catch (e) {
      debugPrint('❌ [CHAT] Error getting token: $e');
      rethrow;
    }
  }

  /// Create or get channel for User-Creator pair
  /// Returns channelId and cid
  Future<Map<String, String>> createOrGetChannel(String otherUserId) async {
    try {
      debugPrint('📞 [CHAT] Creating/getting channel with user: $otherUserId');
      
      final response = await _apiClient.post(
        '/chat/channel',
        data: {
          'otherUserId': otherUserId,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final channelId = data['channelId'] as String;
        final cid = data['cid'] as String;
        
        debugPrint('✅ [CHAT] Channel created/retrieved: $channelId');
        return {
          'channelId': channelId,
          'cid': cid,
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create/get channel');
      }
    } catch (e) {
      debugPrint('❌ [CHAT] Error creating/getting channel: $e');
      rethrow;
    }
  }
}
