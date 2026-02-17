#!/bin/bash

###############################################################################
# macOS Build Script
# Compiles the iOS app
###############################################################################

set -e

echo "🏗️  Building Noble Narrator for iOS"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
MOBILE_DIR="$WORKSPACE_DIR/mobile"

# Build configuration
SCHEME="noblenarrator"
CONFIGURATION="Debug"  # Use "Release" for production
WORKSPACE="$MOBILE_DIR/ios/${SCHEME}.xcworkspace"
BUILD_DIR="$MOBILE_DIR/ios/build"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --device)
            BUILD_FOR_DEVICE=true
            shift
            ;;
        --simulator)
            BUILD_FOR_DEVICE=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--release] [--device|--simulator]"
            exit 1
            ;;
    esac
done

cd "$MOBILE_DIR"

###############################################################################
# 1. Clean Previous Build
###############################################################################

print_step "Cleaning previous build..."

if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi

xcodebuild clean \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    > /dev/null 2>&1

print_success "Clean complete"

###############################################################################
# 2. Build for Simulator or Device
###############################################################################

if [ "$BUILD_FOR_DEVICE" = true ]; then
    print_step "Building for iOS Device ($CONFIGURATION)..."

    # Build for device (requires signing)
    xcodebuild build \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination 'generic/platform=iOS' \
        -derivedDataPath "$BUILD_DIR" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO

    print_success "Device build complete"

else
    print_step "Building for iOS Simulator ($CONFIGURATION)..."

    # Get available simulators
    SIMULATOR=$(xcrun simctl list devices available | grep "iPhone" | head -n 1 | sed 's/.*(\(.*\)).*/\1/')

    if [ -z "$SIMULATOR" ]; then
        print_error "No iOS simulator found"
        exit 1
    fi

    print_step "Using simulator: $(xcrun simctl list devices | grep "$SIMULATOR" | sed 's/(.*//' | xargs)"

    # Build for simulator
    xcodebuild build \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "id=$SIMULATOR" \
        -derivedDataPath "$BUILD_DIR"

    print_success "Simulator build complete"
fi

###############################################################################
# 3. Build Statistics
###############################################################################

print_step "Generating build statistics..."

if [ -d "$BUILD_DIR" ]; then
    BUILD_SIZE=$(du -sh "$BUILD_DIR" | cut -f1)
    print_success "Build size: $BUILD_SIZE"
fi

###############################################################################
# Summary
###############################################################################

echo ""
echo "===================================="
echo -e "${GREEN}✓ Build complete!${NC}"
echo "===================================="
echo ""
echo "Build details:"
echo "  • Configuration: $CONFIGURATION"
echo "  • Target: $([ "$BUILD_FOR_DEVICE" = true ] && echo "iOS Device" || echo "iOS Simulator")"
echo "  • Build directory: $BUILD_DIR"
echo ""

if [ "$BUILD_FOR_DEVICE" != true ]; then
    echo "To run the app:"
    echo "  1. Run: npx expo run:ios"
    echo "  2. Or run from Xcode"
fi

echo ""
