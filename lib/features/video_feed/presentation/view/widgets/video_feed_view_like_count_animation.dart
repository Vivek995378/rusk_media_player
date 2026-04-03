import 'package:flutter/material.dart';

/// Floating "+N" text that drifts upward ~30px and fades out after heart.
/// Duration: 600ms. Parent should give this a new Key on each like to restart.
class VideoFeedViewLikeCountAnimation extends StatefulWidget {
  final int count;
  final Offset origin;

  const VideoFeedViewLikeCountAnimation({
    super.key,
    required this.count,
    required this.origin,
  });

  @override
  State<VideoFeedViewLikeCountAnimation> createState() =>
      _VideoFeedViewLikeCountAnimationState();
}

class _VideoFeedViewLikeCountAnimationState
    extends State<VideoFeedViewLikeCountAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.origin.dx + 20,
      top: widget.origin.dy + 10,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Text(
            '+${widget.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(color: Color(0x88000000), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
