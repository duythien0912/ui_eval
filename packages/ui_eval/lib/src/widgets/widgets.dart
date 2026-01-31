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
  /// Now supports nested paths: {{state.todos.length}}, {{state.todos[index].title}}
  static dynamic processRefs(dynamic value, Map<String, dynamic> state) {
    if (value is String) {
      // Enhanced regex to handle nested properties and array indexing
      final singleRefPattern = RegExp(r'^\{\{\s*state\.([\w\[\]\.]+)\s*\}\}$');
      final singleRefMatch = singleRefPattern.firstMatch(value);

      if (singleRefMatch != null) {
        final path = singleRefMatch.group(1)!;
        return _resolveNestedPath(path, state);
      }

      // Handle {{state.path}} references - replace all occurrences in the string
      final result = value.replaceAllMapped(
        RegExp(r'\{\{\s*state\.([\w\[\]\.]+)\s*\}\}'),
        (match) {
          final path = match.group(1)!;
          final resolvedValue = _resolveNestedPath(path, state);
          return resolvedValue?.toString() ?? '';
        },
      );
      return result;
    }
    return value;
  }

  /// Resolve nested property paths like "todos.length" or "todos[index].title"
  static dynamic _resolveNestedPath(String path, Map<String, dynamic> state) {
    try {
      dynamic current = state;

      // Split by dots and brackets to handle paths like "todos.length" or "todos[0].title"
      final parts = path.split(RegExp(r'[\.\[\]]')).where((s) => s.isNotEmpty).toList();

      for (final part in parts) {
        if (current == null) return null;

        // Check if it's an array index
        final indexMatch = RegExp(r'^\d+$').hasMatch(part);
        if (indexMatch) {
          final index = int.parse(part);
          if (current is List && index >= 0 && index < current.length) {
            current = current[index];
          } else {
            return null;
          }
        }
        // Check if it's a special property like "length"
        else if (part == 'length') {
          if (current is List) {
            return current.length;
          } else if (current is Map) {
            return current.length;
          } else if (current is String) {
            return current.length;
          } else {
            return null;
          }
        }
        // Regular property access
        else if (current is Map<String, dynamic>) {
          current = current[part];
        } else {
          return null;
        }
      }

      return current;
    } catch (e) {
      debugPrint('Error resolving path "$path": $e');
      return null;
    }
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
      default: return null;
    }
  }

  /// Get icon from string value
  static IconData? parseIcon(String? iconValue) {
    if (iconValue == null) return null;
    switch (iconValue.toLowerCase()) {
      case 'add': return Icons.add;
      case 'remove': return Icons.remove;
      case 'delete': return Icons.delete;
      case 'edit': return Icons.edit;
      case 'check': return Icons.check;
      case 'close': return Icons.close;
      case 'home': return Icons.home;
      case 'settings': return Icons.settings;
      case 'search': return Icons.search;
      case 'menu': return Icons.menu;
      case 'more_vert': return Icons.more_vert;
      case 'favorite': return Icons.favorite;
      case 'star': return Icons.star;
      case 'refresh': return Icons.refresh;
      case 'info': return Icons.info;
      case 'warning': return Icons.warning;
      case 'error': return Icons.error;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'person': return Icons.person;
      case 'mail': return Icons.mail;
      case 'phone': return Icons.phone;
      case 'camera': return Icons.camera;
      case 'location_on': return Icons.location_on;
      case 'arrow_back': return Icons.arrow_back;
      case 'arrow_forward': return Icons.arrow_forward;
      default: return Icons.help_outline;
    }
  }

  /// Get alignment from string value
  static Alignment parseAlignment(String? alignValue) {
    if (alignValue == null) return Alignment.center;
    switch (alignValue.toLowerCase()) {
      case 'topleft': return Alignment.topLeft;
      case 'topcenter': return Alignment.topCenter;
      case 'topright': return Alignment.topRight;
      case 'centerleft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerright': return Alignment.centerRight;
      case 'bottomleft': return Alignment.bottomLeft;
      case 'bottomcenter': return Alignment.bottomCenter;
      case 'bottomright': return Alignment.bottomRight;
      default: return Alignment.center;
    }
  }
}
