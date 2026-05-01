/**
 * Settings card — renders settings panel and binds change handlers.
 */
import type { AppConfig, MethodWeights } from "../types/domain";
import { DEFAULT_METHOD_WEIGHTS } from "../types/domain";
import { FINNHUB_KEY_STORAGE } from "../core/finnhub-stream-manager";

const METHOD_NAMES = [
  "Micho",
  "RSI",
  "MACD",
  "Bollinger",
  "Stochastic",
  "OBV",
  "ADX",
  "CCI",
  "SAR",
  "WilliamsR",
  "MFI",
  "SuperTrend",
] as const;

export interface SettingsCallbacks {
  onThemeChange: (theme: AppConfig["theme"]) => void;
  onExport: () => void;
  /** Called when user requests a gzip-compressed export (G11). */
  onExportGz?: () => void;
  onImport: () => void;
  onClearWatchlist: () => void;
  onClearCache: () => void;
  /** Called when user saves or clears the Finnhub API key. */
  onFinnhubKeyChange?: (apiKey: string | null) => void;
  /** Called when user changes per-method consensus weights (G20). */
  onMethodWeightsChange?: (weights: MethodWeights) => void;
}

export function renderSettings(
  container: HTMLElement,
  config: AppConfig,
  callbacks: SettingsCallbacks,
): void {
  const storedKey = ((): string => {
    try {
      return localStorage.getItem(FINNHUB_KEY_STORAGE) ?? "";
    } catch {
      return "";
    }
  })();

  container.innerHTML = `
    <div class="setting-group">
      <label for="theme-select">Theme</label>
      <select id="theme-select">
        <option value="dark"${config.theme === "dark" ? " selected" : ""}>Dark</option>
        <option value="light"${config.theme === "light" ? " selected" : ""}>Light</option>
        <option value="high-contrast"${config.theme === "high-contrast" ? " selected" : ""}>High Contrast</option>
      </select>
    </div>
    <div class="setting-group">
      <label>Watchlist</label>
      <span class="text-secondary">${config.watchlist.length} tickers</span>
    </div>
    <div class="setting-group">
      <label>Actions</label>
      <button id="btn-export" type="button">Export JSON</button>
      <button id="btn-export-gz" type="button">Export .json.gz</button>
      <button id="btn-import" type="button">Import JSON</button>
      <button id="btn-clear" type="button" class="btn-danger">Clear All</button>
    </div>
    <div class="setting-group">
      <label>Cache</label>
      <button id="btn-clear-cache" type="button">Clear Cache</button>
    </div>
    <div class="setting-group">
      <label>About</label>
      <span class="text-secondary">CrossTide — 12-method consensus engine</span>
    </div>
    ${renderWeightsSection(config.methodWeights)}
    <div class="setting-group">
      <label for="finnhub-key-input">
        Finnhub API Key
        <span class="text-secondary" style="font-weight:normal;font-size:0.85em">
          (optional — enables real-time streaming)
        </span>
      </label>
      <input
        id="finnhub-key-input"
        type="password"
        autocomplete="off"
        placeholder="Paste your Finnhub API key…"
        style="flex:1;min-width:0"
        value="${escapeAttr(storedKey)}"
        aria-describedby="finnhub-key-hint"
      />
      <button id="btn-finnhub-save" type="button">Save Key</button>
      <button id="btn-finnhub-clear" type="button" class="btn-danger"${!storedKey ? " disabled" : ""}>Clear</button>
      <p id="finnhub-key-hint" class="text-secondary" style="font-size:0.8em;margin:0">
        Key is stored only in your browser's localStorage. Get a free key at
        <a href="https://finnhub.io" rel="noopener noreferrer" target="_blank">finnhub.io</a>.
      </p>
    </div>`;

  const themeSelect = container.querySelector<HTMLSelectElement>("#theme-select");
  themeSelect?.addEventListener("change", () => {
    callbacks.onThemeChange(themeSelect.value as AppConfig["theme"]);
  });

  container.querySelector("#btn-export")?.addEventListener("click", () => callbacks.onExport());
  container.querySelector("#btn-export-gz")?.addEventListener("click", () => callbacks.onExportGz?.());
  container.querySelector("#btn-import")?.addEventListener("click", () => callbacks.onImport());
  container
    .querySelector("#btn-clear")
    ?.addEventListener("click", () => callbacks.onClearWatchlist());
  container
    .querySelector("#btn-clear-cache")
    ?.addEventListener("click", () => callbacks.onClearCache());

  // Finnhub API key save/clear
  const keyInput = container.querySelector<HTMLInputElement>("#finnhub-key-input");
  const clearBtn = container.querySelector<HTMLButtonElement>("#btn-finnhub-clear");
  container.querySelector("#btn-finnhub-save")?.addEventListener("click", () => {
    const key = keyInput?.value.trim() ?? "";
    if (!key) return;
    callbacks.onFinnhubKeyChange?.(key);
    if (clearBtn) clearBtn.disabled = false;
  });
  clearBtn?.addEventListener("click", () => {
    if (keyInput) keyInput.value = "";
    clearBtn.disabled = true;
    callbacks.onFinnhubKeyChange?.(null);
  });

  // G20: consensus weight sliders
  function readWeights(): MethodWeights {
    const w: MethodWeights = {};
    for (const method of METHOD_NAMES) {
      const slider = container.querySelector<HTMLInputElement>(`#weight-${method}`);
      if (slider) {
        const v = parseFloat(slider.value);
        if (!isNaN(v)) w[method] = Math.min(3, Math.max(0, v));
      }
    }
    return w;
  }

  for (const method of METHOD_NAMES) {
    container.querySelector(`#weight-${method}`)?.addEventListener("input", () => {
      const val = container.querySelector<HTMLInputElement>(`#weight-${method}`)?.value ?? "1";
      const label = container.querySelector<HTMLOutputElement>(`#weight-${method}-out`);
      if (label) label.textContent = parseFloat(val).toFixed(1);
      callbacks.onMethodWeightsChange?.(readWeights());
    });
  }

  container.querySelector("#btn-reset-weights")?.addEventListener("click", () => {
    for (const method of METHOD_NAMES) {
      const slider = container.querySelector<HTMLInputElement>(`#weight-${method}`);
      const label = container.querySelector<HTMLOutputElement>(`#weight-${method}-out`);
      const def = DEFAULT_METHOD_WEIGHTS[method] ?? 1;
      if (slider) slider.value = String(def);
      if (label) label.textContent = def.toFixed(1);
    }
    callbacks.onMethodWeightsChange?.({ ...DEFAULT_METHOD_WEIGHTS });
  });
}

function renderWeightsSection(methodWeights?: MethodWeights): string {
  const rows = METHOD_NAMES.map((method) => {
    const defaultVal = DEFAULT_METHOD_WEIGHTS[method] ?? 1;
    const currentVal = methodWeights?.[method] ?? defaultVal;
    return `<div class="weight-row">
      <label for="weight-${method}" class="weight-label">${method}</label>
      <input
        id="weight-${method}"
        type="range"
        min="0" max="3" step="0.1"
        value="${currentVal.toFixed(1)}"
        class="weight-slider"
        aria-label="${method} weight"
      />
      <output id="weight-${method}-out" class="weight-value">${currentVal.toFixed(1)}</output>
    </div>`;
  }).join("");

  return `<div class="setting-group">
    <label>Consensus Weights
      <span class="text-secondary" style="font-weight:normal;font-size:0.85em">
        (0 = disabled, 1 = normal, 3 = triple)
      </span>
    </label>
    <div class="weight-grid">${rows}</div>
    <button id="btn-reset-weights" type="button">Reset to defaults</button>
  </div>`;
}

function escapeAttr(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}
