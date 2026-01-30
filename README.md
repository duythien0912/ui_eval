# ui_eval

Type-safe DSL for flutter_eval with hot update support. Build dynamic Flutter UIs without writing Dart code as strings.

## Features

- 🎯 **Type-safe DSL** - Build UIs with IDE autocomplete and type checking
- 🔄 **Hot Updates** - Push UI updates over-the-air without app store
- 🧩 **JSON-based UI** - Server-driven UI with state management
- ⚡ **flutter_eval Integration** - Compile to EVC bytecode for production
- 🎨 **Familiar API** - Widget names match Flutter's Material Design

## Installation

```yaml
dependencies:
  ui_eval: ^0.1.0
```

## Quick Start

### 1. Type-Safe DSL

```dart
import 'package:ui_eval/ui_eval.dart';

// Define your UI with type-safe DSL
final program = UIProgram(
  name: 'TodoPage',
  states: [
    UIState(key: 'todos', defaultValue: <Map<String, dynamic>>[]),
    UIState(key: 'newTitle', defaultValue: ''),
  ],
  actions: [
    UIAction(name: 'addTodo'),
    UIAction(name: 'toggleTodo'),
  ],
  root: UIScaffold(
    appBar: UIAppBar(title: 'Todo App'),
    body: UIColumn(
      children: [
        UITextField(
          hint: 'Enter todo...',
          onChanged: UIActionRef('updateTitle'),
        ),
        UIButton(
          onPressed: UIActionRef('addTodo'),
          child: UIText('Add'),
        ),
      ],
    ),
  ),
);

// Generate Dart code
final dartCode = program.toDartCode();

// Or compile to EVC bytecode
final compiler = UICompiler();
final bytes = await compiler.compileToEvc(
  className: 'TodoPage',
  root: program.root,
  states: program.states,
  actions: program.actions,
);
```

### 2. JSON-Based Dynamic UI

```dart
// Define UI as JSON (can come from server)
final uiJson = {
  'version': '1.0.0',
  'name': 'TodoPage',
  'states': [
    {'key': 'todos', 'type': 'List', 'defaultValue': []},
  ],
  'root': {
    'type': 'Scaffold',
    'appBar': {
      'type': 'AppBar',
      'title': 'Todo App',
    },
    'body': {
      'type': 'ListView',
      'children': [
        // ... widgets
      ],
    },
  },
};

// Render with state and actions
UIJsonWidget(
  json: uiJson,
  initialState: {'todos': []},
  actions: {
    'addTodo': (params) => print('Add todo: $params'),
    'toggleTodo': (params) => print('Toggle: $params'),
  },
)
```

### 3. Hot Update Support

```dart
UIEvalWidget(
  json: uiJson,
  initialState: {'todos': []},
  actions: actionHandlers,
  updateUrl: 'https://your-server.com',  // Enable hot updates
  version: '1.0.0',
  updateInterval: Duration(seconds: 30),  // Check every 30s
)
```

## Available Widgets

### Layout
- `UIColumn`, `UIRow`, `UIStack`
- `UIContainer`, `UICenter`, `UIAlign`
- `UIExpanded`, `UISizedBox`, `UIPadding`
- `UISafeArea`, `UIScaffold`

### Content
- `UIText` - Text with state reference support
- `UIIcon`, `UIImage`
- `UICard`, `UIListTile`, `UIDivider`

### Input
- `UIButton`, `UITextButton`, `UIIconButton`
- `UITextField`
- `UICheckbox`, `UISwitch`, `UIRadio`
- `UIFloatingActionButton`

### Lists
- `UIListView`, `UIListViewBuilder`

## Widgets Reference

### UIText
```dart
// Simple text
UIText('Hello World')

// With styling
UIText(
  'Hello',
  fontSize: 24,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
)

// With state reference
UIText.state(UIStateRef('username'))
```

### UIButton
```dart
UIButton(
  onPressed: UIActionRef('onSubmit'),
  backgroundColor: Colors.blue,
  child: UIText('Submit'),
)
```

### UIState
```dart
// Define state
final todos = UIState<List>(key: 'todos', defaultValue: []);
final count = UIState<int>(key: 'count', defaultValue: 0);

// Reference in widgets
UIText.state(todos.ref)
UICheckbox(
  value: UIStateRef('todos.0.completed'),
  onChanged: UIActionRef('toggle'),
)
```

## Hot Update Server

Run the included update server:

```bash
cd example/server
dart update_server.dart
```

Server endpoints:
- `GET /api/update?version=1.0.0` - Check for updates
- `GET /updates/1.1.0.json` - Download UI JSON
- `POST /admin/publish` - Publish new update

## Example: Todo App

See `example/lib/todo_app.dart` for a complete working example.

```bash
cd example
flutter run
```

## Architecture

```
┌─────────────────────────────────────────┐
│  Type-Safe DSL                          │
│  UIColumn, UIButton, etc.               │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  Compiler                               │
│  - Dart code generator                  │
│  - JSON serializer                      │
│  - EVC bytecode compiler (flutter_eval) │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  Runtime                                │
│  - JSON interpreter                     │
│  - EVC executor                         │
│  - Hot update manager                   │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│  Flutter Widgets                        │
└─────────────────────────────────────────┘
```

## License

MIT
