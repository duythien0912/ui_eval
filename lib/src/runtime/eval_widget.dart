import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'hot_update_manager.dart';
import 'ui_runtime.dart';

/// Widget that renders UI from compiled source with hot update support
class UIEvalWidget extends StatefulWidget {
  /// Initial EVC bytecode asset path
  final String? assetPath;
  
  /// Initial EVC bytecode bytes
  final List<int>? initialBytes;
  
  /// JSON UI definition
  final Map<String, dynamic>? json;
  
  /// Server URL for hot updates
  final String? updateUrl;
  
  /// Current version
  final String? version;
  
  /// Polling interval for updates
  final Duration updateInterval;
  
  /// Initial state values
  final Map<String, dynamic> initialState;
  
  /// Action handlers
  final Map<String, Function> actions;
  
  /// Loading widget
  final Widget? loadingWidget;
  
  /// Error widget builder
  final Widget Function(Object error)? errorBuilder;
  
  const UIEvalWidget({
    super.key,
    this.assetPath,
    this.initialBytes,
    this.json,
    this.updateUrl,
    this.version,
    this.updateInterval = const Duration(seconds: 30),
    this.initialState = const {},
    this.actions = const {},
    this.loadingWidget,
    this.errorBuilder,
  }) : assert(assetPath != null || initialBytes != null || json != null,
           'Must provide assetPath, initialBytes, or json');

  @override
  State<UIEvalWidget> createState() => _UIEvalWidgetState();
}

class _UIEvalWidgetState extends State<UIEvalWidget> {
  final UIRuntime _runtime = UIRuntime();
  final HotUpdateManager _updateManager = HotUpdateManager();
  
  Widget? _currentWidget;
  Object? _error;
  bool _isLoading = true;
  String? _currentVersion;
  
  @override
  void initState() {
    super.initState();
    _currentVersion = widget.version;
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Load initial UI
      await _loadInitialUI();
      
      // Setup hot updates if URL provided
      if (widget.updateUrl != null) {
        await _setupHotUpdates();
      }
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadInitialUI() async {
    if (widget.json != null) {
      // Load from JSON
      setState(() {
        _currentWidget = _runtime.loadJson(
          widget.json!,
          context: context,
          initialState: widget.initialState,
          actions: widget.actions,
        );
        _isLoading = false;
      });
    } else {
      // Load from EVC bytes
      List<int> bytes;
      
      if (widget.initialBytes != null) {
        bytes = widget.initialBytes!;
      } else if (widget.assetPath != null) {
        final data = await DefaultAssetBundle.of(context)
            .load(widget.assetPath!);
        bytes = data.buffer.asUint8List();
      } else {
        throw StateError('No source provided');
      }
      
      final widget_ = await _runtime.loadEvc(bytes);
      
      setState(() {
        _currentWidget = widget_;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _setupHotUpdates() async {
    await _updateManager.initialize(
      serverUrl: widget.updateUrl!,
      currentVersion: _currentVersion,
      pollingInterval: widget.updateInterval,
    );
    
    // Listen for updates
    _updateManager.updateStream.listen((event) {
      switch (event.type) {
        case UIUpdateEventType.available:
          _onUpdateAvailable(event);
          break;
        case UIUpdateEventType.downloaded:
          _onUpdateDownloaded(event);
          break;
        case UIUpdateEventType.applied:
          _onUpdateApplied(event);
          break;
        default:
          break;
      }
    });
  }
  
  void _onUpdateAvailable(UIUpdateEvent event) {
    if (kDebugMode) {
      print('UI Update available: ${event.version}');
    }
    
    // Auto-download update
    if (event.info != null) {
      _updateManager.downloadUpdate(event.info!);
    }
  }
  
  void _onUpdateDownloaded(UIUpdateEvent event) {
    if (kDebugMode) {
      print('UI Update downloaded: ${event.version}');
    }
    
    // Show update prompt or auto-apply
    _showUpdateDialog(event.version);
  }
  
  void _onUpdateApplied(UIUpdateEvent event) {
    if (kDebugMode) {
      print('UI Update applied: ${event.version}');
    }
    
    // Reload UI with new version
    _reloadUI(event.filePath);
  }
  
  void _showUpdateDialog(String version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Text('A new UI version ($version) is available. Apply now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateManager.applyUpdate(version);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _reloadUI(String? filePath) async {
    setState(() => _isLoading = true);
    
    try {
      final bytes = await _updateManager.loadUpdateBytes(null);
      if (bytes != null) {
        final widget_ = await _runtime.loadEvc(bytes);
        setState(() {
          _currentWidget = widget_;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }
  
  /// Force check for updates
  Future<void> checkForUpdate() async {
    final update = await _updateManager.checkForUpdate();
    if (update != null) {
      final downloaded = await _updateManager.downloadUpdate(update);
      if (downloaded) {
        await _updateManager.applyUpdate(update.version);
      }
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
    
    return _currentWidget ?? const SizedBox.shrink();
  }
  
  @override
  void dispose() {
    _runtime.dispose();
    _updateManager.dispose();
    super.dispose();
  }
}

/// Simplified widget for JSON-based UI without hot update
class UIJsonWidget extends StatelessWidget {
  final Map<String, dynamic> json;
  final Map<String, dynamic> initialState;
  final Map<String, Function> actions;
  
  const UIJsonWidget({
    super.key,
    required this.json,
    this.initialState = const {},
    this.actions = const {},
  });
  
  @override
  Widget build(BuildContext context) {
    final runtime = UIRuntime();
    return runtime.loadJson(
      json,
      context: context,
      initialState: initialState,
      actions: actions,
    );
  }
}
