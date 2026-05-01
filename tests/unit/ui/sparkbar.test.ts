import { describe, it, expect } from "vitest";
import { buildSparkbar } from "../../../src/ui/sparkbar";

describe("sparkbar", () => {
  it("empty input -> svg with no bars", () => {
    const s = buildSparkbar([]);
    expect(s.startsWith("<svg")).toBe(true);
    expect(s).not.toContain("<rect");
  });

  it("flat data -> single line", () => {
    const s = buildSparkbar([5, 5, 5, 5]);
    expect(s).toContain("<line");
    expect(s).not.toContain("<rect");
  });

  it("positive data -> N rects with default color", () => {
    const s = buildSparkbar([1, 2, 3, 4]);
    const matches = s.match(/<rect /g) ?? [];
    expect(matches.length).toBe(4);
    expect(s).toContain('fill="currentColor"');
  });

  it("negative values use negativeColor when crossing zero", () => {
    const s = buildSparkbar([-3, -1, 2, 4], {
      color: "#0f0",
      negativeColor: "#f00",
    });
    expect(s).toContain('fill="#f00"');
    expect(s).toContain('fill="#0f0"');
  });

  it("respects width/height/gap", () => {
    const s = buildSparkbar([1, 2, 3], { width: 60, height: 10, gap: 2 });
    expect(s).toContain('width="60"');
    expect(s).toContain('height="10"');
  });

  it("background is rendered when set", () => {
    const s = buildSparkbar([1, 2, 3], { background: "#222" });
    expect(s).toContain('fill="#222"');
  });

  it("escapes attribute values", () => {
    const s = buildSparkbar([1, 2], { color: '"><script>' });
    expect(s).not.toContain("<script>");
    expect(s).toContain("&quot;");
    expect(s).toContain("&lt;");
  });

  it("precision rounds rect coordinates", () => {
    const s = buildSparkbar([1, 2, 3], { precision: 0 });
    expect(/x="\d+"/.test(s)).toBe(true);
    expect(/x="\d+\.\d+"/.test(s)).toBe(false);
  });
});
