#!/usr/bin/env node
/**
 * ui_eval Build Pipeline
 * 
 * This script compiles Dart DSL + TypeScript logic into single .bundle files
 * 
 * Usage:
 *   node build.js                    # Build all modules
 *   node build.js --watch            # Watch mode
 *   node build.js counter_app        # Build specific module
 */

const { execSync } = require("child_process");
const esbuild = require("esbuild");
const fs = require("fs");
const path = require("path");

const MODULES_DIR = path.join(__dirname, "..", "modules");
const OUTPUT_DIR = path.join(__dirname, "..", "assets", "logic");
const SDK_PATH = path.join(__dirname, "..", "..", "ts_sdk", "dist");

function scanModules() {
  const modules = [];
  if (!fs.existsSync(MODULES_DIR)) return modules;

  const entries = fs.readdirSync(MODULES_DIR, { withFileTypes: true });
  
  for (const entry of entries) {
    if (entry.isDirectory() && !entry.name.startsWith('.')) {
      const modDir = path.join(MODULES_DIR, entry.name, "lib");
      const shortMod = entry.name.replace("_app", "");
      
      // Find UI file
      const uiFile = path.join(modDir, `${shortMod}_ui.dart`);
      const altUiFile = path.join(modDir, "ui.dart");
      const finalUiFile = fs.existsSync(uiFile) ? uiFile : 
                          (fs.existsSync(altUiFile) ? altUiFile : null);
      
      // Find logic file
      const logicFile = path.join(modDir, `${shortMod}_logic.ts`);
      const altLogicFile = path.join(modDir, "logic.ts");
      const finalLogicFile = fs.existsSync(logicFile) ? logicFile :
                             (fs.existsSync(altLogicFile) ? altLogicFile : null);
      
      if (finalUiFile || finalLogicFile) {
        modules.push({
          name: entry.name,
          uiFile: finalUiFile,
          logicFile: finalLogicFile,
        });
      }
    }
  }
  
  return modules;
}

function compileDSL(module) {
  if (!module.uiFile) {
    console.log(`  No DSL file found for ${module.name}`);
    return null;
  }

  console.log(`  Compiling DSL...`);
  
  try {
    // Run the Dart file to get JSON output
    const result = execSync(`cd ${path.dirname(module.uiFile)} && dart ${path.basename(module.uiFile)}`, {
      encoding: 'utf-8',
      timeout: 30000,
    });
    
    // Parse and return the JSON
    return JSON.parse(result.trim());
  } catch (e) {
    console.error(`    Error: ${e.message}`);
    return null;
  }
}

async function compileLogic(module) {
  if (!module.logicFile) {
    console.log(`  No logic file found for ${module.name}`);
    return null;
  }

  console.log(`  Compiling Logic...`);
  
  // Use esbuild to bundle the TypeScript
  const result = await esbuild.build({
    entryPoints: [module.logicFile],
    bundle: true,
    format: "iife",
    globalName: `AppLogic_${module.name}`,
    write: false, // Don't write to file, return as string
    platform: "browser",
    target: "es2020",
    minify: false,
    sourcemap: false,
    external: [],
    alias: { "@ui_eval/sdk": SDK_PATH },
    define: {
      "process.env.NODE_ENV": '"production"',
      __MODULE_ID__: `"${module.name}"`,
    },
  });

  return result.outputFiles[0].text;
}

async function createBundle(module, uiJson, jsCode) {
  if (!uiJson || !jsCode) {
    console.log(`  Skipping bundle (missing ${!uiJson ? 'UI' : ''}${!uiJson && !jsCode ? ' and ' : ''}${!jsCode ? 'Logic' : ''})`);
    return;
  }

  console.log(`  Creating bundle...`);
  
  const bundle = {
    format: "ui_eval_bundle_v1",
    moduleId: module.name,
    generatedAt: new Date().toISOString(),
    ui: uiJson,
    logic: jsCode,
  };

  const outputBundleFile = path.join(OUTPUT_DIR, `${module.name}.bundle`);
  fs.writeFileSync(outputBundleFile, JSON.stringify(bundle, null, 2));

  const stats = fs.statSync(outputBundleFile);
  console.log(`    Written: ${module.name}.bundle (${(stats.size / 1024).toFixed(2)} KB)`);
}

function generateManifest(modules) {
  const manifest = {
    generatedAt: new Date().toISOString(),
    modules: modules.map(m => ({
      name: m.name,
      bundleFile: `assets/logic/${m.name}.bundle`,
    })),
  };
  
  fs.writeFileSync(
    path.join(OUTPUT_DIR, "manifest.json"),
    JSON.stringify(manifest, null, 2)
  );
  
  console.log(`  Written: manifest.json`);
}

async function buildModule(module) {
  console.log(`\n[${module.name}]`);
  
  // Step 1: Compile DSL to JSON (in memory)
  const uiJson = compileDSL(module);
  
  // Step 2: Compile TypeScript to JS (in memory)
  const jsCode = await compileLogic(module);
  
  // Step 3: Create bundle
  await createBundle(module, uiJson, jsCode);
}

async function buildAll(targetModule = null) {
  const modules = scanModules();
  
  if (modules.length === 0) {
    console.log("No modules found!");
    return;
  }

  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  console.log(`Found ${modules.length} module(s)\n`);

  for (const module of modules) {
    if (targetModule && module.name !== targetModule) continue;
    await buildModule(module);
  }

  // Generate manifest
  console.log(`\n[Manifest]`);
  generateManifest(modules.filter(m => !targetModule || m.name === targetModule));

  console.log("\n✅ Build complete!");
}

async function main() {
  const args = process.argv.slice(2);
  const targetModule = args.find(a => !a.startsWith('--'));

  console.log("ui_eval Build Pipeline");
  console.log("======================\n");
  
  await buildAll(targetModule);
}

main().catch((err) => {
  console.error("\n❌ Error:", err.message);
  console.error(err.stack);
  process.exit(1);
});
