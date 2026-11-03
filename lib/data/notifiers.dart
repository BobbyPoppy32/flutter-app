//ValueNotifier: hold the data
//ValueListenableBuilder: Listen to the data (font need setstate)

import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);
ValueNotifier<double> textScaleNotifier = ValueNotifier(1.0);
ValueNotifier<bool> medicationRemindersNotifier = ValueNotifier(true);
ValueNotifier<bool> appointmentRemindersNotifier = ValueNotifier(true);
