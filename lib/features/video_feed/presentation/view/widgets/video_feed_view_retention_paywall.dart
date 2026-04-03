import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:video_player/video_player.dart';

/// Retention paywall that triggers at the 10-second mark.
/// Pauses the video, blurs the background, and slides up
/// a card with a shimmering CTA button.
class VideoFeedViewRetentionPaywall extends StatefulWidget {
  const VideoFeedViewRetentionPaywall({
    required this.controller,
    super.key,
  });
  final VideoPlayerController? controller;

  @override
  State<VideoFeedViewRetentionPaywall> createState() =>
      _VideoFeedViewRetentionPaywallState();
}

class _VideoFeedViewRetentionPaywallState
    extends State<VideoFeedViewRetentionPaywall>
    with TickerProviderStateMixin {
  static const _triggerSecond = 10;

  bool _triggered = false;
  bool _dismissed = false;
  late AnimationController _entryController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _blurAnimation = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOut,
      ),
    );
    widget.controller?.addListener(_onTick);
  }

  @override
  void didUpdateWidget(
    VideoFeedViewRetentionPaywall oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTick);
      _triggered = false;
      _dismissed = false;
      if (_entryController.isCompleted ||
          _entryController.isAnimating) {
        _entryController.reset();
      }
      widget.controller?.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTick);
    _entryController.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_triggered || _dismissed || !mounted) return;
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (ctrl.value.position.inSeconds >= _triggerSecond) {
      _triggered = true;
      ctrl.pause();
      _entryController.forward();
      if (mounted) setState(() {});
    }
  }

  void _dismiss() {
    _entryController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _dismissed = true;
          _triggered = false;
        });
        widget.controller?.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_triggered || _dismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        final blur = _blurAnimation.value;
        // Card slide: map 0→1 to 1→-0.08 (overshoot)
        // then settle at 0. Using a custom curve.
        final slideT = _cardSlideCurve(
          _entryController.value,
        );
        return Stack(
          children: [
            // Blur + scrim
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blur,
                  sigmaY: blur,
                ),
                child: ColoredBox(
                  color: black.withValues(
                    alpha:
                        0.4 * _entryController.value,
                  ),
                ),
              ),
            ),
            // Dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            // Card sliding up from bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FractionalTranslation(
                translation: Offset(0, slideT),
                child: _PaywallCard(
                  onUnlock: _dismiss,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Custom slide curve: card starts fully off-screen
  /// (translateY = 1.0), slides up past its resting
  /// position (overshoots to -0.06), then bounces back
  /// to 0.
  double _cardSlideCurve(double t) {
    if (t <= 0) return 1;
    if (t >= 1) return 0;
    // Phase 1 (0→0.55): slide from 1.0 to -0.06
    // Phase 2 (0.55→0.75): bounce back to 0.03
    // Phase 3 (0.75→1.0): settle to 0
    if (t < 0.55) {
      final p = t / 0.55;
      final eased = Curves.easeOut.transform(p);
      return 1.0 - 1.06 * eased;
    } else if (t < 0.75) {
      final p = (t - 0.55) / 0.2;
      final eased = Curves.easeInOut.transform(p);
      return -0.06 + 0.09 * eased;
    } else {
      final p = (t - 0.75) / 0.25;
      final eased = Curves.easeOut.transform(p);
      return 0.03 - 0.03 * eased;
    }
  }
}

class _PaywallCard extends StatelessWidget {
  const _PaywallCard({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: context.w(16),
        right: context.w(16),
        bottom: context.h(40),
      ),
      padding: context.paddingAll(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E2E),
            Color(0xFF2A1A3E),
          ],
        ),
        borderRadius: context.radiusAll(20),
        border: Border.all(
          color: white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.5),
            blurRadius: context.h(30),
            offset: Offset(0, context.h(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: context.paddingAll(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: white.withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: white,
              size: context.sq(32),
            ),
          ),
          context.hSpace(16),
          Text(
            'Premium Content',
            style: TextStyle(
              color: white,
              fontSize: context.fontSize(22),
              fontWeight: FontWeight.w700,
            ),
          ),
          context.hSpace(8),
          Text(
            'Unlock this episode to keep watching',
            style: TextStyle(
              color: white.withValues(alpha: 0.6),
              fontSize: context.fontSize(14),
            ),
          ),
          context.hSpace(24),
          _ShimmerCtaButton(onTap: onUnlock),
          context.hSpace(12),
          GestureDetector(
            onTap: onUnlock,
            child: Text(
              'Maybe later',
              style: TextStyle(
                color: white.withValues(alpha: 0.4),
                fontSize: context.fontSize(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCtaButton extends StatefulWidget {
  const _ShimmerCtaButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ShimmerCtaButton> createState() =>
      _ShimmerCtaButtonState();
}

class _ShimmerCtaButtonState
    extends State<_ShimmerCtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, _) {
          return CustomPaint(
            painter: _ShimmerButtonPainter(
              progress: _shimmerController.value,
              borderRadius: context.h(14),
            ),
            child: Container(
              width: double.infinity,
              padding: context.paddingVertical(14),
              alignment: Alignment.center,
              child: Text(
                'Unlock Episode',
                style: TextStyle(
                  color: white,
                  fontSize: context.fontSize(16),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws the gradient button
/// background and a white shimmer band sweeping
/// across it every cycle.
class _ShimmerButtonPainter extends CustomPainter {
  _ShimmerButtonPainter({
    required this.progress,
    required this.borderRadius,
  });
  final double progress;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    // Base gradient
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF006E),
          Color(0xFFFB5607),
        ],
      ).createShader(Offset.zero & size);
    canvas
      ..drawRRect(rrect, basePaint)
      // Shimmer band — sweeps left to right
      ..save()
      ..clipRRect(rrect);
    final bandWidth = size.width * 0.35;
    // Extend range so band fully enters and exits
    final totalTravel = size.width + bandWidth;
    final bandCenter =
        -bandWidth / 2 + totalTravel * progress;
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0x00FFFFFF),
          Color(0x55FFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(
        Rect.fromCenter(
          center: Offset(bandCenter, size.height / 2),
          width: bandWidth,
          height: size.height,
        ),
      );
    canvas
      ..drawRect(Offset.zero & size, shimmerPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(_ShimmerButtonPainter old) =>
      old.progress != progress;
}
