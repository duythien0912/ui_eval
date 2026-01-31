// @ts-ignore
import { createModule } from '@ui_eval/sdk';

export interface Todo {
  title: string;
  completed: boolean;
  createdAt: string;
}

const { defineAction, states, api, log, moduleId } = createModule('todo_app');

log('Module initialized');

export const addTodo = defineAction('addTodo', async () => {
  const title = await states.get<string>('newTodoTitle');
  if (!title || title.trim() === '') {
    log('⚠️ Cannot add empty todo');
    return;
  }
  const todos = await states.get<Todo[]>('todos');
  const newTodo: Todo = {
    title: title.trim(),
    completed: false,
    createdAt: new Date().toISOString(),
  };
  await states.set('todos', [...todos, newTodo]);
  await states.set('newTodoTitle', '');
  log('✅ Added todo:', newTodo.title);
});

export const toggleTodo = defineAction('toggleTodo', async (_ctx: any, params: { index: number; }) => {
  const index = params?.index as number;
  if (typeof index !== 'number') {
    log('❌ Invalid index');
    return;
  }
  const todos = await states.get<Todo[]>('todos');
  if (index < 0 || index >= todos.length) {
    log('❌ Index out of bounds:', index);
    return;
  }
  const updatedTodos = [...todos];
  updatedTodos[index] = { ...updatedTodos[index], completed: !updatedTodos[index].completed };
  await states.set('todos', updatedTodos);
  log('✅ Toggled todo at index:', index);
});

export const deleteTodo = defineAction('deleteTodo', async (_ctx: any, params: { index: number; }) => {
  const index = params?.index as number;
  if (typeof index !== 'number') {
    log('❌ Invalid index');
    return;
  }
  const todos = await states.get<Todo[]>('todos');
  if (index < 0 || index >= todos.length) {
    log('❌ Index out of bounds:', index);
    return;
  }
  const deleted = todos[index];
  const updatedTodos = todos.filter((_t: Todo, i: number) => i !== index);
  await states.set('todos', updatedTodos);
  log('🗑️ Deleted todo:', deleted.title);
});

export const updateTitle = defineAction('updateTitle', async (_ctx: any, params: { value: string; }) => {
  const value = params?.value as string ?? '';
  await states.set('newTodoTitle', value);
});

export const setFilter = defineAction('setFilter', async (_ctx: any, params: { filter: string; }) => {
  const filter = params?.filter as 'all' | 'active' | 'completed';
  await states.set('filter', filter);
  log('🔍 Filter set to:', filter);
});

export const clearCompleted = defineAction('clearCompleted', async () => {
  const todos = await states.get<Todo[]>('todos');
  const activeTodos = todos.filter((t: Todo) => !t.completed);
  const clearedCount = todos.length - activeTodos.length;
  await states.set('todos', activeTodos);
  log('🧹 Cleared', clearedCount, 'completed todos');
});

export const fetchTodosFromApi = defineAction('fetchTodosFromApi', async () => {
  try {
    log('🌐 Fetching todos from API...');
    const todos = await api.request({
      url: 'https://jsonplaceholder.typicode.com/todos?_limit=5',
      method: 'GET',
      useFlutterProxy: true,
    });
    const formattedTodos: Todo[] = (todos as any[]).map((t: any) => ({
      title: t.title,
      completed: t.completed,
      createdAt: new Date().toISOString(),
    }));
    await states.set('todos', formattedTodos);
    log('✅ Fetched', formattedTodos.length, 'todos from API');
  } catch (error) {
    log('❌ Failed to fetch todos:', error);
  }
});

export { moduleId };
console.log(`[${moduleId}] Logic loaded successfully`);
