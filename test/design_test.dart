import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/views/pages/family_home_page.dart';
import 'package:flutter_app/views/pages/find_requests_page.dart';
import 'package:flutter_app/views/pages/request_flow_page.dart';
import 'package:flutter_app/views/pages/senior_home_page.dart';
import 'package:flutter_app/views/pages/visit_detail_page.dart';
import 'package:flutter_app/views/pages/visits_page.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

double contrast(Color a, Color b) {
  final (l1, l2) = (a.computeLuminance(), b.computeLuminance());
  return (l1 > l2 ? l1 + 0.05 : l2 + 0.05) / (l1 > l2 ? l2 + 0.05 : l1 + 0.05);
}

/// Every colour pair the app draws, with the floor it must clear. Body ink
/// aims above AA (7:1) because the readers are older.
List<(String, Color, Color, double)> pairsFor(AppPalette p) => [
      for (final (name, bg) in [('ground', p.ground), ('panel', p.panel), ('raised', p.raised)]) ...[
        ('ink on $name', p.ink, bg, 7.0),
        ('muted on $name', p.muted, bg, 4.5),
        ('accentText on $name', p.accentText, bg, 4.5),
        ('danger on $name', p.danger, bg, 4.5),
        ('border on $name', p.border, bg, 3.0),
      ],
      ('accentText on accentTint', p.accentText, p.accentTint, 4.5),
      ('ink on accentTint', p.ink, p.accentTint, 7.0),
      ('onAccent on accent', p.onAccent, p.accent, 4.5),
      ('onDanger on dangerFill', p.onDanger, p.dangerFill, 4.5),
      ('accent on ground', p.accent, p.ground, 3.0),
      ('star on panel', p.star, p.panel, 3.0),
      for (final (name, t) in [('open', p.open), ('matched', p.matched), ('withYou', p.withYou), ('done', p.done), ('cancelled', p.cancelled)])
        ('$name tone', t.ink, t.bg, 4.5),
    ];

Widget at(Widget home, {double scale = 1, bool dark = false}) => MaterialApp(
      theme: buildTheme(AppPalette.light, Brightness.light),
      darkTheme: buildTheme(AppPalette.dark, Brightness.dark),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: home,
    );

void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await appState.init();
  });

  for (final (name, palette) in [('light', AppPalette.light), ('dark', AppPalette.dark)]) {
    test('every $name colour pair clears its contrast floor', () {
      final failures = [
        for (final (what, fg, bg, floor) in pairsFor(palette))
          if (contrast(fg, bg) < floor) '$what: ${contrast(fg, bg).toStringAsFixed(2)} < $floor',
      ];
      expect(failures, isEmpty);
    });
  }

  test('the dark screen setting survives a restart', () async {
    await saveSetting(KConstants.themeModeKey, true);
    await saveSetting(KConstants.textScaleKey, 1.5);
    isDarkModeNotifier.value = false;
    textScaleNotifier.value = 1.0;
    await loadSettings();
    expect(isDarkModeNotifier.value, isTrue);
    expect(textScaleNotifier.value, 1.5);
  });

  testWidgets('with Reduce Motion on, entrances are fully shown on the first frame', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: StaggeredEntrance(index: 3, child: const Text('Hello')),
      ),
    ));
    final fade = tester.widget<FadeTransition>(find.ancestor(of: find.text('Hello'), matching: find.byType(FadeTransition)).first);
    expect(fade.opacity.value, 1);
  });

  // An overflow at 200% fails the test on its own, so pumping each screen is the check.
  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('main screens lay out at 200% text ($mode)', (tester) async {
      usePhone(tester);
      await tester.pumpWidget(at(const WelcomePage(), scale: 2, dark: dark));
      await tester.pumpAndSettle();

      await appState.signInDemo(UserRole.senior);
      final visit = appState.requests.value.firstWhere((r) => r.seniorId == 'demo-senior' && r.status == RequestStatus.matched);
      for (final screen in <Widget>[
        const Scaffold(body: SeniorHomePage()),
        const Scaffold(body: VisitsPage(seniorId: 'demo-senior')),
        VisitDetailPage(requestId: visit.id),
      ]) {
        await tester.pumpWidget(at(screen, scale: 2, dark: dark));
        await tester.pumpAndSettle();
      }

      await appState.signInDemo(UserRole.family);
      await tester.pumpWidget(at(const Scaffold(body: FamilyHomePage()), scale: 2, dark: dark));
      await tester.pumpAndSettle();

      await appState.signInDemo(UserRole.volunteer);
      await tester.pumpWidget(at(const Scaffold(body: FindRequestsPage()), scale: 2, dark: dark));
      await tester.pumpAndSettle();
    });

    testWidgets('every request step lays out at 200% text, as family ($mode)', (tester) async {
      usePhone(tester);
      await appState.signInDemo(UserRole.family);
      await tester.pumpWidget(at(RequestFlowPage(seniorId: 'demo-senior', now: DateTime.now()), scale: 2, dark: dark));
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 5 · For Margaret'), findsOneWidget);
      expect(find.text("A visit to Margaret's doctor or clinic"), findsOneWidget);

      await tapText(tester, 'Blood or lab test');
      await tapText(tester, 'Next');
      await tapText(tester, 'Tomorrow');
      await tapText(tester, 'Next');
      await tester.enterText(find.widgetWithText(TextField, 'Name of the place'), 'Elm Park Lab');
      await tapText(tester, 'Next');
      await tapText(tester, 'Next');
      expect(find.text('Check and send'), findsOneWidget);
      await tapText(tester, 'Send my request');
      expect(find.text('Your request is sent'), findsOneWidget);
    });
  }
}
