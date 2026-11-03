import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    this.contactName,
    this.contactPhone,
    this.onTap,
  });

  final String? contactName;
  final String? contactPhone;
  final VoidCallback? onTap;

  Future<void> _call(BuildContext context) async {
    final phone = contactPhone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't start a call to $phone")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContact = contactName != null && contactName!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.emergencyRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              const IconBadge(icon: Icons.phone, color: AppColors.emergencyRed, size: 22, padding: 10, radius: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Emergency Contact",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                    Text(
                      hasContact
                          ? "$contactName${contactPhone != null && contactPhone!.isNotEmpty ? ' · $contactPhone' : ''}"
                          : "Not set — tap to add one in Profile",
                      style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              if (hasContact && contactPhone != null && contactPhone!.isNotEmpty)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Bright fill + dark text (5.15:1) — white text on this
                    // lighter coral was well below WCAG AA; see
                    // .tastemaker/style-lock.md.
                    backgroundColor: AppColors.emergencyFill,
                    foregroundColor: AppColors.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _call(context),
                  child: const Text("Call"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
