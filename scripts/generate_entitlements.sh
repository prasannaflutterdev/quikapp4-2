#!/bin/bash

set -euo pipefail
trap 'echo "❌ Flutter build failed on line $LINENO"; exit 1' ERR

echo "📥 Parsing environment from \$CM_ENV"
while IFS='=' read -r key value; do
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' | xargs)
  if [[ -n "$key" ]]; then
    export "$key"="$value"
  fi
done < "$CM_ENV"

# Debug output
echo "✅ PROFILE_UUID=$PROFILE_UUID"
echo "✅ PROFILE_NAME=$PROFILE_NAME"
echo "✅ APPLE_TEAM_ID=$APPLE_TEAM_ID"
echo "✅ BUNDLE_ID=$BUNDLE_ID"

echo "🧾 Ensuring entitlements file exists..."
mkdir -p ios/Runner

if [ "$PUSH_NOTIFY" = "true" ]; then
  echo "📲 PUSH_NOTIFY is true — adding aps-environment: production"
  cat > ios/Runner/Runner.entitlements <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>application-identifier</key>
  <string>${APPLE_TEAM_ID}.${BUNDLE_ID}</string>
  <key>keychain-access-groups</key>
  <array>
    <string>${APPLE_TEAM_ID}.*</string>
  </array>
  <key>get-task-allow</key>
  <false/>
  <key>aps-environment</key>
  <string>production</string>
</dict>
</plist>
EOF
else
  echo "🚫 PUSH_NOTIFY is false — creating base entitlements only"
  cat > ios/Runner/Runner.entitlements <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>application-identifier</key>
  <string>${APPLE_TEAM_ID}.${BUNDLE_ID}</string>
  <key>keychain-access-groups</key>
  <array>
    <string>${APPLE_TEAM_ID}.*</string>
  </array>
  <key>get-task-allow</key>
  <false/>
</dict>
</plist>
EOF
fi
