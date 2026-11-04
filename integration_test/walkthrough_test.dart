import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Taps through every main screen on a real device or simulator and saves a
/// screenshot of each. Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/walkthrough_test.dart -d SIMULATOR_ID
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('walk through every screen', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await loadSettings();
    await appState.init();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle();
    }

    Future<void> text(String s) => tap(find.text(s));

    Future<void> scrollDown() async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pumpAndSettle();
    }

    // Every pushed screen has a labelled "Back" button (PageAppBar).
    Future<void> back() => tap(find.text("Back"));

    Future<void> becomeDemo(String tileStart) async {
      await text("Look around with sample people");
      await tap(find.textContaining(tileStart));
    }

    Future<void> signOut() async {
      // Let any "done" message slide away so it can't cover the button.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await text("Profile");
      await text("Sign out");
      await tap(find.text("Sign out").last);
    }

    // ---- Onboarding --------------------------------------------------------
    await shot("01-welcome");
    await text("Get started");
    await shot("02-who-are-you");
    await back();

    // ---- Senior ------------------------------------------------------------
    await becomeDemo("I need help");
    await shot("03-senior-home");
    await scrollDown();
    await shot("04-senior-home-more");
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();

    await text("Ask for help");
    await shot("05-request-what");
    await text("Scan or X\u2011ray");
    await text("Next");
    await shot("06-request-when");
    await text("Tomorrow");
    await tap(find.byTooltip("15 minutes later"));
    await text("Next");
    await text("St. Anne's Imaging");
    await shot("07-request-where");
    await text("Next");
    await shot("08-request-needs");
    await text("Next");
    await shot("09-request-check");
    await text("Send my request");
    await shot("10-request-sent");
    await text("Back to home");

    await text("My visits");
    await shot("11-senior-visits");
    await text("Blood or lab test");
    await shot("12-visit-detail");
    await scrollDown();
    await shot("13-visit-detail-more");
    await tap(find.text("Daniel Okafor"));
    await shot("14-volunteer-profile");
    await back();
    await back();
    await text("Past");
    await text("Pick up medicine");
    await tap(find.byIcon(Icons.star_outline_rounded).last);
    await shot("15-rate-visit");
    await back();
    await text("Profile");
    await shot("16-senior-profile");
    await text("Settings");
    await shot("17-settings");
    await back();
    await signOut();

    // ---- Volunteer ---------------------------------------------------------
    await becomeDemo("I want to volunteer");
    await shot("18-volunteer-home");
    await text("I'm at the door");
    await shot("19-volunteer-checked-in");
    await text("Visit done");
    await shot("20-volunteer-finish");
    await text("Yes, visit done");
    await scrollDown();
    await shot("21-volunteer-impact");

    await text("Find");
    await shot("22-find");
    await text("Change filters");
    await shot("23-find-filters");
    await text("Within 5 km");
    await text("Show requests");
    await shot("24-find-filtered");
    await tap(find.textContaining("Harold P."));
    await shot("25-request-before-accept");
    await text("Say yes to helping");
    await shot("26-accept-confirm");
    await text("Yes, I'll help");
    await shot("27-request-accepted");
    await back();
    await text("My visits");
    await shot("28-volunteer-visits");
    await text("Profile");
    await shot("29-volunteer-profile");
    await signOut();

    // ---- Family ------------------------------------------------------------
    await becomeDemo("I'm helping my mum");
    await shot("30-family-home");
    await signOut();

    // ---- Largest text and dark mode -----------------------------------------
    textScaleNotifier.value = 2.0;
    await tester.pumpAndSettle();
    await shot("31-welcome-200");
    await becomeDemo("I need help");
    await shot("32-senior-home-200");
    await text("Ask for help");
    await text("Doctor's check-up");
    await text("Next");
    await shot("33-request-when-200");
    await tap(find.text("Back"));
    await tap(find.text("Back"));
    await text("Yes, stop");
    await text("My visits");
    await shot("34-senior-visits-200");
    await signOut();
    await becomeDemo("I want to volunteer");
    await text("Find");
    await shot("35-find-200");
    textScaleNotifier.value = 1.0;
    isDarkModeNotifier.value = true;
    await text("Home");
    await shot("36-volunteer-home-dark");
    await signOut();
    await becomeDemo("I need help");
    await shot("37-senior-home-dark");
    await text("My visits");
    await text("Blood or lab test");
    await shot("38-visit-detail-dark");
    isDarkModeNotifier.value = false;
    await tester.pumpAndSettle();
  });
}
