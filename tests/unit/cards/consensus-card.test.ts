/**
 * Consensus card adapter tests.
 *
 * Validates mount/update delegate to renderConsensus and the CardModule contract.
 */
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";

vi.mock("../../../src/cards/consensus", () => ({
  renderConsensus: vi.fn(),
}));

describe("consensus-card (CardModule)", () => {
  let container: HTMLElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.removeChild(container);
    vi.clearAllMocks();
  });

  it("mounts without throwing", async () => {
    const { default: consensusCard } = await import("../../../src/cards/consensus-card");
    expect(() =>
      consensusCard.mount(container, { route: "consensus", params: { symbol: "AAPL" } }),
    ).not.toThrow();
  });

  it("calls renderConsensus on mount with ticker", async () => {
    const { renderConsensus } = await import("../../../src/cards/consensus");
    const { default: consensusCard } = await import("../../../src/cards/consensus-card");
    consensusCard.mount(container, { route: "consensus", params: { symbol: "TSLA" } });
    expect(renderConsensus).toHaveBeenCalledWith(container, "TSLA", null);
  });

  it("uses empty string when symbol param is missing", async () => {
    const { renderConsensus } = await import("../../../src/cards/consensus");
    const { default: consensusCard } = await import("../../../src/cards/consensus-card");
    consensusCard.mount(container, { route: "consensus", params: {} });
    expect(renderConsensus).toHaveBeenCalledWith(container, "", null);
  });

  it("update re-renders with new ticker", async () => {
    const { renderConsensus } = await import("../../../src/cards/consensus");
    const { default: consensusCard } = await import("../../../src/cards/consensus-card");
    const handle = consensusCard.mount(container, {
      route: "consensus",
      params: { symbol: "AAPL" },
    });
    vi.mocked(renderConsensus).mockClear();
    handle?.update?.({ route: "consensus", params: { symbol: "GOOG" } });
    expect(renderConsensus).toHaveBeenCalledWith(container, "GOOG", null);
  });
});
