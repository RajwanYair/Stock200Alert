import { describe, it, expect, beforeEach, vi } from "vitest";
import { renderSettings } from "../../../src/cards/settings";
import type { AppConfig } from "../../../src/types/domain";

function makeConfig(overrides: Partial<AppConfig> = {}): AppConfig {
  return {
    theme: "dark",
    watchlist: [{ ticker: "AAPL", addedAt: "2025-01-01T00:00:00Z" }],
    ...overrides,
  };
}

describe("renderSettings", () => {
  let container: HTMLElement;
  const callbacks = {
    onThemeChange: vi.fn(),
    onExport: vi.fn(),
    onImport: vi.fn(),
    onClearWatchlist: vi.fn(),
    onClearCache: vi.fn(),
  };

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
    vi.clearAllMocks();
  });

  it("renders theme select with current value", () => {
    renderSettings(container, makeConfig({ theme: "light" }), callbacks);
    const select = container.querySelector("#theme-select") as HTMLSelectElement;
    expect(select).not.toBeNull();
    expect(select.value).toBe("light");
  });

  it("renders high-contrast option", () => {
    renderSettings(container, makeConfig({ theme: "high-contrast" }), callbacks);
    const select = container.querySelector("#theme-select") as HTMLSelectElement;
    const options = Array.from(select.options).map((o) => o.value);
    expect(options).toContain("high-contrast");
  });

  it("shows watchlist ticker count", () => {
    renderSettings(container, makeConfig(), callbacks);
    expect(container.innerHTML).toContain("1 tickers");
  });

  it("calls onThemeChange when theme changes", () => {
    renderSettings(container, makeConfig(), callbacks);
    const select = container.querySelector("#theme-select") as HTMLSelectElement;
    select.value = "light";
    select.dispatchEvent(new Event("change"));
    expect(callbacks.onThemeChange).toHaveBeenCalledWith("light");
  });

  it("calls onExport when export button clicked", () => {
    renderSettings(container, makeConfig(), callbacks);
    (container.querySelector("#btn-export") as HTMLButtonElement).click();
    expect(callbacks.onExport).toHaveBeenCalled();
  });

  it("calls onImport when import button clicked", () => {
    renderSettings(container, makeConfig(), callbacks);
    (container.querySelector("#btn-import") as HTMLButtonElement).click();
    expect(callbacks.onImport).toHaveBeenCalled();
  });

  it("calls onClearWatchlist when clear button clicked", () => {
    renderSettings(container, makeConfig(), callbacks);
    (container.querySelector("#btn-clear") as HTMLButtonElement).click();
    expect(callbacks.onClearWatchlist).toHaveBeenCalled();
  });

  it("calls onClearCache when clear cache button clicked", () => {
    renderSettings(container, makeConfig(), callbacks);
    (container.querySelector("#btn-clear-cache") as HTMLButtonElement).click();
    expect(callbacks.onClearCache).toHaveBeenCalled();
  });

  describe("Finnhub API key inputs", () => {
    it("calls onFinnhubKeyChange with key when Save is clicked with valid input", () => {
      const onFinnhubKeyChange = vi.fn();
      renderSettings(container, makeConfig(), { ...callbacks, onFinnhubKeyChange });
      const keyInput = container.querySelector("#finnhub-key-input") as HTMLInputElement;
      const saveBtn = container.querySelector("#btn-finnhub-save") as HTMLButtonElement;
      keyInput.value = "test-api-key-123";
      saveBtn.click();
      expect(onFinnhubKeyChange).toHaveBeenCalledWith("test-api-key-123");
    });

    it("does not call onFinnhubKeyChange when Save is clicked with empty key", () => {
      const onFinnhubKeyChange = vi.fn();
      renderSettings(container, makeConfig(), { ...callbacks, onFinnhubKeyChange });
      const keyInput = container.querySelector("#finnhub-key-input") as HTMLInputElement;
      keyInput.value = "";
      (container.querySelector("#btn-finnhub-save") as HTMLButtonElement).click();
      expect(onFinnhubKeyChange).not.toHaveBeenCalled();
    });

    it("calls onFinnhubKeyChange(null) and resets input when Clear is clicked", () => {
      const onFinnhubKeyChange = vi.fn();
      renderSettings(container, makeConfig(), { ...callbacks, onFinnhubKeyChange });
      const keyInput = container.querySelector("#finnhub-key-input") as HTMLInputElement;
      const clearBtn = container.querySelector("#btn-finnhub-clear") as HTMLButtonElement;
      keyInput.value = "existing-key";
      clearBtn.removeAttribute("disabled");
      clearBtn.click();
      expect(onFinnhubKeyChange).toHaveBeenCalledWith(null);
      expect(keyInput.value).toBe("");
      expect(clearBtn.disabled).toBe(true);
    });
  });
});
