import { describe, it, expect } from "vitest";
import { computeTsi } from "../../../src/domain/tsi";

describe("tsi", () => {
  it("empty / too short -> []", () => {
    expect(computeTsi([])).toEqual([]);
    expect(computeTsi([100])).toEqual([]);
  });

  it("rejects bad params", () => {
    expect(computeTsi([1, 2, 3], { slow: 0 })).toEqual([]);
    expect(computeTsi([1, 2, 3], { fast: 0 })).toEqual([]);
  });

  it("uptrend -> TSI eventually ~ +100", () => {
    const data = Array.from({ length: 120 }, (_, i) => 100 + i);
    const out = computeTsi(data);
    expect(out[out.length - 1]!.tsi).toBeCloseTo(100, 6);
  });

  it("downtrend -> TSI eventually ~ -100", () => {
    const data = Array.from({ length: 120 }, (_, i) => 200 - i);
    const out = computeTsi(data);
    expect(out[out.length - 1]!.tsi).toBeCloseTo(-100, 6);
  });

  it("values stay in [-100, 100]", () => {
    const data = Array.from({ length: 150 }, (_, i) => 100 + Math.sin(i / 10) * 20);
    const out = computeTsi(data);
    for (const p of out) {
      expect(p.tsi).toBeGreaterThanOrEqual(-100.0001);
      expect(p.tsi).toBeLessThanOrEqual(100.0001);
    }
  });

  it("signal eventually populated", () => {
    const data = Array.from({ length: 120 }, (_, i) => 100 + Math.sin(i / 6) * 5);
    const out = computeTsi(data);
    expect(out.some((p) => p.signal !== null)).toBe(true);
  });
});
