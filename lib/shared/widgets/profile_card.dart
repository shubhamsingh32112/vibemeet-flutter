import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/creator_model.dart';
import '../models/profile_model.dart';
import '../../features/call/services/call_service.dart';

class ProfileCard extends StatelessWidget {
  final CreatorModel? creator;
  final UserProfileModel? user;
  final String? language; // Default language to display

  const ProfileCard({
    super.key,
    this.creator,
    this.user,
    this.language = 'Hindi',
  }) : assert(creator != null || user != null, 'Either creator or user must be provided');

  @override
  Widget build(BuildContext context) {
    if (creator != null) {
      return _buildCreatorCard(context, creator!);
    } else if (user != null) {
      return _buildUserCard(context, user!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCreatorCard(BuildContext context, CreatorModel creator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[800]!.withOpacity(0.8),
            Colors.purple[900]!.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: creator.photo.startsWith('http') || creator.photo.startsWith('data:')
                        ? Image.network(
                            creator.photo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.purple[400],
                                child: Center(
                                  child: Text(
                                    creator.name.isNotEmpty
                                        ? creator.name[0].toUpperCase()
                                        : 'C',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            creator.photo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.purple[400],
                                child: Center(
                                  child: Text(
                                    creator.name.isNotEmpty
                                        ? creator.name[0].toUpperCase()
                                        : 'C',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Language
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language ?? 'Hindi',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // About
            Text(
              creator.about,
              style: TextStyle(
                color: Colors.grey[200],
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Categories
            if (creator.categories != null && creator.categories!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: creator.categories!.take(4).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            // Pricing and Video Call Button
            Row(
              children: [
                // Call Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'e${creator.price.toInt()}/min',
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Video Call Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam,
                        size: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'e${(creator.price * 3).toInt()}/min',
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Video Call Button
                ElevatedButton.icon(
                  onPressed: () => _initiateVideoCall(context, creator),
                  icon: const Icon(Icons.videocam, size: 18),
                  label: const Text('Video Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Initiate video call
  Future<void> _initiateVideoCall(BuildContext context, CreatorModel creator) async {
    debugPrint('📞 [HOME] User tapped video call button');
    debugPrint('   Creator: ${creator.name}');
    debugPrint('   Creator ID: ${creator.id}');
    debugPrint('   Creator User ID: ${creator.userId}');

    final callService = CallService();
    
    try {
      debugPrint('🔄 [HOME] Showing loading dialog...');
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      debugPrint('🔄 [HOME] Initiating call via API...');
      // Initiate call (userId is always present - required field)
      final call = await callService.initiateCall(creator.userId);
      debugPrint('✅ [HOME] Call initiated successfully');
      debugPrint('   CallId: ${call.callId}');
      debugPrint('   Channel: ${call.channelName}');
      debugPrint('   Status: ${call.status.name}');

      // Close loading
      if (context.mounted) {
        Navigator.of(context).pop();
        debugPrint('🔄 [HOME] Loading dialog closed');

        debugPrint('🔄 [HOME] Navigating to video call screen...');
        // Navigate to video call screen (will poll for token)
        context.push('/video-call', extra: {
          'callId': call.callId,
          'channelName': call.channelName,
          'token': null, // Will poll for token
        });
        debugPrint('✅ [HOME] Navigation complete');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [HOME] Initiate call error: $e');
      debugPrint('   Stack: $stackTrace');
      // Close loading if still open
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate call: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildUserCard(BuildContext context, UserProfileModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[800]!.withOpacity(0.8),
            Colors.purple[900]!.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _buildUserAvatar(user),
                ),
                const SizedBox(width: 12),
                // Username and Language
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language ?? 'Hindi',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Categories
            if (user.categories.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.categories.take(4).map((category) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No categories selected',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserProfileModel user) {
    // If user has selected an avatar, use it
    if (user.avatar != null && user.avatar!.isNotEmpty) {
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

  Widget _buildFallbackAvatar(UserProfileModel user) {
    return Container(
      color: Colors.purple[400],
      child: Center(
        child: Text(
          (user.username?.isNotEmpty ?? false)
              ? user.username![0].toUpperCase()
              : 'U',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
