/**
 * Todo App Logic - TypeScript implementation
 *
 * This replaces the Dart action handlers with type-safe TypeScript
 */
import type { ActionDefinition } from '@ui_eval/sdk';
declare const addTodo: ActionDefinition;
declare const toggleTodo: ActionDefinition;
declare const deleteTodo: ActionDefinition;
declare const updateTitle: ActionDefinition;
declare const setFilter: ActionDefinition;
declare const clearCompleted: ActionDefinition;
declare const fetchTodosFromApi: ActionDefinition;
export { addTodo, toggleTodo, deleteTodo, updateTitle, setFilter, clearCompleted, fetchTodosFromApi };
