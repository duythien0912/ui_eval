library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/widgets.dart';

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
