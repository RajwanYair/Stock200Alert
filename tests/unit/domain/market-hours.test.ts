/**
 * Unit tests for market-hours detection (R24).
 */
import { describe, it, expect } from "vitest";
import {
  SCHEDULES,
  isMarketOpen,
  marketStatus,
  allMarketStatuses,
  isAnyMarketOpen,
  openExchanges,
  shouldConnectWs,
} from "../../../src/domain/market-hours";
import type { ExchangeCode } from "../../../src/domain/market-hours";

// ── Helper: create a date at a specific time in a timezone ───────────────

/**
 * Build a Date that corresponds to a given local time in a given timezone.
 * This is approximate but sufficient for unit tests.
 */
function dateAtLocalTime(
  timezone: string,
  year: number,
  month: number,
  day: number,
  hours: number,
  minutes: number,
): Date {
  // Create a UTC date and adjust by testing offset
  const guess = new Date(Date.UTC(year, month - 1, day, hours, minutes));
  const fmt = new Intl.DateTimeFormat("en-US", {
    timeZone: timezone,
    hour: "numeric",
    minute: "numeric",
    hour12: false,
  });
  const parts = fmt.formatToParts(guess);
  const localH = Number(parts.find((p) => p.type === "hour")?.value ?? 0);
  const localM = Number(parts.find((p) => p.type === "minute")?.value ?? 0);
  const diffMin = hours * 60 + minutes - (localH * 60 + localM);
  return new Date(guess.getTime() + diffMin * 60_000);
}

// ── SCHEDULES ────────────────────────────────────────────────────────────

describe("SCHEDULES", () => {
  it("contains all 6 exchanges", () => {
    const codes: ExchangeCode[] = ["NYSE", "NASDAQ", "LSE", "TSE", "HKEX", "EURONEXT"];
    for (const code of codes) {
      expect(SCHEDULES[code]).toBeDefined();
      expect(SCHEDULES[code].timezone).toBeTruthy();
      expect(SCHEDULES[code].tradingDays.length).toBeGreaterThan(0);
    }
  });

  it("NYSE and NASDAQ share schedule", () => {
    expect(SCHEDULES.NYSE.openTime).toBe(SCHEDULES.NASDAQ.openTime);
    expect(SCHEDULES.NYSE.closeTime).toBe(SCHEDULES.NASDAQ.closeTime);
  });
});

// ── isMarketOpen ─────────────────────────────────────────────────────────

describe("isMarketOpen", () => {
  it("NYSE open at 10:00 ET on a Wednesday", () => {
    // Wednesday Jan 15, 2025 at 10:00 ET
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 10, 0);
    expect(isMarketOpen("NYSE", date)).toBe(true);
  });

  it("NYSE closed at 08:00 ET (before open)", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 8, 0);
    expect(isMarketOpen("NYSE", date)).toBe(false);
  });

  it("NYSE closed at 16:00 ET (at close)", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 16, 0);
    expect(isMarketOpen("NYSE", date)).toBe(false);
  });

  it("NYSE closed on Saturday", () => {
    // Saturday Jan 18, 2025
    const date = dateAtLocalTime("America/New_York", 2025, 1, 18, 12, 0);
    expect(isMarketOpen("NYSE", date)).toBe(false);
  });

  it("NYSE closed on Sunday", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 19, 12, 0);
    expect(isMarketOpen("NYSE", date)).toBe(false);
  });

  it("LSE open at 12:00 London on a Tuesday", () => {
    const date = dateAtLocalTime("Europe/London", 2025, 1, 14, 12, 0);
    expect(isMarketOpen("LSE", date)).toBe(true);
  });

  it("TSE open at 10:00 Tokyo on a Monday", () => {
    const date = dateAtLocalTime("Asia/Tokyo", 2025, 1, 13, 10, 0);
    expect(isMarketOpen("TSE", date)).toBe(true);
  });

  it("TSE closed at 16:00 Tokyo", () => {
    const date = dateAtLocalTime("Asia/Tokyo", 2025, 1, 13, 16, 0);
    expect(isMarketOpen("TSE", date)).toBe(false);
  });
});

// ── marketStatus ─────────────────────────────────────────────────────────

describe("marketStatus", () => {
  it("returns open status with nextCloseAt", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 11, 0);
    const status = marketStatus("NYSE", date);
    expect(status.isOpen).toBe(true);
    expect(status.nextCloseAt).toBeTruthy();
    expect(status.nextOpenAt).toBeNull();
    expect(status.openTime).toBe("09:30");
    expect(status.closeTime).toBe("16:00");
  });

  it("returns closed status with nextOpenAt", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 18, 0);
    const status = marketStatus("NYSE", date);
    expect(status.isOpen).toBe(false);
    expect(status.nextOpenAt).toBeTruthy();
    expect(status.nextCloseAt).toBeNull();
  });
});

// ── allMarketStatuses ────────────────────────────────────────────────────

describe("allMarketStatuses", () => {
  it("returns status for all 6 exchanges", () => {
    const statuses = allMarketStatuses(new Date());
    expect(statuses).toHaveLength(6);
    const codes = statuses.map((s) => s.exchange);
    expect(codes).toContain("NYSE");
    expect(codes).toContain("TSE");
  });
});

// ── isAnyMarketOpen ──────────────────────────────────────────────────────

describe("isAnyMarketOpen", () => {
  it("returns boolean", () => {
    expect(typeof isAnyMarketOpen()).toBe("boolean");
  });
});

// ── openExchanges ────────────────────────────────────────────────────────

describe("openExchanges", () => {
  it("returns only open exchanges during NYSE hours", () => {
    // Wed 10:00 ET — NYSE+NASDAQ open, others depend on timezone overlap
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 10, 0);
    const open = openExchanges(date);
    expect(open).toContain("NYSE");
    expect(open).toContain("NASDAQ");
  });

  it("returns empty on weekend", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 18, 12, 0);
    const open = openExchanges(date);
    expect(open).toEqual([]);
  });
});

// ── shouldConnectWs ──────────────────────────────────────────────────────

describe("shouldConnectWs", () => {
  it("returns true when any requested exchange is open", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 15, 10, 0);
    expect(shouldConnectWs(["NYSE", "LSE"], date)).toBe(true);
  });

  it("returns false when all requested exchanges are closed", () => {
    const date = dateAtLocalTime("America/New_York", 2025, 1, 18, 12, 0);
    expect(shouldConnectWs(["NYSE", "NASDAQ"], date)).toBe(false);
  });

  it("returns false for empty exchange list", () => {
    expect(shouldConnectWs([])).toBe(false);
  });
});
