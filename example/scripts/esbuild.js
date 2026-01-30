#!/usr/bin/env node
const esbuild = require("esbuild");
const fs = require("fs");
const path = require("path");

const MODULES_DIR = path.join(__dirname, "..", "modules");
const OUTPUT_DIR = path.join(__dirname, "..", "assets", "logic");
const APPS_DIR = path.join(__dirname, "..", "assets", "apps");
const SDK_PATH = path.join(__dirname, "..", "..", "ts_sdk", "dist");

function scanModules() {
  const entries = {};
  if (!fs.existsSync(MODULES_DIR)) return entries;

  const modules = fs
    .readdirSync(MODULES_DIR, { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => d.name);

  for (const mod of modules) {
    const modDir = path.join(MODULES_DIR, mod, "lib");
    const shortMod = mod.replace("_app", "");
    const possibleFiles = [`${shortMod}_logic.ts`, "logic.ts", "index.ts"];

    for (const file of possibleFiles) {
      const filePath = path.join(modDir, file);
      if (fs.existsSync(filePath)) {
        entries[mod] = filePath;
        console.log(`Found module: ${mod}/`);
        break;
      }
    }
  }
  return entries;
}

function loadUiDefinition(moduleName) {
  const uiPath = path.join(APPS_DIR, `${moduleName}.json`);
  if (fs.existsSync(uiPath)) {
    return JSON.parse(fs.readFileSync(uiPath, "utf-8"));
  }
  return null;
}

function ensureOutputDir() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }
}

async function buildBundle(moduleName, entryPoint, watch = false) {
  const outputJsFile = path.join(OUTPUT_DIR, `${moduleName}.js`);
  const outputBundleFile = path.join(OUTPUT_DIR, `${moduleName}.bundle`);
  
  // Load UI definition
  const uiDef = loadUiDefinition(moduleName);
  if (!uiDef) {
    console.warn(`Warning: No UI definition found for ${moduleName}`);
  }

  const config = {
    entryPoints: [entryPoint],
    bundle: true,
    format: "iife",
    globalName: `AppLogic_${moduleName}`,
    outfile: outputJsFile,
    platform: "browser",
    target: "es2020",
    minify: false,
    sourcemap: false,
    external: [],
    alias: { "@ui_eval/sdk": SDK_PATH },
    define: {
      "process.env.NODE_ENV": '"production"',
      __MODULE_ID__: `"${moduleName}"`,
    },
  };

  if (watch) {
    const ctx = await esbuild.context(config);
    console.log(`Watching: ${moduleName}/`);
    await ctx.watch();
    return;
  }

  await esbuild.build(config);

  // Read the generated JS
  const jsCode = fs.readFileSync(outputJsFile, "utf-8");

  // Create the bundle format
  const bundle = {
    format: "ui_eval_bundle_v1",
    moduleId: moduleName,
    generatedAt: new Date().toISOString(),
    ui: uiDef,
    logic: jsCode,
  };

  // Write bundle file
  fs.writeFileSync(outputBundleFile, JSON.stringify(bundle, null, 2));

  // Clean up separate JS file (optional - keep for debugging)
  // fs.unlinkSync(outputJsFile);

  const stats = fs.statSync(outputBundleFile);
  console.log(`Built: ${moduleName}.bundle (${(stats.size / 1024).toFixed(2)} KB)`);
}

async function buildAll(watch = false) {
  const entries = scanModules();
  if (Object.keys(entries).length === 0) {
    console.log("No modules found!");
    return;
  }

  console.log(`Building ${Object.keys(entries).length} module(s)...\n`);
  ensureOutputDir();

  if (watch) {
    for (const [modName, entryPoint] of Object.entries(entries)) {
      await buildBundle(modName, entryPoint, true);
    }
  } else {
    for (const [modName, entryPoint] of Object.entries(entries)) {
      await buildBundle(modName, entryPoint, false);
    }
    console.log("\nAll builds complete!");
  }
}

function generateManifest() {
  const entries = scanModules();
  const manifest = {
    generatedAt: new Date().toISOString(),
    modules: Object.keys(entries).map((name) => ({
      name,
      bundleFile: `assets/logic/${name}.bundle`,
    })),
  };
  fs.writeFileSync(
    path.join(OUTPUT_DIR, "manifest.json"),
    JSON.stringify(manifest, null, 2)
  );
}

async function main() {
  const args = process.argv.slice(2);
  const watch = args.includes("--watch");

  console.log("ui_eval Bundle Build Pipeline\n");
  await buildAll(watch);
  if (!watch) generateManifest();
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
