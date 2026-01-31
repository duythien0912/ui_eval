library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Riverpod-based State Manager
/// Replaces custom StateManager with production-ready solution
class RiverpodStateManager {
  static final RiverpodStateManager _instance = RiverpodStateManager._internal();
  factory RiverpodStateManager() => _instance;
  RiverpodStateManager._internal();

  final Map<String, StateProvider<dynamic>> _providers = {};
  ProviderContainer? _container;

  /// Initialize with a ProviderContainer
  void initialize(ProviderContainer container) {
    _container = container;
  }

  /// Get or create a provider for a given key
  StateProvider<dynamic> _getProvider(String key, dynamic defaultValue) {
    if (!_providers.containsKey(key)) {
      _providers[key] = StateProvider<dynamic>((ref) => defaultValue);
    }
    return _providers[key]!;
  }

  /// Get state value
  dynamic get(String key, {dynamic defaultValue}) {
    if (_container == null) return defaultValue;

    final provider = _getProvider(key, defaultValue);
    return _container!.read(provider);
  }

  /// Set state value
  void set(String key, dynamic value) {
    if (_container == null) return;

    final provider = _getProvider(key, value);
    _container!.read(provider.notifier).state = value;
  }

  /// Update state value with updater function
  void update(String key, dynamic Function(dynamic) updater, {dynamic defaultValue}) {
    if (_container == null) return;

    final provider = _getProvider(key, defaultValue);
    final current = _container!.read(provider);
    final newValue = updater(current);
    _container!.read(provider.notifier).state = newValue;
  }

  /// Check if a key exists
  bool has(String key) {
    return _providers.containsKey(key);
  }

  /// Get all state keys
  Iterable<String> get keys => _providers.keys;

  /// Get all state as a map (for debugging)
  Map<String, dynamic> toMap() {
    if (_container == null) return {};

    final result = <String, dynamic>{};
    _providers.forEach((key, provider) {
      result[key] = _container!.read(provider);
    });
    return result;
  }

  /// Clear all state (useful for testing)
  void clear() {
    _providers.clear();
  }

  /// Listen to state changes
  void listen(String key, void Function(dynamic) callback, {dynamic defaultValue}) {
    if (_container == null) return;

    final provider = _getProvider(key, defaultValue);
    _container!.listen<dynamic>(
      provider,
      (previous, next) => callback(next),
    );
  }
}

/// Legacy StateManager wrapper for backward compatibility
/// Delegates to RiverpodStateManager
class StateManager {
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  final _riverpod = RiverpodStateManager();

  void initialize(ProviderContainer container) {
    _riverpod.initialize(container);
  }

  dynamic get(String key, {dynamic defaultValue}) {
    return _riverpod.get(key, defaultValue: defaultValue);
  }

  void set(String key, dynamic value) {
    _riverpod.set(key, value);
  }

  void update(String key, dynamic Function(dynamic) updater, {dynamic defaultValue}) {
    _riverpod.update(key, updater, defaultValue: defaultValue);
  }

  bool has(String key) {
    return _riverpod.has(key);
  }

  Iterable<String> get keys => _riverpod.keys;

  Map<String, dynamic> toMap() {
    return _riverpod.toMap();
  }

  void clear() {
    _riverpod.clear();
  }
}
