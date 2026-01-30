import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Simple HTTP server for serving UI updates
/// Run with: dart example/server/update_server.dart
class UpdateServer {
  final int port;
  final String updatesDir;
  
  HttpServer? _server;
  
  UpdateServer({
    this.port = 8080,
    this.updatesDir = 'updates',
  });
  
  Future<void> start() async {
    // Create updates directory if not exists
    final dir = Directory(updatesDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // Create sample updates
    await _createSampleUpdates();
    
    // Start server
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('Update server running on http://localhost:$port');
    print('Updates directory: ${path.absolute(updatesDir)}');
    print('');
    print('Available endpoints:');
    print('  GET /api/update?version={current} - Check for updates');
    print('  GET /updates/{version}.json - Download UI JSON');
    print('  POST /admin/publish - Publish new update');
    print('');
    
    await for (final request in _server!) {
      _handleRequest(request);
    }
  }
  
  void _handleRequest(HttpRequest request) {
    final uri = request.uri;
    final method = request.method;
    
    print('${DateTime.now()} $method ${uri.path}');
    
    // CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
    
    if (method == 'OPTIONS') {
      request.response.statusCode = 204;
      request.response.close();
      return;
    }
    
    try {
      if (uri.path == '/api/update' && method == 'GET') {
        _handleCheckUpdate(request);
      } else if (uri.path.startsWith('/updates/') && method == 'GET') {
        _handleDownloadUpdate(request);
      } else if (uri.path == '/admin/publish' && method == 'POST') {
        _handlePublishUpdate(request);
      } else if (uri.path == '/admin/list' && method == 'GET') {
        _handleListUpdates(request);
      } else {
        _sendJson(request, {'error': 'Not found'}, status: 404);
      }
    } catch (e) {
      print('Error handling request: $e');
      _sendJson(request, {'error': 'Internal server error'}, status: 500);
    }
  }
  
  void _handleCheckUpdate(HttpRequest request) {
    final currentVersion = request.uri.queryParameters['version'];
    
    // Get latest version
    final latest = _getLatestVersion();
    
    if (latest == null) {
      _sendJson(request, {
        'version': currentVersion ?? '1.0.0',
        'hasUpdate': false,
      });
      return;
    }
    
    final hasUpdate = currentVersion == null || 
        _compareVersions(latest, currentVersion) > 0;
    
    _sendJson(request, {
      'version': latest,
      'hasUpdate': hasUpdate,
      'downloadUrl': '/updates/$latest.json',
      'releaseNotes': 'UI update version $latest',
      'forceUpdate': false,
      'releaseDate': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> _handleDownloadUpdate(HttpRequest request) async {
    final filename = path.basename(request.uri.path);
    final filePath = path.join(updatesDir, filename);
    final file = File(filePath);
    
    if (!await file.exists()) {
      _sendJson(request, {'error': 'Update not found'}, status: 404);
      return;
    }
    
    request.response.headers.contentType = ContentType.json;
    await request.response.addStream(file.openRead());
    await request.response.close();
  }
  
  Future<void> _handlePublishUpdate(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    
    final version = data['version'] as String;
    final uiJson = data['ui'] as Map<String, dynamic>;
    
    // Save update
    final filename = '$version.json';
    final filePath = path.join(updatesDir, filename);
    await File(filePath).writeAsString(jsonEncode(uiJson));
    
    print('Published update: $version');
    
    _sendJson(request, {
      'success': true,
      'version': version,
      'url': '/updates/$filename',
    });
  }
  
  Future<void> _handleListUpdates(HttpRequest request) async {
    final dir = Directory(updatesDir);
    if (!await dir.exists()) {
      _sendJson(request, {'updates': []});
      return;
    }
    
    final files = await dir
        .list()
        .where((f) => f is File && f.path.endsWith('.json'))
        .map((f) => path.basenameWithoutExtension(f.path))
        .toList();
    
    files.sort((a, b) => _compareVersions(b, a));
    
    _sendJson(request, {
      'updates': files.map((v) => {
        'version': v,
        'url': '/updates/$v.json',
      }).toList(),
    });
  }
  
  Future<void> _createSampleUpdates() async {
    // Version 1.0.0 - Basic UI
    final v1 = {
      'version': '1.0.0',
      'name': 'TodoPage',
      'states': [],
      'root': {
        'type': 'Scaffold',
        'appBar': {
          'type': 'AppBar',
          'title': 'Todo App v1.0',
          'backgroundColor': Colors.blue.value,
        },
        'body': {
          'type': 'Center',
          'child': {
            'type': 'Text',
            'data': 'Basic Todo App',
          },
        },
      },
    };
    
    // Version 1.1.0 - Enhanced UI with stats
    final v2 = {
      'version': '1.1.0',
      'name': 'TodoPage',
      'states': [
        {'key': 'pendingCount', 'type': 'int', 'defaultValue': 0},
        {'key': 'completedCount', 'type': 'int', 'defaultValue': 0},
      ],
      'root': {
        'type': 'Scaffold',
        'appBar': {
          'type': 'AppBar',
          'title': 'Todo App v1.1 (Updated!)',
          'backgroundColor': Colors.teal.value,
          'foregroundColor': Colors.white.value,
        },
        'body': {
          'type': 'Column',
          'children': [
            {
              'type': 'Container',
              'color': Colors.teal[50]?.value,
              'padding': {'left': 16, 'top': 16, 'right': 16, 'bottom': 16},
              'child': {
                'type': 'Row',
                'mainAxisAlignment': 2, // spaceEvenly
                'children': [
                  {
                    'type': 'Column',
                    'children': [
                      {'type': 'Text', 'data': '{{pendingCount}}', 'fontSize': 32, 'fontWeight': 1, 'color': Colors.teal.value},
                      {'type': 'Text', 'data': 'Pending', 'color': Colors.grey[600]?.value},
                    ],
                  },
                  {
                    'type': 'Column',
                    'children': [
                      {'type': 'Text', 'data': '{{completedCount}}', 'fontSize': 32, 'fontWeight': 1, 'color': Colors.green.value},
                      {'type': 'Text', 'data': 'Done', 'color': Colors.grey[600]?.value},
                    ],
                  },
                ],
              },
            },
            {'type': 'Expanded', 'child': {'type': 'Center', 'child': {'type': 'Text', 'data': 'Your todos will appear here'}}},
          ],
        },
      },
    };
    
    // Save sample updates
    await File(path.join(updatesDir, '1.0.0.json')).writeAsString(jsonEncode(v1));
    await File(path.join(updatesDir, '1.1.0.json')).writeAsString(jsonEncode(v2));
    
    print('Created sample updates: 1.0.0, 1.1.0');
  }
  
  String? _getLatestVersion() {
    final dir = Directory(updatesDir);
    if (!dir.existsSync()) return null;
    
    final versions = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => path.basenameWithoutExtension(f.path))
        .toList();
    
    if (versions.isEmpty) return null;
    
    versions.sort((a, b) => _compareVersions(b, a));
    return versions.first;
  }
  
  int _compareVersions(String a, String b) {
    final partsA = a.split('.').map(int.parse).toList();
    final partsB = b.split('.').map(int.parse).toList();
    
    for (var i = 0; i < partsA.length && i < partsB.length; i++) {
      final cmp = partsA[i].compareTo(partsB[i]);
      if (cmp != 0) return cmp;
    }
    
    return partsA.length.compareTo(partsB.length);
  }
  
  void _sendJson(HttpRequest request, Map<String, dynamic> data, {int status = 200}) {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data));
    request.response.close();
  }
  
  Future<void> stop() async {
    await _server?.close();
  }
}

void main() async {
  final server = UpdateServer(port: 8080);
  
  // Handle Ctrl+C
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down server...');
    await server.stop();
    exit(0);
  });
  
  await server.start();
}
