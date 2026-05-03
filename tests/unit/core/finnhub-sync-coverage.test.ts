/**
 * Coverage for finnhub-ws.ts (line 119 — non-string message) and
 * sync-queue.ts (lines 52, 62 — enqueue with body+headers, headers-only).
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import { createFinnhubStream } from "../../../src/core/finnhub-ws";
import { createSyncQueue } from "../../../src/core/sync-queue";
import type { IDB } from "../../../src/core/idb";

// ── Finnhub WS mock ────────────────────────────────────────────────────────

class MockWebSocket {
  static instances: MockWebSocket[] = [];
  readyState = 0;
  url: string;
  private listeners: Record<string, Array<(e?: unknown) => void>> = {};

  constructor(url: string) {
    this.url = url;
    MockWebSocket.instances.push(this);
    setTimeout(() => {
      this.readyState = 1;
      this.emit("open", {});
    }, 0);
  }

  addEventListener = (type: string, cb: (e?: unknown) => void): void => {
    if (!this.listeners[type]) this.listeners[type] = [];
    this.listeners[type]!.push(cb);
  };

  removeEventListener = vi.fn();
  send = vi.fn();
  close = vi.fn(() => {
    this.readyState = 3;
    this.emit("close", {});
  });

  private emit(type: string, e: unknown): void {
    for (const cb of this.listeners[type] ?? []) cb(e);
  }

  simulateMessage(data: unknown): void {
    this.emit("message", { data });
  }
}

describe("finnhub-ws coverage — non-string message (line 119)", () => {
  beforeEach(() => {
    MockWebSocket.instances = [];
    vi.useFakeTimers();
  });

  it("ignores non-string message data", async () => {
    const tradeCb = vi.fn();
    const stream = createFinnhubStream({
      apiKey: "test",
      tickers: ["AAPL"],
      WebSocketImpl: MockWebSocket as unknown as typeof WebSocket,
    });
    stream.onTrade(tradeCb);

    await vi.advanceTimersByTimeAsync(10);
    const ws = MockWebSocket.instances[0]!;

    // Send non-string data (ArrayBuffer)
    ws.simulateMessage(new ArrayBuffer(8));
    expect(tradeCb).not.toHaveBeenCalled();

    // Send null
    ws.simulateMessage(null);
    expect(tradeCb).not.toHaveBeenCalled();

    stream.destroy();
    vi.useRealTimers();
  });

  it("ignores malformed JSON message", async () => {
    const tradeCb = vi.fn();
    const stream = createFinnhubStream({
      apiKey: "test",
      WebSocketImpl: MockWebSocket as unknown as typeof WebSocket,
    });
    stream.onTrade(tradeCb);

    await vi.advanceTimersByTimeAsync(10);
    const ws = MockWebSocket.instances[0]!;

    ws.simulateMessage("not json {{{");
    expect(tradeCb).not.toHaveBeenCalled();

    stream.destroy();
    vi.useRealTimers();
  });
});

// ── Sync queue mock IDB ────────────────────────────────────────────────────

function createMockDB(): IDB {
  const store = new Map<string, unknown>();
  return {
    get: async <T>(key: string): Promise<T | undefined> => store.get(key) as T | undefined,
    set: async (key: string, value: unknown): Promise<void> => {
      store.set(key, value);
    },
    delete: async (key: string): Promise<void> => {
      store.delete(key);
    },
    keys: async (): Promise<string[]> => [...store.keys()],
    clear: async (): Promise<void> => {
      store.clear();
    },
  } as IDB;
}

describe("sync-queue coverage — enqueue body+headers and headers-only (lines 52, 62)", () => {
  let db: IDB;

  beforeEach(() => {
    db = createMockDB();
  });

  it("enqueue stores body + headers when both present (line 52)", async () => {
    const q = await createSyncQueue({ db });
    const id = await q.enqueue({
      url: "https://api.example.com/sync",
      method: "POST",
      body: '{"key":"value"}',
      headers: { "Content-Type": "application/json", Authorization: "Bearer xyz" },
    });
    expect(id).toBeGreaterThan(0);
    const items = await q.list();
    expect(items).toHaveLength(1);
    expect(items[0]!.body).toBe('{"key":"value"}');
    expect(items[0]!.headers).toEqual({
      "Content-Type": "application/json",
      Authorization: "Bearer xyz",
    });
  });

  it("enqueue stores headers only (no body) (line 62)", async () => {
    const q = await createSyncQueue({ db });
    const id = await q.enqueue({
      url: "https://api.example.com/check",
      method: "GET",
      headers: { Authorization: "Bearer abc" },
    });
    expect(id).toBeGreaterThan(0);
    const items = await q.list();
    expect(items).toHaveLength(1);
    expect(items[0]!.body).toBeUndefined();
    expect(items[0]!.headers).toEqual({ Authorization: "Bearer abc" });
  });
});
