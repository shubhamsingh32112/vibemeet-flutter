import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/creator_model.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/styles/app_brand_styles.dart';
import '../../../shared/widgets/ui_primitives.dart';
import '../../auth/providers/auth_provider.dart';
import '../../call/services/call_service.dart';
import '../../call/utils/call_helper.dart';
import '../../../core/api/api_client.dart';
import '../providers/home_provider.dart';

class HomeUserGridCard extends ConsumerWidget {
  final CreatorModel? creator;
  final UserProfileModel? user;

  const HomeUserGridCard({
    super.key,
    this.creator,
    this.user,
  }) : assert(creator != null || user != null, 'Either creator or user must be provided');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final String title = creator?.name ?? user?.username ?? 'User';
    final authState = ref.watch(authProvider);
    final isRegularUser = authState.user?.role == 'user';
    final showFavorite = isRegularUser && creator != null;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: _CardImage(creator: creator, user: user)),
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
                  isFavorite: creator!.isFavorite,
                  onPressed: () async {
                    try {
                      final apiClient = ApiClient();
                      await apiClient.post('/user/favorites/${creator!.id}');
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
                  const SizedBox(width: AppSpacing.md),
                  _VideoPillButton(
                    onPressed: creator == null ? null : () => _initiateVideoCall(context, creator!),
                  ),
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

  Future<void> _initiateVideoCall(BuildContext context, CreatorModel creator) async {
    final callService = CallService();
    await initiateVideoCall(
      context: context,
      creatorUserId: creator.userId,
      initiateCallFn: callService.initiateCall,
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

class _VideoPillButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _VideoPillButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam, size: 18, color: scheme.onPrimary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Video',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
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

