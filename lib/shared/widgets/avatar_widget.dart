import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/creator_model.dart';
import '../models/profile_model.dart';
import '../models/call_model.dart';

/// A reusable avatar widget that handles:
/// - Creator photos (URLs from CreatorModel.photo or CreatorInfo.avatar)
/// - User avatars (premade assets from UserModel.avatar)
/// - Creator avatars in UserModel (URLs when role='creator')
/// - Fallback to initials
class AvatarWidget extends StatelessWidget {
  /// Size of the avatar (diameter)
  final double size;
  
  /// User model (for user avatars or creator avatars in UserModel)
  final UserModel? user;
  
  /// Creator model (for creator photos)
  final CreatorModel? creator;
  
  /// User profile model (for user avatars in profile context)
  final UserProfileModel? userProfile;
  
  /// Creator info from call model (for creator photos in calls)
  final CreatorInfo? creatorInfo;
  
  /// Caller info from call model (for caller avatars in calls)
  final CallerInfo? callerInfo;
  
  /// Direct avatar string (for cases where we just have the avatar string)
  /// Can be a URL (http/https/data:) or a premade avatar filename
  final String? avatar;
  
  /// Username for fallback initials
  final String? username;
  
  /// Name for fallback initials (used for creators)
  final String? name;
  
  /// Gender for premade avatar selection
  final String? gender;
  
  /// Role to determine if avatar is a creator photo URL
  final String? role;
  
  /// Background color for fallback avatar
  final Color? backgroundColor;
  
  /// Border radius (use 0 for circular, or a value for rounded corners)
  final double? borderRadius;

  const AvatarWidget({
    super.key,
    this.size = 60,
    this.user,
    this.creator,
    this.userProfile,
    this.creatorInfo,
    this.callerInfo,
    this.avatar,
    this.username,
    this.name,
    this.gender,
    this.role,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Priority 1: Creator photo from CreatorModel
    if (creator != null && creator!.photo.isNotEmpty) {
      return _buildNetworkAvatar(
        url: creator!.photo,
        fallbackText: creator!.name.isNotEmpty ? creator!.name[0].toUpperCase() : 'C',
      );
    }

    // Priority 2: Creator photo from CreatorInfo (call context)
    if (creatorInfo != null && creatorInfo!.avatar != null && creatorInfo!.avatar!.isNotEmpty) {
      final avatarStr = creatorInfo!.avatar!;
      // Check if it's a URL
      if (avatarStr.startsWith('http://') ||
          avatarStr.startsWith('https://') ||
          avatarStr.startsWith('data:')) {
        return _buildNetworkAvatar(
          url: avatarStr,
          fallbackText: creatorInfo!.username?.isNotEmpty == true
              ? creatorInfo!.username![0].toUpperCase()
              : 'C',
        );
      }
    }

    // Priority 3: User avatar from UserModel (check if it's a URL for creators)
    if (user != null && user!.avatar != null && user!.avatar!.isNotEmpty) {
      final avatarStr = user!.avatar!;
      // If user is a creator/admin and avatar is a URL, use it as network image
      if ((user!.role == 'creator' || user!.role == 'admin') &&
          (avatarStr.startsWith('http://') ||
              avatarStr.startsWith('https://') ||
              avatarStr.startsWith('data:'))) {
        return _buildNetworkAvatar(
          url: avatarStr,
          fallbackText: user!.username?.isNotEmpty == true
              ? user!.username![0].toUpperCase()
              : 'U',
        );
      }
      // Otherwise, treat as premade avatar
      return _buildAssetAvatar(
        avatar: avatarStr,
        gender: user!.gender ?? gender ?? 'male',
      );
    }

    // Priority 4: User avatar from UserProfileModel
    if (userProfile != null &&
        userProfile!.avatar != null &&
        userProfile!.avatar!.isNotEmpty) {
      final avatarStr = userProfile!.avatar!;
      // Check if it's a URL (shouldn't be for UserProfileModel, but handle it)
      if (avatarStr.startsWith('http://') ||
          avatarStr.startsWith('https://') ||
          avatarStr.startsWith('data:')) {
        return _buildNetworkAvatar(
          url: avatarStr,
          fallbackText: userProfile!.username?.isNotEmpty == true
              ? userProfile!.username![0].toUpperCase()
              : 'U',
        );
      }
      // Otherwise, treat as premade avatar
      return _buildAssetAvatar(
        avatar: avatarStr,
        gender: userProfile!.gender ?? gender ?? 'male',
      );
    }

    // Priority 5: Caller avatar from CallerInfo
    if (callerInfo != null &&
        callerInfo!.avatar != null &&
        callerInfo!.avatar!.isNotEmpty) {
      final avatarStr = callerInfo!.avatar!;
      // Check if it's a URL
      if (avatarStr.startsWith('http://') ||
          avatarStr.startsWith('https://') ||
          avatarStr.startsWith('data:')) {
        return _buildNetworkAvatar(
          url: avatarStr,
          fallbackText: callerInfo!.username?.isNotEmpty == true
              ? callerInfo!.username![0].toUpperCase()
              : 'U',
        );
      }
      // Otherwise, treat as premade avatar
      return _buildAssetAvatar(
        avatar: avatarStr,
        gender: gender ?? 'male',
      );
    }

    // Priority 6: Direct avatar string
    if (avatar != null && avatar!.isNotEmpty) {
      final avatarStr = avatar!;
      // Check if it's a URL
      if (avatarStr.startsWith('http://') ||
          avatarStr.startsWith('https://') ||
          avatarStr.startsWith('data:')) {
        return _buildNetworkAvatar(
          url: avatarStr,
          fallbackText: _getFallbackText(),
        );
      }
      // Otherwise, treat as premade avatar
      return _buildAssetAvatar(
        avatar: avatarStr,
        gender: gender ?? 'male',
      );
    }

    // Priority 7: Fallback to initials
    return _buildFallbackAvatar();
  }

  Widget _buildNetworkAvatar({
    required String url,
    required String fallbackText,
  }) {
    final bgColor = backgroundColor ?? Colors.purple[400]!;
    final radius = borderRadius ?? size / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackContainer(fallbackText, bgColor, radius);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallbackContainer(fallbackText, bgColor, radius);
        },
      ),
    );
  }

  Widget _buildAssetAvatar({
    required String avatar,
    required String gender,
  }) {
    final avatarPath = gender == 'female'
        ? 'lib/assets/female/$avatar'
        : 'lib/assets/male/$avatar';
    final radius = borderRadius ?? size / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        avatarPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar();
        },
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    final bgColor = backgroundColor ?? Colors.purple[400]!;
    final radius = borderRadius ?? size / 2;
    final fallbackText = _getFallbackText();

    return _buildFallbackContainer(fallbackText, bgColor, radius);
  }

  Widget _buildFallbackContainer(String text, Color bgColor, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getFallbackText() {
    // Try to get text from various sources
    if (name != null && name!.isNotEmpty) {
      return name![0].toUpperCase();
    }
    if (username != null && username!.isNotEmpty) {
      return username![0].toUpperCase();
    }
    if (user?.username != null && user!.username!.isNotEmpty) {
      return user!.username![0].toUpperCase();
    }
    if (userProfile?.username != null && userProfile!.username!.isNotEmpty) {
      return userProfile!.username![0].toUpperCase();
    }
    if (creator?.name != null && creator!.name.isNotEmpty) {
      return creator!.name[0].toUpperCase();
    }
    if (creatorInfo?.username != null && creatorInfo!.username!.isNotEmpty) {
      return creatorInfo!.username![0].toUpperCase();
    }
    if (callerInfo?.username != null && callerInfo!.username!.isNotEmpty) {
      return callerInfo!.username![0].toUpperCase();
    }
    // Default fallback
    return '?';
  }
}
