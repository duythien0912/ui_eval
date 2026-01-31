library;

// ========================================
// GLOBAL CONSTANTS for clean syntax
// ========================================

/// Main state accessor: state[MyEnum.key]
const state = _StateBuilder();

/// Loop index variable: state[MyEnum.todos][index]
const index = _SpecialVar('index');

/// Input value variable: params: {'value': value}
const value = _SpecialVar('{{value}}');

// ========================================
// IMPLEMENTATION
// ========================================

/// Builder for creating state references with clean syntax
class _StateBuilder {
  const _StateBuilder();

  /// Access state by enum: state[State.todos]
  StateRef operator [](Enum key) => StateRef._fromEnum(key);
}

/// Reference to a state value with chainable operations
class StateRef {
  final String _path;

  StateRef._fromEnum(Enum key) : _path = key.name;
  StateRef._fromPath(this._path);

  /// Get length property: state[State.todos].length
  StateRef get length => StateRef._fromPath('$_path.length');

  /// Array/Map indexing: state[State.todos][index] or state[State.todos]['key']
  StateRef operator [](dynamic indexOrKey) {
    if (indexOrKey is _SpecialVar) {
      // Special variable like 'index'
      return StateRef._fromPath('$_path[${indexOrKey._name}]');
    } else if (indexOrKey is String) {
      // String key for map access
      return StateRef._fromPath("$_path['$indexOrKey']");
    } else if (indexOrKey is int) {
      // Numeric index
      return StateRef._fromPath('$_path[$indexOrKey]');
    } else {
      // Fallback
      return StateRef._fromPath('$_path[$indexOrKey]');
    }
  }

  /// Serialize to string template format (NOT JSON object)
  /// This ensures widgets receive "{{state.key}}" instead of {"_expr": "state.key"}
  dynamic toJson() => toString();

  /// Implicit conversion to string for widget parameters
  @override
  String toString() => '{{state.$_path}}';
}

/// Special variable (index, value, etc.)
class _SpecialVar {
  final String _name;
  const _SpecialVar(this._name);

  /// Serialize to template string format
  dynamic toJson() => toString();

  @override
  String toString() => '{{$_name}}';
}
