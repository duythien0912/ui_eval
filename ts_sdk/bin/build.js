#!/usr/bin/env node

/**
 * UI Eval Build Script
 *
 * Complete build pipeline:
 * 1. Compile Dart UI files to JSON (using Flutter context from example app)
 * 2. Bundle TypeScript logic to JavaScript strings
 * 3. Combine into final JSON bundles
 *
 * Usage:
 *   ui-eval-build                    # Build all modules
 *   ui-eval-build --watch            # Watch mode
 *   ui-eval-build counter_app        # Build specific module
 */

const esbuild = require('esbuild');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

// Configuration - resolve paths from current working directory
const CWD = process.cwd();
// Detect if we're running from example/ or example/modules/
const isInModulesDir = fs.existsSync(path.join(CWD, 'package.json')) &&
                       fs.existsSync(path.join(CWD, 'counter_app'));
const MODULES_DIR = isInModulesDir ? CWD : path.join(CWD, 'modules');
const OUTPUT_DIR = isInModulesDir ? path.join(CWD, '..', 'assets') : path.join(CWD, 'assets');
const EXAMPLE_DIR = isInModulesDir ? path.join(CWD, '..') : CWD;
const TS_SDK_DIR = path.resolve(__dirname, '..');

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

/**
 * Scan modules directory and find all modules with UI and logic files
 */
function scanModules() {
  const modules = [];

  if (!fs.existsSync(MODULES_DIR)) {
    log('Modules directory not found!', 'red');
    log(`Expected: ${MODULES_DIR}`, 'yellow');
    return modules;
  }

  const entries = fs.readdirSync(MODULES_DIR, { withFileTypes: true });

  for (const entry of entries) {
    if (entry.isDirectory() && !entry.name.startsWith('.')) {
      const moduleName = entry.name;
      const moduleDir = path.join(MODULES_DIR, moduleName);
      const libDir = path.join(moduleDir, 'lib');

      if (!fs.existsSync(libDir)) continue;

      // Look for UI Dart file
      const shortName = moduleName.replace('_app', '');
      const uiDartFile = path.join(libDir, `${shortName}_ui.dart`);

      // Look for logic TypeScript file
      const logicTsFile = path.join(libDir, `${shortName}_logic.ts`);

      // Module must have at least UI file
      if (fs.existsSync(uiDartFile)) {
        modules.push({
          name: moduleName,
          moduleDir,
          uiDartFile,
          logicTsFile: fs.existsSync(logicTsFile) ? logicTsFile : null,
          outputFile: path.join(OUTPUT_DIR, `${moduleName}.bundle`),
        });
      }
    }
  }

  return modules;
}

/**
 * Compile Dart UI file to JSON (runs from example directory for Flutter context)
 */
async function compileDartUI(module) {
  log(`  Compiling Dart UI: ${path.basename(module.uiDartFile)}`, 'cyan');

  // Create a temporary compilation script in the example directory
  const tempScript = `
import 'dart:convert';
import 'package:ui_eval/dsl_only.dart';

// Import the module UI file using relative path from example directory
import 'modules/${module.name}/lib/${path.basename(module.uiDartFile)}';

void main() {
  final app = ${toPascalCase(module.name.replace('_app', ''))}MiniApp();
  final json = app.program.toJson();
  print('__JSON_START__');
  print(jsonEncode(json));
  print('__JSON_END__');
}
`;

  const tempFile = path.join(EXAMPLE_DIR, `.temp_compile_${module.name}.dart`);
  fs.writeFileSync(tempFile, tempScript);

  try {
    // Run from example directory where Flutter context exists
    const result = execSync(`dart run ${path.basename(tempFile)}`, {
      cwd: EXAMPLE_DIR,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    const startIdx = result.indexOf('__JSON_START__');
    const endIdx = result.indexOf('__JSON_END__');

    if (startIdx === -1 || endIdx === -1) {
      throw new Error('Could not find JSON markers in Dart output');
    }

    const jsonStr = result.substring(startIdx + '__JSON_START__'.length, endIdx).trim();
    const uiJson = JSON.parse(jsonStr);

    log(`    ✓ UI compiled`, 'green');
    return uiJson;
  } catch (error) {
    log(`    ✗ Failed to compile Dart UI`, 'red');
    if (error.stderr) {
      console.error(error.stderr.toString());
    }
    throw error;
  } finally {
    if (fs.existsSync(tempFile)) {
      fs.unlinkSync(tempFile);
    }
  }
}

/**
 * Bundle TypeScript logic to JavaScript string
 */
async function bundleTypeScriptLogic(module) {
  if (!module.logicTsFile) {
    log(`  No TypeScript logic file found, using empty logic`, 'yellow');
    return '';
  }

  log(`  Bundling TypeScript logic: ${path.basename(module.logicTsFile)}`, 'cyan');

  const tempOutFile = path.join(module.moduleDir, '.temp_logic_bundle.js');

  try {
    await esbuild.build({
      entryPoints: [module.logicTsFile],
      bundle: true,
      outfile: tempOutFile,
      platform: 'neutral',
      format: 'iife',
      target: 'es2020',
      minify: false,
      sourcemap: false,
      external: [],
      alias: {
        '@ui_eval/sdk': path.join(TS_SDK_DIR, 'dist/index.js'),
      },
    });

    const logicCode = fs.readFileSync(tempOutFile, 'utf8');
    log(`    ✓ Logic bundled (${(logicCode.length / 1024).toFixed(2)} KB)`, 'green');
    return logicCode;
  } catch (error) {
    log(`    ✗ Failed to bundle TypeScript logic`, 'red');
    console.error(error);
    throw error;
  } finally {
    if (fs.existsSync(tempOutFile)) {
      fs.unlinkSync(tempOutFile);
    }
  }
}

/**
 * Build a single module (UI + Logic → JSON bundle)
 */
async function buildModule(module) {
  log(`Building ${module.name}...`, 'blue');

  try {
    // Step 1: Compile Dart UI to JSON
    const uiJson = await compileDartUI(module);

    // Step 2: Bundle TypeScript logic to JS string
    const logicCode = await bundleTypeScriptLogic(module);

    // Step 3: Create final JSON bundle
    const bundle = {
      format: 'ui_eval_bundle_v1',
      moduleId: module.name,
      generatedAt: new Date().toISOString(),
      ui: uiJson,
      logic: logicCode,
    };

    // Step 4: Write to output file
    const bundleJson = JSON.stringify(bundle, null, 2);
    fs.writeFileSync(module.outputFile, bundleJson, 'utf8');

    log(`  ✓ ${module.name}.bundle (${(bundleJson.length / 1024).toFixed(2)} KB)`, 'green');
  } catch (error) {
    log(`  ✗ Failed to build ${module.name}`, 'red');
    throw error;
  }
}

/**
 * Build all modules
 */
async function buildAll(targetModule = null, watchMode = false) {
  log('UI Eval Module Builder\n', 'blue');

  // Ensure TypeScript SDK is built
  log('Building TypeScript SDK...', 'yellow');

  try {
    execSync('npm run build', {
      cwd: TS_SDK_DIR,
      stdio: 'inherit',
    });
    log('  ✓ SDK built\n', 'green');
  } catch (error) {
    log('  ✗ SDK build failed', 'red');
    process.exit(1);
  }

  // Scan and build modules
  const modules = scanModules();

  if (modules.length === 0) {
    log('No modules found!', 'yellow');
    return;
  }

  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  // Build modules
  const modulesToBuild = targetModule
    ? modules.filter(m => m.name === targetModule)
    : modules;

  if (modulesToBuild.length === 0) {
    log(`Module '${targetModule}' not found!`, 'red');
    return;
  }

  let hasErrors = false;
  for (const module of modulesToBuild) {
    try {
      await buildModule(module);
    } catch (error) {
      hasErrors = true;
    }
  }

  if (!hasErrors) {
    log(`\n✓ Build complete! ${modulesToBuild.length} module(s) built.`, 'green');
    log(`\nOutput: ${OUTPUT_DIR}`, 'cyan');
  } else {
    log('\n✗ Build completed with errors.', 'red');
    process.exit(1);
  }

  // Watch mode
  if (watchMode) {
    log('\nWatching for changes...', 'yellow');
    log('Watch mode not yet implemented for Dart + TS builds', 'yellow');
    log('Please rebuild manually when files change', 'yellow');
  }
}

/**
 * Convert string to PascalCase
 */
function toPascalCase(str) {
  return str
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join('');
}

// Parse CLI arguments
const args = process.argv.slice(2);
const watchMode = args.includes('--watch') || args.includes('-w');
const targetModule = args.find(arg => !arg.startsWith('--'));

// Run build
buildAll(targetModule, watchMode).catch(error => {
  console.error(error);
  process.exit(1);
});
