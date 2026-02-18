#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
dart tools/generate_module_registry.dart
