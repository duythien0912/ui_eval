#!/usr/bin/env node

/**
 * Watch Mode for ui_eval modules
 * Auto-rebuilds modules when Dart or TypeScript files change
 */

const { watch } = require('chokidar');
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

console.log('🔍 UI Eval Watch Mode Starting...\n');

// Determine if we're in example/modules or ts_sdk directory
const cwd = process.cwd();
const isInModules = cwd.includes('/modules');
const modulesPath = isInModules ? cwd : path.join(cwd, '../example/modules');

if (!fs.existsSync(modulesPath)) {
  console.error('❌ Error: modules directory not found');
  console.error('   Run this from: ts_sdk/ or example/modules/');
  process.exit(1);
}

console.log(`📁 Watching: ${modulesPath}`);
console.log('   Dart UI files: **/*_ui.dart');
console.log('   TypeScript logic: **/*_logic.ts\n');

// Track rebuilds to prevent duplicates
const rebuildQueue = new Set();
let rebuildTimer = null;

function extractModuleName(filePath) {
  const parts = filePath.split(path.sep);
  const modulesIndex = parts.indexOf('modules');
  if (modulesIndex >= 0 && parts.length > modulesIndex + 1) {
    return parts[modulesIndex + 1];
  }
  return null;
}

function rebuildModule(moduleName) {
  try {
    console.log(`\n🔨 Building ${moduleName}...`);
    const startTime = Date.now();

    // Run build command
    const buildScript = path.join(__dirname, 'build.js');
    execSync(`node "${buildScript}" ${moduleName}`, {
      stdio: 'inherit',
      cwd: path.dirname(__dirname)
    });

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`✅ ${moduleName} rebuilt in ${duration}s`);
    console.log('   Ready for hot reload!\n');
    console.log('⌚ Watching for changes...');
  } catch (error) {
    console.error(`❌ Build failed for ${moduleName}`);
    console.error(`   ${error.message}\n`);
    console.log('⌚ Watching for changes...');
  }
}

function scheduleRebuild(moduleName) {
  rebuildQueue.add(moduleName);

  // Debounce rebuilds (wait 300ms for more changes)
  if (rebuildTimer) {
    clearTimeout(rebuildTimer);
  }

  rebuildTimer = setTimeout(() => {
    const modules = Array.from(rebuildQueue);
    rebuildQueue.clear();

    modules.forEach(module => {
      rebuildModule(module);
    });
  }, 300);
}

// Watch for file changes
const watcher = watch(
  [
    `${modulesPath}/**/lib/*_ui.dart`,
    `${modulesPath}/**/lib/*_logic.ts`
  ],
  {
    ignored: /(^|[\/\\])\../, // ignore dotfiles
    persistent: true,
    ignoreInitial: true,
  }
);

watcher
  .on('change', (filePath) => {
    const moduleName = extractModuleName(filePath);
    const fileName = path.basename(filePath);

    if (moduleName) {
      console.log(`\n📝 Changed: ${fileName}`);
      scheduleRebuild(moduleName);
    }
  })
  .on('add', (filePath) => {
    const moduleName = extractModuleName(filePath);
    const fileName = path.basename(filePath);

    if (moduleName) {
      console.log(`\n➕ Added: ${fileName}`);
      scheduleRebuild(moduleName);
    }
  })
  .on('error', (error) => {
    console.error(`❌ Watcher error: ${error}`);
  });

console.log('✅ Watch mode active!');
console.log('   Edit any module file to trigger auto-rebuild');
console.log('   Press Ctrl+C to stop\n');
console.log('⌚ Watching for changes...');

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\n👋 Stopping watch mode...');
  watcher.close();
  process.exit(0);
});
