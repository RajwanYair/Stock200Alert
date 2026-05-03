/**
 * Coverage for backtest-engine.ts — force-close at end, drawdown, majority edges.
 */
import { describe, it, expect, vi } from "vitest";
import type { MethodSignal } from "../../../src/types/domain";
import { makeCandles } from "../../helpers/candle-factory";

vi.mock("../../../src/domain/signal-aggregator", () => ({
  aggregateSignals: vi.fn(),
}));

import { runBacktest, type BacktestConfig } from "../../../src/domain/backtest-engine";
import { aggregateSignals } from "../../../src/domain/signal-aggregator";

const mockedAggregate = vi.mocked(aggregateSignals);

const baseConfig: BacktestConfig = {
  ticker: "TEST",
  initialCapital: 10000,
  methods: ["RSI", "MACD", "Bollinger"],
  windowSize: 3,
};

describe("backtest-engine coverage — uncovered branches", () => {
  it("closes open position at end of data (line 101-113)", () => {
    // 7 candles: windowSize=3, so loop runs i=3..6
    // At i=3 produce BUY majority, then never produce SELL
    const candles = makeCandles([100, 101, 102, 103, 104, 105, 110]);

    mockedAggregate.mockImplementation((): MethodSignal[] => {
      // All 3 methods signal BUY — majority always holds
      return [
        { method: "RSI", direction: "BUY", confidence: 0.8 },
        { method: "MACD", direction: "BUY", confidence: 0.7 },
        { method: "Bollinger", direction: "BUY", confidence: 0.6 },
      ];
    });

    const result = runBacktest(candles, baseConfig);
    // Position opened at i=3 (close=103), never sold, auto-closed at end (close=110)
    expect(result.trades.length).toBeGreaterThanOrEqual(1);
    const lastTrade = result.trades[result.trades.length - 1]!;
    expect(lastTrade.exitPrice).toBe(110);
    expect(lastTrade.profit).toBeGreaterThan(0);
  });

  it("handles drawdown calculation when equity drops", () => {
    // BUY at i=3 (close=100), then SELL at i=5 (close=80) → loss
    const candles = makeCandles([100, 100, 100, 100, 90, 80, 70]);
    let callCount = 0;

    mockedAggregate.mockImplementation((): MethodSignal[] => {
      callCount++;
      if (callCount === 1) {
        // First call (i=3): BUY
        return [
          { method: "RSI", direction: "BUY", confidence: 0.9 },
          { method: "MACD", direction: "BUY", confidence: 0.9 },
          { method: "Bollinger", direction: "BUY", confidence: 0.9 },
        ];
      }
      // Subsequent: SELL majority
      return [
        { method: "RSI", direction: "SELL", confidence: 0.9 },
        { method: "MACD", direction: "SELL", confidence: 0.9 },
        { method: "Bollinger", direction: "SELL", confidence: 0.9 },
      ];
    });

    const result = runBacktest(candles, baseConfig);
    expect(result.maxDrawdown).toBeGreaterThan(0);
  });

  it("exactly half buy signals does NOT trigger entry (majority requires >)", () => {
    // 2 methods: exactly half buy does NOT meet buyCount > relevant.length / 2
    const config: BacktestConfig = { ...baseConfig, methods: ["RSI", "MACD"] };
    const candles = makeCandles([100, 100, 100, 100, 105, 110]);

    mockedAggregate.mockImplementation((): MethodSignal[] => {
      return [
        { method: "RSI", direction: "BUY", confidence: 0.8 },
        { method: "MACD", direction: "SELL", confidence: 0.8 },
      ];
    });

    const result = runBacktest(candles, config);
    // 1 BUY out of 2 is not > 1 (which is 2/2), so no entry
    expect(result.trades).toHaveLength(0);
  });

  it("totalReturnPercent is 0 when initialCapital is 0", () => {
    const config: BacktestConfig = { ...baseConfig, initialCapital: 0 };
    const candles = makeCandles([100, 100, 100, 100]);

    mockedAggregate.mockReturnValue([]);
    const result = runBacktest(candles, config);
    expect(result.totalReturnPercent).toBe(0);
  });

  it("handles HOLD signals (no entry when no majority)", () => {
    const candles = makeCandles([100, 100, 100, 100, 105, 110]);

    mockedAggregate.mockImplementation((): MethodSignal[] => {
      return [
        { method: "RSI", direction: "HOLD", confidence: 0.5 },
        { method: "MACD", direction: "HOLD", confidence: 0.5 },
        { method: "Bollinger", direction: "HOLD", confidence: 0.5 },
      ];
    });

    const result = runBacktest(candles, baseConfig);
    expect(result.trades).toHaveLength(0);
    expect(result.totalReturn).toBe(0);
  });
});
