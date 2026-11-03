import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/views/pages/find_requests_page.dart';
import 'package:flutter_app/views/pages/request_flow_page.dart';
import 'package:flutter_app/views/pages/visits_page.dart';
import 'package:flutter_app/views/pages/volunteer_request_page.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> fresh() async {
  SharedPreferences.setMockInitialValues({});
  await appState.init();
}

/// A phone-sized screen, so layouts are tested at the size they ship at.
void usePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget wrap(Widget child) => MaterialApp(theme: buildTheme(AppPalette.light, Brightness.light), home: child);

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

HelpRequest openRequestOf(String seniorId) =>
    appState.requests.value.firstWhere((r) => r.seniorId == seniorId && r.status == RequestStatus.open);

void main() {
  setUp(fresh);

  testWidgets('app boots to the welcome screen', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Alongside'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Look around with sample people'), findsOneWidget);
  });

  testWidgets('a senior asks for help, step by step', (tester) async {
    usePhone(tester);
    await appState.signInDemo(UserRole.senior);
    final before = appState.requests.value.length;
    await tester.pumpWidget(wrap(RequestFlowPage(seniorId: 'demo-senior', now: DateTime.now())));
    await tester.pumpAndSettle();

    // Nothing chosen yet: Next explains what's missing instead of moving on.
    await tapText(tester, 'Next');
    expect(find.text('Please choose what you need help with.'), findsOneWidget);
    expect(find.text('Step 1 of 5'), findsOneWidget);

    await tapText(tester, 'Blood or lab test');
    await tapText(tester, 'Next');
    expect(find.text('When is it?'), findsOneWidget);
    await tapText(tester, 'Tomorrow');
    await tester.tap(find.byTooltip('15 minutes later'));
    await tester.pumpAndSettle();
    expect(find.text('10:15 am'), findsOneWidget);
    await tapText(tester, 'Next');

    expect(find.text('Where are you going?'), findsOneWidget);
    await tapText(tester, 'Next');
    expect(find.text("Please write where you're going."), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Name of the place'), 'Elm Park Lab');
    await tapText(tester, 'Next');

    // Needs come pre-ticked from Margaret's profile.
    expect(find.text('Anything we should know?'), findsOneWidget);
    await tapText(tester, 'Next');

    expect(find.text('Check and send'), findsOneWidget);
    expect(find.text('Blood or lab test'), findsOneWidget);
    // "Change" jumps back to that step, then straight back to the summary.
    await tester.tap(find.text('Change').first);
    await tester.pumpAndSettle();
    await tapText(tester, "Doctor's check-up");
    await tapText(tester, 'Save and go back to the summary');
    expect(find.text('Check and send'), findsOneWidget);
    expect(find.text("Doctor's check-up"), findsOneWidget);

    await tapText(tester, 'Send my request');
    expect(find.text('Your request is sent'), findsOneWidget);

    expect(appState.requests.value.length, before + 1);
    final sent = appState.requests.value.last;
    expect(sent.type, HelpType.checkup);
    expect(sent.status, RequestStatus.open);
    expect(sent.placeName, 'Elm Park Lab');
    expect(sent.needs, {MobilityNeed.walker, MobilityNeed.hearing});
    expect(sent.when.hour, 10);
    expect(sent.when.minute, 15);
  });

  testWidgets('a volunteer only sees private details after saying yes', (tester) async {
    usePhone(tester);
    await appState.signInDemo(UserRole.volunteer);
    final request = openRequestOf('s-harold');
    await tester.pumpWidget(wrap(VolunteerRequestPage(requestId: request.id)));
    await tester.pumpAndSettle();

    expect(find.text('Harold P.'), findsOneWidget);
    expect(find.text('Harold Petrov'), findsNothing);
    expect(find.textContaining('Main Street Pharmacy'), findsNothing);
    expect(find.text('Door code'), findsNothing);

    await tapText(tester, 'Say yes to helping');
    expect(find.textContaining('Help Harold'), findsOneWidget);
    await tapText(tester, "Yes, I'll help");

    final accepted = appState.requestById(request.id)!;
    expect(accepted.status, RequestStatus.matched);
    expect(accepted.volunteerId, 'demo-volunteer');
    expect(find.text('Harold Petrov'), findsOneWidget);
    expect(find.textContaining('Main Street Pharmacy'), findsOneWidget);
    expect(find.text('Door code'), findsOneWidget);
    expect(find.text("I can't make it"), findsOneWidget);
  });

  testWidgets('an unchecked volunteer sees no requests at all', (tester) async {
    usePhone(tester);
    await appState.createAccount(name: 'Sam Rivera', role: UserRole.volunteer, phone: '555 010 3030');
    final me = appState.currentUser.value!;
    expect(me.vetting.complete, isFalse);
    expect(appState.openFor(me), isEmpty);

    await tester.pumpWidget(wrap(const Scaffold(body: FindRequestsPage())));
    await tester.pumpAndSettle();
    expect(find.text('Your checks come first'), findsOneWidget);
    expect(find.textContaining('km away'), findsNothing);

    await tapText(tester, 'Pretend my checks have passed');
    expect(find.text('Find someone to help'), findsOneWidget);
    // No checked car insurance, so rides stay hidden even once vetted.
    expect(appState.openFor(appState.currentUser.value!).any((r) => r.type == HelpType.ride), isFalse);
  });

  test('a visit runs from yes to done, and a drop-out reopens it', () async {
    final daniel = appState.userById('demo-volunteer')!;
    final r = openRequestOf('s-eleanor');

    await appState.accept(r.id, daniel.id);
    await appState.confirmComing(r.id);
    expect(appState.requestById(r.id)!.confirmedAt, isNotNull);
    await appState.checkIn(r.id);
    expect(appState.requestById(r.id)!.status, RequestStatus.withYou);
    final before = appState.statsFor(daniel.id).visits;
    await appState.complete(r.id, note: 'Dr. said come back in a year.');
    expect(appState.requestById(r.id)!.status, RequestStatus.done);
    expect(appState.statsFor(daniel.id).visits, before + 1);

    final other = openRequestOf('s-agnes');
    await appState.accept(other.id, daniel.id);
    await appState.withdraw(other.id);
    final reopened = appState.requestById(other.id)!;
    expect(reopened.status, RequestStatus.open);
    expect(reopened.volunteerId, isNull);
    expect(reopened.droppedBy, contains(daniel.id));
    expect(appState.openFor(daniel).map((r) => r.id), isNot(contains(other.id)));
  });

  test('backup and no-show alerts fire at the right times', () {
    final now = DateTime(2026, 11, 3, 12);
    final open = HelpRequest(
      id: 'x',
      seniorId: 'demo-senior',
      type: HelpType.scan,
      when: now.add(const Duration(hours: 20)),
      placeName: 'Clinic',
      address: '',
      distanceKm: 1,
      status: RequestStatus.open,
      createdAt: now.subtract(const Duration(days: 3)),
      meetingCode: '1234',
    );
    expect(open.needsBackup(now), isTrue);
    expect(open.needsBackup(now.subtract(const Duration(days: 1))), isFalse);

    final late = open.copyWith(status: RequestStatus.matched, volunteerId: () => 'demo-volunteer');
    // A scan: the volunteer is due at the door 45 minutes before it.
    expect(late.doorTime, late.when.subtract(const Duration(minutes: 45)));
    expect(late.isNoShow(late.doorTime.add(const Duration(minutes: 5))), isFalse);
    expect(late.isNoShow(late.doorTime.add(const Duration(minutes: 15))), isTrue);
    expect(AppState.canCheckIn(late, late.doorTime.subtract(const Duration(hours: 2))), isFalse);
    expect(AppState.canCheckIn(late, late.doorTime.subtract(const Duration(minutes: 30))), isTrue);
  });

  test('requests and accounts survive a restart', () async {
    await appState.signInDemo(UserRole.senior);
    final r = await appState.addRequest(
      seniorId: 'demo-senior',
      type: HelpType.ride,
      when: DateTime.now().add(const Duration(days: 3)),
      placeName: 'Lakeside Hospital',
      address: '1200 Lakeshore Drive',
      needs: {MobilityNeed.car},
    );
    await appState.rate(r.id, 4, 'Kind');

    final restarted = AppState();
    await restarted.init();
    final back = restarted.requestById(r.id)!;
    expect(back.type, HelpType.ride);
    expect(back.needs, {MobilityNeed.car});
    expect(back.rating, 4);
    expect(restarted.currentUser.value?.id, 'demo-senior');
    expect(restarted.userById('demo-volunteer')!.vetting.complete, isTrue);
  });

  test('day labels stay right across a clock change', () {
    // Clocks go back on 1 November 2026 in North America and on 25 October
    // in Europe; both are inside this window wherever the tests run.
    final now = DateTime(2026, 10, 24, 23, 30);
    for (var i = 2; i < 14; i++) {
      final d = DateUtils.addDaysToDate(DateTime(2026, 10, 24), i);
      expect(d.hour, 0);
      expect(formatDay(d, now: now), isNot(anyOf('Today', 'Tomorrow')));
    }
    expect(formatDay(DateTime(2026, 11, 2), now: DateTime(2026, 10, 31, 23)), 'Monday 2 November');
    expect(formatDay(DateTime(2026, 10, 26, 9), now: DateTime(2026, 10, 25, 1)), 'Tomorrow');
  });

  test('the gate holds inside accept, and past requests drop out', () async {
    await appState.createAccount(name: 'Sam Rivera', role: UserRole.volunteer);
    final sam = appState.currentUser.value!;
    final r = openRequestOf('s-harold');
    expect(await appState.accept(r.id, sam.id), isFalse);
    expect(appState.requestById(r.id)!.status, RequestStatus.open);

    final ride = openRequestOf('s-george');
    expect(await appState.accept(ride.id, 'v-priya'), isFalse, reason: 'Priya has no car');
    expect(await appState.accept(ride.id, 'demo-volunteer'), isTrue);
    expect(await appState.accept(ride.id, 'v-tom'), isFalse, reason: 'already taken');

    final past = await appState.addRequest(
      seniorId: 's-ruth',
      type: HelpType.medicine,
      when: DateTime.now().subtract(const Duration(hours: 3)),
      placeName: 'Main Street Pharmacy',
      address: '',
    );
    final daniel = appState.userById('demo-volunteer')!;
    expect(appState.openFor(daniel).map((r) => r.id), isNot(contains(past.id)));
    expect(appState.forSenior('s-ruth', upcoming: true).map((r) => r.id), isNot(contains(past.id)));
    expect(appState.forSenior('s-ruth', upcoming: false).map((r) => r.id), contains(past.id));
  });

  testWidgets('family can\'t see visits once sharing is turned off', (tester) async {
    usePhone(tester);
    await appState.signInDemo(UserRole.senior);
    await appState.updateCurrentUser((u) => u.copyWith(shareWithFamily: false));
    await appState.signInDemo(UserRole.family);
    await tester.pumpWidget(wrap(const Scaffold(body: VisitsPage(seniorId: 'demo-senior'))));
    await tester.pumpAndSettle();
    expect(find.textContaining('turned off sharing'), findsOneWidget);
    expect(find.text('Blood or lab test'), findsNothing);
  });
}
