import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/creator_task_service.dart';
import '../models/creator_task_model.dart';

/// Service provider
final creatorTaskServiceProvider = Provider<CreatorTaskService>((ref) {
  return CreatorTaskService();
});

/// Provider for getting creator tasks
final creatorTasksProvider = FutureProvider<CreatorTasksResponse>((ref) async {
  final service = ref.read(creatorTaskServiceProvider);
  return await service.getCreatorTasks();
});
