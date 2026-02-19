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

# Remove iOS build directory
if [ -d "ios/build" ]; then
    rm -rf ios/build
    print_success "Removed iOS build directory"
fi

# Remove derived data
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA" ]; then
    print_warning "Xcode DerivedData exists (not removing by default)"
    echo "  Location: $DERIVED_DATA"
    echo "  Use --deep to remove"
fi

# Clean Expo cache
print_step "Cleaning Expo cache..."
bunx expo start --clear --minify 2>/dev/null || true
print_success "Expo cache cleared"

# Clean node_modules (optional in deep clean)
if [ "$DEEP_CLEAN" = true ]; then
    print_step "Deep cleaning enabled..."
    
    # Remove node_modules
    if [ -d "node_modules" ]; then
        rm -rf node_modules
        print_success "Removed node_modules"
    fi
    
    # Remove iOS folder
    if [ -d "ios" ]; then
        rm -rf ios
        print_success "Removed iOS project folder"
    fi
    
    # Remove bun lockfile
    if [ -f "bun.lockb" ]; then
        rm bun.lockb
        print_success "Removed bun.lockb"
    fi
    
    # Remove Xcode DerivedData
    if [ -d "$DERIVED_DATA" ]; then
        rm -rf "$DERIVED_DATA"
        print_success "Removed Xcode DerivedData"
    fi
    
    # Remove Metro cache
    print_step "Removing Metro cache..."
    rm -rf "$TMPDIR/metro-"* "$TMPDIR/haste-map-"* 2>/dev/null || true
    print_success "Metro cache removed"
fi

###############################################################################
# Summary
###############################################################################

echo ""
echo "============================"
print_success "Clean complete!"
echo "============================"
echo ""
if [ "$DEEP_CLEAN" = true ]; then
    echo "Deep clean performed. Run setup and prebuild again:"
    echo "  ./scripts/macos-setup.sh"
    echo "  ./scripts/macos-prebuild.sh"
else
    echo "Standard clean performed."
fi
echo ""
