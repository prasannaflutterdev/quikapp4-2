#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Error at line $LINENO"; exit 1' ERR

echo "🔧 Starting Google Services plugin injection..."

# Check if google-services.json exists
if [ ! -f android/app/google-services.json ]; then
  echo "❌ Missing android/app/google-services.json"
  exit 1
fi
echo "✅ google-services.json found."

if [ "${PUSH_NOTIFY:-false}" = "true" ]; then
  echo "✔ PUSH_NOTIFY=true, injecting Firebase Google Services plugin..."

  FIREBASE_CLASSPATH='classpath("com.google.gms:google-services:4.3.15")'
  DESUGAR_DEP='implementation("com.android.tools:desugar_jdk_libs:2.0.4")'

  PROJECT_BUILD_FILE="android/build.gradle.kts"
  APP_BUILD_FILE="android/app/build.gradle.kts"

  # ───── Add Firebase classpath to android/build.gradle.kts ─────
  if ! grep -q 'com.google.gms:google-services' "$PROJECT_BUILD_FILE"; then
    echo "🔧 Injecting Firebase classpath into $PROJECT_BUILD_FILE..."
    awk '
      /buildscript\s*{/ { print; in_block=1; next }
      in_block && /dependencies\s*{/ {
        print
        print "        classpath(\"com.google.gms:google-services:4.3.15\")"
        in_block=0
        next
      }
      { print }
    ' "$PROJECT_BUILD_FILE" > tmp && mv tmp "$PROJECT_BUILD_FILE"
    echo "✅ Firebase classpath injected."
  else
    echo "✅ Firebase classpath already present."
  fi

  # ───── Apply Google Services plugin in android/app/build.gradle.kts ─────
  if grep -q 'plugins\s*{' "$APP_BUILD_FILE"; then
    if ! grep -q 'id("com.google.gms.google-services")' "$APP_BUILD_FILE"; then
      echo "🔧 Applying Google Services plugin in $APP_BUILD_FILE..."
      sed -i.bak '/plugins\s*{/a\
id("com.google.gms.google-services")
' "$APP_BUILD_FILE"
      echo "✅ Google Services plugin applied."
    else
      echo "✅ Google Services plugin already applied."
    fi
  else
    echo "❌ plugins block not found in $APP_BUILD_FILE"
    exit 1
  fi

  # ───── Add desugar_jdk_libs dependency if missing ─────
  if ! grep -q 'desugar_jdk_libs' "$APP_BUILD_FILE"; then
    echo "🔧 Adding desugar_jdk_libs dependency in $APP_BUILD_FILE..."
    sed -i.bak '/dependencies\s*{/a\
coreLibraryDesugaring('"$DESUGAR_DEP"')
' "$APP_BUILD_FILE"
    echo "✅ desugar_jdk_libs dependency added."
  else
    echo "✅ desugar_jdk_libs dependency already present."
  fi

  # ───── Enable desugaring in compileOptions ─────
  if ! grep -q 'isCoreLibraryDesugaringEnabled = true' "$APP_BUILD_FILE"; then
    echo "🔧 Enabling desugaring in compileOptions in $APP_BUILD_FILE..."
    sed -i.bak '/compileOptions\s*{/a\
isCoreLibraryDesugaringEnabled = true
' "$APP_BUILD_FILE"
    echo "✅ Desugaring enabled in compileOptions."
  else
    echo "✅ Desugaring already enabled in compileOptions."
  fi

else
  echo "🚫 Skipping Firebase plugin injection because PUSH_NOTIFY != true"
fi

echo "🎉 Google Services plugin injection script completed."
