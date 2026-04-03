import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:video_player/video_player.dart';

class VideoFeedViewProgressScrubber extends StatefulWidget {
  const VideoFeedViewProgressScrubber({
    required this.controller,
    super.key,
  });
  final VideoPlayerController? controller;

  @override
  State<VideoFeedViewProgressScrubber> createState() =>
      VideoFeedViewProgressScrubberState();
}

class VideoFeedViewProgressScrubberState
    extends State<VideoFeedViewProgressScrubber>
    with SingleTickerProviderStateMixin {
  bool _isScrubbing = false;
  double _scrubProgress = 0;
  double _scrubX = 0;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  void externalSeekStart(double progress) {
    final ctrl = widget.controller;
    if (ctrl == null ||
        !ctrl.value.isInitialized ||
        ctrl.value.duration.inMilliseconds == 0) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    setState(() {
      _isScrubbing = true;
      _scrubProgress = progress.clamp(0.0, 1.0);
      _scrubX = _scrubProgress * box.size.width;
    });
    _expandController.forward();
    ctrl.pause();
  }

  void externalSeekUpdate(double progress) {
    if (!_isScrubbing) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    setState(() {
      _scrubProgress = progress.clamp(0.0, 1.0);
      _scrubX = _scrubProgress * box.size.width;
    });
    final ctrl = widget.controller;
    if (ctrl != null && ctrl.value.isInitialized) {
      final ms = (_scrubProgress * ctrl.value.duration.inMilliseconds).round();
      ctrl.seekTo(Duration(milliseconds: ms));
    }
  }

  void externalSeekEnd({required bool resume}) {
    if (!_isScrubbing) return;
    final ctrl = widget.controller;
    if (ctrl != null && ctrl.value.isInitialized) {
      final ms = (_scrubProgress * ctrl.value.duration.inMilliseconds).round();
      ctrl.seekTo(Duration(milliseconds: ms));
      if (resume) ctrl.play();
    }
    _expandController.reverse();
    setState(() => _isScrubbing = false);
  }

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: AppDurations.progressScrubber,
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeOut,
      ),
    );
    widget.controller?.addListener(_onVideoTick);
  }

  @override
  void didUpdateWidget(VideoFeedViewProgressScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      try {
        oldWidget.controller?.removeListener(_onVideoTick);
      } catch (_) {}
      widget.controller?.addListener(_onVideoTick);
    }
  }

  @override
  void dispose() {
    try {
      widget.controller?.removeListener(_onVideoTick);
    } catch (_) {}
    _expandController.dispose();
    super.dispose();
  }

  void _onVideoTick() {
    if (!_isScrubbing && mounted) {
      setState(() {});
    }
  }

  double get _currentProgress {
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return 0;
    final duration = ctrl.value.duration.inMilliseconds;
    if (duration == 0) return 0;
    return ctrl.value.position.inMilliseconds / duration;
  }

  Duration get _currentPosition {
    if (_isScrubbing) {
      final ctrl = widget.controller;
      if (ctrl == null || !ctrl.value.isInitialized) {
        return Duration.zero;
      }
      final ms = (_scrubProgress * ctrl.value.duration.inMilliseconds).round();
      return Duration(milliseconds: ms);
    }
    return widget.controller?.value.position ?? Duration.zero;
  }

  Duration get _totalDuration {
    return widget.controller?.value.duration ?? Duration.zero;
  }

  void _onHorizontalDragStart(DragStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null ||
        !ctrl.value.isInitialized ||
        ctrl.value.duration.inMilliseconds == 0) {
      return;
    }
    setState(() {
      _isScrubbing = true;
      _scrubX = d.localPosition.dx;
    });
    _expandController.forward();
    ctrl.pause();
    _updateScrubProgress(d.localPosition.dx);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    if (!_isScrubbing) return;
    setState(() => _scrubX = d.localPosition.dx);
    _updateScrubProgress(d.localPosition.dx);
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    if (!_isScrubbing) return;
    final ctrl = widget.controller;
    if (ctrl != null && ctrl.value.isInitialized) {
      final ms = (_scrubProgress * ctrl.value.duration.inMilliseconds).round();
      ctrl
        ..seekTo(Duration(milliseconds: ms))
        ..play();
    }
    _expandController.reverse();
    setState(() => _isScrubbing = false);
  }

  void _updateScrubProgress(double localX) {
    final box = context.findRenderObject()! as RenderBox;
    final width = box.size.width;
    setState(() {
      _scrubProgress = (localX / width).clamp(0, 1);
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _isScrubbing ? _scrubProgress : _currentProgress;

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final expandT = _expandAnimation.value;
          final barHeight = context.h(AppSizes.progressBarHeight) +
              context.h(AppSizes.progressBarExpandedHeight - AppSizes.progressBarHeight) * expandT;

          return SizedBox(
            height: context.h(AppSizes.progressBarTouchHeight),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                if (_isScrubbing)
                  Positioned(
                    bottom: context.h(20),
                    left: _scrubX - context.w(40),
                    child: _TimePreview(
                      current: _formatDuration(_currentPosition),
                      total: _formatDuration(_totalDuration),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: barHeight,
                  child: CustomPaint(
                    painter: _ProgressBarPainter(
                      progress: progress,
                      expandFactor: expandT,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimePreview extends StatelessWidget {
  const _TimePreview({
    required this.current,
    required this.total,
  });
  final String current;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(8),
        vertical: context.h(4),
      ),
      decoration: BoxDecoration(
        color: black.withValues(alpha: 0.7),
        borderRadius: context.radiusAll(6),
      ),
      child: AppText(
        '$current / $total',
        style: AppTextStyle.labelMedium,
        color: white,
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    required this.progress,
    required this.expandFactor,
  });
  final double progress;
  final double expandFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = white.withValues(alpha: 0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.height / 2),
      ),
      bgPaint,
    );

    if (progress > 0) {
      final filledWidth = size.width * progress;
      final gradient = progressBarGradient.createShader(
        Rect.fromLTWH(0, 0, filledWidth, size.height),
      );
      final fillPaint = Paint()..shader = gradient;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, filledWidth, size.height),
          Radius.circular(size.height / 2),
        ),
        fillPaint,
      );
    }

    if (expandFactor > 0 && progress > 0) {
      final handleRadius = (size.height * 1.5) * expandFactor;
      final handleX = size.width * progress;
      final handlePaint = Paint()..color = white;
      canvas.drawCircle(
        Offset(handleX, size.height / 2),
        handleRadius,
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter old) =>
      old.progress != progress || old.expandFactor != expandFactor;
}
