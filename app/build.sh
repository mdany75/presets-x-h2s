#!/bin/bash
# Construit « Presets X-H2S.app » (une fenêtre native qui affiche index.html du dépôt)
# et l'image disque à distribuer.
# Requiert seulement les outils de ligne de commande d'Apple : xcode-select --install
#
#   app/build.sh             construit app/build/Presets-X-H2S.dmg (l'application est dedans)
#   app/build.sh --install   construit, puis installe l'app dans /Applications et l'ouvre
#
# La page embarquée est l'index.html du dépôt au moment de la compilation. Ensuite,
# l'application se met à jour seule depuis GitHub (branche main) à chaque lancement :
# il n'est pas nécessaire de recompiler après un changement de fiches.
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Presets X-H2S"
EXECUTABLE="PresetsXH2S"
BUNDLE_ID="com.danymenard.presets-x-h2s"
MIN_MACOS="14.0"
DMG_NAME="Presets-X-H2S.dmg"
PAGE="../index.html"

INSTALL=false
if [[ "${1:-}" == "--install" ]]; then
  INSTALL=true
elif [[ $# -gt 0 ]]; then
  echo "usage : app/build.sh [--install]" >&2
  exit 1
fi

[[ -f "$PAGE" ]] || { echo "index.html introuvable à la racine du dépôt" >&2; exit 1; }

# L'app est assemblée hors du dossier du projet : iCloud Drive ajoute aux dossiers
# des attributs que codesign refuse (« detritus not allowed »).
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
APP="$WORK/$APP_NAME.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/fr.lproj"

echo "› Compilation"
for arch in arm64 x86_64; do
  swiftc -O -swift-version 5 -target "$arch-apple-macos$MIN_MACOS" \
    Sources/*.swift -o "$WORK/$EXECUTABLE-$arch"
done
lipo -create "$WORK/$EXECUTABLE-arm64" "$WORK/$EXECUTABLE-x86_64" \
  -output "$APP/Contents/MacOS/$EXECUTABLE"

echo "› Icône"
swiftc -swift-version 5 scripts/make_icon.swift -o "$WORK/make_icon"
"$WORK/make_icon" "$WORK/AppIcon.iconset"
iconutil -c icns "$WORK/AppIcon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"

echo "› Ressources"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp "$PAGE" "$APP/Contents/Resources/index.html"
cp ../selection.js "$APP/Contents/Resources/selection.js"
# fr.lproj : sa présence suffit pour que les panneaux système s'affichent en français.
printf '"CFBundleName" = "%s";\n"CFBundleDisplayName" = "%s";\n' "$APP_NAME" "$APP_NAME" \
  > "$APP/Contents/Resources/fr.lproj/InfoPlist.strings"

echo "› Signature"
# Signature locale (ad hoc). Avec un compte Apple Developer, remplacer « - » par
# l'identité « Developer ID Application: … », puis notariser l'image disque.
xattr -cr "$APP"
codesign --force --sign - --identifier "$BUNDLE_ID" "$APP"
codesign --verify --strict "$APP"

echo "› Image disque"
# L'application et un raccourci vers Applications : on glisse l'une sur l'autre pour installer.
STAGING="$WORK/dmg"
mkdir -p "$STAGING"
ditto "$APP" "$STAGING/$APP_NAME.app"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO -quiet "$WORK/$DMG_NAME"
hdiutil verify -quiet "$WORK/$DMG_NAME"

# Seule l'image disque est conservée (et versionnée) ; l'application assemblée reste dans le
# dossier temporaire.
mkdir -p build
cp "$WORK/$DMG_NAME" "build/$DMG_NAME"
echo "✓ app/build/$DMG_NAME"

if $INSTALL; then
  echo "› Installation"
  INSTALLED="/Applications/$APP_NAME.app"
  pkill -x "$EXECUTABLE" || true
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -x "$EXECUTABLE" >/dev/null || break
    sleep 0.5
  done
  rm -rf "$INSTALLED"
  ditto "$APP" "$INSTALLED"
  codesign --verify --strict "$INSTALLED"
  open "$INSTALLED"
  echo "✓ $INSTALLED"
fi
