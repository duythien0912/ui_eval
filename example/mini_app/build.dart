#!/usr/bin/env dart
/// Build script to compile mini_app to JSON
/// Usage: dart build.dart

import 'dart:convert';
import 'dart:io';
import 'lib/todo_app.dart';

void main() {
  print('Building mini_app...\n');
  
  // Build the app
  final app = TodoApp();
  final program = app.build();
  
  // Create output directory
  final outputDir = Directory('../host_app/assets/apps');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  
  // Write JSON
  final outputFile = File('${outputDir.path}/todo_app.json');
  final jsonString = const JsonEncoder.withIndent('  ').convert(program.toJson());
  outputFile.writeAsStringSync(jsonString);
  
  print('✅ Built: ${outputFile.path}');
  print('');
  print('App: ${program.name} v${program.version}');
  print('States: ${program.states.map((s) => s.key).join(', ')}');
  print('Actions: ${program.actions.map((a) => a.name).join(', ')}');
  print('');
  print('Next steps:');
  print('  1. cd ../host_app');
  print('  2. flutter run');
}
