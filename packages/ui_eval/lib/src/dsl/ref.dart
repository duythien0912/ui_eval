library;

/// Represents a reference to state in the format {{state.key}}
class UIStateRef {
  final String key;
  final String? fallback;

  const UIStateRef(this.key, {this.fallback});

  /// Parse a reference string like "{{state.count}}" or "{{state.items[0]}}"
  factory UIStateRef.parse(String ref) {
    final match = RegExp(r'\{\{\s*state\.(\w+(?:\[.*?\])?)\s*\}\}').firstMatch(ref);
    if (match == null) {
      throw FormatException('Invalid state reference: $ref');
    }
    return UIStateRef(match.group(1)!);
  }

  static bool isRef(String value) =>
      RegExp(r'\{\{\s*state\.').hasMatch(value);

  @override
  String toString() => '{{state.$key}}';
}

/// Represents a reference to action parameters
class UIParamRef {
  final String key;

  const UIParamRef(this.key);

  factory UIParamRef.parse(String ref) {
    final match = RegExp(r'\{\{\s*params\.(\w+)\s*\}\}').firstMatch(ref);
    if (match == null) {
      throw FormatException('Invalid param reference: $ref');
    }
    return UIParamRef(match.group(1)!);
  }

  static bool isRef(String value) =>
      RegExp(r'\{\{\s*params\.').hasMatch(value);

  @override
  String toString() => '{{params.$key}}';
}
