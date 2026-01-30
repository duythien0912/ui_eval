import 'package:flutter/material.dart';
import '../core/ui_widget.dart';

/// Column layout widget
class UIColumn extends UIWidget {
  final List<UIWidget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;
  
  const UIColumn({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Column',
    'children': children.map((c) => c.toJson()).toList(),
    'mainAxisAlignment': mainAxisAlignment.index,
    'crossAxisAlignment': crossAxisAlignment.index,
    'mainAxisSize': mainAxisSize.index,
    if (spacing != null) 'spacing': spacing,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i Column(');
    
    final props = <String>[];
    if (mainAxisAlignment != MainAxisAlignment.start) {
      props.add('mainAxisAlignment: MainAxisAlignment.values[${mainAxisAlignment.index}]');
    }
    if (crossAxisAlignment != CrossAxisAlignment.center) {
      props.add('crossAxisAlignment: CrossAxisAlignment.values[${crossAxisAlignment.index}]');
    }
    if (mainAxisSize != MainAxisSize.max) {
      props.add('mainAxisSize: MainAxisSize.values[${mainAxisSize.index}]');
    }
    if (spacing != null) {
      props.add('spacing: $spacing');
    }
    
    for (final prop in props) {
      buffer.writeln('$i   $prop,');
    }
    
    buffer.writeln('$i   children: [');
    for (final child in children) {
      buffer.writeln('${child.toDartCode(indent: indent + 2)},');
    }
    buffer.writeln('$i   ],');
    buffer.write('$i)');
    
    return buffer.toString();
  }
}
