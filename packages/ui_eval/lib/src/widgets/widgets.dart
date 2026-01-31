library;

import 'package:flutter/material.dart';
import 'layout.dart';
import 'content.dart';
import 'input.dart';
import 'lists.dart';
import 'template_processor.dart';

/// Factory for building widgets from JSON definition
class UIWidgets {
  static final _templateProcessor = TemplateProcessor();

  static Widget build({
    required String type,
    required Map<String, dynamic> def,
    required Map<String, dynamic> state,
    required Function(String action, Map<String, dynamic>? params) onAction,
    required Function(String key, dynamic value) onStateChange,
    required dynamic Function(String key) getState,
  }) {
    switch (type) {
      // Layout widgets
      case 'scaffold':
        return UILayout.buildScaffold(
            def, state, onAction, onStateChange, getState);
      case 'appBar':
        return UILayout.buildAppBar(
            def, state, onAction, onStateChange, getState);
      case 'container':
        return UILayout.buildContainer(
            def, state, onAction, onStateChange, getState);
      case 'row':
        return UILayout.buildRow(def, state, onAction, onStateChange, getState);
      case 'column':
        return UILayout.buildColumn(
            def, state, onAction, onStateChange, getState);
      case 'stack':
        return UILayout.buildStack(
            def, state, onAction, onStateChange, getState);
      case 'positioned':
        return UILayout.buildPositioned(
            def, state, onAction, onStateChange, getState);
      case 'expanded':
        return UILayout.buildExpanded(
            def, state, onAction, onStateChange, getState);
      case 'sizedBox':
        return UILayout.buildSizedBox(
            def, state, onAction, onStateChange, getState);
      case 'padding':
        return UILayout.buildPadding(
            def, state, onAction, onStateChange, getState);
      case 'center':
        return UILayout.buildCenter(
            def, state, onAction, onStateChange, getState);
      case 'wrap':
        return UILayout.buildWrap(
            def, state, onAction, onStateChange, getState);

      // Content widgets
      case 'text':
        return UIContent.buildText(
            def, state, onAction, onStateChange, getState);
      case 'button':
        return UIContent.buildButton(
            def, state, onAction, onStateChange, getState);
      case 'icon':
        return UIContent.buildIcon(
            def, state, onAction, onStateChange, getState);
      case 'image':
        return UIContent.buildImage(
            def, state, onAction, onStateChange, getState);
      case 'card':
        return UIContent.buildCard(
            def, state, onAction, onStateChange, getState);
      case 'divider':
        return UIContent.buildDivider(
            def, state, onAction, onStateChange, getState);
      case 'iconButton':
        return UIContent.buildIconButton(
            def, state, onAction, onStateChange, getState);
      case 'floatingActionButton':
        return UIContent.buildFloatingActionButton(
            def, state, onAction, onStateChange, getState);
      case 'chip':
        return UIContent.buildChip(
            def, state, onAction, onStateChange, getState);

      // Input widgets
      case 'textField':
        return UIInput.buildTextField(
            def, state, onAction, onStateChange, getState);
      case 'checkbox':
        return UIInput.buildCheckbox(
            def, state, onAction, onStateChange, getState);
      case 'switch':
        return UIInput.buildSwitch(
            def, state, onAction, onStateChange, getState);
      case 'slider':
        return UIInput.buildSlider(
            def, state, onAction, onStateChange, getState);

      // List widgets
      case 'listView':
        return UILists.buildListView(
            def, state, onAction, onStateChange, getState);
      case 'listTile':
        return UILists.buildListTile(
            def, state, onAction, onStateChange, getState);
      case 'gridView':
        return UILists.buildGridView(
            def, state, onAction, onStateChange, getState);

      default:
        return const SizedBox.shrink();
    }
  }

  /// Process action parameters using Jinja template engine
  static Map<String, dynamic>? processActionParams(
    Map<String, dynamic>? params,
    Map<String, dynamic> state,
  ) {
    return _templateProcessor.processActionParams(params, state);
  }

  /// Process template references using Jinja template engine
  /// Now supports complex expressions like {{state.items.length}}
  static dynamic processRefs(dynamic value, Map<String, dynamic> state) {
    return _templateProcessor.processRefs(value, state);
  }

  /// Parse color from string value
  static Color? parseColor(String? colorValue) {
    if (colorValue == null) return null;

    switch (colorValue.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'teal':
        return Colors.teal;
      case 'cyan':
        return Colors.cyan;
      case 'indigo':
        return Colors.indigo;
      case 'lime':
        return Colors.lime;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'transparent':
        return Colors.transparent;
      default:
        // Try to parse hex color
        if (colorValue.startsWith('#')) {
          try {
            final hex = colorValue.substring(1);
            if (hex.length == 6) {
              return Color(int.parse('FF$hex', radix: 16));
            } else if (hex.length == 8) {
              return Color(int.parse(hex, radix: 16));
            }
          } catch (e) {
            return null;
          }
        }
        return null;
    }
  }

  /// Parse icon from string value
  static IconData parseIcon(String? iconValue) {
    if (iconValue == null) return Icons.help_outline;

    switch (iconValue.toLowerCase()) {
      case 'add':
        return Icons.add;
      case 'remove':
        return Icons.remove;
      case 'delete':
        return Icons.delete;
      case 'edit':
        return Icons.edit;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'home':
        return Icons.home;
      case 'settings':
        return Icons.settings;
      case 'search':
        return Icons.search;
      case 'menu':
        return Icons.menu;
      case 'more_vert':
        return Icons.more_vert;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'refresh':
        return Icons.refresh;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'person':
        return Icons.person;
      case 'mail':
        return Icons.mail;
      case 'phone':
        return Icons.phone;
      case 'camera':
        return Icons.camera;
      case 'location_on':
        return Icons.location_on;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      default:
        return Icons.help_outline;
    }
  }

  /// Get alignment from string value
  static Alignment parseAlignment(String? alignValue) {
    if (alignValue == null) return Alignment.center;
    switch (alignValue.toLowerCase()) {
      case 'topleft':
        return Alignment.topLeft;
      case 'topcenter':
        return Alignment.topCenter;
      case 'topright':
        return Alignment.topRight;
      case 'centerleft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerright':
        return Alignment.centerRight;
      case 'bottomleft':
        return Alignment.bottomLeft;
      case 'bottomcenter':
        return Alignment.bottomCenter;
      case 'bottomright':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }
}
