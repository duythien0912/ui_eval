# CLAUDE.md - Project Guide for AI Assistants

## Project Overview

**ui_eval** is a type-safe UI DSL (Domain Specific Language) framework for Flutter that enables creating dynamic, bundled mini-applications with separated UI and logic layers.

### Key Features
- **Type-safe Dart DSL** for defining Flutter UIs declaratively
- **TypeScript business logic** execution via flutter_js
- **JSON-based bundling** for dynamic app loading
- **State management bridge** between Dart and TypeScript
- **Multi-module architecture** for independent mini-apps

## Architecture

### Three-Layer System

1. **DSL Layer (Dart)** - `packages/ui_eval/lib/src/dsl/`
   - Pure Dart classes for UI definition (no Flutter dependencies)
   - Compiles to JSON representation
   - Type-safe widget definitions

2. **Runtime Layer (Dart/Flutter)** - `packages/ui_eval/lib/src/runtime/`
   - Interprets JSON UI definitions
   - Executes bundled JavaScript logic
   - Manages state synchronization
   - Handles bridge communication

3. **Logic Layer (TypeScript)** - `ts_sdk/`
   - TypeScript SDK for action handlers
   - State management API
   - API client for HTTP requests
   - Compiled to JavaScript and bundled

## Project Structure

```
ui_eval/
├── packages/
│   └── ui_eval/                  # Main package
│       ├── lib/
│       │   ├── ui_eval.dart      # Main export (DSL + Runtime)
│       │   ├── dsl_only.dart     # Pure DSL exports (no Flutter)
│       │   ├── runtime.dart      # Runtime exports
│       │   └── src/
│       │       ├── dsl/          # DSL classes (widgets, state, actions)
│       │       ├── runtime/      # Runtime engine & state manager
│       │       └── widgets/      # Widget implementations
│       └── pubspec.yaml
│
├── ts_sdk/                        # TypeScript SDK
│   ├── src/
│   │   ├── index.ts              # Main exports
│   │   ├── bridge.ts             # Flutter bridge communication
│   │   └── actions.ts            # Action registration system
│   ├── bin/
│   │   └── build.js              # Build script for modules
│   └── package.json
│
├── example/                       # Host Flutter app
│   ├── lib/
│   │   └── main.dart             # App launcher with bundle loading
│   ├── modules/                  # Mini-app modules
│   │   ├── counter_app/
│   │   │   ├── lib/
│   │   │   │   ├── counter_ui.dart    # Dart DSL definition
│   │   │   │   └── counter_logic.ts   # TypeScript logic
│   │   │   └── pubspec.yaml
│   │   └── todo_app/
│   │       ├── lib/
│   │       │   ├── todo_ui.dart
│   │       │   └── todo_logic.ts
│   │       └── pubspec.yaml
│   ├── assets/                   # Built bundles
│   │   ├── counter_app.bundle
│   │   └── todo_app.bundle
│   └── pubspec.yaml
│
└── .gitignore
```

## How It Works

### Build Process

1. **TypeScript SDK Compilation**
   ```bash
   cd ts_sdk && npm run build
   ```
   - Compiles TypeScript to JavaScript in `ts_sdk/dist/`

2. **Module Building** (from `example/` or `example/modules/`)
   ```bash
   npx ui-eval-build                    # Build all modules
   npx ui-eval-build counter_app        # Build specific module
   ```

   For each module:
   - Compiles Dart UI file (`*_ui.dart`) to JSON using the DSL
   - Bundles TypeScript logic file (`*_logic.ts`) to JavaScript string
   - Combines into a `.bundle` file with format:
     ```json
     {
       "format": "ui_eval_bundle_v1",
       "moduleId": "counter_app",
       "generatedAt": "2026-01-31T...",
       "ui": { /* JSON UI tree */ },
       "logic": "/* JavaScript code string */"
     }
     ```

3. **Runtime Loading**
   - Flutter app loads bundles from assets
   - `UIBundleLoader` widget parses JSON and creates Flutter widgets
   - JavaScript logic is injected into flutter_js engine
   - Bridge connects Dart state with TypeScript actions

### Communication Flow

```
User Interaction → Flutter Widget → Action Trigger
                                          ↓
                            UIActionTrigger(action: 'increment')
                                          ↓
                            LogicCoordinator.executeAction()
                                          ↓
                            JavaScript VM (flutter_js)
                                          ↓
                        TypeScript action handler executes
                                          ↓
                            Bridge: states.set('count', newValue)
                                          ↓
                            StateManager updates state
                                          ↓
                            Widget rebuilds with new value
```

## Creating a New Module

### Step 1: Create Module Structure

```bash
cd example/modules
mkdir my_app
cd my_app
```

Create `pubspec.yaml`:
```yaml
name: my_app
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  ui_eval:
    path: ../../../packages/ui_eval
```

Create `lib/` directory:
```bash
mkdir lib
```

### Step 2: Define UI (Dart DSL)

Create `lib/my_ui.dart`:
```dart
import 'package:ui_eval/dsl_only.dart';

class MyMiniApp {
  const MyMiniApp();

  UIProgram get program => UIProgram(
    id: 'my_app',
    name: 'My App',
    version: '1.0.0',
    states: [
      UIState(key: 'message', defaultValue: 'Hello', type: 'string'),
    ],
    root: UIScaffold(
      appBar: UIAppBar(
        title: 'My App',
        backgroundColor: 'blue',
      ),
      body: UIColumn(
        mainAxisAlignment: UIMainAxisAlignment.center,
        children: [
          UIText(
            text: '{{state.message}}',
            fontSize: 24,
          ),
          UISizedBox(height: 16),
          UIButton(
            text: 'Update',
            onTap: UIActionTrigger(action: 'updateMessage'),
          ),
        ],
      ),
    ).toJson(),
  );
}
```

### Step 3: Define Logic (TypeScript)

Create `lib/my_logic.ts`:
```typescript
import { createModule } from '@ui_eval/sdk';

const { defineAction, states, log } = createModule('my_app');

export const updateMessage = defineAction('updateMessage', async () => {
  await states.set('message', 'Updated!');
  log('Message updated');
});
```

### Step 4: Register in Host App

Edit `example/pubspec.yaml`:
```yaml
dependencies:
  my_app:
    path: modules/my_app
```

Edit `example/lib/main.dart` - add to `apps` list:
```dart
MiniAppInfo(
  id: 'my',
  name: 'My App',
  description: 'My custom app',
  icon: Icons.star,
  color: Colors.purple,
  bundlePath: 'assets/my_app.bundle',
),
```

### Step 5: Build and Run

```bash
cd example/modules
npx ui-eval-build my_app

cd ..
flutter pub get
flutter run
```

## Common Development Tasks

### Building Modules

From `example/` or `example/modules/`:
```bash
# Build all modules
npx ui-eval-build

# Build specific module
npx ui-eval-build counter_app

# Watch mode (not yet implemented)
npx ui-eval-build --watch
```

### Running the Example App

```bash
cd example
flutter pub get
flutter run  # or flutter run -d macos
```

### Running Tests

```bash
cd example
flutter test
./run_tests.sh  # Integration tests
```

### Updating TypeScript SDK

After modifying `ts_sdk/src/`:
```bash
cd ts_sdk
npm run build
```

Then rebuild modules that use the SDK.

## Key DSL Widgets

### Layout Widgets
- `UIScaffold` - App scaffold with appBar and body
- `UIColumn` - Vertical layout
- `UIRow` - Horizontal layout
- `UIContainer` - Box with padding, margin, decoration
- `UISizedBox` - Fixed size spacer
- `UICenter` - Centers child
- `UIExpanded` - Fills available space

### Content Widgets
- `UIText` - Text display with styling
- `UIIcon` - Icon display
- `UIImage` - Image display

### Input Widgets
- `UIButton` - Clickable button (elevated, outlined, text)
- `UIIconButton` - Icon button
- `UITextField` - Text input
- `UISlider` - Value slider
- `UICheckbox` - Checkbox
- `UISwitch` - Toggle switch

### List Widgets
- `UIListView` - Scrollable list
- `UIListTile` - List item with title/subtitle

## State Management

### Defining State

In Dart DSL:
```dart
states: [
  UIState(key: 'count', defaultValue: 0, type: 'int'),
  UIState(key: 'items', defaultValue: [], type: 'list'),
  UIState(key: 'user', defaultValue: null, type: 'map'),
]
```

### Using State in UI

Template syntax: `{{state.keyName}}`
```dart
UIText(text: 'Count: {{state.count}}')
```

### Accessing State in Logic

```typescript
// Get state
const count = await states.get<number>('count');

// Set state
await states.set('count', 5);

// Update state
await states.update('count', (prev) => prev + 1);
```

## Action System

### Defining Actions

```typescript
export const myAction = defineAction('myAction', async (ctx, params) => {
  // Access state
  const value = await ctx.states.get('key');

  // Update state
  await ctx.states.set('key', newValue);

  // Make API calls
  const data = await ctx.api.get('https://api.example.com/data');

  // Log messages
  ctx.log('Action executed', value);
});
```

### Triggering Actions from UI

```dart
UIButton(
  text: 'Click Me',
  onTap: UIActionTrigger(
    action: 'myAction',
    params: {'value': 42},
  ),
)
```

### Passing Parameters

```dart
UIButton(
  onTap: UIActionTrigger(
    action: 'setValue',
    params: {
      'value': 100,
      'animate': true,
    },
  ),
)
```

In TypeScript:
```typescript
defineAction('setValue', async (ctx, params) => {
  const value = params?.value ?? 0;
  const animate = params?.animate ?? false;
  // ...
});
```

## API Integration

The SDK provides an HTTP client:

```typescript
// GET request
const data = await ctx.api.get<MyType>('https://api.example.com/items');

// POST request
const result = await ctx.api.post('https://api.example.com/items', {
  name: 'New Item',
});

// Custom request
const response = await ctx.api.request({
  url: 'https://api.example.com/data',
  method: 'PUT',
  headers: { 'Authorization': 'Bearer token' },
  body: { data: 'value' },
  useFlutterProxy: true, // Use Flutter's HTTP client
});
```

## Debugging

### Console Logging

From TypeScript:
```typescript
log('Debug message', value);
console.log('This also works');
```

Logs appear in:
- Flutter console (prefixed with `[module_id]`)
- Dart debug output

### Inspecting State

```typescript
const allState = {
  count: await states.get('count'),
  items: await states.get('items'),
};
log('Current state:', allState);
```

### Common Issues

1. **Module not found in build**
   - Ensure `*_ui.dart` exists in `lib/` directory
   - Module name should match directory name
   - Run build from correct directory

2. **Action not executing**
   - Check action is exported from `*_logic.ts`
   - Verify action name matches in UI and logic
   - Check browser console for JavaScript errors

3. **State not updating**
   - Ensure using `await` on state operations
   - Check state key matches definition
   - Verify state type matches value

4. **TypeScript compilation errors**
   - Run `cd ts_sdk && npm run build`
   - Check import paths use `@ui_eval/sdk`
   - Ensure TypeScript SDK is built before modules

## File Naming Conventions

For a module named `my_app`:
- Directory: `example/modules/my_app/`
- UI file: `lib/my_ui.dart` (not `my_app_ui.dart`)
- Logic file: `lib/my_logic.ts` (not `my_app_logic.ts`)
- Class name: `MyMiniApp` (PascalCase of name without `_app`)
- Module ID: `'my_app'` (in both Dart and TypeScript)

The build script looks for files matching `{shortName}_ui.dart` where `shortName = moduleName.replace('_app', '')`.

## Git Status Note

Current modifications:
- `packages/ui_eval/lib/src/runtime/runtime_widget.dart` (Modified)

When working on this project, be aware that this file may have uncommitted changes.

## Platform Support

Tested platforms:
- macOS (development)
- iOS (mobile)
- Android (likely works, not explicitly tested in structure)
- Web (flutter_js may have limitations)

## Dependencies

### Main Package (`packages/ui_eval/`)
- `flutter_js: 0.8.7` - JavaScript execution
- `http: ^1.1.0` - HTTP client
- `path_provider: ^2.1.1` - File system access

### TypeScript SDK (`ts_sdk/`)
- `esbuild: ^0.20.0` - TypeScript bundling
- `typescript: ^5.3.0` - TypeScript compiler

### Example App (`example/`)
- `ui_eval` (local package)
- Module packages (local)
- `flutter_js: ^0.8.7`
- `integration_test` (for testing)

## Next Steps for Development

When enhancing this project, consider:

1. **Add watch mode** to `ts_sdk/bin/build.js` for auto-rebuilding
2. **Implement more widgets** in DSL (e.g., GridView, TabBar, Drawer)
3. **Add validation** for state types and action parameters
4. **Create CLI tool** for scaffolding new modules
5. **Add hot reload** support for development
6. **Improve error messages** from build script and runtime
7. **Add bundle versioning** and migration support
8. **Create documentation** generator from DSL definitions

## Resources

- Main entry point: `example/lib/main.dart`
- DSL definitions: `packages/ui_eval/lib/src/dsl/`
- Build script: `ts_sdk/bin/build.js`
- Example modules: `example/modules/*/lib/`
- Runtime engine: `packages/ui_eval/lib/src/runtime/runtime_widget.dart`

---

**Last Updated**: 2026-01-31
**Project Version**: 0.1.0
