#!/bin/bash
# sign-and-notarize.sh
# One-shot build + sign + notarize + staple + zip for CodexBarMenuBar.
#
# Prerequisites (one-time setup, see README):
#   1. "Developer ID Application" certificate installed in Keychain
#   2. App-Specific Password generated at appleid.apple.com
#   3. `xcrun notarytool store-credentials "CodexBarProfile" ...` already ran
#
# Usage:
#   ./scripts/sign-and-notarize.sh 0.26.2
#
# Output:
#   build/CodexBarMenuBar-v<version>.zip   (signed, notarized, stapled)

set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────
SIGN_IDENTITY="Developer ID Application: Lobo Lu (256AW7ZTF6)"
NOTARY_PROFILE="CodexBarProfile"
SCHEME="CodexBarMenuBar"
PROJECT="CodexBarMenuBar.xcodeproj"

# ─── Args ─────────────────────────────────────────────────────────────────
if [ $# -lt 1 ]; then
    echo "Usage: $0 <version>   (e.g. 0.26.2)"
    exit 1
fi
VERSION="$1"

# Always run from the repo root
cd "$(dirname "$0")/.."

BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$SCHEME.xcarchive"
EXPORT_DIR="$BUILD_DIR/export"
APP_PATH="$EXPORT_DIR/$SCHEME.app"
ZIP_PATH="$BUILD_DIR/$SCHEME-v$VERSION.zip"

echo "════════════════════════════════════════"
echo "  CodexBarMenuBar  v$VERSION"
echo "  Sign + Notarize + Staple"
echo "════════════════════════════════════════"

# ─── Step 1: Clean ────────────────────────────────────────────────────────
echo ""
echo "[1/6] Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$EXPORT_DIR"

# ─── Step 2: Archive ──────────────────────────────────────────────────────
echo ""
echo "[2/6] Building Release archive (~30s)..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    MARKETING_VERSION="$VERSION" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    archive 2>&1 | grep -E "^(error:|warning:|\*\* )" || true

if [ ! -d "$ARCHIVE_PATH/Products/Applications/$SCHEME.app" ]; then
    echo "ERROR: Archive failed — .app not found"
    exit 1
fi

# Copy the .app out so we can sign it cleanly
cp -R "$ARCHIVE_PATH/Products/Applications/$SCHEME.app" "$EXPORT_DIR/"

# ─── Step 3: Sign ─────────────────────────────────────────────────────────
echo ""
echo "[3/6] Code-signing with Developer ID Application..."
# --options runtime: enable Hardened Runtime (required for notarization)
# --timestamp: include secure timestamp (required for notarization)
# Sign nested binaries first (best practice instead of --deep)
find "$APP_PATH" -type f \( -name "*.dylib" -o -name "*.framework" \) -print0 | \
    xargs -0 -I {} codesign --force --options runtime --timestamp \
        --sign "$SIGN_IDENTITY" {} 2>/dev/null || true

# Sign the main bundle last
codesign --force --options runtime --timestamp \
    --sign "$SIGN_IDENTITY" \
    "$APP_PATH"

# Verify the signature
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
echo "✓ Signature OK"

# ─── Step 4: Zip for notarization ─────────────────────────────────────────
echo ""
echo "[4/6] Creating archive for notarization upload..."
NOTARIZE_ZIP="$BUILD_DIR/notarize-upload.zip"
/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$NOTARIZE_ZIP"

# ─── Step 5: Submit to Apple's Notary service ─────────────────────────────
echo ""
echo "[5/6] Submitting to Apple notary service (1-5 min)..."
xcrun notarytool submit "$NOTARIZE_ZIP" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait

# ─── Step 6: Staple ───────────────────────────────────────────────────────
echo ""
echo "[6/6] Stapling notarization ticket to the app..."
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
echo "✓ Stapled and validated"

# ─── Final: re-zip the stapled .app for distribution ──────────────────────
echo ""
echo "Creating final distribution zip..."
rm -f "$NOTARIZE_ZIP"
/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

# ─── Generate SHA256 checksum ─────────────────────────────────────────────
echo ""
echo "Generating SHA256 checksum..."
SHA_PATH="$ZIP_PATH.sha256"
( cd "$(dirname "$ZIP_PATH")" && shasum -a 256 "$(basename "$ZIP_PATH")" > "$(basename "$SHA_PATH")" )
echo "  $(cat "$SHA_PATH")"

echo ""
echo "════════════════════════════════════════"
echo "  ✅ DONE"
echo "  Output:   $ZIP_PATH"
echo "  Size:     $(du -h "$ZIP_PATH" | cut -f1)"
echo "  Checksum: $SHA_PATH"
echo "════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Test: open $APP_PATH"
echo "  2. Upload zip + checksum to GitHub Release:"
echo "     gh release upload v$VERSION $ZIP_PATH $SHA_PATH --clobber"
