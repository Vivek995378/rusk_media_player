import 'package:flutter/material.dart';

// Base
const black = Colors.black;
const black54 = Colors.black54;
const white = Colors.white;
const transparent = Colors.transparent;

// Brand — Instagram-inspired palette
const accentPink = Color(0xFFFF006E);
const accentOrange = Color(0xFFFB5607);
const accentPurple = Color(0xFF833AB4);
const accentYellow = Color(0xFFFCAF45);
const accentRed = Color(0xFFE1306C);

// Surfaces
const surfaceDark = Color(0xFF121212);
const surfaceCard = Color(0xFF1E1E1E);
const surfaceElevated = Color(0xFF2A2A2A);

// Semantic
const red = Colors.red;
const blue = Colors.blue;
const orange = Colors.orange;
const green = Colors.green;

// Gradients
const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [accentPurple, accentPink, accentOrange],
);

const subtleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1E1E2E),
    Color(0xFF2A1A3E),
  ],
);
