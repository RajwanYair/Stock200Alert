import { describe, it, expect } from "vitest";
import { computeChoppinessIndex } from "../../../src/domain/choppiness-index";
import type { Candle } from "../../../src/domain/heikin-ashi";

function make(closes: number[]): Candle[] {
  return closes.map((c, i) => ({ time: i, open: c, high: c + 1, low: c - 1, close: c }));
}

describe("computeChoppinessIndex", () => {
  it("empty -> empty", () => {
    expect(computeChoppinessIndex([])).toEqual([]);
  });
  it("nulls before period-1 ready", () => {
    const out = computeChoppinessIndex(make([1, 2, 3]), 14);
    expect(out.every((v) => v === null)).toBe(true);
  });
  it("strong uptrend -> low choppiness (<50)", () => {
    const closes = Array.from({ length: 30 }, (_, i) => 10 + i * 5);
    const out = computeChoppinessIndex(make(closes), 14);
    expect(out[20]!).toBeLessThan(50);
  });
  it("range-bound -> high choppiness (>50)", () => {
    const closes = Array.from({ length: 30 }, (_, i) => 100 + (i % 2 === 0 ? 0.1 : -0.1));
    const out = computeChoppinessIndex(make(closes), 14);
    expect(out[20]!).toBeGreaterThan(50);
  });
  it("custom period", () => {
    const closes = Array.from({ length: 20 }, (_, i) => 100 + i);
    const out = computeChoppinessIndex(make(closes), 7);
    expect(out[6]).not.toBeNull();
  });
});
