import 'dart:convert';
import '../core/ui_widget.dart';
import '../core/ui_state.dart';
import '../core/ui_action.dart';

/// Generates Dart code from UI DSL for flutter_eval
class DartCodeGenerator {
  final StringBuffer _buffer = StringBuffer();
  int _indentLevel = 0;
  
  String get _indent => '  ' * _indentLevel;
  
  /// Generate complete Dart file from UI program
  String generateProgram({
    required String className,
    required UIWidget root,
    required List<UIState> states,
    required List<UIAction> actions,
    List<String> imports = const [],
  }) {
    _buffer.clear();
    _indentLevel = 0;
    
    // Generate imports
    _writeln("import 'package:flutter/material.dart';");
    _writeln("import 'package:flutter_eval/flutter_eval.dart';");
    for (final import in imports) {
      _writeln("import '$import';");
    }
    _writeln();
    
    // Generate state class if needed
    if (states.isNotEmpty) {
      _generateStateClass(className, states);
      _writeln();
    }
    
    // Generate main widget class
    if (states.isNotEmpty) {
      _generateStatefulWidget(className, root, actions);
    } else {
      _generateStatelessWidget(className, root);
    }
    
    return _buffer.toString();
  }
  
  void _generateStateClass(String className, List<UIState> states) {
    _writeln('class _${className}State extends ChangeNotifier {');
    _indentLevel++;
    
    // State fields
    for (final state in states) {
      _writeln('${state.type ?? 'dynamic'} ${state.key} = ${jsonEncode(state.defaultValue)};');
    }
    _writeln();
    
    // Setters that notify
    for (final state in states) {
      _writeln('void set${state.key[0].toUpperCase()}${state.key.substring(1)}(value) {');
      _indentLevel++;
      _writeln('${state.key} = value;');
      _writeln('notifyListeners();');
      _indentLevel--;
      _writeln('}');
      _writeln();
    }
    
    _indentLevel--;
    _writeln('}');
  }
  
  void _generateStatefulWidget(String className, UIWidget root, List<UIAction> actions) {
    _writeln('class $className extends StatefulWidget {');
    _indentLevel++;
    _writeln('const $className({super.key});');
    _indentLevel--;
    _writeln();
    _writeln('  @override');
    _writeln('  State<$className> createState() => _$className' 'State();');
    _writeln('}');
    _writeln();
    
    _writeln('class _$className' 'State extends State<$className> {');
    _indentLevel++;
    
    // State instance
    _writeln('final _state = _${className}State();');
    _writeln();
    
    // Init state
    _writeln('@override');
    _writeln('void initState() {');
    _indentLevel++;
    _writeln('super.initState();');
    _writeln('_state.addListener(() => setState(() {}));');
    _indentLevel--;
    _writeln('}');
    _writeln();
    
    // Build method
    _writeln('@override');
    _writeln('Widget build(BuildContext context) {');
    _indentLevel++;
    _write('return ');
    _write(root.toDartCode(indent: _indentLevel));
    _writeln(';');
    _indentLevel--;
    _writeln('}');
    
    _indentLevel--;
    _writeln('}');
  }
  
  void _generateStatelessWidget(String className, UIWidget root) {
    _writeln('class $className extends StatelessWidget {');
    _indentLevel++;
    _writeln('const $className({super.key});');
    _indentLevel--;
    _writeln();
    _writeln('  @override');
    _writeln('  Widget build(BuildContext context) {');
    _indentLevel++;
    _write('return ');
    _write(root.toDartCode(indent: _indentLevel));
    _writeln(';');
    _indentLevel--;
    _writeln('  }');
    _writeln('}');
  }
  
  void _write(String text) => _buffer.write(text);
  void _writeln([String text = '']) => _buffer.writeln('$_indent$text');
}

/// Generates JSON representation for runtime interpretation
class JsonCodeGenerator {
  Map<String, dynamic> generateProgram({
    required String name,
    required UIWidget root,
    required List<UIState> states,
    required List<UIAction> actions,
  }) {
    return {
      'version': '1.0.0',
      'name': name,
      'states': states.map((s) => s.toJson()).toList(),
      'actions': actions.map((a) => a.toJson()).toList(),
      'root': root.toJson(),
    };
  }
}
