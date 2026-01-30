import 'package:flutter/material.dart';
import '../core/ui_widget.dart';
import '../core/ui_state.dart';

/// Text widget for the DSL
class UIText extends UIWidget {
  final String data;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  
  const UIText(
    this.data, {
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
  });
  
  /// Create text with state reference
  factory UIText.state(UIStateRef ref, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return UIText(
      ref.expression,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'Text',
    'data': data,
    if (fontSize != null) 'fontSize': fontSize,
    if (color != null) 'color': color!.value,
    if (fontWeight != null) 'fontWeight': fontWeight!.index,
    if (textAlign != null) 'textAlign': textAlign!.index,
    if (maxLines != null) 'maxLines': maxLines,
  };
  
  @override
  String toDartCode({int indent = 0}) {
    final i = _indent(indent);
    final buffer = StringBuffer();
    buffer.write('$i Text(');
    
    // Handle state reference or literal string
    if (data.startsWith('{{') && data.endsWith('}}')) {
      buffer.write("'\${${data.substring(2, data.length - 2)}}'");
    } else {
      buffer.write("'$data'");
    }
    
    final props = <String>[];
    if (fontSize != null) props.add("style: TextStyle(fontSize: $fontSize)");
    if (color != null) props.add("style: TextStyle(color: Color(${color!.value}))");
    if (fontWeight != null) props.add("style: TextStyle(fontWeight: FontWeight.values[${fontWeight!.index}])");
    if (textAlign != null) props.add("textAlign: TextAlign.values[${textAlign!.index}]");
    if (maxLines != null) props.add("maxLines: $maxLines");
    
    if (props.isNotEmpty) {
      buffer.write(', ');
      buffer.write(props.join(', '));
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}
