// @ts-ignore
import { createModule } from "@ui_eval/sdk";

// ========================================
// STATE & ACTION ENUMS (must match Dart)
// ========================================
enum State {
  count = "count",
  step = "step",
  history = "history",
}

enum Action {
  increment = "increment",
  decrement = "decrement",
  reset = "reset",
  double = "double",
  setValue = "setValue",
  setStep = "setStep",
}

// ========================================
// MODULE SETUP
// ========================================
const { defineAction, states, log, moduleId } = createModule("counter_app");

log("Module initialized");

// ========================================
// ACTIONS
// ========================================
export const increment = defineAction(Action.increment, async () => {
  const count = await states.get<number>(State.count);
  const step = await states.get<number>(State.step);
  const newCount = count + step;
  await states.set(State.count, newCount);
  await _addToHistory(newCount);
  log("⬆️ Incremented:", count, "→", newCount);
});

export const decrement = defineAction(Action.decrement, async () => {
  const count = await states.get<number>(State.count);
  const step = await states.get<number>(State.step);
  const newCount = count - step;
  await states.set(State.count, newCount);
  await _addToHistory(newCount);
  log("⬇️ Decremented:", count, "→", newCount);
});

export const reset = defineAction(Action.reset, async () => {
  await states.set(State.count, 0);
  await states.set(State.history, []);
  log("🔄 Counter reset");
});

export const setStep = defineAction(
  Action.setStep,
  async (_ctx: any, params: { step: number }) => {
    const step = Math.round((params?.step as number) ?? 1);
    await states.set(State.step, step);
    log("📐 Step set to:", step);
  },
);

export const double = defineAction(Action.double, async () => {
  const count = await states.get<number>(State.count);
  const newCount = count * 2;
  await states.set(State.count, newCount);
  await _addToHistory(newCount);
  log("✖️ Doubled:", count, "→", newCount);
});

export const setValue = defineAction(
  Action.setValue,
  async (_ctx: any, params: { value: number }) => {
    const value = (params?.value as number) ?? 0;
    await states.set(State.count, value);
    await _addToHistory(value);
    log("🎯 Value set to:", value);
  },
);

async function _addToHistory(value: number): Promise<void> {
  const history = await states.get<number[]>(State.history);
  const newHistory = [...history, value];
  const maxHistory = 10; // Keep last 10 values
  if (newHistory.length > maxHistory) {
    newHistory.shift();
  }
  await states.set(State.history, newHistory);
}

export { moduleId };
console.log(`[${moduleId}] Logic loaded successfully`);
