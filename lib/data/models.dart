enum UserRole {
  senior,
  companion;

  static UserRole fromName(String name) => UserRole.values.firstWhere((e) => e.name == name);
}

enum RequestTaskType {
  medicalCheckup,
  medicinePickup,
  houseCare,
  qualityFood,
  transportation,
  other;

  static RequestTaskType fromName(String name) => RequestTaskType.values.firstWhere((e) => e.name == name);

  String get label {
    switch (this) {
      case RequestTaskType.medicalCheckup:
        return "Medical Checkup";
      case RequestTaskType.medicinePickup:
        return "Pick Up Medicine";
      case RequestTaskType.houseCare:
        return "House Care";
      case RequestTaskType.qualityFood:
        return "Quality Food";
      case RequestTaskType.transportation:
        return "Transportation";
      case RequestTaskType.other:
        return "Other";
    }
  }
}

enum RequestStatus {
  open,
  accepted,
  completed,
  cancelled;

  static RequestStatus fromName(String name) => RequestStatus.values.firstWhere((e) => e.name == name);

  String get label {
    switch (this) {
      case RequestStatus.open:
        return "Waiting for a helper";
      case RequestStatus.accepted:
        return "Helper confirmed";
      case RequestStatus.completed:
        return "Completed";
      case RequestStatus.cancelled:
        return "Cancelled";
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  // Local-account password, prototype-only (plain text, on-device storage —
  // there is no server, so this never leaves the device). Never shown back
  // to the user after registration.
  final String? password;

  // Senior-only fields.
  final int? age;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? medicalNotes;

  // Companion-only fields.
  final String? schoolOrOrg;
  final String? availabilityNote;
  final String? backgroundCheckStatus;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password,
    this.age,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.medicalNotes,
    this.schoolOrOrg,
    this.availabilityNote,
    this.backgroundCheckStatus,
  });

  AppUser copyWith({
    String? name,
    String? email,
    int? age,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? medicalNotes,
    String? schoolOrOrg,
    String? availabilityNote,
    String? backgroundCheckStatus,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role,
      password: password,
      age: age ?? this.age,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      schoolOrOrg: schoolOrOrg ?? this.schoolOrOrg,
      availabilityNote: availabilityNote ?? this.availabilityNote,
      backgroundCheckStatus: backgroundCheckStatus ?? this.backgroundCheckStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'password': password,
    'age': age,
    'address': address,
    'emergencyContactName': emergencyContactName,
    'emergencyContactPhone': emergencyContactPhone,
    'medicalNotes': medicalNotes,
    'schoolOrOrg': schoolOrOrg,
    'availabilityNote': availabilityNote,
    'backgroundCheckStatus': backgroundCheckStatus,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    role: UserRole.fromName(json['role'] as String),
    password: json['password'] as String?,
    age: json['age'] as int?,
    address: json['address'] as String?,
    emergencyContactName: json['emergencyContactName'] as String?,
    emergencyContactPhone: json['emergencyContactPhone'] as String?,
    medicalNotes: json['medicalNotes'] as String?,
    schoolOrOrg: json['schoolOrOrg'] as String?,
    availabilityNote: json['availabilityNote'] as String?,
    backgroundCheckStatus: json['backgroundCheckStatus'] as String?,
  );
}

class HelpRequest {
  final String id;
  final String seniorId;
  final String seniorName;
  final RequestTaskType taskType;
  final String? notes;
  final String locationText;
  final DateTime requestedDateTime;
  final RequestStatus status;
  final String? acceptedByCompanionId;
  final String? acceptedByCompanionName;
  final DateTime createdAt;

  const HelpRequest({
    required this.id,
    required this.seniorId,
    required this.seniorName,
    required this.taskType,
    this.notes,
    required this.locationText,
    required this.requestedDateTime,
    required this.status,
    this.acceptedByCompanionId,
    this.acceptedByCompanionName,
    required this.createdAt,
  });

  HelpRequest copyWith({
    RequestStatus? status,
    String? acceptedByCompanionId,
    String? acceptedByCompanionName,
  }) {
    return HelpRequest(
      id: id,
      seniorId: seniorId,
      seniorName: seniorName,
      taskType: taskType,
      notes: notes,
      locationText: locationText,
      requestedDateTime: requestedDateTime,
      status: status ?? this.status,
      acceptedByCompanionId: acceptedByCompanionId ?? this.acceptedByCompanionId,
      acceptedByCompanionName: acceptedByCompanionName ?? this.acceptedByCompanionName,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'seniorId': seniorId,
    'seniorName': seniorName,
    'taskType': taskType.name,
    'notes': notes,
    'locationText': locationText,
    'requestedDateTime': requestedDateTime.toIso8601String(),
    'status': status.name,
    'acceptedByCompanionId': acceptedByCompanionId,
    'acceptedByCompanionName': acceptedByCompanionName,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HelpRequest.fromJson(Map<String, dynamic> json) => HelpRequest(
    id: json['id'] as String,
    seniorId: json['seniorId'] as String,
    seniorName: json['seniorName'] as String,
    taskType: RequestTaskType.fromName(json['taskType'] as String),
    notes: json['notes'] as String?,
    locationText: json['locationText'] as String,
    requestedDateTime: DateTime.parse(json['requestedDateTime'] as String),
    status: RequestStatus.fromName(json['status'] as String),
    acceptedByCompanionId: json['acceptedByCompanionId'] as String?,
    acceptedByCompanionName: json['acceptedByCompanionName'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
