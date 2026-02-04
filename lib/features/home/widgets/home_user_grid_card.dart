import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/creator_model.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/styles/app_brand_styles.dart';
import '../../../shared/widgets/ui_primitives.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../providers/home_provider.dart';
import '../../video/services/call_service.dart';
import '../../video/providers/stream_video_provider.dart';
import '../../video/services/call_navigation_service.dart';
import '../../video/services/permission_service.dart';

class HomeUserGridCard extends ConsumerStatefulWidget {
  final CreatorModel? creator;
  final UserProfileModel? user;

  const HomeUserGridCard({
    super.key,
    this.creator,
    this.user,
  }) : assert(creator != null || user != null, 'Either creator or user must be provided');

  @override
  ConsumerState<HomeUserGridCard> createState() => _HomeUserGridCardState();
}

class _HomeUserGridCardState extends ConsumerState<HomeUserGridCard> {
  bool _isInitiatingCall = false;

  Future<void> _initiateVideoCall() async {
    if (widget.creator == null) return;
    if (_isInitiatingCall) return;

    setState(() {
      _isInitiatingCall = true;
    });

    try {
      final callService = ref.read(callServiceProvider);
      final streamVideo = ref.read(streamVideoProvider);

      if (streamVideo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video service not available. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get current user's Firebase UID
      final authState = ref.read(authProvider);
      final firebaseUser = authState.firebaseUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      // Get creator's Firebase UID (required for Stream Video calls)
      final creatorFirebaseUid = widget.creator!.firebaseUid;
      if (creatorFirebaseUid == null) {
        throw Exception('Creator Firebase UID not available');
      }
      
      // 🔥 CRITICAL: Request camera and microphone permissions BEFORE starting call
      // Stream SDK does NOT auto-request permissions
      // Must be done BEFORE getOrCreate() / join()
      // video: true because this is a video call
      final hasPermissions = await PermissionService.ensurePermissions(video: true);
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera and microphone permissions are required for video calls'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // Initiate call using SDK (not REST)
      // This replaces the old REST-based approach - calls are now created entirely via SDK
      final call = await callService.initiateCall(
        creatorFirebaseUid: creatorFirebaseUid,
        currentUserFirebaseUid: firebaseUser.uid,
        creatorMongoId: widget.creator!.id,
        streamVideo: streamVideo,
      );

      // 🔥 CRITICAL FIX: Navigate IMMEDIATELY after call creation (BEFORE join)
      // Stream Video call flow: create call → show UI → join() in background
      // join() blocks waiting for callee to accept - don't block UI thread
      // The call screen will handle the join state and show appropriate UI
      CallNavigationService.navigateToCall(call);
      
      // Join the call in background (non-blocking)
      // This allows UI to show immediately while waiting for callee to accept
      callService.joinCall(call).then((_) {
        debugPrint('✅ [HOME CARD] Join completed successfully');
      }).catchError((error) {
        debugPrint('❌ [HOME CARD] Error joining call: $error');
        // Error is handled by call screen - user can see the failure state
      });
    } catch (e) {
      debugPrint('❌ [HOME CARD] Error initiating call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start video call: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitiatingCall = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final String title = widget.creator?.name ?? widget.user?.username ?? 'User';
    final authState = ref.watch(authProvider);
    final isRegularUser = authState.user?.role == 'user';
    final showFavorite = isRegularUser && widget.creator != null;
    final showVideoCall = isRegularUser && widget.creator != null;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _CardImage(creator: widget.creator, user: widget.user)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppBrandGradients.userCardOverlay(scheme),
                ),
              ),
            ),
            if (showFavorite)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: _FavoriteButton(
                  isFavorite: widget.creator!.isFavorite,
                  onPressed: () async {
                    try {
                      final apiClient = ApiClient();
                      await apiClient.post('/user/favorites/${widget.creator!.id}');
                      // Refresh feed to get updated isFavorite flags
                      ref.invalidate(creatorsProvider);
                      ref.invalidate(homeFeedProvider);
                    } catch (_) {
                      // Non-blocking: if request fails, UI will resync on next refresh.
                    }
                  },
                ),
              ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _CardText(
                      title: title,
                      subtitle: _subtitle(),
                      textColor: scheme.onSurface,
                    ),
                  ),
                  if (showVideoCall) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _VideoCallButton(
                      isLoading: _isInitiatingCall,
                      onPressed: _initiateVideoCall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _subtitle() {
    // Only show if something relevant is available (don't hardcode).
    // If you later add country/flag to the feed model, map it here.
    return null;
  }
}

class _VideoCallButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _VideoCallButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                  ),
                )
              : Icon(
                  Icons.videocam,
                  color: scheme.onPrimary,
                  size: 20,
                ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? scheme.error : scheme.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _CardText extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color textColor;

  const _CardText({
    required this.title,
    required this.subtitle,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subtitleStyle,
          ),
        ],
      ],
    );
  }
}

class _CardImage extends StatelessWidget {
  final CreatorModel? creator;
  final UserProfileModel? user;

  const _CardImage({required this.creator, required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarStr = creator?.photo ?? user?.avatar;
    if (avatarStr == null || avatarStr.isEmpty) {
      // Fallback to a semantic surface tone (no hardcoded colors).
      final scheme = Theme.of(context).colorScheme;
      return DecoratedBox(decoration: BoxDecoration(color: scheme.surfaceContainerHigh));
    }

    if (avatarStr.startsWith('http://') ||
        avatarStr.startsWith('https://') ||
        avatarStr.startsWith('data:')) {
      return Image.network(
        avatarStr,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          final scheme = Theme.of(context).colorScheme;
          return DecoratedBox(decoration: BoxDecoration(color: scheme.surfaceContainerHigh));
        },
      );
    }

    // Treat as premade avatar asset (user only).
    final gender = user?.gender ?? 'male';
    final assetPath = gender == 'female' ? 'lib/assets/female/$avatarStr' : 'lib/assets/male/$avatarStr';
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        final scheme = Theme.of(context).colorScheme;
        return DecoratedBox(decoration: BoxDecoration(color: scheme.surfaceContainerHigh));
      },
    );
  }
}

