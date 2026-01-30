export interface BridgeMessage {
  type: 'state.get' | 'state.set' | 'api.request' | 'action.execute' | 'console.log';
  callId: string;
  moduleId: string;
  payload: any;
}

export interface ApiRequestConfig {
  url: string;
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  headers?: Record<string, string>;
  body?: any;
  useFlutterProxy?: boolean;
}

export interface StateProxy {
  get<T>(key: string): Promise<T>;
  set<T>(key: string, value: T): Promise<void>;
  update<T>(key: string, updater: (prev: T) => T): Promise<void>;
}

export interface ApiClient {
  request<T = any>(config: ApiRequestConfig): Promise<T>;
  get<T = any>(url: string, headers?: Record<string, string>): Promise<T>;
  post<T = any>(url: string, body: any, headers?: Record<string, string>): Promise<T>;
  put<T = any>(url: string, body: any, headers?: Record<string, string>): Promise<T>;
  delete<T = any>(url: string, headers?: Record<string, string>): Promise<T>;
}

export interface ActionContext {
  states: StateProxy;
  api: ApiClient;
  log: (...args: any[]) => void;
}

export interface ActionHandler {
  (context: ActionContext, params?: Record<string, any>): Promise<void> | void;
}

type PromiseResolver = (value: any) => void;

export class ModuleBridge {
  private pendingCalls: Map<string, PromiseResolver> = new Map();
  private callId = 0;
  private moduleId: string;

  constructor(moduleId: string) {
    this.moduleId = moduleId;
    this.setupMessageListener();
    this.interceptConsole();
  }

  getModuleId(): string {
    return this.moduleId;
  }

  private setupMessageListener(): void {
    window.addEventListener('message', (event: MessageEvent) => {
      const data = event.data;
      if (data?.type?.startsWith('response.') && data.callId && data.moduleId === this.moduleId) {
        this.handleResponse(data.callId, data.payload);
      }
    });
  }

  private interceptConsole(): void {
    const originalLog = console.log;
    const originalWarn = console.warn;
    const originalError = console.error;
    const moduleId = this.moduleId;
    
    console.log = (...args: any[]) => {
      this.postMessageNoResponse('console.log', { 
        level: 'log', 
        args: args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a))
      });
      originalLog.apply(console, [`[${moduleId}]`, ...args]);
    };

    console.warn = (...args: any[]) => {
      this.postMessageNoResponse('console.log', { 
        level: 'warn', 
        args: args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a))
      });
      originalWarn.apply(console, [`[${moduleId}]`, ...args]);
    };

    console.error = (...args: any[]) => {
      this.postMessageNoResponse('console.log', { 
        level: 'error', 
        args: args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a))
      });
      originalError.apply(console, [`[${moduleId}]`, ...args]);
    };
  }

  private handleResponse(callId: string, payload: any): void {
    const resolve = this.pendingCalls.get(callId);
    if (resolve) {
      resolve(payload);
      this.pendingCalls.delete(callId);
    }
  }

  private generateCallId(): string {
    return `${this.moduleId}_${++this.callId}_${Date.now()}`;
  }

  async postMessage<T = any>(type: BridgeMessage['type'], payload: any): Promise<T> {
    const callId = this.generateCallId();
    return new Promise((resolve) => {
      this.pendingCalls.set(callId, resolve);
      const message: BridgeMessage = { type, callId, moduleId: this.moduleId, payload };
      if ((window as any).FlutterBridge?.postMessage) {
        (window as any).FlutterBridge.postMessage(JSON.stringify(message));
      } else {
        console.log('[FlutterBridge] Message:', message);
        resolve(undefined as T);
      }
    });
  }

  postMessageNoResponse(type: BridgeMessage['type'], payload: any): void {
    const callId = this.generateCallId();
    const message: BridgeMessage = { type, callId, moduleId: this.moduleId, payload };
    if ((window as any).FlutterBridge?.postMessage) {
      (window as any).FlutterBridge.postMessage(JSON.stringify(message));
    }
  }

  createStateProxy(): StateProxy {
    return {
      get: async <T>(key: string): Promise<T> => {
        const result = await this.postMessage('state.get', { key });
        return result?.value as T;
      },
      set: async <T>(key: string, value: T): Promise<void> => {
        await this.postMessage('state.set', { key, value });
      },
      update: async <T>(key: string, updater: (prev: T) => T): Promise<void> => {
        const current = await this.postMessage('state.get', { key });
        const next = updater(current?.value as T);
        await this.postMessage('state.set', { key, value: next });
      }
    };
  }

  createApiClient(): ApiClient {
    const request = async <T = any>(config: ApiRequestConfig): Promise<T> => {
      const response = await this.postMessage<{ data: T }>('api.request', {
        url: config.url,
        method: config.method ?? 'GET',
        headers: config.headers ?? {},
        body: config.body,
        useFlutterProxy: config.useFlutterProxy ?? true,
      });
      return response.data;
    };

    return {
      request,
      get: <T = any>(url: string, headers?: Record<string, string>) => 
        request<T>({ url, method: 'GET', headers }),
      post: <T = any>(url: string, body: any, headers?: Record<string, string>) => 
        request<T>({ url, method: 'POST', body, headers }),
      put: <T = any>(url: string, body: any, headers?: Record<string, string>) => 
        request<T>({ url, method: 'PUT', body, headers }),
      delete: <T = any>(url: string, headers?: Record<string, string>) => 
        request<T>({ url, method: 'DELETE', headers }),
    };
  }
}

export class FlutterBridge {
  private static instances: Map<string, ModuleBridge> = new Map();

  static getModule(moduleId: string): ModuleBridge {
    if (!this.instances.has(moduleId)) {
      this.instances.set(moduleId, new ModuleBridge(moduleId));
    }
    return this.instances.get(moduleId)!;
  }

  static hasModule(moduleId: string): boolean {
    return this.instances.has(moduleId);
  }

  static removeModule(moduleId: string): void {
    this.instances.delete(moduleId);
  }
}
