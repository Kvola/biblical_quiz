#!/usr/bin/env bash
# Construit les APK de version finale, un par type de processeur (plus légers) :
#   dist/QuizBiblique-<version>.apk          téléphones récents (arm64), le bon dans 95 % des cas
#   dist/QuizBiblique-<version>-ancien.apk   anciens téléphones 32 bits (armeabi-v7a)
#
# Avant de construire, le contenu est validé : un APK ne part jamais avec une
# question invalide. Signature : clé de android/key.properties si le fichier
# existe, sinon clé de développement (avertissement affiché).
set -euo pipefail
cd "$(dirname "$0")/.."

python3 scripts/validate_content.py
flutter build apk --release --split-per-abi

version=$(grep '^version:' pubspec.yaml | sed -E 's/version: *([^+]+).*/\1/')
out=build/app/outputs/flutter-apk
mkdir -p dist
cp "$out/app-arm64-v8a-release.apk" "dist/QuizBiblique-$version.apk"
cp "$out/app-armeabi-v7a-release.apk" "dist/QuizBiblique-$version-ancien.apk"

if [ -f android/key.properties ]; then
  echo "Signé avec la clé de publication (android/key.properties)."
else
  echo "ATTENTION : signé avec la clé de DÉVELOPPEMENT (android/key.properties absent)."
fi
ls -lh dist/QuizBiblique-"$version"*.apk | awk '{print $5, $9}'
