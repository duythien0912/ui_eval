#!/usr/bin/env node

/**
 * UI Eval Build Script
 *
 * Bundles TypeScript modules into JavaScript bundles for runtime evaluation.
 *
 * Usage:
 *   ui-eval-build                    # Build all modules
 *   ui-eval-build --watch            # Watch mode
 *   ui-eval-build counter_app        # Build specific module
 */

const esbuild = require('esbuild');
const path = require('path');
const fs = require('fs');

// Configuration - resolve paths from current working directory
const CWD = process.cwd();
// Detect if we're running from example/ or example/modules/
const isInModulesDir = fs.existsSync(path.join(CWD, 'package.json')) &&
                       fs.existsSync(path.join(CWD, 'counter_app'));
const MODULES_DIR = isInModulesDir ? CWD : path.join(CWD, 'modules');
const OUTPUT_DIR = isInModulesDir ? path.join(CWD, '..', 'assets') : path.join(CWD, 'assets');
const TS_SDK_DIR = path.resolve(__dirname, '..');

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  blue: '\x1b[34m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

/**
 * Scan modules directory and find all TypeScript modules
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

      // Look for TypeScript files in lib directory
      if (fs.existsSync(libDir)) {
        const tsFiles = fs.readdirSync(libDir).filter(f => f.endsWith('.ts'));

        if (tsFiles.length > 0) {
          // Use the first .ts file as entry point, or look for *_logic.ts
          const logicFile = tsFiles.find(f => f.endsWith('_logic.ts')) || tsFiles[0];
          const entryPoint = path.join(libDir, logicFile);

          modules.push({
            name: moduleName,
            entryPoint,
            outputFile: path.join(OUTPUT_DIR, `${moduleName}.bundle`),
          });
        }
      }
    }
  }

  return modules;
}

/**
 * Build a single module
 */
async function buildModule(module) {
  log(`Building ${module.name}...`, 'blue');

  try {
    await esbuild.build({
      entryPoints: [module.entryPoint],
      bundle: true,
      outfile: module.outputFile,
      platform: 'neutral',
      format: 'iife',
      target: 'es2020',
      minify: false,
      sourcemap: false,
      external: [], // Bundle everything
      alias: {
        '@ui_eval/sdk': path.join(TS_SDK_DIR, 'dist/index.js'),
      },
      banner: {
        js: '// UI Eval Bundle - Auto-generated, do not edit manually\n',
      },
    });

    log(`  ✓ ${module.name}.bundle`, 'green');
  } catch (error) {
    log(`  ✗ Failed to build ${module.name}:`, 'red');
    console.error(error);
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
  const { execSync } = require('child_process');

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
  } else {
    log('\n✗ Build completed with errors.', 'red');
    process.exit(1);
  }

  // Watch mode
  if (watchMode) {
    log('\nWatching for changes...', 'yellow');

    const contexts = await Promise.all(
      modulesToBuild.map(async (module) => {
        return await esbuild.context({
          entryPoints: [module.entryPoint],
          bundle: true,
          outfile: module.outputFile,
          platform: 'neutral',
          format: 'iife',
          target: 'es2020',
          minify: false,
          sourcemap: false,
          external: [],
          alias: {
            '@ui_eval/sdk': path.join(TS_SDK_DIR, 'dist/index.js'),
          },
          banner: {
            js: '// UI Eval Bundle - Auto-generated, do not edit manually\n',
          },
          plugins: [{
            name: 'rebuild-notifier',
            setup(build) {
              build.onEnd(result => {
                if (result.errors.length === 0) {
                  log(`  ✓ Rebuilt ${module.name}.bundle`, 'green');
                } else {
                  log(`  ✗ Failed to rebuild ${module.name}`, 'red');
                }
              });
            },
          }],
        });
      })
    );

    await Promise.all(contexts.map(ctx => ctx.watch()));

    // Keep the process alive
    await new Promise(() => {});
  }
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
