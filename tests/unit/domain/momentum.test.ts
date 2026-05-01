import { describe, it, expect } from "vitest";
import { computeMomentum } from "../../../src/domain/momentum";

describe("momentum", () => {
  it("rejects bad params", () => {
    expect(computeMomentum([1, 2, 3], 0).every((v) => v === null)).toBe(true);
  });

  it("nulls until period bars elapsed", () => {
    const out = computeMomentum([10, 11, 12, 13, 14], 3);
    expect(out[0]).toBeNull();
    expect(out[2]).toBeNull();
    expect(out[3]).toBe(3);
    expect(out[4]).toBe(3);
  });

  it("downtrend -> negative momentum", () => {
    const out = computeMomentum([20, 18, 16, 14, 12], 2);
    expect(out[2]).toBe(-4);
    expect(out[4]).toBe(-4);
  });

  it("constant -> momentum 0", () => {
    const out = computeMomentum([5, 5, 5, 5, 5], 2);
    expect(out[2]).toBe(0);
    expect(out[4]).toBe(0);
  });

  it("output length matches input", () => {
    expect(computeMomentum([1, 2, 3, 4], 1).length).toBe(4);
  });
});
