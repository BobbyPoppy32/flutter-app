#!/bin/sh
# Turns the rendered brand art (assets/brand/) into every iOS and Android
# icon and launch image. Run after: flutter test tool/render_brand_test.dart
set -e
cd "$(dirname "$0")/.."
SRC=assets/brand/icon-1024.png
IOS=ios/Runner/Assets.xcassets
RES=android/app/src/main/res

# The App Store rejects icons with transparency, so drop the alpha channel.
python3 -I -c "from PIL import Image; import sys; Image.open(sys.argv[1]).convert('RGB').save(sys.argv[2])" "$SRC" "$IOS/AppIcon.appiconset/Icon-App-1024x1024@1x.png"

for spec in 20:1 20:2 20:3 29:1 29:2 29:3 40:1 40:2 40:3 60:2 60:3 76:1 76:2 83.5:2; do
  pt=${spec%%:*}; scale=${spec##*:}
  px=$(python3 -c "print(round($pt*$scale))")
  sips -s format png -z "$px" "$px" "$IOS/AppIcon.appiconset/Icon-App-1024x1024@1x.png" --out "$IOS/AppIcon.appiconset/Icon-App-${pt}x${pt}@${scale}x.png" >/dev/null
done

for spec in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  sips -s format png -z "${spec##*:}" "${spec##*:}" "$IOS/AppIcon.appiconset/Icon-App-1024x1024@1x.png" --out "$RES/mipmap-${spec%%:*}/ic_launcher.png" >/dev/null
done

# Launch screen marks: light and dark, at 1x, 2x and 3x.
for s in "" "@2x" "@3x"; do
  cp "assets/brand/launch-mark$s.png" "$IOS/LaunchImage.imageset/LaunchImage$s.png"
  mkdir -p "$IOS/LaunchImage.imageset"
  cp "assets/brand/launch-mark-dark$s.png" "$IOS/LaunchImage.imageset/LaunchImageDark$s.png"
done
cp assets/brand/launch-mark@3x.png "$RES/drawable/launch_mark.png"
echo "Icons and launch images written."
