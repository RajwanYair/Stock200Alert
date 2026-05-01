import { describe, it, expect } from "vitest";
import { computeStdDev } from "../../../src/domain/standard-deviation";

describe("standard-deviation", () => {
  it("rejects bad params / too short", () => {
    expect(computeStdDev([], 5).every((v) => v === null)).toBe(true);
    expect(computeStdDev([1, 2], 5).every((v) => v === null)).toBe(true);
    expect(computeStdDev([1, 2, 3], 0).every((v) => v === null)).toBe(true);
  });

  it("constant series -> stddev 0", () => {
    const out = computeStdDev([5, 5, 5, 5], 3);
    expect(out[2]).toBeCloseTo(0, 9);
    expect(out[3]).toBeCloseTo(0, 9);
  });

  it("matches manual calc (population)", () => {
    // values [2,4,4,4,5,5,7,9], full-window pop stddev = 2
    const v = [2, 4, 4, 4, 5, 5, 7, 9];
    const out = computeStdDev(v, 8);
    expect(out[7]).toBeCloseTo(2, 9);
  });

  it("sample variant uses (n-1)", () => {
    const v = [2, 4, 4, 4, 5, 5, 7, 9];
    const out = computeStdDev(v, 8, { sample: true });
    // Sample stddev = sqrt(32/7) ≈ 2.138089935
    expect(out[7]).toBeCloseTo(Math.sqrt(32 / 7), 9);
  });

  it("output length matches input", () => {
    expect(computeStdDev([1, 2, 3, 4, 5], 3).length).toBe(5);
  });

  it("nulls before first full window", () => {
    const out = computeStdDev([1, 2, 3, 4], 3);
    expect(out[0]).toBeNull();
    expect(out[1]).toBeNull();
    expect(out[2]).not.toBeNull();
  });
});
