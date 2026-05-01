import { describe, it, expect } from "vitest";
import { safeParse, parse } from "valibot";
import {
  DailyCandleSchema,
  YahooChartSchema,
  FinnhubQuoteSchema,
  FinnhubCandleSchema,
  FinnhubSearchSchema,
  YahooSearchSchema,
  IsoDateSchema,
  NonNegativeNumberSchema,
  TickerSchema,
  MethodSignalSchema,
  ConsensusResultSchema,
  AppConfigSchema,
  PolygonAggsSchema,
  CoinGeckoOhlcSchema,
  parseOrThrow,
} from "../../../src/types/valibot-schemas";

// ---------------------------------------------------------------------------
// IsoDateSchema
// ---------------------------------------------------------------------------
describe("IsoDateSchema", () => {
  it("accepts a valid ISO date", () => {
    const r = safeParse(IsoDateSchema, "2025-01-15");
    expect(r.success).toBe(true);
    if (r.success) expect(r.output).toBe("2025-01-15");
  });

  it("rejects a non-date string", () => {
    expect(safeParse(IsoDateSchema, "not-a-date").success).toBe(false);
  });

  it("rejects a number", () => {
    expect(safeParse(IsoDateSchema, 20250115).success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// NonNegativeNumberSchema
// ---------------------------------------------------------------------------
describe("NonNegativeNumberSchema", () => {
  it("accepts zero", () => {
    expect(safeParse(NonNegativeNumberSchema, 0).success).toBe(true);
  });

  it("accepts positive numbers", () => {
    expect(safeParse(NonNegativeNumberSchema, 123.45).success).toBe(true);
  });

  it("rejects negative numbers", () => {
    expect(safeParse(NonNegativeNumberSchema, -1).success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// DailyCandleSchema
// ---------------------------------------------------------------------------
describe("DailyCandleSchema", () => {
  const validCandle = {
    date: "2025-01-01",
    open: 100,
    high: 110,
    low: 90,
    close: 105,
    volume: 1_000_000,
  };

  it("accepts a valid candle", () => {
    const r = safeParse(DailyCandleSchema, validCandle);
    expect(r.success).toBe(true);
  });

  it("rejects missing close", () => {
    const { close: _, ...noClose } = validCandle;
    expect(safeParse(DailyCandleSchema, noClose).success).toBe(false);
  });

  it("rejects negative volume", () => {
    expect(safeParse(DailyCandleSchema, { ...validCandle, volume: -1 }).success).toBe(false);
  });

  it("rejects invalid date", () => {
    expect(safeParse(DailyCandleSchema, { ...validCandle, date: "bad" }).success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// YahooChartSchema
// ---------------------------------------------------------------------------
describe("YahooChartSchema", () => {
  it("accepts an empty chart wrapper", () => {
    expect(safeParse(YahooChartSchema, { chart: {} }).success).toBe(true);
  });

  it("accepts a realistic Yahoo history response", () => {
    const raw = {
      chart: {
        result: [
          {
            meta: { regularMarketPrice: 150, previousClose: 148, symbol: "AAPL" },
            timestamp: [1700000000, 1700086400],
            indicators: {
              quote: [
                {
                  open: [149, 151],
                  high: [152, 153],
                  low: [148, 150],
                  close: [150, 152],
                  volume: [10000000, 12000000],
                },
              ],
            },
          },
        ],
      },
    };
    const r = safeParse(YahooChartSchema, raw);
    expect(r.success).toBe(true);
  });

  it("accepts null values inside OHLCV arrays", () => {
    const raw = {
      chart: {
        result: [
          {
            meta: {},
            timestamp: [1700000000],
            indicators: {
              quote: [{ open: [null], high: [null], low: [null], close: [null], volume: [null] }],
            },
          },
        ],
      },
    };
    expect(safeParse(YahooChartSchema, raw).success).toBe(true);
  });

  it("rejects non-object input", () => {
    expect(safeParse(YahooChartSchema, "invalid").success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// FinnhubQuoteSchema
// ---------------------------------------------------------------------------
describe("FinnhubQuoteSchema", () => {
  it("accepts a valid Finnhub quote", () => {
    const r = safeParse(FinnhubQuoteSchema, {
      c: 150,
      o: 148,
      h: 152,
      l: 147,
      pc: 148,
      t: 1700000000,
    });
    expect(r.success).toBe(true);
  });

  it("accepts quote without optional timestamp", () => {
    expect(safeParse(FinnhubQuoteSchema, { c: 150, o: 148, h: 152, l: 147, pc: 148 }).success).toBe(
      true,
    );
  });

  it("rejects missing required fields", () => {
    expect(safeParse(FinnhubQuoteSchema, { c: 150 }).success).toBe(false);
  });

  it("rejects string price", () => {
    expect(
      safeParse(FinnhubQuoteSchema, { c: "150", o: 148, h: 152, l: 147, pc: 148 }).success,
    ).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// FinnhubCandleSchema
// ---------------------------------------------------------------------------
describe("FinnhubCandleSchema", () => {
  it("accepts an ok candle response", () => {
    const raw = {
      s: "ok",
      t: [1700000000],
      o: [148],
      h: [152],
      l: [147],
      c: [150],
      v: [10000000],
    };
    expect(safeParse(FinnhubCandleSchema, raw).success).toBe(true);
  });

  it("accepts no_data status", () => {
    expect(safeParse(FinnhubCandleSchema, { s: "no_data" }).success).toBe(true);
  });

  it("rejects unknown status", () => {
    expect(safeParse(FinnhubCandleSchema, { s: "error" }).success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// FinnhubSearchSchema
// ---------------------------------------------------------------------------
describe("FinnhubSearchSchema", () => {
  it("accepts a valid search result", () => {
    const raw = {
      result: [{ description: "Apple Inc.", displaySymbol: "AAPL", symbol: "AAPL", type: "EQS" }],
    };
    expect(safeParse(FinnhubSearchSchema, raw).success).toBe(true);
  });

  it("accepts empty result array", () => {
    expect(safeParse(FinnhubSearchSchema, { result: [] }).success).toBe(true);
  });

  it("accepts missing result key", () => {
    expect(safeParse(FinnhubSearchSchema, {}).success).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// YahooSearchSchema
// ---------------------------------------------------------------------------
describe("YahooSearchSchema", () => {
  it("accepts a valid search response", () => {
    const raw = {
      quotes: [{ symbol: "AAPL", shortname: "Apple Inc." }],
    };
    expect(safeParse(YahooSearchSchema, raw).success).toBe(true);
  });

  it("accepts empty quotes", () => {
    expect(safeParse(YahooSearchSchema, { quotes: [] }).success).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// TickerSchema (branded)
// ---------------------------------------------------------------------------
describe("TickerSchema", () => {
  it("normalizes via brand constructor", () => {
    expect(parse(TickerSchema, " aapl ")).toBe("AAPL");
  });

  it("rejects invalid ticker (digits only)", () => {
    expect(safeParse(TickerSchema, "123").success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// MethodSignalSchema
// ---------------------------------------------------------------------------
describe("MethodSignalSchema", () => {
  it("validates all required fields", () => {
    expect(
      parse(MethodSignalSchema, {
        ticker: "AAPL",
        method: "RSI",
        direction: "BUY",
        description: "RSI < 30",
        currentClose: 175.5,
        evaluatedAt: "2025-06-15T12:00:00Z",
      }),
    ).toBeDefined();
  });

  it("rejects unknown method", () => {
    expect(
      safeParse(MethodSignalSchema, {
        ticker: "AAPL",
        method: "UnknownMethod",
        direction: "BUY",
        description: "",
        currentClose: 100,
        evaluatedAt: "2025-06-15T12:00:00Z",
      }).success,
    ).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// ConsensusResultSchema
// ---------------------------------------------------------------------------
describe("ConsensusResultSchema", () => {
  it("requires unit-interval strength", () => {
    expect(
      safeParse(ConsensusResultSchema, {
        ticker: "AAPL",
        direction: "BUY",
        buyMethods: [],
        sellMethods: [],
        strength: 1.5,
      }).success,
    ).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// AppConfigSchema
// ---------------------------------------------------------------------------
describe("AppConfigSchema", () => {
  it("validates default config", () => {
    expect(parse(AppConfigSchema, { theme: "dark", watchlist: [] })).toBeDefined();
  });

  it("rejects bad theme", () => {
    expect(safeParse(AppConfigSchema, { theme: "neon", watchlist: [] }).success).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// PolygonAggsSchema
// ---------------------------------------------------------------------------
describe("PolygonAggsSchema", () => {
  it("accepts results-less response", () => {
    expect(parse(PolygonAggsSchema, { status: "OK" })).toBeDefined();
  });
});

// ---------------------------------------------------------------------------
// CoinGeckoOhlcSchema
// ---------------------------------------------------------------------------
describe("CoinGeckoOhlcSchema", () => {
  it("accepts tuple array", () => {
    expect(parse(CoinGeckoOhlcSchema, [[1718409600000, 100, 105, 99, 104]])).toHaveLength(1);
  });
});

// ---------------------------------------------------------------------------
// parseOrThrow
// ---------------------------------------------------------------------------
describe("parseOrThrow", () => {
  it("returns parsed value on success", () => {
    expect(parseOrThrow(IsoDateSchema, "2025-06-15", "Date")).toBe("2025-06-15");
  });

  it("throws on failure with schema name", () => {
    expect(() => parseOrThrow(IsoDateSchema, "bogus", "Date")).toThrow(/Date/);
  });
});
