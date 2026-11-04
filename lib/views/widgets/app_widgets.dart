import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/data/models.dart';

/// A tonal surface: one step off the ground, no border, no shadow. The
/// app's only container; structure comes from tone, not lines.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.color, this.onTap, this.semanticLabel});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(AppRadius.card);
    final body = Padding(padding: padding, child: child);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: color ?? p.panel,
        borderRadius: radius,
        // A tappable card is read as one item, not line by line.
        child: _OnPanel(child: onTap == null ? body : MergeSemantics(child: InkWell(onTap: onTap, borderRadius: radius, child: body))),
      ),
    );
  }
}

/// Marks content as sitting on a panel, so tonal controls inside it switch
/// to the ground colour and stay visible as buttons.
class _OnPanel extends InheritedWidget {
  const _OnPanel({required super.child});

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_OnPanel>() != null;

  @override
  bool updateShouldNotify(_OnPanel oldWidget) => false;
}

/// The app bar for pushed screens: a labelled "Back" (not a bare chevron),
/// the same as in the request flow, and an optional plain title.
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({super.key, this.title});

  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      title: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back_rounded, size: AppText.icon(context, 24)),
            label: const Text("Back"),
            style: TextButton.styleFrom(foregroundColor: context.palette.ink),
          ),
          if (title != null) ...[
            const SizedBox(width: 8),
            Flexible(child: Text(title!, overflow: TextOverflow.ellipsis, style: AppText.secondary(context.palette.muted))),
          ],
        ],
      ),
    );
  }
}

/// Screen title in Fraunces, with an optional plain-language line under it.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, textScaler: AppText.titleScaler(context), style: AppText.title(p.ink))),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: AppText.body(p.muted)),
        ],
      ],
    );
  }
}

/// Bold section label, with an optional text action on the right ("See all").
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Semantics(header: true, child: Text(text, style: AppText.section(p.ink)))),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// The one filled button style. Full width, 60dp tall, flat teal, label in
/// bold. Pass [danger] for the emergency call.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.danger = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = danger ? FilledButton.styleFrom(backgroundColor: p.dangerFill, foregroundColor: p.onDanger) : null;
    return SizedBox(
      width: double.infinity,
      child: icon == null
          ? FilledButton(onPressed: onPressed, style: style, child: Text(label, textAlign: TextAlign.center))
          : FilledButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon, size: AppText.icon(context, 24)),
              label: Text(label, textAlign: TextAlign.center),
            ),
    );
  }
}

/// Outlined, ink label: the second choice next to a [PrimaryButton].
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.color});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final onPanel = _OnPanel.of(context);
    // A danger action always sits on the ground colour, panel or not, so it
    // looks the same everywhere.
    final style = color == null
        ? (onPanel ? OutlinedButton.styleFrom(backgroundColor: context.palette.ground) : null)
        : OutlinedButton.styleFrom(
            foregroundColor: color,
            backgroundColor: context.palette.ground,
            side: BorderSide(color: color!, width: 1.5),
          );
    return SizedBox(
      width: double.infinity,
      child: icon == null
          ? OutlinedButton(onPressed: onPressed, style: style, child: Text(label, textAlign: TextAlign.center))
          : OutlinedButton.icon(onPressed: onPressed, style: style, icon: Icon(icon, size: AppText.icon(context, 22)), label: Text(label, textAlign: TextAlign.center)),
    );
  }
}

/// Status as a pale tint with dark ink of the same hue, plus a glyph so the
/// state never relies on colour alone.
class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key, this.forVolunteer = false});

  final RequestStatus status;
  final bool forVolunteer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (tone, icon) = switch (status) {
      RequestStatus.open => (p.open, Icons.hourglass_top_rounded),
      RequestStatus.matched => (p.matched, Icons.check_rounded),
      RequestStatus.withYou => (p.withYou, Icons.directions_walk_rounded),
      RequestStatus.done => (p.done, Icons.done_all_rounded),
      RequestStatus.cancelled => (p.cancelled, Icons.close_rounded),
    };
    final label = forVolunteer ? status.volunteerLabel : status.seniorLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppText.icon(context, 18), color: tone.ink),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: tone.ink))),
        ],
      ),
    );
  }
}

/// A person's initials on a pale tint chosen from their id, so the same
/// person always gets the same colour. Ink stays dark for contrast.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.user, this.size = 56});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // Reuses the status tint pairs: each is already checked at 6.6:1+.
    final tones = [p.matched, p.withYou, p.done, p.open, p.cancelled];
    final tone = tones[user.id.codeUnits.fold(0, (a, b) => a + b) % tones.length];
    final initials = user.name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tone.bg,
        ),
        child: Text(
          initials,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontFamily: AppText.displayFamily,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.38,
            color: tone.ink,
          ),
        ),
      ),
    );
  }
}

/// "Checks passed" mark next to a volunteer's name.
class VettedBadge extends StatelessWidget {
  const VettedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified_user_outlined, size: AppText.icon(context, 20), color: p.accentText),
        const SizedBox(width: 6),
        Flexible(child: Text("Checks passed", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.accentText))),
      ],
    );
  }
}

/// An icon + text line inside a card ("Thursday at 9:40 am", "1.8 km away").
class InfoLine extends StatelessWidget {
  const InfoLine({super.key, required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: AppText.icon(context, 20), color: p.muted)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: strong ? AppText.body(p.ink) : AppText.secondary(p.ink)),
          ),
        ],
      ),
    );
  }
}

/// A large selectable row: help types, needs, roles. Selection shows as a
/// thick accent border, a tinted fill and a filled check icon, so it never
/// relies on colour alone.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.multi = false,
    this.navigates = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final bool multi;
  // Opens another screen rather than picking an answer: shows a chevron.
  final bool navigates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(AppRadius.row);
    return Semantics(
      button: !multi,
      checked: multi ? selected : null,
      selected: multi || navigates ? null : selected,
      inMutuallyExclusiveGroup: !multi && !navigates,
      child: Material(
        color: selected ? p.accentTint : p.panel,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: selected ? p.accent : Colors.transparent, width: 2.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppText.icon(context, 28), color: p.ink),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.body(p.ink).copyWith(fontWeight: FontWeight.w700)),
                        if (subtitle != null) Text(subtitle!, style: AppText.secondary(p.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ExcludeSemantics(
                    child: navigates
                        ? Icon(Icons.chevron_right_rounded, size: AppText.icon(context, 30), color: p.muted)
                        : Icon(
                      selected
                          ? (multi ? Icons.check_box_rounded : Icons.check_circle_rounded)
                          : (multi ? Icons.check_box_outline_blank_rounded : Icons.radio_button_unchecked_rounded),
                      size: AppText.icon(context, 28),
                      color: selected ? p.accent : p.muted,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A short, wrapping row of selectable chips (days, times, filters). Each
/// chip is at least 48dp tall.
class ChipChoice<T> extends StatelessWidget {
  const ChipChoice({super.key, required this.options, required this.selected, required this.label, required this.onSelected});

  final List<T> options;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final o in options)
          Semantics(
            selected: o == selected,
            button: true,
            child: Material(
              color: o == selected ? p.accentTint : p.panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                side: o == selected ? BorderSide(color: p.accent, width: 2.5) : BorderSide(color: p.border, width: 1.5),
              ),
              child: InkWell(
                onTap: () => onSelected(o),
                customBorder: const StadiumBorder(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52, minWidth: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (o == selected) ...[
                          Icon(Icons.check_rounded, size: AppText.icon(context, 20), color: p.ink),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            label(o),
                            style: TextStyle(fontSize: 17, fontWeight: o == selected ? FontWeight.w700 : FontWeight.w400, color: p.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A quiet sentence in a panel for lists with nothing in them, with an
/// optional next step.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.action, this.onAction});

  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppText.body(p.muted)),
          if (action != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, style: TextButton.styleFrom(padding: EdgeInsets.zero), child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

/// Five 52dp stars. Each is its own button with a spoken label.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.onChanged, this.size = 44});

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  static const words = ["", "Poor", "Not great", "Good", "Very good", "Wonderful"];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      children: [
        for (var i = 1; i <= 5; i++)
          onChanged == null
              ? Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded, size: size * 0.5, color: p.star)
              : Semantics(
                  label: "$i star${i == 1 ? '' : 's'}, ${words[i]}",
                  selected: i == value,
                  button: true,
                  child: IconButton(
                    onPressed: () => onChanged!(i),
                    iconSize: size,
                    constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                    icon: Icon(i <= value ? Icons.star_rounded : Icons.star_outline_rounded, color: p.star, size: AppText.icon(context, 24)),
                  ),
                ),
      ],
    );
  }
}

/// Page body with the app's standard 20dp gutters, scrolling, and room at
/// the bottom so the last item clears the navigation bar.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 32)});

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// Fades and lifts a child in on first build, staggered by [index], for
/// list cards. Skipped entirely when the phone asks for reduced motion.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(_fade);

  bool _started = false;

  // Read from MediaQuery, not once at start, so a change in the phone's
  // Reduce Motion setting is followed and tests can switch it on.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      Future.delayed(Duration(milliseconds: 50 * widget.index.clamp(0, 6)), () {
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
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}
