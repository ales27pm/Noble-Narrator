#!/bin/bash

###############################################################################
# macOS Development Mode
# Runs Metro bundler and opens simulator for active development
###############################################################################

set -e

echo "🔥 Starting Development Mode"
echo "============================="
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

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
MOBILE_DIR="$WORKSPACE_DIR/mobile"

cd "$MOBILE_DIR"

###############################################################################
# Check if iOS project exists
###############################################################################

if [ ! -d "ios/Pods" ]; then
    print_error "iOS project not built yet"
    echo ""
    echo "Please run prebuild first:"
    echo "  ./scripts/macos-prebuild.sh"
    echo ""
    exit 1
fi

###############################################################################
# Start Development
###############################################################################

print_step "Starting development environment..."
echo ""
echo "This will:"
echo "  1. Start Metro bundler"
echo "  2. Open iOS Simulator"
echo "  3. Launch the app"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start with clearing cache option
print_step "Starting Metro bundler..."

# Ask if user wants to clear cache
read -p "Clear Metro cache? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Clearing cache..."
    npx expo start --clear
else
    npx expo start
fi

print_success "Development server stopped"
