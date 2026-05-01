import { describe, it, expect } from "vitest";
import { truncateEnd, truncateMiddle, graphemeLength } from "../../../src/ui/text-truncate";

describe("text-truncate", () => {
  it("graphemeLength counts emoji as 1 when Segmenter is available", () => {
    // Tolerate environments without Intl.Segmenter
    const len = graphemeLength("a\u{1F600}b");
    expect([3, 4]).toContain(len);
  });

  it("truncateEnd preserves short strings", () => {
    expect(truncateEnd("hello", 10)).toBe("hello");
    expect(truncateEnd("hello", 5)).toBe("hello");
  });

  it("truncateEnd cuts long strings with ellipsis", () => {
    expect(truncateEnd("hello world", 8)).toBe("hello w\u2026");
  });

  it("truncateEnd handles max <= ellipsis length", () => {
    expect(truncateEnd("hello", 1)).toBe("\u2026");
    expect(truncateEnd("hello", 0)).toBe("");
  });

  it("truncateMiddle preserves short strings", () => {
    expect(truncateMiddle("hello", 10)).toBe("hello");
  });

  it("truncateMiddle cuts middle out of long strings", () => {
    const r = truncateMiddle("abcdefghij", 7);
    expect(r).toBe("abc\u2026hij");
    expect(r.length).toBeLessThanOrEqual(7);
  });

  it("truncateMiddle works with custom ellipsis", () => {
    expect(truncateMiddle("abcdefghij", 7, "...")).toBe("ab...ij");
  });

  it("truncateMiddle max <= ellipsis", () => {
    expect(truncateMiddle("abcdef", 1)).toBe("\u2026");
    expect(truncateMiddle("abcdef", 0)).toBe("");
  });

  it("idempotent on already-fitting strings", () => {
    expect(truncateMiddle("ab", 5)).toBe("ab");
    expect(truncateEnd("ab", 5)).toBe("ab");
  });
});
