/**
 * Coverage for sw-update.ts — onUpdateFound when installing is null but waiting is set.
 * Targets lines 61-62: the `if (!w)` early-return path inside onUpdateFound.
 */
import { describe, it, expect, vi } from "vitest";
import { watchServiceWorkerUpdates } from "../../../src/core/sw-update";

interface FakeWorker {
  state: ServiceWorkerState;
  postMessage: (msg: unknown) => void;
  addEventListener: (type: "statechange", listener: () => void) => void;
}

function makeWorker(state: ServiceWorkerState = "installed"): FakeWorker {
  return {
    state,
    postMessage: vi.fn(),
    addEventListener: vi.fn(),
  };
}

interface FakeReg {
  waiting: FakeWorker | null;
  installing: FakeWorker | null;
  active: FakeWorker | null;
  update: () => Promise<void>;
  addEventListener: (type: "updatefound", listener: () => void) => void;
  _emitUpdateFound: () => void;
}

function makeReg(): FakeReg {
  let listener: (() => void) | null = null;
  return {
    waiting: null,
    installing: null,
    active: null,
    update: vi.fn().mockResolvedValue(undefined),
    addEventListener: (_t, l): void => {
      listener = l;
    },
    _emitUpdateFound: (): void => listener?.(),
  };
}

describe("sw-update coverage — onUpdateFound null-installing paths", () => {
  it("fires when updatefound is emitted and installing is null but waiting is set", () => {
    // Line 61: if (registration.waiting) fire();
    // Line 62: return;
    const reg = makeReg();
    reg.installing = null; // no installing worker
    reg.waiting = makeWorker("installed"); // but waiting worker exists

    const ready = vi.fn();
    const dispose = watchServiceWorkerUpdates(
      reg as unknown as Parameters<typeof watchServiceWorkerUpdates>[0],
      { onUpdateReady: ready },
    );

    // ready fires once from the initial `if (registration.waiting) fire()` check
    expect(ready).toHaveBeenCalledTimes(1);
    ready.mockClear();

    // Emit updatefound — installing is null, so we enter the `if (!w)` branch
    reg._emitUpdateFound();

    // Already notified=true from the initial call, so no second notification
    expect(ready).not.toHaveBeenCalled();
    dispose();
  });

  it("does not double-notify when updatefound fires a second time after initial fire", () => {
    const reg = makeReg();
    reg.waiting = makeWorker("installed");

    const ready = vi.fn();
    const dispose = watchServiceWorkerUpdates(
      reg as unknown as Parameters<typeof watchServiceWorkerUpdates>[0],
      { onUpdateReady: ready },
    );

    // First notification from initial check
    expect(ready).toHaveBeenCalledTimes(1);

    // Emit updatefound with null installing — enters the if (!w) branch
    // notified=true so fire() returns without calling onUpdateReady again
    reg._emitUpdateFound();
    expect(ready).toHaveBeenCalledTimes(1); // still just once
    dispose();
  });

  it("returns early (no fire) when updatefound fires and both installing and waiting are null", () => {
    const reg = makeReg();
    // installing=null, waiting=null

    const ready = vi.fn();
    const dispose = watchServiceWorkerUpdates(
      reg as unknown as Parameters<typeof watchServiceWorkerUpdates>[0],
      { onUpdateReady: ready },
    );

    reg._emitUpdateFound(); // !w is true, waiting is null → just return
    expect(ready).not.toHaveBeenCalled();
    dispose();
  });
});
