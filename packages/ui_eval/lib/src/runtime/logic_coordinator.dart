library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'state_manager.dart';

class _RpcMessage {
  final String type;
  final String callId;
  final String moduleId;
  final Map<String, dynamic> payload;

  _RpcMessage({
    required this.type,
    required this.callId,
    required this.moduleId,
    required this.payload,
  });

  factory _RpcMessage.fromJson(Map<String, dynamic> json) => _RpcMessage(
        type: json['type'] as String,
        callId: json['callId'] as String,
        moduleId: json['moduleId'] as String? ?? 'default',
        payload: json['payload'] as Map<String, dynamic>? ?? {},
      );
}

class GlobalLogicContainer {
  static final GlobalLogicContainer _instance = GlobalLogicContainer._internal();
  factory GlobalLogicContainer() => _instance;
  GlobalLogicContainer._internal();

  WebViewController? _controller;
  bool _initialized = false;
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  final Set<String> _loadedModules = {};
  int _callIdCounter = 0;

  bool get isInitialized => _initialized;
  Set<String> get loadedModules => Set.unmodifiable(_loadedModules);

  Future<void> initialize() async {
    if (_initialized) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: _handleJSMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _injectSdkBootstrap(),
        ),
      );

    await _controller!.loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ui_eval Logic Engine</title>
</head>
<body>
  <div id="root">Logic Engine Ready</div>
  <script>window.__ui_eval_ready__ = true;</script>
</body>
</html>''');

    _initialized = true;
  }

  void _injectSdkBootstrap() {
    const bootstrapJs = '''
const originalLog = console.log;
const originalWarn = console.warn;
const originalError = console.error;

window.__sendConsoleToFlutter = function(level, args) {
  if (window.FlutterBridge?.postMessage) {
    const message = {
      type: 'console.log',
      callId: 'console_' + Date.now(),
      moduleId: 'system',
      payload: {
        level: level,
        args: args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a))
      }
    };
    window.FlutterBridge.postMessage(JSON.stringify(message));
  }
};

console.log = function(...args) {
  window.__sendConsoleToFlutter('log', args);
  originalLog.apply(console, args);
};

console.warn = function(...args) {
  window.__sendConsoleToFlutter('warn', args);
  originalWarn.apply(console, args);
};

console.error = function(...args) {
  window.__sendConsoleToFlutter('error', args);
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

console.log('[System] SDK Bootstrap loaded');
''';
    _controller?.runJavaScript(bootstrapJs);
  }

  Future<void> loadModule(String moduleId, String assetPath) async {
    if (!_initialized) {
      throw StateError('GlobalLogicContainer not initialized. Call initialize() first.');
    }

    if (_loadedModules.contains(moduleId)) {
      debugPrint('[LogicEngine] Module $moduleId already loaded');
      return;
    }

    debugPrint('[LogicEngine] Loading module: $moduleId from $assetPath');

    await _controller!.runJavaScript('''
(async function() {
  try {
    const response = await fetch('$assetPath');
    const code = await response.text();
    const moduleWrapper = new Function('moduleId', `
      \${code}
      if (typeof AppLogic_${moduleId} !== 'undefined') {
        window.__ui_eval_registry__.register('${moduleId}', AppLogic_${moduleId});
      }
    `);
    moduleWrapper('${moduleId}');
    console.log('[System] Module ${moduleId} loaded successfully');
  } catch (err) {
    console.error('[System] Failed to load module ${moduleId}:', err);
  }
})();
''');

    _loadedModules.add(moduleId);
  }

  /// Load module logic directly from JavaScript code string
  Future<void> loadModuleLogic(String moduleId, String jsCode) async {
    if (!_initialized) {
      throw StateError('GlobalLogicContainer not initialized. Call initialize() first.');
    }

    if (_loadedModules.contains(moduleId)) {
      debugPrint('[LogicEngine] Module $moduleId already loaded');
      return;
    }

    debugPrint('[LogicEngine] Loading module logic: $moduleId');

    // Escape the JS code for injection
    final escapedCode = jsCode
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n');

    await _controller!.runJavaScript('''
(function() {
  try {
    const code = '$escapedCode';
    const moduleWrapper = new Function('moduleId', `
      \${code}
      if (typeof AppLogic_${moduleId} !== 'undefined') {
        window.__ui_eval_registry__.register('${moduleId}', AppLogic_${moduleId});
      }
    `);
    moduleWrapper('${moduleId}');
    console.log('[System] Module ${moduleId} logic loaded successfully');
  } catch (err) {
    console.error('[System] Failed to load module logic ${moduleId}:', err);
  }
})();
''');

    _loadedModules.add(moduleId);
  }

  WebViewController? get controller => _controller;

  void _handleJSMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    final msg = _RpcMessage.fromJson(data);

    switch (msg.type) {
      case 'state.get':
        _handleStateGet(msg);
        break;
      case 'state.set':
        _handleStateSet(msg);
        break;
      case 'api.request':
        _handleApiRequest(msg);
        break;
      case 'action.result':
        _handleActionResult(msg);
        break;
      case 'console.log':
        _handleConsoleLog(msg);
        break;
    }
  }

  Future<void> _handleStateGet(_RpcMessage msg) async {
    final key = msg.payload['key'] as String;
    final scopedKey = '${msg.moduleId}:$key';
    final value = StateManager().get(scopedKey);
    _sendResponse(msg.callId, msg.moduleId, {'value': value});
  }

  Future<void> _handleStateSet(_RpcMessage msg) async {
    final key = msg.payload['key'] as String;
    final value = msg.payload['value'];
    final scopedKey = '${msg.moduleId}:$key';
    StateManager().set(scopedKey, value);
    _sendResponse(msg.callId, msg.moduleId, {'success': true});
  }

  Future<void> _handleApiRequest(_RpcMessage msg) async {
    _sendResponse(msg.callId, msg.moduleId, {
      'data': [],
      'statusCode': 200,
      'headers': {},
    });
  }

  void _handleActionResult(_RpcMessage msg) {
    final completer = _pendingRequests.remove(msg.callId);
    completer?.complete(msg.payload);
  }

  void _handleConsoleLog(_RpcMessage msg) {
    final level = msg.payload['level'] as String? ?? 'log';
    final args = msg.payload['args'] as List<dynamic>? ?? [];
    final prefix = '[JS - ${msg.moduleId}]';

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

  void _sendResponse(String callId, String moduleId, Map<String, dynamic> payload) {
    final response = jsonEncode({
      'type': 'response',
      'callId': callId,
      'moduleId': moduleId,
      'payload': payload,
    });
    _controller?.runJavaScript('window.postMessage($response, "*")');
  }

  Future<dynamic> executeAction(String moduleId, String actionName, [Map<String, dynamic>? params]) {
    final callId = 'dart_${++_callIdCounter}_${DateTime.now().millisecondsSinceEpoch}';
    final completer = Completer<dynamic>();
    _pendingRequests[callId] = completer;

    final js = '''
(async function() {
  try {
    await window.__ui_eval_registry__.execute('$moduleId', '$actionName', ${jsonEncode(params)});
    window.postMessage({
      type: 'response.action.result',
      callId: '$callId',
      moduleId: '$moduleId',
      payload: { success: true }
    }, '*');
  } catch (err) {
    console.error('[$moduleId] Action $actionName failed:', err);
    window.postMessage({
      type: 'response.action.result',
      callId: '$callId',
      moduleId: '$moduleId',
      payload: { success: false, error: String(err) }
    }, '*');
  }
})();
''';

    _controller?.runJavaScript(js);
    return completer.future;
  }
}

class LogicCoordinator {
  Future<void> executeAction(String moduleId, String name, [Map<String, dynamic>? params]) async {
    await GlobalLogicContainer().executeAction(moduleId, name, params);
  }

  bool isModuleLoaded(String moduleId) {
    return GlobalLogicContainer().loadedModules.contains(moduleId);
  }

  Set<String> get loadedModules => GlobalLogicContainer().loadedModules;
}

class LogicEngineWidget extends StatelessWidget {
  final Widget child;
  const LogicEngineWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = GlobalLogicContainer().controller;
    return Stack(
      children: [
        child,
        if (controller != null)
          Offstage(
            offstage: true,
            child: SizedBox(
              width: 1,
              height: 1,
              child: WebViewWidget(controller: controller),
            ),
          ),
      ],
    );
  }
}
