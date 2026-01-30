import '../types.dart';
import '../ui_widget.dart';

// ==================== Layout Widgets ====================

/// Column layout widget
class UIColumn extends UIWidget {
  final List<UIWidget> children;
  final UIMainAxisAlignment mainAxisAlignment;
  final UICrossAxisAlignment crossAxisAlignment;
  final UIMainAxisSize mainAxisSize;
  final double? spacing;
  
  const UIColumn({
    required this.children,
    this.mainAxisAlignment = UIMainAxisAlignment.start,
    this.crossAxisAlignment = UICrossAxisAlignment.center,
    this.mainAxisSize = UIMainAxisSize.max,
    this.spacing,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'children': children.map((c) => c.toJson()).toList(),
    'mainAxisAlignment': mainAxisAlignment.index,
    'crossAxisAlignment': crossAxisAlignment.index,
    'mainAxisSize': mainAxisSize.index,
    if (spacing != null) 'spacing': spacing,
  };
}

/// Row layout widget
class UIRow extends UIWidget {
  final List<UIWidget> children;
  final UIMainAxisAlignment mainAxisAlignment;
  final UICrossAxisAlignment crossAxisAlignment;
  final UIMainAxisSize mainAxisSize;
  final double? spacing;
  
  const UIRow({
    required this.children,
    this.mainAxisAlignment = UIMainAxisAlignment.start,
    this.crossAxisAlignment = UICrossAxisAlignment.center,
    this.mainAxisSize = UIMainAxisSize.max,
    this.spacing,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'children': children.map((c) => c.toJson()).toList(),
    'mainAxisAlignment': mainAxisAlignment.index,
    'crossAxisAlignment': crossAxisAlignment.index,
    'mainAxisSize': mainAxisSize.index,
    if (spacing != null) 'spacing': spacing,
  };
}

/// Stack layout widget
class UIStack extends UIWidget {
  final List<UIWidget> children;
  final UIAlignment alignment;
  
  const UIStack({
    required this.children,
    this.alignment = UIAlignment.topLeft,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'children': children.map((c) => c.toJson()).toList(),
    'alignment': {'x': alignment.x, 'y': alignment.y},
  };
}

/// Positioned widget for Stack
class UIPositioned extends UIWidget {
  final UIWidget child;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  
  const UIPositioned({
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
  });
  
  factory UIPositioned.fill({required UIWidget child}) => 
      UIPositioned(left: 0, top: 0, right: 0, bottom: 0, child: child);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    if (left != null) 'left': left,
    if (top != null) 'top': top,
    if (right != null) 'right': right,
    if (bottom != null) 'bottom': bottom,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };
}

/// Container widget
class UIContainer extends UIWidget {
  final UIWidget? child;
  final UIColor? color;
  final double? width;
  final double? height;
  final UIEdgeInsets? padding;
  final UIEdgeInsets? margin;
  final UIAlignment? alignment;
  
  const UIContainer({
    this.child,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.alignment,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (child != null) 'child': child!.toJson(),
    if (color != null) 'color': color!.toJson(),
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (padding != null) 'padding': padding!.toJson(),
    if (margin != null) 'margin': margin!.toJson(),
    if (alignment != null) 'alignment': {'x': alignment!.x, 'y': alignment!.y},
  };
}

/// Center alignment widget
class UICenter extends UIWidget {
  final UIWidget child;
  final double? widthFactor;
  final double? heightFactor;
  
  const UICenter({
    required this.child,
    this.widthFactor,
    this.heightFactor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    if (widthFactor != null) 'widthFactor': widthFactor,
    if (heightFactor != null) 'heightFactor': heightFactor,
  };
}

/// Align widget
class UIAlign extends UIWidget {
  final UIWidget child;
  final UIAlignment alignment;
  
  const UIAlign({
    required this.child,
    this.alignment = UIAlignment.center,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    'alignment': {'x': alignment.x, 'y': alignment.y},
  };
}

/// Padding widget
class UIPadding extends UIWidget {
  final UIWidget child;
  final UIEdgeInsets padding;
  
  const UIPadding({
    required this.child,
    required this.padding,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    'padding': padding.toJson(),
  };
}

/// SafeArea widget
class UISafeArea extends UIWidget {
  final UIWidget child;
  
  const UISafeArea({required this.child});
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
  };
}

/// Expanded widget
class UIExpanded extends UIWidget {
  final UIWidget child;
  final int flex;
  
  const UIExpanded({
    required this.child,
    this.flex = 1,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    'flex': flex,
  };
}

/// SizedBox widget
class UISizedBox extends UIWidget {
  final UIWidget? child;
  final double? width;
  final double? height;
  
  const UISizedBox({
    this.child,
    this.width,
    this.height,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (child != null) 'child': child!.toJson(),
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };
}

/// Scaffold widget
class UIScaffold extends UIWidget {
  final UIWidget? appBar;
  final UIWidget body;
  final UIWidget? floatingActionButton;
  final UIWidget? bottomNavigationBar;
  final UIWidget? drawer;
  final UIColor? backgroundColor;
  
  const UIScaffold({
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (appBar != null) 'appBar': appBar!.toJson(),
    'body': body.toJson(),
    if (floatingActionButton != null) 'floatingActionButton': floatingActionButton!.toJson(),
    if (bottomNavigationBar != null) 'bottomNavigationBar': bottomNavigationBar!.toJson(),
    if (drawer != null) 'drawer': drawer!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
  };
}

/// AppBar widget
class UIAppBar extends UIWidget {
  final String? title;
  final List<UIWidget>? actions;
  final UIWidget? leading;
  final UIColor? backgroundColor;
  final UIColor? foregroundColor;
  final double? elevation;
  
  const UIAppBar({
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (title != null) 'title': title,
    if (actions != null) 'actions': actions!.map((a) => a.toJson()).toList(),
    if (leading != null) 'leading': leading!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
    if (foregroundColor != null) 'foregroundColor': foregroundColor!.toJson(),
    if (elevation != null) 'elevation': elevation,
  };
}

/// Divider widget
class UIDivider extends UIWidget {
  final double? height;
  final double? thickness;
  final UIColor? color;
  final double? indent;
  final double? endIndent;
  
  const UIDivider({
    this.height,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (height != null) 'height': height,
    if (thickness != null) 'thickness': thickness,
    if (color != null) 'color': color!.toJson(),
    if (indent != null) 'indent': indent,
    if (endIndent != null) 'endIndent': endIndent,
  };
}
