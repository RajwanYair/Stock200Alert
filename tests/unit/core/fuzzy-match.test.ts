import { describe, it, expect } from "vitest";
import { fuzzyScore, fuzzySearch } from "../../../src/core/fuzzy-match";

describe("fuzzy-match", () => {
  it("empty query matches all with score 1", () => {
    expect(fuzzyScore("", "anything").score).toBe(1);
  });

  it("subsequence matches", () => {
    expect(fuzzyScore("aapl", "Apple Inc AAPL").score).toBeGreaterThan(0);
  });

  it("non-subsequence returns 0", () => {
    expect(fuzzyScore("xyz", "Apple").score).toBe(0);
  });

  it("prefix scores higher than middle", () => {
    const a = fuzzyScore("app", "apple");
    const b = fuzzyScore("app", "snapple");
    expect(a.score).toBeGreaterThan(b.score);
  });

  it("consecutive chars boost score", () => {
    const a = fuzzyScore("abc", "abcdef");
    const b = fuzzyScore("abc", "axbxcx");
    expect(a.score).toBeGreaterThan(b.score);
  });

  it("returns matched indices", () => {
    expect(fuzzyScore("ace", "abcde").indices).toEqual([0, 2, 4]);
  });

  it("fuzzySearch sorts by score desc and respects limit", () => {
    const items = ["snapple", "apple", "applet", "banana"];
    const res = fuzzySearch("app", items, { key: (x) => x, limit: 2 });
    expect(res.length).toBe(2);
    expect(res[0]!.item).toBe("apple");
    expect(res[0]!.score).toBeGreaterThan(res[1]!.score);
  });

  it("uses key function for objects", () => {
    const items = [{ t: "AAPL" }, { t: "MSFT" }];
    const res = fuzzySearch("aap", items, { key: (x) => x.t });
    expect(res[0]!.item.t).toBe("AAPL");
  });

  it("threshold filters weak matches", () => {
    const res = fuzzySearch("z", ["abc", "azzzz"], {
      key: (x) => x,
      threshold: 100,
    });
    expect(res.length).toBe(0);
  });
});
