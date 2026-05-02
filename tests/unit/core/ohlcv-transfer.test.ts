import { describe, it, expect } from "vitest";
import { candlesToBuffer, bufferToCandles, OHLCV_STRIDE } from "../../../src/core/ohlcv-transfer";
import type { DailyCandle } from "../../../src/types/domain";

const SAMPLE: DailyCandle[] = [
  { date: "2024-01-02", open: 100, high: 110, low: 95, close: 105, volume: 1_000_000 },
  { date: "2024-01-03", open: 105, high: 112, low: 102, close: 108, volume: 1_200_000 },
  { date: "2024-01-04", open: 108, high: 115, low: 107, close: 113, volume: 900_000 },
];

describe("candlesToBuffer", () => {
  it("produces a buffer with length = candles × OHLCV_STRIDE", () => {
    const buf = candlesToBuffer(SAMPLE);
    expect(buf).toBeInstanceOf(Float64Array);
    expect(buf.length).toBe(SAMPLE.length * OHLCV_STRIDE);
  });

  it("packs OHLCV values in the correct slots", () => {
    const buf = candlesToBuffer(SAMPLE);
    const [c] = SAMPLE;
    expect(buf[0]).toBe(Date.parse(c!.date));
    expect(buf[1]).toBe(c!.open);
    expect(buf[2]).toBe(c!.high);
    expect(buf[3]).toBe(c!.low);
    expect(buf[4]).toBe(c!.close);
    expect(buf[5]).toBe(c!.volume);
  });

  it("returns empty buffer for empty input", () => {
    const buf = candlesToBuffer([]);
    expect(buf.length).toBe(0);
  });
});

describe("bufferToCandles", () => {
  it("round-trips DailyCandle[] → buffer → DailyCandle[]", () => {
    const buf = candlesToBuffer(SAMPLE);
    const result = bufferToCandles(buf);
    expect(result).toHaveLength(SAMPLE.length);
    for (let i = 0; i < SAMPLE.length; i++) {
      expect(result[i]!.date).toBe(SAMPLE[i]!.date);
      expect(result[i]!.open).toBeCloseTo(SAMPLE[i]!.open, 10);
      expect(result[i]!.high).toBeCloseTo(SAMPLE[i]!.high, 10);
      expect(result[i]!.low).toBeCloseTo(SAMPLE[i]!.low, 10);
      expect(result[i]!.close).toBeCloseTo(SAMPLE[i]!.close, 10);
      expect(result[i]!.volume).toBeCloseTo(SAMPLE[i]!.volume, 10);
    }
  });

  it("returns empty array for empty buffer", () => {
    expect(bufferToCandles(new Float64Array(0))).toEqual([]);
  });

  it("preserves date as YYYY-MM-DD string", () => {
    const buf = candlesToBuffer(SAMPLE);
    const result = bufferToCandles(buf);
    expect(result[0]!.date).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect(result[0]!.date).toBe("2024-01-02");
  });
});
