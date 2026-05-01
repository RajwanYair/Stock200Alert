import { describe, it, expect } from "vitest";
import { deepEqual } from "../../../src/core/deep-equal";

describe("deep-equal", () => {
  it("primitives", () => {
    expect(deepEqual(1, 1)).toBe(true);
    expect(deepEqual("a", "a")).toBe(true);
    expect(deepEqual(true, true)).toBe(true);
    expect(deepEqual(null, null)).toBe(true);
    expect(deepEqual(undefined, undefined)).toBe(true);
    expect(deepEqual(1, 2)).toBe(false);
    expect(deepEqual("a", "b")).toBe(false);
    expect(deepEqual(null, undefined)).toBe(false);
  });

  it("NaN equals NaN", () => {
    expect(deepEqual(NaN, NaN)).toBe(true);
    expect(deepEqual(NaN, 0)).toBe(false);
  });

  it("plain objects", () => {
    expect(deepEqual({ a: 1, b: { c: 2 } }, { a: 1, b: { c: 2 } })).toBe(true);
    expect(deepEqual({ a: 1 }, { a: 1, b: 2 })).toBe(false);
    expect(deepEqual({ a: 1 }, { a: 2 })).toBe(false);
  });

  it("arrays", () => {
    expect(deepEqual([1, 2, [3, 4]], [1, 2, [3, 4]])).toBe(true);
    expect(deepEqual([1, 2, 3], [1, 2])).toBe(false);
    expect(deepEqual([1, 2, 3], [1, 2, 4])).toBe(false);
    expect(deepEqual([1, 2], { 0: 1, 1: 2, length: 2 })).toBe(false);
  });

  it("Date / RegExp", () => {
    expect(deepEqual(new Date(1), new Date(1))).toBe(true);
    expect(deepEqual(new Date(1), new Date(2))).toBe(false);
    expect(deepEqual(/a/g, /a/g)).toBe(true);
    expect(deepEqual(/a/g, /a/i)).toBe(false);
  });

  it("Map and Set", () => {
    expect(deepEqual(new Map([["a", 1]]), new Map([["a", 1]]))).toBe(true);
    expect(deepEqual(new Map([["a", 1]]), new Map([["a", 2]]))).toBe(false);
    expect(deepEqual(new Set([1, 2, 3]), new Set([3, 2, 1]))).toBe(true);
    expect(deepEqual(new Set([1, 2]), new Set([1, 3]))).toBe(false);
  });

  it("type mismatches", () => {
    expect(deepEqual([1, 2], new Set([1, 2]))).toBe(false);
    expect(deepEqual({}, [])).toBe(false);
    expect(deepEqual(new Date(), {})).toBe(false);
  });

  it("cyclic references compare equal when symmetric", () => {
    const a: Record<string, unknown> = { x: 1 };
    a["self"] = a;
    const b: Record<string, unknown> = { x: 1 };
    b["self"] = b;
    expect(deepEqual(a, b)).toBe(true);
  });
});
