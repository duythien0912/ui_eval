import { createModule } from '@ui_eval/sdk';

const { defineAction, states, log, moduleId } = createModule('counter');

log('Module initialized');

export const increment = defineAction('increment', async () => {
  const count = await states.get<number>('count');
  const step = await states.get<number>('step');
  const newCount = count + step;
  await states.set('count', newCount);
  await _addToHistory(newCount);
  log('⬆️ Incremented:', count, '→', newCount);
});

export const decrement = defineAction('decrement', async () => {
  const count = await states.get<number>('count');
  const step = await states.get<number>('step');
  const newCount = count - step;
  await states.set('count', newCount);
  await _addToHistory(newCount);
  log('⬇️ Decremented:', count, '→', newCount);
});

export const reset = defineAction('reset', async () => {
  await states.set('count', 0);
  await states.set('history', []);
  log('🔄 Counter reset');
});

export const setStep = defineAction('setStep', async (_ctx, params) => {
  const step = (params?.step as number) ?? 1;
  await states.set('step', step);
  log('📐 Step set to:', step);
});

export const double = defineAction('double', async () => {
  const count = await states.get<number>('count');
  const newCount = count * 2;
  await states.set('count', newCount);
  await _addToHistory(newCount);
  log('✖️ Doubled:', count, '→', newCount);
});

export const setValue = defineAction('setValue', async (_ctx, params) => {
  const value = (params?.value as number) ?? 0;
  await states.set('count', value);
  await _addToHistory(value);
  log('🎯 Value set to:', value);
});

async function _addToHistory(value: number): Promise<void> {
  const history = await states.get<number[]>('history');
  const maxHistory = await states.get<number>('maxHistory');
  const newHistory = [...history, value];
  if (newHistory.length > maxHistory) {
    newHistory.shift();
  }
  await states.set('history', newHistory);
}

export { moduleId };
console.log(`[${moduleId}] Logic loaded successfully`);
