import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/models.dart';
import 'package:url_launcher/url_launcher.dart';

const _months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const _days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

/// The senior's first name when family is looking, or null when it's the
/// senior themselves, so copy can say "Margaret's door" or "your door".
String? familyView(String seniorId) =>
    appState.currentUser.value?.id == seniorId ? null : appState.userById(seniorId)?.firstName ?? "their";

/// A help type's label, said about [forName] when family is asking.
String helpLabel(HelpType t, {String? forName}) =>
    forName != null && t == HelpType.comeAlong ? "Someone to go with $forName" : t.label;

/// A help type's description, said about [forName] when family is asking.
String helpDescription(HelpType t, {String? forName}) => switch ((t, forName)) {
      (HelpType.checkup, final String n) => "A visit to $n's doctor or clinic",
      (HelpType.ride, final String n) => "Someone drives $n there and back",
      _ => t.description,
    };

/// "your door" for the senior, "Margaret's door" for their family.
String doorOf(String seniorId) => switch (familyView(seniorId)) { null => "your door", final n => "$n's door" };

/// "9:40 am" — lower-case am/pm reads as a word, not a code.
String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return "$hour:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}";
}

/// "Today", "Tomorrow", "Yesterday", or "Thursday 6 November". Spelled out in
/// full: abbreviations are harder to read for older eyes and screen readers.
String formatDay(DateTime d, {DateTime? now}) {
  final n = now ?? DateTime.now();
  // Compared in UTC so a clock change can't make a day 23 or 25 hours long.
  final diff = DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(n.year, n.month, n.day)).inDays;
  if (diff == 0) return "Today";
  if (diff == 1) return "Tomorrow";
  if (diff == -1) return "Yesterday";
  return "${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}";
}

String formatWhen(DateTime d, {DateTime? now}) => "${formatDay(d, now: now)} at ${formatTime(d)}";

/// For the middle of a sentence: "today", "tomorrow" or "on Thursday 6
/// November", plus " at 9:40 am" unless [time] is false.
String whenPhrase(DateTime d, {DateTime? now, bool time = true}) {
  final day = formatDay(d, now: now);
  final phrase = ["Today", "Tomorrow", "Yesterday"].contains(day) ? day.toLowerCase() : "on $day";
  return time ? "$phrase at ${formatTime(d)}" : phrase;
}

/// "by today at 4:00 pm" / "by Thursday 5 November at 9:40 am".
String byPhrase(DateTime d, {DateTime? now}) {
  final p = whenPhrase(d, now: now);
  return p.startsWith("on ") ? "by ${p.substring(3)}" : "by $p";
}

String formatShortDay(DateTime d) => "${_days[d.weekday - 1].substring(0, 3)} ${d.day}";

String formatMonthYear(DateTime d) => "${_months[d.month - 1]} ${d.year}";

/// "45 minutes", "1 hour", "1½ hours".
String formatDuration(int minutes) => minutes < 60
    ? "$minutes minutes"
    : minutes % 60 == 0
        ? "${minutes ~/ 60} hour${minutes == 60 ? '' : 's'}"
        : "${minutes ~/ 60}½ hours";

String formatKm(double km) => "${km.toStringAsFixed(1)} km away";

String greeting(DateTime now) => now.hour < 12
    ? "Good morning"
    : now.hour < 18
        ? "Good afternoon"
        : "Good evening";

IconData iconFor(HelpType type) => switch (type) {
      HelpType.checkup => Icons.medical_services_outlined,
      HelpType.medicine => Icons.medication_outlined,
      HelpType.scan => Icons.monitor_heart_outlined,
      HelpType.labTest => Icons.science_outlined,
      HelpType.ride => Icons.directions_car_outlined,
      HelpType.comeAlong => Icons.people_outline,
    };

/// Opens the phone or messages app. The simulator has neither, so on failure
/// the number is shown instead of failing silently.
Future<void> contact(BuildContext context, String phone, {bool message = false}) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  final ok = await launchUrl(Uri(scheme: message ? 'sms' : 'tel', path: digits)).catchError((_) => false);
  if (ok || !context.mounted) return;
  // A dialog, not a toast: the number stays until it has been read.
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("This phone can't ${message ? 'send messages' : 'make calls'}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Use another phone to reach them on:"),
          const SizedBox(height: 8),
          SelectableText(phone, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
    ),
  );
}
