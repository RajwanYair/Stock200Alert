/**
 * Coverage for heatmap-layout.ts — vertical placeRow branch (lines 89-104).
 * A tall narrow bounds forces `frame.w < frame.h` → vertical placement.
 */
import { describe, it, expect } from "vitest";
import { computeHeatmap, type HeatmapItem } from "../../../src/cards/heatmap-layout";

describe("heatmap-layout coverage — vertical placement (lines 89-104)", () => {
  it("uses vertical stacking for tall narrow bounds", () => {
    // Width 20 × Height 200 → frame is taller than wide → else branch
    const items: HeatmapItem[] = [
      { ticker: "A", weight: 50, changePct: 1 },
      { ticker: "B", weight: 30, changePct: -1 },
      { ticker: "C", weight: 20, changePct: 0 },
    ];
    const bounds = { x: 0, y: 0, width: 20, height: 200 };
    const rects = computeHeatmap(items, bounds);

    // Should produce rectangles
    expect(rects.length).toBeGreaterThan(0);

    // All rects within bounds
    for (const r of rects) {
      expect(r.x).toBeGreaterThanOrEqual(0);
      expect(r.y).toBeGreaterThanOrEqual(0);
      expect(r.x + r.w).toBeLessThanOrEqual(20 + 1e-6);
      expect(r.y + r.h).toBeLessThanOrEqual(200 + 1e-6);
    }

    // Total area conserved
    const totalArea = rects.reduce((s, r) => s + r.w * r.h, 0);
    expect(totalArea).toBeCloseTo(20 * 200, 1);
  });

  it("vertical branch places rects with correct x offset at frame.x", () => {
    // Very tall so row gets placed in vertical mode
    const items: HeatmapItem[] = [
      { ticker: "X", weight: 10, changePct: 2 },
      { ticker: "Y", weight: 10, changePct: -2 },
    ];
    const bounds = { x: 5, y: 10, width: 10, height: 200 };
    const rects = computeHeatmap(items, bounds);

    expect(rects.length).toBe(2);
    // Both rects should start at bounds.x = 5 (vertical mode puts items in same column)
    expect(rects[0]!.x).toBeCloseTo(5, 1);
    // Total area conserved
    const totalArea = rects.reduce((s, r) => s + r.w * r.h, 0);
    expect(totalArea).toBeCloseTo(10 * 200, 1);
  });
});
