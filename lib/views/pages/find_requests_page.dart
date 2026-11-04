import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/pages/volunteer_profile_page.dart';
import 'package:flutter_app/views/pages/volunteer_request_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';

enum _Within {
  any("Any distance", null),
  two("Within 2 km", 2),
  five("Within 5 km", 5),
  ten("Within 10 km", 10);

  const _Within(this.label, this.km);
  final String label;
  final double? km;
}

enum _When {
  any("Any time", null),
  today("Today", 0),
  threeDays("Next 3 days", 3),
  week("This week", 7);

  const _When(this.label, this.days);
  final String label;
  final int? days;
}

/// Open requests near a volunteer. Shows nothing at all until their safety
/// checks are done: the verdict's gate, enforced in [AppState.openFor].
class FindRequestsPage extends StatefulWidget {
  const FindRequestsPage({super.key});

  @override
  State<FindRequestsPage> createState() => _FindRequestsPageState();
}

class _FindRequestsPageState extends State<FindRequestsPage> {
  HelpType? _type;
  _Within _within = _Within.any;
  _When _when = _When.any;

  bool _matches(HelpRequest r, DateTime now) {
    if (_type != null && r.type != _type) return false;
    if (_within.km != null && r.distanceKm > _within.km!) return false;
    if (_when.days != null) {
      final end = DateUtils.addDaysToDate(DateUtils.dateOnly(now), _when.days! + 1);
      if (!r.when.isBefore(end)) return false;
    }
    return true;
  }

  String get _summary => "${_type?.label ?? "All kinds of help"}, ${_within.label.toLowerCase()}, ${_when.label.toLowerCase()}";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.currentUser,
      builder: (context, me, _) {
        if (!me!.vetting.complete) return _ChecksFirst(user: me);
        return ValueListenableBuilder(
          valueListenable: appState.requests,
          builder: (context, _, _) {
            final p = context.palette;
            final now = DateTime.now();
            final all = appState.openFor(me);
            final list = all.where((r) => _matches(r, now)).toList();
            final filtered = _type != null || _within != _Within.any || _when != _When.any;
            return PageBody(
              children: [
                const ScreenTitle("Find someone to help"),
                const SizedBox(height: 8),
                Text(
                  "${list.length} open ${list.length == 1 ? 'request' : 'requests'} near ${me.area ?? 'you'}",
                  style: AppText.body(p.ink),
                ),
                const SizedBox(height: 16),
                Panel(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                  onTap: _openFilters,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.tune_rounded, color: p.ink, size: AppText.icon(context, 24))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_summary, style: AppText.secondary(p.ink)),
                            const SizedBox(height: 4),
                            Text(
                              "Change filters",
                              style: AppText.body(p.accentText).copyWith(fontSize: 17, fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (list.isEmpty)
                  EmptyState(
                    message: all.isEmpty ? "Nobody near you needs help right now. Check back later." : "Nothing matches these filters.",
                    action: filtered ? "Show everything" : null,
                    onAction: () => setState(() {
                      _type = null;
                      _within = _Within.any;
                      _when = _When.any;
                    }),
                  ),
                for (final (i, r) in list.indexed) ...[
                  StaggeredEntrance(index: i, child: _OpenRequestCard(request: r)),
                  const SizedBox(height: 12),
                ],
                if (!AppState.canDrive(me)) ...[
                  const SizedBox(height: 8),
                  Text("Rides aren't shown, because they need a car whose insurance we've checked.", style: AppText.small(p.muted)),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          final p = context.palette;
          void update(VoidCallback f) {
            setState(f);
            setSheet(() {});
          }

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(header: true, child: Text("Filters", style: AppText.heading(p.ink))),
                    const SizedBox(height: 20),
                    Text("Kind of help", style: AppText.section(p.ink)),
                    const SizedBox(height: 10),
                    ChipChoice<HelpType?>(
                      options: const [null, ...HelpType.values],
                      selected: _type,
                      label: (t) => t?.label ?? "All",
                      onSelected: (t) => update(() => _type = t),
                    ),
                    const SizedBox(height: 22),
                    Text("Distance", style: AppText.section(p.ink)),
                    const SizedBox(height: 10),
                    ChipChoice<_Within>(
                      options: _Within.values,
                      selected: _within,
                      label: (w) => w.label,
                      onSelected: (w) => update(() => _within = w),
                    ),
                    const SizedBox(height: 22),
                    Text("When", style: AppText.section(p.ink)),
                    const SizedBox(height: 10),
                    ChipChoice<_When>(
                      options: _When.values,
                      selected: _when,
                      label: (w) => w.label,
                      onSelected: (w) => update(() => _when = w),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(label: "Show requests", onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OpenRequestCard extends StatelessWidget {
  const _OpenRequestCard({required this.request});

  final HelpRequest request;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = request;
    final senior = appState.userById(r.seniorId)!;
    return Panel(
      onTap: () => openRequestForVolunteer(context, r),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(iconFor(r.type), size: 44),
              const SizedBox(width: AppSpace.m),
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 8), child: Text(r.type.label, style: AppText.heading(p.ink)))),
              Icon(Icons.chevron_right_rounded, color: p.muted, size: AppText.icon(context, 28)),
            ],
          ),
          const SizedBox(height: 4),
          InfoLine(icon: Icons.schedule_rounded, text: formatWhen(r.when), strong: true),
          InfoLine(
            icon: Icons.timelapse_rounded,
            text: "About ${formatDuration(r.durationMinutes)}${r.type == HelpType.ride || r.needs.contains(MobilityNeed.car) ? ', needs a car' : ''}",
          ),
          InfoLine(icon: Icons.person_outline_rounded, text: "${senior.shortName}, ${formatKm(r.distanceKm)}"),
          if (r.needs.isNotEmpty) InfoLine(icon: Icons.accessibility_new_rounded, text: r.needs.map((n) => n.label).join(", ")),
          if (r.needsBackup(DateTime.now())) ...[
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: NoticeChip("Needed soon: nobody has said yes", icon: Icons.schedule_rounded)),
          ],
          if (r.droppedBy.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: NoticeChip("Their volunteer had to drop out", icon: Icons.person_off_outlined)),
          ],
        ],
      ),
    );
  }
}

/// What an unchecked volunteer sees in place of requests.
class _ChecksFirst extends StatelessWidget {
  const _ChecksFirst({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PageBody(
      children: [
        const ScreenTitle("Your checks come first"),
        const SizedBox(height: 10),
        Text(
          "To keep everyone safe, requests stay hidden until every check is done. "
          "${user.vetting.passed} of 4 are done. This usually takes about a week.",
          style: AppText.body(p.ink),
        ),
        const SizedBox(height: 20),
        VettingList(vetting: user.vetting, drives: user.hasCar),
        const SizedBox(height: 28),
        Text("This is a prototype with no server, so nobody can run real checks yet.", style: AppText.small(p.muted)),
        const SizedBox(height: 10),
        SecondaryButton(
          label: "Pretend my checks have passed",
          onPressed: () => appState.updateCurrentUser(
            (u) => u.copyWith(
              vetting: Vetting(idChecked: true, backgroundCheckOn: DateTime.now(), referencesChecked: true, trainingDone: true),
            ),
          ),
        ),
      ],
    );
  }
}
