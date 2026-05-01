import { describe, it, expect } from "vitest";
import {
  isTicker,
  asTicker,
  isISODate,
  asISODate,
  isPrice,
  asPrice,
  isPercent,
  asPercent,
  tryTicker,
} from "../../../src/domain/branded";

describe("branded", () => {
  it("isTicker accepts canonical tickers", () => {
    expect(isTicker("AAPL")).toBe(true);
    expect(isTicker("BRK.B")).toBe(true);
    expect(isTicker("X")).toBe(true);
  });

  it("isTicker rejects garbage", () => {
    expect(isTicker("aapl")).toBe(false);
    expect(isTicker("")).toBe(false);
    expect(isTicker("TOOLONGTICKER")).toBe(false);
    expect(isTicker(123)).toBe(false);
  });

  it("asTicker normalizes case and trims", () => {
    expect(asTicker(" aapl ")).toBe("AAPL");
  });

  it("asTicker throws on invalid", () => {
    expect(() => asTicker("aa pl")).toThrow();
  });

  it("tryTicker returns null on invalid", () => {
    expect(tryTicker("!!!")).toBeNull();
    expect(tryTicker("msft")).toBe("MSFT");
  });

  it("isISODate accepts both date and datetime", () => {
    expect(isISODate("2024-01-01")).toBe(true);
    expect(isISODate("2024-01-01T12:34:56Z")).toBe(true);
    expect(isISODate("2024-01-01T12:34:56.789+02:00")).toBe(true);
  });

  it("isISODate rejects unparseable", () => {
    expect(isISODate("not-a-date")).toBe(false);
    expect(isISODate("2024-13-01")).toBe(false);
  });

  it("asISODate throws on bad input", () => {
    expect(() => asISODate("nope")).toThrow();
  });

  it("isPrice rejects negatives, NaN, non-numbers", () => {
    expect(isPrice(0)).toBe(true);
    expect(isPrice(100.25)).toBe(true);
    expect(isPrice(-1)).toBe(false);
    expect(isPrice(NaN)).toBe(false);
    expect(isPrice("100")).toBe(false);
  });

  it("asPrice throws on negative", () => {
    expect(() => asPrice(-1)).toThrow();
  });

  it("isPercent allows negatives", () => {
    expect(isPercent(-5)).toBe(true);
    expect(isPercent(NaN)).toBe(false);
  });

  it("asPercent passes through", () => {
    expect(asPercent(12.5)).toBe(12.5);
  });
});
