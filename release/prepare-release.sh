#!/usr/bin/env bash
set -e

VERSION="$1"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>   (e.g. 0.1.0)"
    exit 1
fi

TAG="v$VERSION"
EXT_NAME="weewx-override-driver-sensors"
ZIP_NAME="$EXT_NAME.zip"
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

echo "Preparing release $TAG"

for f in CHANGELOG.md README.md LICENSE install.py bin/user/OverrideDriverSensors.py; do
    [[ -f "$f" ]] || { echo "Missing file: $f"; exit 1; }
done

mkdir -p "$RELEASE_DIR"

# extract release notes from CHANGELOG
awk -v ver="$VERSION" '
    $0 ~ "^## \\[" ver "\\]" { in_section=1; print; next }
    in_section && $0 ~ "^## \\[" { exit }
    in_section { print }
' CHANGELOG.md \
| sed -E 's/^(#+)/\1#/; s/^##/#/' \
| sed -E 's/^(#+)#/\1/' \
| sed '${/^$/d;}' \
> $RELEASE_DIR/RELEASE_NOTES.md

if [[ ! -s $RELEASE_DIR/RELEASE_NOTES.md ]]; then
    echo "ERROR: No changelog entry for version $VERSION"
    exit 1
fi

echo "Generated $RELEASE_DIR/RELEASE_NOTES.md"


TMP_DIR="$(mktemp -d)"
PKG_DIR="$TMP_DIR/$EXT_NAME"

echo "📦 Assembling extension package..."

mkdir -p "$PKG_DIR/bin/user"

# copy ONLY installable files
cp install.py "$PKG_DIR/"
cp README.md "$PKG_DIR/"
cp CHANGELOG.md "$PKG_DIR/"
cp LICENSE "$PKG_DIR/"
cp $RELEASE_DIR/RELEASE_NOTES.md "$PKG_DIR/"
cp bin/user/OverrideDriverSensors.py "$PKG_DIR/bin/user/"

echo "🗜 Creating ZIP..."
(
    cd "$TMP_DIR"
    zip -r "$ZIP_NAME" "$EXT_NAME" >/dev/null
)

mv "$TMP_DIR/$ZIP_NAME" "$RELEASE_DIR/"
rm -rf "$TMP_DIR"

echo
echo "✅ Prepared release:"
echo "   Tag:    $TAG"
echo "   ZIP:    $RELEASE_DIR/$ZIP_NAME"
echo "   Notes:  $RELEASE_DIR/RELEASE_NOTES.md"
echo
echo "👉 Review $RELEASE_DIR/RELEASE_NOTES.md, then run:"
echo "   ./publish-release.sh $VERSION"
