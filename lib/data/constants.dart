import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KConstants {
  static const String ThemeModeKey = "isDarkKey";
  static const String TextScaleKey = "textScaleKey";

  // Local-persistence keys (prototype: on-device only, no server).
  static const String AccountsKey = "accountsKey";
  static const String CurrentUserEmailKey = "currentUserEmailKey";
  static const String RequestsKey = "requestsKey";
  static const String MedicationRemindersKey = "medicationRemindersKey";
  static const String AppointmentRemindersKey = "appointmentRemindersKey";
}

/// Central place for the app's color palette & gradients,
/// inspired by the ElderNet / soft teal-blue reference design.
class AppColors {
  // Text/icon/border role: used on light backgrounds (links, outlined
  // button labels, icons, focus borders) — needs to be dark enough to read
  // as text on its own (5.22:1 vs white; the brighter originals below only
  // hit 2.49:1 there, failing WCAG AA).
  static const Color tealStart = Color(0xFF0A7A6E);
  static const Color tealEnd = Color(0xFF0B8074);
  static const Color blueAccent = Color(0xFF4F8FF0);

  // Fill role: the reference mockup's actual bright mint/teal, used only as
  // a solid/gradient fill (primaryGradient) and always paired with dark
  // (textDark) foreground content on top — 5.92:1 / 7.91:1, better margin
  // than darkening the fill itself would give. See .tastemaker/style-lock.md.
  static const Color tealFillStart = Color(0xFF12B8A6);
  static const Color tealFillEnd = Color(0xFF4FD1C5);

  static const Color softMint = Color(0xFFE9F8F4);
  static const Color softBlue = Color(0xFFEAF2FF);
  // Text/icon/border role — dark enough to read as text on its own
  // (4.93:1 vs white; see emergencyFill below for the fill-role variant).
  static const Color emergencyRed = Color(0xFFCC3B3B);
  // Fill role: a lighter coral closer to the reference image, used only for
  // solid fills (the emergency Call button) paired with dark foreground
  // text — 5.15:1, better margin than darkening the fill would give.
  static const Color emergencyFill = Color(0xFFF27070);

  static const Color textDark = Color(0xFF1F2933);
  // Darkened from #6B7280 (4.42:1 against the mint background — just under
  // the 4.5 floor) to 6.05:1. The old value is reused below for
  // statusCancelled, where it's paired only with white and still clears AA.
  static const Color textGrey = Color(0xFF5C6370);

  static const Color statusOpen = textGrey;
  static const Color statusAccepted = tealStart;
  // Darkened from #3FAE5C (2.83:1 with white) to 5.47:1.
  static const Color statusCompleted = Color(0xFF26783D);
  // The old textGrey value — still clears 4.83:1 against white, reused here
  // instead of the original #9CA3AF (2.54:1, failed).
  static const Color statusCancelled = Color(0xFF6B7280);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealFillStart, tealFillEnd],
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

/// Single source of truth for corner radii, so cards/buttons/fields stop
/// drifting between 14/16/18/20/22/30 across the app.
class AppRadius {
  static const double field = 14.0;
  static const double card = 20.0;
  static const double hero = 28.0;
  static const double pill = 30.0;
}

/// Base text sizes, modestly larger than Material defaults, for a
/// senior-friendly baseline. The user's Settings text-size slider further
/// scales these at runtime via TextScaler — see main.dart. Fredoka is used
/// for headings (big, friendly, rounded letterforms) and Nunito for body
/// copy (very readable rounded sans) — the same pairing is wired into
/// ThemeData in main.dart so unstyled Material widgets pick it up too.
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.fredoka(
    fontSize: 30.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static TextStyle get heading2 => GoogleFonts.fredoka(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static TextStyle get body => GoogleFonts.nunito(
    fontSize: 17.0,
    color: AppColors.textDark,
  );
  static TextStyle get bodySecondary => GoogleFonts.nunito(
    fontSize: 15.0,
    color: AppColors.textGrey,
  );
  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 13.0,
    color: AppColors.textGrey,
  );
}
