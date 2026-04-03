import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_description_text.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_user_header.dart';

class VideoFeedViewUserInfoSection extends StatelessWidget {
  const VideoFeedViewUserInfoSection({
    required this.profileImageUrl,
    required this.username,
    required this.description,
    super.key,
  });
  final String profileImageUrl;
  final String username;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.w(16),
        right: context.w(16),
        top: context.h(16),
        bottom: context.h(80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: context.h(8),
        children: [
          VideoFeedViewUserHeader(
            profileImageUrl: profileImageUrl,
            username: username,
          ),
          VideoFeedViewDescriptionText(text: description),
        ],
      ),
    );
  }
}
