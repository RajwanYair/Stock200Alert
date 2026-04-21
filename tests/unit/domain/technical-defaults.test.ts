/**
 * Technical Defaults tests.
 */
import { describe, it, expect } from "vitest";
import { DEFAULTS } from "../../../src/domain/technical-defaults";

describe("DEFAULTS", () => {
  it.each([
    ["rsiOversold", 30],
    ["rsiOverbought", 70],
    ["macdFastPeriod", 12],
    ["macdSlowPeriod", 26],
    ["macdSignalPeriod", 9],
    ["sma50Period", 50],
    ["sma150Period", 150],
    ["sma200Period", 200],
    ["bollingerPeriod", 20],
    ["bollingerMultiplier", 2.0],
    ["mfiOversold", 20],
    ["mfiOverbought", 80],
    ["williamsROversold", -80],
    ["williamsROverbought", -20],
    ["cciOversold", -100],
    ["cciOverbought", 100],
    ["period", 14],
  ] as const)("%s = %s", (key, expected) => {
    expect(DEFAULTS[key]).toBe(expected);
  });
});
