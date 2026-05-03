/**
 * Coverage for multi-chart-layout.ts — crosshair sync handlers (lines 326-347).
 * Tests mousemove/mouseleave dispatching bus.publish and setCrosshair callback.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import multiChartLayoutCard from "../../../src/cards/multi-chart-layout";

interface CrosshairSub {
  setCrosshair(time: string | null): void;
}

const subscriptions: Array<{ channel: string; subscriber: CrosshairSub }> = [];
const publishCalls: Array<{ channel: string; value: string | null }> = [];

vi.mock("../../../src/ui/chart-sync", () => ({
  getGlobalChartSyncBus: () => ({
    subscribe: vi.fn((channel: string, subscriber: CrosshairSub) => {
      subscriptions.push({ channel, subscriber });
    }),
    unsubscribe: vi.fn(),
    publish: vi.fn((channel: string, value: string | null) => {
      publishCalls.push({ channel, value });
    }),
    clear: vi.fn(),
  }),
}));

vi.mock("../../../src/core/config", () => ({
  loadConfig: () => ({
    theme: "dark",
    watchlist: [
      { ticker: "AAPL", addedAt: "2024-01-01" },
      { ticker: "MSFT", addedAt: "2024-01-01" },
    ],
  }),
}));

function storageMock(): Storage {
  const store: Record<string, string> = {};
  return {
    getItem: (k: string) => store[k] ?? null,
    setItem: (k: string, v: string) => {
      store[k] = v;
    },
    removeItem: (k: string) => {
      delete store[k];
    },
    clear: () => {
      Object.keys(store).forEach((k) => delete store[k]);
    },
    key: (i: number) => Object.keys(store)[i] ?? null,
    get length() {
      return Object.keys(store).length;
    },
  };
}

describe("multi-chart-layout coverage — crosshair sync (lines 326-347)", () => {
  let container: HTMLDivElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
    subscriptions.length = 0;
    publishCalls.length = 0;

    const storage = storageMock();
    // Pre-populate prices for AAPL so SVG renders
    const prices = Array.from({ length: 10 }, (_, i) => ({
      date: `2024-01-${String(i + 1).padStart(2, "0")}`,
      close: 150 + i,
    }));
    storage.setItem("crosstide-cache-AAPL", JSON.stringify(prices));
    storage.setItem(
      "crosstide-multi-chart",
      JSON.stringify({ layout: "2x2", tickers: ["AAPL", "", "", ""] }),
    );
    vi.stubGlobal("localStorage", storage);
  });

  afterEach(() => {
    container.remove();
    vi.unstubAllGlobals();
  });

  it("mousemove on SVG publishes x position (line 328)", () => {
    multiChartLayoutCard.mount(container, { route: "multi-chart", params: {} });

    const svg = container.querySelector<SVGElement>("svg.multi-chart-svg");
    expect(svg).not.toBeNull();

    // Mock getBoundingClientRect
    vi.spyOn(svg!, "getBoundingClientRect").mockReturnValue({
      left: 0,
      top: 0,
      right: 280,
      bottom: 120,
      width: 280,
      height: 120,
      x: 0,
      y: 0,
      toJSON: () => ({}),
    });

    svg!.dispatchEvent(new MouseEvent("mousemove", { clientX: 140, clientY: 60 }));

    expect(publishCalls.length).toBeGreaterThan(0);
    const lastCall = publishCalls[publishCalls.length - 1]!;
    expect(lastCall.value).not.toBeNull();
    // x = (140 - 0)/280 * 280 = 140
    expect(Number(lastCall.value)).toBeCloseTo(140, 0);
  });

  it("mouseleave on SVG publishes null (line 332)", () => {
    multiChartLayoutCard.mount(container, { route: "multi-chart", params: {} });

    const svg = container.querySelector<SVGElement>("svg.multi-chart-svg");
    expect(svg).not.toBeNull();

    svg!.dispatchEvent(new MouseEvent("mouseleave"));

    const leaveCall = publishCalls.find((c) => c.value === null);
    expect(leaveCall).toBeDefined();
  });

  it("setCrosshair sets crosshair line position (lines 338-344)", () => {
    multiChartLayoutCard.mount(container, { route: "multi-chart", params: {} });

    // Should have registered at least one subscription
    expect(subscriptions.length).toBeGreaterThan(0);

    const crosshairLine = container.querySelector<SVGLineElement>(".mc-crosshair-line");
    expect(crosshairLine).not.toBeNull();

    // Call setCrosshair with a value
    subscriptions[0]!.subscriber.setCrosshair("140");
    expect(crosshairLine!.getAttribute("x1")).toBe("140");
    expect(crosshairLine!.getAttribute("x2")).toBe("140");
    expect(crosshairLine!.getAttribute("opacity")).toBe("0.6");

    // Call setCrosshair with null → opacity = 0
    subscriptions[0]!.subscriber.setCrosshair(null);
    expect(crosshairLine!.getAttribute("opacity")).toBe("0");
  });
});
