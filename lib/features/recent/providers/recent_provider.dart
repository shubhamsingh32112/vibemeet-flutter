import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../call/providers/call_provider.dart';
import '../../../shared/models/call_model.dart';

final recentCallsProvider = FutureProvider<List<CallModel>>((ref) async {
  final callService = ref.read(callServiceProvider);
  return callService.getRecentCalls();
});

