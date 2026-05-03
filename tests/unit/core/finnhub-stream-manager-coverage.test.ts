/**
 * Coverage for finnhub-stream-manager.ts — empty key, localStorage throw, no-stream setTickers.
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import { createStreamManager } from "../../../src/core/finnhub-stream-manager";

// Minimal MockWebSocket for tests
class MockWebSocket {
  static CONNECTING = 0;
  static OPEN = 1;
  static CLOSING = 2;
  static CLOSED = 3;
  readyState = MockWebSocket.CONNECTING;
  url: string;
  sent: string[] = [];
  private listeners = new Map<string, Array<(e: Event) => void>>();
  constructor(url: string) {
    this.url = url;
  }
  send(data: string): void {
    this.sent.push(data);
  }
  close(): void {
    this.readyState = MockWebSocket.CLOSED;
    for (const cb of this.listeners.get("close") ?? []) cb({ type: "close" } as Event);
  }
  addEventListener(event: string, cb: (e: Event) => void): void {
    const list = this.listeners.get(event) ?? [];
    list.push(cb);
    this.listeners.set(event, list);
  }
  removeEventListener(): void {}
  simulateOpen(): void {
    this.readyState = MockWebSocket.OPEN;
    for (const cb of this.listeners.get("open") ?? []) cb({ type: "open" } as Event);
  }
}

let lastWs: MockWebSocket | null = null;
function MockWSImpl(url: string): MockWebSocket {
  lastWs = new MockWebSocket(url);
  return lastWs;
}

afterEach(() => {
  vi.restoreAllMocks();
});

describe("finnhub-stream-manager coverage — uncovered branches", () => {
  it("start with empty apiKey does nothing (line 90-91)", () => {
    const mgr = createStreamManager({ WebSocketImpl: MockWSImpl as unknown as typeof WebSocket });
    const statuses: string[] = [];
    mgr.onStatusChange((s) => statuses.push(s));
    mgr.start("", ["AAPL"]);
    expect(mgr.getStatus()).toBe("idle");
    expect(mgr.isActive()).toBe(false);
    expect(lastWs).toBeNull();
  });

  it("start with whitespace-only apiKey does nothing", () => {
    const mgr = createStreamManager({ WebSocketImpl: MockWSImpl as unknown as typeof WebSocket });
    mgr.start("   ", ["AAPL"]);
    expect(mgr.isActive()).toBe(false);
    expect(lastWs).toBeNull();
  });

  it("setTickers without active stream only updates internal state (line 121)", () => {
    const mgr = createStreamManager({ WebSocketImpl: MockWSImpl as unknown as typeof WebSocket });
    // setTickers before start — no stream exists
    mgr.setTickers(["AAPL", "GOOG"]);
    expect(mgr.isActive()).toBe(false);
    // Now start with a key — should subscribe to the updated tickers
    mgr.start("key", ["AAPL", "GOOG"]);
    lastWs!.simulateOpen();
    const subs = lastWs!.sent
      .map((s) => JSON.parse(s) as Record<string, unknown>)
      .filter((m) => m["type"] === "subscribe")
      .map((m) => m["symbol"]);
    expect(subs).toContain("AAPL");
    expect(subs).toContain("GOOG");
  });

  it("localStorage.setItem throwing does not crash start (line 94-96)", () => {
    const throwingStorage = {
      getItem: () => null,
      setItem: () => {
        throw new DOMException("QuotaExceeded");
      },
      removeItem: () => undefined,
    };
    vi.stubGlobal("localStorage", throwingStorage);

    const mgr = createStreamManager({ WebSocketImpl: MockWSImpl as unknown as typeof WebSocket });
    // Should not throw
    mgr.start("valid-key", ["AAPL"]);
    expect(mgr.isActive()).toBe(true);
    expect(mgr.getStatus()).toBe("connecting");
  });
});
