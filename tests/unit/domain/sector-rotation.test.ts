/**
 * Tests for H20: Sector Rotation domain.
 */
import { describe, it, expect } from "vitest";
import {
  computeReturn,
  computeRelativeReturn,
  classifySectorPerformance,
  rankSectors,
  SECTOR_ETFS,
  type SectorReturnInput,
} from "../../../src/domain/sector-rotation";

// ─────────────────────────── computeReturn ───────────────────────────────────

describe("computeReturn", () => {
  it("calculates simple return correctly", () => {
    const closes = [100, 102, 104, 106, 108, 110];
    // days=5: (110 - 100) / 100 = 0.1
    expect(computeReturn(closes, 5)).toBeCloseTo(0.1);
  });

  it("returns 0 when insufficient data", () => {
    expect(computeReturn([100, 105], 5)).toBe(0);
  });

  it("returns 0 when start price is 0", () => {
    const closes = [0, 1, 2, 3, 4, 5];
    expect(computeReturn(closes, 5)).toBe(0);
  });

  it("returns 0 when start price is non-finite", () => {
    const closes = [NaN, 1, 2, 3, 4, 5];
    expect(computeReturn(closes, 5)).toBe(0);
  });

  it("handles negative return", () => {
    const closes = [100, 98, 96, 94, 92, 90];
    expect(computeReturn(closes, 5)).toBeCloseTo(-0.1);
  });

  it("single element array returns 0 for days=1", () => {
    expect(computeReturn([100], 1)).toBe(0);
  });
});

// ─────────────────────────── computeRelativeReturn ───────────────────────────

describe("computeRelativeReturn", () => {
  it("returns sector - benchmark", () => {
    expect(computeRelativeReturn(0.08, 0.05)).toBeCloseTo(0.03);
  });

  it("returns negative when sector underperforms", () => {
    expect(computeRelativeReturn(0.02, 0.07)).toBeCloseTo(-0.05);
  });

  it("returns 0 when equal", () => {
    expect(computeRelativeReturn(0.05, 0.05)).toBeCloseTo(0);
  });
});

// ─────────────────────────── classifySectorPerformance ───────────────────────

describe("classifySectorPerformance", () => {
  it("outperform when relativeReturn > default threshold (0.0025)", () => {
    expect(classifySectorPerformance(0.005)).toBe("outperform");
  });

  it("underperform when relativeReturn < -default threshold", () => {
    expect(classifySectorPerformance(-0.01)).toBe("underperform");
  });

  it("flat within threshold", () => {
    expect(classifySectorPerformance(0.001)).toBe("flat");
    expect(classifySectorPerformance(-0.001)).toBe("flat");
    expect(classifySectorPerformance(0)).toBe("flat");
  });

  it("respects custom threshold", () => {
    // threshold=0.01 — 0.005 should be flat
    expect(classifySectorPerformance(0.005, 0.01)).toBe("flat");
    expect(classifySectorPerformance(0.015, 0.01)).toBe("outperform");
  });
});

// ─────────────────────────── rankSectors ─────────────────────────────────────

describe("rankSectors", () => {
  const sectors: SectorReturnInput[] = [
    { ticker: "XLK", periodReturn: 0.1 },
    { ticker: "XLE", periodReturn: -0.05 },
    { ticker: "XLV", periodReturn: 0.03 },
  ];

  it("sorts by relative return descending (best rank=1)", () => {
    const result = rankSectors(sectors, 0);
    expect(result[0]?.ticker).toBe("XLK");
    expect(result[0]?.rank).toBe(1);
    expect(result[result.length - 1]?.ticker).toBe("XLE");
  });

  it("rank is 1-based and contiguous", () => {
    const result = rankSectors(sectors, 0);
    expect(result.map((r) => r.rank)).toEqual([1, 2, 3]);
  });

  it("calculates relativeReturn vs. benchmark", () => {
    const result = rankSectors([{ ticker: "XLK", periodReturn: 0.1 }], 0.05);
    expect(result[0]?.relativeReturn).toBeCloseTo(0.05);
  });

  it("assigns performance classification", () => {
    const result = rankSectors(sectors, 0);
    expect(result.find((r) => r.ticker === "XLK")?.performance).toBe("outperform");
    expect(result.find((r) => r.ticker === "XLE")?.performance).toBe("underperform");
  });

  it("returns empty array for empty input", () => {
    expect(rankSectors([])).toHaveLength(0);
  });

  it("does not mutate the input array", () => {
    const copy = [...sectors];
    rankSectors(sectors, 0.02);
    expect(sectors[0]?.ticker).toBe(copy[0]?.ticker);
  });

  it("all flat when returns equal benchmark", () => {
    const allFlat = sectors.map((s) => ({ ...s, periodReturn: 0.05 }));
    const result = rankSectors(allFlat, 0.05);
    expect(result.every((r) => r.performance === "flat")).toBe(true);
  });
});

// ─────────────────────────── SECTOR_ETFS catalogue ───────────────────────────

describe("SECTOR_ETFS", () => {
  it("contains exactly 11 sector ETFs", () => {
    expect(SECTOR_ETFS).toHaveLength(11);
  });

  it("includes XLK and XLE", () => {
    expect(SECTOR_ETFS).toContain("XLK");
    expect(SECTOR_ETFS).toContain("XLE");
  });
});
