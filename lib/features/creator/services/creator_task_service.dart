import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/creator_task_model.dart';

class CreatorTaskService {
  final ApiClient _apiClient = ApiClient();

  /// Get creator tasks progress
  Future<CreatorTasksResponse> getCreatorTasks() async {
    try {
      debugPrint('📋 [CREATOR TASKS] Fetching tasks...');
      final response = await _apiClient.get('/creator/tasks');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ [CREATOR TASKS] Tasks fetched successfully');
        return CreatorTasksResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch tasks: ${response.data['error']}');
      }
    } catch (e) {
      debugPrint('❌ [CREATOR TASKS] Error fetching tasks: $e');
      rethrow;
    }
  }

  /// Claim task reward
  Future<void> claimTaskReward(String taskKey) async {
    try {
      debugPrint('🎁 [CREATOR TASKS] Claiming reward for task: $taskKey');
      final response = await _apiClient.post('/creator/tasks/$taskKey/claim');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('✅ [CREATOR TASKS] Reward claimed successfully');
      } else {
        throw Exception('Failed to claim reward: ${response.data['error']}');
      }
    } catch (e) {
      debugPrint('❌ [CREATOR TASKS] Error claiming reward: $e');
      rethrow;
    }
  }
}
