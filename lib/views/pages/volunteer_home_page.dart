import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/volunteer_request_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

class VolunteerHomePage extends StatelessWidget {
  const VolunteerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.requests,
      builder: (context, _, _) {
        final p = context.palette;
        final me = appState.currentUser.value!;
        final now = DateTime.now();
        final upcoming = appState.forVolunteer(me.id, upcoming: true);
        final next = upcoming.firstOrNull;
        final nextSenior = appState.userById(next?.seniorId);
        final stats = appState.statsFor(me.id);
        final open = appState.openFor(me).length;
        final hours = stats.minutes / 60;

        return PageBody(
          children: [
            Semantics(header: true, child: Text("${greeting(now)}, ${me.firstName}", textScaler: AppText.titleScaler(context), style: AppText.title(p.ink))),
            const SizedBox(height: 8),
            Text(
              !me.vetting.complete
                  ? "Thanks for signing up. ${me.vetting.passed} of 4 safety checks are done."
                  : next == null
                      ? "You have no visits planned."
                      : "Be at ${nextSenior!.firstName}'s door ${whenPhrase(next.doorTime, now: now)}.",
              style: AppText.body(p.ink),
            ),
            if (next != null) ...[
              const SizedBox(height: 28),
              const SectionHeading("Your next visit"),
              Panel(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: StatusPill(next.status, forVolunteer: true)),
                    const SizedBox(height: 14),
                    Text(next.type.label, style: AppText.heading(p.ink)),
                    const SizedBox(height: 4),
                    Text(formatWhen(next.when), style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
                    InfoLine(icon: Icons.person_outline_rounded, text: nextSenior!.name),
                    InfoLine(icon: Icons.place_outlined, text: "From ${nextSenior.address ?? nextSenior.area} to ${next.placeName}"),
                    const SizedBox(height: 18),
                    VolunteerActions(request: next),
                    const SizedBox(height: 4),
                    TextButton(onPressed: () => openRequestForVolunteer(context, next), child: const Text("See all the details")),
                  ],
                ),
              ),
            ],
            if (upcoming.length > 1) ...[
              const SizedBox(height: 28),
              SectionHeading("Also coming up", action: "See all", onAction: () => selectedPageNotifier.value = 2),
              for (final (i, r) in upcoming.skip(1).take(2).indexed) ...[
                StaggeredEntrance(
                  index: i,
                  child: VisitCard(request: r, forVolunteer: true, onTap: () => openRequestForVolunteer(context, r)),
                ),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 28),
            Panel(
              color: p.accentTint,
              onTap: () => selectedPageNotifier.value = 1,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      !me.vetting.complete
                          ? "Requests appear here once your checks are done."
                          : open == 0
                              ? "Nobody near you needs help right now."
                              : "$open open ${open == 1 ? 'request' : 'requests'} near you",
                      style: AppText.section(p.ink),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.ink, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SectionHeading("What you've given"),
            StatStrip(items: [
              ("${stats.visits}", stats.visits == 1 ? "visit" : "visits"),
              (hours == hours.roundToDouble() ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1), "hours"),
              ("${stats.people}", stats.people == 1 ? "person" : "people"),
            ]),
            if (stats.rating != null) ...[
              const SizedBox(height: 10),
              Text(
                "People rated your visits ${stats.rating!.toStringAsFixed(1)} out of 5 on average.",
                style: AppText.secondary(p.muted),
              ),
            ],
          ],
        );
      },
    );
  }
}
