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
BUILD_FOR_DEVICE=false
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
            echo "Usage: $0 [--release] [--simulator|--device]"
            exit 1
            ;;
    esac
done

# Verify iOS project exists
if [ ! -d "$MOBILE_DIR/ios" ]; then
    print_error "iOS project not found. Run prebuild first:"
    echo "  ./scripts/macos-prebuild.sh"
    exit 1
fi

if [ ! -f "$WORKSPACE" ]; then
    print_error "Xcode workspace not found: $WORKSPACE"
    exit 1
fi

# Create build directory
mkdir -p "$BUILD_DIR"

###############################################################################
# Build for Simulator or Device
###############################################################################

cd "$MOBILE_DIR/ios"

if [ "$BUILD_FOR_DEVICE" = true ]; then
    print_step "Building for physical device ($CONFIGURATION)..."
    
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -sdk iphoneos \
        -derivedDataPath "$BUILD_DIR" \
        build
    
    print_success "Device build complete"
else
    print_step "Building for iOS Simulator ($CONFIGURATION)..."
    
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -sdk iphonesimulator \
        -derivedDataPath "$BUILD_DIR" \
        build
    
    print_success "Simulator build complete"
fi

###############################################################################
# Summary
###############################################################################

echo ""
echo "===================================="
print_success "Build complete!"
echo "===================================="
echo ""
echo "Next step: Run the app:"
echo "  ./scripts/macos-run.sh"
echo ""
