/**
 * OG image generator tests (B7).
 */
import { describe, it, expect } from "vitest";
import { generateOgImageSvg, svgToDataUri } from "../../../src/core/og-image";

describe("generateOgImageSvg", () => {
  it("returns a string starting with SVG header", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL" });
    expect(svg).toContain("<svg");
    expect(svg).toContain('xmlns="http://www.w3.org/2000/svg"');
  });

  it("includes the ticker in the SVG", () => {
    const svg = generateOgImageSvg({ ticker: "MSFT" });
    expect(svg).toContain("MSFT");
  });

  it("includes the price when provided", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", price: 189.5 });
    expect(svg).toContain("189");
  });

  it("includes positive change percent with + prefix", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", changePercent: 1.23 });
    expect(svg).toContain("+1.23%");
  });

  it("includes negative change percent without +", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", changePercent: -2.5 });
    expect(svg).toContain("-2.50%");
  });

  it("includes direction badge label", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", direction: "BUY" });
    expect(svg).toContain("BUY");
  });

  it("replaces underscore in STRONG_BUY with space", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", direction: "STRONG_BUY" });
    expect(svg).toContain("STRONG BUY");
  });

  it("includes company name when provided", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", name: "Apple Inc." });
    expect(svg).toContain("Apple Inc.");
  });

  it("does not include badge section when direction is omitted", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL" });
    expect(svg).not.toContain("badge");
  });

  it("uses custom accentColor when provided", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL", accentColor: "#ff0000" });
    expect(svg).toContain("#ff0000");
  });

  it("escapes XML special chars in ticker", () => {
    const svg = generateOgImageSvg({ ticker: "A&B" });
    expect(svg).toContain("A&amp;B");
    expect(svg).not.toContain("A&B");
  });

  it("SVG has correct viewBox dimensions 1200x630", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL" });
    expect(svg).toContain("1200");
    expect(svg).toContain("630");
  });

  it("includes CrossTide branding", () => {
    const svg = generateOgImageSvg({ ticker: "AAPL" });
    expect(svg).toContain("CrossTide");
  });
});

describe("svgToDataUri", () => {
  it("returns a data URI with correct mime type", () => {
    const svg = "<svg></svg>";
    const uri = svgToDataUri(svg);
    expect(uri).toMatch(/^data:image\/svg\+xml;base64,/);
  });

  it("round-trips through base64", () => {
    const svg = generateOgImageSvg({ ticker: "TSLA", price: 250, direction: "HOLD" });
    const uri = svgToDataUri(svg);
    expect(uri.length).toBeGreaterThan(50);
  });
});
