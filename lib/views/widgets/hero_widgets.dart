import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealStart.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              // Dark text: the fill is the reference's bright teal gradient,
              // which only clears WCAG AA paired with dark text (5.92:1 /
              // 7.91:1) — white text on it was 2.49:1. See
              // .tastemaker/style-lock.md.
              color: AppColors.textDark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              // Full-opacity textDark, not a lightened tint: hierarchy here
              // comes from the smaller/regular-weight type, not from
              // lowering contrast — a lighter tone fails against this fill
              // (textGrey only hit 2.43:1 / 3.24:1 against the two gradient
              // stops when tested).
              style: const TextStyle(
                fontSize: 15.0,
                color: AppColors.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}