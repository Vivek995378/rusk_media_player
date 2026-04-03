import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';

class VideoFeedViewDescriptionText extends StatelessWidget {
  const VideoFeedViewDescriptionText({
    required this.text,
    super.key,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    final displayText = text.length > AppSizes.descriptionMaxLength
        ? '${text.substring(0, AppSizes.descriptionMaxLength)}...'
        : text;

    return AppText(
      displayText,
      color: white,
      shadows: [
        Shadow(
          color: black.withValues(alpha: 0.6),
          blurRadius: 4,
        ),
      ],
    );
  }
}
