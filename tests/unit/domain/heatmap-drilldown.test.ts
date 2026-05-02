/**
 * Tests for G21 — Heatmap Sector Drill-down domain helpers.
 */
import { describe, it, expect } from "vitest";
import {
  computeAbsoluteMove,
  buildDrilldownEntries,
  sortDrilldown,
  buildBreadcrumb,
  buildDrilldown,
  computeAttributionBar,
} from "../../../src/domain/heatmap-drilldown";
import type { ConstituentStock } from "../../../src/cards/heatmap";

// ─── fixtures ────────────────────────────────────────────────────────────────

const TECH_CONSTITUENTS: ConstituentStock[] = [
  { ticker: "AAPL", name: "Apple Inc.", price: 180, changePercent: 2, weight: 0.5 },
  { ticker: "MSFT", name: "Microsoft", price: 400, changePercent: -1, weight: 0.3 },
  { ticker: "NVDA", name: "Nvidia", price: 800, changePercent: 5, weight: 0.2 },
];

// ─── computeAbsoluteMove ─────────────────────────────────────────────────────

describe("computeAbsoluteMove", () => {
  it("positive change * weight", () => {
    expect(computeAbsoluteMove(2, 0.5)).toBeCloseTo(1);
  });

  it("negative change is treated as absolute", () => {
    expect(computeAbsoluteMove(-3, 0.4)).toBeCloseTo(1.2);
  });

  it("zero weight → 0", () => {
    expect(computeAbsoluteMove(10, 0)).toBe(0);
  });

  it("zero change → 0", () => {
    expect(computeAbsoluteMove(0, 0.5)).toBe(0);
  });
});

// ─── buildDrilldownEntries ────────────────────────────────────────────────────

describe("buildDrilldownEntries", () => {
  const entries = buildDrilldownEntries(TECH_CONSTITUENTS);

  it("produces one entry per valid constituent", () => {
    expect(entries).toHaveLength(3);
  });

  it("attribution fractions sum to 1", () => {
    const sum = entries.reduce((s, e) => s + e.attribution, 0);
    expect(sum).toBeCloseTo(1);
  });

  it("cellArea equals constituent weight", () => {
    const aapl = entries.find((e) => e.ticker === "AAPL");
    expect(aapl?.cellArea).toBeCloseTo(0.5);
  });

  it("absoluteMove = |changePercent × weight|", () => {
    const nvda = entries.find((e) => e.ticker === "NVDA");
    expect(nvda?.absoluteMove).toBeCloseTo(1); // |5 × 0.2|
  });

  it("skips entries with weight <= 0", () => {
    const withZero: ConstituentStock[] = [
      ...TECH_CONSTITUENTS,
      { ticker: "BAD", price: 100, changePercent: 10, weight: 0 },
    ];
    const result = buildDrilldownEntries(withZero);
    expect(result.some((e) => e.ticker === "BAD")).toBe(false);
  });

  it("returns empty array for empty input", () => {
    expect(buildDrilldownEntries([])).toHaveLength(0);
  });

  it("preserves name field", () => {
    const aapl = entries.find((e) => e.ticker === "AAPL");
    expect(aapl?.name).toBe("Apple Inc.");
  });
});

// ─── sortDrilldown ───────────────────────────────────────────────────────────

describe("sortDrilldown", () => {
  const entries = buildDrilldownEntries(TECH_CONSTITUENTS);

  it("default sort is absoluteMove descending", () => {
    const sorted = sortDrilldown(entries);
    // AAPL: |2*0.5|=1, NVDA: |5*0.2|=1, MSFT: |-1*0.3|=0.3 → tied AAPL/NVDA then MSFT
    const last = sorted[sorted.length - 1];
    expect(last?.ticker).toBe("MSFT");
  });

  it("sort by changePercent descending puts NVDA first (highest +5%)", () => {
    const sorted = sortDrilldown(entries, "changePercent");
    expect(sorted[0]?.ticker).toBe("NVDA");
  });

  it("sort by weight descending puts AAPL first (0.5 weight)", () => {
    const sorted = sortDrilldown(entries, "weight");
    expect(sorted[0]?.ticker).toBe("AAPL");
  });

  it("does not mutate input array", () => {
    const copy = [...entries];
    sortDrilldown(entries, "weight");
    expect(entries.map((e) => e.ticker)).toEqual(copy.map((e) => e.ticker));
  });
});

// ─── buildBreadcrumb ─────────────────────────────────────────────────────────

describe("buildBreadcrumb", () => {
  it("returns [All Sectors, <sector>]", () => {
    expect(buildBreadcrumb("Technology")).toEqual(["All Sectors", "Technology"]);
  });

  it("works for any sector name", () => {
    const bc = buildBreadcrumb("Energy");
    expect(bc[0]).toBe("All Sectors");
    expect(bc[1]).toBe("Energy");
  });
});

// ─── buildDrilldown ──────────────────────────────────────────────────────────

describe("buildDrilldown", () => {
  const result = buildDrilldown("Technology", TECH_CONSTITUENTS);

  it("preserves sector name", () => {
    expect(result.sector).toBe("Technology");
  });

  it("sets topContributor to highest absoluteMove ticker", () => {
    // AAPL: 1, NVDA: 1, MSFT: 0.3 — AAPL should be first after sort
    expect(["AAPL", "NVDA"]).toContain(result.topContributor);
  });

  it("breadcrumb ends with sector name", () => {
    expect(result.breadcrumb[result.breadcrumb.length - 1]).toBe("Technology");
  });

  it("returns empty entries for empty constituents", () => {
    const r = buildDrilldown("Utilities", []);
    expect(r.entries).toHaveLength(0);
    expect(r.topContributor).toBeNull();
  });

  it("custom sort by changePercent is applied", () => {
    const r = buildDrilldown("Technology", TECH_CONSTITUENTS, "changePercent");
    expect(r.entries[0]?.ticker).toBe("NVDA");
  });
});

// ─── computeAttributionBar ────────────────────────────────────────────────────

describe("computeAttributionBar", () => {
  const result = buildDrilldown("Technology", TECH_CONSTITUENTS);

  it("fractions sum to 1", () => {
    const bar = computeAttributionBar(result);
    const sum = bar.reduce((s, b) => s + b.fraction, 0);
    expect(sum).toBeCloseTo(1);
  });

  it("sorted descending by fraction", () => {
    const bar = computeAttributionBar(result);
    for (let i = 0; i < bar.length - 1; i++) {
      expect(bar[i]!.fraction).toBeGreaterThanOrEqual(bar[i + 1]!.fraction);
    }
  });

  it("returns empty array for empty result", () => {
    const empty = buildDrilldown("Empty", []);
    expect(computeAttributionBar(empty)).toHaveLength(0);
  });
});
