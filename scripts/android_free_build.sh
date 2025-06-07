#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Android FREE build failed on line $LINENO"; exit 1' ERR

echo "🧹 Running flutter clean..."
flutter clean --verbose

echo "🔍 Debugging Minimal Environment..."
env | grep -E '^(WEB_URL|APP_NAME|PKG_NAME|VERSION_NAME|VERSION_CODE|IS_|LOGO_URL|BOTTOMMENU_|SPLASH)' | sort

# Define minimal dart defines for free APK builds
get_dart_defines() {
cat <<EOF
"--dart-define=WEB_URL=${WEB_URL}"
"--dart-define=APP_NAME=${APP_NAME}"
"--dart-define=PKG_NAME=${PKG_NAME}"
"--dart-define=VERSION_NAME=${VERSION_NAME}"
"--dart-define=VERSION_CODE=${VERSION_CODE}"

"--dart-define=IS_SPLASH=${IS_SPLASH}"
"--dart-define=SPLASH=${SPLASH}"
"--dart-define=SPLASH_BG=${SPLASH_BG}"
"--dart-define=SPLASH_BG_COLOR=${SPLASH_BG_COLOR}"
"--dart-define=SPLASH_ANIMATION=${SPLASH_ANIMATION}"
"--dart-define=SPLASH_TAGLINE=${SPLASH_TAGLINE}"
"--dart-define=SPLASH_TAGLINE_COLOR=${SPLASH_TAGLINE_COLOR}"
"--dart-define=SPLASH_DURATION=${SPLASH_DURATION}"

"--dart-define=IS_BOTTOMMENU=${IS_BOTTOMMENU}"
"--dart-define=BOTTOMMENU_ITEMS=${BOTTOMMENU_ITEMS}"
"--dart-define=BOTTOMMENU_BG_COLOR=${BOTTOMMENU_BG_COLOR}"
"--dart-define=BOTTOMMENU_ICON_COLOR=${BOTTOMMENU_ICON_COLOR}"
"--dart-define=BOTTOMMENU_TEXT_COLOR=${BOTTOMMENU_TEXT_COLOR}"
"--dart-define=BOTTOMMENU_FONT=${BOTTOMMENU_FONT}"
"--dart-define=BOTTOMMENU_FONT_SIZE=${BOTTOMMENU_FONT_SIZE}"
"--dart-define=BOTTOMMENU_FONT_BOLD=${BOTTOMMENU_FONT_BOLD}"
"--dart-define=BOTTOMMENU_FONT_ITALIC=${BOTTOMMENU_FONT_ITALIC}"
"--dart-define=BOTTOMMENU_ACTIVE_TAB_COLOR=${BOTTOMMENU_ACTIVE_TAB_COLOR}"
"--dart-define=BOTTOMMENU_ICON_POSITION=${BOTTOMMENU_ICON_POSITION}"
"--dart-define=BOTTOMMENU_VISIBLE_ON=${BOTTOMMENU_VISIBLE_ON}"
EOF
}

# 📦 Build APK (no keystore setup needed for debug/test builds)
echo "📦 Building Free APK..."
eval flutter build apk --release $(get_dart_defines)
echo "✅ Free APK build completed."

# ✅ Output check
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK_PATH" ]]; then
  echo "🎉 APK ready for testing:"
  echo "  📦 APK: $APK_PATH"
else
  echo "❌ APK not found: $APK_PATH"
  exit 1
fi
