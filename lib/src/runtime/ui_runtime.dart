import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import '../core/ui_widget.dart';
import '../core/ui_state.dart';
import '../core/ui_action.dart';
import 'hot_update_manager.dart';

/// Runtime engine for executing compiled UI
class UIRuntime {
  final Runtime _runtime = Runtime();
  final Map<String, dynamic> _stateValues = {};
  final Map<String, Function> _actionHandlers = {};
  
  /// Load and execute EVC bytecode
  Future<Widget> loadEvc(List<int> bytes, {String entryPoint = 'main'}) async {
    final program = Program.read(bytes);
    _runtime.loadProgram(program);
    
    // Execute and get widget
    final result = _runtime.executeLib(
      'package:$entryPoint/main.dart',
      'main',
    );
    
    return result as Widget;
  }
  
  /// Load and render JSON-based UI
  Widget loadJson(Map<String, dynamic> json, {
    required BuildContext context,
    Map<String, dynamic> initialState = const {},
    Map<String, Function> actions = const {},
  }) {
    // Initialize state
    _stateValues.clear();
    _stateValues.addAll(initialState);
    
    // Register actions
    _actionHandlers.clear();
    _actionHandlers.addAll(actions);
    
    // Parse and build widget tree
    final root = json['root'] as Map<String, dynamic>;
    return _buildWidget(root, context);
  }
  
  /// Build Flutter widget from JSON representation
  Widget _buildWidget(Map<String, dynamic> json, BuildContext context) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'Scaffold':
        return _buildScaffold(json, context);
      case 'AppBar':
        return _buildAppBar(json, context);
      case 'Column':
        return _buildColumn(json, context);
      case 'Row':
        return _buildRow(json, context);
      case 'Container':
        return _buildContainer(json, context);
      case 'Center':
        return _buildCenter(json, context);
      case 'Text':
        return _buildText(json, context);
      case 'ElevatedButton':
        return _buildButton(json, context);
      case 'TextButton':
        return _buildTextButton(json, context);
      case 'ListView':
        return _buildListView(json, context);
      case 'ListTile':
        return _buildListTile(json, context);
      case 'Card':
        return _buildCard(json, context);
      case 'TextField':
        return _buildTextField(json, context);
      case 'Checkbox':
        return _buildCheckbox(json, context);
      case 'FloatingActionButton':
        return _buildFAB(json, context);
      case 'SafeArea':
        return _buildSafeArea(json, context);
      case 'Padding':
        return _buildPadding(json, context);
      case 'Expanded':
        return _buildExpanded(json, context);
      case 'SizedBox':
        return _buildSizedBox(json, context);
      case 'Divider':
        return _buildDivider(json, context);
      case 'Icon':
        return _buildIcon(json, context);
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildScaffold(Map<String, dynamic> json, BuildContext context) {
    return Scaffold(
      appBar: json['appBar'] != null
          ? _buildWidget(json['appBar'] as Map<String, dynamic>, context) as PreferredSizeWidget?
          : null,
      body: _buildWidget(json['body'] as Map<String, dynamic>, context),
      floatingActionButton: json['floatingActionButton'] != null
          ? _buildWidget(json['floatingActionButton'] as Map<String, dynamic>, context)
          : null,
      bottomNavigationBar: json['bottomNavigationBar'] != null
          ? _buildWidget(json['bottomNavigationBar'] as Map<String, dynamic>, context)
          : null,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'] as int)
          : null,
    );
  }
  
  Widget _buildAppBar(Map<String, dynamic> json, BuildContext context) {
    return AppBar(
      title: json['title'] != null ? Text(json['title'] as String) : null,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'] as int)
          : null,
      foregroundColor: json['foregroundColor'] != null
          ? Color(json['foregroundColor'] as int)
          : null,
      elevation: json['elevation'] as double?,
    );
  }
  
  Widget _buildColumn(Map<String, dynamic> json, BuildContext context) {
    final children = (json['children'] as List<dynamic>)
        .map((c) => _buildWidget(c as Map<String, dynamic>, context))
        .toList();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.values[json['mainAxisAlignment'] as int? ?? 0],
      crossAxisAlignment: CrossAxisAlignment.values[json['crossAxisAlignment'] as int? ?? 2],
      mainAxisSize: MainAxisSize.values[json['mainAxisSize'] as int? ?? 1],
      children: children,
    );
  }
  
  Widget _buildRow(Map<String, dynamic> json, BuildContext context) {
    final children = (json['children'] as List<dynamic>)
        .map((c) => _buildWidget(c as Map<String, dynamic>, context))
        .toList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.values[json['mainAxisAlignment'] as int? ?? 0],
      crossAxisAlignment: CrossAxisAlignment.values[json['crossAxisAlignment'] as int? ?? 2],
      mainAxisSize: MainAxisSize.values[json['mainAxisSize'] as int? ?? 1],
      children: children,
    );
  }
  
  Widget _buildContainer(Map<String, dynamic> json, BuildContext context) {
    return Container(
      width: json['width'] as double?,
      height: json['height'] as double?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      padding: json['padding'] != null
          ? EdgeInsets.all((json['padding'] as Map<String, dynamic>)['left'] as double)
          : null,
      margin: json['margin'] != null
          ? EdgeInsets.all((json['margin'] as Map<String, dynamic>)['left'] as double)
          : null,
      child: json['child'] != null
          ? _buildWidget(json['child'] as Map<String, dynamic>, context)
          : null,
    );
  }
  
  Widget _buildCenter(Map<String, dynamic> json, BuildContext context) {
    return Center(
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildText(Map<String, dynamic> json, BuildContext context) {
    String data = json['data'] as String;
    
    // Process state references
    data = _processStateReferences(data);
    
    return Text(
      data,
      style: TextStyle(
        fontSize: json['fontSize'] as double?,
        color: json['color'] != null ? Color(json['color'] as int) : null,
        fontWeight: json['fontWeight'] != null
            ? FontWeight.values[json['fontWeight'] as int]
            : null,
      ),
      textAlign: json['textAlign'] != null
          ? TextAlign.values[json['textAlign'] as int]
          : null,
      maxLines: json['maxLines'] as int?,
    );
  }
  
  Widget _buildButton(Map<String, dynamic> json, BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleAction(json['onPressed'] as String?),
      style: ElevatedButton.styleFrom(
        backgroundColor: json['backgroundColor'] != null
            ? Color(json['backgroundColor'] as int)
            : null,
        elevation: json['elevation'] as double?,
      ),
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildTextButton(Map<String, dynamic> json, BuildContext context) {
    return TextButton(
      onPressed: () => _handleAction(json['onPressed'] as String?),
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildListView(Map<String, dynamic> json, BuildContext context) {
    final children = (json['children'] as List<dynamic>)
        .map((c) => _buildWidget(c as Map<String, dynamic>, context))
        .toList();
    
    return ListView(
      shrinkWrap: json['shrinkWrap'] as bool? ?? false,
      physics: json['physics'] != null
          ? const NeverScrollableScrollPhysics()
          : null,
      children: children,
    );
  }
  
  Widget _buildListTile(Map<String, dynamic> json, BuildContext context) {
    return ListTile(
      leading: json['leading'] != null
          ? _buildWidget(json['leading'] as Map<String, dynamic>, context)
          : null,
      title: json['title'] != null
          ? _buildWidget(json['title'] as Map<String, dynamic>, context)
          : null,
      subtitle: json['subtitle'] != null
          ? _buildWidget(json['subtitle'] as Map<String, dynamic>, context)
          : null,
      trailing: json['trailing'] != null
          ? _buildWidget(json['trailing'] as Map<String, dynamic>, context)
          : null,
      onTap: () => _handleAction(json['onTap'] as String?),
      tileColor: json['tileColor'] != null
          ? Color(json['tileColor'] as int)
          : null,
    );
  }
  
  Widget _buildCard(Map<String, dynamic> json, BuildContext context) {
    return Card(
      elevation: json['elevation'] as double?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      margin: json['margin'] != null
          ? EdgeInsets.all((json['margin'] as Map<String, dynamic>)['left'] as double)
          : null,
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildTextField(Map<String, dynamic> json, BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: json['hint'] as String?,
        labelText: json['label'] as String?,
      ),
      obscureText: json['obscureText'] as bool? ?? false,
      maxLines: json['maxLines'] as int? ?? 1,
      onChanged: (value) => _handleAction(json['onChanged'] as String?, params: {'value': value}),
      onSubmitted: (value) => _handleAction(json['onSubmitted'] as String?, params: {'value': value}),
    );
  }
  
  Widget _buildCheckbox(Map<String, dynamic> json, BuildContext context) {
    final valueRef = json['value'] as String;
    final key = valueRef.replaceAll('{{', '').replaceAll('}}', '');
    final value = _stateValues[key] as bool? ?? false;
    
    return Checkbox(
      value: value,
      onChanged: (newValue) {
        _stateValues[key] = newValue;
        _handleAction(json['onChanged'] as String?, params: {'value': newValue});
      },
      activeColor: json['activeColor'] != null
          ? Color(json['activeColor'] as int)
          : null,
    );
  }
  
  Widget _buildFAB(Map<String, dynamic> json, BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleAction(json['onPressed'] as String?),
      mini: json['mini'] as bool? ?? false,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'] as int)
          : null,
      foregroundColor: json['foregroundColor'] != null
          ? Color(json['foregroundColor'] as int)
          : null,
      elevation: json['elevation'] as double?,
      tooltip: json['tooltip'] as String?,
      child: json['icon'] != null
          ? const Icon(Icons.add)  // Simplified - would map icon code points
          : (json['child'] != null
              ? _buildWidget(json['child'] as Map<String, dynamic>, context)
              : null),
    );
  }
  
  Widget _buildSafeArea(Map<String, dynamic> json, BuildContext context) {
    return SafeArea(
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildPadding(Map<String, dynamic> json, BuildContext context) {
    final padding = json['padding'] as Map<String, dynamic>;
    return Padding(
      padding: EdgeInsets.all(padding['left'] as double),
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildExpanded(Map<String, dynamic> json, BuildContext context) {
    return Expanded(
      flex: json['flex'] as int? ?? 1,
      child: _buildWidget(json['child'] as Map<String, dynamic>, context),
    );
  }
  
  Widget _buildSizedBox(Map<String, dynamic> json, BuildContext context) {
    return SizedBox(
      width: json['width'] as double?,
      height: json['height'] as double?,
      child: json['child'] != null
          ? _buildWidget(json['child'] as Map<String, dynamic>, context)
          : null,
    );
  }
  
  Widget _buildDivider(Map<String, dynamic> json, BuildContext context) {
    return Divider(
      height: json['height'] as double?,
      thickness: json['thickness'] as double?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      indent: json['indent'] as double?,
      endIndent: json['endIndent'] as double?,
    );
  }
  
  Widget _buildIcon(Map<String, dynamic> json, BuildContext context) {
    return Icon(
      IconData(
        json['icon'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      size: json['size'] as double?,
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }
  
  String _processStateReferences(String data) {
    // Replace {{key}} with actual state values
    final regex = RegExp(r'\{\{(\w+)\}\}');
    return data.replaceAllMapped(regex, (match) {
      final key = match.group(1)!;
      return _stateValues[key]?.toString() ?? '';
    });
  }
  
  void _handleAction(String? actionRef, {Map<String, dynamic> params = const {}}) {
    if (actionRef == null) return;
    
    // Parse action reference (@actionName)
    final actionName = actionRef.startsWith('@')
        ? actionRef.substring(1)
        : actionRef;
    
    final handler = _actionHandlers[actionName];
    if (handler != null) {
      handler(params);
    }
  }
  
  void dispose() {
    _runtime.dispose();
  }
}
