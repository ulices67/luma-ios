#!/bin/bash
set -e

echo "=============================================="
echo "🚀 Compilando Luma para iOS (Generando .ipa)..."
echo "=============================================="

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

OUTPUT_DIR="$PROJECT_DIR/build"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "📦 1. Compilando Luma.xcodeproj para dispositivo iOS (Release - arm64)..."
xcodebuild clean build \
  -project Luma.xcodeproj \
  -scheme Luma \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$OUTPUT_DIR/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

APP_PATH="$OUTPUT_DIR/DerivedData/Build/Products/Release-iphoneos/Luma.app"

if [ ! -d "$APP_PATH" ]; then
  echo "❌ Error: No se encontró Luma.app en $APP_PATH"
  exit 1
fi

echo "📦 2. Empaquetando Payload -> Luma.ipa..."
mkdir -p "$OUTPUT_DIR/Payload"
cp -R "$APP_PATH" "$OUTPUT_DIR/Payload/"

cd "$OUTPUT_DIR"
zip -r -q "Luma.ipa" Payload
rm -rf Payload

echo "=============================================="
echo "✅ ¡Compilación completada con éxito!"
echo "📁 Archivo IPA generado en:"
echo "   $OUTPUT_DIR/Luma.ipa"
echo "=============================================="
