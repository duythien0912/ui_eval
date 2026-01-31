library;

import 'package:jinja/jinja.dart';

/// Template processor using Jinja engine
/// Replaces manual regex parsing with production-ready template engine
class TemplateProcessor {
  static final TemplateProcessor _instance = TemplateProcessor._internal();
  factory TemplateProcessor() => _instance;
  TemplateProcessor._internal();

  late final Environment _env;
  bool _initialized = false;

  /// Initialize the Jinja environment
  void initialize() {
    if (_initialized) return;

    _env = Environment(
      autoReload: false,
      trimBlocks: true,
      leftStripBlocks: true,
    );

    _initialized = true;
  }

  /// Process a value that may contain template expressions
  ///
  /// Examples:
  /// - {{state.todos[index].title}}
  /// - {{state.count}}
  /// - {{state.items.length}}
  ///
  /// The state map should include all variables, including special ones like 'index'
  dynamic processRefs(dynamic value, Map<String, dynamic> state) {
    if (!_initialized) initialize();

    if (value is! String) return value;

    // If no template syntax, return as-is
    if (!value.contains('{{')) return value;

    try {
      // Create nested state structure for Jinja
      // This allows both {{state.todos[index]}} and {{index}} to work
      final contextState = <String, dynamic>{
        'state': state,
        // Extract special variables to top level for bracket notation
        if (state.containsKey('index')) 'index': state['index'],
        if (state.containsKey('value')) 'value': state['value'],
      };

      final template = _env.fromString(value);
      final result = template.render(contextState);

      // Try to parse as number if it looks numeric
      if (result is String) {
        final numValue = num.tryParse(result);
        if (numValue != null) return numValue;

        // Try to parse as bool
        if (result.toLowerCase() == 'true') return true;
        if (result.toLowerCase() == 'false') return false;
      }

      return result;
    } catch (e) {
      // If template parsing fails, return original value
      // This prevents breaking the app on malformed templates
      return value;
    }
  }

  /// Process action parameters to resolve template expressions
  Map<String, dynamic>? processActionParams(
    Map<String, dynamic>? params,
    Map<String, dynamic> state,
  ) {
    if (params == null) return null;

    final processed = <String, dynamic>{};
    params.forEach((key, value) {
      processed[key] = processRefs(value, state);
    });
    return processed;
  }
}
