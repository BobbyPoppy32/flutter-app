import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/family_home_page.dart';
import 'package:flutter_app/views/pages/find_requests_page.dart';
import 'package:flutter_app/views/pages/profile_page.dart';
import 'package:flutter_app/views/pages/senior_home_page.dart';
import 'package:flutter_app/views/pages/visits_page.dart';
import 'package:flutter_app/views/pages/volunteer_home_page.dart';

/// The signed-in shell: a few labelled tabs per role, never hidden behind a
/// menu or a gesture.
class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser.value!;
    final (pages, items) = switch (user.role) {
      UserRole.senior => (
          [const SeniorHomePage(), VisitsPage(seniorId: user.id), const ProfilePage()],
          const [
            (Icons.home_outlined, Icons.home_rounded, "Home"),
            (Icons.event_note_outlined, Icons.event_note_rounded, "My visits"),
            (Icons.person_outline_rounded, Icons.person_rounded, "Profile"),
          ],
        ),
      UserRole.family => (
          [const FamilyHomePage(), VisitsPage(seniorId: user.seniorId!), const ProfilePage()],
          const [
            (Icons.home_outlined, Icons.home_rounded, "Home"),
            (Icons.event_note_outlined, Icons.event_note_rounded, "Visits"),
            (Icons.person_outline_rounded, Icons.person_rounded, "Profile"),
          ],
        ),
      UserRole.volunteer => (
          [const VolunteerHomePage(), const FindRequestsPage(), const VolunteerVisitsPage(), const ProfilePage()],
          const [
            (Icons.home_outlined, Icons.home_rounded, "Home"),
            (Icons.search_rounded, Icons.search_rounded, "Find"),
            (Icons.event_note_outlined, Icons.event_note_rounded, "My visits"),
            (Icons.person_outline_rounded, Icons.person_rounded, "Profile"),
          ],
        ),
    };

    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selected, _) {
        final index = selected.clamp(0, pages.length - 1);
        final p = context.palette;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 200),
              child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
            ),
          ),
          // Tab labels are capped at 1.5x: four labels can't fit side by side
          // at 2x, and every screen's own content still scales to 2x.
          bottomNavigationBar: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.5,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
              child: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  selectedPageNotifier.value = i;
                },
                destinations: [
                  for (final (icon, selectedIcon, label) in items)
                    NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selectedIcon), label: label),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
