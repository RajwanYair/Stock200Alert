/**
 * Watchlist card adapter tests.
 *
 * Validates mount renders a loading placeholder and the CardModule contract.
 */
import { describe, it, expect, beforeEach, afterEach } from "vitest";

describe("watchlist-card (CardModule)", () => {
  let container: HTMLElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
  });

  afterEach(() => {
    document.body.removeChild(container);
  });

  it("mounts without throwing", async () => {
    const { default: watchlistCard } = await import("../../../src/cards/watchlist-card");
    expect(() => watchlistCard.mount(container, { route: "watchlist", params: {} })).not.toThrow();
  });

  it("renders loading placeholder on mount", async () => {
    const { default: watchlistCard } = await import("../../../src/cards/watchlist-card");
    watchlistCard.mount(container, { route: "watchlist", params: {} });
    const p = container.querySelector("p.empty-state");
    expect(p).not.toBeNull();
    expect(p?.textContent).toBe("Loading watchlist…");
  });

  it("update does not throw", async () => {
    const { default: watchlistCard } = await import("../../../src/cards/watchlist-card");
    const handle = watchlistCard.mount(container, { route: "watchlist", params: {} });
    expect(() => handle?.update?.({ route: "watchlist", params: {} })).not.toThrow();
  });
});
