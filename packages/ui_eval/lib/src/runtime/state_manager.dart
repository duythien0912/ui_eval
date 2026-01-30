library;

import 'dart:collection';
import 'package:flutter/material.dart';

/// Global state manager singleton
class StateManager extends ChangeNotifier {
  static final StateManager _instance = StateManager._internal();

  factory StateManager() => _instance;
  StateManager._internal();

  final Map<String, dynamic> _state = {};
  final Map<String, List<void Function(dynamic)>> _listeners = {};

  T? get<T>(String key) => _state[key] as T?;

  T getOr<T>(String key, T defaultValue) => (_state[key] as T?) ?? defaultValue;

  void set<T>(String key, T value) {
    final oldValue = _state[key];
    if (oldValue == value) return;

    _state[key] = value;
    notifyListeners();
    _listeners[key]?.forEach((listener) => listener(value));
  }

  void update<T>(String key, T Function(T current) updater) {
    final current = get<T>(key);
    if (current != null) {
      set(key, updater(current));
    }
  }

  bool has(String key) => _state.containsKey(key);
  void remove(String key) {
    _state.remove(key);
    notifyListeners();
  }

  void clear() {
    _state.clear();
    notifyListeners();
  }

  Iterable<String> get keys => _state.keys;
  Map<String, dynamic> get all => UnmodifiableMapView(_state);

  void addKeyListener(String key, void Function(dynamic) listener) {
    _listeners.putIfAbsent(key, () => []).add(listener);
  }

  void removeKeyListener(String key, void Function(dynamic) listener) {
    _listeners[key]?.remove(listener);
  }

  void init(Map<String, dynamic> values) {
    _state.addAll(values);
    notifyListeners();
  }
}

/// Mixin for widgets that need to listen to state changes
mixin StateListenerMixin<T extends StatefulWidget> on State<T> {
  final List<VoidCallback> _stateListeners = [];

  void addStateListener(VoidCallback listener) {
    _stateListeners.add(listener);
    StateManager().addListener(listener);
  }

  void removeStateListener(VoidCallback listener) {
    _stateListeners.remove(listener);
    StateManager().removeListener(listener);
  }

  @override
  void dispose() {
    for (final listener in _stateListeners) {
      StateManager().removeListener(listener);
    }
    _stateListeners.clear();
    super.dispose();
  }
}
