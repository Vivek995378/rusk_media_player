import 'package:flutter/material.dart';

abstract final class MEBrandColors {
  static const primary50 = Color(0xFFFFF1F1);
  static const primary100 = Color(0xFFFFDFDF);
  static const primary200 = Color(0xFFFFC5C5);
  static const primary300 = Color(0xFFFF9D9D);
  static const primary400 = Color(0xFFFF6464);
  static const primary500 = Color(0xFFFF2D2D);
  static const primary600 = Color(0xFFED1515);
  static const primary700 = Color(0xFFC80D0D);
  static const primary800 = Color(0xFFA50F0F);
  static const primary900 = Color(0xFF881414);
  static const primary950 = Color(0xFF4B0404);
}

abstract final class MENeutralColors {
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF6F6F6);
  static const neutral100 = Color(0xFFE7E7E7);
  static const neutral200 = Color(0xFFD1D1D1);
  static const neutral300 = Color(0xFFB0B0B0);
  static const neutral400 = Color(0xFF888888);
  static const neutral500 = Color(0xFF6D6D6D);
  static const neutral600 = Color(0xFF5D5D5D);
  static const neutral700 = Color(0xFF4F4F4F);
  static const neutral800 = Color(0xFF454545);
  static const neutral900 = Color(0xFF3D3D3D);
  static const neutral1000 = Color(0xFF000000);
}

abstract final class MEErrorColors {
  static const error50 = Color(0xFFFFF1F2);
  static const error100 = Color(0xFFFFE1E3);
  static const error200 = Color(0xFFFFC8CC);
  static const error300 = Color(0xFFFFA1A8);
  static const error400 = Color(0xFFFF6B76);
  static const error500 = Color(0xFFF83B49);
  static const error600 = Color(0xFFE5192E);
  static const error700 = Color(0xFFC11023);
  static const error800 = Color(0xFFA01121);
  static const error900 = Color(0xFF841422);
  static const error950 = Color(0xFF48050D);
}

abstract final class MESuccessColors {
  static const success50 = Color(0xFFEFFEF4);
  static const success100 = Color(0xFFD9FDE6);
  static const success200 = Color(0xFFB5FACE);
  static const success300 = Color(0xFF7CF5AA);
  static const success400 = Color(0xFF3CE67E);
  static const success500 = Color(0xFF14CC5B);
  static const success600 = Color(0xFF09A94A);
  static const success700 = Color(0xFF0B853D);
  static const success800 = Color(0xFF0F6934);
  static const success900 = Color(0xFF0D562C);
  static const success950 = Color(0xFF013017);
}

abstract final class MEWarningColors {
  static const warning50 = Color(0xFFFFFBEB);
  static const warning100 = Color(0xFFFFF3C6);
  static const warning200 = Color(0xFFFFE588);
  static const warning300 = Color(0xFFFFD24A);
  static const warning400 = Color(0xFFFFBD20);
  static const warning500 = Color(0xFFF99B07);
  static const warning600 = Color(0xFFDD7302);
  static const warning700 = Color(0xFFB75006);
  static const warning800 = Color(0xFF943D0C);
  static const warning900 = Color(0xFF7A330D);
  static const warning950 = Color(0xFF461902);
}

abstract final class MESupportiveColors {
  static const supportive50 = Color(0xFFF5F3FF);
  static const supportive100 = Color(0xFFEDE8FF);
  static const supportive200 = Color(0xFFDCD4FF);
  static const supportive300 = Color(0xFFC3B1FF);
  static const supportive400 = Color(0xFFA685FF);
  static const supportive500 = Color(0xFF8B53FF);
  static const supportive600 = Color(0xFF7C30F7);
  static const supportive700 = Color(0xFF6D1EE3);
  static const supportive800 = Color(0xFF5C18BF);
  static const supportive900 = Color(0xFF4C159C);
  static const supportive950 = Color(0xFF2E0A6A);
}

const black = MENeutralColors.neutral1000;
const white = MENeutralColors.neutral0;
const transparent = Colors.transparent;

const accentPink = MEBrandColors.primary500;
const accentOrange = MEWarningColors.warning600;
const accentPurple = MESupportiveColors.supportive700;
const accentYellow = MEWarningColors.warning400;
const accentRed = MEErrorColors.error600;

const surfaceDark = Color(0xFF121212);
const surfaceCard = MENeutralColors.neutral800;
const surfaceElevated = MENeutralColors.neutral700;

const heartRed = MEErrorColors.error500;
const heartPink = MEErrorColors.error400;
const heartLight = MEErrorColors.error300;
const heartSoft = MEErrorColors.error200;
const heartFuchsia = MEBrandColors.primary400;

const playGreen = MESuccessColors.success400;
const playGreenLight = MESuccessColors.success300;
const playGreenDark = MESuccessColors.success500;
const playGreenDarkest = MESuccessColors.success700;
const pauseRed = MEErrorColors.error700;

const paywallPurple = MESupportiveColors.supportive800;
const paywallViolet = MESupportiveColors.supportive600;
const paywallFuchsia = MESupportiveColors.supportive500;
const paywallGold = MEWarningColors.warning300;
const paywallDarkStart = MESupportiveColors.supportive950;
const paywallDarkEnd = Color(0xFF0D0B1A);

const loaderOrange = MEWarningColors.warning700;

const snackbarDarkStart = Color(0xFF1A1A2E);
const snackbarDarkEnd = Color(0xFF16213E);
const snackbarGreen = MESuccessColors.success300;

const shimmerPurpleStart = Color(0x006D1EE3);
const shimmerPinkCenter = MEBrandColors.primary500;
const shimmerOrangeEnd = Color(0x00DD7302);

const splashDark = Color(0xFF0A0A0A);
const splashPurpleDark = MESupportiveColors.supportive950;
const subtleGradientStart = Color(0xFF1E1E2E);
const subtleGradientEnd = Color(0xFF2A1A3E);

const red = MEErrorColors.error500;

const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [accentPurple, accentPink, accentOrange],
);

const subtleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [subtleGradientStart, subtleGradientEnd],
);

const paywallCardGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [paywallDarkStart, paywallDarkEnd],
);

const paywallButtonGradient = LinearGradient(
  colors: [paywallFuchsia, paywallViolet],
);

const followButtonGradient = LinearGradient(
  colors: [accentPink, accentOrange],
);

const progressBarGradient = LinearGradient(
  colors: [accentPink, accentOrange],
);

const volumeBarGradient = LinearGradient(
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
  colors: [playGreen, playGreenLight, white],
);
