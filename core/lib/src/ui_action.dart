import 'types.dart';

/// Action builder for fluent API
class UIActionBuilder {
  final List<UIAction> _actions = [];
  
  UIAction action(String name, {String? description}) {
    final action = UIAction(name: name, description: description);
    _actions.add(action);
    return action;
  }
  
  UIAction actionWithParams(String name, {required List<UIActionParam> params, String? description}) {
    final action = UIAction(name: name, params: params, description: description);
    _actions.add(action);
    return action;
  }
  
  List<UIAction> get all => List.unmodifiable(_actions);
  List<UIAction> build() => all;
}

UIActionBuilder get actions => UIActionBuilder();

/// Common action presets
class UICommonActions {
  static UIActionRef get back => const UIActionRef('back');
  static UIActionRef get refresh => const UIActionRef('refresh');
  static UIActionRef get submit => const UIActionRef('submit');
  static UIActionRef get cancel => const UIActionRef('cancel');
  static UIActionRef get delete => const UIActionRef('delete');
  static UIActionRef get save => const UIActionRef('save');
  static UIActionRef get close => const UIActionRef('close');
  
  static UIActionRef navigateTo(String route) => UIActionRef('navigate', args: {'to': route});
  static UIActionRef setState(String key, dynamic value) => UIActionRef('setState', args: {'key': key, 'value': value});
}
