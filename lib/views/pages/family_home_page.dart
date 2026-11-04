import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/request_flow_page.dart';
import 'package:flutter_app/views/pages/senior_home_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

/// A family member's home: their relative's next visit, anything that
/// needs a backup plan, and a way to ask for help on their behalf.
class FamilyHomePage extends StatelessWidget {
  const FamilyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.requests,
      builder: (context, _, _) {
        final p = context.palette;
        final me = appState.currentUser.value!;
        final senior = appState.userById(me.seniorId)!;
        final now = DateTime.now();

        if (!senior.shareWithFamily) {
          return PageBody(
            children: [
              Semantics(header: true, child: Text("${greeting(now)}, ${me.firstName}", textScaler: AppText.titleScaler(context), style: AppText.title(p.ink))),
              const SizedBox(height: 16),
              EmptyState(message: "${senior.firstName} has turned off sharing, so their visits are private."),
            ],
          );
        }

        final upcoming = appState.forSenior(senior.id, upcoming: true);
        final alerts = upcoming.where((r) => r.needsBackup(now) || r.isNoShow(now)).toList();
        final next = upcoming.where((r) => !alerts.contains(r)).firstOrNull;

        return PageBody(
          children: [
            Semantics(header: true, child: Text("${greeting(now)}, ${me.firstName}", textScaler: AppText.titleScaler(context), style: AppText.title(p.ink))),
            if (todayLine(upcoming, now, you: false, name: senior.firstName) case final line when line.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(line, style: AppText.body(p.ink)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: "Ask for help for ${senior.firstName}",
              icon: Icons.add_rounded,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RequestFlowPage(seniorId: senior.id))),
            ),
            // The alert already offers this call; don't show it twice.
            if (senior.phone != null && alerts.isEmpty) ...[
              const SizedBox(height: 10),
              SecondaryButton(label: "Call ${senior.firstName}", icon: Icons.call_outlined, onPressed: () => contact(context, senior.phone!)),
            ],
            for (final r in alerts) ...[const SizedBox(height: 20), AlertPanel(request: r)],
            if (next != null) ...[
              const SizedBox(height: 32),
              SectionHeading("${senior.firstName}'s next visit"),
              NextVisitPanel(request: next),
            ],
            if (upcoming.length > alerts.length + 1) ...[
              const SizedBox(height: 28),
              SectionHeading("Also coming up", action: "See all", onAction: () => selectedPageNotifier.value = 1),
              for (final r in upcoming.where((r) => r != next && !alerts.contains(r)).take(2)) ...[
                VisitCard(request: r, onTap: () => openVisit(context, r)),
                const SizedBox(height: 12),
              ],
            ],
            const SizedBox(height: 24),
            Text(
              "You'll see a note here when a volunteer says yes, drops out, or doesn't arrive, and when nobody has said yes in time.",
              style: AppText.secondary(p.muted),
            ),
          ],
        );
      },
    );
  }
}
