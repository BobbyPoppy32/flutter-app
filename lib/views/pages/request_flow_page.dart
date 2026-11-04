import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/pages/visit_detail_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

/// Asking for help, one question per screen: what, when, where, anything
/// we should know, then a summary to check. Answers are kept when going
/// back, and "Change" on the summary returns straight to the summary.
class RequestFlowPage extends StatefulWidget {
  const RequestFlowPage({super.key, required this.seniorId, this.now});

  final String seniorId;
  // For tests: pins "today" so the day choices are predictable.
  final DateTime? now;

  @override
  State<RequestFlowPage> createState() => _RequestFlowPageState();
}

class _RequestFlowPageState extends State<RequestFlowPage> {
  static const _steps = 5;
  late final AppUser senior = appState.userById(widget.seniorId)!;
  late final DateTime _now = widget.now ?? DateTime.now();

  int _step = 0;
  bool _fromSummary = false;
  bool _sending = false;
  String? _error;

  HelpType? _type;
  DateTime? _day;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _place = TextEditingController();
  final _address = TextEditingController();
  late Set<MobilityNeed> _needs = {...senior.needs};
  final _notes = TextEditingController();

  @override
  void dispose() {
    _place.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime? get _when => _day == null ? null : DateTime(_day!.year, _day!.month, _day!.day, _time.hour, _time.minute);

  bool get _forSomeoneElse => appState.currentUser.value?.id != senior.id;
  // On the step line rather than beside Back, so it can wrap at large text.
  String get _forLine => _forSomeoneElse ? " · For ${senior.firstName}" : "";

  String? _problem() => switch (_step) {
    0 when _type == null => "Please choose what you need help with.",
    1 when _day == null => "Please choose a day.",
    1 when !_when!.isAfter(widget.now ?? DateTime.now()) => "That time has already passed. Please choose a later time.",
    2 when _place.text.trim().isEmpty => "Please write where you're going.",
    _ => null,
  };

  void _next() {
    final problem = _problem();
    setState(() => _error = problem);
    if (problem != null) {
      _announce(problem);
      return;
    }
    _goTo(_fromSummary ? _steps - 1 : _step + 1);
  }

  /// Moves to [step] at the top of the page (the body is keyed by step, so
  /// it starts scrolled up) and tells VoiceOver where it is now.
  void _goTo(int step, {bool fromSummary = false}) {
    setState(() {
      _step = step;
      _fromSummary = fromSummary;
      _error = null;
    });
    _announce("Step ${step + 1} of $_steps. ${_titles[step]}");
  }

  void _announce(String message) => SemanticsService.sendAnnouncement(View.of(context), message, Directionality.of(context));

  List<String> get _titles => [
    _forSomeoneElse ? "What does ${senior.firstName} need help with?" : "What do you need help with?",
    "When is it?",
    "Where are you going?",
    "Anything we should know?",
    "Check and send",
  ];

  Future<void> _back() async {
    if (_step > 0) {
      _goTo(_step - 1);
      return;
    }
    if (await _confirmLeave() && mounted) Navigator.pop(context);
  }

  Future<bool> _confirmLeave() async {
    if (_type == null) return true;
    return confirmAction(
      context,
      title: "Stop asking for help?",
      body: "What you've filled in so far won't be saved.",
      confirmLabel: "Yes, stop",
      cancelLabel: "Keep going",
    );
  }

  void _change(int step) => _goTo(step, fromSummary: true);

  Future<void> _send() async {
    if (_sending) return;
    // The flow may have been left open for a while: check the time again.
    if (!_when!.isAfter(widget.now ?? DateTime.now())) {
      setState(() {
        _step = 1;
        _error = "That time has already passed. Please choose a later time.";
      });
      return;
    }
    setState(() => _sending = true);
    final request = await appState.addRequest(
      seniorId: senior.id,
      type: _type!,
      when: _when!,
      placeName: _place.text.trim(),
      address: _address.text.trim(),
      needs: _needs,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RequestSentPage(requestId: request.id)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final titles = _titles;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _back,
                      icon: Icon(Icons.arrow_back_rounded, size: AppText.icon(context, 24)),
                      label: const Text("Back"),
                      style: TextButton.styleFrom(foregroundColor: p.ink),
                    ),
                  ],
                ),
              ),
              Expanded(
                // Each step settles in with a short fade and lift; none with
                // Reduce Motion on.
                child: AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.standard),
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  ),
                  layoutBuilder: (current, previous) => Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
                  child: PageBody(
                    key: ValueKey(_step),
                    children: [
                      Semantics(
                        label: "Step ${_step + 1} of $_steps$_forLine",
                        excludeSemantics: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Step ${_step + 1} of $_steps$_forLine", style: AppText.secondary(p.muted)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                for (var i = 0; i < _steps; i++) ...[
                                  if (i > 0) const SizedBox(width: 4),
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration: AppMotion.of(context, AppMotion.standard),
                                      curve: AppMotion.enter,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: i <= _step ? p.accent : p.border,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ScreenTitle(titles[_step]),
                      const SizedBox(height: 20),
                      ...switch (_step) {
                        0 => _whatStep(),
                        1 => _whenStep(p),
                        2 => _whereStep(p),
                        3 => _notesStep(p),
                        _ => _summaryStep(p),
                      },
                      if (_error != null && _step != 2) ...[
                        const SizedBox(height: 16),
                        Semantics(
                          liveRegion: true,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline_rounded, color: p.danger, size: AppText.icon(context, 24)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: AppText.body(p.danger))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Pinned so nobody has to discover that the page scrolls to move on.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: p.ground,
                  border: Border(top: BorderSide(color: p.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: _step < _steps - 1
                      ? PrimaryButton(label: _fromSummary ? "Save and go back to the summary" : "Next", onPressed: _next)
                      : PrimaryButton(label: "Send my request", icon: Icons.send_rounded, onPressed: _sending ? null : _send),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _whatStep() => [
    for (final t in HelpType.values) ...[
      ChoiceTile(
        icon: iconFor(t),
        title: helpLabel(t, forName: _forSomeoneElse ? senior.firstName : null),
        subtitle: helpDescription(t, forName: _forSomeoneElse ? senior.firstName : null),
        selected: _type == t,
        onTap: () => setState(() {
          _type = t;
          _error = null;
        }),
      ),
      const SizedBox(height: 10),
    ],
  ];

  static const _quickTimes = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
  ];

  List<Widget> _whenStep(AppPalette p) {
    final today = DateUtils.dateOnly(_now);
    final days = [for (var i = 0; i < 7; i++) DateUtils.addDaysToDate(today, i)];
    final custom = _day != null && !days.contains(_day);
    String dayLabel(DateTime d) => d == today
        ? "Today"
        : d == DateUtils.addDaysToDate(today, 1)
        ? "Tomorrow"
        : formatShortDay(d);
    void shift(int minutes) {
      final total = (_time.hour * 60 + _time.minute + minutes).clamp(6 * 60, 21 * 60);
      setState(() => _time = TimeOfDay(hour: total ~/ 60, minute: total % 60));
    }

    final timeLabel = formatTime(DateTime(2000, 1, 1, _time.hour, _time.minute));
    return [
      Text("Day", style: AppText.section(p.ink)),
      const SizedBox(height: 10),
      ChipChoice<DateTime>(
        options: [...days, if (custom) _day!],
        selected: _day,
        label: (d) => custom && d == _day ? formatDay(d, now: _now) : dayLabel(d),
        onSelected: (d) => setState(() {
          _day = d;
          _error = null;
        }),
      ),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(onPressed: _pickLaterDay, child: const Text("A later day")),
      ),
      const SizedBox(height: 20),
      Text(_type == HelpType.medicine ? "Pick it up at about" : "My appointment is at", style: AppText.section(p.ink)),
      const SizedBox(height: 10),
      ChipChoice<TimeOfDay>(
        options: _quickTimes,
        selected: _quickTimes.contains(_time) ? _time : null,
        label: (t) => formatTime(DateTime(2000, 1, 1, t.hour, t.minute)),
        onSelected: (t) => setState(() => _time = t),
      ),
      const SizedBox(height: 12),
      Text("Or set it exactly", style: AppText.secondary(p.muted)),
      const SizedBox(height: 8),
      Panel(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _RoundIconButton(icon: Icons.remove_rounded, label: "15 minutes earlier", onPressed: () => shift(-15)),
            Expanded(
              child: Semantics(
                liveRegion: true,
                label: "Time",
                value: timeLabel,
                increasedValue: "15 minutes later",
                decreasedValue: "15 minutes earlier",
                onIncrease: () => shift(15),
                onDecrease: () => shift(-15),
                excludeSemantics: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(timeLabel, maxLines: 1, textScaler: AppText.titleScaler(context), style: AppText.title(p.ink)),
                ),
              ),
            ),
            _RoundIconButton(icon: Icons.add_rounded, label: "15 minutes later", onPressed: () => shift(15)),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Text("Your volunteer will plan to get you there with time to spare.", style: AppText.secondary(p.muted)),
    ];
  }

  Future<void> _pickLaterDay() async {
    final today = DateUtils.dateOnly(_now);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final p = context.palette;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Semantics(header: true, child: Text("Choose a day", style: AppText.heading(p.ink))),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      for (var i = 7; i < 35; i++)
                        ListTile(
                          minTileHeight: 56,
                          title: Text(formatDay(DateUtils.addDaysToDate(today, i), now: _now), style: AppText.body(p.ink)),
                          trailing: Icon(Icons.chevron_right_rounded, color: p.muted, size: AppText.icon(context, 24)),
                          onTap: () => Navigator.pop(context, DateUtils.addDaysToDate(today, i)),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: SecondaryButton(label: "Go back", onPressed: () => Navigator.pop(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _day = picked;
        _error = null;
      });
    }
  }

  List<Widget> _whereStep(AppPalette p) {
    final recent = <String, String>{for (final r in appState.requests.value.where((r) => r.seniorId == senior.id)) r.placeName: r.address};
    return [
      if (senior.address != null) ...[
        Panel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.home_outlined, color: p.ink, size: AppText.icon(context, 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your volunteer will meet ${_forSomeoneElse ? senior.firstName : 'you'} at home: ${senior.address}.",
                  style: AppText.secondary(p.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
      TextField(
        controller: _place,
        style: AppText.body(p.ink),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: "Name of the place", hintText: "For example, Dr. Lin's clinic", errorText: _error),
        onChanged: (_) => setState(() => _error = null),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _address,
        style: AppText.body(p.ink),
        decoration: const InputDecoration(labelText: "Address, if you know it"),
      ),
      if (recent.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text("Places you've been before", style: AppText.section(p.ink)),
        const SizedBox(height: 10),
        for (final MapEntry(key: place, value: address) in recent.entries.take(4)) ...[
          ChoiceTile(
            title: place,
            subtitle: address,
            selected: _place.text == place,
            onTap: () => setState(() {
              _place.text = place;
              _address.text = address;
              _error = null;
            }),
          ),
          const SizedBox(height: 10),
        ],
      ],
    ];
  }

  List<Widget> _notesStep(AppPalette p) => [
    Text("Pick anything that helps your volunteer plan.", style: AppText.secondary(p.muted)),
    const SizedBox(height: 12),
    for (final n in MobilityNeed.values) ...[
      ChoiceTile(
        title: n.label,
        multi: true,
        selected: _needs.contains(n),
        onTap: () => setState(() => _needs = _needs.contains(n) ? ({..._needs}..remove(n)) : {..._needs, n}),
      ),
      const SizedBox(height: 10),
    ],
    const SizedBox(height: 10),
    TextField(
      controller: _notes,
      style: AppText.body(p.ink),
      maxLines: 4,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(labelText: "Anything else (optional)", alignLabelWithHint: true),
    ),
    const SizedBox(height: 8),
    Text("Only the volunteer who says yes sees your notes.", style: AppText.small(p.muted)),
  ];

  List<Widget> _summaryStep(AppPalette p) {
    Widget row(String label, String value, int step) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.secondary(p.muted)),
                  Text(value, style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _change(step),
              child: Text("Change", semanticsLabel: "Change $label"),
            ),
          ],
        ),
      ),
    );
    return [
      row("Help with", helpLabel(_type!, forName: _forSomeoneElse ? senior.firstName : null), 0),
      row("When", formatWhen(_when!, now: _now), 1),
      row("Where", [_place.text.trim(), _address.text.trim()].where((s) => s.isNotEmpty).join(", "), 2),
      row(
        "Good to know",
        [..._needs.map((n) => n.label), if (_notes.text.trim().isNotEmpty) "“${_notes.text.trim()}”"].join("\n").ifEmpty("Nothing added"),
        3,
      ),
      const SizedBox(height: 4),
      Text(
        "Your volunteer will come to ${_forSomeoneElse ? "${senior.firstName}'s door" : "your door"} at about ${formatTime(HelpRequest.doorTimeFor(_type!, _when!))}.",
        style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      Text(
        "Only checked volunteers can see your request. If nobody says yes in time, you'll see a warning on your Home screen${senior.emergencyName != null && senior.shareWithFamily ? ', and so will ${senior.emergencyName!.split(' ').first}' : ''}, so there's time for a backup plan.",
        style: AppText.secondary(p.ink),
      ),
    ];
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      iconSize: 30,
      style: IconButton.styleFrom(backgroundColor: p.ground, foregroundColor: p.ink, minimumSize: const Size(60, 60)),
      icon: Icon(icon, size: AppText.icon(context, 24)),
    );
  }
}

class RequestSentPage extends StatelessWidget {
  const RequestSentPage({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = appState.requestById(requestId)!;
    final senior = appState.userById(r.seniorId)!;
    final family = senior.emergencyName != null && senior.shareWithFamily ? senior.emergencyName!.split(' ').first : null;
    return Scaffold(
      body: SafeArea(
        child: PageBody(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          children: [
            const Align(alignment: Alignment.centerLeft, child: SuccessMark()),
            const SizedBox(height: AppSpace.xxl),
            const ScreenTitle("Your request is sent"),
            const SizedBox(height: 12),
            Text("${r.type.label}, ${whenPhrase(r.when)}.", style: AppText.body(p.ink)),
            const SizedBox(height: 28),
            Text("What happens next", style: AppText.section(p.ink)),
            const SizedBox(height: 12),
            for (final line in [
              "Checked volunteers near you can now see it.",
              "When someone says yes, you'll see their name on your Home screen${family != null ? ', and so will $family' : ''}.",
              "If nobody has said yes ${byPhrase(r.backupDeadline)}, you'll see a warning there${family != null ? ', and so will $family' : ''}, so there's time for a backup plan.",
            ])
              InfoLine(icon: Icons.check_rounded, text: line),
            const SizedBox(height: 32),
            PrimaryButton(label: "Back to home", onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 10),
            SecondaryButton(
              label: "See this request",
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VisitDetailPage(requestId: r.id))),
            ),
          ],
        ),
      ),
    );
  }
}
