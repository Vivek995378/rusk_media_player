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
      fontSize: fontSize != null ? context.fontSize(fontSize!) : baseStyle.fontSize,
      letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      height: height ?? baseStyle.height,
      shadows: shadows ?? baseStyle.shadows,
      decoration: decoration ?? baseStyle.decoration,
    );
  }

  TextStyle _getBaseStyle(BuildContext context) {
    switch (style) {
      case AppTextStyle.headlineLarge:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(36),
          fontWeight: FontWeight.w900,
          color: white,
          letterSpacing: 0.5,
        );
      case AppTextStyle.headlineMedium:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(28),
          fontWeight: FontWeight.w800,
          color: white,
          letterSpacing: 0.4,
        );
      case AppTextStyle.headlineSmall:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(22),
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: 0.3,
        );
      case AppTextStyle.titleLarge:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(20),
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: 0.2,
        );
      case AppTextStyle.titleMedium:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(16),
          fontWeight: FontWeight.bold,
          color: white,
          letterSpacing: 0.15,
        );
      case AppTextStyle.titleSmall:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(14),
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.1,
        );
      case AppTextStyle.bodyLarge:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(16),
          fontWeight: FontWeight.w400,
          color: white,
          letterSpacing: 0.5,
        );
      case AppTextStyle.bodyMedium:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(14),
          fontWeight: FontWeight.w400,
          color: white,
          letterSpacing: 0.25,
        );
      case AppTextStyle.bodySmall:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(12),
          fontWeight: FontWeight.w400,
          color: white,
          letterSpacing: 0.4,
        );
      case AppTextStyle.labelLarge:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(14),
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.1,
        );
      case AppTextStyle.labelMedium:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(12),
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.5,
        );
      case AppTextStyle.labelSmall:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(11),
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.5,
        );
      case AppTextStyle.caption:
        return TextStyle(
          fontFamily: 'Onest',
          fontSize: context.fontSize(10),
          fontWeight: FontWeight.w400,
          color: white.withValues(alpha: 0.6),
          letterSpacing: 0.4,
        );
    }
  }
}
