import 'package:flutter/material.dart';
import '../core/ui_widget.dart';

/// Icon widget
class UIIcon extends UIWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  
  const UIIcon({
    required this.icon,
    this.size,
    this.color,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Icon',
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    if (size != null) 'size': size,
    if (color != null) 'color': color!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    buffer.write('$i Icon(Icons.add'); // Simplified - would need icon mapping
    
    if (size != null) {
      buffer.write(', size: $size');
    }
    
    if (color != null) {
      buffer.write(', color: Color(${color!.value})');
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}
