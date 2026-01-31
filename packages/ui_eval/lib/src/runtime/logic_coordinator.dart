library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'state_manager.dart';

/// FlutterJS-based Logic Coordinator - replaces WebView with QuickJS/JavascriptCore
class FlutterJsLogicCoordinator {
  static final FlutterJsLogicCoordinator _instance = FlutterJsLogicCoordinator._internal();
  factory FlutterJsLogicCoordinator() => _instance;
  FlutterJsLogicCoordinator._internal();

  JavascriptRuntime? _runtime;
  bool _initialized = false;
  final Set<String> _loadedModules = {};
  int _callIdCounter = 0;
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  bool get isInitialized => _initialized;
  Set<String> get loadedModules => Set.unmodifiable(_loadedModules);

  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('[FlutterJS] Initializing...');
    
    // Create the JavaScript runtime
    _runtime = getJavascriptRuntime();
    
    // Set up message handler for Dart-JS communication
    _runtime!.onMessage('flutter_bridge', (dynamic args) {
      _handleJsMessage(args);
    });

    // Inject the SDK bootstrap
    await _injectSdkBootstrap();

    _initialized = true;
    debugPrint('[FlutterJS] Initialized successfully');
  }

  void _handleJsMessage(dynamic args) {
    try {
      // Also dispatch to JS listeners for TS SDK compatibility
      _dispatchToJsListeners(args);
      
      if (args is Map<String, dynamic>) {
        final type = args['type'] as String?;
        final callId = args['callId'] as String? ?? '';
        final moduleId = args['moduleId'] as String? ?? 'default';
        final payload = args['payload'] as Map<String, dynamic>? ?? {};

        switch (type) {
          case 'state.get':
            _handleStateGet(moduleId, payload, callId);
            break;
          case 'state.set':
            _handleStateSet(moduleId, payload, callId);
            break;
          case 'console.log':
            _handleConsoleLog(moduleId, payload);
            break;
          case 'response.action.result':
            _handleActionResult(callId, payload);
            break;
          default:
            debugPrint('[FlutterJS] Unknown message type: $type');
        }
      }
    } catch (e) {
      debugPrint('[FlutterJS] Message handler error: $e');
    }
  }

  void _dispatchToJsListeners(dynamic message) {
    try {
      final jsonMessage = jsonEncode(message);
      _runtime?.evaluate('''
        if (window.__dispatchMessage) {
          window.__dispatchMessage($jsonMessage);
        }
      ''');
    } catch (e) {
      // Ignore errors from dispatch
    }
  }

  void _handleStateGet(String moduleId, Map<String, dynamic> payload, String callId) {
    final key = payload['key'] as String;
    final scopedKey = '$moduleId:$key';
    final value = StateManager().get(scopedKey);
    
    _sendResponse(callId, moduleId, {'value': value});
  }

  void _handleStateSet(String moduleId, Map<String, dynamic> payload, String callId) {
    final key = payload['key'] as String;
    final value = payload['value'];
    final scopedKey = '$moduleId:$key';
    StateManager().set(scopedKey, value);
    
    _sendResponse(callId, moduleId, {'success': true});
  }

  void _handleConsoleLog(String moduleId, Map<String, dynamic> payload) {
    final level = payload['level'] as String? ?? 'log';
    final args = payload['args'] as List<dynamic>? ?? [];
    final prefix = '[JS - $moduleId]';

    switch (level) {
      case 'warn':
        debugPrint('$prefix ⚠️ ${args.join(' ')}');
        break;
      case 'error':
        debugPrint('$prefix ❌ ${args.join(' ')}');
        break;
      default:
        debugPrint('$prefix ${args.join(' ')}');
        break;
    }
  }

  void _handleActionResult(String callId, dynamic payload) {
    final completer = _pendingRequests.remove(callId);
    completer?.complete(payload);
  }

  void _sendResponse(String callId, String moduleId, Map<String, dynamic> payload, {String responseType = 'state'}) {
    final response = {
      'type': 'response.$responseType',
      'callId': callId,
      'moduleId': moduleId,
      'payload': payload,
    };
    final responseJson = jsonEncode(response);
    
    // Send to pending callbacks (for Dart-side completers)
    _runtime?.evaluate('''
      if (window.__pendingCallbacks__ && window.__pendingCallbacks__['$callId']) {
        window.__pendingCallbacks__['$callId']($responseJson);
        delete window.__pendingCallbacks__['$callId'];
      }
    ''');
    
    // Also dispatch as message event (for TS SDK compatibility)
    _dispatchToJsListeners(response);
  }

  void _checkEvalResult(JsEvalResult result, String context) {
    if (result.isError) {
      debugPrint('[FlutterJS] ❌ Error in $context: ${result.stringResult}');
    } else if (result.stringResult.isNotEmpty && result.stringResult != 'undefined' && result.stringResult != 'null') {
      debugPrint('[FlutterJS] ℹ️ $context result: ${result.stringResult}');
    }
  }

  Future<void> _injectSdkBootstrap() async {
    const bootstrapJs = '''
(function() {
  // Create window object if not exists (for non-browser environments)
  if (typeof globalThis !== 'undefined') {
    globalThis.window = globalThis.window || globalThis;
  }
  const window = globalThis.window;
  
  // Store event listeners for message passing
  window.__eventListeners = [];
  
  // Mock addEventListener for message events
  window.addEventListener = function(event, handler) {
    if (event === 'message') {
      window.__eventListeners.push(handler);
    }
  };
  
  // Function to dispatch messages to listeners
  window.__dispatchMessage = function(data) {
    const event = { data: data };
    window.__eventListeners.forEach(function(handler) {
      try {
        handler(event);
      } catch (e) {
        console.error('Error in message handler:', e);
      }
    });
  };

  const originalLog = console.log;
  const originalWarn = console.warn;
  const originalError = console.error;

  window.__pendingCallbacks__ = {};
  
  window.__sendConsoleToDart = function(level, args) {
    sendMessage('flutter_bridge', JSON.stringify({
      type: 'console.log',
      callId: 'console_' + Date.now(),
      moduleId: 'system',
      payload: {
        level: level,
        args: args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a))
      }
    }));
  };

  console.log = function(...args) {
    window.__sendConsoleToDart('log', args);
    originalLog.apply(console, args);
  };

  console.warn = function(...args) {
    window.__sendConsoleToDart('warn', args);
    originalWarn.apply(console, args);
  };

  console.error = function(...args) {
    window.__sendConsoleToDart('error', args);
    originalError.apply(console, args);
  };

  window.__ui_eval_registry__ = {
    modules: new Map(),
    register: function(moduleId, exports) {
      this.modules.set(moduleId, exports);
      console.log('[System] Module registered:', moduleId);
    },
    execute: function(moduleId, actionName, params) {
      const module = this.modules.get(moduleId);
      if (module && module.__ui_eval_actions__) {
        return module.__ui_eval_actions__.execute(actionName, params);
      }
      console.error('[System] Module or action not found:', moduleId, actionName);
    }
  };

  // Bridge for state operations - compatible with TS SDK
  window.FlutterBridge = {
    postMessage: function(message) {
      sendMessage('flutter_bridge', message);
    }
  };

  console.log('[System] FlutterJS SDK Bootstrap loaded');
})();
''';
    final result = _runtime!.evaluate(bootstrapJs);
    _checkEvalResult(result, 'SDK Bootstrap');
  }

  Future<void> loadModuleLogic(String moduleId, String jsCode) async {
    if (!_initialized) {
      throw StateError('FlutterJsLogicCoordinator not initialized. Call initialize() first.');
    }

    if (_loadedModules.contains(moduleId)) {
      debugPrint('[FlutterJS] Module $moduleId already loaded');
      return;
    }

    debugPrint('[FlutterJS] Loading module logic: $moduleId');

    // Wrap the code to register the module
    final wrappedCode = '''
(function() {
  try {
    $jsCode
    // Check if TS SDK registered the module automatically
    const modules = window.__ui_eval_registry__?.getModules?.() || [];
    if (modules.includes('${moduleId}')) {
      console.log('[System] Module ${moduleId} registered by TS SDK');
    } else if (typeof AppLogic_${moduleId} !== 'undefined') {
      window.__ui_eval_registry__.register('${moduleId}', AppLogic_${moduleId});
      console.log('[System] Module ${moduleId} registered from AppLogic variable');
    } else {
      console.warn('[System] Module ${moduleId} may not be properly registered');
    }
  } catch (err) {
    console.error('[System] Failed to load module logic ${moduleId}:', err);
  }
})();
''';

    final result = _runtime!.evaluate(wrappedCode);
    _checkEvalResult(result, 'loadModuleLogic($moduleId)');
    _loadedModules.add(moduleId);
  }

  Future<dynamic> executeAction(String moduleId, String actionName, [Map<String, dynamic>? params]) async {
    if (!_initialized) {
      throw StateError('FlutterJsLogicCoordinator not initialized');
    }

    final callId = 'dart_${++_callIdCounter}_${DateTime.now().millisecondsSinceEpoch}';
    final completer = Completer<dynamic>();
    _pendingRequests[callId] = completer;

    final js = '''
(async function() {
  try {
    await window.__ui_eval_registry__.execute('$moduleId', '$actionName', ${jsonEncode(params)});
    sendMessage('flutter_bridge', JSON.stringify({
      type: 'response.action.result',
      callId: '$callId',
      moduleId: '$moduleId',
      payload: { success: true }
    }));
  } catch (err) {
    console.error('[$moduleId] Action $actionName failed:', err);
    sendMessage('flutter_bridge', JSON.stringify({
      type: 'response.action.result',
      callId: '$callId',
      moduleId: '$moduleId',
      payload: { success: false, error: String(err) }
    }));
  }
})();
''';

    final result = _runtime!.evaluate(js);
    _checkEvalResult(result, 'executeAction($moduleId.$actionName)');
    
    // Wait for the action to complete with a timeout
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      _pendingRequests.remove(callId);
      throw Exception('Action $actionName timed out');
    }
  }

  void dispose() {
    _runtime?.dispose();
    _initialized = false;
    _loadedModules.clear();
  }
}

/// LogicCoordinator wrapper that uses FlutterJS instead of WebView
class LogicCoordinator {
  Future<void> executeAction(String moduleId, String name, [Map<String, dynamic>? params]) async {
    await FlutterJsLogicCoordinator().executeAction(moduleId, name, params);
  }

  bool isModuleLoaded(String moduleId) {
    return FlutterJsLogicCoordinator().loadedModules.contains(moduleId);
  }

  Set<String> get loadedModules => FlutterJsLogicCoordinator().loadedModules;
}

/// Global logic container using FlutterJS
class GlobalLogicContainer {
  static final GlobalLogicContainer _instance = GlobalLogicContainer._internal();
  factory GlobalLogicContainer() => _instance;
  GlobalLogicContainer._internal();

  bool _initialized = false;

  bool get isInitialized => _initialized;
  Set<String> get loadedModules => FlutterJsLogicCoordinator().loadedModules;

  Future<void> initialize() async {
    if (_initialized) return;
    await FlutterJsLogicCoordinator().initialize();
    _initialized = true;
  }

  Future<void> loadModuleLogic(String moduleId, String jsCode) async {
    if (!_initialized) {
      throw StateError('GlobalLogicContainer not initialized. Call initialize() first.');
    }
    await FlutterJsLogicCoordinator().loadModuleLogic(moduleId, jsCode);
  }

  Future<dynamic> executeAction(String moduleId, String actionName, [Map<String, dynamic>? params]) {
    return FlutterJsLogicCoordinator().executeAction(moduleId, actionName, params);
  }
}
