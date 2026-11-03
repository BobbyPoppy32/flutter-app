import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/views/widgets/app_widgets.dart';

const _tips = [
  (Icons.self_improvement_rounded, "A short walk in fresh air can lift your mood and energy for the whole day."),
  (Icons.water_drop_outlined, "Remember to drink water throughout the day, even if you don't feel thirsty."),
  (Icons.groups_outlined, "A quick call to a friend or family member can be great for your wellbeing."),
  (Icons.bedtime_outlined, "A consistent sleep schedule helps your body and mind stay sharp."),
  (Icons.local_florist_outlined, "A few minutes tending to a plant or garden is a gentle, grounding activity."),
];

/// A rotating wellness tip — a plain-content stand-in for the reference
/// mockup's "Live Shows" video feed. No fake video/media playback is
/// implied; this is honestly just a short static tip, changed daily.
class WellnessTipCard extends StatelessWidget {
  const WellnessTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
    final (icon, tip) = _tips[dayIndex % _tips.length];

    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          IconBadge(icon: icon, gradient: AppColors.primaryGradient, foreground: AppColors.textDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Wellness Tip",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textGrey),
                ),
                const SizedBox(height: 4),
                Text(tip, style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
