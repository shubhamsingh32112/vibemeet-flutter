import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/welcome_dialog.dart';
import '../../../core/services/welcome_service.dart';
import '../../auth/providers/auth_provider.dart';

class GenderSelectionScreen extends ConsumerStatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  ConsumerState<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends ConsumerState<GenderSelectionScreen> {
  String? _selectedGender;
  bool _isLoading = false;
  bool _welcomeDialogShown = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    // Check and show welcome dialog if needed
    _checkAndShowWelcomeDialog();
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    // Wait for the first frame to ensure context is available
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Check if user is authenticated
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      return; // Don't show welcome dialog if not authenticated
    }
    
    // Check if user has seen the welcome dialog
    final hasSeen = await WelcomeService.hasSeenWelcome();
    if (!hasSeen && !_welcomeDialogShown && mounted) {
      _welcomeDialogShown = true;
      _showWelcomeDialog();
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must click "I agree"
      builder: (context) => WelcomeDialog(
        onAgree: () async {
          // Mark as seen
          await WelcomeService.markWelcomeAsSeen();
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Future<void> _saveGender() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [GENDER] Saving gender to backend...');
      debugPrint('   Gender: $_selectedGender');
      
      final response = await _apiClient.put(
        '/user/profile',
        data: {'gender': _selectedGender},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [GENDER] Gender saved successfully');
        debugPrint('   Response: ${response.data}');
        
        // Refresh user data in auth provider
        await ref.read(authProvider.notifier).refreshUser();
        
        // Navigate to home
        if (mounted) {
          context.go('/home');
        }
      } else {
        throw Exception('Failed to save gender: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [GENDER] Error saving gender: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save gender: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D1B3D),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  
                  // Title
                  Text(
                    'Tell us about yourself',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 28,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Select your gender',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Gender Options
                  _buildGenderOption(
                    icon: Icons.male,
                    label: 'Male',
                    value: 'male',
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  _buildGenderOption(
                    icon: Icons.female,
                    label: 'Female',
                    value: 'female',
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  _buildGenderOption(
                    icon: Icons.person,
                    label: 'Other',
                    value: 'other',
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Continue Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveGender,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedGender != null
                            ? Colors.white
                            : Colors.grey[600],
                        foregroundColor: _selectedGender != null
                            ? const Color(0xFF2D1B3D)
                            : Colors.grey[400],
                        disabledBackgroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const LoadingIndicator()
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _selectedGender == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
