#!/usr/bin/env bash
set -euo pipefail
trap 'echo "❌ Error on line $LINENO"; exit 1' ERR

TEMPLATE="android/app/src/main/AndroidManifest_template.xml"
TARGET="android/app/src/main/AndroidManifest.xml"
PERMISSIONS=""

echo "🔧 Checking environment flags for permission injection..."

if [[ "${IS_CAMERA:-false}" == "true" ]]; then
  echo "📸 Adding CAMERA permission"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.CAMERA\" />\n"
fi

if [[ "${IS_MIC:-false}" == "true" ]]; then
  echo "🎙️ Adding MICROPHONE permission"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.RECORD_AUDIO\" />\n"
fi

if [[ "${IS_LOCATION:-false}" == "true" ]]; then
  echo "📍 Adding LOCATION permissions"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.ACCESS_FINE_LOCATION\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.ACCESS_COARSE_LOCATION\" />\n"
fi

if [[ "${IS_CONTACT:-false}" == "true" ]]; then
  echo "📇 Adding CONTACT permission"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.READ_CONTACTS\" />\n"
fi

if [[ "${IS_CALENDAR:-false}" == "true" ]]; then
  echo "🗓️ Adding CALENDAR permissions"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.READ_CALENDAR\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.WRITE_CALENDAR\" />\n"
fi

if [[ "${IS_NOTIFICATION:-false}" == "true" ]]; then
  echo "🔔 Adding NOTIFICATION permission"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.POST_NOTIFICATIONS\" />\n"
fi

if [[ "${IS_BIOMETRIC:-false}" == "true" ]]; then
  echo "🧬 Adding BIOMETRIC permissions"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.USE_BIOMETRIC\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.USE_FINGERPRINT\" />\n"
fi

if [[ "${IS_STORAGE:-false}" == "true" ]]; then
  echo "💾 Adding STORAGE permissions"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.READ_EXTERNAL_STORAGE\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.READ_MEDIA_IMAGES\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.READ_MEDIA_VIDEO\" />\n"
  PERMISSIONS+="<uses-permission android:name=\"android.permission.READ_MEDIA_AUDIO\" />\n"
fi

echo -e "✍️ Injecting permissions into AndroidManifest.xml..."
sed "s|<!-- PERMISSION_PLACEHOLDER -->|$PERMISSIONS|" "$TEMPLATE" > "$TARGET"

echo "✅ AndroidManifest.xml generated with dynamic permissions"
