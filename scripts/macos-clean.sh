#!/bin/bash

###############################################################################
# macOS Clean Script
# Removes all build artifacts and caches
###############################################################################

echo "🧹 Cleaning Build Artifacts"
echo "============================"
echo ""

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

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
MOBILE_DIR="$WORKSPACE_DIR/mobile"

# Parse arguments
DEEP_CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --deep)
            DEEP_CLEAN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--deep]"
            exit 1
            ;;
    esac
done

cd "$MOBILE_DIR"

###############################################################################
# Standard Clean
###############################################################################

print_step "Removing build artifacts..."

# iOS build folder
if [ -d "ios/build" ]; then
    rm -rf ios/build
    print_success "Removed ios/build"
fi

# Xcode derived data
if [ -d "ios/DerivedData" ]; then
    rm -rf ios/DerivedData
    print_success "Removed ios/DerivedData"
fi

# Metro bundler cache
if [ -d ".expo" ]; then
    rm -rf .expo
    print_success "Removed .expo cache"
fi

# Temporary files
rm -rf /tmp/metro-* /tmp/react-* 2>/dev/null
print_success "Removed Metro temp files"

###############################################################################
# Deep Clean (if requested)
###############################################################################

if [ "$DEEP_CLEAN" = true ]; then
    print_warning "Performing deep clean..."

    # Remove node_modules
    if [ -d "node_modules" ]; then
        print_step "Removing node_modules (this may take a moment)..."
        rm -rf node_modules
        print_success "Removed node_modules"
    fi

    # Remove iOS folder
    if [ -d "ios" ]; then
        rm -rf ios
        print_success "Removed ios folder"
    fi

    # Remove Pods cache
    if [ -d ~/Library/Caches/CocoaPods ]; then
        print_step "Cleaning CocoaPods cache..."
        rm -rf ~/Library/Caches/CocoaPods
        print_success "Cleaned CocoaPods cache"
    fi

    # Remove Watchman cache
    if command -v watchman &> /dev/null; then
        print_step "Cleaning Watchman cache..."
        watchman watch-del-all
        print_success "Cleaned Watchman cache"
    fi

    echo ""
    print_warning "Deep clean complete. You'll need to rebuild:"
    echo "  bun install"
    echo "  ./scripts/macos-prebuild.sh"
fi

###############################################################################
# Summary
###############################################################################

echo ""
echo "============================"
echo -e "${GREEN}✓ Clean complete!${NC}"
echo "============================"
echo ""

if [ "$DEEP_CLEAN" = false ]; then
    echo "Standard clean performed."
    echo ""
    echo "For deep clean (removes node_modules, ios/):"
    echo "  ./scripts/macos-clean.sh --deep"
fi

echo ""
