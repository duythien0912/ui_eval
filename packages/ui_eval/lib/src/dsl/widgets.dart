library;

import 'types.dart';
import 'action.dart';

/// Base class for all DSL widgets
abstract class UIWidget {
  const UIWidget();
  
  String get type;
  Map<String, dynamic> toJson();
}

/// DSL for Scaffold widget
class UIScaffold extends UIWidget {
  @override
  final String type = 'scaffold';
  
  final UIAppBar? appBar;
  final UIWidget? body;
  final UIFloatingActionButton? floatingActionButton;
  final UIWidget? bottomNavigationBar;

  const UIScaffold({
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (appBar != null) 'appBar': appBar!.toJson(),
    if (body != null) 'body': body!.toJson(),
    if (floatingActionButton != null) 'floatingActionButton': floatingActionButton!.toJson(),
    if (bottomNavigationBar != null) 'bottomNavigationBar': bottomNavigationBar!.toJson(),
  };
}

/// DSL for AppBar widget
class UIAppBar extends UIWidget {
  @override
  final String type = 'appBar';
  
  final String title;
  final String? backgroundColor;
  final String? foregroundColor;
  final double? elevation;
  final bool? centerTitle;
  final UIWidget? leading;
  final List<UIWidget>? actions;

  const UIAppBar({
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle,
    this.leading,
    this.actions,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    if (backgroundColor != null) 'backgroundColor': backgroundColor,
    if (foregroundColor != null) 'foregroundColor': foregroundColor,
    if (elevation != null) 'elevation': elevation,
    if (centerTitle != null) 'centerTitle': centerTitle,
    if (leading != null) 'leading': leading!.toJson(),
    if (actions != null) 'actions': actions!.map((a) => a.toJson()).toList(),
  };
}

/// DSL for Container widget
class UIContainer extends UIWidget {
  @override
  final String type = 'container';
  
  final double? width;
  final double? height;
  final String? color;
  final UIEdgeInsets? padding;
  final UIEdgeInsets? margin;
  final UIDecoration? decoration;
  final UIWidget? child;

  const UIContainer({
    this.width,
    this.height,
    this.color,
    this.padding,
    this.margin,
    this.decoration,
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (color != null) 'color': color,
    if (padding != null) 'padding': padding!.toJson(),
    if (margin != null) 'margin': margin!.toJson(),
    if (decoration != null) 'decoration': decoration!.toJson(),
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Row widget
class UIRow extends UIWidget {
  @override
  final String type = 'row';
  
  final UIMainAxisAlignment? mainAxisAlignment;
  final UICrossAxisAlignment? crossAxisAlignment;
  final List<UIWidget> children;

  const UIRow({
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    required this.children,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mainAxisAlignment != null) 'mainAxisAlignment': mainAxisAlignment!.name,
    if (crossAxisAlignment != null) 'crossAxisAlignment': crossAxisAlignment!.name,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

/// DSL for Column widget
class UIColumn extends UIWidget {
  @override
  final String type = 'column';
  
  final UIMainAxisAlignment? mainAxisAlignment;
  final UICrossAxisAlignment? crossAxisAlignment;
  final List<UIWidget> children;

  const UIColumn({
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    required this.children,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mainAxisAlignment != null) 'mainAxisAlignment': mainAxisAlignment!.name,
    if (crossAxisAlignment != null) 'crossAxisAlignment': crossAxisAlignment!.name,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

/// DSL for Text widget
class UIText extends UIWidget {
  @override
  final String type = 'text';
  
  final String text;
  final double? fontSize;
  final UIFontWeight? fontWeight;
  final String? color;
  final UITextAlign? textAlign;
  final int? maxLines;
  final String? decoration;

  const UIText({
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.decoration,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    if (fontSize != null) 'fontSize': fontSize,
    if (fontWeight != null) 'fontWeight': fontWeight!.name,
    if (color != null) 'color': color,
    if (textAlign != null) 'textAlign': textAlign!.name,
    if (maxLines != null) 'maxLines': maxLines,
    if (decoration != null) 'decoration': decoration,
  };
}

/// DSL for Button widget
class UIButton extends UIWidget {
  @override
  final String type = 'button';
  
  final String text;
  final UIButtonType? buttonType;
  final UIActionTrigger? onTap;

  const UIButton({
    required this.text,
    this.buttonType,
    this.onTap,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    if (buttonType != null) 'type_': buttonType!.name,
    if (onTap != null) 'onTap': onTap!.toJson(),
  };
}

/// DSL for IconButton widget
class UIIconButton extends UIWidget {
  @override
  final String type = 'iconButton';
  
  final String icon;
  final double? size;
  final String? color;
  final UIActionTrigger? onTap;

  const UIIconButton({
    required this.icon,
    this.size,
    this.color,
    this.onTap,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'icon': icon,
    if (size != null) 'size': size,
    if (color != null) 'color': color,
    if (onTap != null) 'onTap': onTap!.toJson(),
  };
}

/// DSL for FloatingActionButton widget
class UIFloatingActionButton extends UIWidget {
  @override
  final String type = 'floatingActionButton';
  
  final String? icon;
  final String? backgroundColor;
  final UIActionTrigger? onTap;

  const UIFloatingActionButton({
    this.icon,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (icon != null) 'icon': icon,
    if (backgroundColor != null) 'backgroundColor': backgroundColor,
    if (onTap != null) 'onTap': onTap!.toJson(),
  };
}

/// DSL for Icon widget
class UIIcon extends UIWidget {
  @override
  final String type = 'icon';
  
  final String icon;
  final double? size;
  final String? color;

  const UIIcon({
    required this.icon,
    this.size,
    this.color,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'icon': icon,
    if (size != null) 'size': size,
    if (color != null) 'color': color,
  };
}

/// DSL for SizedBox widget
class UISizedBox extends UIWidget {
  @override
  final String type = 'sizedBox';
  
  final double? width;
  final double? height;
  final UIWidget? child;

  const UISizedBox({
    this.width,
    this.height,
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Expanded widget
class UIExpanded extends UIWidget {
  @override
  final String type = 'expanded';
  
  final int? flex;
  final UIWidget? child;

  const UIExpanded({
    this.flex,
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (flex != null) 'flex': flex,
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Padding widget
class UIPadding extends UIWidget {
  @override
  final String type = 'padding';
  
  final UIEdgeInsets padding;
  final UIWidget? child;

  const UIPadding({
    required this.padding,
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'padding': padding.toJson(),
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Center widget
class UICenter extends UIWidget {
  @override
  final String type = 'center';
  
  final UIWidget? child;

  const UICenter({
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Card widget
class UICard extends UIWidget {
  @override
  final String type = 'card';
  
  final double? elevation;
  final String? color;
  final UIWidget? child;

  const UICard({
    this.elevation,
    this.color,
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (elevation != null) 'elevation': elevation,
    if (color != null) 'color': color,
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Divider widget
class UIDivider extends UIWidget {
  @override
  final String type = 'divider';
  
  final double? height;
  final double? thickness;
  final String? color;

  const UIDivider({
    this.height,
    this.thickness,
    this.color,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (height != null) 'height': height,
    if (thickness != null) 'thickness': thickness,
    if (color != null) 'color': color,
  };
}

/// DSL for TextField widget
class UITextField extends UIWidget {
  @override
  final String type = 'textField';
  
  final dynamic value;
  final String? hint;
  final String? label;
  final UITextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final UIActionTrigger? onChanged;

  const UITextField({
    this.value,
    this.hint,
    this.label,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines,
    this.onChanged,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (value != null) 'value': value,
    if (hint != null) 'hint': hint,
    if (label != null) 'label': label,
    if (keyboardType != null) 'keyboardType': keyboardType!.name,
    if (obscureText) 'obscureText': obscureText,
    if (maxLines != null) 'maxLines': maxLines,
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
  };
}

/// DSL for Checkbox widget
class UICheckbox extends UIWidget {
  @override
  final String type = 'checkbox';
  
  final dynamic value;
  final UIActionTrigger? onChanged;

  const UICheckbox({
    this.value,
    this.onChanged,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (value != null) 'value': value,
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
  };
}

/// DSL for Switch widget
class UISwitch extends UIWidget {
  @override
  final String type = 'switch';
  
  final dynamic value;
  final UIActionTrigger? onChanged;

  const UISwitch({
    this.value,
    this.onChanged,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (value != null) 'value': value,
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
  };
}

/// DSL for Slider widget
class UISlider extends UIWidget {
  @override
  final String type = 'slider';
  
  final dynamic value;
  final double min;
  final double max;
  final int? divisions;
  final UIActionTrigger? onChanged;

  const UISlider({
    this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.onChanged,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (value != null) 'value': value,
    'min': min,
    'max': max,
    if (divisions != null) 'divisions': divisions,
    if (onChanged != null) 'onChanged': onChanged!.toJson(),
  };
}

/// DSL for ListView widget
class UIListView extends UIWidget {
  @override
  final String type = 'listView';
  
  final bool shrinkWrap;
  final UIAxis? scrollDirection;
  final String itemCount;
  final UIWidget itemBuilder;

  const UIListView({
    this.shrinkWrap = false,
    this.scrollDirection,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'shrinkWrap': shrinkWrap,
    if (scrollDirection != null) 'scrollDirection': scrollDirection!.name,
    'itemCount': itemCount,
    'itemBuilder': itemBuilder.toJson(),
  };
}

/// DSL for ListTile widget
class UIListTile extends UIWidget {
  @override
  final String type = 'listTile';
  
  final UIWidget? leading;
  final UIWidget? title;
  final UIWidget? subtitle;
  final UIWidget? trailing;
  final UIActionTrigger? onTap;

  const UIListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (leading != null) 'leading': leading!.toJson(),
    if (title != null) 'title': title!.toJson(),
    if (subtitle != null) 'subtitle': subtitle!.toJson(),
    if (trailing != null) 'trailing': trailing!.toJson(),
    if (onTap != null) 'onTap': onTap!.toJson(),
  };
}

/// DSL for GridView widget
class UIGridView extends UIWidget {
  @override
  final String type = 'gridView';
  
  final bool shrinkWrap;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final String itemCount;
  final UIWidget itemBuilder;

  const UIGridView({
    this.shrinkWrap = false,
    this.crossAxisCount = 2,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'shrinkWrap': shrinkWrap,
    'crossAxisCount': crossAxisCount,
    if (childAspectRatio != null) 'childAspectRatio': childAspectRatio,
    if (crossAxisSpacing != null) 'crossAxisSpacing': crossAxisSpacing,
    if (mainAxisSpacing != null) 'mainAxisSpacing': mainAxisSpacing,
    'itemCount': itemCount,
    'itemBuilder': itemBuilder.toJson(),
  };
}

/// DSL for Wrap widget
class UIWrap extends UIWidget {
  @override
  final String type = 'wrap';
  
  final double? spacing;
  final double? runSpacing;
  final UIWrapAlignment? alignment;
  final List<UIWidget> children;

  const UIWrap({
    this.spacing,
    this.runSpacing,
    this.alignment,
    required this.children,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (spacing != null) 'spacing': spacing,
    if (runSpacing != null) 'runSpacing': runSpacing,
    if (alignment != null) 'alignment': alignment!.name,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

/// DSL for Chip widget
class UIChip extends UIWidget {
  @override
  final String type = 'chip';
  
  final String label;
  final String? backgroundColor;
  final UIWidget? avatar;

  const UIChip({
    required this.label,
    this.backgroundColor,
    this.avatar,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    if (backgroundColor != null) 'backgroundColor': backgroundColor,
    if (avatar != null) 'avatar': avatar!.toJson(),
  };
}

/// DSL for Stack widget
class UIStack extends UIWidget {
  @override
  final String type = 'stack';
  
  final UIAlignment? alignment;
  final List<UIWidget> children;

  const UIStack({
    this.alignment,
    required this.children,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (alignment != null) 'alignment': alignment!.name,
    'children': children.map((c) => c.toJson()).toList(),
  };
}

/// DSL for Positioned widget
class UIPositioned extends UIWidget {
  @override
  final String type = 'positioned';
  
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final UIWidget? child;

  const UIPositioned({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.child,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (left != null) 'left': left,
    if (top != null) 'top': top,
    if (right != null) 'right': right,
    if (bottom != null) 'bottom': bottom,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (child != null) 'child': child!.toJson(),
  };
}

/// DSL for Image widget
class UIImage extends UIWidget {
  @override
  final String type = 'image';
  
  final String src;
  final double? width;
  final double? height;
  final UIBoxFit? fit;

  const UIImage({
    required this.src,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'src': src,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (fit != null) 'fit': fit!.name,
  };
}

/// EdgeInsets DSL
class UIEdgeInsets {
  final double? all;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const UIEdgeInsets.all(this.all)
      : left = null,
        top = null,
        right = null,
        bottom = null;

  const UIEdgeInsets.only({
    this.left,
    this.top,
    this.right,
    this.bottom,
  }) : all = null;

  const UIEdgeInsets.symmetric({
    double? horizontal,
    double? vertical,
  })  : all = null,
        left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  dynamic toJson() {
    if (all != null) return all;
    return {
      if (left != null) 'left': left,
      if (top != null) 'top': top,
      if (right != null) 'right': right,
      if (bottom != null) 'bottom': bottom,
    };
  }
}

/// BoxDecoration DSL
class UIDecoration {
  final String? color;
  final double? borderRadius;

  const UIDecoration({
    this.color,
    this.borderRadius,
  });

  Map<String, dynamic> toJson() => {
    if (color != null) 'color': color,
    if (borderRadius != null) 'borderRadius': borderRadius,
  };
}

/// Action trigger for onTap, onChanged, etc.
class UIActionTrigger {
  final String action;
  final Map<String, dynamic>? params;

  /// Create action trigger from enum or string
  UIActionTrigger({
    required dynamic action,
    this.params,
  }) : action = action is Enum ? action.name : action.toString();

  Map<String, dynamic> toJson() => {
    'action': action,
    if (params != null) 'params': params,
  };
}

/// Alignment enum extension
enum UIAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// WrapAlignment enum extension
enum UIWrapAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}
