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

/// Harbour Ink brand hues (.tastemaker/style-lock.md). Widgets don't read
/// these directly: they go through [AppPalette], which maps them onto light
/// and dark roles.
class AppColors {
  // Deep navy: trust of a paid professional service, without hospital teal.
  static const Color navy = Color(0xFF1F3A5F);
  // Warm linen ground: softer on older eyes than pure white.
  static const Color linen = Color(0xFFF6F1E8);
  static const Color ink = Color(0xFF1B2230);
  // Apricot warmth. Only a fill behind dark ink (7.4:1), or the logo's
  // second stroke on navy; too light to be text on linen.
  static const Color apricot = Color(0xFFE8A25A);
  // The logo's second stroke on light grounds (3.9:1 on linen).
  static const Color apricotDeep = Color(0xFFB8681F);
  static const Color charcoal = Color(0xFF16181D);
}

/// One pale-tint + ink pair per status, told apart by lightness, icon and
/// words rather than hue alone. Each pair clears 4.5:1 (test/design_test.dart).
class Tone {
  const Tone(this.bg, this.ink);
  final Color bg;
  final Color ink;

  static Tone lerp(Tone a, Tone b, double t) => Tone(Color.lerp(a.bg, b.bg, t)!, Color.lerp(a.ink, b.ink, t)!);
}

/// Colour roles for one brightness. Linen ground with near-white cards that
/// carry the structure, navy for the one main action, apricot for warmth.
/// No gradients and no resting shadows.
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
    required this.highlight,
    required this.onHighlight,
    required this.brand,
    required this.brandSecond,
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
  final Color highlight;
  final Color onHighlight;
  // The logo's two strokes on this ground.
  final Color brand;
  final Color brandSecond;
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
    ground: AppColors.linen,
    panel: Color(0xFFFFFCF7),
    raised: Color(0xFFEEE7DA),
    // 3.7:1 on linen, 4.0:1 on cards: outlines and empty marks stay visible.
    border: Color(0xFF857C6E),
    ink: AppColors.ink,
    muted: Color(0xFF4E5563),
    accent: AppColors.navy,
    onAccent: Colors.white,
    accentText: AppColors.navy,
    accentTint: Color(0xFFDDE5F0),
    highlight: AppColors.apricot,
    onHighlight: AppColors.ink,
    brand: AppColors.navy,
    brandSecond: AppColors.apricotDeep,
    danger: Color(0xFFA8261D),
    dangerFill: Color(0xFFA8261D),
    onDanger: Colors.white,
    open: Tone(Color(0xFFF7E6C2), Color(0xFF5E3D00)),
    matched: Tone(Color(0xFFDDE5F0), AppColors.navy),
    withYou: Tone(Color(0xFFF6DCC3), Color(0xFF6E3608)),
    done: Tone(Color(0xFFDCEADB), Color(0xFF1F4E2A)),
    cancelled: Tone(Color(0xFFE7E2D9), Color(0xFF474C55)),
    star: Color(0xFF9A5F0A),
  );

  static const dark = AppPalette(
    ground: AppColors.charcoal,
    panel: Color(0xFF1F232A),
    raised: Color(0xFF292E36),
    border: Color(0xFF737A86),
    ink: Color(0xFFF3EEE6),
    muted: Color(0xFFB7B1A7),
    // Navy disappears on charcoal, so the action colour turns to a pale
    // harbour blue with navy-black words on it (8.9:1).
    accent: Color(0xFF9DBDE6),
    onAccent: Color(0xFF0F1B2D),
    accentText: Color(0xFFA9C7EE),
    accentTint: Color(0xFF24344C),
    highlight: AppColors.apricot,
    onHighlight: AppColors.ink,
    brand: Color(0xFFF3EEE6),
    brandSecond: AppColors.apricot,
    danger: Color(0xFFFF9C91),
    dangerFill: Color(0xFFF28B82),
    onDanger: Color(0xFF2A0F0C),
    open: Tone(Color(0xFF3A2E14), Color(0xFFF2CD7A)),
    matched: Tone(Color(0xFF24344C), Color(0xFFB5CDEE)),
    withYou: Tone(Color(0xFF3B2817), Color(0xFFF4BA8C)),
    done: Tone(Color(0xFF1D3325), Color(0xFFA0D6AA)),
    cancelled: Tone(Color(0xFF2B2E34), Color(0xFFCBCED4)),
    star: Color(0xFFF2C46B),
  );

  @override
  AppPalette copyWith() => this;

  // A real blend, so switching the dark screen on fades rather than snaps.
  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ground: c(ground, other.ground),
      panel: c(panel, other.panel),
      raised: c(raised, other.raised),
      border: c(border, other.border),
      ink: c(ink, other.ink),
      muted: c(muted, other.muted),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      accentText: c(accentText, other.accentText),
      accentTint: c(accentTint, other.accentTint),
      highlight: c(highlight, other.highlight),
      onHighlight: c(onHighlight, other.onHighlight),
      brand: c(brand, other.brand),
      brandSecond: c(brandSecond, other.brandSecond),
      danger: c(danger, other.danger),
      dangerFill: c(dangerFill, other.dangerFill),
      onDanger: c(onDanger, other.onDanger),
      open: Tone.lerp(open, other.open, t),
      matched: Tone.lerp(matched, other.matched, t),
      withYou: Tone.lerp(withYou, other.withYou, t),
      done: Tone.lerp(done, other.done, t),
      cancelled: Tone.lerp(cancelled, other.cancelled, t),
      star: c(star, other.star),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Radii: soft cards, rounder inner rows, fully round buttons.
class AppRadius {
  static const double row = 16.0;
  static const double card = 24.0;
  static const double pill = 999.0;
}

/// The spacing steps every screen uses.
class AppSpace {
  static const double xs = 4, s = 8, m = 12, l = 16, xl = 20, xxl = 24, section = 32, page = 48;
}

/// One calm motion budget: short, ease-out, no bounce. With the phone's
/// Reduce Motion on, every duration is zero.
class AppMotion {
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 240);
  static const emphasized = Duration(milliseconds: 420);
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;

  static Duration of(BuildContext context, Duration d) => MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}

/// Two faces, each with one job: Literata (a calm book serif with a large
/// x-height) for greetings and titles, Atkinson Hyperlegible Next (drawn by
/// the Braille Institute for low-vision readers) for everything else.
/// Nothing is under 15pt, and the text-size setting scales it all to 2x.
class AppText {
  static const String displayFamily = "Literata";
  static const String bodyFamily = "AtkinsonNext";

  /// Titles are already 28pt and up, so they grow to 1.5x at most while body
  /// text goes to 2x: at 2x a greeting took three lines and pushed the
  /// screen's one action below the fold.
  static TextScaler titleScaler(BuildContext context) => MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5);

  /// Icons beside text grow with it, to 1.5x.
  static double icon(BuildContext context, double base) => MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5).scale(base);

  static TextStyle display(Color c) =>
      TextStyle(fontFamily: displayFamily, fontSize: 38, height: 1.1, fontWeight: FontWeight.w600, color: c, letterSpacing: -0.6);
  static TextStyle title(Color c) =>
      TextStyle(fontFamily: displayFamily, fontSize: 30, height: 1.15, fontWeight: FontWeight.w600, color: c, letterSpacing: -0.4);
  static TextStyle heading(Color c) =>
      TextStyle(fontFamily: displayFamily, fontSize: 23, height: 1.2, fontWeight: FontWeight.w600, color: c, letterSpacing: -0.2);
  static TextStyle section(Color c) => TextStyle(fontSize: 19, height: 1.3, fontWeight: FontWeight.w700, color: c);
  static TextStyle body(Color c) => TextStyle(fontSize: 18, height: 1.45, color: c);
  static TextStyle secondary(Color c) => TextStyle(fontSize: 16, height: 1.4, color: c);
  static TextStyle small(Color c) => TextStyle(fontSize: 15, height: 1.35, color: c);

  /// Pills, badges and short tags.
  static TextStyle label(Color c) => TextStyle(fontSize: 15, height: 1.2, fontWeight: FontWeight.w700, color: c, letterSpacing: 0.1);

  /// The door code and other numbers read aloud at the door: fixed-width
  /// digits so "6 3 7 5" never shifts.
  static TextStyle code(Color c) => TextStyle(
        fontFamily: displayFamily,
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: c,
        letterSpacing: 2,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle wordmark(Color c, {double size = 26}) =>
      TextStyle(fontFamily: displayFamily, fontSize: size, height: 1, fontWeight: FontWeight.w600, color: c, letterSpacing: 0.3);
}
