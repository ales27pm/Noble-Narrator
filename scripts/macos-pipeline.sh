#!/bin/bash

###############################################################################
# Complete macOS Build Pipeline
# Runs the entire build process from setup to running the app
###############################################################################

set -e

echo "🚀 Noble Narrator - Complete macOS Build Pipeline"
echo "=================================================="
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

###############################################################################
# Pipeline Steps
###############################################################################

STEPS=(
    "1:Setup macOS Environment:macos-setup.sh"
    "2:Prebuild iOS Project:macos-prebuild.sh"
    "3:Build iOS App:macos-build.sh"
    "4:Run on Simulator:macos-run.sh"
)

# Parse arguments
SKIP_SETUP=false
SKIP_RUN=false
BUILD_RELEASE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-setup)
            SKIP_SETUP=true
            shift
            ;;
        --skip-run)
            SKIP_RUN=true
            shift
            ;;
        --release)
            BUILD_RELEASE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-setup] [--skip-run] [--release]"
            exit 1
            ;;
    esac
done

###############################################################################
# Execute Pipeline
###############################################################################

START_TIME=$(date +%s)

for step in "${STEPS[@]}"; do
    STEP_NUM=$(echo "$step" | cut -d: -f1)
    STEP_NAME=$(echo "$step" | cut -d: -f2)
    STEP_SCRIPT=$(echo "$step" | cut -d: -f3)

    # Skip steps if requested
    if [ "$SKIP_SETUP" = true ] && [ "$STEP_NUM" = "1" ]; then
        print_step "Skipping Step $STEP_NUM: $STEP_NAME"
        continue
    fi

    if [ "$SKIP_RUN" = true ] && [ "$STEP_NUM" = "4" ]; then
        print_step "Skipping Step $STEP_NUM: $STEP_NAME"
        continue
    fi

    echo ""
    echo "=================================================="
    echo -e "${BLUE}STEP $STEP_NUM: $STEP_NAME${NC}"
    echo "=================================================="
    echo ""

    STEP_START=$(date +%s)

    # Execute step
    if [ "$STEP_NUM" = "3" ] && [ "$BUILD_RELEASE" = true ]; then
        bash "$SCRIPT_DIR/$STEP_SCRIPT" --release
    else
        bash "$SCRIPT_DIR/$STEP_SCRIPT"
    fi

    STEP_END=$(date +%s)
    STEP_DURATION=$((STEP_END - STEP_START))

    echo ""
    print_success "Step $STEP_NUM completed in ${STEP_DURATION}s"
done

END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))

###############################################################################
# Summary
###############################################################################

echo ""
echo "=================================================="
echo -e "${GREEN}✓ Pipeline Complete!${NC}"
echo "=================================================="
echo ""
echo "Total time: ${TOTAL_DURATION}s"
echo ""
echo "Your app is ready!"
echo ""
