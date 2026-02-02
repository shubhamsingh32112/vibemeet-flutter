import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/earnings_model.dart';

class EarningsService {
  final ApiClient _apiClient = ApiClient();

  /// Get creator earnings from call history
  Future<CreatorEarnings> getCreatorEarnings() async {
    try {
      debugPrint('💰 [EARNINGS] Fetching creator earnings...');
      final response = await _apiClient.get('/creator/earnings');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ [EARNINGS] Earnings fetched successfully');
        return CreatorEarnings.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch earnings: ${response.data['error']}');
      }
    } catch (e) {
      debugPrint('❌ [EARNINGS] Error fetching earnings: $e');
      rethrow;
    }
  }
}
