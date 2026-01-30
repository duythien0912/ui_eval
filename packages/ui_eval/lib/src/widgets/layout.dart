library;

import 'package:flutter/material.dart';
import 'widgets.dart';

class UILayout {
  static Widget buildScaffold(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Scaffold(
      appBar: def['appBar'] != null
          ? buildAppBar(def['appBar'], state, onAction, onStateChange, getState)
              as PreferredSizeWidget
          : null,
      body: def['body'] != null
          ? UIWidgets.build(
              type: def['body']['type'] as String,
              def: def['body'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
      floatingActionButton: def['floatingActionButton'] != null
          ? UIWidgets.build(
              type: 'floatingActionButton',
              def: def['floatingActionButton'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            ) as Widget?
          : null,
      bottomNavigationBar: def['bottomNavigationBar'] != null
          ? UIWidgets.build(
              type: def['bottomNavigationBar']['type'] as String,
              def: def['bottomNavigationBar'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
    );
  }

  static Widget buildAppBar(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return AppBar(
      title: def['title'] != null
          ? Text(UIWidgets.processRefs(def['title'], state)?.toString() ?? '')
          : null,
      backgroundColor: UIWidgets.parseColor(def['backgroundColor'] as String?),
      foregroundColor: UIWidgets.parseColor(def['foregroundColor'] as String?),
      elevation: (def['elevation'] as num?)?.toDouble(),
      centerTitle: def['centerTitle'] as bool?,
      leading: def['leading'] != null
          ? UIWidgets.build(
              type: def['leading']['type'] as String,
              def: def['leading'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
      actions: def['actions'] != null
          ? (def['actions'] as List).map<Widget>((action) => UIWidgets.build(
                type: action['type'] as String,
                def: action as Map<String, dynamic>,
                state: state,
                onAction: onAction,
                onStateChange: onStateChange,
                getState: getState,
              )).toList()
          : null,
    );
  }

  static Widget buildContainer(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Container(
      width: (def['width'] as num?)?.toDouble(),
      height: (def['height'] as num?)?.toDouble(),
      color: UIWidgets.parseColor(def['color'] as String?),
      padding: _parseEdgeInsets(def['padding']),
      margin: _parseEdgeInsets(def['margin']),
      decoration: def['decoration'] != null
          ? BoxDecoration(
              color: UIWidgets.parseColor(def['decoration']['color'] as String?),
              borderRadius: (def['decoration']['borderRadius'] as num?) != null
                  ? BorderRadius.circular(
                      (def['decoration']['borderRadius'] as num).toDouble())
                  : null,
            )
          : null,
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

  static Widget buildRow(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(def['mainAxisAlignment'] as String?),
      crossAxisAlignment: _parseCrossAxisAlignment(def['crossAxisAlignment'] as String?),
      children: (def['children'] as List? ?? [])
          .map<Widget>((child) => UIWidgets.build(
                type: child['type'] as String,
                def: child as Map<String, dynamic>,
                state: state,
                onAction: onAction,
                onStateChange: onStateChange,
                getState: getState,
              ))
          .toList(),
    );
  }

  static Widget buildColumn(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Column(
      mainAxisAlignment: _parseMainAxisAlignment(def['mainAxisAlignment'] as String?),
      crossAxisAlignment: _parseCrossAxisAlignment(def['crossAxisAlignment'] as String?),
      children: (def['children'] as List? ?? [])
          .map<Widget>((child) => UIWidgets.build(
                type: child['type'] as String,
                def: child as Map<String, dynamic>,
                state: state,
                onAction: onAction,
                onStateChange: onStateChange,
                getState: getState,
              ))
          .toList(),
    );
  }

  static Widget buildStack(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Stack(
      alignment: _parseAlignment(def['alignment'] as String?),
      children: (def['children'] as List? ?? [])
          .map<Widget>((child) => UIWidgets.build(
                type: child['type'] as String,
                def: child as Map<String, dynamic>,
                state: state,
                onAction: onAction,
                onStateChange: onStateChange,
                getState: getState,
              ))
          .toList(),
    );
  }

  static Widget buildPositioned(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Positioned(
      left: (def['left'] as num?)?.toDouble(),
      top: (def['top'] as num?)?.toDouble(),
      right: (def['right'] as num?)?.toDouble(),
      bottom: (def['bottom'] as num?)?.toDouble(),
      width: (def['width'] as num?)?.toDouble(),
      height: (def['height'] as num?)?.toDouble(),
      child: def['child'] != null
          ? UIWidgets.build(
              type: def['child']['type'] as String,
              def: def['child'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : const SizedBox.shrink(),
    );
  }

  static Widget buildExpanded(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Expanded(
      flex: (def['flex'] as num?)?.toInt() ?? 1,
      child: def['child'] != null
          ? UIWidgets.build(
              type: def['child']['type'] as String,
              def: def['child'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : const SizedBox.shrink(),
    );
  }

  static Widget buildSizedBox(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return SizedBox(
      width: (def['width'] as num?)?.toDouble(),
      height: (def['height'] as num?)?.toDouble(),
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

  static Widget buildPadding(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Padding(
      padding: _parseEdgeInsets(def['padding']) ?? EdgeInsets.zero,
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

  static Widget buildCenter(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Center(
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

  static Widget buildWrap(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    return Wrap(
      spacing: (def['spacing'] as num?)?.toDouble() ?? 0.0,
      runSpacing: (def['runSpacing'] as num?)?.toDouble() ?? 0.0,
      alignment: _parseWrapAlignment(def['alignment'] as String?),
      children: (def['children'] as List? ?? [])
          .map<Widget>((child) => UIWidgets.build(
                type: child['type'] as String,
                def: child as Map<String, dynamic>,
                state: state,
                onAction: onAction,
                onStateChange: onStateChange,
                getState: getState,
              ))
          .toList(),
    );
  }

  // Helper methods
  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }
    if (value is Map<String, dynamic>) {
      return EdgeInsets.only(
        left: (value['left'] as num?)?.toDouble() ?? 0.0,
        top: (value['top'] as num?)?.toDouble() ?? 0.0,
        right: (value['right'] as num?)?.toDouble() ?? 0.0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0.0,
      );
    }
    return null;
  }

  static MainAxisAlignment _parseMainAxisAlignment(String? value) {
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.center;
    }
  }

  static Alignment _parseAlignment(String? value) {
    switch (value) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default: return Alignment.topLeft;
    }
  }

  static WrapAlignment _parseWrapAlignment(String? value) {
    switch (value) {
      case 'start': return WrapAlignment.start;
      case 'end': return WrapAlignment.end;
      case 'center': return WrapAlignment.center;
      case 'spaceBetween': return WrapAlignment.spaceBetween;
      case 'spaceAround': return WrapAlignment.spaceAround;
      case 'spaceEvenly': return WrapAlignment.spaceEvenly;
      default: return WrapAlignment.start;
    }
  }
}
