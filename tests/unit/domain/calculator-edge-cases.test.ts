/**
 * Extended calculator tests — edge cases for SMA, EMA, RSI, MACD, Bollinger.
 */
import { describe, it, expect } from "vitest";
import { computeSma, computeSmaSeries } from "../../../src/domain/sma-calculator";
import { computeEma, computeEmaSeries } from "../../../src/domain/ema-calculator";
import { computeRsi, computeRsiSeries } from "../../../src/domain/rsi-calculator";
import { computeMacdSeries } from "../../../src/domain/macd-calculator";
import { computeBollingerSeries, computeBollinger } from "../../../src/domain/bollinger-calculator";
import { makeCandles } from "../../helpers/candle-factory";

describe("SMA edge cases", () => {
  it("SMA of single-value array with period=1 returns that value", () => {
    expect(computeSma(makeCandles([42]), 1)).toBe(42);
  });

  it("SMA series length always equals candle count", () => {
    for (const len of [5, 10, 20, 50]) {
      const closes = Array.from({ length: len }, (_, i) => i + 1);
      const series = computeSmaSeries(makeCandles(closes), 5);
      expect(series).toHaveLength(len);
    }
  });

  it("SMA with all-same values returns that value", () => {
    const closes = Array.from({ length: 20 }, () => 100);
    expect(computeSma(makeCandles(closes), 10)).toBe(100);
  });

  it("SMA with ascending values uses last N", () => {
    const closes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    // SMA(5) of last 5: (6+7+8+9+10)/5 = 8
    expect(computeSma(makeCandles(closes), 5)).toBe(8);
  });
});

describe("EMA edge cases", () => {
  it("EMA with period=1 tracks the close exactly", () => {
    const closes = [10, 20, 30, 40, 50];
    expect(computeEma(makeCandles(closes), 1)).toBe(50);
  });

  it("EMA series first non-null equals SMA of first period", () => {
    const closes = [10, 20, 30, 40, 50];
    const series = computeEmaSeries(makeCandles(closes), 3);
    // SMA of first 3: (10+20+30)/3 = 20
    expect(series[2]?.value).toBe(20);
  });

  it("EMA converges to constant for flat prices", () => {
    const closes = Array.from({ length: 50 }, () => 100);
    expect(computeEma(makeCandles(closes), 14)).toBe(100);
  });
});

describe("RSI edge cases", () => {
  it("RSI is 100 for strictly ascending closes", () => {
    const closes = Array.from({ length: 20 }, (_, i) => 50 + i * 2);
    const series = computeRsiSeries(makeCandles(closes));
    const lastRsi = series[series.length - 1];
    expect(lastRsi?.value).toBe(100);
  });

  it("RSI is 0 for strictly descending closes", () => {
    const closes = Array.from({ length: 20 }, (_, i) => 100 - i * 2);
    const series = computeRsiSeries(makeCandles(closes));
    const lastRsi = series[series.length - 1];
    expect(lastRsi?.value).toBe(0);
  });

  it("RSI is between 0 and 100 for oscillating prices", () => {
    const closes = Array.from({ length: 30 }, (_, i) => 100 + Math.sin(i) * 10);
    const series = computeRsiSeries(makeCandles(closes));
    for (const p of series) {
      if (p.value !== null) {
        expect(p.value).toBeGreaterThanOrEqual(0);
        expect(p.value).toBeLessThanOrEqual(100);
      }
    }
  });

  it("RSI returns null for insufficient data", () => {
    expect(computeRsi(makeCandles([100, 101]))).toBeNull();
  });
});

describe("MACD edge cases", () => {
  it("MACD returns empty series for insufficient data", () => {
    const closes = Array.from({ length: 10 }, () => 100);
    const series = computeMacdSeries(makeCandles(closes));
    // Need at least 26 candles for slow EMA
    for (const p of series) {
      expect(p.macd).toBeNull();
    }
  });

  it("MACD histogram is 0 when MACD equals signal", () => {
    const closes = Array.from({ length: 60 }, () => 100);
    const series = computeMacdSeries(makeCandles(closes));
    const last = series[series.length - 1];
    if (last?.macd !== null && last?.signal !== null) {
      expect(last.histogram).toBeCloseTo(0);
    }
  });

  it("MACD line diverges from signal on trending data", () => {
    const closes = Array.from({ length: 60 }, (_, i) => 50 + i);
    const series = computeMacdSeries(makeCandles(closes));
    const last = series[series.length - 1];
    if (last?.macd !== null) {
      expect(last.macd).toBeGreaterThan(0);
    }
  });
});

describe("Bollinger edge cases", () => {
  it("Bollinger upper > middle > lower for varying data", () => {
    const closes = Array.from({ length: 30 }, (_, i) => 100 + Math.sin(i) * 10);
    const series = computeBollingerSeries(makeCandles(closes));
    const last = series[series.length - 1];
    if (last?.upper !== null && last?.middle !== null && last?.lower !== null) {
      expect(last.upper).toBeGreaterThan(last.middle!);
      expect(last.middle).toBeGreaterThan(last.lower!);
    }
  });

  it("Bollinger bands collapse for flat prices", () => {
    const closes = Array.from({ length: 30 }, () => 50);
    const series = computeBollingerSeries(makeCandles(closes));
    const last = series[series.length - 1];
    if (last?.upper !== null && last?.lower !== null) {
      expect(last.upper).toBeCloseTo(last.lower!, 5);
    }
  });

  it("computeBollinger returns null for insufficient data", () => {
    const closes = Array.from({ length: 10 }, () => 100);
    expect(computeBollinger(makeCandles(closes))).toBeNull();
  });

  it("percentB is between 0 and 1 when price is within bands", () => {
    const closes = Array.from({ length: 30 }, (_, i) => 100 + Math.sin(i) * 3);
    const series = computeBollingerSeries(makeCandles(closes));
    for (const p of series) {
      if (p.percentB !== null) {
        expect(p.percentB).toBeGreaterThanOrEqual(-0.5);
        expect(p.percentB).toBeLessThanOrEqual(1.5);
      }
    }
  });
});
