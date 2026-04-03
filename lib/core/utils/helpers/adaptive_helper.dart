import 'package:flutter/material.dart';

class AdaptiveHelper {
  static const double designWidth = 430;
  static const double designHeight = 932;
  static const double fontScaleMin = 0.7;
  static const double fontScaleMax = 1.5;

  static double height(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.height * (pixels / designHeight);
  static double width(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.width * (pixels / designWidth);
  static double spacing(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.height * (pixels / designHeight);
  static double corner(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.height * (pixels / designHeight);
  static double text(BuildContext context, double pixels) {
    final scale = MediaQuery.of(context).size.width / designWidth;
    return pixels * scale.clamp(fontScaleMin, fontScaleMax);
  }
}
