#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="weewx-override-driver-sensors"
DIST_DIR="dist"
START_VERSION="0.1.0"

# ---- helpers ----
die() {
    echo "❌ $1" >&2
    exit 1
}

is_semver() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# ---- determine version ----
if [[ $# -eq 1 ]]; then
    VERSION="$1"
    is_semver "$VERSION" || die "Invalid version '$VERSION' (expected X.Y.Z)"
else
    if git describe --tags --abbrev=0 >/dev/null 2>&1; then
        LAST_TAG=$(git describe --tags --abbrev=0 | sed 's/^v//')
        IFS='.' read -r MAJOR MINOR PATCH <<< "$LAST_TAG"
        PATCH=$((PATCH + 1))
        VERSION="${MAJOR}.${MINOR}.${PATCH}"
    else
        VERSION="${START_VERSION}"
    fi
fi

TAG="v${VERSION}"

echo "📦 Building release ${TAG}"

# ---- prepare dist ----
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

ZIP_NAME="${REPO_NAME}-${VERSION}.zip"

# ---- create zip ----
zip -r "${DIST_DIR}/${ZIP_NAME}" . \
    -x "*.git*" \
    -x ".idea/*" \
    -x ".vscode/*" \
    -x "__pycache__/*" \
    -x "*.pyc" \
    -x "${DIST_DIR}/*"

# ---- summary ----
echo
echo "✅ ZIP created:"
echo "   ${DIST_DIR}/${ZIP_NAME}"
echo
echo "➡️  Suggested next steps:"
echo "   git tag ${TAG}"
echo "   git push origin ${TAG}"
