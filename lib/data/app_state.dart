import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App/domain state, persisted on-device via SharedPreferences (JSON-encoded
/// lists). There is no backend — accounts, sessions, and requests all live
/// only on this device, but they survive app restarts.
class AppState {
  final ValueNotifier<AppUser?> currentUser = ValueNotifier(null);
  final ValueNotifier<List<HelpRequest>> requests = ValueNotifier([]);

  List<AppUser> _accounts = [];
  SharedPreferences? _prefs;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;

    final accountsJson = prefs.getString(KConstants.AccountsKey);
    if (accountsJson != null) {
      final decoded = jsonDecode(accountsJson) as List;
      _accounts = decoded.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
    }

    final requestsJson = prefs.getString(KConstants.RequestsKey);
    if (requestsJson != null) {
      final decoded = jsonDecode(requestsJson) as List;
      requests.value = decoded.map((e) => HelpRequest.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _seedMockData();
      await _saveRequests();
    }

    final sessionEmail = prefs.getString(KConstants.CurrentUserEmailKey);
    if (sessionEmail != null) {
      currentUser.value = _accounts.cast<AppUser?>().firstWhere(
        (a) => a!.email.toLowerCase() == sessionEmail.toLowerCase(),
        orElse: () => null,
      );
    }
  }

  void _seedMockData() {
    final now = DateTime.now();
    requests.value = [
      HelpRequest(
        id: "seed-1",
        seniorId: "seed-senior-1",
        seniorName: "Eleanor Wright",
        taskType: RequestTaskType.medicalCheckup,
        notes: "Annual checkup with Dr. Lin",
        locationText: "Sunview Medical Centre",
        requestedDateTime: now.add(const Duration(days: 1, hours: 3)),
        status: RequestStatus.open,
        createdAt: now,
      ),
      HelpRequest(
        id: "seed-2",
        seniorId: "seed-senior-2",
        seniorName: "Harold Petrov",
        taskType: RequestTaskType.medicinePickup,
        notes: "Just need a short walk to the pharmacy",
        locationText: "Shoppers Drug Mart, Main St",
        requestedDateTime: now.add(const Duration(days: 2, hours: 1)),
        status: RequestStatus.open,
        createdAt: now,
      ),
      HelpRequest(
        id: "seed-3",
        seniorId: "seed-senior-3",
        seniorName: "Margaret Chu",
        taskType: RequestTaskType.medicalCheckup,
        notes: "Dentist follow-up appointment",
        locationText: "Downtown Dental Clinic",
        requestedDateTime: now.add(const Duration(days: 3, hours: 5)),
        status: RequestStatus.open,
        createdAt: now,
      ),
    ];
  }

  Future<void> _saveRequests() async {
    await _prefs?.setString(
      KConstants.RequestsKey,
      jsonEncode(requests.value.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> _saveAccounts() async {
    await _prefs?.setString(
      KConstants.AccountsKey,
      jsonEncode(_accounts.map((a) => a.toJson()).toList()),
    );
  }

  /// Registers a new local account. Returns null on success, or an error
  /// message if the email is already taken.
  Future<String?> register(AppUser profile) async {
    final exists = _accounts.any((a) => a.email.toLowerCase() == profile.email.toLowerCase());
    if (exists) return "An account with that email already exists.";

    _accounts = [..._accounts, profile];
    await _saveAccounts();
    currentUser.value = profile;
    selectedPageNotifier.value = 0;
    await _prefs?.setString(KConstants.CurrentUserEmailKey, profile.email);
    return null;
  }

  /// Logs in against a previously registered local account. Returns null on
  /// success, or an error message if the credentials don't match.
  Future<String?> login({required String email, required String password}) async {
    final match = _accounts.cast<AppUser?>().firstWhere(
      (a) => a!.email.toLowerCase() == email.toLowerCase() && a.password == password,
      orElse: () => null,
    );
    if (match == null) return "No account found with that email and password.";

    currentUser.value = match;
    selectedPageNotifier.value = 0;
    await _prefs?.setString(KConstants.CurrentUserEmailKey, match.email);
    return null;
  }

  Future<void> logout() async {
    currentUser.value = null;
    selectedPageNotifier.value = 0;
    await _prefs?.remove(KConstants.CurrentUserEmailKey);
  }

  /// Instantly signs in with a fixed local demo account for the given role —
  /// no email/password needed. Creates the account once, then reuses it.
  /// Handy for trying the app without registering first.
  Future<void> loginAsDemo(UserRole role) async {
    final demoId = role == UserRole.senior ? "demo-senior" : "demo-companion";
    var demo = _accounts.cast<AppUser?>().firstWhere((a) => a!.id == demoId, orElse: () => null);

    if (demo == null) {
      demo = role == UserRole.senior
          ? const AppUser(
              id: "demo-senior",
              name: "Jane (Demo)",
              email: "demo.senior@example.com",
              password: "demo",
              role: UserRole.senior,
              age: 78,
              emergencyContactName: "Sam (Son)",
              emergencyContactPhone: "555-010-2020",
            )
          : const AppUser(
              id: "demo-companion",
              name: "Alex (Demo)",
              email: "demo.companion@example.com",
              password: "demo",
              role: UserRole.companion,
              schoolOrOrg: "State University",
              availabilityNote: "Weekday afternoons",
              backgroundCheckStatus: "Verified",
            );
      _accounts = [..._accounts, demo];
      await _saveAccounts();
    }

    currentUser.value = demo;
    selectedPageNotifier.value = 0;
    await _prefs?.setString(KConstants.CurrentUserEmailKey, demo.email);
  }

  Future<void> updateCurrentUser(AppUser Function(AppUser) updater) async {
    final user = currentUser.value;
    if (user == null) return;
    final updated = updater(user);
    currentUser.value = updated;
    _accounts = [
      for (final a in _accounts)
        if (a.id == updated.id) updated else a,
    ];
    await _saveAccounts();
  }

  String _newRequestId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> addRequest({
    required RequestTaskType taskType,
    String? notes,
    required String locationText,
    required DateTime requestedDateTime,
  }) async {
    final senior = currentUser.value;
    if (senior == null) return;
    final request = HelpRequest(
      id: _newRequestId(),
      seniorId: senior.id,
      seniorName: senior.name,
      taskType: taskType,
      notes: notes,
      locationText: locationText,
      requestedDateTime: requestedDateTime,
      status: RequestStatus.open,
      createdAt: DateTime.now(),
    );
    requests.value = [...requests.value, request];
    await _saveRequests();
  }

  Future<void> _updateRequest(String requestId, HelpRequest Function(HelpRequest) updater) async {
    requests.value = [
      for (final r in requests.value)
        if (r.id == requestId) updater(r) else r,
    ];
    await _saveRequests();
  }

  Future<void> acceptRequest(String requestId, {required String companionId, required String companionName}) {
    return _updateRequest(
      requestId,
      (r) => r.copyWith(
        status: RequestStatus.accepted,
        acceptedByCompanionId: companionId,
        acceptedByCompanionName: companionName,
      ),
    );
  }

  Future<void> completeRequest(String requestId) {
    return _updateRequest(requestId, (r) => r.copyWith(status: RequestStatus.completed));
  }

  Future<void> cancelRequest(String requestId) {
    return _updateRequest(requestId, (r) => r.copyWith(status: RequestStatus.cancelled));
  }

  List<HelpRequest> requestsForSenior(String seniorId) {
    final list = requests.value.where((r) => r.seniorId == seniorId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<HelpRequest> openRequestsForCompanions() {
    final list = requests.value.where((r) => r.status == RequestStatus.open).toList();
    list.sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));
    return list;
  }

  List<HelpRequest> commitmentsForCompanion(String companionId) {
    final list = requests.value.where((r) => r.acceptedByCompanionId == companionId).toList();
    list.sort((a, b) => a.requestedDateTime.compareTo(b.requestedDateTime));
    return list;
  }

  /// Every registered companion account, for a senior to browse. Real
  /// registered accounts only — no fabricated ratings or stock photos.
  List<AppUser> allCompanions() {
    final list = _accounts.where((a) => a.role == UserRole.companion).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}

final AppState appState = AppState();
