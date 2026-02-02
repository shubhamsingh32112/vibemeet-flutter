import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/widgets/main_layout.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/recent_provider.dart';
import '../../../shared/models/call_model.dart';

class RecentScreen extends ConsumerStatefulWidget {
  const RecentScreen({super.key});

  @override
  ConsumerState<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends ConsumerState<RecentScreen> {
  Future<void> _refresh() async {
    // Force a re-fetch
    ref.invalidate(recentCallsProvider);
    await ref.read(recentCallsProvider.future);
  }

  String _formatWhen(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  String _statusLabel(CallModel call) {
    switch (call.status) {
      case CallStatus.ended:
        return call.durationFormatted != null && call.durationFormatted!.isNotEmpty
            ? 'Call • ${call.durationFormatted}'
            : 'Call ended';
      case CallStatus.missed:
        return 'Missed call';
      case CallStatus.rejected:
        return 'Call rejected';
      case CallStatus.accepted:
        return 'In call';
      case CallStatus.ringing:
        return 'Ringing';
      case CallStatus.initiated:
        return 'Initiated';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final me = auth.user;
    final myId = me?.id ?? '';

    final recentCallsAsync = ref.watch(recentCallsProvider);

    return MainLayout(
      selectedIndex: 1,
      child: recentCallsAsync.when(
        loading: () => const SkeletonList(itemCount: 8),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load recent calls', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (calls) {
          if (calls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No recent calls',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your recent calls will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                final isCaller = myId.isNotEmpty && call.callerUserId == myId;
                final String? otherNameRaw = isCaller ? call.creator?.username : call.caller?.username;
                final String? otherAvatar = isCaller ? call.creator?.avatar : call.caller?.avatar;
                final otherName = (otherNameRaw != null && otherNameRaw.isNotEmpty) ? otherNameRaw : 'Unknown';

                final when = _formatWhen(call.endedAt ?? call.updatedAt ?? call.createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (otherAvatar != null && otherAvatar.isNotEmpty)
                          ? NetworkImage(otherAvatar)
                          : null,
                      child: (otherAvatar == null || otherAvatar.isEmpty)
                          ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?')
                          : null,
                    ),
                    title: Text(otherName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_statusLabel(call)),
                        if (when.isNotEmpty) Text(when, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (index * 40).ms)
                    .slideX(begin: 0.06, end: 0);
              },
            ),
          );
        },
      ),
    );
  }
}
