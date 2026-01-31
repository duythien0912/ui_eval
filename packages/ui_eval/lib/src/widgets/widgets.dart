library;

import 'package:flutter/material.dart';
import 'layout.dart';
import 'content.dart';
import 'input.dart';
import 'lists.dart';

/// Factory for building widgets from JSON definition
class UIWidgets {
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
        return UILayout.buildScaffold(def, state, onAction, onStateChange, getState);
      case 'appBar':
        return UILayout.buildAppBar(def, state, onAction, onStateChange, getState);
      case 'container':
        return UILayout.buildContainer(def, state, onAction, onStateChange, getState);
      case 'row':
        return UILayout.buildRow(def, state, onAction, onStateChange, getState);
      case 'column':
        return UILayout.buildColumn(def, state, onAction, onStateChange, getState);
      case 'stack':
        return UILayout.buildStack(def, state, onAction, onStateChange, getState);
      case 'positioned':
        return UILayout.buildPositioned(def, state, onAction, onStateChange, getState);
      case 'expanded':
        return UILayout.buildExpanded(def, state, onAction, onStateChange, getState);
      case 'sizedBox':
        return UILayout.buildSizedBox(def, state, onAction, onStateChange, getState);
      case 'padding':
        return UILayout.buildPadding(def, state, onAction, onStateChange, getState);
      case 'center':
        return UILayout.buildCenter(def, state, onAction, onStateChange, getState);
      case 'wrap':
        return UILayout.buildWrap(def, state, onAction, onStateChange, getState);

      // Content widgets
      case 'text':
        return UIContent.buildText(def, state, onAction, onStateChange, getState);
      case 'button':
        return UIContent.buildButton(def, state, onAction, onStateChange, getState);
      case 'icon':
        return UIContent.buildIcon(def, state, onAction, onStateChange, getState);
      case 'image':
        return UIContent.buildImage(def, state, onAction, onStateChange, getState);
      case 'card':
        return UIContent.buildCard(def, state, onAction, onStateChange, getState);
      case 'divider':
        return UIContent.buildDivider(def, state, onAction, onStateChange, getState);
      case 'iconButton':
        return UIContent.buildIconButton(def, state, onAction, onStateChange, getState);
      case 'floatingActionButton':
        return UIContent.buildFloatingActionButton(def, state, onAction, onStateChange, getState);
      case 'chip':
        return UIContent.buildChip(def, state, onAction, onStateChange, getState);

      // Input widgets
      case 'textField':
        return UIInput.buildTextField(def, state, onAction, onStateChange, getState);
      case 'checkbox':
        return UIInput.buildCheckbox(def, state, onAction, onStateChange, getState);
      case 'switch':
        return UIInput.buildSwitch(def, state, onAction, onStateChange, getState);
      case 'slider':
        return UIInput.buildSlider(def, state, onAction, onStateChange, getState);

      // List widgets
      case 'listView':
        return UILists.buildListView(def, state, onAction, onStateChange, getState);
      case 'listTile':
        return UILists.buildListTile(def, state, onAction, onStateChange, getState);
      case 'gridView':
        return UILists.buildGridView(def, state, onAction, onStateChange, getState);

      default:
        return const SizedBox.shrink();
    }
  }

  /// Process a value that may contain state references like {{state.key}}
  static dynamic processRefs(dynamic value, Map<String, dynamic> state) {
    if (value is String) {
      // Check if the entire string is a single state reference
      final singleRefMatch = RegExp(r'^\{\{\s*state\.(\w+)\s*\}\}$').firstMatch(value);
      if (singleRefMatch != null) {
        final key = singleRefMatch.group(1)!;
        return state[key];
      }
      
      // Handle {{state.key}} references - replace all occurrences in the string
      final result = value.replaceAllMapped(
        RegExp(r'\{\{\s*state\.(\w+)\s*\}\}'),
        (match) {
          final key = match.group(1)!;
          final stateValue = state[key];
          return stateValue?.toString() ?? '';
        },
      );
      return result;
    }
    return value;
  }

  /// Get color from string value
  static Color? parseColor(String? colorValue) {
    if (colorValue == null) return null;
    if (colorValue.startsWith('#')) {
      return Color(int.parse(colorValue.substring(1), radix: 16) + 0xFF000000);
    }
    // Handle named colors
    switch (colorValue.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'cyan': return Colors.cyan;
      case 'amber': return Colors.amber;
      case 'lime': return Colors.lime;
      case 'indigo': return Colors.indigo;
      case 'brown': return Colors.brown;
      case 'grey':
      case 'gray': return Colors.grey;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'transparent': return Colors.transparent;
      default: return null;
    }
  }

  /// Get icon from string name
  static IconData? parseIcon(String? iconName) {
    if (iconName == null) return null;
    switch (iconName.toLowerCase()) {
      case 'add': return Icons.add;
      case 'remove':
      case 'minus': return Icons.remove;
      case 'delete': return Icons.delete;
      case 'edit': return Icons.edit;
      case 'save': return Icons.save;
      case 'cancel': return Icons.cancel;
      case 'check':
      case 'done': return Icons.check;
      case 'close': return Icons.close;
      case 'arrow_back': return Icons.arrow_back;
      case 'arrow_forward': return Icons.arrow_forward;
      case 'menu': return Icons.menu;
      case 'home': return Icons.home;
      case 'search': return Icons.search;
      case 'settings': return Icons.settings;
      case 'person':
      case 'user': return Icons.person;
      case 'refresh': return Icons.refresh;
      case 'favorite': return Icons.favorite;
      case 'star': return Icons.star;
      case 'share': return Icons.share;
      case 'more_vert': return Icons.more_vert;
      case 'info': return Icons.info;
      case 'warning': return Icons.warning;
      case 'error': return Icons.error;
      case 'check_circle': return Icons.check_circle;
      case 'circle': return Icons.circle;
      case 'radio_button_unchecked': return Icons.radio_button_unchecked;
      case 'radio_button_checked': return Icons.radio_button_checked;
      case 'check_box': return Icons.check_box;
      case 'check_box_outline_blank': return Icons.check_box_outline_blank;
      default: return null;
    }
  }
}
