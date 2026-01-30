import '../types.dart';
import '../ui_widget.dart';

// ==================== Content Widgets ====================

/// Text widget
class UIText extends UIWidget {
  final String data;
  final double? fontSize;
  final UIColor? color;
  final UIFontWeight? fontWeight;
  final UITextAlign? textAlign;
  final int? maxLines;
  
  const UIText(
    this.data, {
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
  });
  
  factory UIText.ref(UIRef ref, {
    double? fontSize,
    UIColor? color,
    UIFontWeight? fontWeight,
    UITextAlign? textAlign,
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
  
  factory UIText.state(UIState state, {
    double? fontSize,
    UIColor? color,
    UIFontWeight? fontWeight,
    UITextAlign? textAlign,
    int? maxLines,
  }) {
    return UIText.ref(
      state.ref,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'data': data,
    if (fontSize != null) 'fontSize': fontSize,
    if (color != null) 'color': color!.toJson(),
    if (fontWeight != null) 'fontWeight': fontWeight!.index,
    if (textAlign != null) 'textAlign': textAlign!.index,
    if (maxLines != null) 'maxLines': maxLines,
  };
}

/// Icon widget
class UIIcon extends UIWidget {
  final UIIconData icon;
  final double? size;
  final UIColor? color;
  
  const UIIcon({
    required this.icon,
    this.size,
    this.color,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'icon': icon.toJson(),
    if (size != null) 'size': size,
    if (color != null) 'color': color!.toJson(),
  };
}

/// Card widget
class UICard extends UIWidget {
  final UIWidget child;
  final double? elevation;
  final UIColor? color;
  final UIEdgeInsets? margin;
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
    'type': flutterType,
    'child': child.toJson(),
    if (elevation != null) 'elevation': elevation,
    if (color != null) 'color': color!.toJson(),
    if (margin != null) 'margin': margin!.toJson(),
    if (onTap != null) 'onTap': onTap!.toJson(),
  };
}

/// Chip widget
class UIChip extends UIWidget {
  final UIWidget label;
  final UIIconData? avatar;
  final UIActionRef? onDeleted;
  final UIActionRef? onPressed;
  final UIColor? backgroundColor;
  
  const UIChip({
    required this.label,
    this.avatar,
    this.onDeleted,
    this.onPressed,
    this.backgroundColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'label': label.toJson(),
    if (avatar != null) 'avatar': avatar!.toJson(),
    if (onDeleted != null) 'onDeleted': onDeleted!.toJson(),
    if (onPressed != null) 'onPressed': onPressed!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
  };
}
