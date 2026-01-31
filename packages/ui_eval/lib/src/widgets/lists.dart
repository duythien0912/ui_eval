library;

import 'package:flutter/material.dart';
import 'widgets.dart';

class UILists {
  static Widget buildListView(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final itemCountValue = UIWidgets.processRefs(def['itemCount'], state);
    final itemCount = itemCountValue is int ? itemCountValue : 0;
    final itemBuilder = def['itemBuilder'] as Map<String, dynamic>?;
    final shrinkWrap = def['shrinkWrap'] as bool? ?? false;
    final scrollDirection = def['scrollDirection'] as String? ?? 'vertical';

    if (itemBuilder == null) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      scrollDirection: scrollDirection == 'horizontal' ? Axis.horizontal : Axis.vertical,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final itemState = Map<String, dynamic>.from(state);
        itemState['index'] = index;
        return UIWidgets.build(
          type: itemBuilder['type'] as String,
          def: itemBuilder,
          state: itemState,
          onAction: onAction,
          onStateChange: onStateChange,
          getState: (key) => itemState[key],
        );
      },
    );
  }

  static Widget buildListTile(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final onTapAction = def['onTap'] as Map<String, dynamic>?;

    return ListTile(
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
      title: def['title'] != null
          ? UIWidgets.build(
              type: def['title']['type'] as String,
              def: def['title'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
      subtitle: def['subtitle'] != null
          ? UIWidgets.build(
              type: def['subtitle']['type'] as String,
              def: def['subtitle'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
      trailing: def['trailing'] != null
          ? UIWidgets.build(
              type: def['trailing']['type'] as String,
              def: def['trailing'] as Map<String, dynamic>,
              state: state,
              onAction: onAction,
              onStateChange: onStateChange,
              getState: getState,
            )
          : null,
      onTap: onTapAction != null
          ? () {
              final actionName = onTapAction['action'] as String;
              final params = onTapAction['params'] as Map<String, dynamic>?;
              final processedParams = UIWidgets.processActionParams(params, state);
              onAction(actionName, processedParams);
            }
          : null,
    );
  }

  static Widget buildGridView(
    Map<String, dynamic> def,
    Map<String, dynamic> state,
    Function(String, Map<String, dynamic>?) onAction,
    Function(String, dynamic) onStateChange,
    dynamic Function(String) getState,
  ) {
    final itemCountValue = UIWidgets.processRefs(def['itemCount'], state);
    final itemCount = itemCountValue is int ? itemCountValue : 0;
    final itemBuilder = def['itemBuilder'] as Map<String, dynamic>?;
    final crossAxisCount = (def['crossAxisCount'] as num?)?.toInt() ?? 2;
    final shrinkWrap = def['shrinkWrap'] as bool? ?? false;

    if (itemBuilder == null) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: (def['childAspectRatio'] as num?)?.toDouble() ?? 1.0,
        crossAxisSpacing: (def['crossAxisSpacing'] as num?)?.toDouble() ?? 0.0,
        mainAxisSpacing: (def['mainAxisSpacing'] as num?)?.toDouble() ?? 0.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final itemState = Map<String, dynamic>.from(state);
        itemState['index'] = index;
        return UIWidgets.build(
          type: itemBuilder['type'] as String,
          def: itemBuilder,
          state: itemState,
          onAction: onAction,
          onStateChange: onStateChange,
          getState: (key) => itemState[key],
        );
      },
    );
  }
}
