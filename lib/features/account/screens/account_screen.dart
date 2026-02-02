import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/widgets/main_layout.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/styles/app_brand_styles.dart';
import '../../../shared/widgets/ui_primitives.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/admin_view_provider.dart';
import '../../creator/providers/creator_status_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  String? _appVersion;
  String? _buildNumber;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }


  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Log Out',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Reset admin view mode on logout
      ref.read(adminViewModeProvider.notifier).reset();
      await ref.read(authProvider.notifier).signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final scheme = Theme.of(context).colorScheme;

    return MainLayout(
      selectedIndex: 3,
      child: authState.isLoading && user == null
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                      // Profile Header Card
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  // Profile Picture
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppBrandGradients.avatarRing,
                                      border: Border.all(
                                        color: scheme.surface,
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: AvatarWidget(
                                        user: user,
                                        size: 100,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Username or User ID
                                  Text(
                                    user?.username ?? user?.id ?? 'N/A',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  // Creator Badge
                                  if (user?.role == 'creator') ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppBrandGradients.creatorBadge,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Creator',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Creator Online/Offline Toggle
                                    AppCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Availability Status',
                                            style: TextStyle(
                                              color: scheme.onSurfaceVariant,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Consumer(
                                            builder: (context, ref, child) {
                                              final status = ref.watch(creatorStatusProvider);
                                              final notifier = ref.read(creatorStatusProvider.notifier);
                                              final isOnline = status == CreatorStatus.online;

                                              return Row(
                                                children: [
                                                  // Status Indicator
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isOnline
                                                          ? scheme.primary
                                                          : scheme.outlineVariant,
                                                      boxShadow: isOnline
                                                          ? [
                                                              BoxShadow(
                                                                color: scheme.primary.withOpacity(0.5),
                                                                blurRadius: 8,
                                                                spreadRadius: 2,
                                                              ),
                                                            ]
                                                          : null,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      isOnline ? 'Online' : 'Offline',
                                                      style: TextStyle(
                                                        color: scheme.onSurface,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  // Toggle Switch
                                                  Switch(
                                                    value: isOnline,
                                                    onChanged: (value) {
                                                      notifier.toggleStatus();
                                                    },
                                                    activeColor: scheme.primary,
                                                    activeTrackColor: scheme.primary.withOpacity(0.5),
                                                    inactiveThumbColor: scheme.outlineVariant,
                                                    inactiveTrackColor: scheme.outline,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Admin Badge and View Mode Toggle
                                  if (user?.role == 'admin') ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppBrandGradients.adminBadge,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.admin_panel_settings,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Admin',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Admin View Mode Toggle
                                    AppCard(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'View Mode',
                                            style: TextStyle(
                                              color: scheme.onSurfaceVariant,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Consumer(
                                            builder: (context, ref, child) {
                                              final viewMode = ref.watch(adminViewModeProvider);
                                              final notifier = ref.read(adminViewModeProvider.notifier);

                                              // Initialize to user mode if not set
                                              if (viewMode == null) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  notifier.setViewMode(AdminViewMode.user);
                                                });
                                              }

                                              final currentMode = viewMode ?? AdminViewMode.user;

                                              return Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        notifier.setViewMode(AdminViewMode.user);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 16,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: currentMode == AdminViewMode.user
                                                              ? scheme.primary
                                                              : scheme.surface.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: currentMode == AdminViewMode.user
                                                                ? scheme.primary
                                                                : scheme.outline.withOpacity(0.2),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.person,
                                                              size: 16,
                                                              color: currentMode == AdminViewMode.user
                                                                  ? scheme.onPrimary
                                                                  : scheme.onSurfaceVariant,
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'User View',
                                                              style: TextStyle(
                                                                color: currentMode == AdminViewMode.user
                                                                    ? scheme.onPrimary
                                                                    : scheme.onSurfaceVariant,
                                                                fontSize: 12,
                                                                fontWeight: currentMode == AdminViewMode.user
                                                                    ? FontWeight.bold
                                                                    : FontWeight.normal,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        notifier.setViewMode(AdminViewMode.creator);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 10,
                                                          horizontal: 16,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: currentMode == AdminViewMode.creator
                                                              ? scheme.secondary
                                                              : scheme.surface.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: currentMode == AdminViewMode.creator
                                                                ? scheme.secondary
                                                                : scheme.outline.withOpacity(0.2),
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                              size: 16,
                                                              color: currentMode == AdminViewMode.creator
                                                                  ? scheme.onSecondary
                                                                  : scheme.onSurfaceVariant,
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'Creator View',
                                                              style: TextStyle(
                                                                color: currentMode == AdminViewMode.creator
                                                                    ? scheme.onSecondary
                                                                    : scheme.onSurfaceVariant,
                                                                fontSize: 12,
                                                                fontWeight: currentMode == AdminViewMode.creator
                                                                    ? FontWeight.bold
                                                                    : FontWeight.normal,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Categories (if available)
                                  if (user?.categories != null && user!.categories!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: user.categories!.map((category) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: scheme.surfaceVariant.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: scheme.outline.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: scheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Edit Button
                            Positioned(
                              top: 16,
                              right: 16,
                              child: IconButton(
                                onPressed: () async {
                                  await context.push('/edit-profile');
                                  // Refresh user data when returning from edit profile
                                  if (mounted) {
                                    ref.read(authProvider.notifier).refreshUser();
                                  }
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: scheme.onSurface,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Menu Options
                      // Wallet - Visible for all users (creators see earnings, users see purchase)
                      _buildMenuCard(
                        icon: Icons.account_balance_wallet,
                        title: 'Wallet',
                        onTap: () {
                          context.push('/wallet');
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildMenuCard(
                        icon: Icons.receipt_long,
                        title: 'Transactions',
                        onTap: () {
                          context.push('/transactions');
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildMenuCard(
                        icon: Icons.headset_mic,
                        title: 'Help & Support',
                        onTap: () {
                          // TODO: Navigate to help & support screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help & Support coming soon')),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      _buildMenuCard(
                        icon: Icons.settings,
                        title: 'Account Settings',
                        onTap: () {
                          // TODO: Navigate to account settings screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account Settings coming soon')),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Log Out Button
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          leading: Icon(
                            Icons.logout,
                            color: scheme.error,
                            size: 24,
                          ),
                          title: Text(
                            'Log Out',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: scheme.onSurfaceVariant,
                            size: 16,
                          ),
                          onTap: _handleLogout,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Footer Information
                      Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              children: [
                                const TextSpan(text: 'Need Help? Please contact '),
                                TextSpan(
                                  text: 'support@eazeapp.com',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _appVersion != null && _buildNumber != null
                                ? 'Version $_appVersion ($_buildNumber)'
                                : 'Version 1.0.0 (1)',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }


  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          icon,
          color: scheme.onSurface,
          size: 24,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: scheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
