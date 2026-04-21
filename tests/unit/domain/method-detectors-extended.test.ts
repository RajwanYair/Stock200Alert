/**
 * Extended method detector tests — edge cases and cross-method validation.
 */
import { describe, it, expect } from "vitest";
import { evaluate as evalMacd } from "../../../src/domain/macd-method";
import { evaluate as evalBollinger } from "../../../src/domain/bollinger-method";
import { evaluate as evalStochastic } from "../../../src/domain/stochastic-method";
import { evaluate as evalObv } from "../../../src/domain/obv-method";
import { evaluate as evalAdx } from "../../../src/domain/adx-method";
import { evaluate as evalCci } from "../../../src/domain/cci-method";
import { evaluate as evalSar } from "../../../src/domain/sar-method";
import { evaluate as evalWilliamsR } from "../../../src/domain/williams-r-method";
import { evaluate as evalMfi } from "../../../src/domain/mfi-method";
import { evaluate as evalSupertrend } from "../../../src/domain/supertrend-method";
import { makeCandles } from "../../helpers/candle-factory";

const ENOUGH_DATA = Array.from({ length: 60 }, (_, i) => 100 + Math.sin(i / 5) * 20);
const TOO_FEW = [100, 101];
const FLAT = Array.from({ length: 60 }, () => 100);

const detectors = [
  { name: "MACD", fn: evalMacd, method: "MACD" },
  { name: "Bollinger", fn: evalBollinger, method: "Bollinger" },
  { name: "Stochastic", fn: evalStochastic, method: "Stochastic" },
  { name: "OBV", fn: evalObv, method: "OBV" },
  { name: "ADX", fn: evalAdx, method: "ADX" },
  { name: "CCI", fn: evalCci, method: "CCI" },
  { name: "SAR", fn: evalSar, method: "SAR" },
  { name: "WilliamsR", fn: evalWilliamsR, method: "WilliamsR" },
  { name: "MFI", fn: evalMfi, method: "MFI" },
  { name: "SuperTrend", fn: evalSupertrend, method: "SuperTrend" },
] as const;

describe("method detectors — shared contract", () => {
  for (const { name, fn, method } of detectors) {
    describe(name, () => {
      it("returns null for insufficient data", () => {
        expect(fn("AAPL", makeCandles(TOO_FEW))).toBeNull();
      });

      it("returns a MethodSignal or null for sufficient data", () => {
        const result = fn("AAPL", makeCandles(ENOUGH_DATA));
        if (result !== null) {
          expect(result.ticker).toBe("AAPL");
          expect(result.method).toBe(method);
          expect(["BUY", "SELL", "NEUTRAL"]).toContain(result.direction);
          expect(result.description).toBeTypeOf("string");
          expect(result.description.length).toBeGreaterThan(0);
          expect(result.currentClose).toBeTypeOf("number");
          expect(result.evaluatedAt).toBeTypeOf("string");
        }
      });

      it("uses the correct ticker in result", () => {
        const result = fn("MSFT", makeCandles(ENOUGH_DATA));
        if (result !== null) {
          expect(result.ticker).toBe("MSFT");
        }
      });

      it("handles flat prices without crashing", () => {
        // Should not throw, may return null or NEUTRAL
        expect(() => fn("AAPL", makeCandles(FLAT))).not.toThrow();
      });
    });
  }
});
