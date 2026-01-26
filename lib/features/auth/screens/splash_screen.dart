import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait a moment for initialization
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    try {
      // Try to read auth state
      final authState = ref.read(authProvider);
      
      // Check if there's a Firebase error
      if (authState.error != null && authState.error!.contains('Firebase')) {
        // Show error and navigate to login anyway
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Firebase not configured. Please run: flutterfire configure'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
          // Navigate to login anyway
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) context.go('/login');
        }
        return;
      }
      
      if (authState.isAuthenticated) {
        // Check if user has completed onboarding (has gender)
        if (authState.user?.gender == null || authState.user!.gender!.isEmpty) {
          if (mounted) context.go('/gender');
        } else {
          if (mounted) context.go('/home');
        }
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      // If there's an error, just go to login
      debugPrint('Auth check error: $e');
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(delay: 200.ms),
            const SizedBox(height: 32),
            const CircularProgressIndicator()
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
