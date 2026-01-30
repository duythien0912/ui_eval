"use strict";
var AppLogic = (() => {
  // ../../ts_sdk/dist/bridge.js
  var FlutterBridge = class {
    constructor() {
      this.pendingCalls = /* @__PURE__ */ new Map();
      this.callId = 0;
      this.setupMessageListener();
    }
    setupMessageListener() {
      window.addEventListener("message", (event) => {
        const data = event.data;
        if (data?.type?.startsWith("response.") && data.callId) {
          this.handleResponse(data.callId, data.payload);
        }
      });
    }
    handleResponse(callId, payload) {
      const resolve = this.pendingCalls.get(callId);
      if (resolve) {
        resolve(payload);
        this.pendingCalls.delete(callId);
      }
    }
    generateCallId() {
      return `ts_${++this.callId}_${Date.now()}`;
    }
    /**
     * Send a message to Flutter and await response
     */
    async postMessage(type, payload) {
      const callId = this.generateCallId();
      return new Promise((resolve) => {
        this.pendingCalls.set(callId, resolve);
        const message = { type, callId, payload };
        if (window.FlutterBridge?.postMessage) {
          window.FlutterBridge.postMessage(JSON.stringify(message));
        } else {
          console.log("[FlutterBridge] Message:", message);
          resolve(void 0);
        }
      });
    }
    /**
     * Register a native action handler (called from Flutter)
     */
    registerAction(name, handler) {
      window[`__action_${name}__`] = handler;
    }
  };
  var bridge = new FlutterBridge();

  // ../../ts_sdk/dist/states.js
  var StateManager = class {
    constructor() {
      this.cache = /* @__PURE__ */ new Map();
    }
    async get(key) {
      const value = await bridge.postMessage("state.get", { key });
      this.cache.set(key, value);
      return value;
    }
    async set(key, value) {
      this.cache.set(key, value);
      await bridge.postMessage("state.set", { key, value });
    }
    async update(key, updater) {
      const current = await this.get(key);
      const next = updater(current);
      await this.set(key, next);
    }
  };
  var states = new StateManager();

  // ../../ts_sdk/dist/api.js
  var ApiClient = class {
    /**
     * Make an HTTP request through Flutter's native HTTP client
     * This bypasses browser CORS restrictions
     */
    async request(config) {
      const response = await bridge.postMessage("api.request", {
        url: config.url,
        method: config.method ?? "GET",
        headers: config.headers ?? {},
        body: config.body,
        useFlutterProxy: config.useFlutterProxy ?? true
      });
      return response.data;
    }
    async get(url, headers) {
      return this.request({ url, method: "GET", headers });
    }
    async post(url, body, headers) {
      return this.request({ url, method: "POST", body, headers });
    }
    async put(url, body, headers) {
      return this.request({ url, method: "PUT", body, headers });
    }
    async delete(url, headers) {
      return this.request({ url, method: "DELETE", headers });
    }
  };
  var api = new ApiClient();

  // ../../ts_sdk/dist/actions.js
  var ActionRegistry = class {
    constructor() {
      this.actions = /* @__PURE__ */ new Map();
    }
    register(name, handler) {
      this.actions.set(name, handler);
      bridge.registerAction(name, handler);
      console.log("[ActionRegistry] Registered:", name);
    }
    get(name) {
      return this.actions.get(name);
    }
    has(name) {
      return this.actions.has(name);
    }
    async execute(name, params) {
      const handler = this.actions.get(name);
      if (!handler) {
        console.error("[ActionRegistry] Action not found:", name);
        return;
      }
      const context = {
        states,
        api,
        log: (...args) => console.log(`[Action:${name}]`, ...args)
      };
      await handler(context, params);
    }
    list() {
      return Array.from(this.actions.keys());
    }
  };
  var registry = new ActionRegistry();
  function defineAction(name, handler) {
    const definition = { name, handler };
    registry.register(name, handler);
    return definition;
  }
  window.__ui_eval_actions__ = {
    execute: (name, params) => {
      return registry.execute(name, params);
    },
    list: () => registry.list()
  };

  // ../../ts_sdk/dist/index.js
  console.log("[@ui_eval/sdk] SDK loaded v1.0.0");

  // dist/todoLogic.js
  var addTodo = defineAction("addTodo", async ({ log }) => {
    const title = await states.get("newTodoTitle");
    if (!title || title.trim() === "") {
      log("Cannot add empty todo");
      return;
    }
    const todos = await states.get("todos");
    const newTodo = {
      title: title.trim(),
      completed: false,
      createdAt: (/* @__PURE__ */ new Date()).toISOString()
    };
    await states.set("todos", [...todos, newTodo]);
    await states.set("newTodoTitle", "");
    log("Added todo:", newTodo.title);
  });
  var toggleTodo = defineAction("toggleTodo", async ({ log }, params) => {
    const index = params?.index;
    if (typeof index !== "number") {
      log("Invalid index for toggleTodo");
      return;
    }
    const todos = await states.get("todos");
    if (index < 0 || index >= todos.length) {
      log("Index out of bounds:", index);
      return;
    }
    const updatedTodos = [...todos];
    updatedTodos[index] = {
      ...updatedTodos[index],
      completed: !updatedTodos[index].completed
    };
    await states.set("todos", updatedTodos);
    log("Toggled todo at index:", index);
  });
  var deleteTodo = defineAction("deleteTodo", async ({ log }, params) => {
    const index = params?.index;
    if (typeof index !== "number") {
      log("Invalid index for deleteTodo");
      return;
    }
    const todos = await states.get("todos");
    if (index < 0 || index >= todos.length) {
      log("Index out of bounds:", index);
      return;
    }
    const deleted = todos[index];
    const updatedTodos = todos.filter((_t, i) => i !== index);
    await states.set("todos", updatedTodos);
    log("Deleted todo:", deleted.title);
  });
  var updateTitle = defineAction("updateTitle", async (_ctx, params) => {
    const value = params?.value;
    await states.set("newTodoTitle", value ?? "");
  });
  var setFilter = defineAction("setFilter", async ({ log }, params) => {
    const filter = params?.filter;
    await states.set("filter", filter);
    log("Filter set to:", filter);
  });
  var clearCompleted = defineAction("clearCompleted", async ({ log }) => {
    const todos = await states.get("todos");
    const activeTodos = todos.filter((t) => !t.completed);
    const clearedCount = todos.length - activeTodos.length;
    await states.set("todos", activeTodos);
    log("Cleared", clearedCount, "completed todos");
  });
  var fetchTodosFromApi = defineAction("fetchTodosFromApi", async ({ log }) => {
    try {
      log("Fetching todos from API...");
      const todos = await api.request({
        url: "https://jsonplaceholder.typicode.com/todos?_limit=5",
        method: "GET",
        useFlutterProxy: true
      });
      const formattedTodos = todos.map((t) => ({
        title: t.title,
        completed: t.completed,
        createdAt: (/* @__PURE__ */ new Date()).toISOString()
      }));
      await states.set("todos", formattedTodos);
      log("Fetched", formattedTodos.length, "todos");
    } catch (error) {
      log("Failed to fetch todos:", error);
    }
  });
  console.log("[TodoLogic] Actions registered");

  // dist/index.js
  console.log("[Logic] Bundle loaded");
})();
//# sourceMappingURL=logic_bundle.js.map
