#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Failed to update package name on line $LINENO"; exit 1' ERR

echo "🔧 Updating Android and iOS package name (bundle ID)..."

# Validate the format of the bundle ID
if [[ ! "${PKG_NAME:-}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\.[a-zA-Z_][a-zA-Z0-9_]*)+$ ]]; then
  echo "❌ ERROR: Invalid package/bundle identifier: '$PKG_NAME'"
  exit 1
fi

echo "✔ Package name / Bundle ID: $PKG_NAME"

echo "────────────── ANDROID UPDATE ──────────────"
echo "📦 Updating Android package..."

# Run Flutter rename tool
flutter pub run rename setBundleId --value "$PKG_NAME"

# Update package name in AndroidManifest.xml
ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$ANDROID_MANIFEST" ]; then
  sed -i.bak "s/package=\"[^\"]*\"/package=\"$PKG_NAME\"/g" "$ANDROID_MANIFEST"
  echo "✅ AndroidManifest.xml package updated"
else
  echo "❌ AndroidManifest.xml not found"
  exit 1
fi

# Update applicationId in Kotlin DSL build file
BUILD_FILE="android/app/build.gradle.kts"
if [ -f "$BUILD_FILE" ]; then
  sed -i.bak -E "s/applicationId\s*=\s*\"[^\"]+\"/applicationId = \"$PKG_NAME\"/" "$BUILD_FILE"
  echo "✅ applicationId updated in Kotlin DSL"
else
  echo "⚠️ build.gradle.kts not found. Skipping applicationId update."
fi

echo "✅ Android package name updated."

echo "────────────── iOS UPDATE ──────────────"
echo "🍏 Updating iOS bundle identifier..."

IOS_PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"
if [ -f "$IOS_PROJECT_FILE" ]; then
  sed -i.bak "s/PRODUCT_BUNDLE_IDENTIFIER = .*;/PRODUCT_BUNDLE_IDENTIFIER = $PKG_NAME;/g" "$IOS_PROJECT_FILE"
  echo "✅ PRODUCT_BUNDLE_IDENTIFIER updated in project.pbxproj"
else
  echo "❌ iOS project file not found at $IOS_PROJECT_FILE"
  exit 1
fi

echo "🎉 Package name update completed successfully."
