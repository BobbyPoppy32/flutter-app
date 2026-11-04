import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/pages/senior_home_page.dart';
import 'package:flutter_app/views/pages/volunteer_profile_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

/// One visit, as the senior or their family sees it.
class VisitDetailPage extends StatelessWidget {
  const VisitDetailPage({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: "Visit"),
      body: ValueListenableBuilder(
        valueListenable: appState.requests,
        builder: (context, _, _) {
          final p = context.palette;
          final r = appState.requestById(requestId)!;
          final now = DateTime.now();
          final volunteer = appState.userById(r.volunteerId);
          final dropped = appState.userById(r.droppedBy.lastOrNull);
          final isFamily = appState.currentUser.value?.id != r.seniorId;
          if (isFamily && appState.userById(r.seniorId)?.shareWithFamily != true) {
            return const PageBody(children: [EmptyState(message: "These visits are private.")]);
          }

          return PageBody(
            children: [
              Align(alignment: Alignment.centerLeft, child: StatusPill(r.status)),
              const SizedBox(height: 14),
              ScreenTitle(r.type.label),
              const SizedBox(height: 6),
              Text(formatWhen(r.when), style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
              InfoLine(icon: Icons.place_outlined, text: [r.placeName, r.address].where((s) => s.isNotEmpty).join(", ")),
              if (r.status.isActive)
                InfoLine(icon: Icons.door_front_door_outlined, text: "Your volunteer comes to ${doorOf(r.seniorId)} at about ${formatTime(r.doorTime)}"),
              if (r.needsBackup(now) || r.isNoShow(now)) ...[const SizedBox(height: 20), AlertPanel(request: r)],
              if (r.status == RequestStatus.open && dropped != null) ...[
                const SizedBox(height: 20),
                Panel(
                  child: Text(
                    "${dropped.firstName} can't make it any more. Other volunteers can see your request again.",
                    style: AppText.secondary(p.ink),
                  ),
                ),
              ],
              if (volunteer != null && r.status != RequestStatus.cancelled) ...[
                const SizedBox(height: 28),
                SectionHeading(r.status == RequestStatus.done ? "Who helped" : "Who's coming"),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      VolunteerRow(
                        volunteer: volunteer,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VolunteerProfilePage(volunteerId: volunteer.id)),
                        ),
                      ),
                      if (r.status.isActive) ...[
                        const SizedBox(height: 16),
                        DoorCode(code: r.meetingCode, name: volunteer.firstName, senior: familyView(r.seniorId)),
                        const SizedBox(height: 16),
                        ContactButtons(name: volunteer.firstName, phone: volunteer.phone ?? ""),
                      ],
                    ],
                  ),
                ),
              ],
              if (r.status == RequestStatus.done) ...[
                const SizedBox(height: 28),
                _RatingSection(request: r, volunteerName: volunteer?.firstName ?? "your volunteer"),
              ],
              const SizedBox(height: 28),
              const SectionHeading("How it's going"),
              if (r.status == RequestStatus.cancelled)
                Text("This request was cancelled.", style: AppText.body(p.muted))
              else
                JourneyTimeline(request: r, volunteerName: volunteer?.firstName),
              if (r.needs.isNotEmpty || r.notes != null) ...[
                const SizedBox(height: 28),
                const SectionHeading("What the volunteer knows"),
                for (final n in r.needs) InfoLine(icon: Icons.check_rounded, text: n.label),
                if (r.notes != null) InfoLine(icon: Icons.notes_rounded, text: r.notes!),
              ],
              if (r.volunteerNote != null) ...[
                const SizedBox(height: 28),
                SectionHeading("Note from ${volunteer?.firstName ?? 'your volunteer'}"),
                Text(r.volunteerNote!, style: AppText.body(p.ink)),
              ],
              if (r.problem != null) ...[
                const SizedBox(height: 20),
                Panel(child: Text("You reported a problem: ${r.problem}. It's saved with this visit.", style: AppText.secondary(p.ink))),
              ],
              const SizedBox(height: 32),
              if (r.volunteerId != null && r.problem == null && r.status != RequestStatus.cancelled) ...[
                SecondaryButton(label: "Report a problem", icon: Icons.flag_outlined, onPressed: () => reportProblem(context, r)),
                const SizedBox(height: 10),
              ],
              if (r.status == RequestStatus.open || r.status == RequestStatus.matched)
                SecondaryButton(
                  label: "Cancel this request",
                  color: p.danger,
                  onPressed: () async {
                    final ok = await confirmAction(
                      context,
                      title: "Cancel this request?",
                      body: volunteer != null
                          ? "${volunteer.firstName} will see that you don't need help ${whenPhrase(r.when)} any more."
                          : "Volunteers will stop seeing it.",
                      confirmLabel: "Yes, cancel it",
                      cancelLabel: "Keep it",
                      danger: true,
                    );
                    if (!ok) return;
                    await appState.cancel(r.id);
                    if (context.mounted) showDone(context, isFamily ? "Request cancelled." : "Your request is cancelled.");
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> reportProblem(BuildContext context, HelpRequest r) async {
  const options = ["The volunteer didn't come", "I didn't feel safe", "Something went wrong with my medicine", "Something else"];
  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final p = context.palette;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(header: true, child: Text("What happened?", style: AppText.heading(p.ink))),
              const SizedBox(height: 8),
              // shortcut: nobody is told about a report yet, so the copy only promises it is saved; name a real coordinator once one exists.
              Text(
                "Your report is saved with this visit. If you need help now, call someone you trust. If you're in danger, call your local emergency number now.",
                style: AppText.secondary(p.ink),
              ),
              const SizedBox(height: 20),
              for (final o in options) ...[
                ChoiceTile(title: o, selected: false, navigates: true, onTap: () => Navigator.pop(context, o)),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              SecondaryButton(label: "Go back", onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
    },
  );
  if (choice == null) return;
  await appState.reportProblem(r.id, choice);
  if (context.mounted) showDone(context, "Thank you. Your report is saved with this visit.");
}

class _RatingSection extends StatefulWidget {
  const _RatingSection({required this.request, required this.volunteerName});

  final HelpRequest request;
  final String volunteerName;

  @override
  State<_RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<_RatingSection> {
  int _stars = 0;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = widget.request;
    if (r.rating != null) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your rating", style: AppText.section(p.ink)),
            const SizedBox(height: 6),
            Semantics(
              label: "${r.rating} out of 5",
              excludeSemantics: true,
              child: StarRating(value: r.rating!, size: 56),
            ),
            if (r.ratingNote != null) ...[const SizedBox(height: 6), Text("“${r.ratingNote}”", style: AppText.body(p.ink))],
          ],
        ),
      );
    }
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("How did it go with ${widget.volunteerName}?", style: AppText.section(p.ink)),
          const SizedBox(height: 8),
          StarRating(value: _stars, onChanged: (v) => setState(() => _stars = v)),
          if (_stars > 0) ...[
            Text("$_stars out of 5: ${StarRating.words[_stars]}", style: AppText.secondary(p.ink)),
            const SizedBox(height: 14),
            TextField(
              controller: _note,
              style: AppText.body(p.ink),
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: "Anything to add? (optional)", alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: "Save my rating",
              onPressed: () async {
                await appState.rate(r.id, _stars, _note.text.trim().isEmpty ? null : _note.text.trim());
                if (context.mounted) showDone(context, "Thank you. ${widget.volunteerName} will see your rating.");
              },
            ),
            if (_stars <= 2) ...[
              const SizedBox(height: 10),
              SecondaryButton(label: "Report a problem", onPressed: () => reportProblem(context, r)),
            ],
          ],
        ],
      ),
    );
  }
}
