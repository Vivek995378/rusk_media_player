import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
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
        // Gradient ring around avatar
        Container(
          padding: context.paddingAll(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: brandGradient,
          ),
          child: Container(
            padding: context.paddingAll(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: black,
            ),
            child: CircleAvatar(
              radius: context.sq(18),
              backgroundImage: NetworkImage(
                profileImageUrl,
              ),
            ),
          ),
        ),
        Text(
          username,
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: context.fontSize(16),
            shadows: [
              Shadow(
                color: black.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const VideoFeedViewFollowButton(),
      ],
    );
  }
}
