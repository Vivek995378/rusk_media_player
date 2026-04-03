import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_dev_snackbar.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_feature_hints.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_heart_animation.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_mute_button.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_optimized_video_player.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_overlay_section.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_play_pause_indicator.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_progress_scrubber.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_retention_paywall.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_volume_gesture.dart';
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
  State<VideoFeedViewItem> createState() => _VideoFeedViewItemState();
}

class _VideoFeedViewItemState extends State<VideoFeedViewItem> {
  final _heartKey = GlobalKey<VideoFeedViewHeartAnimationState>();
  final _playPauseKey = GlobalKey<VideoFeedViewPlayPauseIndicatorState>();
  final _scrubberKey = GlobalKey<VideoFeedViewProgressScrubberState>();
  bool _showHints = false;

  @override
  void initState() {
    super.initState();
    if (!VideoFeedViewFeatureHints.hasShown) {
      VideoFeedViewFeatureHints.hasShown = true;
      _showHints = true;
      _pauseForHints();
    }
  }

  void _pauseForHints() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller?.pause();
    });
  }

  void _onHintsDismissed() {
    if (!mounted) return;
    setState(() => _showHints = false);
    widget.controller?.play();
  }

  bool get _isReady {
    final c = widget.controller;
    return c != null &&
        c.value.isInitialized &&
        !c.value.hasError &&
        c.value.duration.inMilliseconds > 0;
  }

  @override
  void didUpdateWidget(VideoFeedViewItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_showHints &&
        widget.controller != oldWidget.controller &&
        widget.controller != null) {
      widget.controller!.pause();
    }
  }

  void _toggleLike() {
    context.read<VideoFeedCubit>().toggleLike(widget.videoItem.id);
  }

  void _togglePlayPause() {
    if (!_isReady) return;
    final c = widget.controller!;
    if (c.value.isPlaying) {
      c.pause();
      _playPauseKey.currentState?.show(isPlaying: false);
    } else {
      c.play();
      _playPauseKey.currentState?.show(isPlaying: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTapDown: _isReady
          ? (details) {
              _heartKey.currentState?.trigger(details.localPosition);
              final cubit = context.read<VideoFeedCubit>();
              if (!cubit.state.isVideoLiked(widget.videoItem.id)) {
                _toggleLike();
              }
            }
          : null,
      onDoubleTap: _isReady ? () {} : null,
      child: VideoFeedViewVolumeGesture(
        controller: widget.controller,
        scrubberKey: _scrubberKey,
        child: Stack(
          children: [
            VideoFeedViewOptimizedVideoPlayer(
              controller: widget.controller,
              videoId: widget.videoItem.id,
            ),
            if (_isReady) ...[
              BlocSelector<VideoFeedCubit, VideoFeedState, bool>(
                selector: (state) => state.isVideoLiked(widget.videoItem.id),
                builder: (context, isLiked) {
                  return VideoFeedViewOverlaySection(
                    profileImageUrl: widget.videoItem.profileImageUrl,
                    username: widget.videoItem.username,
                    description: widget.videoItem.description,
                    isLiked: isLiked,
                    onLikeTap: _toggleLike,
                    onCommentTap: () =>
                        showDevSnackbar(context, AppStrings.commentsFeature),
                    onShareTap: () =>
                        showDevSnackbar(context, AppStrings.shareFeature),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoFeedViewProgressScrubber(
                  key: _scrubberKey,
                  controller: widget.controller,
                ),
              ),
              VideoFeedViewRetentionPaywall(controller: widget.controller),
              VideoFeedViewHeartAnimation(key: _heartKey),
              VideoFeedViewPlayPauseIndicator(key: _playPauseKey),
              VideoFeedViewMuteButton(controller: widget.controller),
            ],
            if (_showHints)
              Positioned.fill(
                child: VideoFeedViewFeatureHints(
                  onDismiss: _onHintsDismissed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
