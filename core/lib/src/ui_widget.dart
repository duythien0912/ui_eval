import 'types.dart';
export 'types.dart';

/// Base class for all UI DSL widgets
abstract class UIWidget {
  const UIWidget();
  
  Map<String, dynamic> toJson();
  
  String get type => runtimeType.toString().replaceAll('UI', '');
  
  String get flutterType {
    const mapping = {
      'Text': 'Text',
      'Button': 'ElevatedButton',
      'TextButton': 'TextButton',
      'IconButton': 'IconButton',
      'Column': 'Column',
      'Row': 'Row',
      'Container': 'Container',
      'Center': 'Center',
      'Scaffold': 'Scaffold',
      'AppBar': 'AppBar',
      'ListView': 'ListView',
      'ListTile': 'ListTile',
      'Card': 'Card',
      'TextField': 'TextField',
      'Checkbox': 'Checkbox',
      'Icon': 'Icon',
      'FloatingActionButton': 'FloatingActionButton',
      'SafeArea': 'SafeArea',
      'Padding': 'Padding',
      'Expanded': 'Expanded',
      'SizedBox': 'SizedBox',
      'Divider': 'Divider',
      'Stack': 'Stack',
      'Positioned': 'Positioned',
      'Align': 'Align',
      'Chip': 'Chip',
    };
    return mapping[type] ?? type;
  }
}

/// Program definition
class UIProgram {
  final String name;
  final String version;
  final UIWidget root;
  final List<UIState> states;
  final List<UIAction> actions;
  final Map<String, dynamic> metadata;
  
  const UIProgram({
    required this.name,
    required this.root,
    this.version = '1.0.0',
    this.states = const [],
    this.actions = const [],
    this.metadata = const {},
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'version': version,
    'metadata': metadata,
    'states': states.map((s) => s.toJson()).toList(),
    'actions': actions.map((a) => a.toJson()).toList(),
    'root': root.toJson(),
  };
}
