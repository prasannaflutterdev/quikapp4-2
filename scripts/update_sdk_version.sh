#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ SDK version update failed on line $LINENO"; exit 1' ERR

echo "🔧 Starting SDK version update..."

if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
  echo "✔ PUSH_NOTIFY=true, proceeding with SDK version update."

  # Android build.gradle.kts path
  ANDROID_BUILD_FILE="android/app/build.gradle.kts"
  if [ -f "$ANDROID_BUILD_FILE" ]; then
    echo "📱 Updating Android minSdkVersion and targetSdkVersion in $ANDROID_BUILD_FILE"
    sed -i.bak -E "s/minSdkVersion\s*=\s*\d+/minSdkVersion = 21/" "$ANDROID_BUILD_FILE"
    sed -i.bak -E "s/targetSdkVersion\s*=\s*\d+/targetSdkVersion = 34/" "$ANDROID_BUILD_FILE"
    echo "✅ Android SDK versions updated."
  else
    echo "⚠️ Android build.gradle.kts not found at $ANDROID_BUILD_FILE"
  fi

  # iOS Podfile minimum deployment target
  PODFILE_PATH="ios/Podfile"
  if [ -f "$PODFILE_PATH" ]; then
    echo "🍏 Updating iOS minimum deployment target in Podfile"
    sed -i.bak -E "s/platform :ios, '[0-9.]+'/platform :ios, '13.0'/" "$PODFILE_PATH"
    echo "✅ iOS deployment target updated in Podfile."
  else
    echo "⚠️ Podfile not found. Skipping iOS Podfile update."
  fi

  # iOS Xcode project minimum deployment target
  IOS_PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"
  if [ -f "$IOS_PROJECT_FILE" ]; then
    echo "🍏 Updating iOS deployment target in Xcode project"
    # Use macOS-compatible sed syntax with empty backup extension
    sed -i '' -e "s/IPHONEOS_DEPLOYMENT_TARGET = .*;/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/" "$IOS_PROJECT_FILE"
    echo "✅ iOS deployment target updated in Xcode project."
  else
    echo "⚠️ iOS project.pbxproj not found. Skipping Xcode project update."
  fi

else
  echo "🚫 SDK version update skipped because PUSH_NOTIFY != true"
fi

echo "🎉 SDK version update script completed."
