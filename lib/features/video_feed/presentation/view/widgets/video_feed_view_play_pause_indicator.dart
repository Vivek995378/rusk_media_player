import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

class VideoFeedViewPlayPauseIndicator extends StatefulWidget {
  const VideoFeedViewPlayPauseIndicator({super.key});

  @override
  State<VideoFeedViewPlayPauseIndicator> createState() =>
      VideoFeedViewPlayPauseIndicatorState();
}

class VideoFeedViewPlayPauseIndicatorState
    extends State<VideoFeedViewPlayPauseIndicator>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _isPlaying = true;
  bool _visible = false;

  void show({required bool isPlaying}) {
    _isPlaying = isPlaying;
    _visible = true;
    _controller?.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller!);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.9),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 0)
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
                width: context.sq(80),
                height: context.sq(80),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _isPlaying
                        ? [
                            const Color(0xFF00E676),
                            const Color(0xFF00C853),
                            const Color(0xFF009624),
                          ]
                        : [
                            accentPink,
                            const Color(0xFFFF4081),
                            const Color(0xFFD50000),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying
                              ? const Color(0xFF00E676)
                              : accentPink)
                          .withValues(alpha: 0.5),
                      blurRadius: context.sq(30),
                      spreadRadius: context.sq(5),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: white,
                  size: context.sq(44),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
