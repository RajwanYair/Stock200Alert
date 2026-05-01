import { describe, it, expect } from "vitest";
import { djb2, djb2Hex, fnv1a32 } from "../../../src/core/hash-djb2";

describe("djb2", () => {
  it("returns 0 for empty string base hash xor only -> 5381", () => {
    expect(djb2("")).toBe(5381);
  });
  it("deterministic", () => {
    expect(djb2("hello")).toBe(djb2("hello"));
  });
  it("different inputs -> different hashes (in practice)", () => {
    expect(djb2("hello")).not.toBe(djb2("world"));
  });
  it("returns unsigned 32-bit", () => {
    const h = djb2("xyz");
    expect(h).toBeGreaterThanOrEqual(0);
    expect(h).toBeLessThanOrEqual(0xffffffff);
  });
});

describe("djb2Hex", () => {
  it("8-char zero-padded", () => {
    const s = djb2Hex("");
    expect(s).toHaveLength(8);
    expect(/^[0-9a-f]{8}$/.test(s)).toBe(true);
  });
  it("matches djb2 numerically", () => {
    expect(parseInt(djb2Hex("crosstide"), 16)).toBe(djb2("crosstide"));
  });
});

describe("fnv1a32", () => {
  it("seed value for empty string", () => {
    expect(fnv1a32("")).toBe(0x811c9dc5);
  });
  it("deterministic", () => {
    expect(fnv1a32("abc")).toBe(fnv1a32("abc"));
  });
  it("returns unsigned 32-bit", () => {
    const h = fnv1a32("longer string");
    expect(h).toBeGreaterThanOrEqual(0);
    expect(h).toBeLessThanOrEqual(0xffffffff);
  });
  it("distinguishes inputs", () => {
    expect(fnv1a32("a")).not.toBe(fnv1a32("b"));
  });
});
