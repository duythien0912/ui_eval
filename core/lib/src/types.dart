// Core types for ui_eval
// All base types defined here to avoid circular imports

/// Reference to a value
class UIRef {
  final String path;
  final List<String>? args;
  
  const UIRef(this.path, {this.args});
  
  String get expression {
    if (args != null && args!.isNotEmpty) {
      return '{{$path(${args!.join(',')})}}';
    }
    return '{{$path}}';
  }
  
  @override
  String toString() => expression;
  
  Map<String, dynamic> toJson() => {
    '_ref': path,
    if (args != null) '_args': args,
  };
}

/// Reference to an action
class UIActionRef {
  final String name;
  final Map<String, dynamic>? args;
  
  const UIActionRef(this.name, {this.args});
  
  @override
  String toString() => '@$name';
  
  Map<String, dynamic> toJson() => {
    '_action': name,
    if (args != null) '_args': args,
  };
}

/// Represents a reactive state variable
class UIState<T> {
  final String key;
  final T defaultValue;
  final String? type;
  
  const UIState({
    required this.key,
    required this.defaultValue,
    this.type,
  });
  
  Map<String, dynamic> toJson() => {
    'key': key,
    'defaultValue': defaultValue,
    'type': type ?? T.toString(),
  };
  
  UIRef get ref => UIRef(key);
  UIRef prop(String property) => UIRef('$key.$property');
  UIRef index(int idx) => UIRef('$key.$idx');
  
  @override
  String toString() => '{{$key}}';
}

/// Represents an action/event handler
class UIAction {
  final String name;
  final List<UIActionParam> params;
  final String? description;
  
  const UIAction({
    required this.name,
    this.params = const [],
    this.description,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'params': params.map((p) => p.toJson()).toList(),
    if (description != null) 'description': description,
  };
  
  UIActionRef call([Map<String, dynamic>? args]) => UIActionRef(name, args: args);
  
  @override
  String toString() => '@$name';
}

/// Action parameter definition
class UIActionParam {
  final String name;
  final String type;
  final bool required;
  final dynamic defaultValue;
  
  const UIActionParam({
    required this.name,
    required this.type,
    this.required = true,
    this.defaultValue,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'required': required,
    if (defaultValue != null) 'defaultValue': defaultValue,
  };
}

/// Color definition
class UIColor {
  final int value;
  
  const UIColor(this.value);
  
  static const transparent = UIColor(0x00000000);
  static const black = UIColor(0xFF000000);
  static const white = UIColor(0xFFFFFFFF);
  static const red = UIColor(0xFFF44336);
  static const pink = UIColor(0xFFE91E63);
  static const purple = UIColor(0xFF9C27B0);
  static const deepPurple = UIColor(0xFF673AB7);
  static const indigo = UIColor(0xFF3F51B5);
  static const blue = UIColor(0xFF2196F3);
  static const lightBlue = UIColor(0xFF03A9F4);
  static const cyan = UIColor(0xFF00BCD4);
  static const teal = UIColor(0xFF009688);
  static const green = UIColor(0xFF4CAF50);
  static const lightGreen = UIColor(0xFF8BC34A);
  static const lime = UIColor(0xFFCDDC39);
  static const yellow = UIColor(0xFFFFEB3B);
  static const amber = UIColor(0xFFFFC107);
  static const orange = UIColor(0xFFFF9800);
  static const deepOrange = UIColor(0xFFFF5722);
  static const brown = UIColor(0xFF795548);
  static const grey = UIColor(0xFF9E9E9E);
  static const blueGrey = UIColor(0xFF607D8B);
  
  Map<String, dynamic> toJson() => {'_color': value};
}

/// EdgeInsets
class UIEdgeInsets {
  final double left;
  final double top;
  final double right;
  final double bottom;
  
  const UIEdgeInsets.all(double value)
      : left = value, top = value, right = value, bottom = value;
  
  const UIEdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
      : left = horizontal, top = vertical, right = horizontal, bottom = vertical;
  
  const UIEdgeInsets.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });
  
  Map<String, dynamic> toJson() => {
    'left': left,
    'top': top,
    'right': right,
    'bottom': bottom,
  };
}

/// Alignment
enum UIAlignment {
  topLeft(-1.0, -1.0),
  topCenter(0.0, -1.0),
  topRight(1.0, -1.0),
  centerLeft(-1.0, 0.0),
  center(0.0, 0.0),
  centerRight(1.0, 0.0),
  bottomLeft(-1.0, 1.0),
  bottomCenter(0.0, 1.0),
  bottomRight(1.0, 1.0);
  
  final double x;
  final double y;
  const UIAlignment(this.x, this.y);
}

/// Axis alignments
enum UIMainAxisAlignment { start, end, center, spaceBetween, spaceAround, spaceEvenly }
enum UICrossAxisAlignment { start, end, center, stretch, baseline }
enum UIMainAxisSize { min, max }

/// Font weight
enum UIFontWeight { w100, w200, w300, w400, w500, w600, w700, w800, w900 }

/// Text alignment
enum UITextAlign { left, right, center, justify, start, end }

/// Icon data
class UIIconData {
  final int codePoint;
  final String? fontFamily;
  final String? fontPackage;
  
  const UIIconData(this.codePoint, {this.fontFamily, this.fontPackage});
  
  static const add = UIIconData(0xe145);
  static const remove = UIIconData(0xe15b);
  static const delete = UIIconData(0xe872);
  static const edit = UIIconData(0xe3c9);
  static const check = UIIconData(0xe5ca);
  static const close = UIIconData(0xe5cd);
  static const arrowBack = UIIconData(0xe5c4);
  static const arrowForward = UIIconData(0xe5c8);
  static const menu = UIIconData(0xe5d2);
  static const moreVert = UIIconData(0xe5d4);
  static const home = UIIconData(0xe88a);
  static const settings = UIIconData(0xe8b8);
  static const person = UIIconData(0xe7fd);
  static const search = UIIconData(0xe8b6);
  static const favorite = UIIconData(0xe87d);
  static const star = UIIconData(0xe838);
  static const info = UIIconData(0xe88e);
  static const warning = UIIconData(0xe002);
  static const error = UIIconData(0xe000);
  static const checkCircle = UIIconData(0xe86c);
  static const refresh = UIIconData(0xe5d5);
  
  Map<String, dynamic> toJson() => {
    'codePoint': codePoint,
    if (fontFamily != null) 'fontFamily': fontFamily,
    if (fontPackage != null) 'fontPackage': fontPackage,
  };
}
