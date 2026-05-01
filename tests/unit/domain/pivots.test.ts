import { describe, it, expect } from "vitest";
import { computePivots } from "../../../src/domain/pivots";

const HLC = { high: 110, low: 90, close: 105 };

describe("pivots", () => {
  it("classic central pivot is (H+L+C)/3", () => {
    const p = computePivots(HLC, "classic");
    expect(p.p).toBeCloseTo((110 + 90 + 105) / 3, 5);
  });

  it("classic R1 = 2P - L, S1 = 2P - H", () => {
    const p = computePivots(HLC, "classic");
    expect(p.r1).toBeCloseTo(2 * p.p - 90, 5);
    expect(p.s1).toBeCloseTo(2 * p.p - 110, 5);
  });

  it("classic R2/S2 are symmetric around P by range", () => {
    const p = computePivots(HLC, "classic");
    expect(p.r2 - p.p).toBeCloseTo(p.p - p.s2, 5);
  });

  it("fibonacci uses 0.382 / 0.618 / 1.0 ratios", () => {
    const p = computePivots(HLC, "fibonacci");
    const range = 110 - 90;
    expect(p.r1 - p.p).toBeCloseTo(0.382 * range, 5);
    expect(p.r2 - p.p).toBeCloseTo(0.618 * range, 5);
    expect(p.r3 - p.p).toBeCloseTo(range, 5);
  });

  it("camarilla uses 1.1/12 etc. of range", () => {
    const p = computePivots(HLC, "camarilla");
    const range = 110 - 90;
    expect(p.r1 - 105).toBeCloseTo((range * 1.1) / 12, 5);
    expect(p.r3 - 105).toBeCloseTo((range * 1.1) / 4, 5);
  });

  it("woodie weights close double", () => {
    const p = computePivots({ ...HLC, open: 100 }, "woodie");
    expect(p.p).toBeCloseTo((110 + 90 + 2 * 105) / 4, 5);
  });

  it("woodie throws without open", () => {
    expect(() => computePivots(HLC, "woodie")).toThrow(TypeError);
  });

  it("R levels are monotone increasing, S decreasing from anchor", () => {
    for (const kind of ["classic", "fibonacci", "camarilla"] as const) {
      const p = computePivots(HLC, kind);
      expect(p.r2).toBeGreaterThan(p.r1);
      expect(p.r3).toBeGreaterThan(p.r2);
      expect(p.s2).toBeLessThan(p.s1);
      expect(p.s3).toBeLessThan(p.s2);
    }
  });
});
