import 'types.dart';

/// State builder for fluent API
class UIStateBuilder {
  final List<UIState> _states = [];
  
  UIState<String> string(String key, String defaultValue) {
    final state = UIState<String>(key: key, defaultValue: defaultValue, type: 'String');
    _states.add(state);
    return state;
  }
  
  UIState<int> integer(String key, int defaultValue) {
    final state = UIState<int>(key: key, defaultValue: defaultValue, type: 'int');
    _states.add(state);
    return state;
  }
  
  UIState<double> float(String key, double defaultValue) {
    final state = UIState<double>(key: key, defaultValue: defaultValue, type: 'double');
    _states.add(state);
    return state;
  }
  
  UIState<bool> boolean(String key, bool defaultValue) {
    final state = UIState<bool>(key: key, defaultValue: defaultValue, type: 'bool');
    _states.add(state);
    return state;
  }
  
  UIState<List<T>> list<T>(String key, List<T> defaultValue) {
    final state = UIState<List<T>>(key: key, defaultValue: defaultValue, type: 'List<$T>');
    _states.add(state);
    return state;
  }
  
  UIState<Map<K, V>> map<K, V>(String key, Map<K, V> defaultValue) {
    final state = UIState<Map<K, V>>(key: key, defaultValue: defaultValue, type: 'Map<$K,$V>');
    _states.add(state);
    return state;
  }
  
  List<UIState> get all => List.unmodifiable(_states);
  List<UIState> build() => all;
}

UIStateBuilder get states => UIStateBuilder();
