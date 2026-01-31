import 'package:flutter/material.dart';
import 'package:ui_eval/ui_eval.dart';

/// Mock LogicCoordinator for testing without actual WebView
class MockLogicCoordinator extends LogicCoordinator {
  final Map<String, dynamic> _mockState = {};
  final Map<String, Function> _actions = {};

  void registerAction(String name, Function handler) {
    _actions[name] = handler;
  }

  void setMockState(String key, dynamic value) {
    _mockState[key] = value;
  }

  dynamic getMockState(String key) {
    return _mockState[key];
  }

  @override
  Future<void> executeAction(String moduleId, String name, [Map<String, dynamic>? params]) async {
    debugPrint('[MockLogicCoordinator] Executing action: $name with params: $params');
    
    final handler = _actions[name];
    if (handler != null) {
      await handler(params);
    }
  }

  @override
  bool isModuleLoaded(String moduleId) => true;

  @override
  Set<String> get loadedModules => {'counter_app'};
}

/// Test helper to create a mock action handler for counter app
Map<String, Function(Map<String, dynamic>? params)> createCounterActions({
  required Function(String key, dynamic value) onStateChange,
  required Map<String, dynamic> state,
}) {
  return {
    'increment': (params) {
      final step = (state['step'] as num?)?.toInt() ?? 1;
      final currentCount = (state['count'] as num?)?.toInt() ?? 0;
      onStateChange('count', currentCount + step);
    },
    'decrement': (params) {
      final step = (state['step'] as num?)?.toInt() ?? 1;
      final currentCount = (state['count'] as num?)?.toInt() ?? 0;
      onStateChange('count', currentCount - step);
    },
    'reset': (params) {
      onStateChange('count', 0);
      onStateChange('history', <int>[]);
    },
    'setStep': (params) {
      // Handle both direct value and templated value
      final step = params?['step'] ?? params?['value'] ?? 1;
      if (step is num) {
        onStateChange('step', step.toInt());
      }
    },
    'double': (params) {
      final currentCount = (state['count'] as num?)?.toInt() ?? 0;
      onStateChange('count', currentCount * 2);
    },
    'setValue': (params) {
      final value = params?['value'] ?? 0;
      if (value is num) {
        onStateChange('count', value.toInt());
      }
    },
  };
}
