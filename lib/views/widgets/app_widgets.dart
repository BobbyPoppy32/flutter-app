import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';

/// Shared "floating white card" look used everywhere: request cards, empty
/// states, settings groups, form tiles. One place to keep radius/shadow
/// consistent instead of every file re-declaring its own BoxDecoration.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = AppRadius.card,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.softShadow,
        border: border,
      ),
      child: child,
    );
  }
}

/// The app's one CTA button shape: a gradient pill with a soft glow.
/// Used for every primary action (get started, submit, request help, ...).
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56.0,
    this.radius = AppRadius.field,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.primaryGradient,
        color: onPressed == null ? AppColors.textGrey.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.tealStart.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          // Dark foreground: the fill is the reference's bright teal
          // (tealFillStart/End), which only clears WCAG AA as a fill paired
          // with dark text (5.92:1 / 7.91:1) — white text on it was 2.49:1.
          foregroundColor: AppColors.textDark,
          minimumSize: Size(double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        child: child,
      ),
    );
  }
}

/// A colored "chip" showing a HelpRequest's status (Waiting / Confirmed /
/// Completed / Cancelled) — was duplicated identically across the senior
/// and companion home pages.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// "Nothing here yet" placeholder card, shared between the senior and
/// companion home screens instead of two near-identical private widgets.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textGrey),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 15, color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Small rounded square with a centered icon — used for the emergency-call
/// badge and role-picker icons, previously hand-rolled with slightly
/// different values in each spot.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.gradient,
    this.color,
    this.foreground = Colors.white,
    this.size = 32,
    this.padding = 14,
    this.radius = 18,
  });

  final IconData icon;
  final Gradient? gradient;
  final Color? color;
  // Defaults to white, which is safe against the dark solid fills
  // (tealStart, emergencyRed) this widget is normally given. Pass
  // AppColors.textDark when the badge uses the brighter primaryGradient
  // fill instead — white fails contrast there (2.49:1); see
  // .tastemaker/style-lock.md.
  final Color foreground;
  final double size;
  final double padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? AppColors.tealStart) : null,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: foreground, size: size),
    );
  }
}

/// Bold section label used above lists ("My Requests", "Open Requests", ...)
/// so every page's headers share one style instead of repeated inline
/// TextStyles.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textDark),
    );
  }
}

/// Fades and slides a child in on first build, staggered by [index] — used
/// for list cards (requests, commitments) so they enter with a soft rhythm
/// instead of popping in all at once. Respects the OS reduce-motion setting.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(_fade);

    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduceMotion) {
      _controller.value = 1.0;
    } else {
      Future.delayed(Duration(milliseconds: 40 * widget.index), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Decorated text field used across every form in the app (login, register,
/// request help). Uses TextFormField so callers can attach a [validator].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: AppColors.tealStart),
      ),
    );
  }
}
