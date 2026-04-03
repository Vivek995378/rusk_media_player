import 'package:flutter/material.dart';
import 'package:rusk_media_player/core/utils/constants/app_sizes.dart';

abstract final class AdaptiveHelper {
  static double height(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.height * (pixels / AppSizes.designHeight);

  static double width(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.width * (pixels / AppSizes.designWidth);

  static double spacing(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.height * (pixels / AppSizes.designHeight);

  static double corner(BuildContext context, double pixels) =>
      MediaQuery.of(context).size.height * (pixels / AppSizes.designHeight);

  static double text(BuildContext context, double pixels) {
    final scale = MediaQuery.of(context).size.width / AppSizes.designWidth;
    return pixels * scale.clamp(AppSizes.fontScaleMin, AppSizes.fontScaleMax);
  }
}
