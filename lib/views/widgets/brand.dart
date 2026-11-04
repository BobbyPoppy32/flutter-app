import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';

/// The Alongside mark, "Leaning A": a tall stroke rises and leans in, a
/// shorter one leans against it, and the dot between them is the crossbar.
/// Two people walking together, and the A of the name.
///
/// Drawn in a 1×1 box so the same geometry makes the in-app logo, the app
/// icon and the launch screen (tool/render_brand_test.dart). Where the short
/// stroke meets the tall one a gap of [ground] is cut, so the mark also
/// works in a single colour.
class AlongsideMarkPainter extends CustomPainter {
  const AlongsideMarkPainter({required this.primary, required this.secondary, this.ground});

  final Color primary;
  final Color secondary;
  // The colour behind the mark, for the cut between the strokes. Without it
  // the short stroke is drawn without a cut (fine on any plain ground).
  final Color? ground;

  static const _weight = 0.13;
  static const _cut = 0.07;

  @override
  void paint(Canvas canvas, Size size) {
    double x(double v) => v * size.width;
    double y(double v) => v * size.height;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * size.width
      ..strokeCap = StrokeCap.round;

    final tall = Path()
      ..moveTo(x(0.22), y(0.86))
      ..quadraticBezierTo(x(0.30), y(0.30), x(0.56), y(0.15));
    final short = Path()
      ..moveTo(x(0.80), y(0.86))
      ..quadraticBezierTo(x(0.76), y(0.48), x(0.53), y(0.30));

    canvas.drawPath(tall, stroke(primary, _weight));
    if (ground != null) canvas.drawPath(short, stroke(ground!, _weight + _cut));
    canvas.drawPath(short, stroke(secondary, _weight));
    canvas.drawCircle(Offset(x(0.53), y(0.62)), size.width * 0.075, Paint()..color = secondary);
  }

  @override
  bool shouldRepaint(AlongsideMarkPainter old) => old.primary != primary || old.secondary != secondary || old.ground != ground;
}

/// The mark alone, in the palette's brand colours. Decorative, so hidden
/// from screen readers; the wordmark or the screen says the name.
class AlongsideMark extends StatelessWidget {
  const AlongsideMark({super.key, this.size = 48, this.ground});

  final double size;
  final Color? ground;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: AlongsideMarkPainter(primary: p.brand, secondary: p.brandSecond, ground: ground ?? p.ground)),
      ),
    );
  }
}

/// Mark plus the "Alongside" wordmark, kept as live text so it stays sharp
/// and is read out as the app's name.
class AlongsideLogo extends StatelessWidget {
  const AlongsideLogo({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      header: true,
      label: "Alongside",
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AlongsideMark(size: size * 1.35),
          SizedBox(width: size * 0.3),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Alongside", textScaler: AppText.titleScaler(context), style: AppText.wordmark(p.brand, size: size)),
            ),
          ),
        ],
      ),
    );
  }
}
