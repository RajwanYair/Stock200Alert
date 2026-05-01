/**
 * i18n foundation tests (C1).
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import {
  getLocale,
  formatNumber,
  formatCompact,
  formatCurrency,
  formatPercent,
  formatDate,
  formatDateTime,
  formatRelativeTime,
  formatTimeAgo,
} from "../../../src/core/i18n";

// Force a stable locale for all tests
const TEST_LOCALE = "en-US";

describe("getLocale", () => {
  it("returns navigator.language when available", () => {
    vi.stubGlobal("navigator", { language: "fr-FR" });
    expect(getLocale()).toBe("fr-FR");
    vi.unstubAllGlobals();
  });

  it("falls back to 'en' when navigator is unavailable", () => {
    vi.stubGlobal("navigator", undefined);
    expect(getLocale()).toBe("en");
    vi.unstubAllGlobals();
  });
});

describe("formatNumber", () => {
  it("formats with default 0-2 fraction digits", () => {
    expect(formatNumber(1234567.89, { locale: TEST_LOCALE })).toBe("1,234,567.89");
  });

  it("formats integer with no trailing decimal", () => {
    expect(formatNumber(1000, { locale: TEST_LOCALE })).toBe("1,000");
  });

  it("respects custom fractionDigits", () => {
    expect(
      formatNumber(1.2345, {
        locale: TEST_LOCALE,
        minimumFractionDigits: 4,
        maximumFractionDigits: 4,
      }),
    ).toBe("1.2345");
  });

  it("compact notation abbreviates large numbers", () => {
    expect(
      formatNumber(1_500_000, {
        locale: TEST_LOCALE,
        notation: "compact",
        maximumFractionDigits: 1,
      }),
    ).toBe("1.5M");
  });
});

describe("formatCompact", () => {
  it("abbreviates billions", () => {
    expect(formatCompact(2_400_000_000, TEST_LOCALE)).toBe("2.4B");
  });

  it("abbreviates millions", () => {
    expect(formatCompact(750_000, TEST_LOCALE)).toBe("750K");
  });
});

describe("formatCurrency", () => {
  it("formats USD with dollar symbol", () => {
    expect(formatCurrency(49.99, "USD", { locale: TEST_LOCALE })).toBe("$49.99");
  });

  it("formats EUR with currency code display", () => {
    const result = formatCurrency(100, "EUR", { locale: TEST_LOCALE, display: "code" });
    expect(result).toContain("EUR");
  });
});

describe("formatPercent", () => {
  it("formats a ratio (0.0512) as 5.12%", () => {
    expect(formatPercent(0.0512, { locale: TEST_LOCALE })).toBe("5.12%");
  });

  it("formats already-percent value (5.12) as 5.12%", () => {
    expect(formatPercent(5.12, { locale: TEST_LOCALE, alreadyPercent: true })).toBe("5.12%");
  });

  it("respects fractionDigits", () => {
    expect(formatPercent(0.5, { locale: TEST_LOCALE, fractionDigits: 0 })).toBe("50%");
  });
});

describe("formatDate", () => {
  it("returns a non-empty string for a valid date", () => {
    const result = formatDate(new Date(2025, 0, 15), "medium", { locale: TEST_LOCALE });
    expect(result).toContain("2025");
  });

  it("accepts a numeric timestamp", () => {
    const result = formatDate(0, "short", { locale: TEST_LOCALE });
    expect(typeof result).toBe("string");
    expect(result.length).toBeGreaterThan(0);
  });
});

describe("formatDateTime", () => {
  it("includes both date and time components", () => {
    const result = formatDateTime(new Date(2025, 5, 15, 14, 30), "medium", "short", TEST_LOCALE);
    expect(result).toContain("2025");
    // Should include time indicator (AM/PM or hour)
    expect(result.length).toBeGreaterThan(8);
  });
});

describe("formatRelativeTime", () => {
  it("returns 'yesterday' for -1 day with auto numeric", () => {
    const result = formatRelativeTime(-1, "day", { locale: TEST_LOCALE, numeric: "auto" });
    expect(result).toBe("yesterday");
  });

  it("returns '2 days ago' for -2 days", () => {
    const result = formatRelativeTime(-2, "day", { locale: TEST_LOCALE });
    expect(result).toBe("2 days ago");
  });

  it("returns 'in 3 hours' for +3 hours", () => {
    const result = formatRelativeTime(3, "hour", { locale: TEST_LOCALE });
    expect(result).toBe("in 3 hours");
  });
});

describe("formatTimeAgo", () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it("returns seconds ago for very recent timestamp", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2025-06-15T12:00:00Z"));
    const ts = new Date("2025-06-15T11:59:50Z");
    const result = formatTimeAgo(ts, { locale: TEST_LOCALE });
    expect(result).toContain("second");
  });

  it("returns minutes ago for timestamp about 5 minutes old", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2025-06-15T12:00:00Z"));
    const ts = new Date("2025-06-15T11:55:00Z");
    const result = formatTimeAgo(ts, { locale: TEST_LOCALE });
    expect(result).toContain("minute");
  });

  it("returns days ago for timestamp multiple days old", () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2025-06-20T12:00:00Z"));
    const ts = new Date("2025-06-15T12:00:00Z");
    const result = formatTimeAgo(ts, { locale: TEST_LOCALE });
    expect(result).toContain("day");
  });
});
