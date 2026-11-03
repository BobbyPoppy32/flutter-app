import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/pages/role_selection_page.dart';
import 'package:flutter_app/views/widget_tree.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:flutter_app/views/widgets/hero_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.title,
    this.role,
  });

  final String title;
  // Set when arriving from RoleSelectionPage to register; null for Login,
  // which doesn't need a role upfront — the saved account already has one.
  final UserRole? role;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  // Register-mode, senior-only fields.
  final controllerAge = TextEditingController();
  final controllerEmergencyName = TextEditingController();
  final controllerEmergencyPhone = TextEditingController();

  // Register-mode, companion-only fields.
  final controllerSchool = TextEditingController();
  final controllerAvailability = TextEditingController();

  bool _submitting = false;
  String? _errorText;

  bool get isRegister => widget.title == "Register";

  @override
  void dispose() {
    controllerName.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
    controllerAge.dispose();
    controllerEmergencyName.dispose();
    controllerEmergencyPhone.dispose();
    controllerSchool.dispose();
    controllerAvailability.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroWidget(
                    title: widget.title,
                    subtitle: isRegister
                        ? "Tell us a little about yourself"
                        : "Good to see you again",
                  ),
                  const SizedBox(height: 24.0),

                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    radius: AppRadius.card + 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isRegister) ...[
                          _RoleBadge(role: widget.role!),
                          const SizedBox(height: 16.0),
                          AppTextField(
                            controller: controllerName,
                            hint: "Full Name",
                            icon: Icons.badge_outlined,
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Enter your name" : null,
                          ),
                          const SizedBox(height: 14.0),
                        ],
                        AppTextField(
                          controller: controllerEmail,
                          hint: "Email",
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 14.0),
                        AppTextField(
                          controller: controllerPassword,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (v) =>
                              (v == null || v.length < 4) ? "Password must be at least 4 characters" : null,
                        ),

                        if (isRegister && widget.role == UserRole.senior) ...[
                          const SizedBox(height: 20.0),
                          const _SectionLabel(text: "About you"),
                          const SizedBox(height: 10.0),
                          AppTextField(
                            controller: controllerAge,
                            hint: "Age",
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14.0),
                          AppTextField(
                            controller: controllerEmergencyName,
                            hint: "Emergency Contact Name",
                            icon: Icons.emergency_outlined,
                          ),
                          const SizedBox(height: 14.0),
                          AppTextField(
                            controller: controllerEmergencyPhone,
                            hint: "Emergency Contact Phone",
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],

                        if (isRegister && widget.role == UserRole.companion) ...[
                          const SizedBox(height: 20.0),
                          const _SectionLabel(text: "About you"),
                          const SizedBox(height: 10.0),
                          AppTextField(
                            controller: controllerSchool,
                            hint: "School or Organization",
                            icon: Icons.school_outlined,
                          ),
                          const SizedBox(height: 14.0),
                          AppTextField(
                            controller: controllerAvailability,
                            hint: "Availability (e.g. Weekday afternoons)",
                            icon: Icons.schedule_outlined,
                          ),
                        ],

                        if (_errorText != null) ...[
                          const SizedBox(height: 14.0),
                          Text(
                            _errorText!,
                            style: const TextStyle(color: AppColors.emergencyRed, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  GradientPillButton(
                    label: widget.title,
                    onPressed: _submitting ? null : onSubmitPressed,
                    height: 56,
                  ),

                  if (!isRegister) ...[
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
                      ),
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(color: AppColors.tealStart),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("or try it instantly", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _submitting ? null : () => _loginAsDemo(UserRole.senior),
                            icon: const Icon(Icons.elderly_rounded, size: 20),
                            label: const Text("Demo Senior"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _submitting ? null : () => _loginAsDemo(UserRole.companion),
                            icon: const Icon(Icons.volunteer_activism_rounded, size: 20),
                            label: const Text("Demo Companion"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Enter your email";
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return "Enter a valid email";
    return null;
  }

  Future<void> onSubmitPressed() async {
    setState(() => _errorText = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    String? error;
    if (isRegister) {
      final role = widget.role!;
      final profile = AppUser(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: controllerName.text.trim(),
        email: controllerEmail.text.trim(),
        password: controllerPassword.text,
        role: role,
        age: role == UserRole.senior ? int.tryParse(controllerAge.text.trim()) : null,
        emergencyContactName: role == UserRole.senior ? _orNull(controllerEmergencyName.text) : null,
        emergencyContactPhone: role == UserRole.senior ? _orNull(controllerEmergencyPhone.text) : null,
        schoolOrOrg: role == UserRole.companion ? _orNull(controllerSchool.text) : null,
        availabilityNote: role == UserRole.companion ? _orNull(controllerAvailability.text) : null,
        backgroundCheckStatus: role == UserRole.companion ? "Pending" : null,
      );
      error = await appState.register(profile);
    } else {
      error = await appState.login(
        email: controllerEmail.text.trim(),
        password: controllerPassword.text,
      );
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _submitting = false;
        _errorText = error;
      });
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
      (route) => false,
    );
  }

  String? _orNull(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _loginAsDemo(UserRole role) async {
    setState(() => _submitting = true);
    await appState.loginAsDemo(role);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WidgetTree()),
      (route) => false,
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final isSenior = role == UserRole.senior;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tealStart.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSenior ? Icons.elderly_rounded : Icons.volunteer_activism_rounded,
            size: 18,
            color: AppColors.tealStart,
          ),
          const SizedBox(width: 8),
          Text(
            isSenior ? "Registering as a Senior" : "Registering as a Companion",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.tealStart),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 0.4),
    );
  }
}
