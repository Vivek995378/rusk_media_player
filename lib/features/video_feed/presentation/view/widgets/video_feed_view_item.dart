import 'package:flutter/material.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_heart_animation.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_optimized_video_player.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_overlay_section.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_progress_scrubber.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_retention_paywall.dart';
import 'package:video_player/video_player.dart';

class VideoFeedViewItem extends StatefulWidget {
  const VideoFeedViewItem({
    required this.videoItem,
    required this.controller,
    super.key,
  });
  final VideoEntity videoItem;
  final VideoPlayerController? controller;

  @override
  State<VideoFeedViewItem> createState() =>
      _VideoFeedViewItemState();
}

class _VideoFeedViewItemState
    extends State<VideoFeedViewItem> {
  final _heartKey =
      GlobalKey<VideoFeedViewHeartAnimationState>();

  bool get _isReady {
    final c = widget.controller;
    return c != null &&
        c.value.isInitialized &&
        !c.value.hasError &&
        c.value.duration.inMilliseconds > 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _isReady
          ? (details) {
              _heartKey.currentState?.trigger(
                details.localPosition,
              );
            }
          : null,
      onDoubleTap: _isReady ? () {} : null,
      child: Stack(
        children: [
          // Player shows shimmer when not ready
          VideoFeedViewOptimizedVideoPlayer(
            controller: widget.controller,
            videoId: widget.videoItem.id,
          ),
          // Only show overlay + controls when ready
          if (_isReady) ...[
            VideoFeedViewOverlaySection(
              profileImageUrl:
                  widget.videoItem.profileImageUrl,
              username: widget.videoItem.username,
              description:
                  widget.videoItem.description,
              isBookmarked:
                  widget.videoItem.isBookmarked,
              isLiked: widget.videoItem.isLiked,
              likeCount: widget.videoItem.likeCount,
              commentCount:
                  widget.videoItem.commentCount,
              shareCount:
                  widget.videoItem.shareCount,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoFeedViewProgressScrubber(
                controller: widget.controller,
              ),
            ),
            VideoFeedViewRetentionPaywall(
              controller: widget.controller,
            ),
            VideoFeedViewHeartAnimation(
              key: _heartKey,
            ),
          ],
        ],
      ),
    );
  }
}
