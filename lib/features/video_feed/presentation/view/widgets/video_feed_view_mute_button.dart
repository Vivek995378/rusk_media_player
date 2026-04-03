import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/features/video_feed/presentation/view/widgets/video_feed_view_volume_gesture.dart';
import 'package:video_player/video_player.dart';

class VideoFeedViewMuteButton extends StatefulWidget {
  const VideoFeedViewMuteButton({required this.controller, super.key});

  final VideoPlayerController? controller;

  @override
  State<VideoFeedViewMuteButton> createState() =>
      _VideoFeedViewMuteButtonState();
}

class _VideoFeedViewMuteButtonState extends State<VideoFeedViewMuteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  double _volumeBeforeMute = 0.8;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppDurations.buttonScale,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_scaleController);
    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(VideoFeedViewMuteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerUpdate);
      widget.controller?.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    _scaleController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  bool get _isMuted => VideoFeedViewVolumeGesture.globalVolume <= 0;

  void _toggleMute() {
    _scaleController.forward(from: 0);
    if (_isMuted) {
      final restored = _volumeBeforeMute > 0 ? _volumeBeforeMute : 0.8;
      VideoFeedViewVolumeGesture.globalVolume = restored;
      widget.controller?.setVolume(restored);
    } else {
      _volumeBeforeMute = VideoFeedViewVolumeGesture.globalVolume;
      VideoFeedViewVolumeGesture.globalVolume = 0;
      widget.controller?.setVolume(0);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: context.h(48),
      right: context.w(16),
      child: GestureDetector(
        onTap: _toggleMute,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: context.sq(36),
            height: context.sq(36),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: black.withValues(alpha: 0.45),
            ),
            child: Icon(
              _isMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              color: white,
              size: context.sq(18),
            ),
          ),
        ),
      ),
    );
  }
}
