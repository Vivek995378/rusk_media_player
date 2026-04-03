import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/design_system/colors.dart';
import 'package:rusk_media_player/core/utils/extensions/context_size_extensions.dart';

enum AppTextStyle {
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  caption,
}

class AppText extends StatelessWidget {
  const AppText(
      this.text, {
        super.key,
        this.style = AppTextStyle.bodyMedium,
        this.color,
        this.fontWeight,
        this.fontSize,
        this.letterSpacing,
        this.height,
        this.maxLines,
        this.overflow,
        this.textAlign,
        this.shadows,
        this.decoration,
      });

  final String text;
  final AppTextStyle style;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final List<Shadow>? shadows;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: _buildTextStyle(context),
    );
  }

  TextStyle _buildTextStyle(BuildContext context) {
    final baseStyle = _getBaseStyle(context);

    return baseStyle.copyWith(
      color: color ?? baseStyle.color,
      fontWeight: fontWeight ?? baseStyle.fontWeight,
      fontSize:
      fontSize != null ? context.fontSize(fontSize!) : baseStyle.fontSize,
      letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      height: height ?? baseStyle.height,
      shadows: shadows ?? baseStyle.shadows,
      decoration: decoration ?? baseStyle.decoration,
    );
  }

  TextStyle _getBaseStyle(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    switch (style) {
      case AppTextStyle.headlineLarge:
        return theme.headlineLarge!.copyWith(
          fontSize: context.fontSize(36),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        );

      case AppTextStyle.headlineMedium:
        return theme.headlineMedium!.copyWith(
          fontSize: context.fontSize(28),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        );

      case AppTextStyle.headlineSmall:
        return theme.headlineSmall!.copyWith(
          fontSize: context.fontSize(22),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        );

      case AppTextStyle.titleLarge:
        return theme.titleLarge!.copyWith(
          fontSize: context.fontSize(20),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        );

      case AppTextStyle.titleMedium:
        return theme.titleMedium!.copyWith(
          fontSize: context.fontSize(16),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        );

      case AppTextStyle.titleSmall:
        return theme.titleSmall!.copyWith(
          fontSize: context.fontSize(14),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        );

      case AppTextStyle.bodyLarge:
        return theme.bodyLarge!.copyWith(
          fontSize: context.fontSize(16),
          letterSpacing: 0.5,
        );

      case AppTextStyle.bodyMedium:
        return theme.bodyMedium!.copyWith(
          fontSize: context.fontSize(14),
          letterSpacing: 0.25,
        );

      case AppTextStyle.bodySmall:
        return theme.bodySmall!.copyWith(
          fontSize: context.fontSize(12),
          letterSpacing: 0.4,
        );

      case AppTextStyle.labelLarge:
        return theme.labelLarge!.copyWith(
          fontSize: context.fontSize(14),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        );

      case AppTextStyle.labelMedium:
        return theme.labelMedium!.copyWith(
          fontSize: context.fontSize(12),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );

      case AppTextStyle.labelSmall:
        return theme.labelSmall!.copyWith(
          fontSize: context.fontSize(11),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );

      case AppTextStyle.caption:
        return theme.bodySmall!.copyWith(
          fontSize: context.fontSize(10),
          color: white.withValues(alpha: 0.6),
          letterSpacing: 0.4,
        );
    }
  }
}
