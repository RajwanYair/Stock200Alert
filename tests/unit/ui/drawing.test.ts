import { describe, it, expect } from "vitest";
import {
  emptyDrawingState,
  addShape,
  removeShape,
  updateShape,
  hitTest,
  fibLevelPrice,
  DEFAULT_FIB_LEVELS,
  type Shape,
} from "../../../src/ui/drawing";

const trend = (id: string): Shape => ({
  id,
  kind: "trendline",
  a: { x: 0, y: 0 },
  b: { x: 100, y: 100 },
});

describe("drawing", () => {
  it("emptyDrawingState has no shapes", () => {
    expect(emptyDrawingState().shapes).toEqual([]);
  });

  it("addShape appends", () => {
    const s = addShape(emptyDrawingState(), trend("a"));
    expect(s.shapes).toHaveLength(1);
    expect(s.shapes[0]!.id).toBe("a");
  });

  it("removeShape filters", () => {
    let s = addShape(emptyDrawingState(), trend("a"));
    s = addShape(s, trend("b"));
    s = removeShape(s, "a");
    expect(s.shapes.map((x) => x.id)).toEqual(["b"]);
  });

  it("updateShape patches matching id", () => {
    let s = addShape(emptyDrawingState(), trend("a"));
    s = updateShape(s, "a", { color: "red" });
    expect(s.shapes[0]!.color).toBe("red");
  });

  it("hitTest finds horizontal line within tolerance", () => {
    const s = addShape(emptyDrawingState(), {
      id: "h",
      kind: "hline",
      y: 100,
    });
    expect(hitTest(s, 5, 102)).toBe("h");
    expect(hitTest(s, 5, 200)).toBeNull();
  });

  it("hitTest finds trendline along the diagonal", () => {
    const s = addShape(emptyDrawingState(), trend("t"));
    // (50, 50) is on the line.
    expect(hitTest(s, 50, 50)).toBe("t");
    // Far from line.
    expect(hitTest(s, 0, 100)).toBeNull();
  });

  it("hitTest returns topmost shape", () => {
    let s = addShape(emptyDrawingState(), { id: "h1", kind: "hline", y: 50 });
    s = addShape(s, { id: "h2", kind: "hline", y: 50 });
    expect(hitTest(s, 0, 50)).toBe("h2");
  });

  it("hitTest matches fib level lines within range", () => {
    const fib: Shape = {
      id: "f",
      kind: "fib",
      start: { x: 0, y: 100 },
      end: { x: 100, y: 200 },
      levels: DEFAULT_FIB_LEVELS,
    };
    const s = addShape(emptyDrawingState(), fib);
    // 0.5 level => y = 150 between x in [0, 100]
    expect(hitTest(s, 50, 150)).toBe("f");
    // outside x-range
    expect(hitTest(s, -10, 150)).toBeNull();
  });

  it("fibLevelPrice interpolates", () => {
    const fib = {
      id: "f",
      kind: "fib" as const,
      start: { x: 0, y: 100 },
      end: { x: 100, y: 200 },
      levels: DEFAULT_FIB_LEVELS,
    };
    expect(fibLevelPrice(fib, 0)).toBe(100);
    expect(fibLevelPrice(fib, 1)).toBe(200);
    expect(fibLevelPrice(fib, 0.5)).toBe(150);
  });

  it("hitTest returns null for empty state", () => {
    expect(hitTest(emptyDrawingState(), 0, 0)).toBeNull();
  });
});
