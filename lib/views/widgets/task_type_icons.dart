import 'package:flutter/material.dart';
import 'package:flutter_app/data/models.dart';

/// Icon per help-request category, used by the "What do you need help
/// with?" grid/list and anywhere a task type needs a glyph.
IconData iconForTaskType(RequestTaskType type) {
  switch (type) {
    case RequestTaskType.medicalCheckup:
      return Icons.medical_services_outlined;
    case RequestTaskType.medicinePickup:
      return Icons.medication_outlined;
    case RequestTaskType.houseCare:
      return Icons.home_repair_service_outlined;
    case RequestTaskType.qualityFood:
      return Icons.restaurant_outlined;
    case RequestTaskType.transportation:
      return Icons.directions_car_outlined;
    case RequestTaskType.other:
      return Icons.more_horiz_rounded;
  }
}
