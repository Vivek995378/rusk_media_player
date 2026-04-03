import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class VideoFeedViewMuteIndicator extends StatefulWidget {
  const VideoFeedViewMuteIndicator({super.key});

  @override
  State<VideoFeedViewMuteIndicator> createState() =>
      VideoFeedViewMuteIndicatorState();
}

class VideoFeedViewMuteIndicatorState
    extends State<VideoFeedViewMuteIndicator>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _isMuted = false;
  bool _visible = false;

  void show({required bool isMuted}) {
    _isMuted = isMuted;
    _visible = true;
    _controller?.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
    ]).animate(_controller!);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween(0.9), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller!);
    setState(() {});
    _controller!.forward().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || _controller == null) return const SizedBox.shrink();
    return Center(
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, _) {
          return Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scale.value.clamp(0.0, 2.0),
              child: Container(
                width: context.sq(64),
                height: context.sq(64),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: black.withValues(alpha: 0.6),
                  boxShadow: [
                    BoxShadow(
                      color: black.withValues(alpha: 0.3),
                      blurRadius: context.sq(20),
                      spreadRadius: context.sq(2),
                    ),
                  ],
                ),
                child: Icon(
                  _isMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: white,
                  size: context.sq(32),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
