#!/bin/bash
set -e

RELEASE_TYPE="$1"
VERSION="$2"

if [ "$RELEASE_TYPE" != "prerelease" ]; then
    if [[ $VERSION =~ ^([0-9]+)\.([0-9]+)\. ]]; then
        MAJOR=${BASH_REMATCH[1]}
        MINOR=${BASH_REMATCH[2]}
        
        echo "Creating tags: v$MAJOR and v$MAJOR.$MINOR"
        git tag -f "v$MAJOR"
        git tag -f "v$MAJOR.$MINOR" 
        git push origin --tags --force
    else
        echo "Error: Invalid version format: $VERSION"
        exit 1
    fi
else
    echo "Skipping major/minor tags for prerelease"
fi