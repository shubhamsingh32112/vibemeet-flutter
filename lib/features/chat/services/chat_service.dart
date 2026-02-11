import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// Get Stream Chat token from backend
  Future<String> getChatToken() async {
    try {
      debugPrint('📞 [CHAT] Requesting Stream Chat token...');

      final response = await _apiClient.post('/chat/token', data: {});

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

  /// Create or get channel for User-Creator pair.
  /// Returns channelId, cid and quota info.
  Future<Map<String, dynamic>> createOrGetChannel(String otherUserId) async {
    try {
      debugPrint('📞 [CHAT] Creating/getting channel with user: $otherUserId');

      final response = await _apiClient.post(
        '/chat/channel',
        data: {'otherUserId': otherUserId},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('✅ [CHAT] Channel: ${data['channelId']}');
        return data;
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to create/get channel');
      }
    } catch (e) {
      debugPrint('❌ [CHAT] Error creating/getting channel: $e');
      rethrow;
    }
  }

  /// Pre-send check — call this BEFORE sending each message (user role).
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "canSend": true/false,
  ///   "freeRemaining": 2,
  ///   "coinsCharged": 0 or 5,
  ///   "userCoins": 25,
  ///   "error": "..." // only when canSend == false
  /// }
  /// ```
  Future<Map<String, dynamic>> preSendMessage(
    String channelId, {
    String? messageId,
  }) async {
    try {
      debugPrint('💬 [CHAT] Pre-send check for channel: $channelId (msgId: $messageId)');

      final response = await _apiClient.post(
        '/chat/pre-send',
        data: {
          'channelId': channelId,
          if (messageId != null) 'messageId': messageId,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint(
          '💬 [CHAT] Pre-send result: canSend=${data['canSend']}, '
          'freeRemaining=${data['freeRemaining']}, '
          'coinsCharged=${data['coinsCharged']}',
        );
        return data;
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to validate message');
      }
    } catch (e) {
      debugPrint('❌ [CHAT] Pre-send error: $e');
      rethrow;
    }
  }

  /// Get current message quota for a channel.
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "freeRemaining": 2,
  ///   "costPerMessage": 0 or 5,
  ///   "freeTotal": 3,
  ///   "userCoins": 25
  /// }
  /// ```
  Future<Map<String, dynamic>> getMessageQuota(String channelId) async {
    try {
      final response = await _apiClient.get('/chat/quota/$channelId');

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get quota');
      }
    } catch (e) {
      debugPrint('❌ [CHAT] Error getting quota: $e');
      rethrow;
    }
  }
}
