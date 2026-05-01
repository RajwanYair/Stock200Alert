import { describe, it, expect } from "vitest";
import { computeWma } from "../../../src/domain/wma";

describe("wma", () => {
  it("rejects bad params / too short", () => {
    expect(computeWma([], 5).every((v) => v === null)).toBe(true);
    expect(computeWma([1, 2], 5).every((v) => v === null)).toBe(true);
    expect(computeWma([1, 2, 3], 0).every((v) => v === null)).toBe(true);
  });

  it("constant series -> WMA = constant", () => {
    const out = computeWma([5, 5, 5, 5, 5], 3);
    expect(out[2]).toBeCloseTo(5, 9);
    expect(out[4]).toBeCloseTo(5, 9);
  });

  it("matches manual calculation for period 3", () => {
    // values [1,2,3,4,5], weights (1,2,3) on (1,2,3): (1+4+9)/6 = 14/6
    const out = computeWma([1, 2, 3, 4, 5], 3);
    expect(out[0]).toBeNull();
    expect(out[1]).toBeNull();
    expect(out[2]).toBeCloseTo(14 / 6, 9);
    expect(out[3]).toBeCloseTo((2 + 6 + 12) / 6, 9); // (2,3,4)*(1,2,3)
    expect(out[4]).toBeCloseTo((3 + 8 + 15) / 6, 9); // (3,4,5)*(1,2,3)
  });

  it("output length matches input", () => {
    const data = Array.from({ length: 20 }, (_, i) => i);
    expect(computeWma(data, 5).length).toBe(20);
  });

  it("WMA reacts faster than SMA on trend (last point)", () => {
    const data = Array.from({ length: 10 }, (_, i) => i + 1);
    const wma = computeWma(data, 5);
    // SMA of last 5 = (6+7+8+9+10)/5 = 8; WMA should be > SMA in uptrend
    expect(wma[9]!).toBeGreaterThan(8);
  });
});
