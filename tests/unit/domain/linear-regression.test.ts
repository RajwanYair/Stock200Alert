import { describe, it, expect } from "vitest";
import {
  linearRegression,
  regressionLine,
  regressionChannel,
} from "../../../src/domain/linear-regression";

describe("linear-regression", () => {
  it("perfect line fits exactly", () => {
    const r = linearRegression([0, 1, 2, 3], [2, 4, 6, 8]);
    expect(r.slope).toBeCloseTo(2, 6);
    expect(r.intercept).toBeCloseTo(2, 6);
    expect(r.r2).toBeCloseTo(1, 6);
  });

  it("predict applies fitted line", () => {
    const r = linearRegression([0, 1, 2], [1, 3, 5]);
    expect(r.predict(10)).toBeCloseTo(21, 6);
  });

  it("r2 is 0 for vertical (constant y)", () => {
    const r = linearRegression([0, 1, 2], [5, 5, 5]);
    expect(r.r2).toBe(0);
  });

  it("handles n<2 gracefully", () => {
    const r = linearRegression([1], [9]);
    expect(r.predict(123)).toBe(9);
    expect(r.r2).toBe(0);
  });

  it("regressionLine produces fit of same length", () => {
    const out = regressionLine([1, 2, 3, 4, 5]);
    expect(out.fit.length).toBe(5);
    expect(out.slope).toBeCloseTo(1, 6);
    expect(out.r2).toBeCloseTo(1, 6);
  });

  it("regressionChannel widens with stdDev multiplier", () => {
    const values = [1, 3, 2, 5, 4, 7];
    const c1 = regressionChannel(values, 1);
    const c2 = regressionChannel(values, 2);
    const w1 = c1.upper[0]! - c1.lower[0]!;
    const w2 = c2.upper[0]! - c2.lower[0]!;
    expect(w2).toBeCloseTo(2 * w1, 6);
  });

  it("perfect line has zero-width channel", () => {
    const c = regressionChannel([0, 1, 2, 3, 4], 2);
    expect(c.upper[0]).toBeCloseTo(c.lower[0]!, 6);
  });

  it("noisy data has r2 between 0 and 1", () => {
    const r = linearRegression([0, 1, 2, 3, 4], [0, 1.2, 1.9, 3.1, 4.2]);
    expect(r.r2).toBeGreaterThan(0.9);
    expect(r.r2).toBeLessThanOrEqual(1);
  });
});
