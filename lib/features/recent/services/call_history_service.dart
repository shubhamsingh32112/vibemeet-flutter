import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/call_history_model.dart';

class CallHistoryService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch paginated call history for the authenticated user.
  Future<List<CallHistoryModel>> getCallHistory({int page = 1, int limit = 20}) async {
    debugPrint('📋 [CALL HISTORY] Fetching page $page (limit $limit)...');
    final response = await _apiClient.get('/user/call-history?page=$page&limit=$limit');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final callsJson = response.data['data']['calls'] as List<dynamic>;
      final calls = callsJson
          .map((json) => CallHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('✅ [CALL HISTORY] Fetched ${calls.length} records');
      return calls;
    } else {
      throw Exception(
          'Failed to fetch call history: ${response.data['error'] ?? 'Unknown error'}');
    }
  }
}
