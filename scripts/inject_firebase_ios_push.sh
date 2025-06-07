#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Error on line $LINENO"; exit 1' ERR

echo "🔧 Starting Firebase Push Notification setup for iOS..."

if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
  echo "🔔 Enabling Firebase Push Notifications for iOS..."

  # Ensure directories exist
  mkdir -p assets firebase/ios ios/Runner ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm

  # 1. Download GoogleService-Info.plist
  if [ -n "${firebase_config_ios:-}" ]; then
    echo "📥 Downloading GoogleService-Info.plist..."
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 --no-check-certificate \
      -O assets/GoogleService-Info.plist "$firebase_config_ios"
  else
    echo "⚠️ firebase_config_ios not set. Skipping GoogleService-Info.plist download."
  fi

  # Copy plist to iOS project
  if [ -f assets/GoogleService-Info.plist ]; then
    cp assets/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
    echo "✅ GoogleService-Info.plist copied to ios/Runner/"
  else
    echo "❌ Missing GoogleService-Info.plist after download. Aborting."
    exit 1
  fi

  # 2. Copy Package.resolved if available
  if [ -f firebase/ios/Package.resolved ]; then
    cp firebase/ios/Package.resolved ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
    echo "📦 Firebase SDK Package.resolved copied."
  else
    echo "⚠️ Package.resolved not found. You may need to add Firebase SDK manually in Xcode."
  fi

  # 3. Download APNs Auth Key if URL provided
  if [ -n "${APNS_AUTH_KEY_URL:-}" ]; then
    echo "📥 Downloading APNs Auth Key..."
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 --no-check-certificate \
      -O firebase/ios/AuthKey.p8 "$APNS_AUTH_KEY_URL"
    echo "✅ AuthKey.p8 downloaded."
  else
    echo "ℹ️ APNS_AUTH_KEY_URL not set. Skipping APNs Auth Key download."
  fi

  # 4. Check APNs entitlement key in Runner.entitlements
  ENTITLEMENTS_FILE="ios/Runner/Runner.entitlements"
  if [ -f "$ENTITLEMENTS_FILE" ]; then
    if grep -q "aps-environment" "$ENTITLEMENTS_FILE"; then
      echo "✅ APNs entitlement key found in Runner.entitlements."
    else
      echo "⚠️ Warning: aps-environment key missing in Runner.entitlements."
    fi
  else
    echo "⚠️ Warning: Runner.entitlements file not found at $ENTITLEMENTS_FILE."
  fi

else
  echo "🚫 PUSH_NOTIFY is false. Skipping Firebase push notification setup for iOS."

  # Clean up any existing Firebase iOS config files
  rm -f ios/Runner/GoogleService-Info.plist
  rm -f ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
  echo "🧹 Cleaned up Firebase iOS config files."
fi

echo "🎉 Firebase iOS push notification setup script complete."
