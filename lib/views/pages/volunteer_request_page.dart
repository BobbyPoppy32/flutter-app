import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

void openRequestForVolunteer(BuildContext context, HelpRequest r) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerRequestPage(requestId: r.id)));

/// A request as a volunteer sees it. Before they say yes it shows only what
/// they need to decide (the kind of help, when, how far, the needs); the
/// place, the full name, the phone number and the notes come after.
class VolunteerRequestPage extends StatelessWidget {
  const VolunteerRequestPage({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: "Request"),
      body: ValueListenableBuilder(
        valueListenable: appState.requests,
        builder: (context, _, _) {
          final p = context.palette;
          final me = appState.currentUser.value!;
          final r = appState.requestById(requestId)!;
          final senior = appState.userById(r.seniorId)!;
          final mine = r.volunteerId == me.id;
          // The request's needs plus the ones on the senior's profile, so
          // "Good to know" and the hard-of-hearing hint never disagree.
          final needs = {...r.needs, ...senior.needs};

          return PageBody(
            children: [
              Align(alignment: Alignment.centerLeft, child: StatusPill(r.status, forVolunteer: true)),
              const SizedBox(height: 14),
              ScreenTitle(r.type.label),
              const SizedBox(height: 6),
              Text(formatWhen(r.when), style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
              InfoLine(icon: Icons.timelapse_rounded, text: "About ${formatDuration(r.durationMinutes)}"),
              InfoLine(
                icon: Icons.door_front_door_outlined,
                text: r.type == HelpType.medicine
                    ? "Bring it to ${senior.firstName}'s door by about ${formatTime(r.doorTime)}"
                    : "Be at ${senior.firstName}'s door by ${formatTime(r.doorTime)}",
              ),
              const SizedBox(height: 24),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Avatar(user: senior),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mine ? senior.name : senior.shortName, style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
                              Text(mine ? (senior.address ?? senior.area ?? "") : "${senior.area}, ${formatKm(r.distanceKm)}", style: AppText.secondary(p.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (mine && r.status.isActive) ...[
                      if (needs.contains(MobilityNeed.hearing)) ...[
                        const SizedBox(height: 14),
                        Text("${senior.firstName} is hard of hearing. Send a message before you call.", style: AppText.secondary(p.ink)),
                      ],
                      if (senior.phone != null) ...[
                        const SizedBox(height: 14),
                        ContactButtons(
                          name: senior.firstName,
                          phone: senior.phone!,
                          preferText: needs.contains(MobilityNeed.hearing),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (mine && r.status.isActive) ...[
                const SizedBox(height: 16),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Door code", style: AppText.secondary(p.muted)),
                      Text(r.meetingCode.split('').join(' '), textScaler: AppText.titleScaler(context), style: AppText.title(p.ink).copyWith(fontSize: 34)),
                      Text("Show ${senior.firstName} this number when you arrive, so they know it's you.", style: AppText.secondary(p.ink)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const SectionHeading("Good to know"),
              for (final n in needs) InfoLine(icon: Icons.check_rounded, text: n.label),
              if (needs.isEmpty) Text("No mobility needs listed.", style: AppText.secondary(p.muted)),
              if (mine) ...[
                InfoLine(icon: Icons.place_outlined, text: [r.placeName, r.address].where((s) => s.isNotEmpty).join(", ")),
                if (r.notes != null) InfoLine(icon: Icons.notes_rounded, text: "“${r.notes}”"),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InfoLine(
                    icon: Icons.lock_outline_rounded,
                    text: "The place, ${senior.firstName}'s full name, phone number and notes are shared once you say yes.",
                  ),
                ),
              if (mine && r.status != RequestStatus.cancelled) ...[
                const SizedBox(height: 28),
                const SectionHeading("How it's going"),
                JourneyTimeline(request: r, forVolunteer: true),
              ],
              if (r.status == RequestStatus.done && r.rating != null) ...[
                const SizedBox(height: 28),
                SectionHeading("${senior.firstName}'s rating"),
                StarRating(value: r.rating!, size: 56),
                if (r.ratingNote != null) Text("“${r.ratingNote}”", style: AppText.body(p.ink)),
              ],
              const SizedBox(height: 32),
              VolunteerActions(request: r),
            ],
          );
        },
      ),
    );
  }
}

/// The next thing this volunteer can do with [request]: say yes, confirm
/// they're still coming, say they're at the door, finish, or step back.
class VolunteerActions extends StatelessWidget {
  const VolunteerActions({super.key, required this.request});

  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = request;
    final me = appState.currentUser.value!;
    final senior = appState.userById(r.seniorId)!;
    final now = DateTime.now();
    final family = senior.emergencyName != null && senior.shareWithFamily ? " and ${senior.emergencyName!.split(' ').first}" : "";

    if (r.status == RequestStatus.open) {
      if (r.type == HelpType.ride && !AppState.canDrive(me)) {
        return Text("Rides need a car whose insurance we've checked.", style: AppText.body(p.muted));
      }
      return PrimaryButton(
        label: "Say yes to helping",
        onPressed: () async {
          final ok = await confirmAction(
            context,
            title: "Help ${senior.firstName} ${whenPhrase(r.when)}?",
            body: "You're promising to be there. ${senior.firstName}$family will see it's you in the app. "
                "If anything changes, let them know as early as you can.",
            confirmLabel: "Yes, I'll help",
          );
          if (!ok) return;
          final accepted = await appState.accept(r.id, me.id);
          if (!context.mounted) return;
          showDone(context, accepted ? "You're helping ${senior.firstName}. ${senior.firstName}$family can now see it's you." : "Sorry, this request isn't open to you any more.");
        },
      );
    }
    if (r.volunteerId != me.id) return const SizedBox.shrink();

    final dropOut = SecondaryButton(
      label: "I can't make it",
      color: p.danger,
      onPressed: () async {
        final soon = r.when.difference(now).inHours < 24;
        final ok = await confirmAction(
          context,
          title: "Can't make it?",
          body: "${senior.firstName}$family will see that you can't come, and other volunteers can see the request again straight away."
              "${soon ? " It's less than a day away, so please call ${senior.firstName} too." : ""}",
          confirmLabel: "Yes, I can't make it",
          cancelLabel: "I can still go",
          danger: true,
        );
        if (!ok) return;
        await appState.withdraw(r.id);
        if (!context.mounted) return;
        showDone(context, "Thanks for telling us. ${senior.firstName}'s request is open again.");
        // Leave the request's own page, but never pop the home screen this
        // panel is also shown on.
        if (ModalRoute.of(context)?.isFirst == false) Navigator.pop(context);
      },
    );

    switch (r.status) {
      case RequestStatus.matched:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (AppState.canCheckIn(r, now))
              PrimaryButton(
                label: "I'm at the door",
                icon: Icons.door_front_door_outlined,
                onPressed: () async {
                  await appState.checkIn(r.id);
                  if (context.mounted) showDone(context, "${senior.firstName} can see you've arrived.");
                },
              )
            else if (AppState.canConfirm(r, now))
              PrimaryButton(
                label: "I'm still coming",
                icon: Icons.thumb_up_alt_outlined,
                onPressed: () async {
                  await appState.confirmComing(r.id);
                  if (context.mounted) showDone(context, "Thanks. ${senior.firstName} can see you're still coming.");
                },
              )
            else
              Text(
                r.confirmedAt != null
                    ? "You've confirmed. \"I'm at the door\" appears an hour before."
                    : "The day before, come back here to confirm you're still coming.",
                style: AppText.secondary(p.muted),
              ),
            const SizedBox(height: 10),
            dropOut,
          ],
        );
      case RequestStatus.withYou:
        return PrimaryButton(
          label: "Visit done",
          icon: Icons.done_all_rounded,
          onPressed: () => _finish(context, r, senior),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _finish(BuildContext context, HelpRequest r, AppUser senior) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FinishSheet(
        question: r.type == HelpType.medicine ? "Has ${senior.firstName} got the medicine?" : "Is ${senior.firstName} home safely?",
        seniorName: senior.firstName,
      ),
    );
    if (note == null) return;
    await appState.complete(r.id, note: note.isEmpty ? null : note);
    if (context.mounted) showDone(context, "Thank you for helping ${senior.firstName}.");
  }
}

/// "Is Eleanor home safely?" Returns the note (maybe empty) when done, or
/// null for "Not yet". Owns its text controller so it outlives the sheet's
/// closing animation.
class _FinishSheet extends StatefulWidget {
  const _FinishSheet({required this.question, required this.seniorName});

  final String question;
  final String seniorName;

  @override
  State<_FinishSheet> createState() => _FinishSheetState();
}

class _FinishSheetState extends State<_FinishSheet> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(header: true, child: Text(widget.question, style: AppText.heading(p.ink))),
              const SizedBox(height: 8),
              Text(
                "Leave a short note for ${widget.seniorName}, like what the doctor said or when to go back.",
                style: AppText.secondary(p.ink),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                style: AppText.body(p.ink),
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: "Note (optional)", alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: "Yes, visit done", onPressed: () => Navigator.pop(context, _note.text.trim())),
              const SizedBox(height: 10),
              SecondaryButton(label: "Not yet", onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
