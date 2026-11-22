#!/usr/bin/env bash
# Compila la APK firmada. Si algo falla, deja las últimas líneas del registro como anotaciones visibles.
set -uo pipefail
LOG="${RUNNER_TEMP:-/tmp}/android-build.log"
: > "$LOG"
step() {
  local name="$1"; shift
  echo "=== $name" | tee -a "$LOG"
  if ! "$@" >> "$LOG" 2>&1; then
    echo "::error::Falló: $name"
    grep -E "What went wrong|error|Error|FAILURE|Could not|Exception" "$LOG" | tail -25 | sed 's/^/::error::/'
    tail -30 "$LOG" | sed 's/^/::error::/'
    exit 1
  fi
}

[ -n "${KEYSTORE_PASSWORD:-}" ] || { echo "::error::Falta el secreto KEYSTORE_PASSWORD"; exit 1; }
export KEYSTORE_PATH="$PWD/android-release.keystore" KEY_PASSWORD="$KEYSTORE_PASSWORD" KEY_ALIAS="${KEY_ALIAS:-editorvideo}"

step "npm ci" npm ci
step "cap add android" npx cap add android
step "iconos" npx --yes @capacitor/assets@3 generate --android \
  --iconBackgroundColor '#2d4796' --iconBackgroundColorDark '#2d4796' \
  --splashBackgroundColor '#0e1014' --splashBackgroundColorDark '#0e1014'
step "cap sync" npx cap sync android
step "versión y firma" node scripts/patch-android.mjs
chmod +x android/gradlew
step "gradle assembleRelease" bash -c "cd android && ./gradlew assembleRelease --no-daemon --stacktrace"
step "copiar APK" cp android/app/build/outputs/apk/release/app-release.apk editor-video.apk
echo "APK lista: $(du -h editor-video.apk | cut -f1)"
