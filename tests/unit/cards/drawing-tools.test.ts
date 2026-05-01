import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  drawTrendline,
  drawFib,
  mountDrawingTools,
  FIB_LEVELS,
} from "../../../src/cards/drawing-tools";
import type { TrendlineDrawing, FibDrawing } from "../../../src/cards/drawing-tools";

// ──────────────────────────────────────────────────────────────
// Canvas mock helpers
// ──────────────────────────────────────────────────────────────

function makeCtx(): CanvasRenderingContext2D {
  return {
    save: vi.fn(),
    restore: vi.fn(),
    beginPath: vi.fn(),
    moveTo: vi.fn(),
    lineTo: vi.fn(),
    stroke: vi.fn(),
    fillText: vi.fn(),
    clearRect: vi.fn(),
    setLineDash: vi.fn(),
    strokeStyle: "",
    fillStyle: "",
    lineWidth: 1,
    globalAlpha: 1,
    font: "",
    textBaseline: "alphabetic",
  } as unknown as CanvasRenderingContext2D;
}

// ──────────────────────────────────────────────────────────────
// drawTrendline
// ──────────────────────────────────────────────────────────────

describe("drawTrendline", () => {
  it("calls moveTo and lineTo with correct coordinates", () => {
    const ctx = makeCtx();
    const d: TrendlineDrawing = {
      kind: "trendline",
      p1: { x: 10, y: 20 },
      p2: { x: 100, y: 80 },
      color: "#f59e0b",
    };
    drawTrendline(ctx, d);
    expect(ctx.moveTo).toHaveBeenCalledWith(10, 20);
    expect(ctx.lineTo).toHaveBeenCalledWith(100, 80);
    expect(ctx.stroke).toHaveBeenCalled();
  });

  it("saves and restores context state", () => {
    const ctx = makeCtx();
    const d: TrendlineDrawing = {
      kind: "trendline",
      p1: { x: 0, y: 0 },
      p2: { x: 1, y: 1 },
      color: "#fff",
    };
    drawTrendline(ctx, d);
    expect(ctx.save).toHaveBeenCalledOnce();
    expect(ctx.restore).toHaveBeenCalledOnce();
  });
});

// ──────────────────────────────────────────────────────────────
// drawFib
// ──────────────────────────────────────────────────────────────

describe("drawFib", () => {
  it("draws one line per Fibonacci level", () => {
    const ctx = makeCtx();
    const d: FibDrawing = {
      kind: "fib",
      high: { x: 50, y: 0 },
      low: { x: 50, y: 200 },
      color: "#6366f1",
    };
    drawFib(ctx, d, 400);
    // moveTo + lineTo per level
    expect(ctx.moveTo).toHaveBeenCalledTimes(FIB_LEVELS.length);
    expect(ctx.lineTo).toHaveBeenCalledTimes(FIB_LEVELS.length);
    expect(ctx.stroke).toHaveBeenCalledTimes(FIB_LEVELS.length);
  });

  it("places 0% line at high.y and 100% line at low.y", () => {
    const ctx = makeCtx();
    const d: FibDrawing = {
      kind: "fib",
      high: { x: 0, y: 50 },
      low: { x: 0, y: 300 },
      color: "#6366f1",
    };
    drawFib(ctx, d, 400);
    // First lineTo call should be at y=50 (0%), last at y=300 (100%)
    const calls = (ctx.moveTo as ReturnType<typeof vi.fn>).mock.calls;
    expect(calls[0]?.[1]).toBe(50); // 0% → y = high.y
    expect(calls[calls.length - 1]?.[1]).toBe(300); // 100% → y = low.y
  });

  it("saves and restores context state", () => {
    const ctx = makeCtx();
    const d: FibDrawing = {
      kind: "fib",
      high: { x: 0, y: 0 },
      low: { x: 0, y: 100 },
      color: "#fff",
    };
    drawFib(ctx, d, 100);
    expect(ctx.save).toHaveBeenCalledOnce();
    expect(ctx.restore).toHaveBeenCalledOnce();
  });
});

// ──────────────────────────────────────────────────────────────
// FIB_LEVELS constant
// ──────────────────────────────────────────────────────────────

describe("FIB_LEVELS", () => {
  it("starts at 0 and ends at 1", () => {
    expect(FIB_LEVELS[0]?.level).toBe(0);
    expect(FIB_LEVELS[FIB_LEVELS.length - 1]?.level).toBe(1);
  });

  it("contains the standard 61.8% level", () => {
    const levels = FIB_LEVELS.map((l) => l.level);
    expect(levels).toContain(0.618);
  });

  it("has 7 levels", () => {
    expect(FIB_LEVELS).toHaveLength(7);
  });
});

// ──────────────────────────────────────────────────────────────
// mountDrawingTools
// ──────────────────────────────────────────────────────────────

describe("mountDrawingTools", () => {
  let container: HTMLDivElement;
  let fakeCtx: CanvasRenderingContext2D;

  beforeEach(() => {
    fakeCtx = makeCtx();
    // happy-dom doesn't implement canvas; stub getContext globally
    vi.spyOn(HTMLCanvasElement.prototype, "getContext").mockReturnValue(
      fakeCtx as unknown as RenderingContext,
    );

    container = document.createElement("div");
    Object.defineProperty(container, "getBoundingClientRect", {
      value: () => ({ width: 400, height: 300, top: 0, left: 0, right: 400, bottom: 300 }),
      configurable: true,
    });
    document.body.appendChild(container);
  });

  afterEach(() => {
    container.remove();
    vi.restoreAllMocks();
  });

  it("appends a canvas child to the container", () => {
    const handle = mountDrawingTools(container);
    expect(container.querySelector("canvas")).not.toBeNull();
    handle.dispose();
  });

  it("dispose() removes the canvas", () => {
    const handle = mountDrawingTools(container);
    handle.dispose();
    expect(container.querySelector("canvas")).toBeNull();
  });

  it("getDrawings() starts empty", () => {
    const handle = mountDrawingTools(container);
    expect(handle.getDrawings()).toHaveLength(0);
    handle.dispose();
  });

  it("clearDrawings() empties the drawing list", () => {
    const handle = mountDrawingTools(container);
    handle.setTool("trendline");

    const canvas = container.querySelector("canvas")!;
    const rect = { width: 400, height: 300, top: 0, left: 0 };
    Object.defineProperty(canvas, "getBoundingClientRect", {
      value: () => rect,
      configurable: true,
    });

    // Simulate 2 clicks for a trendline
    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 20, bubbles: true }));
    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 100, clientY: 80, bubbles: true }));

    expect(handle.getDrawings()).toHaveLength(1);
    handle.clearDrawings();
    expect(handle.getDrawings()).toHaveLength(0);

    handle.dispose();
  });

  it("setTool('trendline') + 2 clicks adds a trendline drawing", () => {
    const handle = mountDrawingTools(container);
    handle.setTool("trendline");

    const canvas = container.querySelector("canvas")!;
    Object.defineProperty(canvas, "getBoundingClientRect", {
      value: () => ({ top: 0, left: 0 }),
      configurable: true,
    });

    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 20 }));
    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 100, clientY: 80 }));

    const drawings = handle.getDrawings();
    expect(drawings).toHaveLength(1);
    expect(drawings[0]?.kind).toBe("trendline");

    handle.dispose();
  });

  it("setTool('fib') + 2 clicks adds a fib drawing", () => {
    const handle = mountDrawingTools(container);
    handle.setTool("fib");

    const canvas = container.querySelector("canvas")!;
    Object.defineProperty(canvas, "getBoundingClientRect", {
      value: () => ({ top: 0, left: 0 }),
      configurable: true,
    });

    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 50, clientY: 10 }));
    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 50, clientY: 200 }));

    const drawings = handle.getDrawings();
    expect(drawings).toHaveLength(1);
    expect(drawings[0]?.kind).toBe("fib");

    handle.dispose();
  });

  it("setTool('none') prevents drawings from being added", () => {
    const handle = mountDrawingTools(container);
    handle.setTool("none");

    const canvas = container.querySelector("canvas")!;
    Object.defineProperty(canvas, "getBoundingClientRect", {
      value: () => ({ top: 0, left: 0 }),
      configurable: true,
    });

    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 10, clientY: 20 }));
    canvas.dispatchEvent(new MouseEvent("mousedown", { clientX: 100, clientY: 80 }));

    expect(handle.getDrawings()).toHaveLength(0);
    handle.dispose();
  });
});
