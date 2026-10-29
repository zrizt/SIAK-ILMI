#!/usr/bin/env bash
# SIAK-ILMI Build Helper
# Run: bash build.sh
set -e
echo "=== SIAK-ILMI: Running pub get ==="
flutter pub get
echo "=== Running build_runner (Drift codegen) ==="
dart run build_runner build --delete-conflicting-outputs
echo "=== Build ready. Run: flutter run ==="
