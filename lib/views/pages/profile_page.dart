import 'package:flutter/material.dart';
import 'package:flutter_app/data/app_state.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/pages/welcome_page.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _editField(String label, String current, Function(String) onSave) {
    final controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.tealStart),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(
    String label,
    String value,
    IconData icon,
    Function(String)? onSave, {
    Color iconColor = AppColors.tealStart,
  }) {
    return GestureDetector(
      onTap: onSave == null ? null : () => _editField(label, value, onSave),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: iconColor),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appState.currentUser,
      builder: (context, user, child) {
        if (user == null) return const SizedBox.shrink();

        return Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 48, color: AppColors.tealStart),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => _editField(
                      'Name',
                      user.name,
                      (v) => appState.updateCurrentUser((u) => u.copyWith(name: v)),
                    ),
                    child: Text(
                      user.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role == UserRole.senior ? "Senior" : "Companion",
                    style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                      children: user.role == UserRole.senior ? _seniorTiles(user) : _companionTiles(user),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.emergencyRed),
                      title: const Text('Log out', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold)),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _seniorTiles(AppUser user) {
    return [
      _profileTile(
        'Age',
        user.age?.toString() ?? 'Not set',
        Icons.cake_outlined,
        (v) => appState.updateCurrentUser((u) => u.copyWith(age: int.tryParse(v))),
      ),
      _profileTile(
        'Address',
        user.address ?? 'Not set',
        Icons.home_outlined,
        (v) => appState.updateCurrentUser((u) => u.copyWith(address: v)),
      ),
      _profileTile(
        'Emergency Contact',
        _emergencyContactSummary(user),
        Icons.emergency_outlined,
        (v) => appState.updateCurrentUser((u) => u.copyWith(emergencyContactName: v)),
        iconColor: AppColors.emergencyRed,
      ),
      _profileTile(
        'Medical Notes',
        user.medicalNotes ?? 'Not set',
        Icons.local_hospital_outlined,
        (v) => appState.updateCurrentUser((u) => u.copyWith(medicalNotes: v)),
      ),
    ];
  }

  String _emergencyContactSummary(AppUser user) {
    final parts = [user.emergencyContactName, user.emergencyContactPhone]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Not set' : parts.join(' · ');
  }

  List<Widget> _companionTiles(AppUser user) {
    return [
      _profileTile(
        'School / Organization',
        user.schoolOrOrg ?? 'Not set',
        Icons.school_outlined,
        (v) => appState.updateCurrentUser((u) => u.copyWith(schoolOrOrg: v)),
      ),
      _profileTile(
        'Availability',
        user.availabilityNote ?? 'Not set',
        Icons.schedule_outlined,
        (v) => appState.updateCurrentUser((u) => u.copyWith(availabilityNote: v)),
      ),
      _profileTile(
        'Background Check',
        user.backgroundCheckStatus ?? 'Pending',
        Icons.verified_user_outlined,
        null, // read-only: not something the user should freely edit
        iconColor: AppColors.blueAccent,
      ),
    ];
  }
}
