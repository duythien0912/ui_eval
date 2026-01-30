#!/usr/bin/env dart
/**
 * DSL Compiler for ui_eval
 * 
 * This script compiles Dart DSL files to JSON by running the Dart code
 * and extracting the program definition.
 * 
 * Usage:
 *   dart compile_dsl.dart                    # Compile all modules
 *   dart compile_dsl.dart --watch            # Watch mode
 *   dart compile_dsl.dart counter_app        # Compile specific module
 */

import 'dart:io';
import 'dart:convert';

final String modulesDir = '../modules';
final String outputDir = '../assets/apps';

class ModuleInfo {
  final String name;
  final String uiFile;
  
  ModuleInfo(this.name, this.uiFile);
}

List<ModuleInfo> scanModules() {
  final modules = <ModuleInfo>[];
  final dir = Directory(modulesDir);
  
  if (!dir.existsSync()) return modules;
  
  for (final entry in dir.listSync()) {
    if (entry is Directory) {
      final name = entry.path.split('/').last;
      if (name.startsWith('.')) continue;
      
      final shortName = name.replaceAll('_app', '');
      final uiFile = '${entry.path}/lib/${shortName}_ui.dart';
      final altUiFile = '${entry.path}/lib/ui.dart';
      
      if (File(uiFile).existsSync()) {
        modules.add(ModuleInfo(name, uiFile));
      } else if (File(altUiFile).existsSync()) {
        modules.add(ModuleInfo(name, altUiFile));
      }
    }
  }
  
  return modules;
}

Future<void> compileModule(ModuleInfo module) async {
  print('Compiling ${module.name}...');
  
  // Create a temporary Dart script that imports the module and outputs JSON
  final tempScript = '''
import 'dart:convert';
import '${module.uiFile}';

void main() {
  final app = ${module.name.replaceAll('_app', '').split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join('')}MiniApp();
  final json = app.compileToJson();
  print('__JSON_START__');
  print(json);
  print('__JSON_END__');
}
''';
  
  final tempFile = File('.temp_compile_${module.name}.dart');
  tempFile.writeAsStringSync(tempScript);
  
  try {
    // Run the temp script
    final result = await Process.run('dart', [
      '--enable-experiment=inline-class',
      tempFile.path,
    ], workingDirectory: Directory.current.path);
    
    if (result.exitCode != 0) {
      print('  Error: ${result.stderr}');
      return;
    }
    
    // Extract JSON from output
    final output = result.stdout as String;
    final startIdx = output.indexOf('__JSON_START__');
    final endIdx = output.indexOf('__JSON_END__');
    
    if (startIdx == -1 || endIdx == -1) {
      print('  Error: Could not find JSON in output');
      print('  Output: \$output');
      return;
    }
    
    final jsonStr = output.substring(startIdx + '__JSON_START__'.length, endIdx).trim();
    
    // Validate JSON
    final json = jsonDecode(jsonStr);
    
    // Write to output file
    final outputFile = File('$outputDir/${module.name}.json');
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync(jsonStr);
    
    print('  Written: ${outputFile.path}');
  } finally {
    tempFile.deleteSync();
  }
}

Future<void> compileAll({String? targetModule}) async {
  final modules = scanModules();
  
  if (modules.isEmpty) {
    print('No modules found!');
    return;
  }
  
  // Ensure output directory exists
  Directory(outputDir).createSync(recursive: true);
  
  for (final module in modules) {
    if (targetModule != null && module.name != targetModule) continue;
    await compileModule(module);
  }
  
  print('\nDSL compilation complete!');
}

void main(List<String> args) async {
  final targetModule = args.firstWhere(
    (a) => !a.startsWith('--'),
    orElse: () => '',
  );
  
  print('ui_eval DSL Compiler\n');
  
  await compileAll(
    targetModule: targetModule.isEmpty ? null : targetModule,
  );
}
