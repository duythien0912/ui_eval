/**
 * Todo App Logic - TypeScript implementation
 *
 * This replaces the Dart action handlers with type-safe TypeScript
 */
import { defineAction, states, api } from '@ui_eval/sdk';
// Add a new todo
const addTodo = defineAction('addTodo', async ({ log }) => {
    const title = await states.get('newTodoTitle');
    if (!title || title.trim() === '') {
        log('Cannot add empty todo');
        return;
    }
    const todos = await states.get('todos');
    const newTodo = {
        title: title.trim(),
        completed: false,
        createdAt: new Date().toISOString(),
    };
    await states.set('todos', [...todos, newTodo]);
    await states.set('newTodoTitle', '');
    log('Added todo:', newTodo.title);
});
// Toggle todo completion status
const toggleTodo = defineAction('toggleTodo', async ({ log }, params) => {
    const index = params?.index;
    if (typeof index !== 'number') {
        log('Invalid index for toggleTodo');
        return;
    }
    const todos = await states.get('todos');
    if (index < 0 || index >= todos.length) {
        log('Index out of bounds:', index);
        return;
    }
    const updatedTodos = [...todos];
    updatedTodos[index] = {
        ...updatedTodos[index],
        completed: !updatedTodos[index].completed,
    };
    await states.set('todos', updatedTodos);
    log('Toggled todo at index:', index);
});
// Delete a todo
const deleteTodo = defineAction('deleteTodo', async ({ log }, params) => {
    const index = params?.index;
    if (typeof index !== 'number') {
        log('Invalid index for deleteTodo');
        return;
    }
    const todos = await states.get('todos');
    if (index < 0 || index >= todos.length) {
        log('Index out of bounds:', index);
        return;
    }
    const deleted = todos[index];
    const updatedTodos = todos.filter((_t, i) => i !== index);
    await states.set('todos', updatedTodos);
    log('Deleted todo:', deleted.title);
});
// Update new todo title input
const updateTitle = defineAction('updateTitle', async (_ctx, params) => {
    const value = params?.value;
    await states.set('newTodoTitle', value ?? '');
});
// Set filter
const setFilter = defineAction('setFilter', async ({ log }, params) => {
    const filter = params?.filter;
    await states.set('filter', filter);
    log('Filter set to:', filter);
});
// Clear all completed todos
const clearCompleted = defineAction('clearCompleted', async ({ log }) => {
    const todos = await states.get('todos');
    const activeTodos = todos.filter((t) => !t.completed);
    const clearedCount = todos.length - activeTodos.length;
    await states.set('todos', activeTodos);
    log('Cleared', clearedCount, 'completed todos');
});
// Example: Fetch todos from API (using Dart proxy)
const fetchTodosFromApi = defineAction('fetchTodosFromApi', async ({ log }) => {
    try {
        log('Fetching todos from API...');
        // Using Flutter proxy to avoid CORS
        const todos = await api.request({
            url: 'https://jsonplaceholder.typicode.com/todos?_limit=5',
            method: 'GET',
            useFlutterProxy: true,
        });
        // Transform API data to our format
        const formattedTodos = todos.map((t) => ({
            title: t.title,
            completed: t.completed,
            createdAt: new Date().toISOString(),
        }));
        await states.set('todos', formattedTodos);
        log('Fetched', formattedTodos.length, 'todos');
    }
    catch (error) {
        log('Failed to fetch todos:', error);
    }
});
// Export actions
export { addTodo, toggleTodo, deleteTodo, updateTitle, setFilter, clearCompleted, fetchTodosFromApi };
console.log('[TodoLogic] Actions registered');
//# sourceMappingURL=todoLogic.js.map