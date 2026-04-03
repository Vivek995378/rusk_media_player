import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_follow_button.dart';

class VideoFeedViewUserHeader extends StatelessWidget {
  const VideoFeedViewUserHeader({
    required this.profileImageUrl,
    required this.username,
    super.key,
  });
  final String profileImageUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.w(8),
      children: [
        Container(
          padding: context.paddingAll(AppSizes.avatarRingPadding),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: brandGradient,
          ),
          child: CircleAvatar(
            radius: context.sq(AppSizes.avatarRadius),
            backgroundImage: NetworkImage(profileImageUrl),
          ),
        ),
        AppText(
          username,
          style: AppTextStyle.titleLarge,
          color: MENeutralColors.neutral0,
        ),
        const VideoFeedViewFollowButton(),
      ],
    );
  }
}
