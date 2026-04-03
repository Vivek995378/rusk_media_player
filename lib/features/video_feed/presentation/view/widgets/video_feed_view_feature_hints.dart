import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';
import 'package:rusk_media_player/core/utils/helpers/local_storage.dart';

class VideoFeedViewFeatureHints extends StatefulWidget {
  const VideoFeedViewFeatureHints({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  static bool get hasShown => LocalStorage.featureHintsShown;

  static Future<void> markShown() => LocalStorage.setFeatureHintsShown();

  @override
  State<VideoFeedViewFeatureHints> createState() =>
      _VideoFeedViewFeatureHintsState();
}

class _VideoFeedViewFeatureHintsState extends State<VideoFeedViewFeatureHints>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _hint1Controller;
  late AnimationController _hint2Controller;
  late AnimationController _hint3Controller;
  late AnimationController _hint4Controller;
  late AnimationController _hint5Controller;
  late AnimationController _dismissController;
  late AnimationController _tapPulseController;
  late AnimationController _dragLoopController;
  late AnimationController _doubleTapController;
  late AnimationController _swipeLoopController;
  late AnimationController _seekLoopController;
  late AnimationController _ctaController;
  late AnimationController _ctaPulseController;
  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hint1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hint2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hint3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hint4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _hint5Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _tapPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _dragLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _swipeLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _seekLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ctaPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _runSequence();
  }

  Future<void> _runSequence() async {
    await _entryController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _hint1Controller.forward();
    unawaited(_tapPulseController.repeat(reverse: true));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _hint2Controller.forward();
    unawaited(_doubleTapController.repeat(reverse: true));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _hint3Controller.forward();
    unawaited(_dragLoopController.repeat());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _hint4Controller.forward();
    unawaited(_swipeLoopController.repeat());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _hint5Controller.forward();
    unawaited(_seekLoopController.repeat());
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _ctaController.forward();
    unawaited(_ctaPulseController.repeat(reverse: true));
    if (mounted) setState(() => _canDismiss = true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _hint1Controller.dispose();
    _hint2Controller.dispose();
    _hint3Controller.dispose();
    _hint4Controller.dispose();
    _hint5Controller.dispose();
    _dismissController.dispose();
    _tapPulseController.dispose();
    _dragLoopController.dispose();
    _doubleTapController.dispose();
    _swipeLoopController.dispose();
    _seekLoopController.dispose();
    _ctaController.dispose();
    _ctaPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _dismissController]),
      builder: (context, _) {
        final entryOpacity = _entryController.value;
        final dismissOpacity = 1.0 - _dismissController.value;
        final opacity = (entryOpacity * dismissOpacity).clamp(0.0, 1.0);
        if (opacity <= 0) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            if (_canDismiss && !_dismissController.isAnimating) {
              _dismissController.forward().then((_) {
                if (mounted) widget.onDismiss();
              });
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: opacity,
            child: ColoredBox(
              color: black.withValues(alpha: 0.65),
              child: SizedBox.expand(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.w(320)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _HintRow(
                          animation: _hint1Controller,
                          icon: _TapIcon(controller: _tapPulseController),
                          label: 'Tap to play / pause',
                        ),
                        context.hSpace(16),
                        _HintRow(
                          animation: _hint2Controller,
                          icon: _DoubleTapIcon(controller: _doubleTapController),
                          label: 'Double tap to like',
                        ),
                        context.hSpace(16),
                        _HintRow(
                          animation: _hint3Controller,
                          icon: _DragIcon(controller: _dragLoopController),
                          label: 'Hold & drag for volume',
                        ),
                        context.hSpace(16),
                        _HintRow(
                          animation: _hint4Controller,
                          icon: _SwipeIcon(controller: _swipeLoopController),
                          label: 'Swipe up / down for videos',
                        ),
                        context.hSpace(16),
                        _HintRow(
                          animation: _hint5Controller,
                          icon: _SeekIcon(controller: _seekLoopController),
                          label: 'Hold & drag sideways to seek',
                        ),
                        context.hSpace(32),
                        _ExperienceCta(
                          entryController: _ctaController,
                          pulseController: _ctaPulseController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({
    required this.animation,
    required this.icon,
    required this.label,
  });

  final AnimationController animation;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ).value;

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, context.h(20) * (1 - t)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.w(14),
                vertical: context.h(12),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: context.radiusAll(14),
                border: Border.all(
                  color: white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  /// FIXED ICON CONTAINER
                  Container(
                    width: context.sq(42),
                    height: context.sq(42),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: white.withValues(alpha: 0.06),
                    ),
                    child: icon,
                  ),

                  context.wSpace(14),

                  /// TEXT
                  Expanded(
                    child: AppText(
                      label,
                      style: AppTextStyle.titleMedium,
                      color: white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TapIcon extends StatelessWidget {
  const _TapIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final scale = 1.0 + controller.value * 0.25;
        final glowOpacity = 0.2 + controller.value * 0.3;
        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: context.sq(42),
              height: context.sq(42),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MESupportiveColors.supportive600.withValues(
                  alpha: 0.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MESupportiveColors.supportive500.withValues(
                      alpha: glowOpacity,
                    ),
                    blurRadius: context.sq(16),
                  ),
                ],
              ),
              child: Icon(
                Icons.touch_app_rounded,
                color: white,
                size: context.sq(22),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DoubleTapIcon extends StatelessWidget {
  const _DoubleTapIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final bounce = sin(controller.value * pi * 2) * 0.15;
        return Center(
          child: Transform.scale(
            scale: 1.0 + bounce,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: MEErrorColors.error400.withValues(
                    alpha: 0.3 + controller.value * 0.4,
                  ),
                  size: context.sq(38),
                ),
                Icon(
                  Icons.favorite_rounded,
                  color: MEErrorColors.error500,
                  size: context.sq(24),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DragIcon extends StatelessWidget {
  const _DragIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final dy = sin(t * pi * 2) * context.h(4);
        return Center(
          child: SizedBox(
            width: context.sq(48),
            height: context.sq(48),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: MESuccessColors.success400.withValues(
                      alpha: 0.5 + (1 - t) * 0.5,
                    ),
                    size: context.sq(14),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, dy),
                  child: Icon(
                    Icons.pan_tool_rounded,
                    color: white,
                    size: context.sq(16),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: MESuccessColors.success400.withValues(
                      alpha: 0.5 + t * 0.5,
                    ),
                    size: context.sq(14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SwipeIcon extends StatelessWidget {
  const _SwipeIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final dy = sin(t * pi * 2) * context.h(6);
        final isUp = t < 0.5;
        final arrowUpOpacity = isUp ? 0.4 + (0.5 - t) * 1.2 : 0.4;
        final arrowDownOpacity = isUp ? 0.4 : 0.4 + (t - 0.5) * 1.2;
        return Center(
          child: SizedBox(
            width: context.sq(48),
            height: context.sq(48),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Opacity(
                    opacity: arrowUpOpacity.clamp(0.0, 1.0),
                    child: Icon(
                      Icons.swipe_up_rounded,
                      color: MEWarningColors.warning400,
                      size: context.sq(14),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, dy),
                  child: Container(
                    width: context.sq(20),
                    height: context.sq(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: white.withValues(alpha: 0.6),
                        width: context.sq(1.5),
                      ),
                    ),
                    child: Icon(
                      Icons.swipe_vertical_rounded,
                      color: white,
                      size: context.sq(12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: arrowDownOpacity.clamp(0.0, 1.0),
                    child: Icon(
                      Icons.swipe_down_rounded,
                      color: MEWarningColors.warning400,
                      size: context.sq(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeekIcon extends StatelessWidget {
  const _SeekIcon({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final dx = sin(t * pi * 2) * context.w(6);
        final isRight = t < 0.5;
        final arrowLeftOpacity = isRight ? 0.4 : 0.4 + (t - 0.5) * 1.2;
        final arrowRightOpacity = isRight ? 0.4 + (0.5 - t) * 1.2 : 0.4;
        return Center(
          child: SizedBox(
            width: context.sq(48),
            height: context.sq(48),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: Opacity(
                    opacity: arrowLeftOpacity.clamp(0.0, 1.0),
                    child: Icon(
                      Icons.fast_rewind_rounded,
                      color: MEBrandColors.primary400,
                      size: context.sq(14),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(dx, 0),
                  child: Icon(
                    Icons.pan_tool_rounded,
                    color: white,
                    size: context.sq(16),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Opacity(
                    opacity: arrowRightOpacity.clamp(0.0, 1.0),
                    child: Icon(
                      Icons.fast_forward_rounded,
                      color: MEBrandColors.primary400,
                      size: context.sq(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExperienceCta extends StatelessWidget {
  const _ExperienceCta({
    required this.entryController,
    required this.pulseController,
  });

  final AnimationController entryController;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entryController, pulseController]),
      builder: (context, _) {
        final entry = CurvedAnimation(
          parent: entryController,
          curve: Curves.easeOutBack,
        ).value;
        if (entry <= 0) return const SizedBox.shrink();
        final pulse = pulseController.value;
        final glowOpacity = 0.15 + pulse * 0.2;
        final scale = 1.0 + pulse * 0.03;
        return Opacity(
          opacity: entry.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, context.h(20) * (1 - entry)),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(20),
                  vertical: context.h(16),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      MESupportiveColors.supportive800,
                      MEBrandColors.primary700,
                    ],
                  ),
                  borderRadius: context.radiusAll(16),
                  boxShadow: [
                    BoxShadow(
                      color: MEBrandColors.primary500.withValues(
                        alpha: glowOpacity,
                      ),
                      blurRadius: context.sq(24),
                      spreadRadius: context.sq(2),
                    ),
                    BoxShadow(
                      color: MESupportiveColors.supportive500.withValues(
                        alpha: glowOpacity * 0.6,
                      ),
                      blurRadius: context.sq(40),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled_rounded,
                      color: white,
                      size: context.sq(28),
                    ),
                    SizedBox(width: context.w(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          'Tap to experience',
                          style: AppTextStyle.bodySmall,
                          color: white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                        AppText(
                          'RUSK MEDIA',
                          style: AppTextStyle.titleLarge,
                          color: white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                        ),
                      ],
                    ),
                    SizedBox(width: context.w(12)),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: white.withValues(alpha: 0.6 + pulse * 0.4),
                      size: context.sq(22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
