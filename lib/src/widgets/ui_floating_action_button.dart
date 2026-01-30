import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_action.dart';

/// Floating action button widget
class UIFloatingActionButton extends UIWidget {
  final UIActionRef onPressed;
  final UIWidget? child;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final bool mini;
  
  const UIFloatingActionButton({
    required this.onPressed,
    this.child,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.mini = false,
  }) : assert(child != null || icon != null, 'Either child or icon must be provided');
  
  factory UIFloatingActionButton.icon({
    required UIActionRef onPressed,
    required IconData icon,
    Color? backgroundColor,
    Color? foregroundColor,
    String? tooltip,
    bool mini = false,
  }) {
    return UIFloatingActionButton(
      onPressed: onPressed,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
      mini: mini,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'FloatingActionButton',
    'onPressed': onPressed.toString(),
    if (child != null) 'child': child!.toJson(),
    if (icon != null) 'icon': icon!.codePoint,
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (foregroundColor != null) 'foregroundColor': foregroundColor!.value,
    if (elevation != null) 'elevation': elevation,
    if (tooltip != null) 'tooltip': tooltip,
    'mini': mini,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i FloatingActionButton(');
    buffer.writeln('$i   onPressed: () { /* ${onPressed.toString()} */ },');
    
    if (mini) {
      buffer.writeln('$i   mini: true,');
    }
    
    if (tooltip != null) {
      buffer.writeln("$i   tooltip: '$tooltip',");
    }
    
    if (backgroundColor != null) {
      buffer.writeln('$i   backgroundColor: Color(${backgroundColor!.value}),');
    }
    
    if (foregroundColor != null) {
      buffer.writeln('$i   foregroundColor: Color(${foregroundColor!.value}),');
    }
    
    if (elevation != null) {
      buffer.writeln('$i   elevation: $elevation,');
    }
    
    if (icon != null) {
      buffer.writeln('$i   child: Icon(Icons.add),');
    } else if (child != null) {
      buffer.write('$i   child: ');
      buffer.write(child!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    buffer.write('$i)');
    
    return buffer.toString();
  }
}
