#!/usr/bin/env bash
# Runs the shared analyzer rules (`analyzer_rules:` in ../.swiftlint.yml)
# against the Swift package in the current directory.
#
# `swiftlint lint` never runs analyzer rules: they need type information,
# which `swiftlint analyze` reads from a full compiler log. This builds into a
# throwaway scratch path, so every file is compiled and logged and the
# project's .build is left alone. Then it runs each rule on its own, because
# SwiftLint 0.65.1 crashes ("Attempted to read an unowned reference") when
# several analyzer rules run in one invocation.
#
#   ../SwiftLintConfig/scripts/swiftlint-analyze.sh          # report
#   ../SwiftLintConfig/scripts/swiftlint-analyze.sh --fix    # also apply fixes
#
# After --fix, build from a clean scratch path. unused_import can remove an
# import that another file was using through Swift's module-wide import leak,
# and an incremental build won't notice. Add the import to the file that uses
# it; don't restore the unused one. (See SwiftLint Never Autofix / unused_import.)
set -euo pipefail

base="$(cd "$(dirname "$0")/.." && pwd)/.swiftlint.yml"
[ -f Package.swift ] || { echo "Run from a Swift package's root directory." >&2; exit 2; }
[ -f .swiftlint.yml ] || { echo "No .swiftlint.yml here." >&2; exit 2; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Building with a compiler log…" >&2
swift build --build-tests -v --scratch-path "$work/build" >"$work/compile.log" 2>&1 \
  || { tail -50 "$work/compile.log" >&2; exit 1; }

rules=$(awk '/^analyzer_rules:/{f=1;next} f&&/^  - /{print $2;next} f{f=0}' "$base")
status=0
for rule in $rules; do
  swiftlint analyze --quiet --compiler-log-path "$work/compile.log" --only-rule "$rule" "$@" || status=$?
done
exit $status
