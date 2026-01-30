import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Manages hot updates for UI components
class HotUpdateManager {
  static final HotUpdateManager _instance = HotUpdateManager._internal();
  factory HotUpdateManager() => _instance;
  HotUpdateManager._internal();
  
  final _updateController = StreamController<UIUpdateEvent>.broadcast();
  Stream<UIUpdateEvent> get updateStream => _updateController.stream;
  
  String? _serverUrl;
  String? _currentVersion;
  Timer? _pollingTimer;
  bool _isChecking = false;
  
  /// Initialize with server configuration
  Future<void> initialize({
    required String serverUrl,
    String? currentVersion,
    Duration pollingInterval = const Duration(seconds: 30),
  }) async {
    _serverUrl = serverUrl;
    _currentVersion = currentVersion ?? await _getLocalVersion();
    
    // Start polling for updates
    _startPolling(pollingInterval);
  }
  
  /// Check for updates manually
  Future<UIUpdateInfo?> checkForUpdate() async {
    if (_serverUrl == null || _isChecking) return null;
    
    _isChecking = true;
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/update?version=$_currentVersion'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final info = UIUpdateInfo.fromJson(data);
        
        if (info.hasUpdate && info.version != _currentVersion) {
          return info;
        }
      }
    } catch (e) {
      debugPrint('Hot update check failed: $e');
    } finally {
      _isChecking = false;
    }
    return null;
  }
  
  /// Download and apply update
  Future<bool> downloadUpdate(UIUpdateInfo info) async {
    try {
      // Download update bundle
      final response = await http.get(
        Uri.parse('$_serverUrl${info.downloadUrl}'),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        // Save to local storage
        final dir = await getApplicationDocumentsDirectory();
        final updateDir = Directory(path.join(dir.path, 'ui_updates'));
        await updateDir.create(recursive: true);
        
        final filePath = path.join(updateDir.path, '${info.version}.evc');
        await File(filePath).writeAsBytes(response.bodyBytes);
        
        // Save metadata
        final metaPath = path.join(updateDir.path, '${info.version}.json');
        await File(metaPath).writeAsString(jsonEncode(info.toJson()));
        
        // Notify listeners
        _updateController.add(UIUpdateEvent(
          type: UIUpdateEventType.downloaded,
          version: info.version,
          filePath: filePath,
        ));
        
        return true;
      }
    } catch (e) {
      debugPrint('Download update failed: $e');
    }
    return false;
  }
  
  /// Apply downloaded update
  Future<bool> applyUpdate(String version) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final updateDir = Directory(path.join(dir.path, 'ui_updates'));
      final filePath = path.join(updateDir.path, '$version.evc');
      
      if (await File(filePath).exists()) {
        // Mark as current version
        await _saveLocalVersion(version);
        _currentVersion = version;
        
        // Notify listeners
        _updateController.add(UIUpdateEvent(
          type: UIUpdateEventType.applied,
          version: version,
          filePath: filePath,
        ));
        
        return true;
      }
    } catch (e) {
      debugPrint('Apply update failed: $e');
    }
    return false;
  }
  
  /// Get the latest available update file
  Future<String?> getLatestUpdateFile() async {
    final version = await _getLocalVersion();
    if (version == null) return null;
    
    final dir = await getApplicationDocumentsDirectory();
    final filePath = path.join(dir.path, 'ui_updates', '$version.evc');
    
    if (await File(filePath).exists()) {
      return filePath;
    }
    return null;
  }
  
  /// Load update file as bytes
  Future<List<int>?> loadUpdateBytes(String? version) async {
    final ver = version ?? await _getLocalVersion();
    if (ver == null) return null;
    
    final dir = await getApplicationDocumentsDirectory();
    final filePath = path.join(dir.path, 'ui_updates', '$ver.evc');
    
    if (await File(filePath).exists()) {
      return await File(filePath).readAsBytes();
    }
    return null;
  }
  
  void _startPolling(Duration interval) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) async {
      final update = await checkForUpdate();
      if (update != null) {
        _updateController.add(UIUpdateEvent(
          type: UIUpdateEventType.available,
          version: update.version,
          info: update,
        ));
      }
    });
  }
  
  Future<String?> _getLocalVersion() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final versionFile = File(path.join(dir.path, 'ui_updates', 'current_version.txt'));
      if (await versionFile.exists()) {
        return await versionFile.readAsString();
      }
    } catch (e) {
      debugPrint('Read version failed: $e');
    }
    return null;
  }
  
  Future<void> _saveLocalVersion(String version) async {
    final dir = await getApplicationDocumentsDirectory();
    final versionFile = File(path.join(dir.path, 'ui_updates', 'current_version.txt'));
    await versionFile.writeAsString(version);
  }
  
  void dispose() {
    _pollingTimer?.cancel();
    _updateController.close();
  }
}

/// Update event types
enum UIUpdateEventType {
  available,   // New update available
  downloaded,  // Update downloaded
  applied,     // Update applied
  failed,      // Update failed
}

/// Update event
class UIUpdateEvent {
  final UIUpdateEventType type;
  final String version;
  final String? filePath;
  final UIUpdateInfo? info;
  
  UIUpdateEvent({
    required this.type,
    required this.version,
    this.filePath,
    this.info,
  });
}

/// Update information from server
class UIUpdateInfo {
  final String version;
  final bool hasUpdate;
  final String? downloadUrl;
  final String? releaseNotes;
  final bool forceUpdate;
  final DateTime? releaseDate;
  
  UIUpdateInfo({
    required this.version,
    required this.hasUpdate,
    this.downloadUrl,
    this.releaseNotes,
    this.forceUpdate = false,
    this.releaseDate,
  });
  
  factory UIUpdateInfo.fromJson(Map<String, dynamic> json) {
    return UIUpdateInfo(
      version: json['version'] as String,
      hasUpdate: json['hasUpdate'] as bool,
      downloadUrl: json['downloadUrl'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'version': version,
    'hasUpdate': hasUpdate,
    'downloadUrl': downloadUrl,
    'releaseNotes': releaseNotes,
    'forceUpdate': forceUpdate,
    'releaseDate': releaseDate?.toIso8601String(),
  };
}
