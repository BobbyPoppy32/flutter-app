import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/home_page.dart';
import 'package:flutter_app/views/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/profile_page.dart';
import 'widgets/navbar_widgets.dart';

List<Widget> pages = [
  HomePage(), 
  ProfilePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Senior App"),
        actions: [
          IconButton(
            onPressed: ()  async {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
              final SharedPreferences prefs = 
                  await SharedPreferences.getInstance();
              await prefs.setBool(
                KConstants.ThemeModeKey, isDarkModeNotifier.value); 
                 
              
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode_rounded,
                );
              },
            ),
          ),
          IconButton(onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) {
              return SettingsPage(title: "Settings 123");
                },
              ),
            );
          }, icon: Icon(Icons.settings),),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) { 
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
