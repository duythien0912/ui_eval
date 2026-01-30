library;

import 'state.dart';
import 'action.dart';

/// Represents a complete UI program definition
class UIProgram {
  final String? id;
  final String? name;
  final String? version;
  final List<UIState>? states;
  final List<UIAction>? actions;
  final Map<String, dynamic> root;

  const UIProgram({
    this.id,
    this.name,
    this.version,
    this.states,
    this.actions,
    required this.root,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (version != null) 'version': version,
        if (states != null) 'states': states!.map((s) => s.toJson()).toList(),
        if (actions != null) 'actions': actions!.map((a) => a.toJson()).toList(),
        'root': root,
      };

  factory UIProgram.fromJson(Map<String, dynamic> json) => UIProgram(
        id: json['id'] as String?,
        name: json['name'] as String?,
        version: json['version'] as String?,
        states: (json['states'] as List?)
            ?.map((s) => UIState.fromJson(s as Map<String, dynamic>))
            .toList(),
        actions: null,
        root: json['root'] as Map<String, dynamic>,
      );
}
