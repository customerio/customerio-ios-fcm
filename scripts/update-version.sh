#!/bin/sh

# Script that updates the version in Package.swift and CioFirebaseWrapper.podspec
#
# Designed to be run from CI server or manually. 
# 
# Use script: ./scripts/update-version.sh "1.0.0"

set -e 

NEW_VERSION="$1"

RELATIVE_PATH_TO_SCRIPTS_DIR=$(dirname "$0")
ABSOLUTE_PATH_TO_SOURCE_CODE_ROOT_DIR=$(realpath "$RELATIVE_PATH_TO_SCRIPTS_DIR/..")
PODSPEC_FILE="$ABSOLUTE_PATH_TO_SOURCE_CODE_ROOT_DIR/CioFirebaseWrapper.podspec"

echo "Updating CioFirebaseWrapper.podspec to new version: $NEW_VERSION"

# Uses CLI tool sd to replace string in a file: https://github.com/chmln/sd
# Given line: `  spec.version      = "1.0.0"` 
# Regex string will match the line of the file that we can then substitute. 
sd 'spec\.version\s*=\s*"(.*)"' "spec.version      = \"$NEW_VERSION\"" $PODSPEC_FILE

echo "Done! Showing changes to confirm it worked: "
git diff $PODSPEC_FILE

