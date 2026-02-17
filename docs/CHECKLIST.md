# macOS Build Checklist

Use this checklist to ensure everything is ready for building on macOS.

## 📋 Pre-Build Checklist

### ✅ System Requirements

- [ ] Running macOS 12.0 or later
- [ ] At least 20GB free disk space
- [ ] Stable internet connection (for downloads)

### ✅ Software Installation

- [ ] **Xcode** installed from Mac App Store
  - [ ] Xcode 15.0 or later
  - [ ] Opened Xcode at least once
  - [ ] License agreement accepted
  - [ ] Command Line Tools installed: `xcode-select --install`

- [ ] **Homebrew** installed
  - [ ] Can run: `brew --version`

- [ ] **Node.js** installed
  - [ ] Can run: `node --version`
  - [ ] Version 18 or later

- [ ] **Bun** installed
  - [ ] Can run: `bun --version`

- [ ] **CocoaPods** installed
  - [ ] Can run: `pod --version`

- [ ] **Git** configured
  - [ ] Can run: `git --version`
  - [ ] Git user configured

### ✅ iOS Simulators

- [ ] At least one iOS simulator installed
  - [ ] Check: `xcrun simctl list devices available | grep iPhone`
  - [ ] iOS 17.0+ recommended
  - [ ] Installed via Xcode > Settings > Platforms

### ✅ Project Setup

- [ ] Repository cloned
- [ ] All scripts are executable: `ls -la scripts/`
- [ ] Can access workspace directory

## 🔧 Build Process Checklist

### Step 1: Validation
```bash
./scripts/macos-validate.sh
```
- [ ] All required tools found
- [ ] No errors reported
- [ ] Project structure verified

### Step 2: Environment Setup
```bash
./scripts/macos-setup.sh
```
- [ ] Script completed without errors
- [ ] All tools installed
- [ ] PATH configured correctly

### Step 3: Prebuild
```bash
./scripts/macos-prebuild.sh
```
- [ ] JavaScript dependencies installed
- [ ] iOS project generated in `mobile/ios/`
- [ ] CocoaPods dependencies installed
- [ ] `noblenarrator.xcworkspace` exists
- [ ] Native module linked (narrator-turbo)

### Step 4: Build
```bash
./scripts/macos-build.sh
```
- [ ] Build completed successfully
- [ ] No Swift compilation errors
- [ ] Build artifacts in `mobile/ios/build/`

### Step 5: Run
```bash
./scripts/macos-run.sh
```
- [ ] iOS Simulator launches
- [ ] App installs on simulator
- [ ] App launches without crashing
- [ ] Metro bundler running

## 🎯 Post-Build Verification

### ✅ App Functionality
- [ ] App launches and shows UI
- [ ] No JavaScript errors in console
- [ ] Native module (narrator-turbo) works
- [ ] Text-to-speech functionality works
- [ ] Hot reload works for JS changes

### ✅ Development Workflow
- [ ] Can edit JavaScript files and see changes
- [ ] Can rebuild native code when needed
- [ ] Can launch on different simulators
- [ ] Metro bundler responds to commands

## 🔄 Continuous Development Checklist

### Daily Workflow
- [ ] Start Metro: `cd mobile && bun start`
- [ ] Run app: `./scripts/macos-run.sh`
- [ ] Make changes and test

### After Native Code Changes
- [ ] Stop the app
- [ ] Rebuild: `./scripts/macos-build.sh`
- [ ] Re-run: `./scripts/macos-run.sh`

### Weekly Maintenance
- [ ] Update dependencies: `cd mobile && bun update`
- [ ] Update CocoaPods: `cd mobile/ios && pod update`
- [ ] Clean build: `./scripts/macos-clean.sh --deep`
- [ ] Fresh rebuild: `./scripts/macos-prebuild.sh`

## 🚨 Troubleshooting Checklist

### If Build Fails
- [ ] Run validation: `./scripts/macos-validate.sh`
- [ ] Check Xcode is up to date
- [ ] Clean build: `./scripts/macos-clean.sh --deep`
- [ ] Rebuild from scratch: `./scripts/macos-prebuild.sh`
- [ ] Check logs in `mobile/ios/build/`

### If App Won't Run
- [ ] Simulator is open and responsive
- [ ] Metro bundler is running
- [ ] No port conflicts (8081, 3000)
- [ ] Check `mobile/expo.log` for errors

### If Native Module Fails
- [ ] Verify files exist:
  - [ ] `mobile/modules/narrator-turbo/ios/NarratorTurboModule.swift`
  - [ ] `mobile/modules/narrator-turbo/narrator-turbo-module.podspec`
- [ ] Check Podfile.lock: `grep narrator-turbo mobile/ios/Podfile.lock`
- [ ] Reinstall pods: `cd mobile/ios && pod install`

## 📦 Production Build Checklist

### Before Release Build
- [ ] All features tested
- [ ] No console errors or warnings
- [ ] Update version in `mobile/app.json`
- [ ] Update build number
- [ ] Clean build directory

### Release Build Steps
- [ ] Build release: `./scripts/macos-build.sh --release`
- [ ] Test release build on simulator
- [ ] Verify app performance
- [ ] Check app size

### App Store Submission (via EAS)
- [ ] EAS CLI installed: `npm install -g eas-cli`
- [ ] Logged in: `eas login`
- [ ] Configure build: `eas build:configure`
- [ ] Build for iOS: `eas build --platform ios`
- [ ] Submit: `eas submit --platform ios`

## 🎓 Learning Checklist

### Understanding the Build
- [ ] Read MACOS_BUILD_GUIDE.md
- [ ] Understand Expo prebuild process
- [ ] Know how CocoaPods works
- [ ] Understand native module structure
- [ ] Familiar with Xcode workspace structure

### Command Mastery
- [ ] Know all script purposes
- [ ] Can run validation
- [ ] Can clean and rebuild
- [ ] Can switch between simulators
- [ ] Can build for release

## 📊 Status Indicators

Use this section to track your current status:

**Last Successful Build:**
- Date: _____________
- Configuration: [ ] Debug [ ] Release
- Target: [ ] Simulator [ ] Device

**Current Issues:**
1. _____________
2. _____________
3. _____________

**Next Steps:**
1. _____________
2. _____________
3. _____________

---

## ✅ Quick Status Check

Run this command to check everything at once:
```bash
./scripts/macos-validate.sh && echo "✓ All systems go!"
```

Expected output:
- ✓ All required tools found
- ✓ iOS simulators available
- ✓ Project structure correct
- ✓ All systems go!

---

**Last Updated:** February 2026
