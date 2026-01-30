/// Represents a reactive state variable in the UI
class UIState<T> {
  final String key;
  final T defaultValue;
  final String? type;
  
  const UIState({
    required this.key,
    required this.defaultValue,
    this.type,
  });
  
  Map<String, dynamic> toJson() => {
    'key': key,
    'defaultValue': defaultValue,
    'type': type ?? T.toString(),
  };
  
  /// Create a reference to this state
  UIStateRef get ref => UIStateRef(key);
  
  @override
  String toString() => '{{$key}}';
}

/// Reference to a state value for use in widgets
class UIStateRef {
  final String key;
  final String? property;
  final List<String>? path;
  
  const UIStateRef(this.key, {this.property, this.path});
  
  String get expression {
    if (path != null && path!.isNotEmpty) {
      return '{{$key.${path!.join('.')}}}';
    }
    return property != null ? '{{$key.$property}}' : '{{$key}}';
  }
  
  @override
  String toString() => expression;
}

/// State declaration helper
class UIStateDeclarations {
  final Map<String, UIState> _states = {};
  
  void add<T>(String key, T defaultValue) {
    _states[key] = UIState<T>(key: key, defaultValue: defaultValue);
  }
  
  UIState<T> get<T>(String key) => _states[key]! as UIState<T>;
  
  List<UIState> get all => _states.values.toList();
  
  Map<String, dynamic> toJson() => {
    for (var entry in _states.entries) entry.key: entry.value.toJson(),
  };
}
