import 'package:flutter/material.dart';

class AppTheme {
  // Ana Renkler
  static const Color deep = Color(0xFF0D0618);
  static const Color void_ = Color(0xFF130A22);
  static const Color purple1 = Color(0xFF1E0F35);
  static const Color purple2 = Color(0xFF2D1654);
  static const Color purple3 = Color(0xFF4A2080);
  static const Color violet = Color(0xFF7C3AED);
  static const Color lavender = Color(0xFFA855F7);
  static const Color lilac = Color(0xFFC084FC);
  static const Color gold = Color(0xFFF4C842);
  static const Color gold2 = Color(0xFFE8A820);
  static const Color gold3 = Color(0xFFFDE68A);
  static const Color rose = Color(0xFFF472B6);
  static const Color white = Color(0xFFFAF5FF);
  static const Color muted = Color(0x80C8AAFF);

  // Gradient'lar
  static const LinearGradient goldToLilac = LinearGradient(
    colors: [gold, lilac],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [purple2, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [void_, deep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Stilleri
  static const TextStyle cinzelLarge = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: white,
    letterSpacing: 2,
  );

  static const TextStyle cinzelMedium = TextStyle(
    fontFamily: 'Cinzel',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: white,
    letterSpacing: 1,
  );

  static const TextStyle cormorantItalic = TextStyle(
    fontFamily: 'Cormorant Garamond',
    fontSize: 15,
    fontStyle: FontStyle.italic,
    color: muted,
  );
}
