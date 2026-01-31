library;

import 'package:flutter/material.dart';
import 'widgets.dart';

class UIInput {
  static Widget buildTextField(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final valueKey = def['value'] as String?;
    final currentValue = UIWidgets.processRefs(valueKey, state)?.toString() ?? '';
    final onChangedAction = def['onChanged'] as Map<String, dynamic>?;

    return TextField(
      controller: TextEditingController(text: currentValue)
        ..selection = TextSelection.collapsed(offset: currentValue.length),
      decoration: InputDecoration(
        hintText: def['hint'] as String?,
        labelText: def['label'] as String?,
        border: const OutlineInputBorder(),
      ),
      keyboardType: _parseTextInputType(def['keyboardType'] as String?),
      obscureText: def['obscureText'] as bool? ?? false,
      maxLines: def['maxLines'] as int? ?? 1,
      onChanged: onChangedAction != null
          ? (value) {
              final actionName = onChangedAction['action'] as String;
              final params = Map<String, dynamic>.from(
                  onChangedAction['params'] as Map<String, dynamic>? ?? {});
              // Process template values like "{{value}}" in params
              params.forEach((key, val) {
                if (val is String && val.contains('{{value}}')) {
                  params[key] = value;
                }
              });
              onAction(actionName, params);
            }
          : null,
    );
  }

  static Widget buildCheckbox(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final value = UIWidgets.processRefs(def['value'], state) as bool? ?? false;
    final onChangedAction = def['onChanged'] as Map<String, dynamic>?;

    return Checkbox(
      value: value,
      onChanged: onChangedAction != null
          ? (newValue) {
              final actionName = onChangedAction['action'] as String;
              final params = Map<String, dynamic>.from(
                  onChangedAction['params'] as Map<String, dynamic>? ?? {});
              // Process template values like "{{value}}" in params
              params.forEach((key, val) {
                if (val is String && val.contains('{{value}}')) {
                  params[key] = newValue;
                }
              });
              onAction(actionName, params);
            }
          : null,
    );
  }

  static Widget buildSwitch(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final value = UIWidgets.processRefs(def['value'], state) as bool? ?? false;
    final onChangedAction = def['onChanged'] as Map<String, dynamic>?;

    return Switch(
      value: value,
      onChanged: onChangedAction != null
          ? (newValue) {
              final actionName = onChangedAction['action'] as String;
              final params = Map<String, dynamic>.from(
                  onChangedAction['params'] as Map<String, dynamic>? ?? {});
              // Process template values like "{{value}}" in params
              params.forEach((key, val) {
                if (val is String && val.contains('{{value}}')) {
                  params[key] = newValue;
                }
              });
              onAction(actionName, params);
            }
          : null,
    );
  }

  static Widget buildSlider(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final value = (UIWidgets.processRefs(def['value'], state) as num?)?.toDouble() ?? 0.0;
    final min = (def['min'] as num?)?.toDouble() ?? 0.0;
    final max = (def['max'] as num?)?.toDouble() ?? 1.0;
    final divisions = (def['divisions'] as num?)?.toInt();
    final onChangedAction = def['onChanged'] as Map<String, dynamic>?;

    // Wrap in Material to satisfy Slider's Material requirement
    return Material(
      type: MaterialType.transparency,
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChangedAction != null
            ? (newValue) {
                final actionName = onChangedAction['action'] as String;
                final params = Map<String, dynamic>.from(
                    onChangedAction['params'] as Map<String, dynamic>? ?? {});
                // Process template values like "{{value}}" in params
                params.forEach((key, val) {
                  if (val is String && val.contains('{{value}}')) {
                    params[key] = newValue;
                  }
                });
                onAction(actionName, params);
              }
            : null,
      ),
    );
  }

  static TextInputType? _parseTextInputType(String? value) {
    switch (value) {
      case 'text': return TextInputType.text;
      case 'number': return TextInputType.number;
      case 'phone': return TextInputType.phone;
      case 'email': return TextInputType.emailAddress;
      case 'url': return TextInputType.url;
      case 'multiline': return TextInputType.multiline;
      default: return null;
    }
  }
}
