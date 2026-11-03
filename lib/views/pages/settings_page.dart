import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _toggleDarkMode(bool value) async {
    isDarkModeNotifier.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KConstants.ThemeModeKey, value);
  }

  void _setTextScale(double value) async {
    textScaleNotifier.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(KConstants.TextScaleKey, value);
  }

  void _toggleMedicationReminders(bool value) async {
    medicationRemindersNotifier.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KConstants.MedicationRemindersKey, value);
  }

  void _toggleAppointmentReminders(bool value) async {
    appointmentRemindersNotifier.value = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KConstants.AppointmentRemindersKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SettingsSectionTitle(title: "Appearance"),
              _SettingsGroup(
                children: [
                  ValueListenableBuilder(
                    valueListenable: isDarkModeNotifier,
                    builder: (context, isDarkMode, child) {
                      return _SettingsSwitchTile(
                        icon: Icons.dark_mode_rounded,
                        title: "Dark Mode",
                        value: isDarkMode,
                        onChanged: _toggleDarkMode,
                      );
                    },
                  ),
                  _SettingsDivider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        const Icon(Icons.text_fields, color: AppColors.tealStart),
                        const SizedBox(width: 14),
                        const Text("Text Size", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: textScaleNotifier,
                    builder: (context, textScale, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Slider(
                          value: textScale,
                          min: 0.8,
                          max: 1.6,
                          divisions: 4,
                          activeColor: AppColors.tealStart,
                          label: "${(textScale * 100).round()}%",
                          onChanged: _setTextScale,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const _SettingsSectionTitle(title: "Notifications"),
              _SettingsGroup(
                children: [
                  ValueListenableBuilder(
                    valueListenable: medicationRemindersNotifier,
                    builder: (context, value, child) => _SettingsSwitchTile(
                      icon: Icons.medication_liquid,
                      title: "Medication Reminders",
                      value: value,
                      onChanged: _toggleMedicationReminders,
                    ),
                  ),
                  _SettingsDivider(),
                  ValueListenableBuilder(
                    valueListenable: appointmentRemindersNotifier,
                    builder: (context, value, child) => _SettingsSwitchTile(
                      icon: Icons.calendar_month,
                      title: "Appointment Reminders",
                      value: value,
                      onChanged: _toggleAppointmentReminders,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const _SettingsSectionTitle(title: "Support"),
              _SettingsGroup(
                children: [
                  _SettingsActionTile(
                    icon: Icons.help_outline,
                    title: "Help & FAQ",
                    onTap: () => _showHelpDialog(context),
                  ),
                  _SettingsDivider(),
                  _SettingsActionTile(
                    icon: Icons.feedback_outlined,
                    title: "Send Feedback",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Thanks! We'll be in touch.")),
                      );
                    },
                  ),
                  _SettingsDivider(),
                  _SettingsActionTile(
                    icon: Icons.info_outline,
                    title: "About This App",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Senior App"),
                            content: const Text(
                              "Helping families stay connected and on top of care, "
                              "one day at a time.",
                            ),
                            actions: [
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.tealStart),
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const _SettingsSectionTitle(title: "Account"),
              _SettingsGroup(
                children: [
                  _SettingsActionTile(
                    icon: Icons.logout,
                    title: "Log Out",
                    titleColor: AppColors.emergencyRed,
                    iconColor: AppColors.emergencyRed,
                    onTap: () async {
                      await appState.logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomePage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Help & FAQ"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _FaqItem(
                question: "How do I request help?",
                answer:
                    "From the Home tab, tap \"Request Help\", choose what you need, "
                    "where, and when — then post it. A companion nearby can accept it.",
              ),
              SizedBox(height: 14),
              _FaqItem(
                question: "How do I set my emergency contact?",
                answer: "Open the Profile tab and tap the Emergency Contact tile to add or edit it.",
              ),
              SizedBox(height: 14),
              _FaqItem(
                question: "Can I cancel a request?",
                answer: "Yes — open the request from \"My Requests\" and tap Cancel, any time before it's completed.",
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.tealStart),
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(answer, style: const TextStyle(color: AppColors.textGrey, height: 1.3)),
      ],
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0));
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.tealStart,
      secondary: Icon(icon, color: AppColors.tealStart),
      title: Text(title, style: const TextStyle(fontSize: 15)),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color titleColor;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppColors.tealStart,
    this.titleColor = AppColors.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(fontSize: 15, color: titleColor)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
      onTap: onTap,
    );
  }
}
