import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Volunteer impact, always computed from their requests, never stored.
class VolunteerStats {
  const VolunteerStats({required this.visits, required this.minutes, required this.people, required this.rating, required this.ratings});
  final int visits;
  final int minutes;
  final int people;
  final double? rating;
  final int ratings;
}

/// App/domain state, persisted on-device via SharedPreferences (JSON lists).
/// There is no backend: accounts and requests live only on this device, so
/// every role's demo account shares one set of seeded requests.
class AppState {
  final ValueNotifier<AppUser?> currentUser = ValueNotifier(null);
  final ValueNotifier<List<AppUser>> users = ValueNotifier([]);
  final ValueNotifier<List<HelpRequest>> requests = ValueNotifier([]);

  SharedPreferences? _prefs;
  final _random = Random();

  Future<void> init({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    final usersJson = prefs.getString(KConstants.accountsKey);
    final requestsJson = prefs.getString(KConstants.requestsKey);
    var loaded = false;
    if (usersJson != null && requestsJson != null) {
      try {
        users.value = [for (final e in jsonDecode(usersJson) as List) AppUser.fromJson(e as Map<String, dynamic>)];
        requests.value = [for (final e in jsonDecode(requestsJson) as List) HelpRequest.fromJson(e as Map<String, dynamic>)];
        loaded = true;
      } catch (e) {
        // Unreadable saved data must never stop the app opening: start from
        // the samples again rather than hang on the splash screen.
        debugPrint("Couldn't read saved data, starting fresh: $e");
      }
    }
    if (!loaded) {
      seed(now ?? DateTime.now());
      await _save();
    }

    final sessionId = prefs.getString(KConstants.currentUserIdKey);
    currentUser.value = sessionId == null ? null : userById(sessionId);
  }

  Future<void> _save() async {
    await _prefs?.setString(KConstants.accountsKey, jsonEncode([for (final u in users.value) u.toJson()]));
    await _prefs?.setString(KConstants.requestsKey, jsonEncode([for (final r in requests.value) r.toJson()]));
  }

  // ---- Accounts ------------------------------------------------------------

  AppUser? userById(String? id) {
    for (final u in users.value) {
      if (u.id == id) return u;
    }
    return null;
  }

  static const demoIds = {UserRole.senior: "demo-senior", UserRole.volunteer: "demo-volunteer", UserRole.family: "demo-family"};

  /// Accounts someone created on this device, oldest first (the seeded
  /// demo people are left out).
  List<AppUser> get ownAccounts => users.value.where((u) => u.id.startsWith("u-")).toList();

  Future<void> signIn(AppUser user) async {
    currentUser.value = user;
    selectedPageNotifier.value = 0;
    await _prefs?.setString(KConstants.currentUserIdKey, user.id);
  }

  Future<void> signInDemo(UserRole role) => signIn(userById(demoIds[role])!);

  Future<void> signOut() async {
    currentUser.value = null;
    selectedPageNotifier.value = 0;
    await _prefs?.remove(KConstants.currentUserIdKey);
  }

  /// Creates a local account. A new volunteer starts with no checks done.
  /// A new family member is linked to the demo senior, since there's no
  /// server to look a real relative up on.
  Future<void> createAccount({required String name, required UserRole role, String? phone}) async {
    final user = AppUser(
      id: "u-${DateTime.now().microsecondsSinceEpoch}",
      name: name,
      role: role,
      phone: phone,
      area: "Elm Park",
      memberSince: DateTime.now(),
      seniorId: role == UserRole.family ? demoIds[UserRole.senior] : null,
    );
    users.value = [...users.value, user];
    await _save();
    await signIn(user);
  }

  Future<void> updateCurrentUser(AppUser Function(AppUser) updater) async {
    final user = currentUser.value;
    if (user == null) return;
    final updated = updater(user);
    currentUser.value = updated;
    users.value = [for (final u in users.value) u.id == updated.id ? updated : u];
    await _save();
  }

  /// Puts the sample people and visits back to the first-launch state.
  /// Accounts and requests made on this phone are kept.
  Future<void> resetDemo() async {
    final keep = ownAccounts.toList();
    final keepRequests = requests.value.where((r) => r.id.startsWith("r-")).toList();
    seed(DateTime.now());
    users.value = [...users.value, ...keep];
    requests.value = [...requests.value, ...keepRequests];
    await _save();
    final current = currentUser.value;
    if (current != null) currentUser.value = userById(current.id);
  }

  // ---- Requests ------------------------------------------------------------

  HelpRequest? requestById(String id) {
    for (final r in requests.value) {
      if (r.id == id) return r;
    }
    return null;
  }

  String _code() => (1000 + _random.nextInt(9000)).toString();

  Future<HelpRequest> addRequest({
    required String seniorId,
    required HelpType type,
    required DateTime when,
    required String placeName,
    required String address,
    Set<MobilityNeed> needs = const {},
    String? notes,
  }) async {
    final request = HelpRequest(
      id: "r-${DateTime.now().microsecondsSinceEpoch}",
      seniorId: seniorId,
      type: type,
      when: when,
      durationMinutes: type == HelpType.medicine ? 45 : 90,
      placeName: placeName,
      address: address,
      distanceKm: _seniorDistanceKm[seniorId] ?? 2.0,
      needs: needs,
      notes: notes,
      status: RequestStatus.open,
      createdAt: DateTime.now(),
      meetingCode: _code(),
    );
    requests.value = [...requests.value, request];
    await _save();
    return request;
  }

  Future<void> _update(String id, HelpRequest Function(HelpRequest) updater) async {
    requests.value = [for (final r in requests.value) r.id == id ? updater(r) : r];
    await _save();
  }

  /// Rides need a car whose insurance has been checked.
  static bool canDrive(AppUser volunteer) => volunteer.hasCar && volunteer.vetting.carInsured;

  /// Says yes for [volunteerId]. Checks the gate again here, not only in
  /// the list, so no other path can let an unchecked volunteer through.
  /// Returns false if they may not take this request.
  Future<bool> accept(String id, String volunteerId) async {
    final r = requestById(id);
    final volunteer = userById(volunteerId);
    if (r == null ||
        volunteer == null ||
        !volunteer.vetting.complete ||
        r.status != RequestStatus.open ||
        r.droppedBy.contains(volunteerId) ||
        (r.type == HelpType.ride && !canDrive(volunteer))) {
      return false;
    }
    await _update(id, (r) => r.copyWith(status: RequestStatus.matched, volunteerId: () => volunteerId, confirmedAt: () => null));
    return true;
  }

  /// "I'm still coming", asked the day before: the main guard against
  /// no-shows.
  Future<void> confirmComing(String id) => _update(id, (r) => r.copyWith(confirmedAt: () => DateTime.now()));

  Future<void> reportProblem(String id, String problem) => _update(id, (r) => r.copyWith(problem: problem));

  Future<void> checkIn(String id) =>
      _update(id, (r) => r.copyWith(status: RequestStatus.withYou, checkedInAt: DateTime.now()));

  Future<void> complete(String id, {String? note}) =>
      _update(id, (r) => r.copyWith(status: RequestStatus.done, completedAt: DateTime.now(), volunteerNote: note));

  Future<void> cancel(String id) => _update(id, (r) => r.copyWith(status: RequestStatus.cancelled));

  /// The volunteer can't make it: the request goes back to open so someone
  /// else can take it, and the senior is told why.
  Future<void> withdraw(String id) => _update(
        id,
        (r) => r.copyWith(
          status: RequestStatus.open,
          volunteerId: () => null,
          confirmedAt: () => null,
          droppedBy: [...r.droppedBy, if (r.volunteerId != null) r.volunteerId!],
        ),
      );

  Future<void> rate(String id, int stars, String? note) =>
      _update(id, (r) => r.copyWith(rating: stars, ratingNote: note));

  /// "I'm at the door" opens an hour before the door time and stays open until
  /// it ends, so the senior never sees "with you" the night before.
  static bool canCheckIn(HelpRequest r, DateTime now) =>
      r.status == RequestStatus.matched && now.isAfter(r.doorTime.subtract(const Duration(hours: 1))) && now.isBefore(r.endsAt);

  /// "I'm still coming" is asked from 36 hours before until check-in.
  static bool canConfirm(HelpRequest r, DateTime now) =>
      r.status == RequestStatus.matched &&
      r.confirmedAt == null &&
      now.isAfter(r.when.subtract(const Duration(hours: 36))) &&
      now.isBefore(r.when);

  List<HelpRequest> forSenior(String seniorId, {required bool upcoming}) {
    final now = DateTime.now();
    final list = requests.value.where((r) => r.seniorId == seniorId && r.isUpcoming(now) == upcoming).toList();
    list.sort((a, b) => upcoming ? a.when.compareTo(b.when) : b.when.compareTo(a.when));
    return list;
  }

  /// Open requests this volunteer may see. The vetting gate lives here, not
  /// in the screen: someone whose checks aren't done gets nothing, and rides
  /// are left out for anyone without a checked, insured car.
  List<HelpRequest> openFor(AppUser volunteer) {
    if (!volunteer.vetting.complete) return [];
    final now = DateTime.now();
    final list = requests.value
        .where((r) =>
            r.status == RequestStatus.open &&
            r.when.isAfter(now) &&
            !r.droppedBy.contains(volunteer.id) &&
            (r.type != HelpType.ride || canDrive(volunteer)))
        .toList();
    list.sort((a, b) => a.when.compareTo(b.when));
    return list;
  }

  List<HelpRequest> forVolunteer(String volunteerId, {required bool upcoming}) {
    final now = DateTime.now();
    final list = requests.value
        .where((r) => r.volunteerId == volunteerId && (upcoming ? r.isUpcoming(now) : r.status == RequestStatus.done))
        .toList();
    list.sort((a, b) => upcoming ? a.when.compareTo(b.when) : b.when.compareTo(a.when));
    return list;
  }

  VolunteerStats statsFor(String volunteerId) {
    final done = forVolunteer(volunteerId, upcoming: false);
    final rated = [for (final r in done) if (r.rating != null) r.rating!];
    return VolunteerStats(
      visits: done.length,
      minutes: done.fold(0, (sum, r) => sum + r.durationMinutes),
      people: done.map((r) => r.seniorId).toSet().length,
      rating: rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length,
      ratings: rated.length,
    );
  }

  // ---- Seed data -------------------------------------------------------------

  // shortcut: one distance per senior from the volunteers' shared area
  // (Elm Park); a real build geocodes both addresses.
  static const _seniorDistanceKm = {
    "demo-senior": 1.8,
    "s-harold": 2.4,
    "s-eleanor": 1.1,
    "s-walter": 4.8,
    "s-agnes": 7.5,
    "s-ruth": 3.2,
    "s-george": 9.6,
  };

  /// Writes the first-launch world: the three demo accounts (Margaret, her
  /// daughter Lena and volunteer Daniel), the other people around them, and
  /// requests spread across the past six weeks and the next two.
  @visibleForTesting
  void seed(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int days, int hour, [int minute = 0]) => DateTime(today.year, today.month, today.day + days, hour, minute);

    const checked = Vetting(idChecked: true, referencesChecked: true, trainingDone: true, carInsured: true);
    users.value = [
      const AppUser(
        id: "demo-senior",
        name: "Margaret Chu",
        role: UserRole.senior,
        phone: "(555) 201-4417",
        area: "Elm Park",
        address: "14 Elm Street, Apartment 3",
        emergencyName: "Lena Chu",
        emergencyRelation: "Daughter",
        emergencyPhone: "(555) 201-8830",
        needs: {MobilityNeed.walker, MobilityNeed.hearing},
      ),
      const AppUser(id: "demo-family", name: "Lena Chu", role: UserRole.family, phone: "(555) 201-8830", seniorId: "demo-senior"),
      AppUser(
        id: "demo-volunteer",
        name: "Daniel Okafor",
        role: UserRole.volunteer,
        phone: "(555) 340-1172",
        area: "Elm Park",
        bio: "Retired school librarian. Happy to wait with you and write down what the doctor says.",
        languages: const ["English", "Igbo"],
        hasCar: true,
        memberSince: DateTime(2025, 3, 4),
        vetting: _checkedOn(checked, today.subtract(const Duration(days: 214))),
      ),
      AppUser(
        id: "v-priya",
        name: "Priya Raman",
        role: UserRole.volunteer,
        phone: "(555) 340-2290",
        area: "Elm Park",
        bio: "Nursing student. I take the bus with you, or meet you there.",
        languages: const ["English", "Tamil"],
        memberSince: DateTime(2025, 9, 15),
        vetting: _checkedOn(const Vetting(idChecked: true, referencesChecked: true, trainingDone: true), today.subtract(const Duration(days: 80))),
      ),
      AppUser(
        id: "v-tom",
        name: "Tom Becker",
        role: UserRole.volunteer,
        phone: "(555) 340-5518",
        area: "Northgate",
        bio: "Drove the number 12 bus for thirty years. Patient driver, roomy car.",
        languages: const ["English", "German"],
        hasCar: true,
        memberSince: DateTime(2024, 11, 2),
        vetting: _checkedOn(checked, today.subtract(const Duration(days: 330))),
      ),
      for (final (id, name, phone, address, needs) in const [
        ("s-harold", "Harold Petrov", "(555) 201-3364", "7 Ash Court", <MobilityNeed>{}),
        ("s-eleanor", "Eleanor Wright", "(555) 201-0972", "31 Birch Avenue", {MobilityNeed.arm}),
        ("s-walter", "Walter Nguyen", "(555) 202-4410", "118 Lakeview Road", {MobilityNeed.wheelchair}),
        ("s-agnes", "Agnes Murphy", "(555) 202-7781", "5 Mill Lane, Flat 2", {MobilityNeed.vision}),
        ("s-ruth", "Ruth Adeyemi", "(555) 201-5523", "62 Cedar Street", <MobilityNeed>{}),
        ("s-george", "George Lindqvist", "(555) 203-1186", "9 Northgate Plaza", {MobilityNeed.walker}),
      ])
        AppUser(id: id, name: name, role: UserRole.senior, area: "Elm Park", phone: phone, address: address, needs: needs),
    ];

    var n = 0;
    HelpRequest req(
      String senior,
      HelpType type,
      DateTime when,
      String place,
      String address, {
      RequestStatus status = RequestStatus.open,
      String? volunteer,
      Set<MobilityNeed> needs = const {},
      String? notes,
      int? rating,
      String? ratingNote,
      int minutes = 90,
      List<String> droppedBy = const [],
      DateTime? created,
    }) {
      n++;
      final past = status == RequestStatus.done;
      return HelpRequest(
        id: "seed-$n",
        seniorId: senior,
        type: type,
        when: when,
        durationMinutes: minutes,
        placeName: place,
        address: address,
        distanceKm: _seniorDistanceKm[senior]!,
        needs: needs,
        notes: notes,
        status: status,
        volunteerId: volunteer,
        createdAt: created ?? when.subtract(const Duration(days: 6)),
        checkedInAt: past ? when.subtract(const Duration(minutes: 25)) : null,
        completedAt: past ? when.add(Duration(minutes: minutes)) : null,
        rating: rating,
        ratingNote: ratingNote,
        meetingCode: (4182 + n * 731 % 5000).toString(),
        droppedBy: droppedBy,
      );
    }

    const walkerHearing = {MobilityNeed.walker, MobilityNeed.hearing};
    requests.value = [
      // Margaret's visits.
      req("demo-senior", HelpType.labTest, at(2, 9, 40), "Elm Park Lab", "212 Birch Avenue",
          status: RequestStatus.matched, volunteer: "demo-volunteer", needs: walkerHearing,
          notes: "It's a fasting blood test, so I'll skip breakfast and may be a little slow."),
      req("demo-senior", HelpType.scan, at(9, 14, 15), "St. Anne's Imaging", "88 Harbour Road, 2nd floor",
          needs: walkerHearing, notes: "Ultrasound on my knee. Please come in with me: I don't always hear my name called.",
          droppedBy: const ["v-tom"]),
      // Asked three days ago, due in 18 hours, nobody yet: past its backup
      // deadline, so the alert shows on first launch.
      req("demo-senior", HelpType.medicine, _quarter(now.add(const Duration(hours: 18))), "Main Street Pharmacy", "301 Main Street",
          minutes: 45, created: now.subtract(const Duration(days: 3)), notes: "My heart tablets. The pharmacy has them ready."),
      req("demo-senior", HelpType.checkup, at(-12, 10, 30), "Dr. Lin, Elm Park Family Practice", "40 Cedar Street",
          status: RequestStatus.done, volunteer: "v-priya", needs: walkerHearing, rating: 5,
          ratingNote: "Priya wrote down everything Dr. Lin said."),
      req("demo-senior", HelpType.medicine, at(-26, 15), "Main Street Pharmacy", "301 Main Street",
          status: RequestStatus.done, volunteer: "demo-volunteer", minutes: 45),
      req("demo-senior", HelpType.ride, at(-40, 8, 30), "Lakeside Hospital", "1200 Lakeshore Drive",
          status: RequestStatus.done, volunteer: "v-tom", needs: walkerHearing, rating: 4,
          ratingNote: "On time, very careful driver."),
      req("demo-senior", HelpType.checkup, at(-19, 11), "Riverside Eye Clinic", "9 Mill Lane",
          status: RequestStatus.cancelled, notes: "Clinic moved the appointment."),

      // Open requests from other people nearby.
      req("s-harold", HelpType.medicine, at(1, 11), "Main Street Pharmacy", "301 Main Street", minutes: 45,
          notes: "Two prescriptions, already paid for. The pharmacist knows I'm sending someone."),
      req("s-eleanor", HelpType.checkup, at(3, 10, 30), "Sunview Medical Centre", "17 Sunview Court",
          needs: {MobilityNeed.arm}, notes: "Annual check-up. I'm steady but like an arm on the stairs."),
      req("s-walter", HelpType.scan, at(4, 8, 15), "Lakeside Hospital Imaging", "1200 Lakeshore Drive",
          needs: {MobilityNeed.wheelchair, MobilityNeed.car}, notes: "MRI. My wheelchair folds into a boot."),
      req("s-agnes", HelpType.comeAlong, at(6, 13), "Riverside Eye Clinic", "9 Mill Lane",
          needs: {MobilityNeed.vision}, notes: "Eye drops make me blurry afterwards, so I need help getting home."),
      req("s-ruth", HelpType.labTest, at(1, 15, 30), "Elm Park Lab", "212 Birch Avenue", minutes: 60),
      req("s-george", HelpType.ride, at(5, 9), "Northgate Heart Clinic", "5 Northgate Plaza",
          needs: {MobilityNeed.walker, MobilityNeed.car}),

      // Daniel's other visits: one later today so check-in can be tried,
      // and his history.
      req("s-eleanor", HelpType.checkup, _quarter(now.add(const Duration(minutes: 75))), "Sunview Medical Centre", "17 Sunview Court",
          status: RequestStatus.matched, volunteer: "demo-volunteer", minutes: 60, needs: {MobilityNeed.arm},
          notes: "Blood pressure check. Please ring twice, the bell is quiet."),
      req("s-harold", HelpType.checkup, at(-5, 9), "Sunview Medical Centre", "17 Sunview Court",
          status: RequestStatus.done, volunteer: "demo-volunteer", rating: 5, ratingNote: "Kind and on time."),
      req("s-ruth", HelpType.labTest, at(-9, 8), "Elm Park Lab", "212 Birch Avenue",
          status: RequestStatus.done, volunteer: "demo-volunteer", minutes: 60, rating: 4),
      req("s-walter", HelpType.ride, at(-16, 13, 30), "Lakeside Hospital", "1200 Lakeshore Drive",
          status: RequestStatus.done, volunteer: "demo-volunteer", needs: {MobilityNeed.wheelchair}, rating: 5),
      req("s-eleanor", HelpType.comeAlong, at(-33, 14), "Riverside Eye Clinic", "9 Mill Lane",
          status: RequestStatus.done, volunteer: "demo-volunteer"),
    ];
  }

  static DateTime _quarter(DateTime d) => DateTime(d.year, d.month, d.day, d.hour, d.minute - d.minute % 15);

  static Vetting _checkedOn(Vetting v, DateTime on) => Vetting(
        idChecked: v.idChecked,
        backgroundCheckOn: on,
        referencesChecked: v.referencesChecked,
        trainingDone: v.trainingDone,
        carInsured: v.carInsured,
      );
}

final AppState appState = AppState();
