import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/data/notifiers.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/brand.dart';
import 'package:flutter_app/views/widgets/visit_widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final returning = appState.ownAccounts;
    void open(bool demo) => Navigator.push(context, MaterialPageRoute(builder: (_) => RolePage(demo: demo)));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageBody(
                padding: const EdgeInsets.fromLTRB(AppSpace.xxl, AppSpace.l, AppSpace.xxl, AppSpace.xxl),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: AlongsideLogo(size: 26)),
                  const SizedBox(height: AppSpace.l),
                  const RouteMotif(height: 120),
                  const SizedBox(height: AppSpace.l),
                  Semantics(
                    header: true,
                    child: Text("Someone to go with you", textScaler: AppText.titleScaler(context), style: AppText.display(p.ink)),
                  ),
                  const SizedBox(height: AppSpace.m),
                  Text(
                    "Checked local volunteers help you get to check-ups, scans and lab tests, and pick up your medicine.",
                    style: AppText.body(p.ink),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  // First thing a senior can change: the size of the words.
                  const TextSizeControl(),
                  const SizedBox(height: AppSpace.xl),
                  for (final line in const [
                    "Every volunteer has their ID and background checked first",
                    "You see who is coming, and a code they show at your door",
                  ])
                    InfoLine(icon: Icons.check_circle_outline_rounded, text: line),
                ],
              ),
            ),
            // Pinned, so the way in is on screen even at the largest text.
            _ActionBar(
              children: [
                if (returning.isNotEmpty) ...[
                  for (final user in returning.take(2)) ...[
                    PrimaryButton(label: "Continue as ${user.firstName}", onPressed: () => appState.signIn(user)),
                    const SizedBox(height: AppSpace.s),
                  ],
                  SecondaryButton(label: "I'm someone new", onPressed: () => open(false)),
                ] else
                  PrimaryButton(label: "Get started", onPressed: () => open(false)),
                const SizedBox(height: AppSpace.xs),
                TextButton(onPressed: () => open(true), child: const Text("Look around with sample people")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Buttons kept at the bottom of the screen, above a hairline.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(color: p.ground, border: Border(top: BorderSide(color: p.border.withValues(alpha: 0.4)))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.xxl, AppSpace.m, AppSpace.xxl, AppSpace.s),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

/// "Is this easy to read?" with Smaller / Bigger buttons, so the first
/// thing a senior can change is the size of the words.
class TextSizeControl extends StatelessWidget {
  const TextSizeControl({super.key});

  static const steps = [1.0, 1.25, 1.5, 1.75, 2.0];

  static void set(double value) {
    textScaleNotifier.value = value;
    saveSetting(KConstants.textScaleKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ValueListenableBuilder(
      valueListenable: textScaleNotifier,
      builder: (context, scale, _) {
        final i = steps.indexWhere((s) => s >= scale - 0.01).clamp(0, steps.length - 1);
        return Panel(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Is this easy to read?", style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
              Text("Text size ${(steps[i] * 100).round()}%", style: AppText.secondary(p.muted)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(backgroundColor: p.ground),
                    onPressed: i == 0 ? null : () => set(steps[i - 1]),
                    icon: Icon(Icons.text_decrease_rounded, size: AppText.icon(context, 24)),
                    label: const Text("Smaller"),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(backgroundColor: p.ground),
                    onPressed: i == steps.length - 1 ? null : () => set(steps[i + 1]),
                    icon: Icon(Icons.text_increase_rounded, size: AppText.icon(context, 24)),
                    label: const Text("Bigger"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class RolePage extends StatelessWidget {
  const RolePage({super.key, this.demo = false});

  /// Picking a role signs straight into that role's sample account.
  final bool demo;

  static const _roles = [
    (UserRole.senior, Icons.event_available_outlined, "I need help getting to appointments", "Ask for a volunteer to come with you or pick up your medicine."),
    (UserRole.volunteer, Icons.volunteer_activism_outlined, "I want to volunteer", "Help an older neighbour get to the doctor. We check everyone first."),
    (UserRole.family, Icons.people_outline_rounded, "I'm helping my mum, dad or another relative", "Follow their visits and ask for help on their behalf."),
  ];

  static const _demoNames = {
    UserRole.senior: "You'll be Margaret, 79.",
    UserRole.volunteer: "You'll be Daniel, a volunteer.",
    UserRole.family: "You'll be Lena, Margaret's daughter.",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(),
      body: PageBody(
        children: [
          ScreenTitle(
            demo ? "Who would you like to be?" : "Who are you?",
            subtitle: demo ? "Everyone here is a sample person. Nothing leaves this phone." : null,
          ),
          const SizedBox(height: 24),
          for (final (role, icon, title, subtitle) in _roles) ...[
            ChoiceTile(
              icon: icon,
              title: title,
              subtitle: demo ? "${_demoNames[role]} $subtitle" : subtitle,
              selected: false,
              navigates: true,
              onTap: () async {
                if (demo) {
                  await appState.signInDemo(role);
                  if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage(role: role)));
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.role});

  final UserRole role;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await appState.createAccount(name: _name.text.trim(), role: widget.role, phone: _phone.text.trim());
    if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final volunteer = widget.role == UserRole.volunteer;
    return Scaffold(
      appBar: const PageAppBar(),
      body: Form(
        key: _formKey,
        child: PageBody(
          children: [
            const ScreenTitle("A little about you"),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              style: AppText.body(p.ink),
              decoration: const InputDecoration(labelText: "Your full name"),
              validator: (v) => (v == null || v.trim().length < 2) ? "Please write your name" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              style: AppText.body(p.ink),
              decoration: const InputDecoration(labelText: "Your phone number"),
              validator: (v) => (v == null || v.replaceAll(RegExp(r'[^0-9]'), '').length < 7) ? "Please write a phone number we can call" : null,
            ),
            const SizedBox(height: 20),
            if (volunteer)
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Before you see anyone's request", style: AppText.section(p.ink)),
                    const SizedBox(height: 6),
                    Text(
                      "We check your ID, run a background check, call two references, and you take a short safety course. "
                      "To give rides, we also check your car insurance. Until then, requests stay hidden.",
                      style: AppText.secondary(p.ink),
                    ),
                  ],
                ),
              )
            else
              Text("We'll only share your number with the volunteer who says yes to your request.", style: AppText.secondary(p.muted)),
            const SizedBox(height: 28),
            PrimaryButton(label: "Create my account", onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
