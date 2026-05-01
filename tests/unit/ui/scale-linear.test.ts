import { describe, it, expect } from "vitest";
import { createLinearScale, niceTicks } from "../../../src/ui/scale-linear";

describe("scale-linear", () => {
  it("maps domain endpoints to range endpoints", () => {
    const s = createLinearScale([0, 100], [0, 1]);
    expect(s(0)).toBe(0);
    expect(s(100)).toBe(1);
    expect(s(50)).toBe(0.5);
  });

  it("inverts back to domain", () => {
    const s = createLinearScale([10, 110], [0, 200]);
    expect(s.invert(s(42))).toBeCloseTo(42, 6);
  });

  it("does not clamp by default; clamps when enabled", () => {
    const a = createLinearScale([0, 10], [0, 100]);
    expect(a(15)).toBe(150);
    const b = createLinearScale([0, 10], [0, 100], { clamp: true });
    expect(b(15)).toBe(100);
    expect(b(-5)).toBe(0);
  });

  it("zero domain -> always returns r0", () => {
    const s = createLinearScale([5, 5], [0, 100]);
    expect(s(5)).toBe(0);
    expect(s(99)).toBe(0);
  });

  it("inverted range works (e.g. SVG y-axis)", () => {
    const s = createLinearScale([0, 100], [200, 0]);
    expect(s(0)).toBe(200);
    expect(s(100)).toBe(0);
    expect(s(50)).toBe(100);
  });

  it("domain() and range() return the configured tuples", () => {
    const s = createLinearScale([1, 2], [3, 4]);
    expect(s.domain()).toEqual([1, 2]);
    expect(s.range()).toEqual([3, 4]);
  });

  it("ticks returns nice round numbers in domain", () => {
    const s = createLinearScale([0, 100], [0, 1]);
    const t = s.ticks(5);
    expect(t).toEqual([0, 20, 40, 60, 80, 100]);
  });

  it("niceTicks: equal start/stop -> [start]", () => {
    expect(niceTicks(5, 5, 5)).toEqual([5]);
  });

  it("niceTicks: count <= 0 -> []", () => {
    expect(niceTicks(0, 10, 0)).toEqual([]);
  });

  it("niceTicks: reversed order returned reversed", () => {
    const fwd = niceTicks(0, 10, 5);
    const rev = niceTicks(10, 0, 5);
    expect(rev).toEqual([...fwd].reverse());
  });
});
