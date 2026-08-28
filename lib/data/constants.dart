// Save this to: lib/data/constants.dart (replaces existing file)

import 'package:flutter/material.dart';

class KConstants {
  static const String ThemeModeKey = "isDarkKey";
}

/// Central place for the app's color palette & gradients,
/// inspired by the ElderNet / soft teal-blue reference design.
class AppColors {
  static const Color tealStart = Color(0xFF12B8A6);
  static const Color tealEnd = Color(0xFF4FD1C5);
  static const Color blueAccent = Color(0xFF4F8FF0);

  static const Color softMint = Color(0xFFE9F8F4);
  static const Color softBlue = Color(0xFFEAF2FF);
  static const Color emergencyRed = Color(0xFFE85C5C);

  static const Color textDark = Color(0xFF1F2933);
  static const Color textGrey = Color(0xFF6B7280);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealStart, tealEnd],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softMint, Colors.white],
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

class KTextStytle {
  static const TextStyle titleTealText = TextStyle(
    color: AppColors.tealStart,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle descriptionText = TextStyle(
    fontSize: 16.0,
  );
}