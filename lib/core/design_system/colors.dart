import 'package:flutter/material.dart';

const black = Colors.black;
const black54 = Colors.black54;
const white = Colors.white;
const transparent = Colors.transparent;

const accentPink = Color(0xFFFF006E);
const accentOrange = Color(0xFFFB5607);
const accentPurple = Color(0xFF833AB4);
const accentYellow = Color(0xFFFCAF45);
const accentRed = Color(0xFFE1306C);

const surfaceDark = Color(0xFF121212);
const surfaceCard = Color(0xFF1E1E1E);
const surfaceElevated = Color(0xFF2A2A2A);

const red = Colors.red;
const blue = Colors.blue;
const orange = Colors.orange;
const green = Colors.green;

const heartRed = Color(0xFFFF1744);
const heartPink = Color(0xFFFF4081);
const heartLight = Color(0xFFFF6090);
const heartSoft = Color(0xFFFF80AB);
const heartFuchsia = Color(0xFFFF1493);

const playGreen = Color(0xFF00E676);
const playGreenLight = Color(0xFF69F0AE);
const playGreenDark = Color(0xFF00C853);
const playGreenDarkest = Color(0xFF009624);
const pauseRed = Color(0xFFD50000);

const paywallPurple = Color(0xFF6B21A8);
const paywallViolet = Color(0xFF7C3AED);
const paywallFuchsia = Color(0xFFD946EF);
const paywallGold = Color(0xFFFFD600);
const paywallDarkStart = Color(0xFF1A1035);
const paywallDarkEnd = Color(0xFF0D0B1A);

const loaderOrange = Color(0xFFFF3D00);

const snackbarDarkStart = Color(0xFF1A1A2E);
const snackbarDarkEnd = Color(0xFF16213E);
const snackbarGreen = Color(0xFF69F0AE);

const shimmerPurpleStart = Color(0x00833AB4);
const shimmerPinkCenter = Color(0xFFE1306C);
const shimmerOrangeEnd = Color(0x00FB5607);

const splashDark = Color(0xFF0A0A0A);
const splashPurpleDark = Color(0xFF1A0A2E);
const subtleGradientStart = Color(0xFF1E1E2E);
const subtleGradientEnd = Color(0xFF2A1A3E);

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
