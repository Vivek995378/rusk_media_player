import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/utils/helpers/adaptive_helper.dart';

extension ContextSizeExtensions on BuildContext {
  // Dimensions
  double h(double pixels) => AdaptiveHelper.height(this, pixels);
  double w(double pixels) => AdaptiveHelper.width(this, pixels);
  double sq(double pixels) => AdaptiveHelper.width(this, pixels);
  double fontSize(double pixels) => AdaptiveHelper.text(this, pixels);

  // Spacing Widgets
  SizedBox hSpace(double pixels) => SizedBox(height: h(pixels));
  SizedBox wSpace(double pixels) => SizedBox(width: w(pixels));
  SizedBox empty() => const SizedBox.shrink();

  // Padding
  EdgeInsets paddingAll(double pixels) => EdgeInsets.all(h(pixels));
  EdgeInsets paddingHorizontal(double pixels) =>
      EdgeInsets.symmetric(horizontal: w(pixels));
  EdgeInsets paddingVertical(double pixels) =>
      EdgeInsets.symmetric(vertical: h(pixels));
  EdgeInsets paddingTop(double pixels) => EdgeInsets.only(top: h(pixels));
  EdgeInsets paddingBottom(double pixels) => EdgeInsets.only(bottom: h(pixels));
  EdgeInsets paddingLeft(double pixels) => EdgeInsets.only(left: w(pixels));
  EdgeInsets paddingRight(double pixels) => EdgeInsets.only(right: w(pixels));
  EdgeInsets get paddingNone => EdgeInsets.zero;

  // Border Radius
  BorderRadius radiusAll(double pixels) =>
      BorderRadius.circular(h(pixels));
  BorderRadius radiusTop(double pixels) => BorderRadius.only(
        topLeft: Radius.circular(h(pixels)),
        topRight: Radius.circular(h(pixels)),
      );
  BorderRadius radiusBottom(double pixels) => BorderRadius.only(
        bottomLeft: Radius.circular(h(pixels)),
        bottomRight: Radius.circular(h(pixels)),
      );
  BorderRadius radiusLeft(double pixels) => BorderRadius.only(
        topLeft: Radius.circular(h(pixels)),
        bottomLeft: Radius.circular(h(pixels)),
      );
  BorderRadius radiusRight(double pixels) => BorderRadius.only(
        topRight: Radius.circular(h(pixels)),
        bottomRight: Radius.circular(h(pixels)),
      );
  BorderRadius radiusTopLeft(double pixels) =>
      BorderRadius.only(topLeft: Radius.circular(h(pixels)));
  BorderRadius radiusTopRight(double pixels) =>
      BorderRadius.only(topRight: Radius.circular(h(pixels)));
  BorderRadius radiusBottomLeft(double pixels) =>
      BorderRadius.only(bottomLeft: Radius.circular(h(pixels)));
  BorderRadius radiusBottomRight(double pixels) =>
      BorderRadius.only(bottomRight: Radius.circular(h(pixels)));

  // Device Info
  double get safeTop => MediaQuery.of(this).padding.top;
  double get safeBottom => MediaQuery.of(this).padding.bottom;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
