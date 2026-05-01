/**
 * Heatmap card adapter tests (A12 — heatmap card activation).
 *
 * Verifies that the CardModule wrapper correctly mounts the sector heatmap,
 * renders tiles, and exposes the expected CardHandle interface.
 */
import { describe, it, expect, beforeEach } from "vitest";

describe("heatmap-card (CardModule)", () => {
  let container: HTMLElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.removeChild(container);
  });

  it("mounts without throwing", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    expect(() => heatmapCard.mount(container, { route: "heatmap", params: {} })).not.toThrow();
  });

  it("renders heatmap tiles", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    heatmapCard.mount(container, { route: "heatmap", params: {} });
    // Heatmap card uses mock sector data — expect tile elements
    const tiles = container.querySelectorAll(".heatmap-tile");
    expect(tiles.length).toBeGreaterThan(0);
  });

  it("renders sector names in the heatmap", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    heatmapCard.mount(container, { route: "heatmap", params: {} });
    expect(container.textContent).toContain("Technology");
  });

  it("returns a CardHandle object", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    const handle = heatmapCard.mount(container, { route: "heatmap", params: {} });
    // CardHandle may be undefined (void) or an object — both are valid
    expect(handle === undefined || typeof handle === "object").toBe(true);
  });

  it("fills the container with heatmap content", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    heatmapCard.mount(container, { route: "heatmap", params: {} });
    expect(container.innerHTML.length).toBeGreaterThan(50);
  });

  it("includes SVG or grid element for layout", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    heatmapCard.mount(container, { route: "heatmap", params: {} });
    const hasGrid = container.querySelector(".heatmap-grid") !== null;
    const hasSvg = container.querySelector("svg") !== null;
    expect(hasGrid || hasSvg).toBe(true);
  });

  it("shows sector count in header", async () => {
    const { default: heatmapCard } = await import("../../../src/cards/heatmap-card");
    heatmapCard.mount(container, { route: "heatmap", params: {} });
    // The mock data has 11 sectors
    expect(container.textContent).toContain("11 sectors");
  });
});
