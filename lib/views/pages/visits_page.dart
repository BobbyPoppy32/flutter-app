import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/views/pages/senior_home_page.dart';
import 'package:flutter_app/views/pages/volunteer_request_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

/// A senior's visits (seen by them or their family): coming up, or past.
class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key, required this.seniorId});

  final String seniorId;

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    final own = appState.currentUser.value?.id == widget.seniorId;
    final senior = appState.userById(widget.seniorId);
    final name = senior?.firstName ?? "";
    if (!own && senior?.shareWithFamily != true) {
      return PageBody(
        children: [
          ScreenTitle("$name's visits"),
          const SizedBox(height: 20),
          EmptyState(message: "$name has turned off sharing, so their visits are private."),
        ],
      );
    }
    return ValueListenableBuilder(
      valueListenable: appState.requests,
      builder: (context, _, _) {
        final list = appState.forSenior(widget.seniorId, upcoming: _upcoming);
        return PageBody(
          children: [
            ScreenTitle(own ? "My visits" : "$name's visits"),
            const SizedBox(height: 20),
            ChipChoice<bool>(
              options: const [true, false],
              selected: _upcoming,
              label: (u) => u ? "Coming up" : "Past",
              onSelected: (u) => setState(() => _upcoming = u),
            ),
            const SizedBox(height: 20),
            if (list.isEmpty)
              EmptyState(message: _upcoming ? "No visits planned." : "No past visits yet."),
            for (final (i, r) in list.indexed) ...[
              StaggeredEntrance(index: i, child: VisitCard(request: r, onTap: () => openVisit(context, r))),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

/// The volunteer's own visits: what they've said yes to, and what they've
/// done.
class VolunteerVisitsPage extends StatefulWidget {
  const VolunteerVisitsPage({super.key});

  @override
  State<VolunteerVisitsPage> createState() => _VolunteerVisitsPageState();
}

class _VolunteerVisitsPageState extends State<VolunteerVisitsPage> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    final me = appState.currentUser.value!;
    return ValueListenableBuilder(
      valueListenable: appState.requests,
      builder: (context, _, _) {
        final list = appState.forVolunteer(me.id, upcoming: _upcoming);
        return PageBody(
          children: [
            const ScreenTitle("My visits"),
            const SizedBox(height: 20),
            ChipChoice<bool>(
              options: const [true, false],
              selected: _upcoming,
              label: (u) => u ? "Coming up" : "Done",
              onSelected: (u) => setState(() => _upcoming = u),
            ),
            const SizedBox(height: 20),
            if (list.isEmpty)
              EmptyState(
                message: _upcoming
                    ? "You haven't said yes to anyone yet. Requests near you are under Find."
                    : "Visits you finish will show up here.",
              ),
            for (final (i, r) in list.indexed) ...[
              StaggeredEntrance(
                index: i,
                child: VisitCard(request: r, forVolunteer: true, onTap: () => openRequestForVolunteer(context, r)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
