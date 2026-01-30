library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _updateState(String key, dynamic value) {
    setState(() {
      _state[key] = value;
    });
  }

  dynamic _getState(String key) {
    return _state[key];
  }

  void _invokeAction(String actionName, Map<String, dynamic>? params) {
    final handler = widget.actions?[actionName];
    if (handler != null) {
      handler(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(_error!);
    }

    try {
      return _buildWidget(widget.uiJson);
    } catch (e) {
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
    } catch (e) {
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
      await LogicCoordinator().executeAction(_bundle!.moduleId, name, params);
      await _syncStateFromTs();
    } catch (e) {
      debugPrint('[${_bundle!.moduleId}] Error executing $name: $e');
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
    setState(() => _state = moduleState);
  }

  Map<String, Function(Map<String, dynamic>? params)> _buildActions() {
    // Get all action names from the UI definition
    final actions = <String, Function(Map<String, dynamic>? params)>{};
    
    // Add a generic action handler that forwards to TypeScript
    void addAction(String name) {
      actions[name] = (params) => _executeAction(name, params);
    }

    // Extract actions from UI definition if available
    final uiActions = _bundle?.ui['actions'] as List<dynamic>?;
    if (uiActions != null) {
      for (final action in uiActions) {
        final name = action['name'] as String?;
        if (name != null) addAction(name);
      }
    }

    // Always add common actions that might be referenced
    // These will be called from TypeScript
    return {
      'increment': (p) => _executeAction('increment', p),
      'decrement': (p) => _executeAction('decrement', p),
      'reset': (p) => _executeAction('reset', p),
      'setStep': (p) => _executeAction('setStep', p),
      'double': (p) => _executeAction('double', p),
      'setValue': (p) => _executeAction('setValue', p),
      'addTodo': (p) => _executeAction('addTodo', p),
      'toggleTodo': (p) => _executeAction('toggleTodo', p),
      'deleteTodo': (p) => _executeAction('deleteTodo', p),
      'updateTitle': (p) => _executeAction('updateTitle', p),
      'setFilter': (p) => _executeAction('setFilter', p),
      'clearCompleted': (p) => _executeAction('clearCompleted', p),
      'fetchTodosFromApi': (p) => _executeAction('fetchTodosFromApi', p),
    };
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
