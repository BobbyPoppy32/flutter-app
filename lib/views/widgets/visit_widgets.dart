import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';

/// The visit as a short journey: asked, confirmed, at your door, done. The
/// app's signature element: the same line the welcome screen draws from
/// home to the clinic.
class JourneyTimeline extends StatelessWidget {
  const JourneyTimeline({super.key, required this.request, this.volunteerName, this.forVolunteer = false});

  final HelpRequest request;
  final String? volunteerName;
  // Told from the volunteer's side: "You said yes", "At Harold's door".
  final bool forVolunteer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = request;
    final who = forVolunteer ? "You" : volunteerName ?? "Your volunteer";
    final senior = appState.userById(r.seniorId)?.firstName ?? "They";
    final steps = [
      (forVolunteer || familyView(r.seniorId) != null ? "$senior asked for help" : "You asked for help", formatWhen(r.createdAt)),
      (
        r.volunteerId == null ? "Finding a volunteer" : "$who said yes",
        r.volunteerId == null
            ? "We'll tell you ${byPhrase(r.backupDeadline)} if nobody has"
            : r.confirmedAt != null
                ? "Confirmed again ${whenPhrase(r.confirmedAt!)}"
                : r.status == RequestStatus.matched
                    ? (forVolunteer ? "You'll confirm the day before" : "They'll confirm the day before")
                    : "",
      ),
      (
        forVolunteer ? "At $senior's door" : "$who at ${doorOf(r.seniorId)}",
        r.checkedInAt != null ? "Arrived at ${formatTime(r.checkedInAt!)}" : "Planned for ${formatWhen(r.doorTime)}",
      ),
      ("Visit done", r.completedAt != null ? formatWhen(r.completedAt!) : ""),
    ];
    final current = switch (r.status) {
      RequestStatus.open => 1,
      RequestStatus.matched => 1,
      RequestStatus.withYou => 2,
      RequestStatus.done => 4,
      RequestStatus.cancelled => -1,
    };
    // A matched visit has completed the "said yes" step.
    final doneUpTo = r.status == RequestStatus.matched ? 2 : current;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _JourneyStep(
            title: steps[i].$1,
            detail: steps[i].$2,
            state: r.status == RequestStatus.cancelled
                ? (i == 0 ? _Step.done : _Step.future)
                : i < doneUpTo
                    ? _Step.done
                    : i == current
                        ? _Step.now
                        : _Step.future,
            last: i == steps.length - 1,
            palette: p,
          ),
      ],
    );
  }
}

enum _Step { done, now, future }

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({required this.title, required this.detail, required this.state, required this.last, required this.palette});

  final String title;
  final String detail;
  final _Step state;
  final bool last;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final marker = switch (state) {
      _Step.done => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, size: 18, color: p.onAccent),
        ),
      _Step.now => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.accent, width: 3)),
          alignment: Alignment.center,
          child: Container(width: 10, height: 10, decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle)),
        ),
      _Step.future => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.border, width: 2)),
        ),
    };
    final stateWord = switch (state) {
      _Step.done => "Done",
      _Step.now => "Now",
      _Step.future => "Not yet",
    };
    return Semantics(
      label: "$stateWord: $title. $detail",
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                marker,
                if (!last)
                  Expanded(child: Container(width: 3, color: state == _Step.done ? p.accent : p.border)),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 18, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body(state == _Step.future ? p.muted : p.ink)
                          .copyWith(fontWeight: state == _Step.now ? FontWeight.w700 : FontWeight.w400),
                    ),
                    if (detail.isNotEmpty) Text(detail, style: AppText.small(p.muted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One visit in a list: what, when, where, status and who. Whole card taps
/// through to the detail.
class VisitCard extends StatelessWidget {
  const VisitCard({super.key, required this.request, required this.onTap, this.forVolunteer = false});

  final HelpRequest request;
  final VoidCallback onTap;
  final bool forVolunteer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = request;
    final other = appState.userById(forVolunteer ? r.seniorId : r.volunteerId);
    final whoLine = forVolunteer
        ? "With ${other?.name ?? 'someone'}"
        : other != null
            ? "With ${other.name}"
            : null;
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(iconFor(r.type), size: AppText.icon(context, 26), color: p.ink)),
              const SizedBox(width: 12),
              Expanded(child: Text(r.type.label, style: AppText.section(p.ink))),
              Icon(Icons.chevron_right_rounded, color: p.muted, size: AppText.icon(context, 28)),
            ],
          ),
          const SizedBox(height: 4),
          InfoLine(icon: Icons.schedule_rounded, text: formatWhen(r.when), strong: true),
          InfoLine(icon: Icons.place_outlined, text: r.placeName),
          if (whoLine != null) InfoLine(icon: Icons.person_outline_rounded, text: whoLine),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: StatusPill(r.status, forVolunteer: forVolunteer)),
        ],
      ),
    );
  }
}

/// Volunteer impact, set as type: three figures with their labels.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final stacked = MediaQuery.textScalerOf(context).scale(18) > 27;
    final cells = [
      for (final (value, label) in items)
        Semantics(
          label: "$value $label",
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                textScaler: AppText.titleScaler(context),
                style: AppText.title(p.accentText).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              Text(label, style: AppText.secondary(p.muted)),
            ],
          ),
        ),
    ];
    return Panel(
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, c) in cells.indexed) ...[if (i > 0) const Divider(height: 28), c],
              ],
            )
          : IntrinsicHeight(
              child: Row(
                children: [
                  for (final (i, c) in cells.indexed) ...[
                    if (i > 0) const VerticalDivider(width: 28),
                    Expanded(child: c),
                  ],
                ],
              ),
            ),
    );
  }
}

/// Call and Message, side by side (stacked at large text). When the senior
/// is hard of hearing, Message comes first.
class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key, required this.name, required this.phone, this.preferText = false});

  final String name;
  final String phone;
  final bool preferText;

  @override
  Widget build(BuildContext context) {
    final call = SecondaryButton(label: "Call $name", icon: Icons.call_outlined, onPressed: () => contact(context, phone));
    final text = SecondaryButton(
      label: "Message $name",
      icon: Icons.chat_bubble_outline_rounded,
      onPressed: () => contact(context, phone, message: true),
    );
    final buttons = preferText ? [text, call] : [call, text];
    return Column(children: [buttons[0], const SizedBox(height: 10), buttons[1]]);
  }
}

/// A bottom sheet that asks before anything that can't be undone, and says
/// who will be told. Resolves true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = "Go back",
  bool danger = false,
}) async {
  final result = await showModalBottomSheet<bool>(
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
              Semantics(header: true, child: Text(title, style: AppText.heading(p.ink))),
              const SizedBox(height: 10),
              Text(body, style: AppText.body(p.ink)),
              const SizedBox(height: 24),
              PrimaryButton(label: confirmLabel, danger: danger, onPressed: () => Navigator.pop(context, true)),
              const SizedBox(height: 10),
              SecondaryButton(label: cancelLabel, onPressed: () => Navigator.pop(context, false)),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// A short confirmation. Replaces any message still showing, so an old one
/// never turns up on the next screen.
void showDone(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  // Long enough for a slow reader, and closable by hand.
  ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 8), showCloseIcon: true));

/// The welcome drawing: home on the left, the clinic on the right, and the
/// route between them drawn on once. Decorative, so hidden from screen
/// readers.
class RouteMotif extends StatefulWidget {
  const RouteMotif({super.key});

  @override
  State<RouteMotif> createState() => _RouteMotifState();
}

class _RouteMotifState extends State<RouteMotif> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    if (WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ExcludeSemantics(
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _RoutePainter(progress: Curves.easeOutCubic.transform(_c.value), ink: p.ink, accent: p.accent, faint: p.border)),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.progress, required this.ink, required this.accent, required this.faint});

  final double progress;
  final Color ink;
  final Color accent;
  final Color faint;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final base = size.height - 18;

    // Ground line.
    canvas.drawLine(Offset(0, base), Offset(size.width, base), Paint()
      ..color = faint
      ..strokeWidth = 2);

    // Home: a small house with a pitched roof and a door.
    const hx = 8.0, hw = 64.0, hh = 46.0;
    final house = Path()
      ..moveTo(hx, base)
      ..lineTo(hx, base - hh)
      ..lineTo(hx + hw / 2, base - hh - 26)
      ..lineTo(hx + hw, base - hh)
      ..lineTo(hx + hw, base);
    canvas.drawPath(house, line);
    canvas.drawRect(Rect.fromLTWH(hx + hw / 2 - 9, base - 26, 18, 26), line);

    // Clinic: a taller flat-roofed block with a cross.
    final cw = 84.0, ch = 84.0, cx = size.width - cw - 8;
    canvas.drawRect(Rect.fromLTWH(cx, base - ch, cw, ch), line);
    final mid = Offset(cx + cw / 2, base - ch + 30);
    canvas.drawLine(mid.translate(-11, 0), mid.translate(11, 0), line..strokeWidth = 4);
    canvas.drawLine(mid.translate(0, -11), mid.translate(0, 11), line);
    line.strokeWidth = 2.5;
    canvas.drawRect(Rect.fromLTWH(cx + cw / 2 - 12, base - 30, 24, 30), line);

    // The route: from the front door, a gentle arc over to the clinic door.
    final start = Offset(hx + hw + 10, base - 6);
    final end = Offset(cx - 10, base - 6);
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx + (end.dx - start.dx) * 0.3, base - 90, start.dx + (end.dx - start.dx) * 0.7, base - 90, end.dx, end.dy);
    final metric = route.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      drawn,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    final dot = metric.getTangentForOffset(metric.length * progress)?.position ?? start;
    canvas.drawCircle(start, 6, Paint()..color = accent);
    canvas.drawCircle(dot, 9, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.progress != progress || old.ink != ink;
}
