import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/pages/settings_page.dart';
import 'package:flutter_app/views/pages/volunteer_profile_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/format.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.currentUser,
      builder: (context, user, _) {
        if (user == null) return const SizedBox.shrink();
        final p = context.palette;
        final roleLine = switch (user.role) {
          UserRole.senior => user.address ?? user.area ?? "",
          UserRole.volunteer => "Volunteer in ${user.area ?? 'your area'}",
          UserRole.family => "Following ${appState.userById(user.seniorId)?.name ?? 'a relative'}'s visits",
        };
        return PageBody(
          children: [
            Row(
              children: [
                Avatar(user: user, size: 72),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(header: true, child: Text(user.name, style: AppText.heading(p.ink))),
                      Text(roleLine, style: AppText.secondary(p.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ...switch (user.role) {
              UserRole.senior => _senior(context, user, p),
              UserRole.volunteer => _volunteer(context, user, p),
              UserRole.family => <Widget>[
                  _DetailsPanel(rows: [("Your phone", user.phone ?? "Not added")], onEdit: () => _edit(context)),
                ],
            },
            const SizedBox(height: 28),
            SecondaryButton(
              label: "Settings",
              icon: Icons.settings_outlined,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: "Sign out",
              icon: Icons.logout_rounded,
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: "Sign out?",
                  body: "Your visits stay saved on this phone. You can come back any time.",
                  confirmLabel: "Sign out",
                  cancelLabel: "Stay signed in",
                );
                if (ok) appState.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _edit(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditDetailsPage()));

  List<Widget> _senior(BuildContext context, AppUser user, AppPalette p) => [
        _DetailsPanel(
          title: "Your details",
          rows: [
            ("Phone", user.phone ?? "Not added"),
            ("Home address", user.address ?? "Not added"),
            ("Usual needs", user.needs.isEmpty ? "None" : user.needs.map((n) => n.label).join("\n")),
          ],
          onEdit: () => _edit(context),
        ),
        const SizedBox(height: 16),
        _DetailsPanel(
          title: "Someone to call",
          rows: [
            ("Name", user.emergencyName == null ? "Not added" : "${user.emergencyName}${user.emergencyRelation == null ? '' : ', ${user.emergencyRelation}'}"),
            ("Phone", user.emergencyPhone ?? "Not added"),
          ],
          onEdit: () => _edit(context),
        ),
        if (user.emergencyName != null) ...[
          const SizedBox(height: 16),
          Panel(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: user.shareWithFamily,
              onChanged: (v) => appState.updateCurrentUser((u) => u.copyWith(shareWithFamily: v)),
              title: Text("${user.emergencyName!.split(' ').first} can follow my visits", style: AppText.body(p.ink)),
              subtitle: Text(
                "They'll see who's coming and be told if nobody says yes in time.",
                style: AppText.secondary(p.muted),
              ),
            ),
          ),
        ],
      ];

  List<Widget> _volunteer(BuildContext context, AppUser user, AppPalette p) {
    final stats = appState.statsFor(user.id);
    return [
      SectionHeading(user.vetting.complete ? "Your checks are done" : "Your checks"),
      VettingList(vetting: user.vetting, drives: user.hasCar),
      const SizedBox(height: 16),
      _DetailsPanel(
        rows: [
          ("Phone", user.phone ?? "Not added"),
          ("Gives rides", user.hasCar ? "Yes" : "No"),
          if (user.memberSince != null) ("Volunteering since", formatMonthYear(user.memberSince!)),
          ("Visits done", "${stats.visits}"),
        ],
        onEdit: () => _edit(context),
      ),
      const SizedBox(height: 16),
      SecondaryButton(
        label: "See my profile as others see it",
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerProfilePage(volunteerId: user.id))),
      ),
      const SizedBox(height: 10),
      SecondaryButton(label: "See my past visits", onPressed: () => selectedPageNotifier.value = 2),
    ];
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({this.title, required this.rows, required this.onEdit});

  final String? title;
  final List<(String, String)> rows;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[Text(title!, style: AppText.section(p.ink)), const SizedBox(height: 12)],
          for (final (i, (label, value)) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Text(label, style: AppText.secondary(p.muted)),
            Text(value, style: AppText.body(p.ink)),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text("Change", semanticsLabel: "Change ${title?.toLowerCase() ?? 'your details'}"),
            ),
          ),
        ],
      ),
    );
  }
}

class EditDetailsPage extends StatefulWidget {
  const EditDetailsPage({super.key});

  @override
  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  final AppUser _user = appState.currentUser.value!;
  late final _name = TextEditingController(text: _user.name);
  late final _phone = TextEditingController(text: _user.phone);
  late final _address = TextEditingController(text: _user.address);
  late final _eName = TextEditingController(text: _user.emergencyName);
  late final _eRelation = TextEditingController(text: _user.emergencyRelation);
  late final _ePhone = TextEditingController(text: _user.emergencyPhone);
  late Set<MobilityNeed> _needs = {..._user.needs};

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _eName, _eRelation, _ePhone]) {
      c.dispose();
    }
    super.dispose();
  }

  // An empty field clears the saved value (see AppUser.copyWith).
  String _clean(TextEditingController c) => c.text.trim();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final senior = _user.role == UserRole.senior;
    Widget field(TextEditingController c, String label, {TextInputType? type}) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: c,
            keyboardType: type,
            style: AppText.body(p.ink),
            textCapitalization: type == null ? TextCapitalization.words : TextCapitalization.none,
            decoration: InputDecoration(labelText: label),
          ),
        );
    return Scaffold(
      appBar: const PageAppBar(),
      body: PageBody(
        children: [
          const ScreenTitle("Your details"),
          const SizedBox(height: 20),
          field(_name, "Full name"),
          field(_phone, "Phone", type: TextInputType.phone),
          if (senior) ...[
            field(_address, "Home address"),
            const SizedBox(height: 14),
            Text("Someone to call", style: AppText.section(p.ink)),
            const SizedBox(height: 10),
            field(_eName, "Their name"),
            field(_eRelation, "Who they are to you, like Daughter"),
            field(_ePhone, "Their phone", type: TextInputType.phone),
            const SizedBox(height: 14),
            Text("Usual needs", style: AppText.section(p.ink)),
            const SizedBox(height: 4),
            Text("We'll fill these in each time you ask for help.", style: AppText.secondary(p.muted)),
            const SizedBox(height: 10),
            for (final n in MobilityNeed.values) ...[
              ChoiceTile(
                title: n.label,
                multi: true,
                selected: _needs.contains(n),
                onTap: () => setState(() => _needs = _needs.contains(n) ? ({..._needs}..remove(n)) : {..._needs, n}),
              ),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: "Save",
            onPressed: () async {
              if (_name.text.trim().isEmpty) return;
              await appState.updateCurrentUser(
                (u) => u.copyWith(
                  name: _name.text.trim(),
                  phone: _clean(_phone),
                  address: _clean(_address),
                  emergencyName: _clean(_eName),
                  emergencyRelation: _clean(_eRelation),
                  emergencyPhone: _clean(_ePhone),
                  needs: _needs,
                ),
              );
              if (context.mounted) {
                Navigator.pop(context);
                showDone(context, "Saved.");
              }
            },
          ),
        ],
      ),
    );
  }
}
