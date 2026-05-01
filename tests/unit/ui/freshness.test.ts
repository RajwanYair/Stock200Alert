import { describe, it, expect } from "vitest";
import {
  classifyFreshness,
  ageBetween,
  formatAge,
  freshnessLabel,
} from "../../../src/ui/freshness";

describe("freshness", () => {
  it("classifies live/fresh/recent/stale/expired", () => {
    expect(classifyFreshness(1000)).toBe("live");
    expect(classifyFreshness(10_000)).toBe("fresh");
    expect(classifyFreshness(45_000)).toBe("recent");
    expect(classifyFreshness(2 * 60_000)).toBe("stale");
    expect(classifyFreshness(60 * 60_000)).toBe("expired");
  });

  it("treats invalid ages as expired", () => {
    expect(classifyFreshness(NaN)).toBe("expired");
    expect(classifyFreshness(-1)).toBe("expired");
  });

  it("respects custom thresholds", () => {
    expect(classifyFreshness(500, { liveMs: 100 })).toBe("fresh");
  });

  it("ageBetween clamps to non-negative", () => {
    expect(ageBetween(100, 50)).toBe(0);
    expect(ageBetween(100, 200)).toBe(100);
  });

  it("formatAge produces compact units", () => {
    expect(formatAge(900)).toBe("1s");
    expect(formatAge(45_000)).toBe("45s");
    expect(formatAge(120_000)).toBe("2m");
    expect(formatAge(2 * 60 * 60_000)).toBe("2h");
    expect(formatAge(3 * 24 * 60 * 60_000)).toBe("3d");
  });

  it("formatAge handles invalid", () => {
    expect(formatAge(NaN)).toBe("—");
    expect(formatAge(-1)).toBe("—");
  });

  it("freshnessLabel returns 'live' label for current data", () => {
    const r = freshnessLabel(1000, 1500);
    expect(r.bucket).toBe("live");
    expect(r.label).toBe("live");
  });

  it("freshnessLabel formats stale ages", () => {
    const r = freshnessLabel(0, 30_000);
    expect(r.bucket).toBe("recent");
    expect(r.label).toMatch(/recent \d+s/);
  });

  it("freshnessLabel returns 'expired' for ancient data", () => {
    expect(freshnessLabel(0, 60 * 60_000).label).toBe("expired");
  });
});
