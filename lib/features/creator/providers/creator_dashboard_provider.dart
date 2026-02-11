import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/creator_dashboard_model.dart';
import '../services/creator_dashboard_service.dart';
import '../../wallet/models/earnings_model.dart';
import '../models/creator_task_model.dart';

// ── Service provider ──────────────────────────────────────────────────────
final creatorDashboardServiceProvider = Provider<CreatorDashboardService>(
  (ref) => CreatorDashboardService(),
);

// ── Main dashboard provider (the single source of truth) ──────────────────
/// Fetches consolidated creator data from GET /creator/dashboard.
///
/// Invalidate this provider to force a re-fetch:
/// ```dart
/// ref.invalidate(creatorDashboardProvider);
/// ```
///
/// This is automatically invalidated when:
/// - `creator:data_updated` socket event fires (call settled / task claimed)
/// - App resumes from background
/// - Manual pull-to-refresh
final creatorDashboardProvider = FutureProvider<CreatorDashboard>((ref) async {
  final service = ref.read(creatorDashboardServiceProvider);
  debugPrint('📊 [PROVIDER] Fetching creator dashboard...');
  return await service.getCreatorDashboard();
});

// ── Derived providers for convenience ─────────────────────────────────────

/// Earnings data extracted from the dashboard.
/// Screens that only need earnings can watch this.
final dashboardEarningsProvider = FutureProvider<CreatorEarnings>((ref) async {
  final dashboard = await ref.watch(creatorDashboardProvider.future);
  return dashboard.earnings;
});

/// Tasks data extracted from the dashboard.
/// Screens that only need tasks can watch this.
final dashboardTasksProvider = FutureProvider<CreatorTasksResponse>((ref) async {
  final dashboard = await ref.watch(creatorDashboardProvider.future);
  return dashboard.tasks;
});

/// Creator's current coin balance from the dashboard.
final dashboardCoinsProvider = FutureProvider<int>((ref) async {
  final dashboard = await ref.watch(creatorDashboardProvider.future);
  return dashboard.coins;
});
