import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

/// A volunteer as a senior or family member sees them: who they are, what
/// was checked and when, and what other people said.
class VolunteerProfilePage extends StatelessWidget {
  const VolunteerProfilePage({super.key, required this.volunteerId});

  final String volunteerId;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = appState.userById(volunteerId)!;
    final stats = appState.statsFor(v.id);
    final said = [
      for (final r in appState.forVolunteer(v.id, upcoming: false))
        if (r.ratingNote != null) (r.ratingNote!, appState.userById(r.seniorId)?.firstName ?? ""),
    ];
    return Scaffold(
      appBar: const PageAppBar(title: "Volunteer"),
      body: PageBody(
        children: [
          Row(
            children: [
              Avatar(user: v, size: 88),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(v.name, style: AppText.heading(p.ink))),
                    if (v.memberSince != null)
                      Text("Volunteering since ${formatMonthYear(v.memberSince!)}", style: AppText.secondary(p.muted)),
                  ],
                ),
              ),
            ],
          ),
          if (v.bio != null) ...[const SizedBox(height: 20), Text(v.bio!, style: AppText.body(p.ink))],
          const SizedBox(height: 8),
          if (v.languages.isNotEmpty) InfoLine(icon: Icons.translate_rounded, text: "Speaks ${v.languages.join(' and ')}"),
          InfoLine(icon: Icons.directions_car_outlined, text: v.hasCar ? "Has a car and can give rides" : "Doesn't drive. Walks or takes the bus with you"),
          const SizedBox(height: 24),
          StatStrip(items: [
            ("${stats.visits}", stats.visits == 1 ? "visit" : "visits"),
            (stats.rating == null ? "–" : stats.rating!.toStringAsFixed(1), "average rating"),
            ("${stats.people}", stats.people == 1 ? "person helped" : "people helped"),
          ]),
          const SizedBox(height: 28),
          const SectionHeading("What we checked"),
          VettingList(vetting: v.vetting, drives: v.hasCar),
          if (said.isNotEmpty) ...[
            const SizedBox(height: 28),
            const SectionHeading("What people said"),
            for (final (note, who) in said.take(3)) ...[
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("“$note”", style: AppText.body(p.ink)),
                    const SizedBox(height: 6),
                    Text(who, style: AppText.secondary(p.muted)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

/// Each safety check on its own line, with a tick or "Waiting".
class VettingList extends StatelessWidget {
  const VettingList({super.key, required this.vetting, required this.drives});

  final Vetting vetting;
  final bool drives;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = [
      ("Photo ID checked in person", vetting.idChecked, null),
      (
        "Background check",
        vetting.backgroundCheckOn != null,
        vetting.backgroundCheckOn == null ? null : "Passed ${formatDay(vetting.backgroundCheckOn!)} ${vetting.backgroundCheckOn!.year}",
      ),
      ("Two references called", vetting.referencesChecked, null),
      ("Safety and dignity course", vetting.trainingDone, null),
      if (drives) ("Car insurance checked", vetting.carInsured, "Needed to give rides"),
    ];
    return Panel(
      child: Column(
        children: [
          for (final (i, (label, ok, detail)) in items.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            Semantics(
              label: "$label: ${ok ? 'done' : 'waiting'}${detail == null ? '' : '. $detail'}",
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(ok ? Icons.check_circle_rounded : Icons.schedule_rounded, color: ok ? p.accent : p.muted, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppText.body(p.ink)),
                        Text(ok ? (detail ?? "Done") : "Waiting", style: AppText.small(p.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
