import 'package:flutter/material.dart';
import 'ui_state.dart';
import 'ui_action.dart';

/// Base class for all UI DSL widgets
abstract class UIWidget {
  const UIWidget();
  
  /// Convert to JSON representation
  Map<String, dynamic> toJson();
  
  /// Get widget type identifier
  String get type => runtimeType.toString().replaceAll('UI', '');
  
  /// Generate Dart code for flutter_eval
  String toDartCode({int indent = 0});
  
  String _indent(int level) => '  ' * level;
}

/// Root widget that can be compiled
class UIProgram {
  final String name;
  final UIWidget root;
  final List<UIState> states;
  final List<UIAction> actions;
  
  const UIProgram({
    required this.name,
    required this.root,
    this.states = const [],
    this.actions = const [],
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'root': root.toJson(),
    'states': states.map((s) => s.toJson()).toList(),
    'actions': actions.map((a) => a.toJson()).toList(),
  };
  
  String toDartCode() {
    final buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter_eval/flutter_eval.dart';");
    buffer.writeln();
    buffer.writeln('class $name extends StatelessWidget {');
    buffer.writeln('  const $name({super.key});');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln(root.toDartCode(indent: 2));
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }
}

/// Reference to a state value
class UIStateRef {
  final String key;
  final String? property;
  
  const UIStateRef(this.key, {this.property});
  
  String get ref => property != null ? '{{$key.$property}}' : '{{$key}}';
  
  @override
  String toString() => ref;
}

/// Reference to an action
class UIActionRef {
  final String name;
  final Map<String, dynamic>? params;
  
  const UIActionRef(this.name, {this.params});
  
  String get ref => '@$name';
  
  @override
  String toString() => ref;
}
