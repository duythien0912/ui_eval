import 'dart:convert';
import 'dart:io';
import 'package:dart_eval/dart_eval.dart';
import 'package:path/path.dart' as path;
import '../core/ui_widget.dart';
import '../core/ui_state.dart';
import '../core/ui_action.dart';
import 'dart_code_generator.dart';

/// Compiles UI DSL to EVC bytecode for flutter_eval
class UICompiler {
  final DartCodeGenerator _dartGen = DartCodeGenerator();
  final JsonCodeGenerator _jsonGen = JsonCodeGenerator();
  final Compiler _compiler = Compiler();
  
  /// Compile UI program to EVC bytecode
  Future<List<int>> compileToEvc({
    required String className,
    required UIWidget root,
    required List<UIState> states,
    required List<UIAction> actions,
  }) async {
    // Generate Dart code
    final dartCode = _dartGen.generateProgram(
      className: className,
      root: root,
      states: states,
      actions: actions,
    );
    
    // Write to temp file
    final tempDir = Directory.systemTemp.createTempSync('ui_eval_');
    final sourceFile = File(path.join(tempDir.path, 'main.dart'));
    await sourceFile.writeAsString(dartCode);
    
    try {
      // Compile to EVC using dart_eval
      final program = _compiler.compile({
        'main': {
          'main.dart': dartCode,
        }
      });
      
      // Serialize to bytes
      final bytes = program.write();
      return bytes;
    } finally {
      // Cleanup
      tempDir.deleteSync(recursive: true);
    }
  }
  
  /// Compile to JSON for runtime interpretation
  Map<String, dynamic> compileToJson({
    required String name,
    required UIWidget root,
    required List<UIState> states,
    required List<UIAction> actions,
  }) {
    return _jsonGen.generateProgram(
      name: name,
      root: root,
      states: states,
      actions: actions,
    );
  }
  
  /// Compile and save to file
  Future<void> compileToFile({
    required String outputPath,
    required String className,
    required UIWidget root,
    required List<UIState> states,
    required List<UIAction> actions,
    UICompileFormat format = UICompileFormat.evc,
  }) async {
    switch (format) {
      case UICompileFormat.evc:
        final bytes = await compileToEvc(
          className: className,
          root: root,
          states: states,
          actions: actions,
        );
        await File(outputPath).writeAsBytes(bytes);
        break;
        
      case UICompileFormat.json:
        final json = compileToJson(
          name: className,
          root: root,
          states: states,
          actions: actions,
        );
        await File(outputPath).writeAsString(jsonEncode(json));
        break;
        
      case UICompileFormat.dart:
        final dart = _dartGen.generateProgram(
          className: className,
          root: root,
          states: states,
          actions: actions,
        );
        await File(outputPath).writeAsString(dart);
        break;
    }
  }
  
  /// Generate Dart code string (for debugging)
  String generateDartCode({
    required String className,
    required UIWidget root,
    required List<UIState> states,
    required List<UIAction> actions,
  }) {
    return _dartGen.generateProgram(
      className: className,
      root: root,
      states: states,
      actions: actions,
    );
  }
}

/// Compilation output formats
enum UICompileFormat {
  evc,   // EVC bytecode for flutter_eval
  json,  // JSON for runtime interpretation
  dart,  // Dart source code
}
