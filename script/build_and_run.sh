#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="Marconio"
SCHEME="Marconio (macOS)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/.build/DerivedData"
SWIFT_PM="$ROOT_DIR/.build/SwiftPM"
APP_BUNDLE="$DERIVED_DATA/Build/Products/Debug/Marconio.app"

export HOME="$ROOT_DIR/.build/home"
export CLANG_MODULE_CACHE_PATH="$ROOT_DIR/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$ROOT_DIR/.build/ModuleCache"
mkdir -p "$HOME" "$CLANG_MODULE_CACHE_PATH"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true
mkdir -p "$DERIVED_DATA" "$SWIFT_PM"

xcodebuild \
  -project "$ROOT_DIR/Marconio.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -derivedDataPath "$DERIVED_DATA" \
  -clonedSourcePackagesDirPath "$SWIFT_PM" \
  -sdk macosx \
  CODE_SIGNING_ALLOWED=NO \
  build

case "$MODE" in
  run)
    /usr/bin/open -n "$APP_BUNDLE"
    ;;
  --verify|verify)
    /usr/bin/open -n "$APP_BUNDLE"
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  --logs|logs)
    /usr/bin/open -n "$APP_BUNDLE"
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    /usr/bin/open -n "$APP_BUNDLE"
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --debug|debug)
    lldb -- "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
    ;;
  *)
    echo "usage: $0 [run|--verify|--logs|--telemetry|--debug]" >&2
    exit 2
    ;;
esac
