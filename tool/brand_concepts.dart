// Logo concepts for the identity checkpoint. Not shipped: the chosen one
// moves to lib/views/widgets/brand.dart.
import 'package:flutter/material.dart';

/// Every concept draws in a 1×1 box scaled to the canvas, with one stroke
/// weight, round ends, and a gap cut where shapes cross so the mark works in
/// one colour.
abstract class ConceptPainter extends CustomPainter {
  ConceptPainter(this.ink, this.second, this.ground);
  final Color ink;
  final Color second;
  final Color ground;

  Paint stroke(Size s, Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w * s.width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Path path(Size s, void Function(Path p, double Function(double) x, double Function(double) y) build) {
    final p = Path();
    build(p, (v) => v * s.width, (v) => v * s.height);
    return p;
  }

  @override
  bool shouldRepaint(covariant ConceptPainter old) => old.ink != ink || old.second != second || old.ground != ground;
}

/// 1. Two companions: a taller figure leaning toward a shorter one.
class CompanionsConcept extends ConceptPainter {
  CompanionsConcept(super.ink, super.second, super.ground);

  @override
  void paint(Canvas c, Size s) {
    const w = 0.12;
    final tall = path(s, (p, x, y) => p
      ..moveTo(x(0.20), y(0.86))
      ..cubicTo(x(0.20), y(0.50), x(0.60), y(0.46), x(0.60), y(0.86)));
    final small = path(s, (p, x, y) => p
      ..moveTo(x(0.54), y(0.86))
      ..cubicTo(x(0.54), y(0.62), x(0.82), y(0.60), x(0.82), y(0.86)));
    c.drawPath(tall, stroke(s, ink, w));
    c.drawPath(small, stroke(s, ground, w + 0.07));
    c.drawPath(small, stroke(s, second, w));
    c.drawCircle(Offset(s.width * 0.43, s.height * 0.27), s.width * 0.085, Paint()..color = ink);
    c.drawCircle(Offset(s.width * 0.69, s.height * 0.45), s.width * 0.07, Paint()..color = second);
  }
}

/// 2. The route: the welcome screen's home-to-clinic arch, with two
/// travellers side by side on it.
class RouteConcept extends ConceptPainter {
  RouteConcept(super.ink, super.second, super.ground);

  @override
  void paint(Canvas c, Size s) {
    const w = 0.12;
    final arch = path(s, (p, x, y) => p
      ..moveTo(x(0.14), y(0.84))
      ..cubicTo(x(0.14), y(0.26), x(0.86), y(0.26), x(0.86), y(0.84)));
    c.drawPath(arch, stroke(s, ink, w));
    c.drawCircle(Offset(s.width * 0.40, s.height * 0.30), s.width * 0.085, Paint()..color = second);
    c.drawCircle(Offset(s.width * 0.60, s.height * 0.30), s.width * 0.085, Paint()..color = ink);
  }
}

/// 3. An "A" made of two companions: the tall stroke rises and leans in, the
/// shorter one leans against it, and the dot between them is the crossbar.
class LeaningAConcept extends ConceptPainter {
  LeaningAConcept(super.ink, super.second, super.ground);

  @override
  void paint(Canvas c, Size s) {
    const w = 0.13;
    final tall = path(s, (p, x, y) => p
      ..moveTo(x(0.22), y(0.86))
      ..quadraticBezierTo(x(0.30), y(0.30), x(0.56), y(0.16)));
    final short = path(s, (p, x, y) => p
      ..moveTo(x(0.80), y(0.86))
      ..quadraticBezierTo(x(0.76), y(0.48), x(0.53), y(0.30)));
    c.drawPath(tall, stroke(s, ink, w));
    c.drawPath(short, stroke(s, ground, w + 0.07));
    c.drawPath(short, stroke(s, second, w));
    c.drawCircle(Offset(s.width * 0.53, s.height * 0.62), s.width * 0.075, Paint()..color = second);
  }
}

/// 4. Brand guardian's "Companions": a tall stroke rising and hooking over
/// toward a shorter one, read as two people and as an "A" with the gap as
/// the crossbar.
class HookConcept extends ConceptPainter {
  HookConcept(super.ink, super.second, super.ground);

  @override
  void paint(Canvas c, Size s) {
    const w = 0.13;
    final tall = path(s, (p, x, y) => p
      ..moveTo(x(0.24), y(0.86))
      ..cubicTo(x(0.27), y(0.52), x(0.36), y(0.20), x(0.50), y(0.17))
      ..quadraticBezierTo(x(0.60), y(0.15), x(0.63), y(0.28)));
    final small = path(s, (p, x, y) => p
      ..moveTo(x(0.77), y(0.86))
      ..quadraticBezierTo(x(0.76), y(0.62), x(0.67), y(0.48)));
    c.drawPath(tall, stroke(s, ink, w));
    c.drawPath(small, stroke(s, second, w));
  }
}

/// 5. Brand guardian's "Doorway": an open arch with someone standing in it.
class DoorwayConcept extends ConceptPainter {
  DoorwayConcept(super.ink, super.second, super.ground);

  @override
  void paint(Canvas c, Size s) {
    final arch = path(s, (p, x, y) => p
      ..moveTo(x(0.20), y(0.88))
      ..lineTo(x(0.20), y(0.42))
      ..arcToPoint(Offset(x(0.80), y(0.42)), radius: Radius.circular(x(0.30)))
      ..lineTo(x(0.80), y(0.88)));
    c.drawPath(arch, stroke(s, ink, 0.10));
    c.drawRRect(
      RRect.fromLTRBR(s.width * 0.46, s.height * 0.52, s.width * 0.62, s.height * 0.88, Radius.circular(s.width * 0.08)),
      Paint()..color = second,
    );
  }
}
