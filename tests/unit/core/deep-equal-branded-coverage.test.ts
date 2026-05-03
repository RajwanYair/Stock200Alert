/**
 * Coverage for deep-equal.ts (lines 28, 33, 43, 47, 68) and branded.ts (lines 41, 50).
 */
import { describe, it, expect } from "vitest";
import { deepEqual } from "../../../src/core/deep-equal";
import { asISODate, asPrice } from "../../../src/domain/branded";

describe("deep-equal coverage — uncovered branches", () => {
  it("returns false when a is not Date but b is Date (line 28)", () => {
    expect(deepEqual({ x: 1 }, new Date("2024-01-01"))).toBe(false);
  });

  it("returns false when a is not RegExp but b is RegExp (line 33)", () => {
    expect(deepEqual({ x: 1 }, /abc/)).toBe(false);
  });

  it("returns false when a is not Map but b is Map (line 43)", () => {
    expect(deepEqual({ x: 1 }, new Map([["x", 1]]))).toBe(false);
  });

  it("returns false when a is not Set but b is Set (line 47)", () => {
    expect(deepEqual({ x: 1 }, new Set([1]))).toBe(false);
  });

  it("Set compare: returns false when b is missing a value from a (line 47)", () => {
    expect(deepEqual(new Set([1, 2, 3]), new Set([1, 2, 4]))).toBe(false);
  });

  it("Map compare: returns false when map values differ (line 37)", () => {
    const a = new Map([["k", 1]]);
    const b = new Map([["k", 2]]);
    expect(deepEqual(a, b)).toBe(false);
  });

  it("returns false when object b is missing a key from a (line 68)", () => {
    expect(deepEqual({ a: 1, b: 2 }, { a: 1, c: 2 })).toBe(false);
  });

  it("handles cyclic references symmetrically", () => {
    const a: Record<string, unknown> = { x: 1 };
    a["self"] = a;
    const b: Record<string, unknown> = { x: 1 };
    b["self"] = b;
    expect(deepEqual(a, b)).toBe(true);
  });
});

describe("branded.ts coverage — asISODate and asPrice throw (lines 41, 50)", () => {
  it("asISODate throws for invalid date string (line 41)", () => {
    expect(() => asISODate("not-a-date")).toThrow("Invalid ISO date");
  });

  it("asISODate throws for non-string input (line 41)", () => {
    expect(() => asISODate(12345)).toThrow("Invalid ISO date");
  });

  it("asPrice throws for negative number (line 50)", () => {
    expect(() => asPrice(-5)).toThrow("Invalid price");
  });

  it("asPrice throws for non-number (line 50)", () => {
    expect(() => asPrice("abc")).toThrow("Invalid price");
  });

  it("asPrice throws for NaN (line 50)", () => {
    expect(() => asPrice(NaN)).toThrow("Invalid price");
  });
});
