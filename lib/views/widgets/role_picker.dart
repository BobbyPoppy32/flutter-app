import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';

/// Two large, tappable role-choice cards, shared between RoleSelectionPage
/// and LoginPage's Login mode (which has no preset role to arrive with).
class RolePickerColumn extends StatelessWidget {
  const RolePickerColumn({super.key, required this.onRoleSelected});

  final ValueChanged<UserRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoleCard(
          icon: Icons.elderly_rounded,
          title: "I need help getting somewhere",
          subtitle: "Post requests for rides to appointments or the pharmacy.",
          onTap: () => onRoleSelected(UserRole.senior),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.volunteer_activism_rounded,
          title: "I want to help",
          subtitle: "Browse nearby requests and offer to assist.",
          onTap: () => onRoleSelected(UserRole.companion),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SoftCard(
        radius: 22,
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: Row(
          children: [
            IconBadge(icon: icon, gradient: AppColors.primaryGradient, foreground: AppColors.textDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
