import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
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
  late final AnimationController _slideController;
  late final AnimationController _shakeController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 8, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -6, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 6, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -3, end: 0), weight: 1),
    ]).animate(_shakeController);

    _slideController.forward().then((_) {
      _shakeController.forward().then((_) {
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _slideController.reverse().then((_) => widget.onDismiss());
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: context.h(100),
      left: context.w(24),
      right: context.w(24),
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(16),
              vertical: context.h(14),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
              borderRadius: context.radiusAll(14),
              border: Border.all(
                color: accentPink.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: accentPink.withValues(alpha: 0.15),
                  blurRadius: context.sq(20),
                  spreadRadius: context.sq(2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.construction_rounded,
                  color: accentOrange,
                  size: context.sq(24),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: Text(
                    '${widget.feature} is under development',
                    style: GoogleFonts.onest(
                      color: white,
                      fontSize: context.fontSize(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.rocket_launch_rounded,
                  color: const Color(0xFF69F0AE),
                  size: context.sq(20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
