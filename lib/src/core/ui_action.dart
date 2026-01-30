/// Represents an action/event handler
class UIAction {
  final String name;
  final List<UIActionParam> params;
  final String? body;
  
  const UIAction({
    required this.name,
    this.params = const [],
    this.body,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'params': params.map((p) => p.toJson()).toList(),
    'body': body,
  };
  
  UIActionRef get ref => UIActionRef(name);
}

/// Action parameter
class UIActionParam {
  final String name;
  final String type;
  final dynamic defaultValue;
  
  const UIActionParam({
    required this.name,
    required this.type,
    this.defaultValue,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'defaultValue': defaultValue,
  };
}

/// Reference to an action for use in widgets
class UIActionRef {
  final String name;
  final Map<String, dynamic>? arguments;
  
  const UIActionRef(this.name, {this.arguments});
  
  @override
  String toString() => '@$name';
}

/// Built-in action types
class UIActions {
  static const String setState = 'setState';
  static const String navigate = 'navigate';
  static const String showDialog = 'showDialog';
  static const String dismiss = 'dismiss';
  static const String refresh = 'refresh';
}
