import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/app_text.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/constants/app_durations.dart';
import 'package:rusk_media_player/core/utils/constants/app_strings.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

void showDevSnackbar(BuildContext context, String feature) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _DevSnackbarOverlay(
      feature: feature,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _DevSnackbarOverlay extends StatefulWidget {
  const _DevSnackbarOverlay({
    required this.feature,
    required this.onDismiss,
  });

  final String feature;
  final VoidCallback onDismiss;

  @override
  State<_DevSnackbarOverlay> createState() => _DevSnackbarOverlayState();
}

class _DevSnackbarOverlayState extends State<_DevSnackbarOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotation;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _slide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_mainController);

    _rotation = Tween<double>(begin: -0.05, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _pulse = Tween<double>(begin: 0.9, end: 1.05).animate(_pulseController);

    _mainController.forward().then((_) {
      Future<void>.delayed(AppDurations.snackbarDisplay, () {
        if (mounted) {
          _mainController.reverse().then((_) => widget.onDismiss());
        }
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: context.h(40),
      left: context.w(20),
      right: context.w(20),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _mainController,
              _pulseController,
            ]),
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotation.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(14),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [snackbarDarkStart, snackbarDarkEnd],
                ),
                borderRadius: context.radiusAll(16),
                border: Border.all(
                  color: accentPink.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentPink.withValues(alpha: 0.25),
                    blurRadius: context.sq(25),
                    spreadRadius: context.sq(3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _pulse.value,
                        child: Icon(
                          Icons.auto_awesome,
                          color: accentOrange,
                          size: context.sq(26),
                        ),
                      );
                    },
                  ),

                  context.wSpace(12),

                  /// Text
                  Expanded(
                    child: AppText(
                      '${widget.feature} ${AppStrings.underDevelopment}',
                      style: AppTextStyle.bodyMedium,
                      fontWeight: FontWeight.w500,
                      color: white,
                    ),
                  ),

                  context.wSpace(10),

                  Transform.rotate(
                    angle: pi / 8,
                    child: Icon(
                      Icons.explore,
                      color: snackbarGreen,
                      size: context.sq(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}