#!/bin/bash
# update-cask.sh
# Update the Homebrew Cask formula in Lobobodev/homebrew-tap to a new version.
#
# Usage:
#   ./scripts/update-cask.sh <version> <sha256>
#
# Example:
#   ./scripts/update-cask.sh 0.27.0 9b3e4410ebb9...

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <version> <sha256>"
    exit 1
fi

VERSION="$1"
SHA256="$2"
TAP_REPO="Lobobodev/homebrew-tap"
CASK_PATH="Casks/codexbarmenubar.rb"

echo "Updating $TAP_REPO :: $CASK_PATH"
echo "  version: $VERSION"
echo "  sha256:  $SHA256"

# Generate new cask content
NEW_CASK=$(cat <<EOF
cask "codexbarmenubar" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/Lobobodev/CodexBarMenuBar/releases/download/v#{version}/CodexBarMenuBar-v#{version}.zip",
      verified: "github.com/Lobobodev/CodexBarMenuBar/"
  name "CodexBarMenuBar"
  desc "macOS menu bar app showing AI provider usage at a glance via CodexBar CLI"
  homepage "https://github.com/Lobobodev/CodexBarMenuBar"

  depends_on macos: ">= :sequoia"
  depends_on cask: "codexbar"

  app "CodexBarMenuBar.app"

  zap trash: [
    "~/Library/Preferences/com.lobo.CodexBarMenuBar.plist",
    "~/Library/Application Support/CodexBarMenuBar",
  ]
end
EOF
)

# Get current file SHA (needed by GitHub API to update)
CURRENT_SHA=$(/opt/homebrew/bin/gh api "repos/$TAP_REPO/contents/$CASK_PATH" --jq '.sha')

# Update via GitHub API
NEW_CONTENT_B64=$(echo "$NEW_CASK" | base64)
/opt/homebrew/bin/gh api -X PUT "repos/$TAP_REPO/contents/$CASK_PATH" \
    -f message="Update codexbarmenubar to v$VERSION" \
    -f content="$NEW_CONTENT_B64" \
    -f sha="$CURRENT_SHA" \
    --jq '.commit.html_url'

echo "✓ Cask updated. Users can now: brew upgrade --cask codexbarmenubar"
