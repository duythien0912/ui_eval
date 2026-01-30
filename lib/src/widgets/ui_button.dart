import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_action.dart';

/// Button widget for the DSL
class UIButton extends UIWidget {
  final UIWidget child;
  final UIActionRef? onPressed;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? elevation;
  
  const UIButton({
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.padding,
    this.elevation,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'ElevatedButton',
    'child': child.toJson(),
    if (onPressed != null) 'onPressed': onPressed.toString(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (padding != null) 'padding': {
      'left': padding!.left,
      'top': padding!.top,
      'right': padding!.right,
      'bottom': padding!.bottom,
    },
    if (elevation != null) 'elevation': elevation,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    buffer.writeln('$i ElevatedButton(');
    
    if (onPressed != null) {
      buffer.writeln('$i   onPressed: () { /* ${onPressed.toString()} */ },');
    } else {
      buffer.writeln('$i   onPressed: null,');
    }
    
    buffer.write('$i   style: ElevatedButton.styleFrom(');
    final styleProps = <String>[];
    if (backgroundColor != null) styleProps.add('backgroundColor: Color(${backgroundColor!.value})');
    if (padding != null) styleProps.add('padding: EdgeInsets.all(${padding!.left})');
    if (elevation != null) styleProps.add('elevation: $elevation');
    if (styleProps.isNotEmpty) {
      buffer.write(styleProps.join(', '));
    }
    buffer.writeln('),');
    
    buffer.write('$i   child: ');
    buffer.write(child.toDartCode(indent: 0));
    buffer.writeln(',');
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// Text button variant
class UITextButton extends UIWidget {
  final UIWidget child;
  final UIActionRef? onPressed;
  
  const UITextButton({
    required this.child,
    this.onPressed,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'TextButton',
    'child': child.toJson(),
    if (onPressed != null) 'onPressed': onPressed.toString(),
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    return '''$i TextButton(
$i   onPressed: () { /* ${onPressed?.toString() ?? 'null'} */ },
$i   child: ${child.toDartCode(indent: 0)},
$i)''';  
  }
}

/// Icon button
class UIIconButton extends UIWidget {
  final IconData icon;
  final UIActionRef? onPressed;
  final Color? color;
  final double? iconSize;
  
  const UIIconButton({
    required this.icon,
    this.onPressed,
    this.color,
    this.iconSize,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'IconButton',
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    if (onPressed != null) 'onPressed': onPressed.toString(),
    if (color != null) 'color': color!.value,
    if (iconSize != null) 'iconSize': iconSize,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final props = <String>[
      'icon: Icon(Icons.${icon.codePoint})',
      'onPressed: () { /* ${onPressed?.toString() ?? 'null'} */ }',
    ];
    if (color != null) props.add('color: Color(${color!.value})');
    if (iconSize != null) props.add('iconSize: $iconSize');
    
    return '$i IconButton(${props.join(', ')})';
  }
}
