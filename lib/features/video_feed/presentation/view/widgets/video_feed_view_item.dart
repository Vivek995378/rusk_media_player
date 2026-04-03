import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/domain/entities/video_entity.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_cubit.dart';
import 'package:rusk_media_player/features/video_feed/presentation/bloc/video_feed_state.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_dev_snackbar.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_heart_animation.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_like_count_animation.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_mute_indicator.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_optimized_video_player.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_overlay_section.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_progress_scrubber.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_retention_paywall.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_volume_bar.dart';
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

class _VideoFeedViewItemState extends State<VideoFeedViewItem>
    with SingleTickerProviderStateMixin {
  final _heartKey = GlobalKey<VideoFeedViewHeartAnimationState>();
  final _muteKey = GlobalKey<VideoFeedViewMuteIndicatorState>();

  // Like count animation
  int _likeCountAnimKey = 0;
  int _consecutiveLikes = 0;
  Offset _lastDoubleTapPosition = Offset.zero;

  // Mute state
  bool _isMuted = false;

  // Long-press hold-to-pause + volume drag
  bool _isHoldingToPause = false;
  bool _wasPlayingBeforeHold = false;
  bool _isDraggingVolume = false;
  double _dragStartY = 0;
  double _startVolume = 1;
  double _volume = 1;

  // Volume bar fade
  late final AnimationController _volumeFadeCtrl;
  late final Animation<double> _volumeFadeAnim;

  // ValueNotifiers to avoid full setState on every drag frame
  final _volumeNotifier = ValueNotifier<double>(1.0);
  final _holdingNotifier = ValueNotifier<bool>(false);
  final _scrubNotifier = ScrubNotifier();

  // Gesture disambiguation: track initial drag direction
  bool _isDraggingHorizontal = false;
  double _dragStartX = 0;
  double _startProgress = 0;

  bool get _isReady {
    final c = widget.controller;
    return c != null &&
        c.value.isInitialized &&
        !c.value.hasError &&
        c.value.duration.inMilliseconds > 0;
  }

  @override
  void initState() {
    super.initState();
    _volumeFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _volumeFadeAnim = CurvedAnimation(
      parent: _volumeFadeCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _volumeFadeCtrl.dispose();
    _volumeNotifier.dispose();
    _holdingNotifier.dispose();
    _scrubNotifier.dispose();
    super.dispose();
  }

  // ── Single tap → mute / unmute ──────────────────────────────────────────
  void _toggleMute() {
    if (!_isReady) return;
    final c = widget.controller!;
    _isMuted = !_isMuted;
    c.setVolume(_isMuted ? 0 : _volume);
    _muteKey.currentState?.show(isMuted: _isMuted);
    HapticFeedback.lightImpact();
    setState(() {});
  }

  // ── Double tap → heart like ─────────────────────────────────────────────
  void _toggleLike() {
    context.read<VideoFeedCubit>().toggleLike(widget.videoItem.id);
  }

  // ── Long press → hold to pause + drag up/down = volume, left/right = seek ──
  void _onLongPressStart(LongPressStartDetails details) {
    if (!_isReady) return;
    final c = widget.controller!;
    _wasPlayingBeforeHold = c.value.isPlaying;
    if (_wasPlayingBeforeHold) c.pause();
    _isHoldingToPause = true;
    _isDraggingVolume = false;
    _isDraggingHorizontal = false;
    _dragStartY = details.localPosition.dy;
    _dragStartX = details.localPosition.dx;
    _startVolume = _volume;
    // Capture current progress for seek baseline
    final ctrl = widget.controller!;
    final dur = ctrl.value.duration.inMilliseconds;
    _startProgress = dur > 0
        ? ctrl.value.position.inMilliseconds / dur
        : 0.0;
    _holdingNotifier.value = true;
    HapticFeedback.mediumImpact();
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isHoldingToPause || !_isReady) return;
    final dy = _dragStartY - details.localPosition.dy;
    final dx = details.localPosition.dx - _dragStartX;

    // Determine drag axis on first significant movement (15px threshold)
    if (!_isDraggingVolume && !_isDraggingHorizontal) {
      if (dx.abs() > 15 && dx.abs() > dy.abs()) {
        _isDraggingHorizontal = true;
        HapticFeedback.selectionClick();
      } else if (dy.abs() > 10) {
        _isDraggingVolume = true;
        _volumeFadeCtrl.forward();
      }
    }

    if (_isDraggingVolume) {
      // Vertical → volume
      final sensitivity = context.screenHeight * 0.45;
      final newVolume = (_startVolume + dy / sensitivity).clamp(0.0, 1.0);
      _volume = newVolume;
      _isMuted = _volume <= 0;
      widget.controller!.setVolume(_volume);
      _volumeNotifier.value = newVolume;
    } else if (_isDraggingHorizontal) {
      // Horizontal → seek
      // Full screen width = full video duration
      final sensitivity = context.screenWidth;
      final delta = dx / sensitivity; // fraction of total duration
      final newProgress = (_startProgress + delta).clamp(0.0, 1.0);
      _scrubNotifier.begin(newProgress);
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (!_isReady) return;
    _isHoldingToPause = false;
    _holdingNotifier.value = false;

    if (_isDraggingVolume) {
      _isDraggingVolume = false;
      _volumeFadeCtrl.reverse();
      if (_wasPlayingBeforeHold) widget.controller!.play();
    } else if (_isDraggingHorizontal) {
      _isDraggingHorizontal = false;
      _scrubNotifier.end(); // scrubber handles seek + resume
    } else {
      // Pure hold (no drag) → just resume
      if (_wasPlayingBeforeHold) widget.controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleMute,
      onDoubleTapDown: _isReady
          ? (details) {
              _heartKey.currentState?.trigger(details.localPosition);
              _lastDoubleTapPosition = details.localPosition;
              _consecutiveLikes++;
              _likeCountAnimKey++;
              setState(() {});
              final cubit = context.read<VideoFeedCubit>();
              if (!cubit.state.isVideoLiked(widget.videoItem.id)) {
                _toggleLike();
              }
            }
          : null,
      onDoubleTap: _isReady ? () {} : null,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          VideoFeedViewOptimizedVideoPlayer(
            controller: widget.controller,
            videoId: widget.videoItem.id,
          ),
          if (_isReady) ...[
            // Overlay section — entry animation runs once, not on like changes
            _VideoFeedOverlayWrapper(
              videoItem: widget.videoItem,
              onLikeTap: _toggleLike,
              onCommentTap: () => showDevSnackbar(context, 'Comments'),
              onShareTap: () => showDevSnackbar(context, 'Share'),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoFeedViewProgressScrubber(
                controller: widget.controller,
                externalScrub: _scrubNotifier,
              ),
            ),
            VideoFeedViewRetentionPaywall(controller: widget.controller),
            VideoFeedViewHeartAnimation(key: _heartKey),
            if (_consecutiveLikes > 0)
              VideoFeedViewLikeCountAnimation(
                key: ValueKey(_likeCountAnimKey),
                count: _consecutiveLikes,
                origin: _lastDoubleTapPosition,
              ),
            VideoFeedViewMuteIndicator(key: _muteKey),

            // Hold-to-pause dim overlay — ValueListenableBuilder avoids full rebuild
            ValueListenableBuilder<bool>(
              valueListenable: _holdingNotifier,
              builder: (_, holding, __) => holding
                  ? Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: black.withValues(alpha: 0.15),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],

          // Volume bar — ValueListenableBuilder so only this rebuilds on drag
          Positioned(
            right: context.w(16),
            top: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _volumeFadeAnim,
              child: Center(
                child: ValueListenableBuilder<double>(
                  valueListenable: _volumeNotifier,
                  builder: (_, vol, __) =>
                      VideoFeedViewVolumeBar(volume: vol),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps [VideoFeedViewOverlaySection] so the entry animation widget
/// is stable across like-state changes. [BlocSelector] is scoped
/// tightly — only [VideoFeedViewInteractionButtons] rebuilds on toggle.
class _VideoFeedOverlayWrapper extends StatelessWidget {
  const _VideoFeedOverlayWrapper({
    required this.videoItem,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
  });

  final VideoEntity videoItem;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<VideoFeedCubit, VideoFeedState, bool>(
      selector: (state) => state.isVideoLiked(videoItem.id),
      builder: (context, isLiked) {
        return VideoFeedViewOverlaySection(
          profileImageUrl: videoItem.profileImageUrl,
          username: videoItem.username,
          description: videoItem.description,
          isLiked: isLiked,
          onLikeTap: onLikeTap,
          onCommentTap: onCommentTap,
          onShareTap: onShareTap,
        );
      },
    );
  }
}
