import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';
import 'package:flutter_app/views/widget_tree.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initThemeMode();
    initTextScale();
    initReminders();
    super.initState();
  }

  void initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDark = prefs.getBool(KConstants.ThemeModeKey);
    isDarkModeNotifier.value = isDark ?? false;
  }

  void initTextScale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? scale = prefs.getDouble(KConstants.TextScaleKey);
    textScaleNotifier.value = scale ?? 1.0;
  }

  void initReminders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    medicationRemindersNotifier.value = prefs.getBool(KConstants.MedicationRemindersKey) ?? true;
    appointmentRemindersNotifier.value = prefs.getBool(KConstants.AppointmentRemindersKey) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        final colorScheme = ColorScheme.fromSeed(
          seedColor: AppColors.tealStart,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: GoogleFonts.nunito().fontFamily,
            textTheme: TextTheme(
              headlineMedium: AppTextStyles.heading1,
              titleLarge: AppTextStyles.heading2,
              bodyLarge: AppTextStyles.body,
              bodyMedium: AppTextStyles.bodySecondary,
              bodySmall: AppTextStyles.caption,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(64, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size(64, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(64, 52),
                foregroundColor: AppColors.tealStart,
                side: const BorderSide(color: AppColors.tealStart, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.softMint.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.field),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.field),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.field),
                borderSide: const BorderSide(color: AppColors.tealStart, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.field),
                borderSide: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.field),
                borderSide: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
              ),
              hintStyle: const TextStyle(color: AppColors.textGrey),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
              titleTextStyle: AppTextStyles.heading2,
              contentTextStyle: AppTextStyles.body,
            ),
            snackBarTheme: SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.tealStart,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
            ),
            listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
          ),
          builder: (context, child) {
            return ValueListenableBuilder(
              valueListenable: textScaleNotifier,
              builder: (context, textScale, _) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                );
              },
            );
          },
          home: appState.currentUser.value == null ? const WelcomePage() : const WidgetTree(),
        );
      },
    );
  }
}
