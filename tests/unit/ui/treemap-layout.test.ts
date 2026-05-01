import { describe, it, expect } from "vitest";
import { squarifyTreemap } from "../../../src/ui/treemap-layout";

const BOUNDS = { x: 0, y: 0, width: 600, height: 400 };

describe("treemap-layout", () => {
  it("empty input produces no rects", () => {
    expect(squarifyTreemap([], BOUNDS)).toEqual([]);
  });

  it("ignores zero/negative values", () => {
    const out = squarifyTreemap(
      [
        { id: "a", value: 10 },
        { id: "b", value: 0 },
        { id: "c", value: -5 },
      ],
      BOUNDS,
    );
    expect(out.length).toBe(1);
    expect(out[0]!.id).toBe("a");
  });

  it("single item fills bounds", () => {
    const [r] = squarifyTreemap([{ id: "a", value: 100 }], BOUNDS);
    expect(r!.x).toBe(0);
    expect(r!.y).toBe(0);
    expect(r!.width).toBe(600);
    expect(r!.height).toBe(400);
  });

  it("areas are proportional to value", () => {
    const out = squarifyTreemap(
      [
        { id: "a", value: 60 },
        { id: "b", value: 30 },
        { id: "c", value: 10 },
      ],
      BOUNDS,
    );
    const totalArea = BOUNDS.width * BOUNDS.height;
    const sumArea = out.reduce((s, r) => s + r.width * r.height, 0);
    expect(sumArea).toBeCloseTo(totalArea, 5);
    const a = out.find((r) => r.id === "a")!;
    const c = out.find((r) => r.id === "c")!;
    expect(a.width * a.height).toBeCloseTo(totalArea * 0.6, 5);
    expect(c.width * c.height).toBeCloseTo(totalArea * 0.1, 5);
  });

  it("rects fit within bounds", () => {
    const out = squarifyTreemap(
      Array.from({ length: 8 }, (_, i) => ({ id: `n${i}`, value: i + 1 })),
      BOUNDS,
    );
    for (const r of out) {
      expect(r.x).toBeGreaterThanOrEqual(BOUNDS.x - 1e-9);
      expect(r.y).toBeGreaterThanOrEqual(BOUNDS.y - 1e-9);
      expect(r.x + r.width).toBeLessThanOrEqual(BOUNDS.x + BOUNDS.width + 1e-9);
      expect(r.y + r.height).toBeLessThanOrEqual(BOUNDS.y + BOUNDS.height + 1e-9);
    }
  });

  it("preserves ids and values", () => {
    const items = [
      { id: "x", value: 5 },
      { id: "y", value: 5 },
    ];
    const out = squarifyTreemap(items, BOUNDS);
    expect(out.map((r) => r.id).sort()).toEqual(["x", "y"]);
    expect(out.map((r) => r.value).sort()).toEqual([5, 5]);
  });

  it("handles many items without crash", () => {
    const items = Array.from({ length: 50 }, (_, i) => ({
      id: `t${i}`,
      value: Math.random() * 100 + 1,
    }));
    const out = squarifyTreemap(items, BOUNDS);
    expect(out.length).toBe(50);
  });
});
