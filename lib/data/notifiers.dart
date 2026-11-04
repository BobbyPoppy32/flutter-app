// ValueNotifier holds the data; ValueListenableBuilder rebuilds on change.

import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
ValueNotifier<double> textScaleNotifier = ValueNotifier(1.0);

/// Reads the saved display settings before the first frame, so the app
/// never flashes in the wrong theme or text size.
Future<void> loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool(KConstants.themeModeKey) ?? false;
  textScaleNotifier.value = prefs.getDouble(KConstants.textScaleKey) ?? 1.0;
}

Future<void> saveSetting(String key, Object value) async {
  final prefs = await SharedPreferences.getInstance();
  if (value is bool) await prefs.setBool(key, value);
  if (value is double) await prefs.setDouble(key, value);
}
