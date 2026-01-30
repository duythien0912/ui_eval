library;

/// Represents an action parameter definition
class UIActionParam {
  final String name;
  final String type;
  final bool required;
  final dynamic defaultValue;

  const UIActionParam({
    required this.name,
    required this.type,
    this.required = true,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'required': required,
        if (defaultValue != null) 'defaultValue': defaultValue,
      };
}

/// Represents an action definition in the DSL
class UIAction {
  final String name;
  final List<UIActionParam> params;

  const UIAction({
    required this.name,
    this.params = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'params': params.map((p) => p.toJson()).toList(),
      };
}

/// Predefined common actions
class UICommonActions {
  static const back = UIAction(name: 'back');
  static const refresh = UIAction(name: 'refresh');
  static const close = UIAction(name: 'close');
  static const submit = UIAction(name: 'submit');
  static const cancel = UIAction(name: 'cancel');
}
