import 'package:flutter/material.dart';
import '../core/ui_widget.dart';

/// Container widget with decoration capabilities
class UIContainer extends UIWidget {
  final UIWidget? child;
  final Color? color;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final Alignment? alignment;
  
  const UIContainer({
    this.child,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Container',
    if (child != null) 'child': child!.toJson(),
    if (color != null) 'color': color!.value,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (padding != null) 'padding': {
      'left': padding!.left,
      'top': padding!.top,
      'right': padding!.right,
      'bottom': padding!.bottom,
    },
    if (margin != null) 'margin': {
      'left': margin!.left,
      'top': margin!.top,
      'right': margin!.right,
      'bottom': margin!.bottom,
    },
    if (alignment != null) 'alignment': alignment.toString(),
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i Container(');
    
    final props = <String>[];
    if (color != null) props.add('color: Color(${color!.value})');
    if (width != null) props.add('width: $width');
    if (height != null) props.add('height: $height');
    if (padding != null) {
      props.add('padding: EdgeInsets.all(${padding!.left})');
    }
    if (margin != null) {
      props.add('margin: EdgeInsets.all(${margin!.left})');
    }
    if (alignment != null) {
      props.add('alignment: Alignment.center');
    }
    
    for (final prop in props) {
      buffer.writeln('$i   $prop,');
    }
    
    if (child != null) {
      buffer.write('$i   child: ');
      buffer.write(child!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// Expanded widget for flex layouts
class UIExpanded extends UIWidget {
  final UIWidget child;
  final int flex;
  
  const UIExpanded({
    required this.child,
    this.flex = 1,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Expanded',
    'child': child.toJson(),
    'flex': flex,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    return '''$i Expanded(
$i   flex: $flex,
$i   child: ${child.toDartCode(indent: 0)},
$i)''';
  }
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
  
  factory UISizedBox.shrink() => const UISizedBox(width: 0, height: 0);
  
  factory UISizedBox.expand({UIWidget? child}) => UISizedBox(
    width: double.infinity,
    height: double.infinity,
    child: child,
  );
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'SizedBox',
    if (child != null) 'child': child!.toJson(),
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    buffer.write('$i SizedBox(');
    
    final props = <String>[];
    if (width != null) props.add('width: $width');
    if (height != null) props.add('height: $height');
    
    if (props.isNotEmpty) {
      buffer.write(props.join(', '));
    }
    
    if (child != null) {
      buffer.write(', child: ');
      buffer.write(child!.toDartCode(indent: 0));
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}

/// Padding widget
class UIPadding extends UIWidget {
  final UIWidget child;
  final EdgeInsets padding;
  
  const UIPadding({
    required this.child,
    required this.padding,
  });
  
  factory UIPadding.all(double value, {required UIWidget child}) {
    return UIPadding(
      padding: EdgeInsets.all(value),
      child: child,
    );
  }
  
  factory UIPadding.symmetric({
    double horizontal = 0,
    double vertical = 0,
    required UIWidget child,
  }) {
    return UIPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Padding',
    'child': child.toJson(),
    'padding': {
      'left': padding.left,
      'top': padding.top,
      'right': padding.right,
      'bottom': padding.bottom,
    },
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    return '''$i Padding(
$i   padding: EdgeInsets.all(${padding.left}),
$i   child: ${child.toDartCode(indent: 0)},
$i)''';
  }
}
