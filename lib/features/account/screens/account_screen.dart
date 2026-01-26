import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../app/widgets/main_layout.dart';
import '../../../shared/widgets/loading_indicator.dart';
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
        backgroundColor: const Color(0xFF2D1B3D),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
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

    return MainLayout(
      selectedIndex: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2D1B3D), // Dark purple-brown
              const Color(0xFF3D2B4D), // Slightly lighter purple-brown
              const Color(0xFF2D1B3D), // Back to dark
            ],
          ),
        ),
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
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
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.purple[300]!,
                                          Colors.purple[600]!,
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: _buildProfileAvatar(user),
                                  ),
                                  const SizedBox(height: 16),
                                  // Username or User ID
                                  Text(
                                    user?.username ?? user?.id ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber[600]!,
                                            Colors.orange[600]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Creator',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Creator Online/Offline Toggle
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Availability Status',
                                            style: TextStyle(
                                              color: Colors.grey[300],
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
                                                          ? Colors.green[400]!
                                                          : Colors.grey[400]!,
                                                      boxShadow: isOnline
                                                          ? [
                                                              BoxShadow(
                                                                color: Colors.green.withOpacity(0.5),
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
                                                        color: Colors.white,
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
                                                    activeColor: Colors.green[400],
                                                    activeTrackColor: Colors.green[300],
                                                    inactiveThumbColor: Colors.grey[400],
                                                    inactiveTrackColor: Colors.grey[600],
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
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red[600]!,
                                            Colors.pink[600]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.admin_panel_settings,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Admin View Mode Toggle
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'View Mode',
                                            style: TextStyle(
                                              color: Colors.grey[300],
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
                                                              ? Colors.blue[600]!.withOpacity(0.8)
                                                              : Colors.white.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: currentMode == AdminViewMode.user
                                                                ? Colors.blue[400]!
                                                                : Colors.white.withOpacity(0.2),
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
                                                                  ? Colors.white
                                                                  : Colors.grey[400],
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'User View',
                                                              style: TextStyle(
                                                                color: currentMode == AdminViewMode.user
                                                                    ? Colors.white
                                                                    : Colors.grey[400],
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
                                                              ? Colors.amber[600]!.withOpacity(0.8)
                                                              : Colors.white.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: currentMode == AdminViewMode.creator
                                                                ? Colors.amber[400]!
                                                                : Colors.white.withOpacity(0.2),
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
                                                                  ? Colors.white
                                                                  : Colors.grey[400],
                                                            ),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'Creator View',
                                                              style: TextStyle(
                                                                color: currentMode == AdminViewMode.creator
                                                                    ? Colors.white
                                                                    : Colors.grey[400],
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
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: Colors.grey[300],
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
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Menu Options
                      _buildMenuCard(
                        icon: Icons.account_balance_wallet,
                        title: 'Wallet',
                        onTap: () {
                          // TODO: Navigate to wallet screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wallet coming soon')),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildMenuCard(
                        icon: Icons.receipt_long,
                        title: 'Transactions',
                        onTap: () {
                          // TODO: Navigate to transactions screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transactions coming soon')),
                          );
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 24,
                          ),
                          title: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
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
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              children: [
                                const TextSpan(text: 'Need Help? Please contact '),
                                TextSpan(
                                  text: 'support@eazeapp.com',
                                  style: const TextStyle(
                                    color: Colors.white,
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
                              color: Colors.grey[500],
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
      ),
    );
  }

  Widget _buildProfileAvatar(user) {
    // If user is a creator, use the creator photo from the creator collection
    if (user?.role == 'creator' || user?.role == 'admin') {
      if (user?.avatar != null && user!.avatar!.isNotEmpty) {
        // Check if avatar is a URL (from creator collection) or a premade avatar path
        if (user.avatar!.startsWith('http://') || 
            user.avatar!.startsWith('https://') ||
            user.avatar!.startsWith('data:')) {
          // It's a URL from creator collection - use it directly
          return ClipOval(
            child: Image.network(
              user.avatar!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackAvatar(user);
              },
            ),
          );
        }
        // If it's not a URL, it might be a premade avatar (for backwards compatibility)
        // But creators should use their photo, so fall through to fallback
      }
      // If no avatar URL, use fallback
      return _buildFallbackAvatar(user);
    }
    
    // For regular users, use premade avatars if available
    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      final gender = user.gender ?? 'male';
      final avatarPath = gender == 'female'
          ? 'lib/assets/female/${user.avatar}'
          : 'lib/assets/male/${user.avatar}';
      
      return ClipOval(
        child: Image.asset(
          avatarPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(user);
          },
        ),
      );
    }
    
    // Fallback to network avatar or initials
    return _buildFallbackAvatar(user);
  }

  Widget _buildFallbackAvatar(user) {
    if (user?.email != null) {
      return ClipOval(
        child: Image.network(
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user!.email!)}&background=7c3aed&color=fff&size=200',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.purple[400],
              child: Center(
                child: Text(
                  (user.email?.substring(0, 1).toUpperCase() ?? 'U'),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.purple[400],
        child: Text(
          (user?.phone != null && user!.phone!.isNotEmpty
              ? user.phone!.substring(user.phone!.length - 1)
              : 'U'),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
