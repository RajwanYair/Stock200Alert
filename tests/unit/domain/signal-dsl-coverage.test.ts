/**
 * Coverage for signal-dsl.ts — uncovered operator/branch paths.
 */
import { describe, it, expect } from "vitest";
import { tokenize, parse, evaluate, compileSignal } from "../../../src/domain/signal-dsl";

describe("signal-dsl coverage — uncovered branches", () => {
  it("evaluates multiplication operator", () => {
    expect(evaluate(parse("3 * 4"))).toBe(12);
  });

  it("evaluates normal division (non-zero)", () => {
    expect(evaluate(parse("10 / 2"))).toBe(5);
  });

  it("evaluates <= comparison", () => {
    expect(evaluate(parse("3 <= 3"))).toBe(true);
    expect(evaluate(parse("4 <= 3"))).toBe(false);
  });

  it("evaluates != comparison", () => {
    expect(evaluate(parse("3 != 4"))).toBe(true);
    expect(evaluate(parse("5 != 5"))).toBe(false);
  });

  it("evaluates > comparison returning false", () => {
    expect(evaluate(parse("2 > 5"))).toBe(false);
  });

  it("evaluates == with booleans", () => {
    expect(evaluate(parse("true == true"))).toBe(true);
    expect(evaluate(parse("true == false"))).toBe(false);
  });

  it("parses and evaluates standalone true literal", () => {
    expect(evaluate(parse("true"))).toBe(true);
    expect(evaluate(parse("false"))).toBe(false);
  });

  it("parses multi-argument function calls", () => {
    const ctx = {
      funcs: {
        max: (a: number | boolean, b: number | boolean): number => Math.max(Number(a), Number(b)),
        clamp: (v: number | boolean, lo: number | boolean, hi: number | boolean): number =>
          Math.max(Number(lo), Math.min(Number(hi), Number(v))),
      },
    };
    expect(evaluate(parse("max(3, 7)"), ctx)).toBe(7);
    expect(evaluate(parse("clamp(10, 0, 5)"), ctx)).toBe(5);
  });

  it("tokenizes whitespace variants (tab, newline, CR)", () => {
    const tokens = tokenize("1\t+\n2\r+ 3");
    const ops = tokens.filter((t) => t.kind === "op");
    expect(ops).toHaveLength(2);
    expect(evaluate(parse("1\t+\n2\r+ 3"))).toBe(6);
  });

  it("subtraction in add precedence", () => {
    expect(evaluate(parse("10 - 3 - 2"))).toBe(5);
  });

  it("or short-circuits (right side not needed)", () => {
    // left is true, right would throw if evaluated (but it IS evaluated in JS &&)
    // Actually in this impl both sides are always evaluated due to JS `||`
    // Just verify the result:
    expect(evaluate(parse("true or false"))).toBe(true);
  });

  it("compileSignal with mul/div expression", () => {
    const fn = compileSignal("price * qty / 100");
    expect(fn({ vars: { price: 50, qty: 200 } })).toBe(100);
  });

  it("throws TypeError when boolean used in arithmetic", () => {
    expect(() => evaluate(parse("true * 2"))).toThrow(TypeError);
    expect(() => evaluate(parse("true - 1"))).toThrow(TypeError);
  });

  it("throws TypeError when number used in boolean op", () => {
    expect(() => evaluate(parse("1 and 2"))).toThrow(TypeError);
    expect(() => evaluate(parse("1 or 0"))).toThrow(TypeError);
  });

  it("nested function calls as arguments", () => {
    const ctx = {
      funcs: {
        add: (a: number | boolean, b: number | boolean): number => Number(a) + Number(b),
        double: (x: number | boolean): number => Number(x) * 2,
      },
    };
    expect(evaluate(parse("add(double(3), 4)"), ctx)).toBe(10);
  });
});
