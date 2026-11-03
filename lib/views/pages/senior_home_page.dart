import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/request_flow_page.dart';
import 'package:flutter_app/views/pages/visit_detail_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

class SeniorHomePage extends StatelessWidget {
  const SeniorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.requests,
      builder: (context, _, _) {
        final p = context.palette;
        final user = appState.currentUser.value!;
        final now = DateTime.now();
        final upcoming = appState.forSenior(user.id, upcoming: true);
        final alerts = upcoming.where((r) => r.needsBackup(now) || r.isNoShow(now)).toList();
        final next = upcoming.where((r) => !alerts.contains(r)).firstOrNull;

        return PageBody(
          children: [
            Semantics(
              header: true,
              child: Text("${greeting(now)}, ${user.firstName}", textScaler: AppText.titleScaler(context), style: AppText.title(p.ink)),
            ),
            const SizedBox(height: 8),
            Text(todayLine(upcoming, now, you: true), style: AppText.body(p.ink)),
            const SizedBox(height: 24),
            PrimaryButton(
              label: "Ask for help",
              icon: Icons.add_rounded,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RequestFlowPage(seniorId: user.id))),
            ),
            for (final r in alerts) ...[const SizedBox(height: 20), AlertPanel(request: r)],
            if (next != null) ...[
              const SizedBox(height: 32),
              const SectionHeading("Your next visit"),
              NextVisitPanel(request: next),
            ],
            if (upcoming.length > alerts.length + 1) ...[
              const SizedBox(height: 32),
              SectionHeading(
                "Also coming up",
                action: "See all",
                onAction: () => selectedPageNotifier.value = 1,
              ),
              for (final (i, r) in upcoming.where((r) => r != next && !alerts.contains(r)).take(2).indexed) ...[
                StaggeredEntrance(index: i, child: VisitCard(request: r, onTap: () => openVisit(context, r))),
                const SizedBox(height: 12),
              ],
            ],
            if (upcoming.isEmpty) ...[
              const SizedBox(height: 24),
              const EmptyState(message: "No visits planned. When you ask for help, it will show up here."),
            ],
            const SizedBox(height: 32),
            EmergencyPanel(user: user),
          ],
        );
      },
    );
  }
}

void openVisit(BuildContext context, HelpRequest r) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => VisitDetailPage(requestId: r.id)));

/// The one sentence under the greeting, built from the data: what happens
/// next, in words.
String todayLine(List<HelpRequest> upcoming, DateTime now, {required bool you, String? name}) {
  final whose = you ? "your" : "$name's";
  if (upcoming.isEmpty) return you ? "Nothing is planned. Ask for help whenever you need it." : "$name has nothing planned.";
  final urgent = upcoming.where((r) => r.needsBackup(now)).firstOrNull;
  if (urgent != null) return "Nobody has said yes to $whose ${urgent.type.noun} yet.";
  final r = upcoming.first;
  final volunteer = appState.userById(r.volunteerId);
  if (volunteer == null) {
    return "We're finding a volunteer for $whose ${r.type.noun} ${whenPhrase(r.when, now: now, time: false)}.";
  }
  return "${volunteer.firstName} is helping with $whose ${r.type.noun} ${whenPhrase(r.when, now: now)}.";
}

/// Nobody has said yes in time, or the volunteer hasn't arrived: say so
/// plainly and put the calls that fix it right there.
class AlertPanel extends StatelessWidget {
  const AlertPanel({super.key, required this.request});

  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = request;
    final senior = appState.userById(r.seniorId)!;
    final volunteer = appState.userById(r.volunteerId);
    final noShow = r.isNoShow(DateTime.now());
    // The senior's backup is their family; the family's backup is the senior.
    final viewerIsFamily = appState.currentUser.value?.id != senior.id;
    final backupName = viewerIsFamily ? senior.firstName : senior.emergencyName?.split(' ').first;
    final backupPhone = viewerIsFamily ? senior.phone : senior.emergencyPhone;
    final title = noShow ? "${volunteer?.firstName ?? 'Your volunteer'} hasn't arrived yet" : "Nobody has said yes yet";
    final body = noShow
        ? "The ${r.type.noun} was at ${formatTime(r.when)}. Give them a call, or call ${backupName ?? 'family'} to make another plan."
        : "The ${r.type.noun} is ${whenPhrase(r.when)}. "
            "We're still asking volunteers, but it's time to make a backup plan.";
    return Panel(
      color: p.open.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, color: p.open.ink, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Semantics(header: true, child: Text(title, style: AppText.section(p.open.ink)))),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: AppText.secondary(p.ink)),
          const SizedBox(height: 16),
          if (noShow && volunteer?.phone != null) ...[
            PrimaryButton(label: "Call ${volunteer!.firstName}", icon: Icons.call_rounded, onPressed: () => contact(context, volunteer.phone!)),
            const SizedBox(height: 10),
          ],
          if (backupPhone != null) ...[
            SecondaryButton(
              label: "Call ${backupName ?? 'family'}",
              icon: Icons.call_outlined,
              onPressed: () => contact(context, backupPhone),
            ),
            const SizedBox(height: 10),
          ] else ...[
            // Someone who lives alone has no family to fall back on yet.
            SecondaryButton(label: "Add someone to call", onPressed: () => selectedPageNotifier.value = 2),
            const SizedBox(height: 10),
          ],
          SecondaryButton(label: "See this visit", onPressed: () => openVisit(context, r)),
        ],
      ),
    );
  }
}

/// The next visit, large: what, when, where, who, and the door code.
class NextVisitPanel extends StatelessWidget {
  const NextVisitPanel({super.key, required this.request});

  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = request;
    final volunteer = appState.userById(r.volunteerId);
    return Panel(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: StatusPill(r.status)),
          const SizedBox(height: 14),
          Text(r.type.label, style: AppText.heading(p.ink)),
          const SizedBox(height: 4),
          Text(formatWhen(r.when), style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
          InfoLine(icon: Icons.place_outlined, text: "${r.placeName}, ${r.address}"),
          if (volunteer != null) ...[
            InfoLine(icon: Icons.door_front_door_outlined, text: "${volunteer.firstName} comes to your door at about ${formatTime(r.doorTime)}", strong: true),
            const SizedBox(height: 18),
            VolunteerRow(volunteer: volunteer),
            const SizedBox(height: 16),
            DoorCode(code: r.meetingCode, name: volunteer.firstName),
            const SizedBox(height: 16),
            ContactButtons(name: volunteer.firstName, phone: volunteer.phone ?? ""),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              "We'll tell you as soon as a volunteer says yes. If nobody has ${byPhrase(r.backupDeadline)}, we'll let you know so there's time for a backup plan.",
              style: AppText.secondary(p.ink),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(onPressed: () => openVisit(context, r), child: const Text("See all the details")),
        ],
      ),
    );
  }
}

/// Four digits the volunteer shows at the door.
class DoorCode extends StatelessWidget {
  const DoorCode({super.key, required this.code, required this.name});

  final String code;
  final String name;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.ground, borderRadius: BorderRadius.circular(AppRadius.row)),
      child: Semantics(
        label: "Door code ${code.split('').join(' ')}. $name will show you this number. If it doesn't match, don't open the door.",
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Door code", style: AppText.secondary(p.muted)),
            Text(
              code.split('').join(' '),
              textScaler: AppText.titleScaler(context),
              style: AppText.title(p.ink).copyWith(fontSize: 34, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 4),
            Text("$name will show you this number. If it doesn't match, don't open the door.", style: AppText.secondary(p.ink)),
          ],
        ),
      ),
    );
  }
}

/// Avatar, name, "Checks passed" and rating; taps through to their profile.
class VolunteerRow extends StatelessWidget {
  const VolunteerRow({super.key, required this.volunteer, this.onTap});

  final AppUser volunteer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final stats = appState.statsFor(volunteer.id);
    final row = Row(
      children: [
        Avatar(user: volunteer),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(volunteer.name, style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
              if (volunteer.vetting.complete) const VettedBadge(),
              if (stats.rating != null)
                Text(
                  "Rated ${stats.rating!.toStringAsFixed(1)} out of 5 by ${stats.ratings} ${stats.ratings == 1 ? 'person' : 'people'}",
                  style: AppText.small(p.muted),
                ),
            ],
          ),
        ),
        if (onTap != null) Icon(Icons.chevron_right_rounded, color: p.muted, size: 28),
      ],
    );
    return onTap == null
        ? row
        : Semantics(
            button: true,
            hint: "Opens ${volunteer.firstName}'s profile",
            child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.row), child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 56), child: row)),
          );
  }
}

/// Who to call when something is wrong, always on the senior's home.
class EmergencyPanel extends StatelessWidget {
  const EmergencyPanel({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasContact = user.emergencyPhone != null && user.emergencyPhone!.isNotEmpty;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text("If something is wrong", style: AppText.section(p.ink))),
          const SizedBox(height: 6),
          Text(
            hasContact
                ? "${user.emergencyName}${user.emergencyRelation == null ? '' : ', your ${user.emergencyRelation!.toLowerCase()}'}, ${user.emergencyPhone}"
                : "You haven't added someone to call yet.",
            style: AppText.secondary(p.ink),
          ),
          const SizedBox(height: 14),
          if (hasContact)
            PrimaryButton(
              label: "Call ${user.emergencyName!.split(' ').first}",
              icon: Icons.call_rounded,
              danger: true,
              onPressed: () => contact(context, user.emergencyPhone!),
            )
          else
            SecondaryButton(label: "Add someone to call", onPressed: () => selectedPageNotifier.value = 2),
          const SizedBox(height: 8),
          Text("In an emergency, call your local emergency number first.", style: AppText.small(p.muted)),
        ],
      ),
    );
  }
}
