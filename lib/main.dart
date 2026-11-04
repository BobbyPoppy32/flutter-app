import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';
import 'package:flutter_app/views/widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSettings();
  await appState.init();
  runApp(const MyApp());
}

ThemeData buildTheme(AppPalette p, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: brightness).copyWith(
    primary: p.accent,
    onPrimary: p.onAccent,
    surface: p.ground,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    error: p.danger,
    outline: p.border,
  );
  final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill));
  const label = TextStyle(fontFamily: AppText.bodyFamily, fontSize: 18, fontWeight: FontWeight.w700);
  final field = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.row),
    borderSide: BorderSide(color: p.border, width: 1.5),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [p],
    fontFamily: AppText.bodyFamily,
    scaffoldBackgroundColor: p.ground,
    // A soft press tint instead of the Android ripple, as on iOS.
    splashFactory: NoSplash.splashFactory,
    highlightColor: p.ink.withValues(alpha: 0.06),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.iOS: _CalmTransitions(), TargetPlatform.android: _CalmTransitions()},
    ),
    textTheme: TextTheme(
      headlineMedium: AppText.title(p.ink),
      titleLarge: AppText.heading(p.ink),
      titleMedium: AppText.section(p.ink),
      bodyLarge: AppText.body(p.ink),
      bodyMedium: AppText.secondary(p.ink),
      bodySmall: AppText.small(p.muted),
      labelLarge: label,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.section(p.ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        disabledBackgroundColor: p.panel,
        disabledForegroundColor: p.muted,
        minimumSize: const Size(64, 60),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: pill,
        textStyle: label,
      ),
    ),
    // Secondary actions are tonal: a panel-coloured pill, no outline.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        // A clear fill: the outline says "button" on cards and on the page,
        // without dark pills sinking into cards in dark mode.
        backgroundColor: Colors.transparent,
        // Disabled stays readable (muted ink, 5.5:1), never faded out.
        disabledForegroundColor: p.muted,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // A visible edge, so a low-vision user can tell it's a button.
        side: BorderSide(color: p.border, width: 1.5),
        shape: pill,
        textStyle: label,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.accentText,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // Underlined so a text action reads as tappable without colour.
        textStyle: label.copyWith(fontSize: 17, decoration: TextDecoration.underline, decorationThickness: 1.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.ground,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: field,
      enabledBorder: field,
      focusedBorder: field.copyWith(borderSide: BorderSide(color: p.accent, width: 2.5)),
      errorBorder: field.copyWith(borderSide: BorderSide(color: p.danger, width: 2)),
      focusedErrorBorder: field.copyWith(borderSide: BorderSide(color: p.danger, width: 2.5)),
      labelStyle: AppText.secondary(p.muted),
      floatingLabelStyle: AppText.secondary(p.accentText),
      hintStyle: AppText.secondary(p.muted),
      errorStyle: AppText.small(p.danger),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      titleTextStyle: AppText.heading(p.ink),
      contentTextStyle: AppText.body(p.ink),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.ink,
      contentTextStyle: AppText.secondary(p.ground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.row)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.panel,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.accentTint,
      height: 76,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: AppText.bodyFamily,
          fontSize: 15,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w400,
          color: s.contains(WidgetState.selected) ? p.ink : p.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(size: 26, color: s.contains(WidgetState.selected) ? p.accentText : p.muted),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onAccent : p.muted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.panel),
      trackOutlineColor: WidgetStateProperty.all(p.border),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.accent,
      inactiveTrackColor: p.border,
      thumbColor: p.accent,
      trackHeight: 6,
      overlayColor: p.accent.withValues(alpha: 0.12),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.ground,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: p.panel,
      headerForegroundColor: p.ink,
    ),
    dividerTheme: DividerThemeData(color: p.border.withValues(alpha: 0.35), thickness: 1, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent, linearTrackColor: p.panel),
    listTileTheme: ListTileThemeData(minVerticalPadding: 12, iconColor: p.ink, textColor: p.ink),
  );
}

/// iOS-style slides between screens, shown at once with Reduce Motion on.
/// The labelled Back button stays on every screen, so the edge swipe is a
/// shortcut, never the only way back.
class _CalmTransitions extends PageTransitionsBuilder {
  const _CalmTransitions();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return const CupertinoPageTransitionsBuilder().buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: "Alongside",
          debugShowCheckedModeBanner: false,
          theme: buildTheme(AppPalette.light, Brightness.light),
          darkTheme: buildTheme(AppPalette.dark, Brightness.dark),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          themeAnimationDuration: AppMotion.standard,
          themeAnimationCurve: AppMotion.enter,
          // The in-app text size multiplies the phone's own setting, so a
          // senior who already set large text on their iPhone keeps it.
          // Capped at 2x, which every screen is laid out to survive.
          builder: (context, child) => ValueListenableBuilder(
            valueListenable: textScaleNotifier,
            builder: (context, textScale, _) {
              final system = MediaQuery.textScalerOf(context).scale(1);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear((system * textScale).clamp(1.0, 2.0))),
                child: child!,
              );
            },
          ),
          home: ValueListenableBuilder(
            valueListenable: appState.currentUser,
            builder: (context, user, _) => user == null ? const WelcomePage() : const WidgetTree(),
          ),
        );
      },
    );
  }
}
