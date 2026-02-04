import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';

class VideoService {
  final ApiClient _apiClient = ApiClient();

  /// Get Stream Video token from backend
  /// 
  /// [role] - Optional role override ('user' or 'creator')
  /// If not provided, backend will auto-detect based on user's role
  /// 
  /// Backend only handles authentication and token generation.
  /// Call creation is done via Flutter SDK (getOrCreate) - not via REST.
  Future<String> getVideoToken({String? role}) async {
    try {
      debugPrint('📹 [VIDEO] Requesting Stream Video token...');
      
      final response = await _apiClient.post(
        '/video/token',
        data: role != null ? {'role': role} : {},
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'] as String;
        debugPrint('✅ [VIDEO] Token received (length: ${token.length})');
        return token;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to get video token');
      }
    } catch (e) {
      debugPrint('❌ [VIDEO] Error getting token: $e');
      rethrow;
    }
  }
}
