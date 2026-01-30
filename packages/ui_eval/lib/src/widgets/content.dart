library;

import 'package:flutter/material.dart';
import 'widgets.dart';

class UIContent {
  static Widget buildText(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final text = UIWidgets.processRefs(def['text'], state)?.toString() ?? '';
    return Text(
      text,
      style: TextStyle(
        fontSize: (def['fontSize'] as num?)?.toDouble(),
        fontWeight: _parseFontWeight(def['fontWeight'] as String?),
        color: UIWidgets.parseColor(def['color'] as String?),
        decoration: _parseTextDecoration(def['decoration'] as String?),
      ),
      textAlign: _parseTextAlign(def['textAlign'] as String?),
      maxLines: (def['maxLines'] as num?)?.toInt(),
      overflow: _parseTextOverflow(def['overflow'] as String?),
    );
  }

  static Widget buildButton(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final text = UIWidgets.processRefs(def['text'], state)?.toString() ?? '';
    final buttonType = def['type_'] as String? ?? 'elevated';
    final onTapAction = def['onTap'] as Map<String, dynamic>?;

    VoidCallback? onPressed;
    if (onTapAction != null) {
      onPressed = () {
        final actionName = onTapAction['action'] as String;
        final params = onTapAction['params'] as Map<String, dynamic>?;
        onAction(actionName, params);
      };
    }

    switch (buttonType) {
      case 'text':
        return TextButton(
          onPressed: onPressed,
          child: Text(text),
        );
      case 'outlined':
        return OutlinedButton(
          onPressed: onPressed,
          child: Text(text),
        );
      case 'icon':
        return IconButton(
          onPressed: onPressed,
          icon: Icon(UIWidgets.parseIcon(def['icon'] as String?)),
        );
      case 'elevated':
      default:
        return ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
        );
    }
  }

  static Widget buildIcon(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Icon(
      UIWidgets.parseIcon(def['icon'] as String?),
      size: (def['size'] as num?)?.toDouble(),
      color: UIWidgets.parseColor(def['color'] as String?),
    );
  }

  static Widget buildImage(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final src = UIWidgets.processRefs(def['src'], state)?.toString() ?? '';
    return Image.network(
      src,
      width: (def['width'] as num?)?.toDouble(),
      height: (def['height'] as num?)?.toDouble(),
      fit: _parseBoxFit(def['fit'] as String?),
    );
  }

  static Widget buildCard(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Card(
      elevation: (def['elevation'] as num?)?.toDouble(),
      color: UIWidgets.parseColor(def['color'] as String?),
      child: def['child'] != null
          ? UIWidgets.build(
              type: def['child']['type'] as String,
              def: def['child'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
    );
  }

  static Widget buildDivider(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Divider(
      height: (def['height'] as num?)?.toDouble(),
      thickness: (def['thickness'] as num?)?.toDouble(),
      indent: (def['indent'] as num?)?.toDouble(),
      endIndent: (def['endIndent'] as num?)?.toDouble(),
      color: UIWidgets.parseColor(def['color'] as String?),
    );
  }

  static Widget buildIconButton(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final onTapAction = def['onTap'] as Map<String, dynamic>?;

    return IconButton(
      icon: Icon(UIWidgets.parseIcon(def['icon'] as String?)),
      iconSize: (def['size'] as num?)?.toDouble(),
      color: UIWidgets.parseColor(def['color'] as String?),
      onPressed: onTapAction != null
          ? () {
              final actionName = onTapAction['action'] as String;
              final params = onTapAction['params'] as Map<String, dynamic>?;
              onAction(actionName, params);
            }
          : null,
    );
  }

  static Widget buildFloatingActionButton(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final onTapAction = def['onTap'] as Map<String, dynamic>?;

    return FloatingActionButton(
      onPressed: onTapAction != null
          ? () {
              final actionName = onTapAction['action'] as String;
              final params = onTapAction['params'] as Map<String, dynamic>?;
              onAction(actionName, params);
            }
          : null,
      backgroundColor: UIWidgets.parseColor(def['backgroundColor'] as String?),
      child: def['icon'] != null
          ? Icon(UIWidgets.parseIcon(def['icon'] as String?))
          : def['child'] != null
              ? UIWidgets.build(
                  type: def['child']['type'] as String,
                  def: def['child'] as Map<String, dynamic>,
                  state: state,
                  onAction: onAction,
                  onStateChange: onStateChange,
                  getState: getState,
                )
              : null,
    );
  }

  static Widget buildChip(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final label = UIWidgets.processRefs(def['label'], state)?.toString() ?? '';

    return Chip(
      label: Text(label),
      backgroundColor: UIWidgets.parseColor(def['backgroundColor'] as String?),
      avatar: def['avatar'] != null
          ? UIWidgets.build(
              type: def['avatar']['type'] as String,
              def: def['avatar'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
    );
  }

  // Helper methods
  static FontWeight? _parseFontWeight(String? value) {
    switch (value) {
      case 'thin': return FontWeight.w100;
      case 'extraLight': return FontWeight.w200;
      case 'light': return FontWeight.w300;
      case 'normal': return FontWeight.normal;
      case 'medium': return FontWeight.w500;
      case 'semiBold': return FontWeight.w600;
      case 'bold': return FontWeight.bold;
      case 'extraBold': return FontWeight.w800;
      case 'black': return FontWeight.w900;
      default: return null;
    }
  }

  static TextAlign? _parseTextAlign(String? value) {
    switch (value) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      default: return null;
    }
  }

  static TextDecoration? _parseTextDecoration(String? value) {
    switch (value) {
      case 'none': return TextDecoration.none;
      case 'underline': return TextDecoration.underline;
      case 'lineThrough': return TextDecoration.lineThrough;
      case 'overline': return TextDecoration.overline;
      default: return null;
    }
  }

  static TextOverflow? _parseTextOverflow(String? value) {
    switch (value) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'visible': return TextOverflow.visible;
      default: return null;
    }
  }

  static BoxFit? _parseBoxFit(String? value) {
    switch (value) {
      case 'fill': return BoxFit.fill;
      case 'contain': return BoxFit.contain;
      case 'cover': return BoxFit.cover;
      case 'fitWidth': return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      case 'scaleDown': return BoxFit.scaleDown;
      default: return null;
    }
  }
}
