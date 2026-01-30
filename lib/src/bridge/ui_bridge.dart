import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_state.dart';
import '../core/ui_action.dart';

/// Bridge between native Flutter and UI DSL
/// Provides utilities for state management and action handling
class UIBridge {
  final Map<String, ValueNotifier<dynamic>> _stateNotifiers = {};
  final Map<String, List<Function>> _actionListeners = {};
  
  /// Create state bridge
  ValueNotifier<T> createState<T>(String key, T initialValue) {
    final notifier = ValueNotifier<T>(initialValue);
    _stateNotifiers[key] = notifier;
    return notifier;
  }
  
  /// Get state notifier
  ValueNotifier<T>? getState<T>(String key) {
    return _stateNotifiers[key] as ValueNotifier<T>?;
  }
  
  /// Update state value
  void setState<T>(String key, T value) {
    final notifier = _stateNotifiers[key];
    if (notifier != null) {
      notifier.value = value;
    }
  }
  
  /// Register action listener
  void onAction(String actionName, Function handler) {
    _actionListeners.putIfAbsent(actionName, () => []);
    _actionListeners[actionName]!.add(handler);
  }
  
  /// Remove action listener
  void offAction(String actionName, Function handler) {
    _actionListeners[actionName]?.remove(handler);
  }
  
  /// Dispatch action
  void dispatch(String actionName, [Map<String, dynamic>? params]) {
    final listeners = _actionListeners[actionName];
    if (listeners != null) {
      for (final handler in listeners) {
        handler(params);
      }
    }
  }
  
  /// Dispose all resources
  void dispose() {
    for (final notifier in _stateNotifiers.values) {
      notifier.dispose();
    }
    _stateNotifiers.clear();
    _actionListeners.clear();
  }
}

/// Mixin for widgets that use UI DSL
 mixin UIBridgeMixin<T extends StatefulWidget> on State<T> {
  final UIBridge _bridge = UIBridge();
  
  UIBridge get bridge => _bridge;
  
  @override
  void dispose() {
    _bridge.dispose();
    super.dispose();
  }
}
