#!/usr/bin/env node
/**
 * DSL Compiler for ui_eval
 * 
 * This script compiles Dart DSL files to JSON by extracting the program definition.
 * It looks for `UIProgram get program =>` pattern and extracts the toJson() output.
 * 
 * Usage:
 *   node compile_dsl.js                    # Compile all modules
 *   node compile_dsl.js --watch            # Watch mode
 *   node compile_dsl.js counter_app        # Compile specific module
 */

const fs = require("fs");
const path = require("path");

const MODULES_DIR = path.join(__dirname, "..", "modules");
const OUTPUT_DIR = path.join(__dirname, "..", "assets", "apps");

function scanModules() {
  const modules = [];
  if (!fs.existsSync(MODULES_DIR)) return modules;

  const entries = fs.readdirSync(MODULES_DIR, { withFileTypes: true });
  
  for (const entry of entries) {
    if (entry.isDirectory() && !entry.name.startsWith('.')) {
      const uiFile = path.join(MODULES_DIR, entry.name, "lib", `${entry.name.replace('_app', '')}_ui.dart`);
      const altUiFile = path.join(MODULES_DIR, entry.name, "lib", "ui.dart");
      
      if (fs.existsSync(uiFile)) {
        modules.push({ name: entry.name, uiFile });
      } else if (fs.existsSync(altUiFile)) {
        modules.push({ name: entry.name, uiFile: altUiFile });
      }
    }
  }
  
  return modules;
}

function parseDartDSL(content) {
  // Extract UIProgram definition
  // Look for: UIProgram get program => UIProgram(...);
  const programMatch = content.match(/UIProgram\s+get\s+program\s*=>\s*UIProgram\s*\(([^)]+)\)/s);
  if (!programMatch) {
    // Try alternative pattern with toJson()
    const altMatch = content.match(/UIProgram\s+get\s+program\s*=>[\s\S]*?\);/);
    if (!altMatch) return null;
  }

  // Extract states
  const states = [];
  const stateMatches = content.matchAll(/UIState\s*\(\s*key:\s*['"](\w+)['"]\s*,\s*defaultValue:\s*([^,\n]+)\s*,\s*type:\s*['"](\w+)['"]\s*\)/g);
  for (const match of stateMatches) {
    let defaultValue = match[2].trim();
    // Convert Dart values to JSON
    if (defaultValue === '[]') defaultValue = [];
    else if (defaultValue === "''" || defaultValue === ' "" ') defaultValue = '';
    else if (!isNaN(Number(defaultValue))) defaultValue = Number(defaultValue);
    else if (defaultValue === 'true') defaultValue = true;
    else if (defaultValue === 'false') defaultValue = false;
    
    states.push({
      key: match[1],
      defaultValue: defaultValue,
      type: match[3]
    });
  }

  // Extract metadata
  const idMatch = content.match(/id:\s*['"]([^'"]+)['"]/);
  const nameMatch = content.match(/name:\s*['"]([^'"]+)['"]/);
  const versionMatch = content.match(/version:\s*['"]([^'"]+)['"]/);

  return {
    id: idMatch?.[1] || 'unknown',
    name: nameMatch?.[1] || 'Unknown App',
    version: versionMatch?.[1] || '1.0.0',
    states: states,
    root: null // Will be built from widget tree
  };
}

function parseWidget(content, startIndex) {
  // Simple widget parser - finds widget constructor calls
  // This is a simplified version - full parser would be more complex
  
  const widgetTypes = [
    'UIScaffold', 'UIAppBar', 'UIContainer', 'UIRow', 'UIColumn',
    'UIText', 'UIButton', 'UIIconButton', 'UIFloatingActionButton',
    'UIIcon', 'UISizedBox', 'UIExpanded', 'UIPadding', 'UICenter',
    'UICard', 'UIDivider', 'UITextField', 'UICheckbox', 'UISwitch',
    'UISlider', 'UIListView', 'UIListTile', 'UIGridView', 'UIWrap',
    'UIChip', 'UIStack', 'UIPositioned', 'UIImage'
  ];
  
  // Find the next widget starting from startIndex
  for (const type of widgetTypes) {
    const pattern = new RegExp(`\\b${type}\\s*\\(`, 'g');
    pattern.lastIndex = startIndex;
    const match = pattern.exec(content);
    if (match) {
      return { type: type.replace('UI', '').toLowerCase(), index: match.index };
    }
  }
  
  return null;
}

function extractWidgetTree(content) {
  // Find the root widget (after "root:")
  const rootMatch = content.match(/root:\s*(\w+)\s*\(/s);
  if (!rootMatch) return null;

  // For now, return a placeholder that indicates the DSL was found
  // A full implementation would parse the entire widget tree
  return { type: 'scaffold', _parsed: true };
}

function compileModule(module) {
  console.log(`Compiling ${module.name}...`);
  
  const content = fs.readFileSync(module.uiFile, 'utf-8');
  
  // Check if file contains DSL program definition
  if (!content.includes('UIProgram get program')) {
    console.log(`  No DSL program found in ${module.uiFile}`);
    return null;
  }

  // Parse the DSL
  const program = parseDartDSL(content);
  if (!program) {
    console.log(`  Failed to parse DSL in ${module.uiFile}`);
    return null;
  }

  // Extract widget tree
  const root = extractWidgetTree(content);
  if (root) {
    program.root = root;
  }

  // For now, we need to actually execute the Dart code to get the full JSON
  // This is a limitation - ideally we'd have a Dart compiler
  // As a workaround, we look for the compileToJson method or inline JSON
  
  // Check if there's an inline JSON definition
  const jsonMatch = content.match(/\/\/\s*JSON:\s*(\{[\s\S]*?\})/);
  if (jsonMatch) {
    try {
      const inlineJson = JSON.parse(jsonMatch[1]);
      return inlineJson;
    } catch (e) {
      // Ignore parse error
    }
  }

  return program;
}

function ensureOutputDir() {
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }
}

async function compileAll(targetModule = null) {
  const modules = scanModules();
  if (modules.length === 0) {
    console.log("No modules found!");
    return;
  }

  ensureOutputDir();

  for (const module of modules) {
    if (targetModule && module.name !== targetModule) continue;
    
    const program = compileModule(module);
    if (program) {
      const outputFile = path.join(OUTPUT_DIR, `${module.name}.json`);
      fs.writeFileSync(outputFile, JSON.stringify(program, null, 2));
      console.log(`  Written: ${outputFile}`);
    }
  }

  console.log("\nDSL compilation complete!");
  console.log("\nNote: Full widget tree parsing requires running Dart code.");
  console.log("For complete compilation, use: flutter run with DSL extraction.");
}

// Alternative: Use Dart to compile
async function compileWithDart(targetModule = null) {
  const { execSync } = require('child_process');
  
  const modules = scanModules();
  ensureOutputDir();

  for (const module of modules) {
    if (targetModule && module.name !== targetModule) continue;
    
    console.log(`Compiling ${module.name} with Dart...`);
    
    try {
      // Create a temporary Dart script to extract the JSON
      const tempScript = `
import 'dart:convert';
import 'dart:io';

// Mock the DSL classes
class UIProgram {
  final String? id;
  final String? name;
  final String? version;
  final List<Map<String, dynamic>>? states;
  final Map<String, dynamic> root;
  
  UIProgram({this.id, this.name, this.version, this.states, required this.root});
  
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (version != null) 'version': version,
    if (states != null) 'states': states,
    'root': root,
  };
}

// Read and evaluate the DSL file content
final content = File('${module.uiFile}').readAsStringSync();

// Extract the program using regex
final programMatch = RegExp(r'UIProgram get program => UIProgram\\(([^)]+)\\)', dotAll: true).firstMatch(content);
if (programMatch != null) {
  print('Found program definition');
}

// For now, output a placeholder
print(jsonEncode({'status': 'compiled', 'module': '${module.name}'}));
`;
      
      const tempFile = path.join(__dirname, 'temp_compile.dart');
      fs.writeFileSync(tempFile, tempScript);
      
      const result = execSync(`dart ${tempFile}`, { encoding: 'utf-8' });
      console.log(result);
      
      fs.unlinkSync(tempFile);
    } catch (e) {
      console.log(`  Dart compilation failed: ${e.message}`);
    }
  }
}

async function main() {
  const args = process.argv.slice(2);
  const targetModule = args.find(a => !a.startsWith('--'));
  const useDart = args.includes('--dart');

  console.log("ui_eval DSL Compiler\n");
  
  if (useDart) {
    await compileWithDart(targetModule);
  } else {
    await compileAll(targetModule);
  }
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
