/**
 * Consensus timeline card tests.
 */
import { describe, it, expect, beforeEach } from "vitest";
import {
  detectTransitions,
  currentStreak,
  renderConsensusTimeline,
  type ConsensusSnapshot,
} from "../../../src/cards/consensus-timeline";

const TIMELINE: ConsensusSnapshot[] = [
  { ticker: "AAPL", direction: "BUY", strength: 0.7, timestamp: "2025-06-01" },
  { ticker: "AAPL", direction: "BUY", strength: 0.65, timestamp: "2025-06-02" },
  { ticker: "AAPL", direction: "NEUTRAL", strength: 0.5, timestamp: "2025-06-03" },
  { ticker: "AAPL", direction: "SELL", strength: 0.6, timestamp: "2025-06-04" },
  { ticker: "AAPL", direction: "SELL", strength: 0.55, timestamp: "2025-06-05" },
];

describe("detectTransitions", () => {
  it("finds all direction changes", () => {
    const t = detectTransitions(TIMELINE);
    expect(t).toHaveLength(2);
    expect(t[0]).toEqual({ from: "BUY", to: "NEUTRAL", at: "2025-06-03" });
    expect(t[1]).toEqual({ from: "NEUTRAL", to: "SELL", at: "2025-06-04" });
  });

  it("returns empty for single snapshot", () => {
    expect(detectTransitions([TIMELINE[0]])).toEqual([]);
  });

  it("returns empty for no changes", () => {
    const same = [TIMELINE[0], { ...TIMELINE[0], timestamp: "2025-06-02" }];
    expect(detectTransitions(same)).toEqual([]);
  });
});

describe("currentStreak", () => {
  it("counts consecutive same-direction from end", () => {
    expect(currentStreak(TIMELINE)).toBe(2); // last 2 are SELL
  });

  it("returns 0 for empty", () => {
    expect(currentStreak([])).toBe(0);
  });

  it("returns full length if all same direction", () => {
    const all = TIMELINE.slice(0, 2); // both BUY
    expect(currentStreak(all)).toBe(2);
  });
});

describe("renderConsensusTimeline", () => {
  let container: HTMLElement;
  beforeEach(() => {
    container = document.createElement("div");
  });

  it("renders dots for each snapshot", () => {
    renderConsensusTimeline(container, "AAPL", TIMELINE);
    const dots = container.querySelectorAll(".timeline-dot");
    expect(dots.length).toBe(5);
  });

  it("shows empty state for no history", () => {
    renderConsensusTimeline(container, "AAPL", []);
    expect(container.textContent).toContain("No consensus history");
  });

  it("shows latest direction badge", () => {
    renderConsensusTimeline(container, "AAPL", TIMELINE);
    expect(container.textContent).toContain("SELL");
  });

  it("shows streak count", () => {
    renderConsensusTimeline(container, "AAPL", TIMELINE);
    expect(container.textContent).toContain("2-day streak");
  });

  it("shows transition count", () => {
    renderConsensusTimeline(container, "AAPL", TIMELINE);
    expect(container.textContent).toContain("2 transitions");
  });

  it("applies direction classes to dots", () => {
    renderConsensusTimeline(container, "AAPL", TIMELINE);
    const dots = container.querySelectorAll(".timeline-dot");
    expect(dots[0].classList.contains("dot-buy")).toBe(true);
    expect(dots[2].classList.contains("dot-neutral")).toBe(true);
    expect(dots[4].classList.contains("dot-sell")).toBe(true);
  });

  it("escapes ticker name", () => {
    renderConsensusTimeline(container, "<img>", TIMELINE);
    expect(container.innerHTML).not.toContain("<img>");
    expect(container.innerHTML).toContain("&lt;img&gt;");
  });
});
