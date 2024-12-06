#!/bin/bash

set -e

eval "$(pkgx --shellcode)"

echo "... checking Swift code..."
if [[ "$1" == "--only-changes" ]]; then
  git diff --staged --name-only | grep ".swift$" | xargs pkgx swiftlint lint --quiet --strict
else
  pkgx swiftlint --quiet --strict
fi
echo "... checking Ruby scripts..."
pkgx +ruby +gem rubocop --format quiet
echo "... checking Shell scripts..."
pkgx shellcheck Scripts/*.sh hooks/* Artifacts/**/*.sh
echo "... checking Markdown documentation..."
pkgx markdownlint --ignore fastlane .
echo "... checking YAML files..."
pkgx yamllint .*.yml .github/
