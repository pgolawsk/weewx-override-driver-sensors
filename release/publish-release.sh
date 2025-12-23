#!/usr/bin/env bash
set -e

VERSION="$1"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>   (e.g. 0.1.0)"
    exit 1
fi

TAG="v$VERSION"
ZIP_NAME="weewx-override-driver-sensors.zip"
RELEASE_DIR="release"
NOTES_FILE="$RELEASE_DIR/RELEASE_NOTES.md"

[[ -f "$RELEASE_DIR/$ZIP_NAME" ]] || {
    echo "❌ ZIP not found. Run prepare-release.sh first."
    exit 1
}

[[ -f "$NOTES_FILE" ]] || {
    echo "❌ RELEASE_NOTES.md not found."
    exit 1
}

echo "🚀 Publishing release $TAG"

git tag -a "$TAG" -m "Release $TAG"
git push origin "$TAG"

gh release create "$TAG" \
    "$RELEASE_DIR/$ZIP_NAME" \
    --title "$TAG" \
    --notes-file "$NOTES_FILE"

echo "✅ Release $TAG published successfully"
