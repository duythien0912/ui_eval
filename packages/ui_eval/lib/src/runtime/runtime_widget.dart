library;

import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import 'logic_coordinator.dart';
import 'state_manager.dart';

/// Widget that renders UI from JSON DSL definition
class UIRuntimeWidget extends StatefulWidget {
  final Map<String, dynamic> uiJson;
  final Map<String, dynamic>? initialState;
  final Map<String, Function(Map<String, dynamic>? params)>? actions;
  final Widget Function(String error)? errorBuilder;

  const UIRuntimeWidget({
    super.key,
    required this.uiJson,
    this.initialState,
    this.actions,
    this.errorBuilder,
  });

  @override
  State<UIRuntimeWidget> createState() => _UIRuntimeWidgetState();
}

class _UIRuntimeWidgetState extends State<UIRuntimeWidget> {
  late Map<String, dynamic> _state;
  String? _error;

  @override
  void initState() {
    super.initState();
    _state = Map<String, dynamic>.from(widget.initialState ?? {});
  }

  @override
  void didUpdateWidget(UIRuntimeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('[UIRuntimeWidget] didUpdateWidget called');
    debugPrint('[UIRuntimeWidget] Old state: ${oldWidget.initialState}');
    debugPrint('[UIRuntimeWidget] New state: ${widget.initialState}');

    // Sync state when initialState prop changes from parent
    if (widget.initialState != null) {
      final newState = Map<String, dynamic>.from(widget.initialState!);
      // Check if state actually changed by comparing key values using deep equality
      bool hasChanged = newState.length != _state.length;
      if (!hasChanged) {
        for (final entry in newState.entries) {
          if (!_deepEquals(_state[entry.key], entry.value)) {
            hasChanged = true;
            debugPrint('[UIRuntimeWidget] State changed for key: ${entry.key}');
            debugPrint('[UIRuntimeWidget]   Old value: ${_state[entry.key]}');
            debugPrint('[UIRuntimeWidget]   New value: ${entry.value}');
            break;
          }
        }
      }
      if (hasChanged) {
        debugPrint('[UIRuntimeWidget] ✅ Calling setState with new state: $newState');
        setState(() => _state = newState);
      } else {
        debugPrint('[UIRuntimeWidget] ⚠️ No state changes detected');
      }
    }
  }

  void _updateState(String key, dynamic value) {
    setState(() {
      _state[key] = value;
    });
  }

  dynamic _getState(String key) {
    return _state[key];
  }

  /// Deep equality check for state values (handles Lists and Maps)
  bool _deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
          return false;
        }
      }
      return true;
    }

    return a == b;
  }

  Future<void> _invokeAction(String actionName, Map<String, dynamic>? params) async {
    final handler = widget.actions?[actionName];
    if (handler != null) {
      await handler(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(_error!);
    }

    try {
      return _buildWidget(widget.uiJson);
    } catch (e, stack) {
      debugPrint('Error build widget: $e');
      debugPrint(stack.toString());
      setState(() => _error = e.toString());
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(e.toString());
      }
      return ErrorWidget(e);
    }
  }

  Widget _buildWidget(dynamic widgetDef) {
    if (widgetDef is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final type = widgetDef['type'] as String?;
    if (type == null) return const SizedBox.shrink();

    return UIWidgets.build(
      type: type,
      def: widgetDef,
      state: _state,
      onAction: _invokeAction,
      onStateChange: _updateState,
      getState: _getState,
    );
  }
}

/// Static entry point to load UI from asset
class UIRuntimeLoader extends StatefulWidget {
  final String assetPath;
  final Map<String, dynamic>? initialState;
  final Map<String, Function(Map<String, dynamic>? params)>? actions;
  final Widget Function(String error)? errorBuilder;
  final Widget? loadingWidget;

  const UIRuntimeLoader({
    super.key,
    required this.assetPath,
    this.initialState,
    this.actions,
    this.errorBuilder,
    this.loadingWidget,
  });

  @override
  State<UIRuntimeLoader> createState() => _UIRuntimeLoaderState();
}

class _UIRuntimeLoaderState extends State<UIRuntimeLoader> {
  Map<String, dynamic>? _uiJson;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUi();
  }

  Future<void> _loadUi() async {
    try {
      final jsonString = await rootBundle.loadString(widget.assetPath);
      setState(() {
        _uiJson = jsonDecode(jsonString) as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Error load ui: $e');
      debugPrint(stack.toString());
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          Center(child: Text('Error: $_error'));
    }

    return UIRuntimeWidget(
      uiJson: _uiJson!,
      initialState: widget.initialState,
      actions: widget.actions,
      errorBuilder: widget.errorBuilder,
    );
  }
}

/// Bundle format for combined UI + Logic
class UIBundle {
  final String format;
  final String moduleId;
  final String generatedAt;
  final Map<String, dynamic> ui;
  final String logic;

  const UIBundle({
    required this.format,
    required this.moduleId,
    required this.generatedAt,
    required this.ui,
    required this.logic,
  });

  factory UIBundle.fromJson(Map<String, dynamic> json) {
    return UIBundle(
      format: json['format'] as String,
      moduleId: json['moduleId'] as String,
      generatedAt: json['generatedAt'] as String,
      ui: json['ui'] as Map<String, dynamic>,
      logic: json['logic'] as String,
    );
  }

  /// Extract initial state from UI definition
  Map<String, dynamic> get initialState {
    final states = ui['states'] as List<dynamic>?;
    if (states == null) return {};
    return {
      for (final s in states) s['key'] as String: s['defaultValue'],
    };
  }

  /// Get the root UI widget definition
  Map<String, dynamic> get rootWidget => ui['root'] as Map<String, dynamic>;
}

/// Loader for bundle files that contain both UI and Logic
class UIBundleLoader extends StatefulWidget {
  final String bundlePath;
  final Widget Function(String error)? errorBuilder;
  final Widget? loadingWidget;

  const UIBundleLoader({
    super.key,
    required this.bundlePath,
    this.errorBuilder,
    this.loadingWidget,
  });

  @override
  State<UIBundleLoader> createState() => _UIBundleLoaderState();
}

class _UIBundleLoaderState extends State<UIBundleLoader> {
  UIBundle? _bundle;
  Map<String, dynamic>? _state;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadBundle();
      _initializeState();
      await _loadLogic();
      setState(() => _isLoading = false);
    } catch (e, stack) {
      debugPrint('Error initializing bundle: $e');
      debugPrint(stack.toString());
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBundle() async {
    final jsonString = await rootBundle.loadString(widget.bundlePath);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    _bundle = UIBundle.fromJson(json);
  }

  void _initializeState() {
    _state = Map<String, dynamic>.from(_bundle!.initialState);
    // Initialize state in global StateManager with module scoping
    for (final entry in _state!.entries) {
      StateManager().set('${_bundle!.moduleId}:${entry.key}', entry.value);
    }
  }

  Future<void> _loadLogic() async {
    final container = GlobalLogicContainer();
    if (!container.isInitialized) {
      await container.initialize();
    }
    await container.loadModuleLogic(_bundle!.moduleId, _bundle!.logic);
    debugPrint('[${_bundle!.moduleId}] Bundle logic loaded');
  }

  Future<void> _executeAction(String name, [Map<String, dynamic>? params]) async {
    try {
      debugPrint('[${_bundle!.moduleId}] 🎯 Executing action: $name with params: $params');
      await LogicCoordinator().executeAction(_bundle!.moduleId, name, params);
      debugPrint('[${_bundle!.moduleId}] ✅ Action completed: $name');
      await _syncStateFromTs();
    } catch (e) {
      debugPrint('[${_bundle!.moduleId}] ❌ Error executing $name: $e');
    }
  }

  Future<void> _syncStateFromTs() async {
    final moduleId = _bundle!.moduleId;
    final scopedKeys = StateManager().keys.where((k) => k.startsWith('$moduleId:'));
    final moduleState = <String, dynamic>{};
    for (final key in scopedKeys) {
      final shortKey = key.substring(moduleId.length + 1);
      moduleState[shortKey] = StateManager().get(key);
    }
    debugPrint('[$moduleId] 🔄 Syncing state from TS: $moduleState');
    setState(() {
      _state = moduleState;
      debugPrint('[$moduleId] ✅ State updated in UIBundleLoader: $_state');
    });
  }

  /// Builds a dynamic action map that can handle any action name.
  /// This uses a proxy pattern to forward any action call to the TypeScript runtime.
  Map<String, Function(Map<String, dynamic>? params)> _buildActions() {
    // Return a dynamic action proxy that intercepts any action call
    return _DynamicActionMap(
      moduleId: _bundle?.moduleId ?? 'unknown',
      executeAction: _executeAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          Center(child: Text('Error: $_error'));
    }

    if (_bundle == null) {
      return widget.errorBuilder?.call('Bundle not loaded') ??
          const Center(child: Text('Error: Bundle not loaded'));
    }

    return UIRuntimeWidget(
      uiJson: _bundle!.rootWidget,
      initialState: _state,
      actions: _buildActions(),
      errorBuilder: widget.errorBuilder,
    );
  }
}

/// A Map implementation that dynamically handles any action name.
/// This allows modules to define any actions without hardcoding them.
class _DynamicActionMap extends MapBase<String, Function(Map<String, dynamic>? params)> {
  final String moduleId;
  final Future<void> Function(String actionName, Map<String, dynamic>? params) executeAction;

  // Cache for created action handlers
  final Map<String, Function(Map<String, dynamic>? params)> _cache = {};

  _DynamicActionMap({
    required this.moduleId,
    required this.executeAction,
  });

  @override
  Function(Map<String, dynamic>? params)? operator [](Object? key) {
    if (key is! String) return null;

    // Return cached handler or create a new one
    return _cache.putIfAbsent(key, () {
      return (Map<String, dynamic>? params) => executeAction(key, params);
    });
  }

  @override
  void operator []=(String key, Function(Map<String, dynamic>? params) value) {
    _cache[key] = value;
  }

  @override
  void clear() => _cache.clear();

  @override
  Iterable<String> get keys => _cache.keys;

  @override
  Function(Map<String, dynamic>? params)? remove(Object? key) => _cache.remove(key);
}

/// A widget that provides the logic engine context.
/// Initializes the Riverpod ProviderContainer for state management.
class LogicEngineWidget extends StatefulWidget {
  final Widget child;

  const LogicEngineWidget({
    super.key,
    required this.child,
  });

  @override
  State<LogicEngineWidget> createState() => _LogicEngineWidgetState();
}

class _LogicEngineWidgetState extends State<LogicEngineWidget> {
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    // Create and initialize the ProviderContainer for Riverpod state management
    _container = ProviderContainer();
    StateManager().initialize(_container);
    debugPrint('[LogicEngineWidget] ProviderContainer initialized');
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the Riverpod container to the widget tree
    return UncontrolledProviderScope(
      container: _container,
      child: widget.child,
    );
  }
}
