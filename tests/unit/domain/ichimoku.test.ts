import { describe, it, expect } from "vitest";
import { computeIchimoku } from "../../../src/domain/ichimoku";
import type { Candle } from "../../../src/domain/heikin-ashi";

const mk = (h: number, l: number, c: number, t: number): Candle => ({
  time: t,
  open: c,
  high: h,
  low: l,
  close: c,
});

const trend = (n: number): Candle[] =>
  Array.from({ length: n }, (_, i) => mk(100 + i, 99 + i, 100 + i, i));

describe("ichimoku", () => {
  it("rejects invalid periods", () => {
    expect(() => computeIchimoku([], { tenkanPeriod: 0 })).toThrow(RangeError);
  });

  it("emits one point per candle", () => {
    const r = computeIchimoku(trend(60));
    expect(r).toHaveLength(60);
  });

  it("tenkan null until window filled", () => {
    const r = computeIchimoku(trend(60));
    expect(r[7]!.tenkan).toBeNull();
    expect(r[8]!.tenkan).not.toBeNull();
  });

  it("kijun null until 26 bars", () => {
    const r = computeIchimoku(trend(60));
    expect(r[24]!.kijun).toBeNull();
    expect(r[25]!.kijun).not.toBeNull();
  });

  it("chikou is close shifted forward by 26", () => {
    const r = computeIchimoku(trend(60));
    expect(r[10]!.chikou).toBe(trend(60)[36]!.close);
  });

  it("chikou null near the end (no future data)", () => {
    const r = computeIchimoku(trend(60));
    expect(r[59]!.chikou).toBeNull();
  });

  it("senkouA null until tenkan+kijun ready and displaced", () => {
    const r = computeIchimoku(trend(60));
    // displacement=26: senkouA at i uses values at i-26, which need
    // kijun ready (kijun warm at i-26 >= 25 => i >= 51).
    expect(r[50]!.senkouA).toBeNull();
    expect(r[51]!.senkouA).not.toBeNull();
  });

  it("custom displacement of 0 makes senkouA align with current bar", () => {
    const r = computeIchimoku(trend(60), { displacement: 0 });
    // No future shift, so senkouA at index 25 = (tenkan+kijun)/2.
    expect(r[25]!.senkouA).not.toBeNull();
  });

  it("preserves time", () => {
    const r = computeIchimoku(trend(30));
    expect(r[5]!.time).toBe(5);
  });
});
