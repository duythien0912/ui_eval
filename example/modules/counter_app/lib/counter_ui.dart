// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ui_eval/runtime.dart';

class CounterMiniApp extends StatefulWidget {
  const CounterMiniApp({super.key});

  @override
  State<CounterMiniApp> createState() => _CounterMiniAppState();
}

class _CounterMiniAppState extends State<CounterMiniApp> {
  Map<String, dynamic>? _uiJson;
  bool _isLoading = true;
  String? _error;
  late Map<String, dynamic> _state;
  late Map<String, Function(Map<String, dynamic>?)> _actions;
  static const String _moduleId = 'counter';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadUiDefinition();
      _initializeState();
      _setupActions();
      await _loadTypeScriptLogic();
      setState(() => _isLoading = false);
    } catch (e, stack) {
      print('Error initializing CounterMiniApp: $e');
      print(stack);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUiDefinition() async {
    try {
      final jsonString = await rootBundle.loadString('assets/apps/counter_app.json');
      _uiJson = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      _uiJson = _getInlineUiDefinition();
    }
  }

  void _initializeState() {
    _state = {'count': 0, 'step': 1, 'history': <int>[], 'maxHistory': 10};
    for (final entry in _state.entries) {
      StateManager().set('${_moduleId}:${entry.key}', entry.value);
    }
  }

  void _setupActions() {
    _actions = {
      'increment': (_) => _executeTsAction('increment'),
      'decrement': (_) => _executeTsAction('decrement'),
      'reset': (_) => _executeTsAction('reset'),
      'setStep': (params) => _executeTsAction('setStep', params),
      'double': (_) => _executeTsAction('double'),
      'setValue': (params) => _executeTsAction('setValue', params),
    };
  }

  Future<void> _loadTypeScriptLogic() async {
    final container = GlobalLogicContainer();
    if (!container.isInitialized) await container.initialize();
    await container.loadModule(_moduleId, 'assets/logic/counter.js');
    print('[$_moduleId] TypeScript logic loaded');
  }

  Future<void> _executeTsAction(String name, [Map<String, dynamic>? params]) async {
    try {
      await LogicCoordinator().executeAction(_moduleId, name, params);
      await _syncStateFromTs();
    } catch (e) {
      print('[$_moduleId] Error executing $name: $e');
    }
  }

  Future<void> _syncStateFromTs() async {
    final scopedKeys = StateManager().keys.where((k) => k.startsWith('$_moduleId:'));
    final moduleState = <String, dynamic>{};
    for (final key in scopedKeys) {
      final shortKey = key.substring(_moduleId.length + 1);
      moduleState[shortKey] = StateManager().get(key);
    }
    setState(() => _state = moduleState);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: UIRuntimeWidget(
        uiJson: _uiJson!,
        initialState: _state,
        actions: _actions,
      ),
    );
  }

  Map<String, dynamic> _getInlineUiDefinition() {
    return {
      'type': 'scaffold',
      'body': {
        'type': 'column',
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'center',
        'children': [
          {'type': 'text', 'text': '{{state.count}}', 'fontSize': 72, 'fontWeight': 'bold'},
          {'type': 'sizedBox', 'height': 32},
          {
            'type': 'row',
            'mainAxisAlignment': 'center',
            'children': [
              {'type': 'iconButton', 'icon': 'remove', 'size': 48, 'onTap': {'action': 'decrement'}},
              {'type': 'sizedBox', 'width': 32},
              {'type': 'button', 'text': 'Reset', 'type_': 'outlined', 'onTap': {'action': 'reset'}},
              {'type': 'sizedBox', 'width': 32},
              {'type': 'iconButton', 'icon': 'add', 'size': 48, 'onTap': {'action': 'increment'}},
            ],
          },
          {'type': 'sizedBox', 'height': 24},
          {'type': 'text', 'text': 'Step: {{state.step}}'},
          {
            'type': 'slider',
            'value': '{{state.step}}',
            'min': 1,
            'max': 10,
            'onChanged': {'action': 'setStep', 'params': {'step': '{{value}}'}},
          },
        ],
      },
    };
  }
}
