/**
 * Type definitions for Todo App
 */
export interface Todo {
    title: string;
    completed: boolean;
    createdAt?: string;
}
export interface TodoAppState {
    todos: Todo[];
    newTodoTitle: string;
    filter: 'all' | 'active' | 'completed';
}
