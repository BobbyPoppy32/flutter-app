// Draws the app icon and launch-screen mark from AlongsideMarkPainter, so
// they always match the logo in the app. Then run tool/make_icons.sh.
// Run: flutter test tool/render_brand_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';
import 'package:flutter_app/views/widgets/brand.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render.dart';

Widget mark(Color bg, Color primary, Color secondary, {double padding = 0.2}) => LayoutBuilder(
      builder: (context, c) => Container(
        color: bg,
        padding: EdgeInsets.all(c.maxWidth * padding),
        child: CustomPaint(painter: AlongsideMarkPainter(primary: primary, secondary: secondary, ground: bg.a == 0 ? null : bg)),
      ),
    );

void main() {
  testWidgets('app icon', (tester) async {
    // Full-bleed square: iOS and Android round the corners themselves.
    await savePng(tester, mark(AppColors.navy, AppColors.linen, AppColors.apricot, padding: 0.14), const Size(1024, 1024), 'assets/brand/icon-1024.png');
  });

  testWidgets('launch marks', (tester) async {
    for (final (scale, suffix) in [(1.0, ''), (2.0, '@2x'), (3.0, '@3x')]) {
      await savePng(tester, mark(Colors.transparent, AppColors.navy, AppColors.apricotDeep, padding: 0), const Size(120, 120),
          'assets/brand/launch-mark$suffix.png', pixelRatio: scale);
      await savePng(tester, mark(Colors.transparent, AppPalette.dark.brand, AppPalette.dark.brandSecond, padding: 0), const Size(120, 120),
          'assets/brand/launch-mark-dark$suffix.png', pixelRatio: scale);
    }
  });
}
