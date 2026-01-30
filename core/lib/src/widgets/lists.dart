import '../types.dart';
import '../ui_widget.dart';

// ==================== List Widgets ====================

/// List view
class UIListView extends UIWidget {
  final List<UIWidget> children;
  final bool shrinkWrap;
  final UIEdgeInsets? padding;
  final UIActionRef? onRefresh;
  
  const UIListView({
    required this.children,
    this.shrinkWrap = false,
    this.padding,
    this.onRefresh,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    'children': children.map((c) => c.toJson()).toList(),
    'shrinkWrap': shrinkWrap,
    if (padding != null) 'padding': padding!.toJson(),
    if (onRefresh != null) 'onRefresh': onRefresh!.toJson(),
  };
}

/// List tile
class UIListTile extends UIWidget {
  final UIWidget? leading;
  final UIWidget? title;
  final UIWidget? subtitle;
  final UIWidget? trailing;
  final UIActionRef? onTap;
  final UIActionRef? onLongPress;
  final UIColor? tileColor;
  
  const UIListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.tileColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': flutterType,
    if (leading != null) 'leading': leading!.toJson(),
    if (title != null) 'title': title!.toJson(),
    if (subtitle != null) 'subtitle': subtitle!.toJson(),
    if (trailing != null) 'trailing': trailing!.toJson(),
    if (onTap != null) 'onTap': onTap!.toJson(),
    if (onLongPress != null) 'onLongPress': onLongPress!.toJson(),
    if (tileColor != null) 'tileColor': tileColor!.toJson(),
  };
}

/// Grid view
class UIGridView extends UIWidget {
  final List<UIWidget> children;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final bool shrinkWrap;
  
  const UIGridView({
    required this.children,
    required this.crossAxisCount,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.shrinkWrap = false,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'GridView',
    'children': children.map((c) => c.toJson()).toList(),
    'crossAxisCount': crossAxisCount,
    if (childAspectRatio != null) 'childAspectRatio': childAspectRatio,
    if (crossAxisSpacing != null) 'crossAxisSpacing': crossAxisSpacing,
    if (mainAxisSpacing != null) 'mainAxisSpacing': mainAxisSpacing,
    'shrinkWrap': shrinkWrap,
  };
}

/// Tab bar
class UITabBar extends UIWidget {
  final List<String> tabs;
  final UIRef currentIndex;
  final UIActionRef? onTap;
  final UIColor? indicatorColor;
  final UIColor? labelColor;
  
  const UITabBar({
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.indicatorColor,
    this.labelColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'TabBar',
    'tabs': tabs,
    'currentIndex': currentIndex.toJson(),
    if (onTap != null) 'onTap': onTap!.toJson(),
    if (indicatorColor != null) 'indicatorColor': indicatorColor!.toJson(),
    if (labelColor != null) 'labelColor': labelColor!.toJson(),
  };
}

/// Bottom navigation bar
class UIBottomNavigationBar extends UIWidget {
  final List<UIBottomNavItem> items;
  final UIRef currentIndex;
  final UIActionRef? onTap;
  final UIColor? selectedItemColor;
  final UIColor? unselectedItemColor;
  
  const UIBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
  });
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'BottomNavigationBar',
    'items': items.map((i) => i.toJson()).toList(),
    'currentIndex': currentIndex.toJson(),
    if (onTap != null) 'onTap': onTap!.toJson(),
    if (selectedItemColor != null) 'selectedItemColor': selectedItemColor!.toJson(),
    if (unselectedItemColor != null) 'unselectedItemColor': unselectedItemColor!.toJson(),
  };
}

/// Bottom nav item
class UIBottomNavItem {
  final UIIconData icon;
  final String label;
  
  const UIBottomNavItem({
    required this.icon,
    required this.label,
  });
  
  Map<String, dynamic> toJson() => {
    'icon': icon.toJson(),
    'label': label,
  };
}
