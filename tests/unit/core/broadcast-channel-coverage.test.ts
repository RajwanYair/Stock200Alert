/**
 * Coverage for broadcast-channel.ts — error handling branches.
 * Targets:
 *   Line 79: console.error when a config-change handler throws
 *   Line 99: console.warn when channel.postMessage throws (channel closed)
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { createCrossTabSync } from "../../../src/core/broadcast-channel";

// ── BroadcastChannel mock ────────────────────────────────────────────────────

type MsgListener = (ev: MessageEvent) => void;

class MockBroadcastChannel {
  static channels = new Map<string, Set<MockBroadcastChannel>>();

  private listeners = new Set<MsgListener>();
  closed = false;

  constructor(readonly name: string) {
    let set = MockBroadcastChannel.channels.get(name);
    if (!set) {
      set = new Set();
      MockBroadcastChannel.channels.set(name, set);
    }
    set.add(this);
  }

  addEventListener(_type: string, listener: MsgListener): void {
    this.listeners.add(listener);
  }

  removeEventListener(_type: string, listener: MsgListener): void {
    this.listeners.delete(listener);
  }

  postMessage(data: unknown): void {
    if (this.closed) throw new DOMException("Channel closed", "InvalidStateError");
    const peers = MockBroadcastChannel.channels.get(this.name) ?? new Set();
    for (const peer of peers) {
      if (peer !== this && !peer.closed) {
        const ev = { data } as MessageEvent;
        for (const listener of peer.listeners) {
          listener(ev);
        }
      }
    }
  }

  close(): void {
    this.closed = true;
    MockBroadcastChannel.channels.get(this.name)?.delete(this);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

describe("broadcast-channel coverage — error branches", () => {
  beforeEach(() => {
    MockBroadcastChannel.channels.clear();
    vi.stubGlobal("BroadcastChannel", MockBroadcastChannel);
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it("logs console.error and continues when a config-change handler throws (line 79)", () => {
    // Line 79: console.error("[CrossTabSync] config-change handler threw:", err)
    const consoleError = vi.spyOn(console, "error").mockImplementation(() => undefined);

    const tab1 = createCrossTabSync();
    const tab2 = createCrossTabSync();

    // Register a handler that throws
    tab2.onConfigChange(() => {
      throw new Error("handler boom");
    });

    // Should not throw — error is caught internally
    expect(() => tab1.broadcastConfig({ x: 1 })).not.toThrow();
    expect(consoleError).toHaveBeenCalledWith(
      "[CrossTabSync] config-change handler threw:",
      expect.any(Error),
    );

    tab1.destroy();
    tab2.destroy();
  });

  it("logs console.warn and does not throw when postMessage fails (line 99)", () => {
    // Line 99: console.warn("[CrossTabSync] postMessage failed:", err)
    const consoleWarn = vi.spyOn(console, "warn").mockImplementation(() => undefined);

    const tab1 = createCrossTabSync();
    // Destroy closes the BroadcastChannel — subsequent postMessage throws
    tab1.destroy();

    // Should not throw — error is caught internally
    expect(() => tab1.broadcastConfig({ y: 2 })).not.toThrow();
    expect(consoleWarn).toHaveBeenCalledWith(
      "[CrossTabSync] postMessage failed:",
      expect.any(Error),
    );
  });
});
