import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_state.dart';

/// List view for displaying scrollable lists
class UIListView extends UIWidget {
  final List<UIWidget> children;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final UIActionRef? onRefresh;
  
  const UIListView({
    required this.children,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.onRefresh,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'ListView',
    'children': children.map((c) => c.toJson()).toList(),
    'shrinkWrap': shrinkWrap,
    if (physics != null) 'physics': physics.toString(),
    if (padding != null) 'padding': {
      'left': padding!.left,
      'top': padding!.top,
      'right': padding!.right,
      'bottom': padding!.bottom,
    },
    if (onRefresh != null) 'onRefresh': onRefresh.toString(),
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i ListView(');
    
    if (shrinkWrap) {
      buffer.writeln('$i   shrinkWrap: true,');
    }
    
    if (physics != null) {
      buffer.writeln('$i   physics: const NeverScrollableScrollPhysics(),');
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

/// List view builder for dynamic lists
class UIListViewBuilder extends UIWidget {
  final UIStateRef itemCount;
  final UIWidget Function(int index) itemBuilder;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final bool reverse;
  
  const UIListViewBuilder({
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.padding,
    this.reverse = false,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'ListView.builder',
    'itemCount': itemCount.expression,
    'shrinkWrap': shrinkWrap,
    'reverse': reverse,
    if (padding != null) 'padding': {
      'left': padding!.left,
      'top': padding!.top,
      'right': padding!.right,
      'bottom': padding!.bottom,
    },
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i ListView.builder(');
    buffer.writeln('$i   itemCount: ${itemCount.expression.replaceAll('{{', '').replaceAll('}}', '')},');
    
    if (shrinkWrap) {
      buffer.writeln('$i   shrinkWrap: true,');
    }
    
    if (reverse) {
      buffer.writeln('$i   reverse: true,');
    }
    
    buffer.writeln('$i   itemBuilder: (context, index) {');
    // Note: itemBuilder function body would need special handling
    buffer.writeln('$i     return Container(); // Generated item');
    buffer.writeln('$i   },');
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// List tile for list items
class UIListTile extends UIWidget {
  final UIWidget? leading;
  final UIWidget? title;
  final UIWidget? subtitle;
  final UIWidget? trailing;
  final UIActionRef? onTap;
  final UIActionRef? onLongPress;
  final Color? tileColor;
  
  const UIListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.tileColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'ListTile',
    if (leading != null) 'leading': leading!.toJson(),
    if (title != null) 'title': title!.toJson(),
    if (subtitle != null) 'subtitle': subtitle!.toJson(),
    if (trailing != null) 'trailing': trailing!.toJson(),
    if (onTap != null) 'onTap': onTap.toString(),
    if (onLongPress != null) 'onLongPress': onLongPress.toString(),
    if (tileColor != null) 'tileColor': tileColor!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i ListTile(');
    
    if (leading != null) {
      buffer.write('$i   leading: ');
      buffer.write(leading!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (title != null) {
      buffer.write('$i   title: ');
      buffer.write(title!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (subtitle != null) {
      buffer.write('$i   subtitle: ');
      buffer.write(subtitle!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (trailing != null) {
      buffer.write('$i   trailing: ');
      buffer.write(trailing!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (onTap != null) {
      buffer.writeln('$i   onTap: () { /* ${onTap.toString()} */ },');
    }
    
    if (tileColor != null) {
      buffer.writeln('$i   tileColor: Color(${tileColor!.value}),');
    }
    
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// Card container widget
class UICard extends UIWidget {
  final UIWidget child;
  final double? elevation;
  final Color? color;
  final EdgeInsets? margin;
  final UIActionRef? onTap;
  
  const UICard({
    required this.child,
    this.elevation,
    this.color,
    this.margin,
    this.onTap,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Card',
    'child': child.toJson(),
    if (elevation != null) 'elevation': elevation,
    if (color != null) 'color': color!.value,
    if (margin != null) 'margin': {
      'left': margin!.left,
      'top': margin!.top,
      'right': margin!.right,
      'bottom': margin!.bottom,
    },
    if (onTap != null) 'onTap': onTap.toString(),
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i Card(');
    
    if (elevation != null) {
      buffer.writeln('$i   elevation: $elevation,');
    }
    
    if (color != null) {
      buffer.writeln('$i   color: Color(${color!.value}),');
    }
    
    if (margin != null) {
      buffer.writeln('$i   margin: EdgeInsets.all(${margin!.left}),');
    }
    
    buffer.write('$i   child: ');
    buffer.write(child.toDartCode(indent: 0));
    buffer.writeln(',');
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// Divider widget
class UIDivider extends UIWidget {
  final double? height;
  final double? thickness;
  final Color? color;
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
    'type': 'Divider',
    if (height != null) 'height': height,
    if (thickness != null) 'thickness': thickness,
    if (color != null) 'color': color!.value,
    if (indent != null) 'indent': indent,
    if (endIndent != null) 'endIndent': endIndent,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    buffer.write('$i Divider(');
    
    final props = <String>[];
    if (height != null) props.add('height: $height');
    if (thickness != null) props.add('thickness: $thickness');
    if (color != null) props.add('color: Color(${color!.value})');
    if (indent != null) props.add('indent: $indent');
    if (endIndent != null) props.add('endIndent: $endIndent');
    
    if (props.isNotEmpty) {
      buffer.write(props.join(', '));
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}
