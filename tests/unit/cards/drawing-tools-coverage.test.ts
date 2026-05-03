/**
 * Additional coverage tests for src/cards/drawing-tools.ts
 * Targets uncovered lines 139-144: no-op handle returned when canvas 2D context is unavailable.
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import { mountDrawingTools } from "../../../src/cards/drawing-tools";

afterEach(() => {
  vi.restoreAllMocks();
});

describe("mountDrawingTools — null canvas context no-op handle (lines 139-144)", () => {
  it("returns a no-op handle when getContext returns null", () => {
    // Force getContext("2d") to return null — covers the no-op return branch
    vi.spyOn(HTMLCanvasElement.prototype, "getContext").mockReturnValue(null);

    const container = document.createElement("div");
    document.body.appendChild(container);

    const handle = mountDrawingTools(container);

    // Canvas is removed from container in the null-ctx path
    expect(container.querySelector("canvas")).toBeNull();

    // All handle methods are no-ops and do not throw
    expect(() => handle.setTool("trendline")).not.toThrow();
    expect(() => handle.setTool("fib")).not.toThrow();
    expect(() => handle.setTool("none")).not.toThrow();
    expect(() => handle.clearDrawings()).not.toThrow();
    expect(handle.getDrawings()).toEqual([]);
    expect(() => handle.dispose()).not.toThrow();

    container.remove();
  });

  it("no-op setTool returns undefined (not a promise or value)", () => {
    vi.spyOn(HTMLCanvasElement.prototype, "getContext").mockReturnValue(null);

    const container = document.createElement("div");
    document.body.appendChild(container);

    const handle = mountDrawingTools(container);
    const result = handle.setTool("fib");
    expect(result).toBeUndefined();

    container.remove();
  });
});
