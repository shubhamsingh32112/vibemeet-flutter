import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/ui_primitives.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🖱️  [UI] Google sign in button pressed');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('   ⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('   📱 Screen: Login Screen');
    debugPrint('   🔘 Action: Google Sign In');

    final startTime = DateTime.now();
    await ref.read(authProvider.notifier).signInWithGoogle();
    final duration = DateTime.now().difference(startTime);

    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('📊 [UI] Google sign in initiated');
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('   ⏱️  Sign-in call duration: ${duration.inMilliseconds}ms');
    debugPrint('   💡 Auth state listener will handle navigation');
    debugPrint('   💡 Backend sync is in progress...');
    
    // The auth state listener in initState will handle navigation
    // when authentication completes. We don't need to check here
    // because the backend sync happens asynchronously via the auth
    // state listener in auth_provider.dart
  }

  Future<void> _handlePhoneLogin() async {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🖱️  [UI] Phone login button pressed');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('   ⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    debugPrint('   📱 Screen: Login Screen');
    debugPrint('   🔘 Action: Phone Sign In');

    final digits = _phoneController.text.trim();

    if (digits.isEmpty) {
      debugPrint('   ❌ Phone number field is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    if (digits.length != 10 || !RegExp(r'^\d{10}$').hasMatch(digits)) {
      debugPrint('   ❌ Invalid phone number length: ${digits.length}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    if (!_acceptTerms) {
      debugPrint('   ❌ Terms and conditions not accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    // Prepend +91 country code
    final phoneNumber = '+91$digits';
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('📱 [UI] Phone number entered');
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('   📞 Phone: $phoneNumber');
    debugPrint('   📏 Digits: ${digits.length}');
    debugPrint('   🔄 Calling signInWithPhone()...');

    final startTime = DateTime.now();
    await ref.read(authProvider.notifier).signInWithPhone(phoneNumber);
    final duration = DateTime.now().difference(startTime);

    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('📊 [UI] Phone sign in initiated');
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('   ⏱️  Duration: ${duration.inMilliseconds}ms');
    debugPrint('   💡 Auth state listener will handle navigation when verification ID is received');
    
    // The auth state listener in build() will handle navigation
    // when verificationId is set in the state
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Listen for authentication state changes to navigate automatically
    // ref.listen MUST be called directly in build() method
    ref.listen(authProvider, (previous, next) {
      // Navigate to OTP screen when verification ID is received
      if (next.verificationId != null && 
          previous?.verificationId != next.verificationId && 
          next.phoneNumber != null &&
          mounted) {
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('✅ [UI] Auth state listener: Verification ID received');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   🆔 Verification ID: ${next.verificationId}');
        debugPrint('   📱 Phone: ${next.phoneNumber}');
        debugPrint('   🧭 Navigating to OTP screen...');
        context.push(
          '/otp?phone=${Uri.encodeComponent(next.phoneNumber!)}&verificationId=${Uri.encodeComponent(next.verificationId!)}',
        );
        debugPrint('   ✅ Navigation completed');
      }
      // Navigate to home or gender selection when authenticated
      else if (next.isAuthenticated && mounted && previous?.isAuthenticated != true) {
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('✅ [UI] Auth state listener: User authenticated');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   🆔 User ID: ${next.user?.id}');
        debugPrint('   📧 Email: ${next.user?.email ?? "N/A"}');
        debugPrint('   👤 Gender: ${next.user?.gender ?? "Not set"}');
        
        // Check if user has completed onboarding (has gender)
        if (next.user?.gender == null || next.user!.gender!.isEmpty) {
          debugPrint('   🎯 Navigating to gender selection screen...');
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.go('/gender');
            }
          });
        } else {
          debugPrint('   🏠 Navigating to home screen...');
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.go('/home');
            }
          });
        }
      } 
      // Show error messages
      else if (next.error != null && mounted && !next.isLoading && previous?.error != next.error) {
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('❌ [UI] Auth state listener: Authentication error');
        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('   Error: ${next.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getHumanReadableError(next.error!)),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    return AppScaffold(
      padded: true,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Login to get started',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+91',
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 24,
                          color: scheme.outlineVariant,
                        ),
                      ],
                    ),
                  ),
                  counterText: '', // hide the "0/10" counter
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You will receive an OTP on this number.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    activeColor: scheme.primary,
                    checkColor: scheme.onPrimary,
                    side: BorderSide(
                      color: scheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'I accept '),
                            TextSpan(
                              text: 'terms & conditions',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: scheme.primary,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'community guidelines',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: scheme.primary,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' of Eaze. I also agree to receiving updates on WhatsApp/SMS.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Get OTP',
                onPressed: (authState.isLoading || !_acceptTerms)
                    ? null
                    : _handlePhoneLogin,
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: scheme.outlineVariant,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      'OR',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: scheme.outlineVariant,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'Continue with Google',
                onPressed:
                    authState.isLoading ? null : _handleGoogleSignIn,
                leading: authState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: LoadingIndicator(size: 20),
                      )
                    : Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: scheme.primary,
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

}
