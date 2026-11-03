import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/companion_home_page.dart';
import 'package:flutter_app/views/pages/companion_requests_page.dart';
import 'package:flutter_app/views/pages/helpers_page.dart';
import 'package:flutter_app/views/pages/senior_home_page.dart';
import 'package:flutter_app/views/pages/senior_requests_page.dart';
import 'package:flutter_app/views/pages/settings_page.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/profile_page.dart';
import 'widgets/navbar_widgets.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.currentUser,
      builder: (context, user, child) {
        if (user == null) {
          // Shouldn't happen given the app's navigation flow, but avoids a
          // crash if this screen is ever reached without a signed-in user.
          return const WelcomePage();
        }

        final pages = user.role == UserRole.senior
            ? const [SeniorHomePage(), SeniorRequestsPage(), HelpersPage(), ProfilePage()]
            : const [CompanionHomePage(), CompanionRequestsPage(), ProfilePage()];

        final navItems = user.role == UserRole.senior
            ? const [
                NavItem(icon: Icons.home_rounded, label: "Home"),
                NavItem(icon: Icons.list_alt_rounded, label: "Requests"),
                NavItem(icon: Icons.diversity_3_rounded, label: "Helpers"),
                NavItem(icon: Icons.person_rounded, label: "Profile"),
              ]
            : const [
                NavItem(icon: Icons.home_rounded, label: "Home"),
                NavItem(icon: Icons.list_alt_rounded, label: "Requests"),
                NavItem(icon: Icons.person_rounded, label: "Profile"),
              ];

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text(
              "Senior App",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () async {
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool(
                    KConstants.ThemeModeKey,
                    isDarkModeNotifier.value,
                  );
                },
                icon: ValueListenableBuilder(
                  valueListenable: isDarkModeNotifier,
                  builder: (context, isDarkMode, child) {
                    return Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode_rounded,
                      color: AppColors.textDark,
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(title: "Settings"),
                    ),
                  );
                },
                icon: const Icon(Icons.settings, color: AppColors.textDark),
              ),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable: selectedPageNotifier,
            builder: (context, selectedPage, child) {
              // Guards against a stale tab index left over from the other
              // role's tab count (e.g. switching accounts after being on a
              // senior-only tab).
              final safeIndex = selectedPage.clamp(0, pages.length - 1);
              return AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: KeyedSubtree(
                  key: ValueKey(safeIndex),
                  child: pages.elementAt(safeIndex),
                ),
              );
            },
          ),
          bottomNavigationBar: NavbarWidget(items: navItems),
        );
      },
    );
  }
}
