// metro.config.js
// NOTE TO AI: Do note change this file unless you are 110% sure you know what you are doing. It will likely break the app.

const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require("nativewind/metro");
const { withVibecodeMetro } = require("@vibecodeapp/sdk/metro");
const path = require("path");
const fs = require("fs");

/** @type {import('expo/metro-config').MetroConfig} */
const config = getDefaultConfig(__dirname);

// Only configure shared folder if it exists (may not exist during Docker build)
const sharedFolder = path.resolve(__dirname, "../shared");
const sharedFolderExists = fs.existsSync(sharedFolder);

// DEBUG: Log metro.config.js version and shared folder status at startup
console.log("[Metro Config] Version: 2025-02-03-v3-fix-dynamic-imports (source: workspace-mobile)");
console.log(`[Metro Config] Shared folder: ${sharedFolder}`);
console.log(`[Metro Config] Shared folder exists: ${sharedFolderExists}`);

if (sharedFolderExists) {
  config.watchFolders = [sharedFolder];
}

// Disable Watchman for file watching.
config.resolver.useWatchman = false;

// Configure asset and source extensions.
const { assetExts, sourceExts } = config.resolver;
config.resolver.assetExts = assetExts.filter((ext) => ext !== "svg");
config.resolver.sourceExts = [...sourceExts, "svg"];

// Handle custom module resolution for shared folder.
config.resolver.extraNodeModules = {
  ...(config.resolver.extraNodeModules || {}),
  "@shared": sharedFolder,
};

// Configure transformer for SVG support.
config.transformer = {
  ...(config.transformer || {}),
  babelTransformerPath: require.resolve("react-native-svg-transformer"),
};

// Some packages ship ESM-only builds; Metro sometimes needs this.
config.transformer.getTransformOptions = async () => ({
  transform: {
    experimentalImportSupport: true,
    inlineRequires: false,
  },
});

// Apply NativeWind + Vibecode Metro wrappers.
module.exports = withVibecodeMetro(withNativeWind(config));
