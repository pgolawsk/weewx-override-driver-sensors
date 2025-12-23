#!/usr/bin/env bash
set -e

VERSION="$1"
DATE="$(date +%Y-%m-%d)"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -n "$LAST_TAG" ]]; then
    RANGE="$LAST_TAG..HEAD"
    echo "Generating changelog from commits $RANGE"
else
    RANGE="HEAD"
    echo "Generating changelog from all commits"
fi

COMMITS=$(git log $RANGE --pretty=format:"%s")

if [[ -z "$COMMITS" ]]; then
    echo "No commits found"
    exit 1
fi

# optional: remove prefixes like feat:, fix:, docs:, ... from commit messages
# CLEAN_COMMITS=$(echo "$COMMITS" | sed -E 's/^(feat|fix|docs|chore|refactor|perf|test)(\([^)]+\))?:[ ]*//I')
CLEAN_COMMITS=$(echo "$COMMITS")

TMP_ENTRY=$(mktemp)

{
    echo "## [$VERSION] - $DATE"
    echo
    echo "$CLEAN_COMMITS" | sed 's/^/- /'
    echo
    echo "---"
    echo
} > "$TMP_ENTRY"

# --- insert to CHANGELOG.md ---
LAST_TAG="${LAST_TAG#v}"
awk '
    BEGIN { inserted = 0 }

    $0 ~ "^## \\[" LAST_TAG "\\]" && inserted == 0 {
        while ((getline line < "'"$TMP_ENTRY"'") > 0) print line
        close("'"$TMP_ENTRY"'")
        inserted = 1
    }
    { print }
    END {
        if (inserted == 0) {
            print "WARNING: LAST_TAG (" LAST_TAG ") not found, appending to top" > "/dev/stderr"
            print ""
            while ((getline line < "'"$TMP_ENTRY"'") > 0) print line
            close("'"$TMP_ENTRY"'")
        }
    }
' LAST_TAG="$LAST_TAG" CHANGELOG.md > CHANGELOG.tmp

mv CHANGELOG.tmp CHANGELOG.md
rm "$TMP_ENTRY"

echo "CHANGELOG.md updated for version $VERSION"
