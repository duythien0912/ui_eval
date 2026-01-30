import { FlutterBridge, ModuleBridge, ActionHandler, ActionContext } from './bridge';

export interface ActionDefinition {
  name: string;
  handler: ActionHandler;
  moduleId: string;
}

interface ModuleActions {
  registry: Map<string, ActionHandler>;
  bridge: ModuleBridge;
}

class ActionRegistry {
  private modules: Map<string, ModuleActions> = new Map();

  private getModule(moduleId: string): ModuleActions {
    if (!this.modules.has(moduleId)) {
      this.modules.set(moduleId, {
        registry: new Map(),
        bridge: FlutterBridge.getModule(moduleId)
      });
    }
    return this.modules.get(moduleId)!;
  }

  register(moduleId: string, name: string, handler: ActionHandler): void {
    const module = this.getModule(moduleId);
    module.registry.set(name, handler);
    console.log(`[ActionRegistry] [${moduleId}] Registered:`, name);
  }

  get(moduleId: string, name: string): ActionHandler | undefined {
    return this.getModule(moduleId).registry.get(name);
  }

  has(moduleId: string, name: string): boolean {
    return this.getModule(moduleId).registry.has(name);
  }

  async execute(moduleId: string, name: string, params?: Record<string, any>): Promise<void> {
    const module = this.getModule(moduleId);
    const handler = module.registry.get(name);
    
    if (!handler) {
      console.error(`[ActionRegistry] [${moduleId}] Action not found:`, name);
      return;
    }

    const context: ActionContext = {
      states: module.bridge.createStateProxy(),
      api: module.bridge.createApiClient(),
      log: (...args) => console.log(`[${moduleId}:${name}]`, ...args),
    };

    try {
      await handler(context, params);
    } catch (error) {
      console.error(`[ActionRegistry] [${moduleId}] Error in ${name}:`, error);
    }
  }

  list(moduleId: string): string[] {
    return Array.from(this.getModule(moduleId).registry.keys());
  }

  getModules(): string[] {
    return Array.from(this.modules.keys());
  }
}

export const registry = new ActionRegistry();

export function defineAction(
  moduleId: string,
  name: string,
  handler: ActionHandler
): ActionDefinition {
  const definition: ActionDefinition = { name, handler, moduleId };
  registry.register(moduleId, name, handler);
  return definition;
}

export function createModule(moduleId: string) {
  const bridge = FlutterBridge.getModule(moduleId);
  const states = bridge.createStateProxy();
  const api = bridge.createApiClient();

  return {
    moduleId,
    states,
    api,
    defineAction: (name: string, handler: ActionHandler) => 
      defineAction(moduleId, name, handler),
    log: (...args: any[]) => console.log(`[${moduleId}]`, ...args),
  };
}

(window as any).__ui_eval_registry__ = {
  execute: (moduleId: string, name: string, params?: Record<string, any>) => {
    return registry.execute(moduleId, name, params);
  },
  list: (moduleId: string) => registry.list(moduleId),
  getModules: () => registry.getModules(),
};
