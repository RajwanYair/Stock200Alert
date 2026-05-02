/**
 * Unit tests for Transferable Float64Array OHLCV helpers (G4).
 */
import { describe, it, expect } from "vitest";
import {
  STRIDE,
  Field,
  packOhlcv,
  unpackOhlcv,
  extractColumn,
  packFromColumns,
  slicePacked,
  collectTransferables,
} from "../../../src/core/transferable-ohlc";
import type { OhlcvRow } from "../../../src/core/transferable-ohlc";

// ── Fixtures ─────────────────────────────────────────────────────────────

const rows: OhlcvRow[] = [
  { open: 100, high: 110, low: 95, close: 105, volume: 1000, timestamp: 1700000000000 },
  { open: 105, high: 115, low: 100, close: 112, volume: 2000, timestamp: 1700086400000 },
  { open: 112, high: 120, low: 108, close: 118, volume: 1500, timestamp: 1700172800000 },
];

// ── STRIDE / Field ───────────────────────────────────────────────────────

describe("STRIDE", () => {
  it("equals 6 (O, H, L, C, V, T)", () => {
    expect(STRIDE).toBe(6);
  });
});

describe("Field", () => {
  it("maps field offsets 0–5", () => {
    expect(Field.Open).toBe(0);
    expect(Field.High).toBe(1);
    expect(Field.Low).toBe(2);
    expect(Field.Close).toBe(3);
    expect(Field.Volume).toBe(4);
    expect(Field.Timestamp).toBe(5);
  });
});

// ── packOhlcv / unpackOhlcv ──────────────────────────────────────────────

describe("packOhlcv", () => {
  it("packs rows into Float64Array with correct length", () => {
    const packed = packOhlcv(rows);
    expect(packed.length).toBe(3);
    expect(packed.buffer).toBeInstanceOf(Float64Array);
    expect(packed.buffer.length).toBe(3 * STRIDE);
  });

  it("stores values at correct offsets", () => {
    const packed = packOhlcv(rows);
    expect(packed.buffer[0]).toBe(100); // open[0]
    expect(packed.buffer[1]).toBe(110); // high[0]
    expect(packed.buffer[4]).toBe(1000); // volume[0]
    expect(packed.buffer[6]).toBe(105); // open[1]
  });

  it("handles empty input", () => {
    const packed = packOhlcv([]);
    expect(packed.length).toBe(0);
    expect(packed.buffer.length).toBe(0);
  });
});

describe("unpackOhlcv", () => {
  it("round-trips pack → unpack", () => {
    const packed = packOhlcv(rows);
    const unpacked = unpackOhlcv(packed.buffer, packed.length);
    expect(unpacked).toEqual(rows);
  });

  it("throws on undersized buffer", () => {
    expect(() => unpackOhlcv(new Float64Array(5), 2)).toThrow(RangeError);
  });

  it("handles empty buffer", () => {
    const result = unpackOhlcv(new Float64Array(0), 0);
    expect(result).toEqual([]);
  });

  it("preserves timestamp precision", () => {
    const packed = packOhlcv(rows);
    const unpacked = unpackOhlcv(packed.buffer, packed.length);
    expect(unpacked[0].timestamp).toBe(1700000000000);
  });
});

// ── extractColumn ────────────────────────────────────────────────────────

describe("extractColumn", () => {
  it("extracts close column", () => {
    const packed = packOhlcv(rows);
    const closes = extractColumn(packed.buffer, packed.length, Field.Close);
    expect(Array.from(closes)).toEqual([105, 112, 118]);
  });

  it("extracts volume column", () => {
    const packed = packOhlcv(rows);
    const vols = extractColumn(packed.buffer, packed.length, Field.Volume);
    expect(Array.from(vols)).toEqual([1000, 2000, 1500]);
  });

  it("returns empty for zero length", () => {
    const col = extractColumn(new Float64Array(0), 0, Field.Open);
    expect(col.length).toBe(0);
  });
});

// ── packFromColumns ──────────────────────────────────────────────────────

describe("packFromColumns", () => {
  it("packs columns and round-trips with unpack", () => {
    const o = new Float64Array([100, 105, 112]);
    const h = new Float64Array([110, 115, 120]);
    const l = new Float64Array([95, 100, 108]);
    const c = new Float64Array([105, 112, 118]);
    const v = new Float64Array([1000, 2000, 1500]);
    const t = new Float64Array([1700000000000, 1700086400000, 1700172800000]);

    const packed = packFromColumns(o, h, l, c, v, t);
    const unpacked = unpackOhlcv(packed.buffer, packed.length);
    expect(unpacked).toEqual(rows);
  });

  it("throws on mismatched column lengths", () => {
    const short = new Float64Array([1]);
    const long = new Float64Array([1, 2]);
    expect(() => packFromColumns(short, long, short, short, short, short)).toThrow(RangeError);
  });
});

// ── slicePacked ──────────────────────────────────────────────────────────

describe("slicePacked", () => {
  it("slices middle range", () => {
    const packed = packOhlcv(rows);
    const sliced = slicePacked(packed, 1, 3);
    expect(sliced.length).toBe(2);
    const unpacked = unpackOhlcv(sliced.buffer, sliced.length);
    expect(unpacked[0].open).toBe(105);
    expect(unpacked[1].open).toBe(112);
  });

  it("clamps out-of-range indices", () => {
    const packed = packOhlcv(rows);
    const sliced = slicePacked(packed, -5, 100);
    expect(sliced.length).toBe(3);
  });

  it("returns empty when start >= end", () => {
    const packed = packOhlcv(rows);
    const sliced = slicePacked(packed, 5);
    expect(sliced.length).toBe(0);
    expect(sliced.buffer.length).toBe(0);
  });

  it("defaults end to packed.length", () => {
    const packed = packOhlcv(rows);
    const sliced = slicePacked(packed, 1);
    expect(sliced.length).toBe(2);
  });
});

// ── collectTransferables ─────────────────────────────────────────────────

describe("collectTransferables", () => {
  it("returns array containing the underlying ArrayBuffer", () => {
    const packed = packOhlcv(rows);
    const transfers = collectTransferables(packed);
    expect(transfers).toHaveLength(1);
    expect(transfers[0]).toBe(packed.buffer.buffer);
  });
});
