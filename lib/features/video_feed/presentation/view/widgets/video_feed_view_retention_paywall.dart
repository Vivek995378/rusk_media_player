import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:video_player/video_player.dart';

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
  bool _triggered = false;
  bool _dismissed = false;
  late AnimationController _entryController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: AppDurations.paywallEntry,
    );
    _blurAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    widget.controller?.addListener(_onTick);
  }

  @override
  void didUpdateWidget(VideoFeedViewRetentionPaywall oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTick);
      _triggered = false;
      _dismissed = false;
      if (_entryController.isCompleted || _entryController.isAnimating) {
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
    if (ctrl.value.position.inSeconds >= AppSizes.paywallTriggerSeconds) {
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

  double _cardSlideCurve(double t) {
    if (t <= 0) return 1;
    if (t >= 1) return 0;
    if (t < 0.55) {
      final p = t / 0.55;
      return 1.0 - 1.06 * Curves.easeOut.transform(p);
    } else if (t < 0.75) {
      final p = (t - 0.55) / 0.2;
      return -0.06 + 0.09 * Curves.easeInOut.transform(p);
    } else {
      final p = (t - 0.75) / 0.25;
      return 0.03 - 0.03 * Curves.easeOut.transform(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_triggered || _dismissed) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        final blur = _blurAnimation.value;
        final slideT = _cardSlideCurve(_entryController.value);
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: ColoredBox(
                  color: black.withValues(alpha: 0.4 * _entryController.value),
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FractionalTranslation(
                translation: Offset(0, slideT),
                child: _PaywallCard(onUnlock: _dismiss),
              ),
            ),
          ],
        );
      },
    );
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
        left: context.w(AppSizes.paywallCardMargin),
        right: context.w(AppSizes.paywallCardMargin),
        bottom: context.h(AppSizes.paywallBottomMargin),
      ),
      padding: context.paddingAll(AppSizes.paywallCardPadding),
      decoration: BoxDecoration(
        gradient: paywallCardGradient,
        borderRadius: context.radiusAll(AppSizes.paywallCardRadius),
        border: Border.all(
          color: paywallPurple.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: paywallViolet.withValues(alpha: 0.15),
            blurRadius: context.h(40),
            offset: Offset(0, context.h(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: context.paddingAll(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: paywallViolet.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: paywallFuchsia,
              size: context.sq(28),
            ),
          ),
          context.hSpace(20),
          AppText(
            AppStrings.paywallTitle,
            style: AppTextStyle.headlineSmall,
          ),
          context.hSpace(10),
          AppText(
            AppStrings.paywallDescription,
            style: AppTextStyle.bodySmall,
            textAlign: TextAlign.center,
            color: white.withValues(alpha: 0.5),
            height: 1.5,
          ),
          context.hSpace(22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText(
                AppStrings.paywallPrice,
                style: AppTextStyle.headlineLarge,
                color: paywallGold,
                fontWeight: FontWeight.w800,
              ),
              SizedBox(width: context.w(6)),
              AppText(
                AppStrings.paywallPriceUnit,
                style: AppTextStyle.bodyMedium,
                color: white.withValues(alpha: 0.4),
              ),
            ],
          ),
          context.hSpace(24),
          _ShimmerCtaButton(onTap: onUnlock),
          context.hSpace(14),
          AppText(
            AppStrings.paywallFooter,
            style: AppTextStyle.bodySmall,
            color: white.withValues(alpha: 0.35),
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
  State<_ShimmerCtaButton> createState() => _ShimmerCtaButtonState();
}

class _ShimmerCtaButtonState extends State<_ShimmerCtaButton>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppDurations.paywallShimmer,
    )..repeat();
    _borderController = AnimationController(
      vsync: this,
      duration: AppDurations.paywallBorder,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_shimmerController, _borderController]),
        builder: (context, _) {
          return CustomPaint(
            painter: _ButtonPainter(
              shimmerProgress: _shimmerController.value,
              borderProgress: _borderController.value,
              borderRadius: context.sq(14),
            ),
            child: Container(
              width: double.infinity,
              padding: context.paddingVertical(16),
              alignment: Alignment.center,
              child: AppText(
                AppStrings.paywallCta,
                style: AppTextStyle.titleMedium,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ButtonPainter extends CustomPainter {
  _ButtonPainter({
    required this.shimmerProgress,
    required this.borderProgress,
    required this.borderRadius,
  });

  final double shimmerProgress;
  final double borderProgress;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final basePaint = Paint()
      ..shader = paywallButtonGradient.createShader(Offset.zero & size);
    canvas
      ..drawRRect(rrect, basePaint)
      ..save()
      ..clipRRect(rrect);

    final bandWidth = size.width * 0.45;
    final totalTravel = size.width + bandWidth;
    final bandCenter = -bandWidth / 2 + totalTravel * shimmerProgress;
    final shimmerRect = Rect.fromCenter(
      center: Offset(bandCenter, size.height / 2),
      width: bandWidth,
      height: size.height,
    );
    final mainShimmer = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x00FFFFFF),
          Color(0x18FFFFFF),
          Color(0x66FFFFFF),
          Color(0x18FFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: [0, 0.25, 0.5, 0.75, 1],
      ).createShader(shimmerRect);
    canvas.drawRect(Offset.zero & size, mainShimmer);

    final trailProgress = (shimmerProgress - 0.15).clamp(0.0, 1.0) / 0.85;
    if (trailProgress > 0) {
      final trailCenter = -bandWidth / 2 + totalTravel * trailProgress;
      final trailRect = Rect.fromCenter(
        center: Offset(trailCenter, size.height / 2),
        width: bandWidth * 0.6,
        height: size.height,
      );
      final trailShimmer = Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x00D946EF),
            Color(0x33D946EF),
            Color(0x00D946EF),
          ],
        ).createShader(trailRect);
      canvas.drawRect(Offset.zero & size, trailShimmer);
    }

    canvas.restore();
    _drawProgressBorder(canvas, size);
  }

  void _drawProgressBorder(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;

    final glowLength = totalLength * 0.3;
    final segStart = totalLength * borderProgress;
    final segEnd = segStart + glowLength;

    final extractedPath = Path();
    if (segEnd <= totalLength) {
      extractedPath.addPath(
        metrics.extractPath(segStart, segEnd),
        Offset.zero,
      );
    } else {
      extractedPath
        ..addPath(metrics.extractPath(segStart, totalLength), Offset.zero)
        ..addPath(metrics.extractPath(0, segEnd - totalLength), Offset.zero);
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..shader = const LinearGradient(
        colors: [
          Color(0x00D946EF),
          Color(0xFFD946EF),
          Color(0xFFFFD600),
          Color(0xFFD946EF),
          Color(0x00D946EF),
        ],
        stops: [0, 0.2, 0.5, 0.8, 1],
      ).createShader(rect);
    canvas.drawPath(extractedPath, glowPaint);

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const LinearGradient(
        colors: [
          Color(0x00FFFFFF),
          Color(0xCCFFFFFF),
          Color(0xFFFFD600),
          Color(0xCCFFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: [0, 0.2, 0.5, 0.8, 1],
      ).createShader(rect);
    canvas.drawPath(extractedPath, corePaint);
  }

  @override
  bool shouldRepaint(_ButtonPainter old) =>
      old.shimmerProgress != shimmerProgress ||
      old.borderProgress != borderProgress;
}
