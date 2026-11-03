import 'package:flutter/material.dart';

class KConstants {
  static const String themeModeKey = "isDarkKey";
  static const String textScaleKey = "textScaleKey";

  // Local-persistence keys (prototype: on-device only, no server). Bumped to
  // v2 when the data model changed, so older on-device data is ignored
  // rather than mis-parsed.
  static const String accountsKey = "accountsKeyV2";
  static const String currentUserIdKey = "currentUserIdKeyV2";
  static const String requestsKey = "requestsKeyV2";
}

/// Brand hues, unchanged from the style lock (.tastemaker/style-lock.md).
/// Widgets don't read these directly: they go through [AppPalette], which
/// maps them onto light and dark roles so dark mode actually adapts.
class AppColors {
  // Text/icon role on light grounds (5.22:1 as white-on-teal fill, 4.74:1 as
  // text on the mint panel).
  static const Color tealStart = Color(0xFF0A7A6E);
  // Bright fill role, only ever paired with dark ink (9.18:1 with #0B1F1C).
  static const Color tealFillEnd = Color(0xFF4FD1C5);
  static const Color softMint = Color(0xFFEDF6F3);
  static const Color emergencyRed = Color(0xFFCC3B3B);
  static const Color emergencyFill = Color(0xFFF27070);
  static const Color textDark = Color(0xFF1F2933);
  static const Color textGrey = Color(0xFF5C6370);
}

/// One pale-tint + ink pair per status. Every pair clears 6.6:1 (light) and
/// 8.3:1 (dark), checked with the WCAG formula; see CHANGES.md.
class Tone {
  const Tone(this.bg, this.ink);
  final Color bg;
  final Color ink;
}

/// Colour roles for one brightness. The style is "editorial greeting" from
/// taste-skill: white ground, tonal mint panels carry the structure, no
/// shadows on anything at rest, no gradients, and the teal accent kept to
/// the one primary action and the data that matters.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ground,
    required this.panel,
    required this.raised,
    required this.border,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.accentTint,
    required this.danger,
    required this.dangerFill,
    required this.onDanger,
    required this.open,
    required this.matched,
    required this.withYou,
    required this.done,
    required this.cancelled,
    required this.star,
  });

  final Color ground;
  final Color panel;
  final Color raised;
  final Color border;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color accentText;
  final Color accentTint;
  final Color danger;
  final Color dangerFill;
  final Color onDanger;
  final Tone open;
  final Tone matched;
  final Tone withYou;
  final Tone done;
  final Tone cancelled;
  final Color star;

  static const light = AppPalette(
    ground: Colors.white,
    panel: AppColors.softMint,
    raised: Color(0xFFF7FAF9),
    // 3.6:1 on white, 3.3:1 on the panel: field outlines and empty marks
    // must be visible (WCAG 1.4.11), not just hinted.
    border: Color(0xFF7D8A86),
    ink: AppColors.textDark,
    muted: AppColors.textGrey,
    accent: AppColors.tealStart,
    onAccent: Colors.white,
    accentText: AppColors.tealStart,
    accentTint: Color(0xFFD6F0EA),
    danger: AppColors.emergencyRed,
    dangerFill: AppColors.emergencyRed,
    onDanger: Colors.white,
    open: Tone(Color(0xFFFFF1D6), Color(0xFF7A4A00)),
    matched: Tone(Color(0xFFD6F0EA), Color(0xFF07574F)),
    withYou: Tone(Color(0xFFE1ECFF), Color(0xFF1C4F9C)),
    done: Tone(Color(0xFFDDF3E3), Color(0xFF1D5E31)),
    cancelled: Tone(Color(0xFFECEEF0), Color(0xFF4A505A)),
    star: Color(0xFF9A6A00),
  );

  static const dark = AppPalette(
    ground: Color(0xFF111413),
    panel: Color(0xFF1A1F1E),
    raised: Color(0xFF222827),
    border: Color(0xFF6B7774),
    ink: Color(0xFFF2F5F4),
    muted: Color(0xFFAEB7B4),
    // A deeper teal than the light theme's fill, so the one filled button
    // doesn't glow on near-black (5.5:1 with its ink).
    accent: Color(0xFF2FA396),
    onAccent: Color(0xFF0B1F1C),
    accentText: Color(0xFF5ED3C6),
    accentTint: Color(0xFF123430),
    danger: Color(0xFFFF8A80),
    dangerFill: AppColors.emergencyFill,
    onDanger: AppColors.textDark,
    open: Tone(Color(0xFF33290F), Color(0xFFF2C46B)),
    matched: Tone(Color(0xFF123430), Color(0xFF7FDCCF)),
    withYou: Tone(Color(0xFF18243A), Color(0xFF9DBEFF)),
    done: Tone(Color(0xFF16301D), Color(0xFF8FD9A3)),
    cancelled: Tone(Color(0xFF262A2F), Color(0xFFC5CBD3)),
    star: Color(0xFFF2C46B),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Radii, chosen once: soft (cards 20, inner rows 14) with fully round
/// buttons, per the editorial-greeting style.
class AppRadius {
  static const double row = 14.0;
  static const double card = 20.0;
  static const double pill = 999.0;
}

/// Two faces, each with one job: Fraunces (a warm, soft serif) for the
/// greeting and screen titles only, Atkinson Hyperlegible (drawn by the
/// Braille Institute for low-vision readers) for everything else. Sizes are
/// set for older eyes first — nothing under 14 — and the Settings text-size
/// control scales all of them up to 2x.
class AppText {
  static const String displayFamily = "Fraunces";
  static const String bodyFamily = "Atkinson";

  /// Titles are already 30pt and up, so they grow to 1.5x at most while body
  /// text goes to 2x: at 2x a greeting took three lines and pushed the
  /// screen's one action below the fold.
  static TextScaler titleScaler(BuildContext context) => MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5);

  /// Icons beside text grow with it, to 1.5x.
  static double icon(BuildContext context, double base) => MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5).scale(base);

  static TextStyle title(Color c) =>
      TextStyle(fontFamily: displayFamily, fontSize: 30, height: 1.15, fontWeight: FontWeight.w600, color: c, letterSpacing: -0.3);
  static TextStyle heading(Color c) =>
      TextStyle(fontFamily: displayFamily, fontSize: 22, height: 1.2, fontWeight: FontWeight.w600, color: c);
  static TextStyle section(Color c) => TextStyle(fontSize: 19, height: 1.3, fontWeight: FontWeight.w700, color: c);
  static TextStyle body(Color c) => TextStyle(fontSize: 18, height: 1.45, color: c);
  static TextStyle secondary(Color c) => TextStyle(fontSize: 16, height: 1.4, color: c);
  static TextStyle small(Color c) => TextStyle(fontSize: 15, height: 1.35, color: c);
}
