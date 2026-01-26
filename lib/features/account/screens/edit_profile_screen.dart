import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/widgets/loading_indicator.dart';
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
    // Validate username
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (username.length < 4 || username.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username must be 4-10 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate categories
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategories.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select maximum 4 categories'),
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
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
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
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final availableAvatars = _getAvailableAvatars();
    final remainingChanges = user != null ? 3 - (user.usernameChangeCount) : 3;
    
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
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
                        const Text(
                          'Your Avatar',
                          style: TextStyle(
                            color: Colors.white,
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
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                          width: isSelected ? 4 : 2,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.3),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          _getAvatarPath(avatar),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.amber[300],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your profile photo is managed in the admin dashboard.',
                                  style: TextStyle(
                                    color: Colors.amber[100],
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
                      const Text(
                        'Username *',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.white,
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
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Username must be 4-10 characters.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Category Selection
                      const Text(
                        'Select a category *',
                        style: TextStyle(
                          color: Colors.white,
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
                                      const SnackBar(
                                        content: Text('Maximum 4 categories allowed'),
                                        backgroundColor: Colors.orange,
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
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: Colors.white,
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
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Save Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2D1B3D),
                            disabledBackgroundColor: Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const LoadingIndicator()
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
