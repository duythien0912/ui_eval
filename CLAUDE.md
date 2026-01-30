# ui_eval - Complete Plugin Knowledge

## Overview

ui_eval is a type-safe UI DSL (Domain Specific Language) for Flutter that enables:
- **Type-safe UI development** without writing Dart code as strings
- **Server-driven UI updates** (hot push) without app store releases
- **Clean separation** between UI development and Flutter runtime

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        DEVELOPMENT PHASE                         │
│                                                                  │
│  ┌──────────────┐          ┌──────────────┐                     │
│  │   mini_app   │  ──────► │  JSON Output │                     │
│  │  (ui_eval)   │  build   │  (deployed)  │                     │
│  └──────────────┘          └──────────────┘                     │
│       Pure Dart                Server/Assets                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      RUNTIME (Flutter)                           │
│                                                                  │
│  ┌──────────────┐          ┌──────────────┐                     │
│  │   host_app   │ ◄─────── │ ui_eval_runtime │                  │
│  │   (Flutter)  │  render  │  (JSON→Widgets) │                  │
│  └──────────────┘          └──────────────┘                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
ui_eval/
├── core/                          # Pure Dart DSL (NO Flutter deps)
│   ├── lib/
│   │   ├── ui_eval.dart           # Main export
│   │   └── src/
│   │       ├── types.dart         # Core types (UIRef, UIState, etc.)
│   │       ├── ui_widget.dart     # UIWidget base class
│   │       ├── ui_state.dart      # State management helpers
│   │       ├── ui_action.dart     # Action helpers
│   │       └── widgets/
│   │           ├── layout.dart    # Layout widgets
│   │           ├── content.dart   # Content widgets
│   │           ├── input.dart     # Input widgets
│   │           └── lists.dart     # List widgets
│   └── pubspec.yaml
│
├── flutter_runtime/               # Flutter rendering runtime
│   ├── lib/
│   │   ├── ui_eval_runtime.dart   # Main export
│   │   └── src/
│   │       └── runtime_widget.dart # UIRuntimeWidget
│   └── pubspec.yaml
│
└── example/
    ├── mini_app/                  # Example: Type-safe development
    │   ├── lib/todo_app.dart
    │   ├── build.dart
    │   └── pubspec.yaml
    │
    └── host_app/                  # Example: Flutter host
        ├── lib/main.dart
        ├── assets/apps/
        │   ├── todo_app.json
        │   ├── counter_app.json
        │   └── profile_app.json
        └── pubspec.yaml
```

## Core Concepts

### 1. UIWidget (Base Class)

All UI elements extend `UIWidget`. It provides:
- `toJson()` - Serialize to JSON for runtime
- `type` - Widget type identifier
- `flutterType` - Mapped Flutter widget name

```dart
abstract class UIWidget {
  Map<String, dynamic> toJson();
  String get type;
  String get flutterType;
}
```

### 2. State Management (UIState<T>)

Type-safe reactive state:

```dart
// Define state
final counter = UIState<int>(key: 'count', defaultValue: 0);
final todos = UIState<List<Map>>(key: 'todos', defaultValue: []);
final user = UIState<Map>(key: 'user', defaultValue: {});

// Reference in UI
UIText.state(counter)                              // {{count}}
UIText.ref(counter.prop('name'))                   // {{count.name}}
UIText.ref(todos.index(0).prop('title'))          // {{todos.0.title}}
```

### 3. Actions (UIAction)

Event handlers with typed parameters:

```dart
// Define action
final addTodo = UIAction(
  name: 'addTodo',
  params: [
    UIActionParam(name: 'title', type: 'String', required: true),
  ],
);

// Use in UI
UIButton(
  onPressed: addTodo(args: {'title': 'New task'}),
  child: UIText('Add'),
)

// Handle in host
UIRuntimeWidget(
  actions: {
    'addTodo': (params) {
      final title = params['title'] as String;
      // Handle action
    },
  },
)
```

### 4. UIProgram

Root container for a complete UI:

```dart
UIProgram(
  name: 'TodoApp',
  version: '1.0.0',
  metadata: {
    'title': 'Todo App',
    'description': 'A simple todo list',
  },
  states: [todos, counter],
  actions: [addTodo, deleteTodo],
  root: UIScaffold(...),  // Root widget
)
```

## Available Widgets

### Layout Widgets

| Widget | Description | Key Properties |
|--------|-------------|----------------|
| `UIScaffold` | App structure | appBar, body, floatingActionButton |
| `UIAppBar` | Top navigation | title, actions, backgroundColor |
| `UIColumn` | Vertical layout | children, mainAxisAlignment |
| `UIRow` | Horizontal layout | children, mainAxisAlignment |
| `UIContainer` | Box container | color, padding, margin, width, height |
| `UICenter` | Center alignment | child, widthFactor, heightFactor |
| `UIAlign` | Custom alignment | child, alignment |
| `UIPadding` | Add padding | child, padding |
| `UIExpanded` | Fill available space | child, flex |
| `UISizedBox` | Fixed size box | width, height, child |
| `UIStack` | Overlapping children | children, alignment |
| `UIPositioned` | Position in Stack | child, left, top, right, bottom |
| `UISafeArea` | Avoid system UI | child |
| `UIDivider` | Horizontal line | height, thickness, color |

### Content Widgets

| Widget | Description | Key Properties |
|--------|-------------|----------------|
| `UIText` | Display text | data, fontSize, color, fontWeight |
| `UIIcon` | Display icon | icon, size, color |
| `UICard` | Material card | child, elevation, color, margin |
| `UIChip` | Tag/label | label, avatar, onDeleted |

### Input Widgets

| Widget | Description | Key Properties |
|--------|-------------|----------------|
| `UIButton` | Elevated button | onPressed, child, backgroundColor |
| `UITextButton` | Text button | onPressed, child, foregroundColor |
| `UIIconButton` | Icon button | icon, onPressed, color |
| `UIFloatingActionButton` | FAB | onPressed, icon/child, backgroundColor |
| `UITextField` | Text input | hint, label, onChanged, onSubmitted |
| `UICheckbox` | Checkbox | value, onChanged, activeColor |
| `UISwitch` | Toggle switch | value, onChanged, activeColor |
| `UIRadio` | Radio button | value, groupValue, onChanged |

### List Widgets

| Widget | Description | Key Properties |
|--------|-------------|----------------|
| `UIListView` | Scrollable list | children, shrinkWrap, padding |
| `UIListTile` | List item | leading, title, subtitle, trailing, onTap |
| `UIGridView` | Grid layout | children, crossAxisCount |
| `UITabBar` | Tab navigation | tabs, currentIndex, onTap |
| `UIBottomNavigationBar` | Bottom nav | items, currentIndex, onTap |

## Type-Safe Development (mini_app)

### 1. Create UI Definition

```dart
// mini_app/lib/my_app.dart
import 'package:ui_eval/ui_eval.dart';

class MyApp {
  UIProgram build() {
    // Define states
    final counter = UIState<int>(key: 'count', defaultValue: 0);
    
    // Define actions
    final increment = UIAction(name: 'increment');
    
    // Build UI
    return UIProgram(
      name: 'CounterApp',
      version: '1.0.0',
      states: [counter],
      actions: [increment],
      root: UIScaffold(
        appBar: UIAppBar(title: 'Counter'),
        body: UICenter(
          child: UIColumn(
            mainAxisSize: UIMainAxisSize.min,
            children: [
              UIText.state(counter, fontSize: 48),
              UIButton(
                onPressed: increment(),
                child: UIText('Increment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  final app = MyApp().build();
  print(jsonEncode(app.toJson()));
}
```

### 2. Build to JSON

```dart
// mini_app/build.dart
import 'dart:convert';
import 'dart:io';
import 'lib/my_app.dart';

void main() {
  final app = MyApp();
  final program = app.build();
  
  final outputFile = File('../host_app/assets/apps/my_app.json');
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(program.toJson())
  );
  
  print('✅ Built: ${outputFile.path}');
}
```

Run build:
```bash
cd mini_app
dart build.dart
```

## Flutter Runtime (host_app)

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ui_eval_runtime/ui_eval_runtime.dart';
import 'dart:convert';

class MiniAppPage extends StatefulWidget {
  @override
  State<MiniAppPage> createState() => _MiniAppPageState();
}

class _MiniAppPageState extends State<MiniAppPage> {
  Map<String, dynamic>? uiJson;
  Map<String, dynamic> state = {'count': 0};
  
  @override
  void initState() {
    super.initState();
    loadApp();
  }
  
  Future<void> loadApp() async {
    final jsonString = await rootBundle.loadString('assets/apps/my_app.json');
    setState(() {
      uiJson = jsonDecode(jsonString);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (uiJson == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return UIRuntimeWidget(
      uiJson: uiJson!,
      initialState: state,
      actions: {
        'increment': (_) => setState(() => state['count']++),
      },
    );
  }
}
```

### State References in JSON

The runtime processes state references in strings:

```json
{"type": "Text", "data": "{{count}}"}
{"type": "Text", "data": "{{user.name}}"}
{"type": "Text", "data": "{{todos.0.title}}"}
```

### Action References in JSON

```json
{"onPressed": {"_action": "increment"}}
{"onPressed": {"_action": "addTodo", "_args": {"title": "New"}}}
```

## Hot Updates

### Server Setup

```dart
// server/update_server.dart
import 'dart:io';

class UpdateServer {
  Future<void> start() async {
    final server = await HttpServer.bind('localhost', 8080);
    print('Update server on http://localhost:8080');
    
    await for (final request in server) {
      handleRequest(request);
    }
  }
  
  void handleRequest(HttpRequest request) {
    if (request.uri.path == '/api/update') {
      // Return update info
      request.response
        ..write(jsonEncode({
          'version': '1.1.0',
          'hasUpdate': true,
          'downloadUrl': '/updates/1.1.0.json',
        }))
        ..close();
    }
  }
}
```

### Client with Hot Update

```dart
UIEvalWidget(
  json: initialJson,
  updateUrl: 'http://localhost:8080',
  version: '1.0.0',
  updateInterval: Duration(seconds: 30),
)
```

## Core Types Reference

### UIColor

```dart
// Predefined colors
UIColor.red, UIColor.blue, UIColor.teal, UIColor.white, UIColor.black

// Custom color
UIColor(0xFF2196F3)  // Material Blue
```

### UIEdgeInsets

```dart
UIEdgeInsets.all(16)                           // All sides
UIEdgeInsets.symmetric(horizontal: 16, vertical: 8)
UIEdgeInsets.only(left: 8, top: 16)
```

### UIAlignment

```dart
UIAlignment.topLeft, UIAlignment.topCenter, UIAlignment.topRight
UIAlignment.centerLeft, UIAlignment.center, UIAlignment.centerRight
UIAlignment.bottomLeft, UIAlignment.bottomCenter, UIAlignment.bottomRight
```

### UIMainAxisAlignment

```dart
UIMainAxisAlignment.start      // Left (Row) / Top (Column)
UIMainAxisAlignment.end        // Right (Row) / Bottom (Column)
UIMainAxisAlignment.center
UIMainAxisAlignment.spaceBetween
UIMainAxisAlignment.spaceAround
UIMainAxisAlignment.spaceEvenly
```

### UIIconData

```dart
// Material Icons
UIIconData.add, UIIconData.delete, UIIconData.edit
UIIconData.check, UIIconData.close, UIIconData.arrowBack
UIIconData.home, UIIconData.settings, UIIconData.person

// Custom icon
UIIconData(0xe145)  // Icon code point
```

## Best Practices

### 1. State Design

```dart
// Good: Flat state structure
final todos = UIState<List<Map>>(key: 'todos', defaultValue: []);
final filter = UIState<String>(key: 'filter', defaultValue: 'all');

// Access: {{todos.0.title}}, {{filter}}
```

### 2. Action Design

```dart
// Good: Descriptive action names with params
final addTodo = UIAction(
  name: 'addTodo',
  params: [UIActionParam(name: 'title', type: 'String')],
);

// Bad: Generic names without params
final action1 = UIAction(name: 'action1');
```

### 3. Widget Composition

```dart
// Good: Break into methods
UIWidget _buildHeader() => UIContainer(...);
UIWidget _buildList() => UIListView(...);
UIWidget _buildItem() => UIListTile(...);

// In build()
root: UIScaffold(
  body: UIColumn(
    children: [
      _buildHeader(),
      _buildList(),
    ],
  ),
)
```

### 4. Version Management

```dart
UIProgram(
  name: 'TodoApp',
  version: '1.2.3',  // Semantic versioning
  metadata: {
    'minHostVersion': '2.0.0',  // Minimum host app version
  },
  ...
)
```

## Common Patterns

### Todo List Pattern

```dart
class TodoApp {
  late final UIState<List<Map>> todos;
  late final UIState<String> newTitle;
  
  UIProgram build() {
    return UIProgram(
      states: [todos, newTitle],
      actions: [
        UIAction(name: 'addTodo'),
        UIAction(name: 'toggleTodo', params: [UIActionParam(name: 'index', type: 'int')]),
        UIAction(name: 'deleteTodo', params: [UIActionParam(name: 'index', type: 'int')]),
      ],
      root: UIScaffold(
        appBar: UIAppBar(title: 'Todos'),
        body: UIColumn(
          children: [
            // Input
            UIRow(
              children: [
                UIExpanded(
                  child: UITextField(
                    hint: 'New todo',
                    onChanged: UIActionRef('updateTitle'),
                  ),
                ),
                UIButton(
                  onPressed: UIActionRef('addTodo'),
                  child: UIText('Add'),
                ),
              ],
            ),
            // List
            UIExpanded(
              child: UIListView(
                children: [
                  // Template item
                  UICard(
                    child: UIListTile(
                      leading: UICheckbox(
                        value: UIRef('todos.0.completed'),
                        onChanged: UIActionRef('toggleTodo', args: {'index': 0}),
                      ),
                      title: UIText.ref(UIRef('todos.0.title')),
                      trailing: UIIconButton(
                        icon: UIIconData.delete,
                        onPressed: UIActionRef('deleteTodo', args: {'index': 0}),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Navigation Pattern

```dart
// Host app handles navigation
UIRuntimeWidget(
  actions: {
    'navigate': (params) {
      final route = params['to'] as String;
      Navigator.pushNamed(context, route);
    },
  },
)

// Mini app triggers navigation
UITextButton(
  onPressed: UICommonActions.navigateTo('/profile'),
  child: UIText('Go to Profile'),
)
```

### Conditional UI Pattern

```dart
// Host app provides computed state
UIRuntimeWidget(
  initialState: {
    'isLoggedIn': false,
    'user': null,
  },
)

// Mini app uses conditional display
// (Runtime handles showing/hiding based on state)
```

## Troubleshooting

### Build Errors

**Error: `dart:ui` not available**
- Cause: mini_app importing Flutter dependencies
- Fix: Ensure mini_app only imports `package:ui_eval/ui_eval.dart`

**Error: Type not found**
- Cause: Missing import or circular dependency
- Fix: Import from `package:ui_eval/ui_eval.dart`

### Runtime Errors

**Error: Widget not rendering**
- Check JSON structure is valid
- Verify all required fields are present
- Check state references match defined states

**Error: Action not firing**
- Verify action name matches handler in host
- Check action params are correctly passed

## File Locations

| Component | Path |
|-----------|------|
| Core DSL | `ui_eval/core/lib/ui_eval.dart` |
| Flutter Runtime | `ui_eval/flutter_runtime/lib/ui_eval_runtime.dart` |
| Mini App Example | `ui_eval/example/mini_app/` |
| Host App Example | `ui_eval/example/host_app/` |

## Dependencies

### mini_app (Pure Dart)
```yaml
dependencies:
  ui_eval:
    path: ../../core  # Relative to mini_app
```

### host_app (Flutter)
```yaml
dependencies:
  ui_eval_runtime:
    path: ../../flutter_runtime  # Relative to host_app
```

## License

MIT
