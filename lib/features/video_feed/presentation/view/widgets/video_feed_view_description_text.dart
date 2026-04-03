import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class VideoFeedViewDescriptionText extends StatelessWidget {
  const VideoFeedViewDescriptionText({
    required this.text,
    super.key,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.length > 50
          ? '${text.substring(0, 50)}...'
          : text,
      style: TextStyle(
        color: white.withValues(alpha: 0.9),
        fontSize: context.fontSize(15),
        shadows: [
          Shadow(
            color: black.withValues(alpha: 0.6),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
