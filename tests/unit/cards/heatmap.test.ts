/**
 * Sector heatmap card tests.
 */
import { describe, it, expect, beforeEach } from "vitest";
import {
  computeHeatmapLayout,
  changeColor,
  renderHeatmap,
  type SectorData,
} from "../../../src/cards/heatmap";

const SECTORS: SectorData[] = [
  { sector: "Technology", marketCap: 500, changePercent: 1.2, tickerCount: 50 },
  { sector: "Healthcare", marketCap: 300, changePercent: -0.8, tickerCount: 30 },
  { sector: "Energy", marketCap: 200, changePercent: 2.5, tickerCount: 20 },
];

describe("computeHeatmapLayout", () => {
  it("returns empty for empty input", () => {
    expect(computeHeatmapLayout([], 1000)).toEqual([]);
  });

  it("returns empty when total cap is 0", () => {
    const z: SectorData[] = [{ sector: "X", marketCap: 0, changePercent: 0, tickerCount: 0 }];
    expect(computeHeatmapLayout(z, 1000)).toEqual([]);
  });

  it("areas sum to totalArea", () => {
    const layout = computeHeatmapLayout(SECTORS, 10000);
    const sum = layout.reduce((s, l) => s + l.area, 0);
    expect(sum).toBeCloseTo(10000, 1);
  });

  it("is sorted by descending area", () => {
    const layout = computeHeatmapLayout(SECTORS, 10000);
    for (let i = 1; i < layout.length; i++) {
      expect(layout[i - 1].area).toBeGreaterThanOrEqual(layout[i].area);
    }
  });

  it("proportional to marketCap", () => {
    const layout = computeHeatmapLayout(SECTORS, 1000);
    expect(layout[0].sector).toBe("Technology");
    expect(layout[0].area).toBe(500); // 500/1000 * 1000
  });
});

describe("changeColor", () => {
  it("strong up for >= 2%", () => expect(changeColor(3)).toBe("heatmap-strong-up"));
  it("up for >= 0.5%", () => expect(changeColor(1)).toBe("heatmap-up"));
  it("flat for near zero", () => expect(changeColor(0)).toBe("heatmap-flat"));
  it("down for < -0.5%", () => expect(changeColor(-1)).toBe("heatmap-down"));
  it("strong down for <= -2%", () => expect(changeColor(-3)).toBe("heatmap-strong-down"));
});

describe("renderHeatmap", () => {
  let container: HTMLElement;
  beforeEach(() => {
    container = document.createElement("div");
  });

  it("renders tiles for each sector", () => {
    renderHeatmap(container, SECTORS);
    const tiles = container.querySelectorAll(".heatmap-tile");
    expect(tiles.length).toBe(3);
  });

  it("shows empty state for no data", () => {
    renderHeatmap(container, []);
    expect(container.textContent).toContain("No sector data");
  });

  it("shows sector count", () => {
    renderHeatmap(container, SECTORS);
    expect(container.textContent).toContain("3 sectors");
  });

  it("includes aria labels", () => {
    renderHeatmap(container, SECTORS);
    const grid = container.querySelector(".heatmap-grid");
    expect(grid?.getAttribute("aria-label")).toBe("Sector Heatmap");
  });

  it("applies correct color class", () => {
    renderHeatmap(container, SECTORS);
    const tiles = container.querySelectorAll(".heatmap-tile");
    // Energy +2.5% → strong-up, Tech +1.2% → up, Healthcare -0.8% → down
    // Sorted by area: Tech, Healthcare, Energy
    expect(tiles[0].classList.contains("heatmap-up")).toBe(true); // Tech
    expect(tiles[1].classList.contains("heatmap-down")).toBe(true); // Healthcare
    expect(tiles[2].classList.contains("heatmap-strong-up")).toBe(true); // Energy
  });

  it("escapes HTML in sector names", () => {
    const xss: SectorData[] = [
      { sector: "<script>alert(1)</script>", marketCap: 100, changePercent: 0, tickerCount: 1 },
    ];
    renderHeatmap(container, xss);
    expect(container.innerHTML).not.toContain("<script>");
    expect(container.innerHTML).toContain("&lt;script&gt;");
  });
});
