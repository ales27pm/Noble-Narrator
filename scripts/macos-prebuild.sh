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

print_step "Running Expo prebuild for iOS..."

# Clean previous iOS build if exists
if [ -d "ios" ]; then
    print_step "Cleaning previous iOS build..."
    rm -rf ios
fi

# Run prebuild
npx expo prebuild --platform ios --clean

print_success "iOS project generated"

###############################################################################
# 3. Install CocoaPods Dependencies
###############################################################################

print_step "Installing CocoaPods dependencies..."

cd ios

# Update CocoaPods repo (optional, can be slow)
# pod repo update

# Install pods
pod install

print_success "CocoaPods dependencies installed"

cd "$MOBILE_DIR"

###############################################################################
# 4. Link Native Module
###############################################################################

print_step "Verifying native module linking..."

# The narrator-turbo module should be auto-linked by Expo
# Check if it's in the Podfile
if grep -q "narrator-turbo-module" ios/Podfile.lock; then
    print_success "Native module linked successfully"
else
    print_error "Native module not linked. Check expo-module.config.js"
fi

###############################################################################
# 5. Configure Build Settings
###############################################################################

print_step "Configuring build settings..."

# Create or update .xcode.env file for Node binary path
cat > ios/.xcode.env.local << EOF
export NODE_BINARY=$(command -v node)
EOF

print_success "Build settings configured"

###############################################################################
# 6. Verify Project Structure
###############################################################################

print_step "Verifying project structure..."

REQUIRED_FILES=(
    "ios/noblenarrator.xcworkspace"
    "ios/Podfile"
    "ios/Pods"
    "modules/narrator-turbo/ios/NarratorTurboModule.swift"
    "modules/narrator-turbo/narrator-turbo-module.podspec"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -e "$file" ]; then
        print_error "Missing: $file"
        exit 1
    fi
done

print_success "Project structure verified"

###############################################################################
# Summary
###############################################################################

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Pre-build complete!${NC}"
echo "=========================================="
echo ""
echo "Project ready for compilation:"
echo "  • iOS project: mobile/ios/noblenarrator.xcworkspace"
echo "  • Native module: modules/narrator-turbo"
echo "  • CocoaPods: Installed and configured"
echo ""
echo "Next step:"
echo "  Run: ./scripts/macos-build.sh"
echo ""
