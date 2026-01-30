import 'package:flutter/material.dart';
import 'dart:convert';

/// Renders UI from JSON definition
class UIRuntimeWidget extends StatefulWidget {
  final Map<String, dynamic> uiJson;
  final Map<String, dynamic> initialState;
  final Map<String, Function> actions;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;
  
  const UIRuntimeWidget({
    super.key,
    required this.uiJson,
    this.initialState = const {},
    this.actions = const {},
    this.loadingWidget,
    this.errorBuilder,
  });
  
  @override
  State<UIRuntimeWidget> createState() => _UIRuntimeWidgetState();
}

class _UIRuntimeWidgetState extends State<UIRuntimeWidget> {
  late Map<String, dynamic> _state;
  
  @override
  void initState() {
    super.initState();
    _state = Map.from(widget.initialState);
  }
  
  @override
  Widget build(BuildContext context) {
    try {
      final root = widget.uiJson['root'] as Map<String, dynamic>;
      return _buildWidget(root);
    } catch (e, stack) {
      debugPrint('UI Runtime Error: $e\n$stack');
      return widget.errorBuilder?.call(e) ?? 
          Center(child: Text('Error: $e'));
    }
  }
  
  Widget _buildWidget(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      // Layout
      case 'Scaffold': return _buildScaffold(json);
      case 'AppBar': return _buildAppBar(json);
      case 'Column': return _buildColumn(json);
      case 'Row': return _buildRow(json);
      case 'Container': return _buildContainer(json);
      case 'Center': return _buildCenter(json);
      case 'Align': return _buildAlign(json);
      case 'Padding': return _buildPadding(json);
      case 'SafeArea': return _buildSafeArea(json);
      case 'Expanded': return _buildExpanded(json);
      case 'SizedBox': return _buildSizedBox(json);
      case 'Stack': return _buildStack(json);
      case 'Positioned': return _buildPositioned(json);
      case 'Divider': return _buildDivider(json);
      
      // Content
      case 'Text': return _buildText(json);
      case 'Icon': return _buildIcon(json);
      case 'Card': return _buildCard(json);
      case 'Chip': return _buildChip(json);
      
      // Input
      case 'ElevatedButton': return _buildButton(json);
      case 'TextButton': return _buildTextButton(json);
      case 'IconButton': return _buildIconButton(json);
      case 'FloatingActionButton': return _buildFAB(json);
      case 'TextField': return _buildTextField(json);
      case 'Checkbox': return _buildCheckbox(json);
      case 'Switch': return _buildSwitch(json);
      case 'Slider': return _buildSlider(json);
      case 'CheckboxListTile': return _buildCheckboxListTile(json);
      
      // Lists
      case 'ListView': return _buildListView(json);
      case 'ListTile': return _buildListTile(json);
      case 'GridView': return _buildGridView(json);
      case 'TabBar': return _buildTabBar(json);
      case 'TabBarView': return _buildTabBarView(json);
      case 'BottomNavigationBar': return _buildBottomNav(json);
      
      default:
        debugPrint('Unknown widget type: $type');
        return const SizedBox.shrink();
    }
  }
  
  // ==================== Layout Builders ====================
  
  Widget _buildScaffold(Map<String, dynamic> json) {
    return Scaffold(
      appBar: json['appBar'] != null ? _buildWidget(json['appBar']) as PreferredSizeWidget? : null,
      body: _buildWidget(json['body']),
      floatingActionButton: json['floatingActionButton'] != null ? _buildWidget(json['floatingActionButton']) : null,
      bottomNavigationBar: json['bottomNavigationBar'] != null ? _buildWidget(json['bottomNavigationBar']) : null,
      drawer: json['drawer'] != null ? _buildWidget(json['drawer']) : null,
      backgroundColor: _parseColor(json['backgroundColor']),
    );
  }
  
  Widget _buildAppBar(Map<String, dynamic> json) {
    return AppBar(
      title: json['title'] != null ? Text(_parseString(json['title'])) : null,
      backgroundColor: _parseColor(json['backgroundColor']),
      foregroundColor: _parseColor(json['foregroundColor']),
      elevation: json['elevation'] as double?,
      actions: json['actions'] != null 
          ? (json['actions'] as List).map((a) => _buildWidget(a as Map<String, dynamic>)).toList()
          : null,
    );
  }
  
  Widget _buildColumn(Map<String, dynamic> json) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.values[json['mainAxisAlignment'] ?? 0],
      crossAxisAlignment: CrossAxisAlignment.values[json['crossAxisAlignment'] ?? 2],
      mainAxisSize: MainAxisSize.values[json['mainAxisSize'] ?? 1],
      children: (json['children'] as List).map((c) => _buildWidget(c as Map<String, dynamic>)).toList(),
    );
  }
  
  Widget _buildRow(Map<String, dynamic> json) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.values[json['mainAxisAlignment'] ?? 0],
      crossAxisAlignment: CrossAxisAlignment.values[json['crossAxisAlignment'] ?? 2],
      mainAxisSize: MainAxisSize.values[json['mainAxisSize'] ?? 1],
      children: (json['children'] as List).map((c) => _buildWidget(c as Map<String, dynamic>)).toList(),
    );
  }
  
  Widget _buildContainer(Map<String, dynamic> json) {
    return Container(
      width: json['width'] as double?,
      height: json['height'] as double?,
      color: _parseColor(json['color']),
      padding: _parseEdgeInsets(json['padding']),
      margin: _parseEdgeInsets(json['margin']),
      alignment: _parseAlignment(json['alignment']),
      child: json['child'] != null ? _buildWidget(json['child']) : null,
    );
  }
  
  Widget _buildCenter(Map<String, dynamic> json) {
    return Center(
      widthFactor: json['widthFactor'] as double?,
      heightFactor: json['heightFactor'] as double?,
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildAlign(Map<String, dynamic> json) {
    final alignment = json['alignment'] as Map<String, dynamic>?;
    return Align(
      alignment: alignment != null 
          ? Alignment(alignment['x'] as double, alignment['y'] as double)
          : Alignment.center,
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildPadding(Map<String, dynamic> json) {
    return Padding(
      padding: _parseEdgeInsets(json['padding']) ?? EdgeInsets.zero,
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildSafeArea(Map<String, dynamic> json) {
    return SafeArea(child: _buildWidget(json['child']));
  }
  
  Widget _buildExpanded(Map<String, dynamic> json) {
    return Expanded(
      flex: json['flex'] as int? ?? 1,
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildSizedBox(Map<String, dynamic> json) {
    return SizedBox(
      width: json['width'] as double?,
      height: json['height'] as double?,
      child: json['child'] != null ? _buildWidget(json['child']) : null,
    );
  }
  
  Widget _buildStack(Map<String, dynamic> json) {
    final alignment = json['alignment'] as Map<String, dynamic>?;
    return Stack(
      alignment: alignment != null 
          ? Alignment(alignment['x'] as double, alignment['y'] as double)
          : AlignmentDirectional.topStart,
      children: (json['children'] as List).map((c) => _buildWidget(c as Map<String, dynamic>)).toList(),
    );
  }
  
  Widget _buildPositioned(Map<String, dynamic> json) {
    return Positioned(
      left: json['left'] as double?,
      top: json['top'] as double?,
      right: json['right'] as double?,
      bottom: json['bottom'] as double?,
      width: json['width'] as double?,
      height: json['height'] as double?,
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildDivider(Map<String, dynamic> json) {
    return Divider(
      height: json['height'] as double?,
      thickness: json['thickness'] as double?,
      color: _parseColor(json['color']),
      indent: json['indent'] as double?,
      endIndent: json['endIndent'] as double?,
    );
  }
  
  // ==================== Content Builders ====================
  
  Widget _buildText(Map<String, dynamic> json) {
    String data = _parseString(json['data']);
    // Process state references
    data = _processRefs(data);
    
    return Text(
      data,
      style: TextStyle(
        fontSize: json['fontSize'] as double?,
        color: _parseColor(json['color']),
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
  
  Widget _buildIcon(Map<String, dynamic> json) {
    final iconData = json['icon'] as Map<String, dynamic>;
    return Icon(
      IconData(
        iconData['codePoint'] as int,
        fontFamily: iconData['fontFamily'] as String?,
        fontPackage: iconData['fontPackage'] as String?,
      ),
      size: json['size'] as double?,
      color: _parseColor(json['color']),
    );
  }
  
  Widget _buildCard(Map<String, dynamic> json) {
    return Card(
      elevation: json['elevation'] as double?,
      color: _parseColor(json['color']),
      margin: _parseEdgeInsets(json['margin']),
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildChip(Map<String, dynamic> json) {
    return Chip(
      label: _buildWidget(json['label']),
      avatar: json['avatar'] != null ? _buildIcon({'type': 'Icon', 'icon': json['avatar']}) : null,
      deleteIcon: json['deleteIcon'] != null ? _buildIcon({'type': 'Icon', 'icon': json['deleteIcon']}) : null,
      onDeleted: json['onDeleted'] != null ? () => _invokeAction(json['onDeleted']) : null,
      backgroundColor: _parseColor(json['backgroundColor']),
    );
  }
  
  // ==================== Input Builders ====================
  
  Widget _buildButton(Map<String, dynamic> json) {
    return ElevatedButton(
      onPressed: json['onPressed'] != null ? () => _invokeAction(json['onPressed']) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _parseColor(json['backgroundColor']),
        foregroundColor: _parseColor(json['foregroundColor']),
        elevation: json['elevation'] as double?,
        padding: _parseEdgeInsets(json['padding']),
      ),
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildTextButton(Map<String, dynamic> json) {
    return TextButton(
      onPressed: json['onPressed'] != null ? () => _invokeAction(json['onPressed']) : null,
      style: TextButton.styleFrom(foregroundColor: _parseColor(json['foregroundColor'])),
      child: _buildWidget(json['child']),
    );
  }
  
  Widget _buildIconButton(Map<String, dynamic> json) {
    final iconData = json['icon'] as Map<String, dynamic>;
    return IconButton(
      icon: Icon(IconData(iconData['codePoint'] as int)),
      onPressed: json['onPressed'] != null ? () => _invokeAction(json['onPressed']) : null,
      color: _parseColor(json['color']),
      iconSize: json['iconSize'] as double?,
      tooltip: json['tooltip'] as String?,
    );
  }
  
  Widget _buildFAB(Map<String, dynamic> json) {
    return FloatingActionButton(
      onPressed: () => _invokeAction(json['onPressed']),
      mini: json['mini'] as bool? ?? false,
      backgroundColor: _parseColor(json['backgroundColor']),
      foregroundColor: _parseColor(json['foregroundColor']),
      elevation: json['elevation'] as double?,
      tooltip: json['tooltip'] as String?,
      child: json['icon'] != null 
          ? _buildIcon({'type': 'Icon', 'icon': json['icon']})
          : (json['child'] != null ? _buildWidget(json['child']) : null),
    );
  }
  
  Widget _buildTextField(Map<String, dynamic> json) {
    return TextField(
      decoration: InputDecoration(
        hintText: json['hint'] as String?,
        labelText: json['label'] as String?,
        prefixIcon: json['prefixIcon'] != null ? _buildIcon({'type': 'Icon', 'icon': json['prefixIcon']}) : null,
        suffixIcon: json['suffixIcon'] != null ? _buildIcon({'type': 'Icon', 'icon': json['suffixIcon']}) : null,
      ),
      obscureText: json['obscureText'] as bool? ?? false,
      maxLines: json['maxLines'] as int? ?? 1,
      maxLength: json['maxLength'] as int?,
      onChanged: json['onChanged'] != null 
          ? (value) => _invokeAction(json['onChanged'], {'value': value})
          : null,
      onSubmitted: json['onSubmitted'] != null 
          ? (value) => _invokeAction(json['onSubmitted'], {'value': value})
          : null,
    );
  }
  
  Widget _buildCheckbox(Map<String, dynamic> json) {
    final valueRef = json['value'] as Map<String, dynamic>;
    final key = valueRef['_ref'] as String;
    final value = _getStateValue(key) as bool? ?? false;
    
    return Checkbox(
      value: value,
      onChanged: json['onChanged'] != null ? (v) {
        _setStateValue(key, v);
        _invokeAction(json['onChanged'], {'value': v});
      } : null,
      activeColor: _parseColor(json['activeColor']),
      checkColor: _parseColor(json['checkColor']),
    );
  }
  
  Widget _buildSwitch(Map<String, dynamic> json) {
    final valueRef = json['value'] as Map<String, dynamic>;
    final key = valueRef['_ref'] as String;
    final value = _getStateValue(key) as bool? ?? false;
    
    return Switch(
      value: value,
      onChanged: json['onChanged'] != null ? (v) {
        _setStateValue(key, v);
        _invokeAction(json['onChanged'], {'value': v});
      } : null,
      activeColor: _parseColor(json['activeColor']),
    );
  }
  
  Widget _buildSlider(Map<String, dynamic> json) {
    final valueRef = json['value'] as Map<String, dynamic>;
    final key = valueRef['_ref'] as String;
    final value = (_getStateValue(key) as num?)?.toDouble() ?? 0.0;
    
    return Slider(
      value: value,
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 1.0,
      onChanged: json['onChanged'] != null ? (v) {
        _setStateValue(key, v);
        _invokeAction(json['onChanged'], {'value': v});
      } : null,
      activeColor: _parseColor(json['activeColor']),
    );
  }
  
  Widget _buildCheckboxListTile(Map<String, dynamic> json) {
    final valueRef = json['value'] as Map<String, dynamic>;
    final key = valueRef['_ref'] as String;
    final value = _getStateValue(key) as bool? ?? false;
    
    return CheckboxListTile(
      value: value,
      onChanged: json['onChanged'] != null ? (v) {
        _setStateValue(key, v);
        _invokeAction(json['onChanged'], {'value': v});
      } : null,
      title: _buildWidget(json['title']),
      subtitle: json['subtitle'] != null ? _buildWidget(json['subtitle']) : null,
      activeColor: _parseColor(json['activeColor']),
    );
  }
  
  // ==================== List Builders ====================
  
  Widget _buildListView(Map<String, dynamic> json) {
    return ListView(
      shrinkWrap: json['shrinkWrap'] as bool? ?? false,
      padding: _parseEdgeInsets(json['padding']),
      children: (json['children'] as List).map((c) => _buildWidget(c as Map<String, dynamic>)).toList(),
    );
  }
  
  Widget _buildListTile(Map<String, dynamic> json) {
    return ListTile(
      leading: json['leading'] != null ? _buildWidget(json['leading']) : null,
      title: json['title'] != null ? _buildWidget(json['title']) : null,
      subtitle: json['subtitle'] != null ? _buildWidget(json['subtitle']) : null,
      trailing: json['trailing'] != null ? _buildWidget(json['trailing']) : null,
      onTap: json['onTap'] != null ? () => _invokeAction(json['onTap']) : null,
      onLongPress: json['onLongPress'] != null ? () => _invokeAction(json['onLongPress']) : null,
      tileColor: _parseColor(json['tileColor']),
      selected: json['selected'] as bool? ?? false,
      dense: json['dense'] as bool? ?? false,
    );
  }
  
  Widget _buildGridView(Map<String, dynamic> json) {
    return GridView.count(
      crossAxisCount: json['crossAxisCount'] as int,
      childAspectRatio: (json['childAspectRatio'] as num?)?.toDouble() ?? 1.0,
      crossAxisSpacing: (json['crossAxisSpacing'] as num?)?.toDouble() ?? 0.0,
      mainAxisSpacing: (json['mainAxisSpacing'] as num?)?.toDouble() ?? 0.0,
      shrinkWrap: json['shrinkWrap'] as bool? ?? false,
      children: (json['children'] as List).map((c) => _buildWidget(c as Map<String, dynamic>)).toList(),
    );
  }
  
  Widget _buildTabBar(Map<String, dynamic> json) {
    return TabBar(
      tabs: (json['tabs'] as List).map((t) => Tab(text: t as String)).toList(),
      onTap: json['onTap'] != null ? (i) => _invokeAction(json['onTap'], {'index': i}) : null,
      indicatorColor: _parseColor(json['indicatorColor']),
      labelColor: _parseColor(json['labelColor']),
      unselectedLabelColor: _parseColor(json['unselectedLabelColor']),
    );
  }
  
  Widget _buildTabBarView(Map<String, dynamic> json) {
    return TabBarView(
      children: (json['children'] as List).map((c) => _buildWidget(c as Map<String, dynamic>)).toList(),
    );
  }
  
  Widget _buildBottomNav(Map<String, dynamic> json) {
    final currentIndexRef = json['currentIndex'] as Map<String, dynamic>;
    final key = currentIndexRef['_ref'] as String;
    final currentIndex = (_getStateValue(key) as num?)?.toInt() ?? 0;
    
    final items = (json['items'] as List).map((i) {
      final item = i as Map<String, dynamic>;
      final icon = item['icon'] as Map<String, dynamic>;
      return BottomNavigationBarItem(
        icon: Icon(IconData(icon['codePoint'] as int)),
        label: item['label'] as String,
      );
    }).toList();
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: json['onTap'] != null ? (i) {
        _setStateValue(key, i);
        _invokeAction(json['onTap'], {'index': i});
      } : null,
      items: items,
      selectedItemColor: _parseColor(json['selectedItemColor']),
      unselectedItemColor: _parseColor(json['unselectedItemColor']),
      elevation: json['elevation'] as double?,
    );
  }
  
  // ==================== Helpers ====================
  
  Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return Color(value['_color'] as int);
    }
    if (value is int) return Color(value);
    return null;
  }
  
  EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    final map = value as Map<String, dynamic>;
    return EdgeInsets.fromLTRB(
      (map['left'] as num).toDouble(),
      (map['top'] as num).toDouble(),
      (map['right'] as num).toDouble(),
      (map['bottom'] as num).toDouble(),
    );
  }
  
  Alignment? _parseAlignment(dynamic value) {
    if (value == null) return null;
    final map = value as Map<String, dynamic>;
    return Alignment(
      (map['x'] as num).toDouble(),
      (map['y'] as num).toDouble(),
    );
  }
  
  String _parseString(dynamic value) {
    if (value is String) return value;
    return value.toString();
  }
  
  String _processRefs(String data) {
    final regex = RegExp(r'\{\{(\w+(?:\.\w+)*)\}\}');
    return data.replaceAllMapped(regex, (match) {
      final key = match.group(1)!;
      return _getStateValue(key)?.toString() ?? '';
    });
  }
  
  dynamic _getStateValue(String key) {
    final parts = key.split('.');
    dynamic value = _state;
    for (final part in parts) {
      if (value is Map) {
        value = value[part];
      } else if (value is List) {
        final idx = int.tryParse(part);
        if (idx != null && idx >= 0 && idx < value.length) {
          value = value[idx];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return value;
  }
  
  void _setStateValue(String key, dynamic value) {
    setState(() {
      final parts = key.split('.');
      if (parts.length == 1) {
        _state[key] = value;
      } else {
        // Handle nested keys
        dynamic current = _state;
        for (var i = 0; i < parts.length - 1; i++) {
          final part = parts[i];
          if (current[part] == null) {
            current[part] = <String, dynamic>{};
          }
          current = current[part];
        }
        current[parts.last] = value;
      }
    });
  }
  
  void _invokeAction(dynamic actionRef, [Map<String, dynamic>? params]) {
    if (actionRef == null) return;
    
    final ref = actionRef as Map<String, dynamic>;
    final name = ref['_action'] as String;
    final args = ref['_args'] as Map<String, dynamic>?;
    
    final handler = widget.actions[name];
    if (handler != null) {
      final mergedParams = <String, dynamic>{};
      if (args != null) mergedParams.addAll(args);
      if (params != null) mergedParams.addAll(params);
      handler(mergedParams);
    }
  }
}
