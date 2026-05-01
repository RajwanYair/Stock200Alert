/**
 * Provider health monitor tests — verify state transition detection.
 */
import { describe, it, expect, beforeEach, vi } from "vitest";
import {
  classifyHealth,
  checkHealthTransition,
  resetHealthMonitor,
} from "../../../src/cards/provider-health-monitor";
import type { ProviderHealthSnapshot } from "../../../src/cards/provider-health";

// Mock notifications so no actual browser API calls are made
vi.mock("../../../src/core/notifications", () => ({
  showNotification: vi.fn(),
}));

function makeSnapshot(
  providers: Array<{ name: string; available: boolean }>,
): ProviderHealthSnapshot {
  return {
    providers: providers.map((p) => ({
      name: p.name,
      available: p.available,
      lastSuccessAt: p.available ? Date.now() : null,
      lastErrorAt: p.available ? null : Date.now(),
      consecutiveErrors: p.available ? 0 : 3,
    })),
    lastRefreshAt: Date.now(),
  };
}

describe("classifyHealth", () => {
  it("returns 'healthy' when all providers are up", () => {
    const snap = makeSnapshot([
      { name: "Yahoo", available: true },
      { name: "Finnhub", available: true },
    ]);
    expect(classifyHealth(snap)).toBe("healthy");
  });

  it("returns 'degraded' when some providers are down", () => {
    const snap = makeSnapshot([
      { name: "Yahoo", available: true },
      { name: "Finnhub", available: false },
    ]);
    expect(classifyHealth(snap)).toBe("degraded");
  });

  it("returns 'down' when all providers are down", () => {
    const snap = makeSnapshot([
      { name: "Yahoo", available: false },
      { name: "Finnhub", available: false },
    ]);
    expect(classifyHealth(snap)).toBe("down");
  });

  it("returns 'unknown' when no providers exist", () => {
    const snap = makeSnapshot([]);
    expect(classifyHealth(snap)).toBe("unknown");
  });
});

describe("checkHealthTransition", () => {
  beforeEach(() => {
    resetHealthMonitor();
    document.body.innerHTML = "";
  });

  it("does not fire notification on first check (unknown → healthy)", () => {
    const snap = makeSnapshot([
      { name: "Yahoo", available: true },
      { name: "Finnhub", available: true },
    ]);
    const status = checkHealthTransition(snap);
    expect(status).toBe("healthy");
  });

  it("fires degradation alert on healthy → degraded", () => {
    // First call: establish healthy baseline
    checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: true },
        { name: "Finnhub", available: true },
      ]),
    );

    // Second call: Finnhub goes down
    const status = checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: true },
        { name: "Finnhub", available: false },
      ]),
    );
    expect(status).toBe("degraded");
    // Toast should be in DOM
    const toast = document.querySelector(".toast-health");
    expect(toast).not.toBeNull();
    expect(toast!.textContent).toContain("Degraded");
  });

  it("fires all-down alert on degraded → down", () => {
    checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: true },
        { name: "Finnhub", available: false },
      ]),
    );

    const status = checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: false },
        { name: "Finnhub", available: false },
      ]),
    );
    expect(status).toBe("down");
    const toasts = document.querySelectorAll(".toast-health");
    expect(toasts.length).toBeGreaterThan(0);
  });

  it("fires recovery alert on down → healthy", () => {
    // Establish down state
    checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: false },
        { name: "Finnhub", available: false },
      ]),
    );

    // Recover
    const status = checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: true },
        { name: "Finnhub", available: true },
      ]),
    );
    expect(status).toBe("healthy");
    const toasts = document.querySelectorAll(".toast-health");
    expect(toasts.length).toBeGreaterThan(0);
  });

  it("does not fire when status stays the same", () => {
    checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: true },
        { name: "Finnhub", available: true },
      ]),
    );

    checkHealthTransition(
      makeSnapshot([
        { name: "Yahoo", available: true },
        { name: "Finnhub", available: true },
      ]),
    );
    // No toast since status didn't change
    const toasts = document.querySelectorAll(".toast-health");
    expect(toasts.length).toBe(0);
  });
});
