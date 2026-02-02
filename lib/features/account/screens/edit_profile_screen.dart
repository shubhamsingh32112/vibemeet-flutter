import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/widgets/ui_primitives.dart';
import '../../../shared/styles/app_brand_styles.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _selectedAvatar;
  final Set<String> _selectedCategories = {};
  late PageController _pageController;

  final List<String> _categories = [
    'Trauma',
    'Health',
    'Breakup',
    'Low confidence',
    'Loneliness',
    'Stress',
    'Work',
    'Family',
    'Relationship',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    final availableAvatars = _getAvailableAvatars();
    
    if (user != null) {
      _usernameController.text = user.username ?? user.id.substring(0, 9);
      _selectedAvatar = user.avatar;
      if (user.categories != null) {
        _selectedCategories.addAll(user.categories!);
      }
    }
    
    // Initialize PageController with selected avatar index
    final initialIndex = _selectedAvatar != null && availableAvatars.contains(_selectedAvatar!)
        ? availableAvatars.indexOf(_selectedAvatar!)
        : 0;
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: initialIndex,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  List<String> _getAvailableAvatars() {
    final user = ref.read(authProvider).user;
    final gender = user?.gender ?? 'male';
    
    if (gender == 'female') {
      return List.generate(10, (index) => 'fa${index + 1}.png');
    } else {
      return List.generate(10, (index) => 'a${index + 1}.png');
    }
  }

  String _getAvatarPath(String avatarName) {
    final user = ref.read(authProvider).user;
    final gender = user?.gender ?? 'male';
    
    if (gender == 'female') {
      return 'lib/assets/female/$avatarName';
    } else {
      return 'lib/assets/male/$avatarName';
    }
  }

  Future<void> _saveProfile() async {
    final scheme = Theme.of(context).colorScheme;
    // Validate username
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a username'),
          backgroundColor: scheme.error,
        ),
      );
      return;
    }

    if (username.length < 4 || username.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Username must be 4-10 characters'),
          backgroundColor: scheme.error,
        ),
      );
      return;
    }

    // Validate categories
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least 1 category'),
          backgroundColor: scheme.error,
        ),
      );
      return;
    }

    if (_selectedCategories.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select maximum 4 categories'),
          backgroundColor: scheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('───────────────────────────────────────────────────────');
      debugPrint('🔄 [EDIT PROFILE] Saving profile...');
      debugPrint('   Username: $username');
      debugPrint('   Avatar: $_selectedAvatar');
      debugPrint('   Categories: ${_selectedCategories.toList()}');

      // For creators, don't send avatar (it's managed in admin dashboard)
      final user = ref.read(authProvider).user;
      final isCreator = user?.role == 'creator' || user?.role == 'admin';
      
      final response = await _apiClient.put(
        '/user/profile',
        data: {
          'username': username,
          if (!isCreator) 'avatar': _selectedAvatar, // Only send avatar for non-creators
          'categories': _selectedCategories.toList(),
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [EDIT PROFILE] Profile saved successfully');
        debugPrint('   Response: ${response.data}');
        
        // Refresh user data from backend
        await ref.read(authProvider.notifier).refreshUser();
        
        debugPrint('✅ [EDIT PROFILE] User data refreshed');
        final updatedUser = ref.read(authProvider).user;
        if (updatedUser != null) {
          debugPrint('   Username: ${updatedUser.username}');
          debugPrint('   Avatar: ${updatedUser.avatar}');
          debugPrint('   Categories: ${updatedUser.categories}');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: scheme.surfaceVariant,
            ),
          );
          context.pop();
        }
      } else {
        throw Exception('Failed to save profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [EDIT PROFILE] Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: scheme.error,
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
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final availableAvatars = _getAvailableAvatars();
    final remainingChanges = user != null ? 3 - (user.usernameChangeCount) : 3;
    final scheme = Theme.of(context).colorScheme;
    
    // Update selected avatar if it's not in the current list
    if (_selectedAvatar != null && !availableAvatars.contains(_selectedAvatar!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedAvatar = availableAvatars.isNotEmpty ? availableAvatars[0] : null;
          });
        }
      });
    }

    return AppScaffold(
      padded: false,
      child: Column(
        children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: scheme.onSurface),
                  ),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      // Avatar Selection - Only show for non-creators
                      if (user?.role != 'creator' && user?.role != 'admin') ...[
                        Text(
                          'Your Avatar',
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        // Carousel-style Avatar Selection
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedAvatar = availableAvatars[index];
                              });
                            },
                            itemCount: availableAvatars.length,
                            itemBuilder: (context, index) {
                              final avatar = availableAvatars[index];
                              final isSelected = _selectedAvatar == avatar;
                              
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  setState(() {
                                    _selectedAvatar = avatar;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Center(
                                    child: Container(
                                      width: isSelected ? 150 : 110,
                                      height: isSelected ? 150 : 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppBrandGradients.avatarCarouselSelectedBorder
                                              : AppBrandGradients.avatarCarouselUnselectedBorder,
                                          width: isSelected
                                              ? AppBrandGradients.avatarCarouselSelectedBorderWidth
                                              : AppBrandGradients.avatarCarouselUnselectedBorderWidth,
                                        ),
                                        boxShadow: isSelected
                                            ? [AppBrandGradients.avatarCarouselGlow]
                                            : null,
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          _getAvatarPath(avatar),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: scheme.surfaceContainerHigh,
                                              child: Icon(
                                                Icons.person,
                                                color: scheme.onSurfaceVariant,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ] else ...[
                        // For creators, show a message that their photo is managed in admin dashboard
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: scheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your profile photo is managed in the admin dashboard.',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                      
                      // Username Field
                      Text(
                        'Username *',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: scheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: scheme.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: scheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: scheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Can change username $remainingChanges more time${remainingChanges != 1 ? 's' : ''}.',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Username must be 4-10 characters.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Category Selection
                      Text(
                        'Select a category *',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  if (_selectedCategories.length < 4) {
                                    _selectedCategories.add(category);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Maximum 4 categories allowed'),
                                        backgroundColor: scheme.error,
                                      ),
                                    );
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? scheme.primaryContainer
                                    : scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: scheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .scale(delay: 100.ms);
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 12),
                      Text(
                        'Select a minimum of 1 and maximum of 4.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Save Button
                      SizedBox(
                        height: 56,
                        child: PrimaryButton(
                          label: 'Save',
                          onPressed: _isLoading ? null : _saveProfile,
                          isLoading: _isLoading,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
