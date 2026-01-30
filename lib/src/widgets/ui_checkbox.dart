import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_state.dart';
import '../core/ui_action.dart';

/// Checkbox widget
class UICheckbox extends UIWidget {
  final UIStateRef value;
  final UIActionRef? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double? size;
  
  const UICheckbox({
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Checkbox',
    'value': value.expression,
    if (onChanged != null) 'onChanged': onChanged.toString(),
    if (activeColor != null) 'activeColor': activeColor!.value,
    if (checkColor != null) 'checkColor': checkColor!.value,
    if (size != null) 'size': size,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.write('$i Checkbox(');
    buffer.write('value: ${value.expression.replaceAll('{{', '').replaceAll('}}', '')}, ');
    
    if (onChanged != null) {
      buffer.write('onChanged: (value) { /* ${onChanged.toString()} */ }, ');
    }
    
    if (activeColor != null) {
      buffer.write('activeColor: Color(${activeColor!.value}), ');
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}

/// Checkbox with label (ListTile style)
class UICheckboxListTile extends UIWidget {
  final UIStateRef value;
  final UIWidget title;
  final UIWidget? subtitle;
  final UIActionRef? onChanged;
  final Color? activeColor;
  final Color? tileColor;
  
  const UICheckboxListTile({
    required this.value,
    required this.title,
    this.subtitle,
    this.onChanged,
    this.activeColor,
    this.tileColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'CheckboxListTile',
    'value': value.expression,
    'title': title.toJson(),
    if (subtitle != null) 'subtitle': subtitle!.toJson(),
    if (onChanged != null) 'onChanged': onChanged.toString(),
    if (activeColor != null) 'activeColor': activeColor!.value,
    if (tileColor != null) 'tileColor': tileColor!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i CheckboxListTile(');
    buffer.writeln('$i   value: ${value.expression.replaceAll('{{', '').replaceAll('}}', '')},');
    
    buffer.write('$i   title: ');
    buffer.write(title.toDartCode(indent: 0));
    buffer.writeln(',');
    
    if (subtitle != null) {
      buffer.write('$i   subtitle: ');
      buffer.write(subtitle!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (onChanged != null) {
      buffer.writeln('$i   onChanged: (value) { /* ${onChanged.toString()} */ },');
    }
    
    if (activeColor != null) {
      buffer.writeln('$i   activeColor: Color(${activeColor!.value}),');
    }
    
    buffer.write('$i)');
    return buffer.toString();
  }
}

/// Switch widget
class UISwitch extends UIWidget {
  final UIStateRef value;
  final UIActionRef? onChanged;
  final Color? activeColor;
  final Color? trackColor;
  
  const UISwitch({
    required this.value,
    this.onChanged,
    this.activeColor,
    this.trackColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Switch',
    'value': value.expression,
    if (onChanged != null) 'onChanged': onChanged.toString(),
    if (activeColor != null) 'activeColor': activeColor!.value,
    if (trackColor != null) 'trackColor': trackColor!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.write('$i Switch(');
    buffer.write('value: ${value.expression.replaceAll('{{', '').replaceAll('}}', '')}, ');
    
    if (onChanged != null) {
      buffer.write('onChanged: (value) { /* ${onChanged.toString()} */ }, ');
    }
    
    if (activeColor != null) {
      buffer.write('activeColor: Color(${activeColor!.value}), ');
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}

/// Radio button widget
class UIRadio<T> extends UIWidget {
  final T value;
  final UIStateRef groupValue;
  final UIActionRef? onChanged;
  final Color? activeColor;
  
  const UIRadio({
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.activeColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Radio',
    'value': value.toString(),
    'groupValue': groupValue.expression,
    if (onChanged != null) 'onChanged': onChanged.toString(),
    if (activeColor != null) 'activeColor': activeColor!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.write('$i Radio(');
    buffer.write('value: $value, ');
    buffer.write('groupValue: ${groupValue.expression.replaceAll('{{', '').replaceAll('}}', '')}, ');
    
    if (onChanged != null) {
      buffer.write('onChanged: (value) { /* ${onChanged.toString()} */ }, ');
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}

/// Chip widget for tags/labels
class UIChip extends UIWidget {
  final UIWidget label;
  final UIWidget? avatar;
  final UIActionRef? onDeleted;
  final UIActionRef? onPressed;
  final Color? backgroundColor;
  final Color? deleteIconColor;
  
  const UIChip({
    required this.label,
    this.avatar,
    this.onDeleted,
    this.onPressed,
    this.backgroundColor,
    this.deleteIconColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Chip',
    'label': label.toJson(),
    if (avatar != null) 'avatar': avatar!.toJson(),
    if (onDeleted != null) 'onDeleted': onDeleted.toString(),
    if (onPressed != null) 'onPressed': onPressed.toString(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (deleteIconColor != null) 'deleteIconColor': deleteIconColor!.value,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i Chip(');
    
    buffer.write('$i   label: ');
    buffer.write(label.toDartCode(indent: 0));
    buffer.writeln(',');
    
    if (avatar != null) {
      buffer.write('$i   avatar: ');
      buffer.write(avatar!.toDartCode(indent: 0));
      buffer.writeln(',');
    }
    
    if (onDeleted != null) {
      buffer.writeln('$i   onDeleted: () { /* ${onDeleted.toString()} */ },');
    }
    
    if (backgroundColor != null) {
      buffer.writeln('$i   backgroundColor: Color(${backgroundColor!.value}),');
    }
    
    buffer.write('$i)');
    return buffer.toString();
  }
}
