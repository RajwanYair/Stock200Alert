/**
 * Coverage for chart-sync.ts — subscribeCrosshairMove callback body (lines 94-97).
 * Targets:
 *   Line 94: `if (isSyncing) return;`
 *   Line 96: `const time = ...`
 *   Line 97: `bus.publish(chartId, time ?? null)`
 */
import { describe, it, expect, vi } from "vitest";
import { createChartSyncBus, wireCrosshairSync } from "../../../src/ui/chart-sync";

describe("chart-sync coverage — crosshairMove callback (lines 94-97)", () => {
  it("crosshairMove callback publishes time to bus (line 96-97)", () => {
    const bus = createChartSyncBus();
    const publishSpy = vi.spyOn(bus, "publish");

    let capturedCallback: ((param: unknown) => void) | null = null;
    const mockChart = {
      subscribeCrosshairMove: (cb: (param: unknown) => void): (() => void) => {
        capturedCallback = cb;
        return (): void => undefined;
      },
      setCrosshairPosition: vi.fn(),
      clearCrosshairPosition: vi.fn(),
    };

    wireCrosshairSync("chartA", mockChart, {}, bus);
    expect(capturedCallback).not.toBeNull();

    // Simulate crosshair move with a time value
    capturedCallback!({ time: "2025-03-10" });
    expect(publishSpy).toHaveBeenCalledWith("chartA", "2025-03-10");
  });

  it("crosshairMove callback publishes null when time is undefined (line 97 ?? null)", () => {
    const bus = createChartSyncBus();
    const publishSpy = vi.spyOn(bus, "publish");

    let capturedCallback: ((param: unknown) => void) | null = null;
    const mockChart = {
      subscribeCrosshairMove: (cb: (param: unknown) => void): (() => void) => {
        capturedCallback = cb;
        return (): void => undefined;
      },
      setCrosshairPosition: vi.fn(),
      clearCrosshairPosition: vi.fn(),
    };

    wireCrosshairSync("chartB", mockChart, {}, bus);

    // Simulate crosshair leave (no time)
    capturedCallback!({ time: undefined });
    expect(publishSpy).toHaveBeenCalledWith("chartB", null);

    publishSpy.mockClear();

    // Null param
    capturedCallback!(null);
    expect(publishSpy).toHaveBeenCalledWith("chartB", null);
  });

  it("isSyncing guard prevents re-entrant publish (line 94)", () => {
    const bus = createChartSyncBus();
    const publishSpy = vi.spyOn(bus, "publish");

    let capturedCallback: ((param: unknown) => void) | null = null;

    // setCrosshairPosition simulates chart firing a crosshairMove event re-entrantly
    const mockChart = {
      subscribeCrosshairMove: (cb: (param: unknown) => void): (() => void) => {
        capturedCallback = cb;
        return (): void => undefined;
      },
      setCrosshairPosition: vi.fn().mockImplementation((): void => {
        // During setCrosshairPosition, the chart fires a crosshairMove — isSyncing is true
        capturedCallback!({ time: "re-entrant" });
      }),
      clearCrosshairPosition: vi.fn(),
    };

    // Register another chart so bus.publish("chartC") triggers setCrosshair on chartD
    wireCrosshairSync("chartD", mockChart, {}, bus);
    publishSpy.mockClear(); // clear any publish from wireCrosshairSync itself

    // Subscribe chart C as the sender; publish from C triggers setCrosshair on D
    const cbC = vi.fn();
    bus.subscribe("chartC", { setCrosshair: cbC });

    // Publish from C — this calls chartD's setCrosshair which sets isSyncing=true,
    // calls setCrosshairPosition, which fires capturedCallback re-entrantly.
    // The re-entrant call should hit line 94 and return early (no publish).
    publishSpy.mockClear();
    bus.publish("chartC", "2025-06-01");

    // The re-entrant crosshairMove call should NOT have triggered another bus.publish
    // (it returned early due to isSyncing guard)
    const reentrantCalls = publishSpy.mock.calls.filter(([, time]) => time === "re-entrant");
    expect(reentrantCalls).toHaveLength(0);
  });
});
