const esbuild = require('esbuild');
const fs = require('fs');
const path = require('path');

const config = {
  entryPoints: ['./dist/index.js'],
  bundle: true,
  format: 'iife',
  globalName: 'AppLogic',
  outfile: '../assets/ts_logic/logic_bundle.js',
  platform: 'browser',
  target: 'es2020',
  minify: false,
  sourcemap: true,
};

async function build() {
  const outputDir = path.dirname(config.outfile);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  await esbuild.build(config);
  console.log('✅ Build complete:', config.outfile);
}

build();
