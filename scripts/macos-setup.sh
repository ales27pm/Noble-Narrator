#!/bin/bash

###############################################################################
# macOS Development Environment Setup Script
# For Noble Narrator - Expo React Native App
###############################################################################

set -e  # Exit on error

MACOS_MAJOR="$(sw_vers -productVersion | cut -d. -f1)"

echo "🚀 Setting up macOS development environment for Noble Narrator"
echo "================================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must be run on macOS"
    exit 1
fi

print_success "Running on macOS"

###############################################################################
# 1. Check Xcode Installation
###############################################################################

print_step "Checking Xcode installation..."

if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode not found"
    echo "Please install Xcode from the Mac App Store"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1)
print_success "Found $XCODE_VERSION"

# Accept Xcode license if needed
print_step "Checking Xcode license..."
if ! xcodebuild -license check &> /dev/null; then
    print_warning "Xcode license not accepted. Accepting..."
    sudo xcodebuild -license accept
fi
print_success "Xcode setup complete"

###############################################################################
# 2. Install Homebrew
###############################################################################

print_step "Checking Homebrew installation..."

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_step "Updating Homebrew..."
brew update
print_success "Homebrew updated"

###############################################################################
# 3. Install Node.js
###############################################################################

print_step "Checking Node.js installation..."

if ! command -v node &> /dev/null; then
    print_warning "Node.js not found. Installing..."
    brew install node
else
    NODE_VERSION=$(node --version)
    print_success "Node.js $NODE_VERSION installed"
fi

###############################################################################
# 4. Install Bun
###############################################################################

print_step "Checking Bun installation..."

if ! command -v bun &> /dev/null; then
    print_warning "Bun not found. Installing..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
else
    print_success "Bun already installed"
fi

BUN_VERSION=$(bun --version)
print_success "Bun $BUN_VERSION ready"

###############################################################################
# 5. Install CocoaPods
###############################################################################

print_step "Checking CocoaPods installation..."

if ! command -v pod &> /dev/null; then
    print_warning "CocoaPods not found. Installing..."
    sudo gem install cocoapods
else
    POD_VERSION=$(pod --version)
    print_success "CocoaPods already installed"
    print_success "CocoaPods $POD_VERSION ready"
fi

###############################################################################
# 6. Check iOS Simulators
###############################################################################

print_step "Checking iOS Simulators..."

SIMULATORS=$(xcrun simctl list devices available 2>/dev/null | grep -c "iPhone" || echo "0")

if [ "$SIMULATORS" -eq 0 ]; then
    print_warning "No iOS simulators found"
    echo "Please install iOS simulators in Xcode:"
    echo "Xcode > Preferences > Components"
    open -a Xcode
else
    print_success "Found $SIMULATORS iOS simulator(s)"
fi

###############################################################################
# 7. Install Watchman (optional but recommended)
###############################################################################

print_step "Checking Watchman installation..."

if ! command -v watchman &> /dev/null; then
    print_warning "Watchman not found."
    if [ "$MACOS_MAJOR" -le 12 ]; then
        print_warning "Skipping Watchman install on macOS 12 (Homebrew compiles heavy deps and often fails)."
        print_warning "Metro can run without Watchman."
    else
        print_warning "Attempting Watchman install (optional)..."
        brew install watchman || print_warning "Watchman install failed (ok). Continuing without it."
    fi
else
    print_success "Watchman already installed"
fi

###############################################################################
# 8. Install EAS CLI
###############################################################################

print_step "Checking EAS CLI installation..."

if ! command -v eas &> /dev/null; then
    print_warning "EAS CLI not found. Installing..."
    npm install -g eas-cli
else
    print_success "EAS CLI already installed"
fi

###############################################################################
# Summary
###############################################################################

echo ""
echo "================================================================"
print_success "macOS development environment setup complete!"
echo "================================================================"
echo ""
echo "Next steps:"
echo "1. Validate environment:"
echo "   ./scripts/macos-validate.sh"
echo ""
echo "2. Run the full build pipeline:"
echo "   ./scripts/macos-pipeline.sh"
echo ""
