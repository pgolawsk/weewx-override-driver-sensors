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

# sanity checks
git diff --quiet || {
    echo "❌ Working tree not clean. Commit changes first."
    exit 1
}

git fetch --tags

if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "❌ Tag $TAG already exists"
    exit 1
fi

mkdir -p "$RELEASE_DIR"

echo "📦 Creating ZIP..."
git archive \
    --format=zip \
    --prefix=weewx-override-driver-sensors/ \
    HEAD \
    -o "$RELEASE_DIR/$ZIP_NAME"

echo "📝 Generating draft release notes..."

LAST_TAG=$(git tag --sort=-v:refname | head -n 1 || true)

{
    echo "# Release $TAG"
    echo
    echo "## Changes"
    echo
    if [[ -n "$LAST_TAG" ]]; then
        git log "$LAST_TAG"..HEAD --pretty=format:"- %s"
    else
    git log --pretty=format:"- %s"
    fi
    echo
    echo "## Notes"
    echo "- "
} > "$NOTES_FILE"

echo
echo "✅ Prepared release:"
echo "   Tag:    $TAG"
echo "   ZIP:    $RELEASE_DIR/$ZIP_NAME"
echo "   Notes:  $NOTES_FILE"
echo
echo "👉 Review & edit RELEASE_NOTES.md, then run:"
echo "   ./release/publish-release.sh $VERSION"
