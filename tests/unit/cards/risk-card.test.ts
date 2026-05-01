/**
 * Risk metrics card adapter tests (B3 — risk card activation).
 *
 * Verifies the CardModule renders risk metrics (Sortino, max drawdown,
 * CAGR, Calmar) and equity curve SVG from demo data.
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest";

describe("risk-card (CardModule)", () => {
  let container: HTMLElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.removeChild(container);
  });

  it("mounts without throwing", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    expect(() => riskCard.mount(container, { route: "risk", params: {} })).not.toThrow();
  });

  it("renders Sortino Ratio metric", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.textContent).toContain("Sortino Ratio");
  });

  it("renders Max Drawdown metric", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.textContent).toContain("Max Drawdown");
  });

  it("renders CAGR metric", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.textContent).toContain("CAGR");
  });

  it("renders Calmar Ratio metric", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.textContent).toContain("Calmar Ratio");
  });

  it("renders equity curve SVG", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.querySelector("svg")).not.toBeNull();
  });

  it("renders gauge bars for each metric", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    const gauges = container.querySelectorAll(".risk-gauge-wrap");
    expect(gauges.length).toBe(4);
  });

  it("renders demo note about equity curve source", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.textContent).toContain("demo");
  });

  it("fills container with substantial HTML", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    expect(container.innerHTML.length).toBeGreaterThan(500);
  });

  it("shows a numeric Sortino value", async () => {
    const { default: riskCard } = await import("../../../src/cards/risk-card");
    riskCard.mount(container, { route: "risk", params: {} });
    // Sortino ratio from the demo curve should be > 0
    const sortino = container.querySelector(".risk-metric-card:first-child .stat-value");
    const value = parseFloat(sortino?.textContent ?? "0");
    expect(value).toBeGreaterThan(0);
  });
});
