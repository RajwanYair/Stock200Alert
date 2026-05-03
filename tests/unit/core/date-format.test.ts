/**
 * Unit tests for core date-format module (R8).
 */
import { describe, it, expect } from "vitest";
import {
  formatDate,
  isoDate,
  isoTime,
  isoDateTime,
  parseIsoDate,
  relativeTime,
  isWeekday,
  previousWeekday,
  nextWeekday,
  tradingDaysBetween,
} from "../../../src/core/date-format";

// ── formatDate ───────────────────────────────────────────────────────────

describe("formatDate", () => {
  const d = new Date(Date.UTC(2025, 0, 15, 9, 5, 3, 42)); // 2025-01-15T09:05:03.042Z

  it("formats YYYY-MM-DD", () => {
    expect(formatDate(d, "YYYY-MM-DD")).toBe("2025-01-15");
  });

  it("formats HH:mm:ss", () => {
    expect(formatDate(d, "HH:mm:ss")).toBe("09:05:03");
  });

  it("formats SSS (milliseconds)", () => {
    expect(formatDate(d, "HH:mm:ss.SSS")).toBe("09:05:03.042");
  });

  it("accepts number (unix-ms)", () => {
    expect(formatDate(d.getTime(), "YYYY")).toBe("2025");
  });

  it("handles repeated tokens", () => {
    expect(formatDate(d, "YYYY/YYYY")).toBe("2025/2025");
  });
});

// ── isoDate / isoTime / isoDateTime ─────────────────────────────────────

describe("isoDate", () => {
  it("formats YYYY-MM-DD", () => {
    expect(isoDate(new Date(Date.UTC(2024, 11, 31)))).toBe("2024-12-31");
  });
});

describe("isoTime", () => {
  it("formats HH:mm:ss", () => {
    expect(isoTime(new Date(Date.UTC(2025, 0, 1, 14, 30, 59)))).toBe("14:30:59");
  });
});

describe("isoDateTime", () => {
  it("includes T separator and Z suffix", () => {
    const result = isoDateTime(new Date(Date.UTC(2025, 0, 1, 0, 0, 0)));
    expect(result).toBe("2025-01-01T00:00:00Z");
  });
});

// ── parseIsoDate ─────────────────────────────────────────────────────────

describe("parseIsoDate", () => {
  it("parses valid YYYY-MM-DD", () => {
    const d = parseIsoDate("2025-06-15");
    expect(d).not.toBeNull();
    expect(d!.getUTCFullYear()).toBe(2025);
    expect(d!.getUTCMonth()).toBe(5); // June = 5
    expect(d!.getUTCDate()).toBe(15);
  });

  it("returns null for invalid format", () => {
    expect(parseIsoDate("2025/06/15")).toBeNull();
    expect(parseIsoDate("not-a-date")).toBeNull();
    expect(parseIsoDate("")).toBeNull();
  });

  it("returns null for out-of-range month", () => {
    expect(parseIsoDate("2025-13-01")).toBeNull();
    expect(parseIsoDate("2025-00-01")).toBeNull();
  });

  it("returns null for impossible day (Feb 30)", () => {
    expect(parseIsoDate("2025-02-30")).toBeNull();
  });

  it("handles leap year Feb 29", () => {
    const d = parseIsoDate("2024-02-29");
    expect(d).not.toBeNull();
    expect(d!.getUTCDate()).toBe(29);
  });

  it("rejects Feb 29 on non-leap year", () => {
    expect(parseIsoDate("2025-02-29")).toBeNull();
  });
});

// ── relativeTime ─────────────────────────────────────────────────────────

describe("relativeTime", () => {
  const now = 1_700_000_000_000;

  it("returns seconds ago", () => {
    expect(relativeTime(now - 30_000, now)).toBe("30s ago");
  });

  it("returns minutes ago", () => {
    expect(relativeTime(now - 5 * 60_000, now)).toBe("5m ago");
  });

  it("returns hours ago", () => {
    expect(relativeTime(now - 3 * 3_600_000, now)).toBe("3h ago");
  });

  it("returns days ago", () => {
    expect(relativeTime(now - 2 * 86_400_000, now)).toBe("2d ago");
  });

  it("future timestamps return just now", () => {
    expect(relativeTime(now + 10_000, now)).toBe("just now");
  });

  it("0 seconds ago", () => {
    expect(relativeTime(now, now)).toBe("0s ago");
  });
});

// ── isWeekday ────────────────────────────────────────────────────────────

describe("isWeekday", () => {
  it("Monday is weekday", () => {
    // 2025-01-13 = Monday
    expect(isWeekday(new Date(Date.UTC(2025, 0, 13)))).toBe(true);
  });

  it("Saturday is not weekday", () => {
    // 2025-01-11 = Saturday
    expect(isWeekday(new Date(Date.UTC(2025, 0, 11)))).toBe(false);
  });

  it("Sunday is not weekday", () => {
    // 2025-01-12 = Sunday
    expect(isWeekday(new Date(Date.UTC(2025, 0, 12)))).toBe(false);
  });
});

// ── previousWeekday ──────────────────────────────────────────────────────

describe("previousWeekday", () => {
  it("Monday → Friday", () => {
    const mon = new Date(Date.UTC(2025, 0, 13)); // Monday
    const prev = previousWeekday(mon);
    expect(prev.getUTCDay()).toBe(5); // Friday
    expect(prev.getUTCDate()).toBe(10);
  });

  it("Wednesday → Tuesday", () => {
    const wed = new Date(Date.UTC(2025, 0, 15)); // Wednesday
    const prev = previousWeekday(wed);
    expect(prev.getUTCDay()).toBe(2); // Tuesday
  });
});

// ── nextWeekday ──────────────────────────────────────────────────────────

describe("nextWeekday", () => {
  it("Friday → Monday", () => {
    const fri = new Date(Date.UTC(2025, 0, 10)); // Friday
    const next = nextWeekday(fri);
    expect(next.getUTCDay()).toBe(1); // Monday
    expect(next.getUTCDate()).toBe(13);
  });

  it("Tuesday → Wednesday", () => {
    const tue = new Date(Date.UTC(2025, 0, 14)); // Tuesday
    const next = nextWeekday(tue);
    expect(next.getUTCDay()).toBe(3); // Wednesday
  });
});

// ── tradingDaysBetween ───────────────────────────────────────────────────

describe("tradingDaysBetween", () => {
  it("Mon to Fri = 5 trading days", () => {
    const mon = new Date(Date.UTC(2025, 0, 13));
    const sat = new Date(Date.UTC(2025, 0, 18)); // exclusive end
    expect(tradingDaysBetween(mon, sat)).toBe(5);
  });

  it("Fri to Mon = 1 trading day (Friday)", () => {
    const fri = new Date(Date.UTC(2025, 0, 10));
    const mon = new Date(Date.UTC(2025, 0, 13));
    expect(tradingDaysBetween(fri, mon)).toBe(1);
  });

  it("same day = 0", () => {
    const d = new Date(Date.UTC(2025, 0, 15));
    expect(tradingDaysBetween(d, d)).toBe(0);
  });

  it("two full weeks = 10 trading days", () => {
    const start = new Date(Date.UTC(2025, 0, 6)); // Monday
    const end = new Date(Date.UTC(2025, 0, 20)); // Monday (exclusive)
    expect(tradingDaysBetween(start, end)).toBe(10);
  });
});
