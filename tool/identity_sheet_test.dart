// Renders the identity checkpoint sheet: logo concepts at icon sizes, the
// draft palette and the font specimens.
// Run: flutter test tool/identity_sheet_test.dart --dart-define=OUT=<dir> --dart-define=FONTS=<dir>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'brand_concepts.dart';
import 'render.dart';

const out = String.fromEnvironment('OUT');
const fonts = String.fromEnvironment('FONTS');

const navy = Color(0xFF1F3A5F), linen = Color(0xFFF6F1E8), ink = Color(0xFF1B2230), apricot = Color(0xFFE8A25A);
const charcoal = Color(0xFF15181E);

typedef Make = ConceptPainter Function(Color ink, Color second, Color ground);

final concepts = <(String, Make)>[
  ('1  Companions (hook)', HookConcept.new),
  ('2  Leaning A', LeaningAConcept.new),
  ('3  Two companions', CompanionsConcept.new),
  ('4  The route', RouteConcept.new),
  ('5  Doorway', DoorwayConcept.new),
];

Widget tile(Make make, double size, Color bg, Color a, Color b) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.225)),
      padding: EdgeInsets.all(size * 0.16),
      child: CustomPaint(painter: make(a, b, bg)),
    );

Widget grey(Widget child) => ColorFiltered(
      colorFilter: const ColorFilter.matrix([0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0]),
      child: child,
    );

TextStyle t(String family, double size, {FontWeight w = FontWeight.w400, Color c = ink}) =>
    TextStyle(fontFamily: family, fontSize: size, fontWeight: w, color: c, height: 1.25);

void main() {
  testWidgets('identity sheet', (tester) async {
    await loadFont('Next', ['$fonts/AtkinsonHyperlegibleNext-Regular.ttf']);
    await loadFont('NextBold', ['$fonts/AtkinsonHyperlegibleNext-Bold.ttf']);
    await loadFont('Literata', ['$fonts/Literata-SemiBold.ttf']);
    await loadFont('Newsreader', ['$fonts/Newsreader-SemiBold.ttf']);
    await loadFont('SourceSerif', ['$fonts/SourceSerif4-SemiBold.ttf']);

    final sheet = Container(
      color: linen,
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alongside — identity checkpoint', style: t('Literata', 44)),
          const SizedBox(height: 8),
          Text('Logo concepts at 180, 87 and 58 px (29pt app icon), one colour on dark, greyscale', style: t('Next', 20, c: const Color(0xFF4A5160))),
          const SizedBox(height: 28),
          for (final (name, make) in concepts) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 240, child: Text(name, style: t('NextBold', 22))),
                tile(make, 180, navy, linen, apricot),
                const SizedBox(width: 24),
                tile(make, 87, navy, linen, apricot),
                const SizedBox(width: 20),
                tile(make, 58, navy, linen, apricot),
                const SizedBox(width: 20),
                tile(make, 58, charcoal, linen, linen),
                const SizedBox(width: 20),
                grey(tile(make, 58, navy, linen, apricot)),
                const SizedBox(width: 20),
                tile(make, 87, Colors.white, navy, apricot),
                const SizedBox(width: 32),
                SizedBox(width: 64, height: 64, child: CustomPaint(painter: make(navy, apricot, linen))),
                const SizedBox(width: 12),
                Text('Alongside', style: t('Literata', 44, c: navy)),
              ],
            ),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 16),
          Text('Palette: Harbour Ink', style: t('NextBold', 24)),
          const SizedBox(height: 12),
          Row(children: [
            for (final (n, c) in [('Navy  #1F3A5F', navy), ('Linen  #F6F1E8', linen), ('Ink  #1B2230', ink), ('Apricot  #E8A25A', apricot), ('Charcoal  #15181E', charcoal)])
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 200, height: 90, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB9B2A6)))),
                  const SizedBox(height: 6),
                  Text(n, style: t('Next', 18)),
                ]),
              ),
          ]),
          const SizedBox(height: 32),
          Text('Type: titles (three serif candidates) with Atkinson Hyperlegible Next for everything else', style: t('NextBold', 24)),
          const SizedBox(height: 16),
          for (final family in ['Literata', 'Newsreader', 'SourceSerif'])
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                SizedBox(width: 240, child: Text(family, style: t('Next', 20, c: const Color(0xFF4A5160)))),
                Text('Good morning, Margaret', style: t(family, 46)),
                const SizedBox(width: 36),
                Text('Daniel comes at 8:55 am', style: t(family, 30, c: navy)),
              ]),
            ),
          const SizedBox(height: 8),
          Text('Body, 18pt:  Daniel will show you this number. If it doesn\'t match, don\'t open the door.', style: t('Next', 22)),
          const SizedBox(height: 6),
          Text('Look-alikes:  Il1  O0  rn m   Door code 6 3 7 5   8:55 am   Dr. Lin\'s clinic', style: t('Next', 28)),
          const SizedBox(height: 6),
          Text('Bold:  Say yes to helping   Someone to come with me', style: t('NextBold', 28)),
        ],
      ),
    );
    await savePng(tester, sheet, const Size(2200, 1960), '$out/identity-sheet.png');
  });
}
