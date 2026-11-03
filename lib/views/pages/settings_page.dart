import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

/// Text size, dark mode, reminders, and the sample data. Every control
/// saves itself the moment it changes.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: const PageAppBar(),
      body: PageBody(
        children: [
          const ScreenTitle("Settings"),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: textScaleNotifier,
            builder: (context, scale, _) => Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Text size", style: AppText.section(p.ink)),
                  Text("${(scale * 100).round()}%", style: AppText.secondary(p.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ExcludeSemantics(child: Text("A", textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 16, color: p.ink))),
                      Expanded(
                        child: Semantics(
                          label: "Text size",
                          child: Slider(
                          value: scale,
                          min: 1.0,
                          max: 2.0,
                          divisions: 4,
                          label: "${(scale * 100).round()}%",
                          semanticFormatterCallback: (v) => "${(v * 100).round()} percent",
                          onChanged: (v) {
                            textScaleNotifier.value = v;
                            saveSetting(KConstants.textScaleKey, v);
                          },
                          ),
                        ),
                      ),
                      ExcludeSemantics(child: Text("A", textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 30, color: p.ink))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: p.ground, borderRadius: BorderRadius.circular(AppRadius.row)),
                    child: Text("Daniel is helping with your blood test on Thursday at 9:40 am.", style: AppText.body(p.ink)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Panel(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: isDarkModeNotifier,
                  builder: (context, dark, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: dark,
                    title: Text("Dark screen", style: AppText.section(p.ink)),
                    subtitle: Text("Light words on a dark background", style: AppText.secondary(p.muted)),
                    onChanged: (v) {
                      isDarkModeNotifier.value = v;
                      saveSetting(KConstants.themeModeKey, v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeading("About this app"),
          Text(
            "Alongside is a prototype. Everything is stored on this phone only, and the people in it are samples.",
            style: AppText.secondary(p.ink),
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            label: "Start the sample visits again",
            icon: Icons.restart_alt_rounded,
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: "Start the samples again?",
                body: "The sample people and their visits go back to how they were at first. Accounts and requests you made stay.",
                confirmLabel: "Yes, start again",
              );
              if (!ok) return;
              await appState.resetDemo();
              if (context.mounted) showDone(context, "The sample visits are back to the start.");
            },
          ),
        ],
      ),
    );
  }
}
