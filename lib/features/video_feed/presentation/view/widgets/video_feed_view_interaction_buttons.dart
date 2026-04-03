import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_interaction_button.dart';

class VideoFeedViewInteractionButtons extends StatelessWidget {
  const VideoFeedViewInteractionButtons({
    required this.isLiked,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    super.key,
  });

  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.h(80),
        right: context.w(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: context.h(24),
        children: [
          VideoFeedViewInteractionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? red : white,
            onTap: onLikeTap,
          ),
          VideoFeedViewInteractionButton(
            icon: LucideIcons.messageCircle,
            onTap: onCommentTap,
          ),
          VideoFeedViewInteractionButton(
            icon: LucideIcons.send,
            onTap: onShareTap,
          ),
        ],
      ),
    );
  }
}
