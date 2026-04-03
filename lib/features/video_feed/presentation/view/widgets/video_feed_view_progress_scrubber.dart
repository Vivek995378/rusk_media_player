import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:video_player/video_player.dart';

/// Notifier used to drive the scrubber from an external gesture (e.g. long-press drag).
/// [progress] is 0.0–1.0. [active] = true while scrubbing.
class ScrubNotifier extends ChangeNotifier {
  double _progress = 0;
  bool _active = false;

  double get progress => _progress;
  bool get active => _active;

  void begin(double progress) {
    _progress = progress.clamp(0.0, 1.0);
    _active = true;
    notifyListeners();
  }

  void update(double progress) {
    _progress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void end() {
    _active = false;
    notifyListeners();
  }
}

class VideoFeedViewProgressScrubber extends StatefulWidget {
  const VideoFeedViewProgressScrubber({
    required this.controller,
    this.externalScrub,
    super.key,
  });
  final VideoPlayerController? controller;

  /// Optional external scrub notifier — driven by long-press horizontal drag
  /// in the parent item widget.
  final ScrubNotifier? externalScrub;

  @override
  State<VideoFeedViewProgressScrubber> createState() =>
      _VideoFeedViewProgressScrubberState();
}

class _VideoFeedViewProgressScrubberState
    extends State<VideoFeedViewProgressScrubber>
    with SingleTickerProviderStateMixin {
  bool _isScrubbing = false;
  double _scrubProgress = 0;
  double _scrubX = 0;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOut),
    );
    widget.controller?.addListener(_onVideoTick);
    widget.externalScrub?.addListener(_onExternalScrub);
  }

  @override
  void didUpdateWidget(VideoFeedViewProgressScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onVideoTick);
      widget.controller?.addListener(_onVideoTick);
    }
    if (oldWidget.externalScrub != widget.externalScrub) {
      oldWidget.externalScrub?.removeListener(_onExternalScrub);
      widget.externalScrub?.addListener(_onExternalScrub);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onVideoTick);
    widget.externalScrub?.removeListener(_onExternalScrub);
    _expandController.dispose();
    super.dispose();
  }

  void _onVideoTick() {
    if (!_isScrubbing && mounted) setState(() {});
  }

  void _onExternalScrub() {
    final notifier = widget.externalScrub;
    if (notifier == null || !mounted) return;
    if (notifier.active) {
      // Convert progress to screen X for tooltip positioning
      final box = context.findRenderObject() as RenderBox?;
      final width = box?.size.width ?? context.screenWidth;
      setState(() {
        _isScrubbing = true;
        _scrubProgress = notifier.progress;
        _scrubX = notifier.progress * width;
      });
      if (!_expandController.isAnimating &&
          _expandController.value < 1) {
        _expandController.forward();
      }
    } else {
      // External scrub ended — seek and resume
      final ctrl = widget.controller;
      if (ctrl != null && ctrl.value.isInitialized) {
        final ms = (notifier.progress * ctrl.value.duration.inMilliseconds).round();
        ctrl.seekTo(Duration(milliseconds: ms)).then((_) => ctrl.play());
      }
      _expandController.reverse();
      setState(() => _isScrubbing = false);
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
      if (ctrl == null || !ctrl.value.isInitialized) return Duration.zero;
      final ms = (_scrubProgress * ctrl.value.duration.inMilliseconds).round();
      return Duration(milliseconds: ms);
    }
    return widget.controller?.value.position ?? Duration.zero;
  }

  Duration get _totalDuration =>
      widget.controller?.value.duration ?? Duration.zero;

  void _onHorizontalDragStart(DragStartDetails d) {
    final ctrl = widget.controller;
    if (ctrl == null ||
        !ctrl.value.isInitialized ||
        ctrl.value.duration.inMilliseconds == 0) return;
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
      ctrl.seekTo(Duration(milliseconds: ms)).then((_) => ctrl.play());
    }
    _expandController.reverse();
    setState(() => _isScrubbing = false);
  }

  void _updateScrubProgress(double localX) {
    final box = context.findRenderObject()! as RenderBox;
    final width = box.size.width;
    setState(() {
      _scrubProgress = (localX / width).clamp(0.0, 1.0);
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
        builder: (context, _) {
          final expandT = _expandAnimation.value;
          final barHeight = context.h(3) + context.h(5) * expandT;

          return SizedBox(
            height: context.h(48),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Time preview tooltip — follows finger
                if (_isScrubbing)
                  Positioned(
                    bottom: context.h(22),
                    left: (_scrubX - context.w(40)).clamp(0.0, double.infinity),
                    child: _TimePreview(
                      current: _formatDuration(_currentPosition),
                      total: _formatDuration(_totalDuration),
                    ),
                  ),
                // Progress bar
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
  const _TimePreview({required this.current, required this.total});
  final String current;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(10),
        vertical: context.h(5),
      ),
      decoration: BoxDecoration(
        color: black.withValues(alpha: 0.75),
        borderRadius: context.radiusAll(8),
        border: Border.all(
          color: white.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        '$current / $total',
        style: TextStyle(
          color: white,
          fontSize: context.fontSize(12),
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({required this.progress, required this.expandFactor});
  final double progress;
  final double expandFactor;

  @override
  void paint(Canvas canvas, Size size) {
    // Track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.height / 2),
      ),
      Paint()..color = white.withValues(alpha: 0.25),
    );

    // Filled gradient
    if (progress > 0) {
      final filledWidth = size.width * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, filledWidth, size.height),
          Radius.circular(size.height / 2),
        ),
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF006E), Color(0xFFFB5607)],
          ).createShader(Rect.fromLTWH(0, 0, filledWidth, size.height)),
      );
    }

    // Scrub handle
    if (expandFactor > 0 && progress > 0) {
      canvas.drawCircle(
        Offset(size.width * progress, size.height / 2),
        (size.height * 1.8) * expandFactor,
        Paint()..color = white,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter old) =>
      old.progress != progress || old.expandFactor != expandFactor;
}
