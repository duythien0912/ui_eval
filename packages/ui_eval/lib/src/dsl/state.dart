library;

/// Represents a state definition in the DSL
class UIState {
  final String key;
  final dynamic defaultValue;
  final String? type;
  final String? description;

  const UIState({
    required this.key,
    required this.defaultValue,
    this.type,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'defaultValue': defaultValue,
        if (type != null) 'type': type,
        if (description != null) 'description': description,
      };

  factory UIState.fromJson(Map<String, dynamic> json) => UIState(
        key: json['key'] as String,
        defaultValue: json['defaultValue'],
        type: json['type'] as String?,
        description: json['description'] as String?,
      );
}

/// Helper to define multiple states
class UIStates {
  final List<UIState> states;

  const UIStates(this.states);

  Map<String, dynamic> toDefaults() => {
        for (final s in states) s.key: s.defaultValue,
      };

  List<Map<String, dynamic>> toJson() =>
      states.map((s) => s.toJson()).toList();
}
