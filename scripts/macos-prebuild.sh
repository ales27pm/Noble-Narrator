#!/bin/bash

###############################################################################
# macOS Pre-build Script
# Prepares the project for iOS compilation
###############################################################################

set -e

echo "🔧 Preparing Noble Narrator for iOS build"
echo "=========================================="

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

cd "$MOBILE_DIR"

###############################################################################
# 1. Install Dependencies
###############################################################################

print_step "Installing JavaScript dependencies..."
bun install
print_success "Dependencies installed"

###############################################################################
# 2. Generate iOS Project with Expo Prebuild
###############################################################################

print_step "Generating iOS project with Expo prebuild..."

# Clean existing iOS folder if needed
if [ -d "ios" ]; then
    print_step "Cleaning existing iOS project..."
    rm -rf ios
fi

# Generate iOS project
bunx expo prebuild --platform ios --clean
print_success "iOS project generated"

###############################################################################
# 3. Install CocoaPods Dependencies
###############################################################################

print_step "Installing CocoaPods dependencies..."
cd ios
pod install
print_success "CocoaPods dependencies installed"

###############################################################################
# 4. Verify Build Configuration
###############################################################################

print_step "Verifying build configuration..."

if [ ! -f "${SCHEME}.xcworkspace" ]; then
    print_error "Xcode workspace not found"
    exit 1
fi

print_success "Build configuration verified"

###############################################################################
# Summary
###############################################################################

echo ""
echo "=========================================="
print_success "Prebuild complete!"
echo "=========================================="
echo ""
echo "Next step: Build the app:"
echo "  ./scripts/macos-build.sh"
echo ""
