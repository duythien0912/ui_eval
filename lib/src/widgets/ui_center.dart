import 'package:flutter/material.dart';
import '../core/ui_widget.dart';

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
    'type': 'Center',
    'child': child.toJson(),
    if (widthFactor != null) 'widthFactor': widthFactor,
    if (heightFactor != null) 'heightFactor': heightFactor,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    buffer.write('$i Center(');
    
    final props = <String>[];
    if (widthFactor != null) props.add('widthFactor: $widthFactor');
    if (heightFactor != null) props.add('heightFactor: $heightFactor');
    
    if (props.isNotEmpty) {
      buffer.write(props.join(', '));
      buffer.write(', ');
    }
    
    buffer.write('child: ');
    buffer.write(child.toDartCode(indent: 0));
    buffer.write(')');
    
    return buffer.toString();
  }
}

/// Align widget with custom alignment
class UIAlign extends UIWidget {
  final UIWidget child;
  final Alignment alignment;
  
  const UIAlign({
    required this.child,
    this.alignment = Alignment.center,
  });
  
  factory UIAlign.topLeft({required UIWidget child}) => 
      UIAlign(child: child, alignment: Alignment.topLeft);
  
  factory UIAlign.topRight({required UIWidget child}) => 
      UIAlign(child: child, alignment: Alignment.topRight);
  
  factory UIAlign.bottomLeft({required UIWidget child}) => 
      UIAlign(child: child, alignment: Alignment.bottomLeft);
  
  factory UIAlign.bottomRight({required UIWidget child}) => 
      UIAlign(child: child, alignment: Alignment.bottomRight);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Align',
    'child': child.toJson(),
    'alignment': {'x': alignment.x, 'y': alignment.y},
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    return '''$i Align(
$i   alignment: Alignment(${alignment.x}, ${alignment.y}),
$i   child: ${child.toDartCode(indent: 0)},
$i)''';
  }
}

/// Stack widget for overlapping children
class UIStack extends UIWidget {
  final List<UIWidget> children;
  final Alignment alignment;
  final StackFit fit;
  
  const UIStack({
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Stack',
    'children': children.map((c) => c.toJson()).toList(),
    'alignment': alignment.toString(),
    'fit': fit.index,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i Stack(');
    buffer.writeln('$i   children: [');
    for (final child in children) {
      buffer.writeln('${child.toDartCode(indent: indent + 2)},');
    }
    buffer.writeln('$i   ],');
    buffer.write('$i)');
    
    return buffer.toString();
  }
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
    'type': 'Positioned',
    'child': child.toJson(),
    if (left != null) 'left': left,
    if (top != null) 'top': top,
    if (right != null) 'right': right,
    if (bottom != null) 'bottom': bottom,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.write('$i Positioned(');
    
    final props = <String>[];
    if (left != null) props.add('left: $left');
    if (top != null) props.add('top: $top');
    if (right != null) props.add('right: $right');
    if (bottom != null) props.add('bottom: $bottom');
    if (width != null) props.add('width: $width');
    if (height != null) props.add('height: $height');
    
    if (props.isNotEmpty) {
      buffer.write(props.join(', '));
      buffer.write(', ');
    }
    
    buffer.write('child: ');
    buffer.write(child.toDartCode(indent: 0));
    buffer.write(')');
    
    return buffer.toString();
  }
}
