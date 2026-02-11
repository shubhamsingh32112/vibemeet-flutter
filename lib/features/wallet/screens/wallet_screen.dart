import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../creator/providers/creator_dashboard_provider.dart';
import '../services/wallet_service.dart';
import '../models/earnings_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ui_primitives.dart';
import '../../../shared/styles/app_brand_styles.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final WalletService _walletService = WalletService();
  bool _isAddingCoins = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data to ensure balance is up-to-date when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  /// Refresh user data from backend to get latest coin balance
  Future<void> _refreshUserData() async {
    try {
      debugPrint('🔄 [WALLET] Refreshing user data to update balance...');
      await ref.read(authProvider.notifier).refreshUser();
      debugPrint('✅ [WALLET] User data refreshed');
    } catch (e) {
      debugPrint('⚠️  [WALLET] Failed to refresh user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final coins = user?.coins ?? 0;
    final isCreator = user?.role == 'creator' || user?.role == 'admin';

    // Watch the dashboard provider for creator earnings (auto-refreshes via socket)
    final earningsAsync = isCreator ? ref.watch(dashboardEarningsProvider) : null;

    return AppScaffold(
      padded: false,
      child: Column(
        children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Wallet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _CoinsPill(coins: coins),
                  ],
                ),
              ),
              if (isCreator)
                earningsAsync!.when(
                  data: (earnings) => _CreatorWalletView(
                    earnings: earnings,
                    isLoadingEarnings: false,
                    earningsError: null,
                    onRefresh: () async {
                      await _refreshUserData();
                      ref.invalidate(creatorDashboardProvider);
                    },
                    onRetry: () => ref.invalidate(creatorDashboardProvider),
                    buildCallEarningCard: _buildCallEarningCard,
                  ),
                  loading: () => _CreatorWalletView(
                    earnings: null,
                    isLoadingEarnings: true,
                    earningsError: null,
                    onRefresh: () async {},
                    onRetry: () {},
                    buildCallEarningCard: _buildCallEarningCard,
                  ),
                  error: (error, _) => _CreatorWalletView(
                    earnings: null,
                    isLoadingEarnings: false,
                    earningsError: error.toString(),
                    onRefresh: () async {
                      ref.invalidate(creatorDashboardProvider);
                    },
                    onRetry: () => ref.invalidate(creatorDashboardProvider),
                    buildCallEarningCard: _buildCallEarningCard,
                  ),
                )
              else
                _UserWalletView(
                  isAddingCoins: _isAddingCoins,
                  onRefresh: _refreshUserData,
                  onAddCoins: _addCoins,
                ),
        ],
      ),
    );
  }

  Widget _buildCallEarningCard(CallEarning call) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppBrandGradients.walletCoinGold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.videocam, color: scheme.onSurface),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.callerUsername,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${call.durationFormatted} • ${call.earnings.toStringAsFixed(0)} coins',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${call.earnings.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppBrandGradients.walletEarningsHighlight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'coins',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addCoins(int coins) async {
    if (_isAddingCoins) return; // Prevent multiple simultaneous requests

    setState(() {
      _isAddingCoins = true;
    });

    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Add coins via API
      await _walletService.addCoins(coins);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Phase C3: No refreshUser() here — coins are updated via coins_updated socket event

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $coins coins added to your account!'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add coins: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingCoins = false;
        });
      }
    }
  }


}

class _CreatorWalletView extends StatelessWidget {
  final CreatorEarnings? earnings;
  final bool isLoadingEarnings;
  final String? earningsError;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final Widget Function(CallEarning call) buildCallEarningCard;

  const _CreatorWalletView({
    required this.earnings,
    required this.isLoadingEarnings,
    required this.earningsError,
    required this.onRefresh,
    required this.onRetry,
    required this.buildCallEarningCard,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isLoadingEarnings) {
      return const Expanded(
        child: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    if (earningsError != null) {
      return Expanded(
        child: ErrorState(
          title: 'Failed to load earnings',
          message: earningsError!,
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
      );
    }

    if (earnings == null) {
      return const Expanded(
        child: EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No earnings data',
          message: 'Your earnings will appear here once you start receiving calls',
        ),
      );
    }

    final e = earnings!;

    return Expanded(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: scheme.onSurface,
        backgroundColor: AppBrandGradients.walletRefreshIndicatorBackground,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          e.totalEarnings.toStringAsFixed(0),
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'coins',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _CreatorStatItem(
                          label: 'Total Calls',
                          value: e.totalCalls.toString(),
                          icon: Icons.phone,
                        ),
                        const SizedBox(width: 24),
                        _CreatorStatItem(
                          label: 'Total Minutes',
                          value: e.totalMinutes.toStringAsFixed(1),
                          icon: Icons.timer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/creator/tasks'),
                        icon: const Icon(Icons.task_alt),
                        label: const Text('View Tasks & Rewards'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Earnings per minute info - Current rate
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: scheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Current rate: ${e.earningsPerMinute.toStringAsFixed(2)} coins/min (${e.calculatedPercentage}% of call rate)',
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (e.avgEarningsPerMinute != null && e.avgEarningsPerMinute! != e.earningsPerMinute) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text(
                          'Historical average: ${e.avgEarningsPerMinute!.toStringAsFixed(2)} coins/min',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Call History
              Text(
                'Call History',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (e.calls.isEmpty)
                const EmptyState(
                  icon: Icons.phone_disabled_outlined,
                  title: 'No calls yet',
                  message: 'Your call history will appear here',
                )
              else
                ...e.calls.map((call) => buildCallEarningCard(call)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatorStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _CreatorStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserWalletView extends StatelessWidget {
  final bool isAddingCoins;
  final Future<void> Function() onRefresh;
  final void Function(int coins) onAddCoins;

  const _UserWalletView({
    required this.isAddingCoins,
    required this.onRefresh,
    required this.onAddCoins,
  });

  @override
  Widget build(BuildContext context) {
    final packages = <_CoinPack>[
      const _CoinPack(
        coins: 250,
        price: 75,
        oldPrice: 149,
        badge: 'Flat 50% off',
      ),
      const _CoinPack(coins: 300, price: 199),
      const _CoinPack(coins: 350, price: 299),
      const _CoinPack(coins: 550, price: 499),
      const _CoinPack(coins: 850, price: 799),
      const _CoinPack(coins: 1400, price: 999),
      const _CoinPack(coins: 3500, price: 2099),
      const _CoinPack(coins: 7500, price: 3999),
      const _CoinPack(coins: 11500, price: 7999),
    ];

    return Expanded(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: Theme.of(context).colorScheme.onSurface,
        backgroundColor: AppBrandGradients.walletRefreshIndicatorBackground,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: _PromoBanner(oldPrice: 149, newPrice: 75),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final pack = packages[index];
                    return _CoinPackCard(
                      pack: pack,
                      onTap: isAddingCoins ? null : () => onAddCoins(pack.coins),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinsPill extends StatelessWidget {
  final int coins;
  const _CoinsPill({required this.coins});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.scrim.withOpacity(0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppBrandGradients.walletCoinGold,
            ),
            child: const Center(
              child: Text(
                'e',
                style: TextStyle(
                  color: AppBrandGradients.walletOnGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            coins.toString(),
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final int oldPrice;
  final int newPrice;
  const _PromoBanner({required this.oldPrice, required this.newPrice});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppBrandGradients.walletPromoBanner,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 8,
            child: Opacity(
              opacity: 0.9,
              child: Row(
                children: const [
                  Icon(Icons.account_balance, color: AppBrandGradients.walletPromoIcon, size: 28),
                  SizedBox(width: 8),
                  Icon(Icons.flag, color: AppBrandGradients.walletPromoIcon, size: 28),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flat 50% off',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: '250 coins  @  '),
                      TextSpan(
                        text: '₹$oldPrice',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: '₹$newPrice',
                        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '  \u00BB\u00BB'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinPack {
  final int coins;
  final int price;
  final int? oldPrice;
  final String? badge;

  const _CoinPack({
    required this.coins,
    required this.price,
    this.oldPrice,
    this.badge,
  });
}

class _CoinPackCard extends StatelessWidget {
  final _CoinPack pack;
  final VoidCallback? onTap;

  const _CoinPackCard({required this.pack, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CoinStackIcon(
            size: pack.coins >= 7500 ? 42 : 36,
          ),
          const SizedBox(height: 10),
          Text(
            pack.coins.toString(),
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (pack.oldPrice != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₹${pack.oldPrice}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${pack.price}',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              '₹${pack.price}',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 10),
          if (pack.badge != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Text(
                pack.badge!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CoinStackIcon extends StatelessWidget {
  final double size;
  const _CoinStackIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(left: 6, top: 8, child: _coin(context, 0.75)),
          Positioned(right: 6, top: 6, child: _coin(context, 0.9)),
          Positioned(left: size * 0.25, bottom: 0, child: _coin(context, 1)),
        ],
      ),
    );
  }

  Widget _coin(BuildContext context, double scale) {
    final d = size * 0.62 * scale;
    // W4 requirement: no gradients inside grid items.
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'e',
          style: TextStyle(
            color: scheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: d * 0.55,
          ),
        ),
      ),
    );
  }
}
