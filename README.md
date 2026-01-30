# ui_eval

Type-safe UI DSL for Flutter with hot update support.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        DEVELOPMENT                               │
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
├── lib/
│   ├── core/                    # Pure Dart DSL (no Flutter)
│   │   ├── ui_eval.dart         # Main export
│   │   ├── src/
│   │   │   ├── ui_widget.dart   # Base widget class
│   │   │   ├── ui_state.dart    # State management
│   │   │   ├── ui_action.dart   # Action handlers
│   │   │   └── widgets/         # All widget types
│   │   │       ├── layout.dart
│   │   │       ├── content.dart
│   │   │       ├── input.dart
│   │   │       └── lists.dart
│   │   └── pubspec.yaml         # Pure Dart package
│   │
│   └── flutter_runtime/         # Flutter runtime (renders JSON)
│       ├── ui_eval_runtime.dart
│       └── src/
│           └── runtime_widget.dart
│
└── example/
    ├── mini_app/                # Example mini app (type-safe dev)
    │   ├── lib/todo_app.dart
    │   ├── build.dart           # Build script
    │   └── pubspec.yaml
    │
    ├── host_app/                # Example Flutter host
    │   ├── lib/main.dart
    │   ├── assets/apps/         # JSON apps
    │   └── pubspec.yaml
    │
    └── server/                  # Update server
        └── update_server.dart
```

## Quick Start

### 1. Create a Mini App

```dart
// mini_app/lib/my_app.dart
import 'package:ui_eval/ui_eval.dart';

class MyApp {
  UIProgram build() {
    // Define state
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

```bash
cd example/mini_app
dart build.dart
# Output: ../host_app/assets/apps/todo_app.json
```

### 3. Run in Host App

```dart
// host_app/main.dart
import 'package:ui_eval_runtime/ui_eval_runtime.dart';

UIRuntimeWidget(
  uiJson: jsonDecode(await rootBundle.loadString('assets/apps/todo_app.json')),
  initialState: {'count': 0},
  actions: {
    'increment': (_) => setState(() => count++),
  },
)
```

## Widget Reference

### Layout
- `UIScaffold`, `UIAppBar`, `UISafeArea`
- `UIColumn`, `UIRow`, `UIStack`, `UIPositioned`
- `UIContainer`, `UICenter`, `UIAlign`, `UIPadding`
- `UIExpanded`, `UISizedBox`, `UIDivider`

### Content
- `UIText`, `UIIcon`, `UIImage`
- `UICard`, `UIChip`, `UIBadge`

### Input
- `UIButton`, `UITextButton`, `UIIconButton`, `UIFloatingActionButton`
- `UITextField`, `UICheckbox`, `UISwitch`, `UIRadio`, `UISlider`

### Lists
- `UIListView`, `UIListTile`, `UIGridView`
- `UITabBar`, `UIBottomNavigationBar`

## State Management

```dart
// Define state
final todos = UIState<List>(key: 'todos', defaultValue: []);
final title = UIState<String>(key: 'title', defaultValue: '');

// Reference in UI
UIText.state(todos)           // {{todos}}
UIText.ref(todos.prop('length'))  // {{todos.length}}
UIText.ref(todos.index(0).prop('title'))  // {{todos.0.title}}
```

## Actions

```dart
// Define action
final addTodo = UIAction(
  name: 'addTodo',
  params: [UIActionParam(name: 'title', type: 'String')],
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
      final title = params['title'];
      // Handle action
    },
  },
)
```

## Hot Updates

```dart
UIEvalWidget(
  json: initialJson,
  updateUrl: 'https://your-server.com',
  version: '1.0.0',
)
```

Run the update server:
```bash
dart example/server/update_server.dart
```

## Benefits

1. **Type Safety** - Catch errors at compile time, not runtime
2. **Hot Updates** - Push UI changes without app store
3. **Clean Separation** - Mini apps don't depend on Flutter
4. **Server-Driven** - Control UI from backend
5. **Version Control** - Track UI versions independently

## License

MIT
