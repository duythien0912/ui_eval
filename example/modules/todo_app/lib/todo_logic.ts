// @ts-ignore
import { createModule } from "@ui_eval/sdk";

// ========================================
// STATE & ACTION ENUMS (must match Dart)
// ========================================
enum State {
  todos = "todos",
  newTodoTitle = "newTodoTitle",
  filter = "filter",
}

enum Action {
  addTodo = "addTodo",
  toggleTodo = "toggleTodo",
  deleteTodo = "deleteTodo",
  updateTitle = "updateTitle",
  setFilter = "setFilter",
  clearCompleted = "clearCompleted",
  fetchTodosFromApi = "fetchTodosFromApi",
}

// ========================================
// TYPES
// ========================================
export interface Todo {
  title: string;
  completed: boolean;
  createdAt: string;
}

// ========================================
// MODULE SETUP
// ========================================
const { defineAction, states, api, log, moduleId } = createModule("todo_app");

log("Module initialized");

// ========================================
// ACTIONS
// ========================================
export const addTodo = defineAction(Action.addTodo, async () => {
  const title = await states.get<string>(State.newTodoTitle);
  if (!title || title.trim() === "") {
    log("⚠️ Cannot add empty todo");
    return;
  }
  const todos = await states.get<Todo[]>(State.todos);
  const newTodo: Todo = {
    title: title.trim(),
    completed: false,
    createdAt: new Date().toISOString(),
  };
  await states.set(State.todos, [...todos, newTodo]);
  await states.set(State.newTodoTitle, "");
  log("✅ Added todo:", newTodo.title);
});

export const toggleTodo = defineAction(
  Action.toggleTodo,
  async (_ctx: any, params: { index: number }) => {
    const index = params?.index as number;
    if (typeof index !== "number") {
      log("❌ Invalid index");
      return;
    }
    const todos = await states.get<Todo[]>(State.todos);
    if (index < 0 || index >= todos.length) {
      log("❌ Index out of bounds:", index);
      return;
    }
    const updatedTodos = [...todos];
    updatedTodos[index] = {
      ...updatedTodos[index],
      completed: !updatedTodos[index].completed,
    };
    await states.set(State.todos, updatedTodos);
    log("✅ Toggled todo at index:", index);
  },
);

export const deleteTodo = defineAction(
  Action.deleteTodo,
  async (_ctx: any, params: { index: number }) => {
    const index = params?.index as number;
    if (typeof index !== "number") {
      log("❌ Invalid index");
      return;
    }
    const todos = await states.get<Todo[]>(State.todos);
    if (index < 0 || index >= todos.length) {
      log("❌ Index out of bounds:", index);
      return;
    }
    const deleted = todos[index];
    const updatedTodos = todos.filter((_t: Todo, i: number) => i !== index);
    await states.set(State.todos, updatedTodos);
    log("🗑️ Deleted todo:", deleted.title);
  },
);

export const updateTitle = defineAction(
  Action.updateTitle,
  async (_ctx: any, params: { value: string }) => {
    const value = (params?.value as string) ?? "";
    await states.set(State.newTodoTitle, value);
  },
);

export const setFilter = defineAction(
  Action.setFilter,
  async (_ctx: any, params: { filter: string }) => {
    const filter = params?.filter as "all" | "active" | "completed";
    await states.set(State.filter, filter);
    log("🔍 Filter set to:", filter);
  },
);

export const clearCompleted = defineAction(Action.clearCompleted, async () => {
  const todos = await states.get<Todo[]>(State.todos);
  const activeTodos = todos.filter((t: Todo) => !t.completed);
  const clearedCount = todos.length - activeTodos.length;
  await states.set(State.todos, activeTodos);
  log("🧹 Cleared", clearedCount, "completed todos");
});

export const fetchTodosFromApi = defineAction(
  Action.fetchTodosFromApi,
  async () => {
    try {
      log("🌐 Fetching todos from API...");
      const response = await api.request({
        url: "https://dummyjson.com/todos?limit=10",
        method: "GET",
        useFlutterProxy: true,
      });

      log("📦 API Response:", JSON.stringify(response).substring(0, 200));

      const todosArray = response.todos || [];
      const formattedTodos: Todo[] = todosArray.map((t: any) => ({
        title: t.todo,
        completed: t.completed,
        createdAt: new Date().toISOString(),
      }));

      await states.set(State.todos, formattedTodos);
      log("✅ Fetched", formattedTodos.length, "todos from API");
    } catch (error) {
      log("❌ Failed to fetch todos:", error);
    }
  },
);

export { moduleId };
console.log(`[${moduleId}] Logic loaded successfully`);
