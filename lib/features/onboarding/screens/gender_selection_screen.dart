import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/avatar_upload_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/welcome_dialog.dart';
import '../../../core/services/welcome_service.dart';
import '../../auth/providers/auth_provider.dart';

class GenderSelectionScreen extends ConsumerStatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  ConsumerState<GenderSelectionScreen> createState() =>
      _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends ConsumerState<GenderSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedAvatar;
  bool _isLoading = false;
  bool _welcomeDialogShown = false;
  final ApiClient _apiClient = ApiClient();

  // Male avatars
  final List<String> _maleAvatars =
      List.generate(10, (i) => 'a${i + 1}.png');

  // Female avatars
  final List<String> _femaleAvatars =
      List.generate(10, (i) => 'fa${i + 1}.png');

  @override
  void initState() {
    super.initState();
    _checkAndShowWelcomeDialog();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> get _currentAvatars {
    if (_selectedGender == 'male') return _maleAvatars;
    if (_selectedGender == 'female') return _femaleAvatars;
    return [];
  }

  String _getAvatarAssetPath(String avatarName) {
    if (_selectedGender == 'female') {
      return 'lib/assets/female/$avatarName';
    }
    return 'lib/assets/male/$avatarName';
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;

    final hasSeen = await WelcomeService.hasSeenWelcome();
    if (!hasSeen && !_welcomeDialogShown && mounted) {
      _welcomeDialogShown = true;
      _showWelcomeDialog();
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WelcomeDialog(
        onAgree: () async {
          await WelcomeService.markWelcomeAsSeen();
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    // ── Validate name ───────────────────────────────────────────────────
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }
    if (name.length < 4 || name.length > 10) {
      _showError('Name must be 4–10 characters');
      return;
    }

    // ── Validate gender ─────────────────────────────────────────────────
    if (_selectedGender == null) {
      _showError('Please select your gender');
      return;
    }

    // ── Validate avatar ─────────────────────────────────────────────────
    if (_selectedAvatar == null) {
      _showError('Please select an avatar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final firebaseUid = authState.firebaseUser?.uid;

      if (firebaseUid == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [ONBOARDING] Saving profile...');
      debugPrint('   Name: $name');
      debugPrint('   Gender: $_selectedGender');
      debugPrint('   Avatar: $_selectedAvatar');

      // 1. Upload avatar to Firebase Storage
      debugPrint('🖼️  [ONBOARDING] Uploading avatar to Firebase Storage...');
      final avatarUrl = await AvatarUploadService.uploadAvatar(
        firebaseUid: firebaseUid,
        avatarName: _selectedAvatar!,
        gender: _selectedGender!,
      );
      debugPrint('✅ [ONBOARDING] Avatar uploaded: $avatarUrl');

      // 2. Save everything to backend in a single call
      final response = await _apiClient.put(
        '/user/profile',
        data: {
          'gender': _selectedGender,
          'username': name,
          'avatar': avatarUrl,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [ONBOARDING] Profile saved successfully');

        // Refresh user data in auth provider
        await ref.read(authProvider.notifier).refreshUser();

        if (mounted) context.go('/home');
      } else {
        throw Exception('Failed to save profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [ONBOARDING] Error: $e');
      if (mounted) _showError('Failed to save profile: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool canContinue =
        _nameController.text.trim().length >= 4 &&
        _selectedGender != null &&
        _selectedAvatar != null;

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
              const Color(0xFF2D1B3D),
              const Color(0xFF3D2B4D),
              const Color(0xFF2D1B3D),
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
                  const SizedBox(height: 40),

                  // ── Title ──────────────────────────────────────────
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

                  const SizedBox(height: 8),

                  Text(
                    "Let's get you set up",
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: -0.2, end: 0),

                  const SizedBox(height: 40),

                  // ── Name field ─────────────────────────────────────
                  Text(
                    'Your Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLength: 10,
                    onChanged: (_) => setState(() {}), // rebuild for button state
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      counterStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 8),

                  Text(
                    '4–10 characters',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),

                  const SizedBox(height: 32),

                  // ── Gender selection ────────────────────────────────
                  Text(
                    'Select your gender',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderChip(
                          icon: Icons.male,
                          label: 'Male',
                          value: 'male',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderChip(
                          icon: Icons.female,
                          label: 'Female',
                          value: 'female',
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // ── Avatar selection (only when gender is chosen) ──
                  if (_selectedGender != null) ...[
                    Text(
                      'Choose your avatar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms),

                    const SizedBox(height: 16),

                    _buildAvatarGrid()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),
                  ],

                  // ── Continue button ────────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (canContinue ? _saveProfile : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canContinue ? Colors.white : Colors.grey[600],
                        foregroundColor: canContinue
                            ? const Color(0xFF2D1B3D)
                            : Colors.grey[400],
                        disabledBackgroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENDER CHIP
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGenderChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
          _selectedAvatar = null; // reset avatar when switching gender
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.12),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AVATAR GRID
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAvatarGrid() {
    final avatars = _currentAvatars;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = _selectedAvatar == avatar;

        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = avatar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Image.asset(
                _getAvatarAssetPath(avatar),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
