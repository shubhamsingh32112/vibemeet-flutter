import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/creator_dashboard_model.dart';

class CreatorDashboardService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch the consolidated creator dashboard (earnings + tasks + coins).
  ///
  /// Backend caches this in Redis for 60 seconds, so repeated calls are cheap.
  Future<CreatorDashboard> getCreatorDashboard() async {
    try {
      debugPrint('📊 [DASHBOARD] Fetching creator dashboard...');
      final response = await _apiClient.get('/creator/dashboard');

      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ [DASHBOARD] Dashboard fetched successfully');
        return CreatorDashboard.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to fetch dashboard: ${response.data['error']}',
        );
      }
    } catch (e) {
      debugPrint('❌ [DASHBOARD] Error fetching dashboard: $e');
      rethrow;
    }
  }
}
