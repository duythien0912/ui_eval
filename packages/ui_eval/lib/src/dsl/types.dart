library;

/// Type-safe DSL types for UI definition

/// Represents a UI component type
enum UIComponentType {
  scaffold,
  appBar,
  text,
  button,
  container,
  row,
  column,
  listView,
  image,
  icon,
  textField,
  card,
  divider,
  expanded,
  sizedBox,
  padding,
  center,
  stack,
  positioned,
  gestureDetector,
  inkWell,
  iconButton,
  floatingActionButton,
  bottomNavigationBar,
  tabBar,
  tabBarView,
  drawer,
  checkbox,
  switch_,
  slider,
  progressIndicator,
  circularProgressIndicator,
  linearProgressIndicator,
  chip,
  wrap,
  gridView,
  singleChildScrollView,
}

/// Represents a button type
enum UIButtonType {
  elevated,
  text,
  outlined,
  filled,
  icon,
}

/// Represents text alignment
enum UITextAlign {
  left,
  right,
  center,
  justify,
  start,
  end,
}

/// Represents font weight
enum UIFontWeight {
  thin,
  extraLight,
  light,
  normal,
  medium,
  semiBold,
  bold,
  extraBold,
  black,
}

/// Represents main axis alignment
enum UIMainAxisAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly,
}

/// Represents cross axis alignment
enum UICrossAxisAlignment {
  start,
  end,
  center,
  stretch,
  baseline,
}

/// Represents axis direction
enum UIAxis {
  horizontal,
  vertical,
}

/// Represents box fit for images
enum UIBoxFit {
  fill,
  contain,
  cover,
  fitWidth,
  fitHeight,
  none,
  scaleDown,
}

/// Represents text input type
enum UITextInputType {
  text,
  number,
  phone,
  email,
  url,
  multiline,
}

/// Extension to convert enum to string
extension UIComponentTypeExtension on UIComponentType {
  String get value => toString().split('.').last;
}
