enum UserRole {
  senior,
  volunteer,
  family;

  static UserRole fromName(String name) => UserRole.values.firstWhere((e) => e.name == name);
}

/// The six kinds of help, worded the way a senior would say them.
enum HelpType {
  checkup("Doctor's check-up", "A visit to your doctor or clinic", "check-up"),
  medicine("Pick up medicine", "Collect a prescription from the pharmacy", "medicine pickup"),
  scan("Scan or X-ray", "Imaging such as an X-ray, ultrasound or MRI", "scan"),
  labTest("Blood or lab test", "A blood draw or other test at a lab", "lab test"),
  ride("Ride to an appointment", "Someone drives you there and back", "ride"),
  comeAlong("Someone to come with me", "Company and an extra pair of ears", "appointment");

  const HelpType(this.label, this.description, this.noun);
  final String label;
  final String description;
  // For the middle of a sentence: "your medicine pickup tomorrow".
  final String noun;

  static HelpType fromName(String name) => HelpType.values.firstWhere((e) => e.name == name);
}

enum RequestStatus {
  open,
  matched,
  withYou,
  done,
  cancelled;

  static RequestStatus fromName(String name) => RequestStatus.values.firstWhere((e) => e.name == name);

  bool get isActive => this == open || this == matched || this == withYou;

  String get seniorLabel => switch (this) {
        open => "Finding a volunteer",
        matched => "Volunteer confirmed",
        withYou => "Volunteer is with you",
        done => "Done",
        cancelled => "Cancelled",
      };

  String get volunteerLabel => switch (this) {
        open => "Open",
        matched => "You're booked",
        withYou => "Checked in",
        done => "Completed",
        cancelled => "Cancelled",
      };
}

enum MobilityNeed {
  walker("Uses a walker or cane"),
  wheelchair("Uses a wheelchair"),
  arm("Needs an arm to hold"),
  car("Needs help getting into a car"),
  hearing("Hard of hearing"),
  vision("Low vision");

  const MobilityNeed(this.label);
  final String label;

  static MobilityNeed fromName(String name) => MobilityNeed.values.firstWhere((e) => e.name == name);
}

/// A volunteer's safety checks. Until every one has passed, the volunteer
/// can't see or accept any request.
class Vetting {
  const Vetting({
    this.idChecked = false,
    this.backgroundCheckOn,
    this.referencesChecked = false,
    this.trainingDone = false,
    this.carInsured = false,
  });

  final bool idChecked;
  final DateTime? backgroundCheckOn;
  final bool referencesChecked;
  final bool trainingDone;
  // Only needed to accept rides.
  final bool carInsured;

  bool get complete => idChecked && backgroundCheckOn != null && referencesChecked && trainingDone;
  int get passed => [idChecked, backgroundCheckOn != null, referencesChecked, trainingDone].where((c) => c).length;

  Map<String, dynamic> toJson() => {
        'idChecked': idChecked,
        'backgroundCheckOn': backgroundCheckOn?.toIso8601String(),
        'referencesChecked': referencesChecked,
        'trainingDone': trainingDone,
        'carInsured': carInsured,
      };

  factory Vetting.fromJson(Map<String, dynamic>? json) => json == null
      ? const Vetting()
      : Vetting(
          idChecked: json['idChecked'] as bool? ?? false,
          backgroundCheckOn: json['backgroundCheckOn'] == null ? null : DateTime.parse(json['backgroundCheckOn'] as String),
          referencesChecked: json['referencesChecked'] as bool? ?? false,
          trainingDone: json['trainingDone'] as bool? ?? false,
          carInsured: json['carInsured'] as bool? ?? false,
        );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.area,
    this.address,
    this.emergencyName,
    this.emergencyRelation,
    this.emergencyPhone,
    this.needs = const {},
    this.shareWithFamily = true,
    this.seniorId,
    this.bio,
    this.languages = const [],
    this.hasCar = false,
    this.memberSince,
    this.vetting = const Vetting(),
  });

  final String id;
  final String name;
  final UserRole role;
  final String? phone;
  final String? area;
  // Senior: home, where volunteers meet them.
  final String? address;

  // Senior: who to call in an emergency, and the needs pre-filled on every
  // new request.
  final String? emergencyName;
  final String? emergencyRelation;
  final String? emergencyPhone;
  final Set<MobilityNeed> needs;
  // Senior: whether their family contact can follow their visits.
  final bool shareWithFamily;

  // Family: which senior they look after.
  final String? seniorId;

  // Volunteer.
  final String? bio;
  final List<String> languages;
  final bool hasCar;
  final DateTime? memberSince;
  final Vetting vetting;

  String get firstName => name.split(' ').first;

  /// "Margaret C." — what a volunteer sees before they accept a request.
  String get shortName {
    final parts = name.split(' ');
    return parts.length > 1 ? "${parts.first} ${parts.last[0]}." : name;
  }

  /// Text fields: null keeps the old value, an empty string clears it.
  AppUser copyWith({
    String? name,
    String? phone,
    String? area,
    String? address,
    String? emergencyName,
    String? emergencyRelation,
    String? emergencyPhone,
    Set<MobilityNeed>? needs,
    bool? shareWithFamily,
    Vetting? vetting,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      role: role,
      phone: _text(phone, this.phone),
      area: _text(area, this.area),
      address: _text(address, this.address),
      emergencyName: _text(emergencyName, this.emergencyName),
      emergencyRelation: _text(emergencyRelation, this.emergencyRelation),
      emergencyPhone: _text(emergencyPhone, this.emergencyPhone),
      needs: needs ?? this.needs,
      shareWithFamily: shareWithFamily ?? this.shareWithFamily,
      seniorId: seniorId,
      bio: bio,
      languages: languages,
      hasCar: hasCar,
      memberSince: memberSince,
      vetting: vetting ?? this.vetting,
    );
  }

  static String? _text(String? next, String? old) => next == null ? old : (next.isEmpty ? null : next);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'phone': phone,
        'area': area,
        'address': address,
        'emergencyName': emergencyName,
        'emergencyRelation': emergencyRelation,
        'emergencyPhone': emergencyPhone,
        'needs': needs.map((n) => n.name).toList(),
        'shareWithFamily': shareWithFamily,
        'seniorId': seniorId,
        'bio': bio,
        'languages': languages,
        'hasCar': hasCar,
        'memberSince': memberSince?.toIso8601String(),
        'vetting': vetting.toJson(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        role: UserRole.fromName(json['role'] as String),
        phone: json['phone'] as String?,
        area: json['area'] as String?,
        address: json['address'] as String?,
        emergencyName: json['emergencyName'] as String?,
        emergencyRelation: json['emergencyRelation'] as String?,
        emergencyPhone: json['emergencyPhone'] as String?,
        needs: {for (final n in (json['needs'] as List? ?? [])) MobilityNeed.fromName(n as String)},
        shareWithFamily: json['shareWithFamily'] as bool? ?? true,
        seniorId: json['seniorId'] as String?,
        bio: json['bio'] as String?,
        languages: [for (final l in (json['languages'] as List? ?? [])) l as String],
        hasCar: json['hasCar'] as bool? ?? false,
        memberSince: json['memberSince'] == null ? null : DateTime.parse(json['memberSince'] as String),
        vetting: Vetting.fromJson(json['vetting'] as Map<String, dynamic>?),
      );
}

class HelpRequest {
  const HelpRequest({
    required this.id,
    required this.seniorId,
    required this.type,
    required this.when,
    required this.placeName,
    required this.address,
    required this.distanceKm,
    required this.status,
    required this.createdAt,
    required this.meetingCode,
    this.durationMinutes = 90,
    this.needs = const {},
    this.notes,
    this.volunteerId,
    this.confirmedAt,
    this.problem,
    this.checkedInAt,
    this.completedAt,
    this.rating,
    this.ratingNote,
    this.volunteerNote,
    this.droppedBy = const [],
  });

  final String id;
  final String seniorId;
  final HelpType type;
  final DateTime when;
  final int durationMinutes;
  final String placeName;
  final String address;
  // Distance from the volunteer's area. shortcut: seeded per senior, not
  // geocoded; a real build computes it from both addresses on the server.
  final double distanceKm;
  final Set<MobilityNeed> needs;
  final String? notes;
  final RequestStatus status;
  final String? volunteerId;
  final DateTime createdAt;
  // The volunteer said "I'm still coming" the day before.
  final DateTime? confirmedAt;
  // A problem the senior or family reported about this visit.
  final String? problem;
  final DateTime? checkedInAt;
  final DateTime? completedAt;
  final int? rating;
  final String? ratingNote;
  final String? volunteerNote;
  // Four digits the volunteer shows at the door so the senior knows it's
  // really them.
  final String meetingCode;
  // Volunteers who said yes and later couldn't make it.
  final List<String> droppedBy;

  DateTime get endsAt => when.add(Duration(minutes: durationMinutes));

  /// When the volunteer is at the senior's door: 45 minutes before an
  /// appointment, or about half an hour after collecting from the pharmacy.
  DateTime get doorTime => doorTimeFor(type, when);

  static DateTime doorTimeFor(HelpType type, DateTime when) =>
      type == HelpType.medicine ? when.add(const Duration(minutes: 30)) : when.subtract(const Duration(minutes: 45));

  /// When we warn the senior and their family if nobody has said yes: a day
  /// before, or halfway to the visit for short-notice requests. Rounded to a
  /// quarter hour so it reads as a time people use, and never in the night:
  /// an overnight deadline moves to 8 pm the evening before, or 8 am if that
  /// is already past.
  DateTime get backupDeadline {
    final dayBefore = when.subtract(const Duration(hours: 24));
    var d = dayBefore.isAfter(createdAt) ? dayBefore : createdAt.add(when.difference(createdAt) ~/ 2);
    d = DateTime(d.year, d.month, d.day, d.hour, d.minute - d.minute % 15);
    if (d.hour >= 21 || d.hour < 8) {
      final evening = DateTime(d.year, d.month, d.day - (d.hour < 8 ? 1 : 0), 20);
      final morning = DateTime(d.year, d.month, d.day + (d.hour >= 21 ? 1 : 0), 8);
      if (evening.isAfter(createdAt)) {
        d = evening;
      } else if (morning.isBefore(when)) {
        d = morning;
      }
    }
    return d;
  }

  /// Still ahead: open or booked and not yet over, or under way (a visit
  /// in progress stays here until the volunteer marks it done).
  bool isUpcoming(DateTime now) => status == RequestStatus.withYou || (status.isActive && endsAt.isAfter(now));

  /// Nobody has said yes and the backup deadline has passed: time for the
  /// senior or family to make another plan.
  bool needsBackup(DateTime now) => status == RequestStatus.open && now.isAfter(backupDeadline) && now.isBefore(when);

  /// The volunteer is 10+ minutes late at the door and hasn't said they're there.
  bool isNoShow(DateTime now) =>
      status == RequestStatus.matched && now.isAfter(doorTime.add(const Duration(minutes: 10))) && now.isBefore(endsAt);

  HelpRequest copyWith({
    RequestStatus? status,
    String? Function()? volunteerId,
    DateTime? Function()? confirmedAt,
    String? problem,
    DateTime? checkedInAt,
    DateTime? completedAt,
    int? rating,
    String? ratingNote,
    String? volunteerNote,
    List<String>? droppedBy,
  }) {
    return HelpRequest(
      id: id,
      seniorId: seniorId,
      type: type,
      when: when,
      durationMinutes: durationMinutes,
      placeName: placeName,
      address: address,
      distanceKm: distanceKm,
      needs: needs,
      notes: notes,
      status: status ?? this.status,
      volunteerId: volunteerId == null ? this.volunteerId : volunteerId(),
      createdAt: createdAt,
      confirmedAt: confirmedAt == null ? this.confirmedAt : confirmedAt(),
      problem: problem ?? this.problem,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
      ratingNote: ratingNote ?? this.ratingNote,
      volunteerNote: volunteerNote ?? this.volunteerNote,
      meetingCode: meetingCode,
      droppedBy: droppedBy ?? this.droppedBy,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seniorId': seniorId,
        'type': type.name,
        'when': when.toIso8601String(),
        'durationMinutes': durationMinutes,
        'placeName': placeName,
        'address': address,
        'distanceKm': distanceKm,
        'needs': needs.map((n) => n.name).toList(),
        'notes': notes,
        'status': status.name,
        'volunteerId': volunteerId,
        'createdAt': createdAt.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
        'problem': problem,
        'checkedInAt': checkedInAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'rating': rating,
        'ratingNote': ratingNote,
        'volunteerNote': volunteerNote,
        'meetingCode': meetingCode,
        'droppedBy': droppedBy,
      };

  static DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);

  factory HelpRequest.fromJson(Map<String, dynamic> json) => HelpRequest(
        id: json['id'] as String,
        seniorId: json['seniorId'] as String,
        type: HelpType.fromName(json['type'] as String),
        when: DateTime.parse(json['when'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 90,
        placeName: json['placeName'] as String,
        address: json['address'] as String,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        needs: {for (final n in (json['needs'] as List? ?? [])) MobilityNeed.fromName(n as String)},
        notes: json['notes'] as String?,
        status: RequestStatus.fromName(json['status'] as String),
        volunteerId: json['volunteerId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        confirmedAt: _date(json['confirmedAt']),
        problem: json['problem'] as String?,
        checkedInAt: _date(json['checkedInAt']),
        completedAt: _date(json['completedAt']),
        rating: json['rating'] as int?,
        ratingNote: json['ratingNote'] as String?,
        volunteerNote: json['volunteerNote'] as String?,
        meetingCode: json['meetingCode'] as String,
        droppedBy: [for (final d in (json['droppedBy'] as List? ?? [])) d as String],
      );
}
