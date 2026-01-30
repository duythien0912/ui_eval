#!/usr/bin/env node
const esbuild = require("esbuild");
const fs = require("fs");
const path = require("path");

const MODULES_DIR = path.join(__dirname, "modules");
const OUTPUT_DIR = path.join(__dirname, "..", "assets", "logic");
const SDK_PATH = path.join(__dirname, "..", "ts_sdk", "dist");

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

function ensureOutputDir() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }
}

async function buildAll(watch = false) {
  const entries = scanModules();
  if (Object.keys(entries).length === 0) {
    console.log("No modules found!");
    return;
  }

  console.log(`Building ${Object.keys(entries).length} module(s)...`);
  ensureOutputDir();

  const builds = Object.entries(entries).map(([modName, entryPoint]) => {
    const outputFile = path.join(OUTPUT_DIR, `${modName}.js`);

    const config = {
      entryPoints: [entryPoint],
      bundle: true,
      format: "iife",
      globalName: `AppLogic_${modName}`,
      outfile: outputFile,
      platform: "browser",
      target: "es2020",
      minify: false,
      sourcemap: true,
      external: [],
      alias: { "@ui_eval/sdk": SDK_PATH },
      define: {
        "process.env.NODE_ENV": '"production"',
        __MODULE_ID__: `"${modName}"`,
      },
      banner: { js: `// ${modName} logic bundle\n// Module ID: ${modName}\n` },
    };

    if (watch) {
      return esbuild.context(config).then((ctx) => {
        console.log(`Watching: ${modName}/`);
        return ctx.watch();
      });
    } else {
      return esbuild.build(config).then(() => {
        const stats = fs.statSync(outputFile);
        console.log(
          `Built: ${modName}.js (${(stats.size / 1024).toFixed(2)} KB)`
        );
      });
    }
  });

  await Promise.all(builds);
  if (!watch) console.log("All builds complete!");
}

function generateManifest() {
  const entries = scanModules();
  const manifest = {
    generatedAt: new Date().toISOString(),
    modules: Object.keys(entries).map((name) => ({
      name,
      logicFile: `assets/logic/${name}.js`,
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

  console.log("ui_eval Module Build Pipeline\n");
  await buildAll(watch);
  if (!watch) generateManifest();
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
