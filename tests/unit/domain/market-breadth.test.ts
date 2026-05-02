/**
 * Tests for G23: Market Breadth domain — computeMarketBreadth + classifyBreadthCondition.
 */
import { describe, it, expect } from "vitest";
import {
  computeMarketBreadth,
  classifyBreadthCondition,
  type BreadthTicker,
} from "../../../src/domain/market-breadth";

function t(
  ticker: string,
  consensus: "BUY" | "SELL" | "NEUTRAL",
  changePercent: number,
  aboveSma50: boolean | null = null,
  aboveSma200: boolean | null = null,
): BreadthTicker {
  return { ticker, price: 100, changePercent, consensus, aboveSma50, aboveSma200 };
}

// ─────────────────────────── computeMarketBreadth ────────────────────────────

describe("computeMarketBreadth — signal counts", () => {
  it("counts BUY / SELL / NEUTRAL correctly", () => {
    const tickers = [t("A", "BUY", 0), t("B", "BUY", 0), t("C", "SELL", 0), t("D", "NEUTRAL", 0)];
    const r = computeMarketBreadth(tickers);
    expect(r.buyCount).toBe(2);
    expect(r.sellCount).toBe(1);
    expect(r.neutralCount).toBe(1);
    expect(r.total).toBe(4);
  });

  it("buyPct and sellPct are fractional [0,1]", () => {
    const tickers = [t("A", "BUY", 0), t("B", "BUY", 0), t("C", "SELL", 0)];
    const r = computeMarketBreadth(tickers);
    expect(r.buyPct).toBeCloseTo(2 / 3);
    expect(r.sellPct).toBeCloseTo(1 / 3);
  });

  it("empty list returns zeros", () => {
    const r = computeMarketBreadth([]);
    expect(r.total).toBe(0);
    expect(r.buyCount).toBe(0);
    expect(r.buyPct).toBe(0);
    expect(r.adRatio).toBeNull();
  });
});

describe("computeMarketBreadth — advance/decline", () => {
  it("counts advancers / decliners with default 0.05 threshold", () => {
    const tickers = [
      t("A", "BUY", 1.0), // advancer
      t("B", "BUY", -1.0), // decliner
      t("C", "BUY", 0.02), // unchanged
    ];
    const r = computeMarketBreadth(tickers);
    expect(r.advancers).toBe(1);
    expect(r.decliners).toBe(1);
    expect(r.unchanged).toBe(1);
  });

  it("adRatio = advancers / decliners", () => {
    const tickers = [t("A", "BUY", 2.0), t("B", "BUY", 2.0), t("C", "SELL", -2.0)];
    const r = computeMarketBreadth(tickers);
    expect(r.adRatio).toBeCloseTo(2);
  });

  it("adRatio is null when no decliners", () => {
    const r = computeMarketBreadth([t("A", "BUY", 2.0), t("B", "BUY", 1.0)]);
    expect(r.adRatio).toBeNull();
  });

  it("respects custom changeThreshold option", () => {
    const tickers = [t("A", "BUY", 0.5), t("B", "SELL", -0.5)];
    const r = computeMarketBreadth(tickers, { changeThreshold: 1.0 });
    // 0.5 < 1.0 threshold → both unchanged
    expect(r.advancers).toBe(0);
    expect(r.decliners).toBe(0);
    expect(r.unchanged).toBe(2);
  });
});

describe("computeMarketBreadth — SMA pct", () => {
  it("computes aboveSma50Pct correctly, ignoring nulls", () => {
    const tickers = [
      t("A", "BUY", 0, true),
      t("B", "BUY", 0, true),
      t("C", "BUY", 0, false),
      t("D", "BUY", 0, null), // excluded
    ];
    const r = computeMarketBreadth(tickers);
    expect(r.aboveSma50Pct).toBeCloseTo(2 / 3);
  });

  it("returns null aboveSma50Pct when all null", () => {
    const r = computeMarketBreadth([t("A", "BUY", 0), t("B", "BUY", 0)]);
    expect(r.aboveSma50Pct).toBeNull();
    expect(r.aboveSma200Pct).toBeNull();
  });

  it("computes aboveSma200Pct independently", () => {
    const tickers = [t("A", "BUY", 0, null, true), t("B", "BUY", 0, null, false)];
    const r = computeMarketBreadth(tickers);
    expect(r.aboveSma50Pct).toBeNull();
    expect(r.aboveSma200Pct).toBe(0.5);
  });
});

describe("computeMarketBreadth — movers & laggards", () => {
  const tickers = [
    t("TOP1", "BUY", 5.0),
    t("TOP2", "BUY", 3.0),
    t("MID", "NEUTRAL", 0.1),
    t("BOT2", "SELL", -3.0),
    t("BOT1", "SELL", -5.0),
  ];

  it("topMovers sorted desc by changePercent", () => {
    const r = computeMarketBreadth(tickers);
    expect(r.topMovers[0]?.ticker).toBe("TOP1");
    expect(r.topMovers[1]?.ticker).toBe("TOP2");
  });

  it("topLaggards sorted asc by changePercent (worst first)", () => {
    const r = computeMarketBreadth(tickers);
    expect(r.topLaggards[0]?.ticker).toBe("BOT1");
    expect(r.topLaggards[1]?.ticker).toBe("BOT2");
  });

  it("respects topN option", () => {
    const r = computeMarketBreadth(tickers, { topN: 2 });
    expect(r.topMovers).toHaveLength(2);
    expect(r.topLaggards).toHaveLength(2);
  });

  it("returns <= topN when fewer tickers exist", () => {
    const r = computeMarketBreadth([t("A", "BUY", 1)], { topN: 3 });
    expect(r.topMovers).toHaveLength(1);
    expect(r.topLaggards).toHaveLength(1);
  });
});

// ─────────────────────────── classifyBreadthCondition ────────────────────────

describe("classifyBreadthCondition", () => {
  it("bullish when buyPct > 0.6 and aboveSma50Pct > 0.6", () => {
    const r = computeMarketBreadth([
      t("A", "BUY", 1, true),
      t("B", "BUY", 1, true),
      t("C", "BUY", 1, true),
      t("D", "NEUTRAL", 0, false),
    ]);
    expect(classifyBreadthCondition(r)).toBe("bullish");
  });

  it("bearish when sellPct > 0.6 and aboveSma50Pct < 0.4", () => {
    const r = computeMarketBreadth([
      t("A", "SELL", -1, false),
      t("B", "SELL", -1, false),
      t("C", "SELL", -1, false),
      t("D", "BUY", 1, true),
    ]);
    expect(classifyBreadthCondition(r)).toBe("bearish");
  });

  it("neutral when mixed signals", () => {
    const r = computeMarketBreadth([t("A", "BUY", 1, true), t("B", "SELL", -1, false)]);
    expect(classifyBreadthCondition(r)).toBe("neutral");
  });

  it("neutral for empty list", () => {
    const r = computeMarketBreadth([]);
    expect(classifyBreadthCondition(r)).toBe("neutral");
  });
});
