import 'package:flutter/material.dart';
import '../core/ui_widget.dart';

/// Scaffold widget for app structure
class UIScaffold extends UIWidget {
  final UIWidget? appBar;
  final UIWidget body;
  final UIWidget? floatingActionButton;
  final UIWidget? bottomNavigationBar;
  final UIWidget? drawer;
  final Color? backgroundColor;
  
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
    'type': 'Scaffold',
    if (appBar != null) 'appBar': appBar!.toJson(),
    'body': body.toJson(),
    if (floatingActionButton != null) 'floatingActionButton': floatingActionButton!.toJson(),
    if (bottomNavigationBar != null) 'bottomNavigationBar': bottomNavigationBar!.toJson(),
    if (drawer != null) 'drawer': drawer!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i Scaffold(');
    
    if (appBar != null) {
      buffer.write('$i   appBar: ');
      buffer.write(appBar!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    buffer.write('$i   body: ');
    buffer.write(body.toDartCode(indent: 0));
    buffer.writeln(',');
    
    if (floatingActionButton != null) {
      buffer.write('$i   floatingActionButton: ');
      buffer.write(floatingActionButton!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (backgroundColor != null) {
      buffer.writeln('$i   backgroundColor: Color(${backgroundColor!.value}),');
    }
    
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// AppBar widget
class UIAppBar extends UIWidget {
  final String? title;
  final List<UIWidget>? actions;
  final UIWidget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
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
    'type': 'AppBar',
    if (title != null) 'title': title,
    if (actions != null) 'actions': actions!.map((a) => a.toJson()).toList(),
    if (leading != null) 'leading': leading!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (foregroundColor != null) 'foregroundColor': foregroundColor!.value,
    if (elevation != null) 'elevation': elevation,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i AppBar(');
    
    if (title != null) {
      buffer.writeln("$i   title: Text('$title'),");
    }
    
    if (actions != null && actions!.isNotEmpty) {
      buffer.writeln('$i   actions: [');
      for (final action in actions!) {
        buffer.writeln('${action.toDartCode(indent: indent + 2)},');
      }
      buffer.writeln('$i   ],');
    }
    
    if (backgroundColor != null) {
      buffer.writeln('$i   backgroundColor: Color(${backgroundColor!.value}),');
    }
    
    if (elevation != null) {
      buffer.writeln('$i   elevation: $elevation,');
    }
    
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// SafeArea widget
class UISafeArea extends UIWidget {
  final UIWidget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  
  const UISafeArea({
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'SafeArea',
    'child': child.toJson(),
    'top': top,
    'bottom': bottom,
    'left': left,
    'right': right,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    return '''$i SafeArea(
$i   child: ${child.toDartCode(indent: 0)},
$i)''';
  }
}
