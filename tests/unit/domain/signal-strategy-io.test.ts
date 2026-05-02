/**
 * Unit tests for shared signal strategy I/O (I6).
 */
import { describe, it, expect } from "vitest";
import {
  exportStrategy,
  importStrategy,
  exportBundle,
  importBundle,
  validateExpression,
  validateVars,
  checksumPayload,
  encodeShareUrl,
  decodeShareUrl,
  payloadToClipboardText,
} from "../../../src/domain/signal-strategy-io";
import type { StrategyPayload } from "../../../src/domain/signal-strategy-io";

// ── helpers ──────────────────────────────────────────────────────────────

function mkPayload(overrides: Partial<StrategyPayload> = {}): StrategyPayload {
  const p: StrategyPayload = {
    version: 1,
    name: "RSI Oversold",
    expression: "rsi(14) < threshold",
    vars: { threshold: 30 },
    createdAt: "2025-07-01T00:00:00.000Z",
    checksum: "",
    ...overrides,
  };
  p.checksum = checksumPayload(p);
  return p;
}

// ── exportStrategy ────────────────────────────────────────────────────────

describe("exportStrategy", () => {
  it("creates a valid payload", () => {
    const p = exportStrategy("My Strat", "sma(20) > sma(50)", { fast: 20 });
    expect(p.version).toBe(1);
    expect(p.name).toBe("My Strat");
    expect(p.expression).toBe("sma(20) > sma(50)");
    expect(p.vars).toEqual({ fast: 20 });
    expect(p.createdAt).toBeTruthy();
    expect(p.checksum).toBeTruthy();
  });

  it("trims name and expression", () => {
    const p = exportStrategy("  My Strat  ", "  expr  ");
    expect(p.name).toBe("My Strat");
    expect(p.expression).toBe("expr");
  });

  it("defaults empty name to Untitled", () => {
    const p = exportStrategy("", "expr");
    expect(p.name).toBe("Untitled");
  });

  it("defaults vars to empty object", () => {
    const p = exportStrategy("test", "expr");
    expect(p.vars).toEqual({});
  });
});

// ── importStrategy ────────────────────────────────────────────────────────

describe("importStrategy", () => {
  it("round-trips a valid payload", () => {
    const original = mkPayload();
    const json = JSON.stringify(original);
    const result = importStrategy(json);
    expect(result.ok).toBe(true);
    expect(result.data?.name).toBe(original.name);
    expect(result.data?.expression).toBe(original.expression);
  });

  it("rejects invalid JSON", () => {
    const result = importStrategy("{bad");
    expect(result.ok).toBe(false);
    expect(result.error).toContain("Invalid JSON");
  });

  it("rejects non-object", () => {
    const result = importStrategy('"string"');
    expect(result.ok).toBe(false);
  });

  it("rejects wrong version", () => {
    const p = mkPayload();
    const json = JSON.stringify({ ...p, version: 2 });
    expect(importStrategy(json).ok).toBe(false);
  });

  it("rejects missing name", () => {
    const p = mkPayload();
    const json = JSON.stringify({ ...p, name: "" });
    expect(importStrategy(json).ok).toBe(false);
  });

  it("rejects missing expression", () => {
    const p = mkPayload();
    const json = JSON.stringify({ ...p, expression: "" });
    expect(importStrategy(json).ok).toBe(false);
  });

  it("rejects dangerous expression", () => {
    const p = mkPayload({ expression: "eval(x)" });
    p.checksum = checksumPayload(p);
    expect(importStrategy(JSON.stringify(p)).ok).toBe(false);
  });

  it("rejects invalid vars", () => {
    const p = mkPayload();
    const json = JSON.stringify({ ...p, vars: { x: "string" } });
    expect(importStrategy(json).ok).toBe(false);
  });

  it("detects checksum tampering", () => {
    const p = mkPayload();
    p.checksum = "badchecksum";
    expect(importStrategy(JSON.stringify(p)).ok).toBe(false);
  });

  it("accepts payload without checksum", () => {
    const p = mkPayload();
    p.checksum = "";
    expect(importStrategy(JSON.stringify(p)).ok).toBe(true);
  });
});

// ── exportBundle / importBundle ───────────────────────────────────────────

describe("exportBundle", () => {
  it("wraps strategies in a bundle", () => {
    const s1 = mkPayload({ name: "A" });
    const s2 = mkPayload({ name: "B" });
    const bundle = exportBundle([s1, s2]);
    expect(bundle.version).toBe(1);
    expect(bundle.strategies).toHaveLength(2);
    expect(bundle.exportedAt).toBeTruthy();
  });
});

describe("importBundle", () => {
  it("round-trips a bundle", () => {
    const s1 = mkPayload({ name: "A" });
    const s2 = mkPayload({ name: "B" });
    const bundle = exportBundle([s1, s2]);
    const result = importBundle(JSON.stringify(bundle));
    expect(result.ok).toBe(true);
    expect(result.data?.strategies).toHaveLength(2);
  });

  it("rejects invalid JSON", () => {
    expect(importBundle("{bad").ok).toBe(false);
  });

  it("rejects missing strategies array", () => {
    expect(importBundle(JSON.stringify({ version: 1 })).ok).toBe(false);
  });

  it("reports which strategy failed", () => {
    const s1 = mkPayload({ name: "A" });
    const badS = { ...mkPayload({ name: "B" }), expression: "" };
    const bundle = { version: 1, strategies: [s1, badS], exportedAt: "" };
    const result = importBundle(JSON.stringify(bundle));
    expect(result.ok).toBe(false);
    expect(result.error).toContain("Strategy[1]");
  });
});

// ── validateExpression ────────────────────────────────────────────────────

describe("validateExpression", () => {
  it("accepts valid expression", () => {
    expect(validateExpression("sma(20) > sma(50) and rsi(14) < 30").ok).toBe(true);
  });

  it("rejects empty expression", () => {
    expect(validateExpression("").ok).toBe(false);
  });

  it("rejects import keyword", () => {
    expect(validateExpression("import('evil')").ok).toBe(false);
  });

  it("rejects eval keyword", () => {
    expect(validateExpression("eval(x)").ok).toBe(false);
  });

  it("rejects Function keyword", () => {
    expect(validateExpression("new Function('x')").ok).toBe(false);
  });

  it("rejects unbalanced parens", () => {
    expect(validateExpression("sma(20").ok).toBe(false);
    expect(validateExpression("sma20)").ok).toBe(false);
  });

  it("accepts balanced nested parens", () => {
    expect(validateExpression("max(sma(20), ema(50))").ok).toBe(true);
  });
});

// ── validateVars ──────────────────────────────────────────────────────────

describe("validateVars", () => {
  it("accepts numbers and booleans", () => {
    expect(validateVars({ x: 42, flag: true }).ok).toBe(true);
  });

  it("rejects string values", () => {
    const result = validateVars({ x: "bad" as unknown as number });
    expect(result.ok).toBe(false);
    expect(result.error).toContain("x");
  });

  it("accepts empty vars", () => {
    expect(validateVars({}).ok).toBe(true);
  });
});

// ── checksumPayload ───────────────────────────────────────────────────────

describe("checksumPayload", () => {
  it("returns a string", () => {
    const p = mkPayload();
    expect(typeof checksumPayload(p)).toBe("string");
  });

  it("is deterministic", () => {
    const p = mkPayload();
    expect(checksumPayload(p)).toBe(checksumPayload(p));
  });

  it("changes when content changes", () => {
    const p1 = mkPayload({ name: "A" });
    const p2 = mkPayload({ name: "B" });
    expect(checksumPayload(p1)).not.toBe(checksumPayload(p2));
  });
});

// ── URL sharing ───────────────────────────────────────────────────────────

describe("encodeShareUrl / decodeShareUrl", () => {
  it("round-trips a payload", () => {
    const p = mkPayload();
    const url = encodeShareUrl(p);
    const result = decodeShareUrl(url);
    expect(result.ok).toBe(true);
    expect(result.data?.name).toBe(p.name);
    expect(result.data?.expression).toBe(p.expression);
  });

  it("uses custom base URL", () => {
    const p = mkPayload();
    const url = encodeShareUrl(p, "https://custom.app/s");
    expect(url.startsWith("https://custom.app/s#")).toBe(true);
  });

  it("rejects URL without hash", () => {
    expect(decodeShareUrl("https://example.com").ok).toBe(false);
  });

  it("rejects invalid base64", () => {
    expect(decodeShareUrl("https://example.com#!!!").ok).toBe(false);
  });
});

// ── payloadToClipboardText ────────────────────────────────────────────────

describe("payloadToClipboardText", () => {
  it("returns pretty-printed JSON", () => {
    const p = mkPayload();
    const text = payloadToClipboardText(p);
    expect(text).toContain('"name"');
    expect(text).toContain("\n");
    expect(JSON.parse(text)).toBeTruthy();
  });
});
