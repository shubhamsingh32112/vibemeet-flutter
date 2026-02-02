import 'package:flutter/material.dart';
import '../models/creator_model.dart';
import '../models/profile_model.dart';
import '../../features/call/services/call_service.dart';
import '../../features/call/utils/call_helper.dart';
import 'avatar_widget.dart';

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
                    child: AvatarWidget(
                      creator: creator,
                      size: 60,
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
            // Pricing and Action Buttons
            Row(
              children: [
                // Call Price
                Flexible(
                  child: Container(
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
                        Flexible(
                          child: Text(
                            '${creator.price.toInt()} coins/min',
                            style: TextStyle(
                              color: Colors.grey[200],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Video Call Button with Price
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: () => _initiateVideoCall(context, creator),
                    icon: const Icon(Icons.videocam, size: 18),
                    label: Text('${creator.price.toInt()} coins/min'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

    await initiateVideoCall(
      context: context,
      creatorUserId: creator.userId,
      initiateCallFn: callService.initiateCall,
    );
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
                  child: ClipOval(
                    child: AvatarWidget(
                      userProfile: user,
                      size: 60,
                    ),
                  ),
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

}
