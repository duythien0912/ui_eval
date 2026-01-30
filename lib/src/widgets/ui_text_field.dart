import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_action.dart';

/// Text input field widget
class UITextField extends UIWidget {
  final String? hint;
  final String? label;
  final UIActionRef? onChanged;
  final UIActionRef? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final UIStateRef? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  
  const UITextField({
    this.hint,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'TextField',
    if (hint != null) 'hint': hint,
    if (label != null) 'label': label,
    if (onChanged != null) 'onChanged': onChanged.toString(),
    if (onSubmitted != null) 'onSubmitted': onSubmitted.toString(),
    'obscureText': obscureText,
    if (keyboardType != null) 'keyboardType': keyboardType!.index,
    'maxLines': maxLines,
    if (maxLength != null) 'maxLength': maxLength,
    if (controller != null) 'controller': controller.toString(),
    if (prefixIcon != null) 'prefixIcon': prefixIcon!.codePoint,
    if (suffixIcon != null) 'suffixIcon': suffixIcon!.codePoint,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    
    buffer.writeln('$i TextField(');
    
    if (hint != null) {
      buffer.writeln("$i   decoration: InputDecoration(hintText: '$hint'),");
    }
    
    if (obscureText) {
      buffer.writeln('$i   obscureText: true,');
    }
    
    if (maxLines != 1) {
      buffer.writeln('$i   maxLines: $maxLines,');
    }
    
    if (onChanged != null) {
      buffer.writeln('$i   onChanged: (value) { /* ${onChanged.toString()} */ },');
    }
    
    buffer.write('$i)');
    
    return buffer.toString();
  }
}

/// Form field with validation support
class UIFormField extends UIWidget {
  final String name;
  final UITextField field;
  final String? Function(String?)? validator;
  final bool required;
  
  const UIFormField({
    required this.name,
    required this.field,
    this.validator,
    this.required = false,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'FormField',
    'name': name,
    'field': field.toJson(),
    'required': required,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    // Form field wrapper around text field
    return field.toDartCode(indent: indent);
  }
}
