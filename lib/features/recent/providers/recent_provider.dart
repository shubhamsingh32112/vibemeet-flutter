import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_history_model.dart';
import '../services/call_history_service.dart';

final callHistoryServiceProvider = Provider<CallHistoryService>((ref) {
  return CallHistoryService();
});

final recentCallsProvider = FutureProvider<List<CallHistoryModel>>((ref) async {
  final service = ref.read(callHistoryServiceProvider);
  return service.getCallHistory();
});