import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_progress_scrubber.dart';
import 'package:video_player/video_player.dart';

enum _DragMode { undecided, volume, seek }

class VideoFeedViewVolumeGesture extends StatefulWidget {
  const VideoFeedViewVolumeGesture({
    required this.controller,
    required this.child,
    required this.scrubberKey,
    super.key,
  });

  static double globalVolume = 1;

  final VideoPlayerController? controller;
  final Widget child;
  final GlobalKey<VideoFeedViewProgressScrubberState> scrubberKey;

  @override
  State<VideoFeedViewVolumeGesture> createState() =>
      _VideoFeedViewVolumeGestureState();
}

class _VideoFeedViewVolumeGestureState
    extends State<VideoFeedViewVolumeGesture>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  _DragMode _dragMode = _DragMode.undecided;
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _startVolume = 1;
  double _seekStartProgress = 0;
  bool _wasPaused = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _directionThreshold = 12.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.volumeFade,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _applyGlobalVolume();
  }

  @override
  void didUpdateWidget(VideoFeedViewVolumeGesture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _applyGlobalVolume();
    }
  }

  void _applyGlobalVolume() {
    final c = widget.controller;
    if (c != null && c.value.isInitialized) {
      c.setVolume(VideoFeedViewVolumeGesture.globalVolume);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  double get _currentProgress {
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return 0;
    final duration = ctrl.value.duration.inMilliseconds;
    if (duration == 0) return 0;
    return ctrl.value.position.inMilliseconds / duration;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (widget.controller == null) return;
    _isDragging = true;
    _dragMode = _DragMode.undecided;
    _dragStartX = details.localPosition.dx;
    _dragStartY = details.localPosition.dy;
    _startVolume = VideoFeedViewVolumeGesture.globalVolume;
    _wasPaused = !widget.controller!.value.isPlaying;
    _seekStartProgress = _currentProgress;
    setState(() {});
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isDragging || widget.controller == null) return;
    final dx = (details.localPosition.dx - _dragStartX).abs();
    final dy = (details.localPosition.dy - _dragStartY).abs();

    if (_dragMode == _DragMode.undecided) {
      if (dx > _directionThreshold || dy > _directionThreshold) {
        _dragMode = dx > dy ? _DragMode.seek : _DragMode.volume;
        if (_dragMode == _DragMode.volume) {
          _fadeController.forward();
        } else {
          widget.scrubberKey.currentState
              ?.externalSeekStart(_seekStartProgress);
        }
      }
      return;
    }

    if (_dragMode == _DragMode.volume) {
      _handleVolumeDrag(details.localPosition.dy);
    } else {
      _handleSeekDrag(details.localPosition.dx);
    }
  }

  void _handleVolumeDrag(double currentY) {
    final dy = _dragStartY - currentY;
    final sensitivity = context.screenHeight * 0.5;
    final newVolume = (_startVolume + dy / sensitivity).clamp(0.0, 1.0);
    VideoFeedViewVolumeGesture.globalVolume = newVolume;
    widget.controller!.setVolume(newVolume);
    setState(() {});
  }

  void _handleSeekDrag(double currentX) {
    final ctrl = widget.controller!;
    if (!ctrl.value.isInitialized || ctrl.value.duration.inMilliseconds == 0) {
      return;
    }
    final screenW = context.screenWidth;
    final dxFromStart = currentX - _dragStartX;
    final seekDelta = dxFromStart / screenW;
    final progress = (_seekStartProgress + seekDelta).clamp(0.0, 1.0);
    widget.scrubberKey.currentState?.externalSeekUpdate(progress);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_dragMode == _DragMode.volume) {
      _fadeController.reverse();
    } else if (_dragMode == _DragMode.seek) {
      widget.scrubberKey.currentState
          ?.externalSeekEnd(resume: !_wasPaused);
    }
    _isDragging = false;
    _dragMode = _DragMode.undecided;
    setState(() {});
  }

  IconData get _volumeIcon {
    final v = VideoFeedViewVolumeGesture.globalVolume;
    if (v <= 0) return Icons.volume_off_rounded;
    if (v < 0.5) return Icons.volume_down_rounded;
    return Icons.volume_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            right: context.w(16),
            top: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: _VolumeBar(
                  volume: VideoFeedViewVolumeGesture.globalVolume,
                  icon: _volumeIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({required this.volume, required this.icon});

  final double volume;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final barHeight = context.h(AppSizes.volumeBarHeight);
    return Container(
      width: context.w(AppSizes.volumeBarWidth),
      padding: context.paddingVertical(10),
      decoration: BoxDecoration(
        color: black.withValues(alpha: 0.55),
        borderRadius: context.radiusAll(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white, size: context.sq(20)),
          SizedBox(height: context.h(8)),
          SizedBox(
            height: barHeight,
            width: context.w(AppSizes.volumeBarTrackWidth),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.24),
                    borderRadius: context.radiusAll(2),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: volume,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: context.radiusAll(2),
                      gradient: volumeBarGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(8)),
          AppText(
            '${(volume * 100).round()}',
            style: AppTextStyle.labelSmall,
            color: white,
          ),
        ],
      ),
    );
  }
}
