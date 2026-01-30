import '../types.dart';
import '../ui_widget.dart';

// ==================== Input Widgets ====================

/// Button widget
class UIButton extends UIWidget {
  final UIWidget child;
  final UIActionRef? onPressed;
  final UIColor? backgroundColor;
  final UIColor? foregroundColor;
  final UIEdgeInsets? padding;
  final double? elevation;
  
  const UIButton({
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.elevation,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    if (onPressed != null) 'onPressed': onPressed!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
    if (foregroundColor != null) 'foregroundColor': foregroundColor!.toJson(),
    if (padding != null) 'padding': padding!.toJson(),
    if (elevation != null) 'elevation': elevation,
  };
}

/// Text button
class UITextButton extends UIWidget {
  final UIWidget child;
  final UIActionRef? onPressed;
  final UIColor? foregroundColor;
  
  const UITextButton({
    required this.child,
    this.onPressed,
    this.foregroundColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'child': child.toJson(),
    if (onPressed != null) 'onPressed': onPressed!.toJson(),
    if (foregroundColor != null) 'foregroundColor': foregroundColor!.toJson(),
  };
}

/// Icon button
class UIIconButton extends UIWidget {
  final UIIconData icon;
  final UIActionRef? onPressed;
  final UIColor? color;
  final double? iconSize;
  final String? tooltip;
  
  const UIIconButton({
    required this.icon,
    this.onPressed,
    this.color,
    this.iconSize,
    this.tooltip,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'icon': icon.toJson(),
    if (onPressed != null) 'onPressed': onPressed!.toJson(),
    if (color != null) 'color': color!.toJson(),
    if (iconSize != null) 'iconSize': iconSize,
    if (tooltip != null) 'tooltip': tooltip,
  };
}

/// Floating action button
class UIFloatingActionButton extends UIWidget {
  final UIActionRef onPressed;
  final UIWidget? child;
  final UIIconData? icon;
  final UIColor? backgroundColor;
  final UIColor? foregroundColor;
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
  }) : assert(child != null || icon != null);
  
  factory UIFloatingActionButton.icon({
    required UIActionRef onPressed,
    required UIIconData icon,
    UIColor? backgroundColor,
    UIColor? foregroundColor,
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
    'type': flutterType,
    'onPressed': onPressed.toJson(),
    if (child != null) 'child': child!.toJson(),
    if (icon != null) 'icon': icon!.toJson(),
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.toJson(),
    if (foregroundColor != null) 'foregroundColor': foregroundColor!.toJson(),
    if (elevation != null) 'elevation': elevation,
    if (tooltip != null) 'tooltip': tooltip,
    'mini': mini,
  };
}

/// Text input field
class UITextField extends UIWidget {
  final String? hint;
  final String? label;
  final UIActionRef? onChanged;
  final UIActionRef? onSubmitted;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final UIIconData? prefixIcon;
  final UIIconData? suffixIcon;
  
  const UITextField({
    this.hint,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (hint != null) 'hint': hint,
    if (label != null) 'label': label,
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
    if (onSubmitted != null) 'onSubmitted': onSubmitted!.toJson(),
    'obscureText': obscureText,
    'maxLines': maxLines,
    if (maxLength != null) 'maxLength': maxLength,
    if (prefixIcon != null) 'prefixIcon': prefixIcon!.toJson(),
    if (suffixIcon != null) 'suffixIcon': suffixIcon!.toJson(),
  };
}

/// Checkbox widget
class UICheckbox extends UIWidget {
  final UIRef value;
  final UIActionRef? onChanged;
  final UIColor? activeColor;
  final UIColor? checkColor;
  
  const UICheckbox({
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'value': value.toJson(),
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
    if (activeColor != null) 'activeColor': activeColor!.toJson(),
    if (checkColor != null) 'checkColor': checkColor!.toJson(),
  };
}

/// Switch widget
class UISwitch extends UIWidget {
  final UIRef value;
  final UIActionRef? onChanged;
  final UIColor? activeColor;
  
  const UISwitch({
    required this.value,
    this.onChanged,
    this.activeColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'value': value.toJson(),
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
    if (activeColor != null) 'activeColor': activeColor!.toJson(),
  };
}

/// Radio button
class UIRadio<T> extends UIWidget {
  final T value;
  final UIRef groupValue;
  final UIActionRef? onChanged;
  final UIColor? activeColor;
  
  const UIRadio({
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.activeColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'value': value.toString(),
    'groupValue': groupValue.toJson(),
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
    if (activeColor != null) 'activeColor': activeColor!.toJson(),
  };
}
