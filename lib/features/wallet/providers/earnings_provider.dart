import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/earnings_service.dart';
import '../models/earnings_model.dart';

/// Service provider
final earningsServiceProvider = Provider<EarningsService>((ref) {
  return EarningsService();
});

/// Provider for getting creator earnings
final creatorEarningsProvider = FutureProvider<CreatorEarnings>((ref) async {
  final service = ref.read(earningsServiceProvider);
  return await service.getCreatorEarnings();
});
