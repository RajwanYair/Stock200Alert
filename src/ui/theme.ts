/**
 * Theme management — dark/light/high-contrast toggle.
 */

export type Theme = "dark" | "light" | "high-contrast";

export function applyTheme(theme: Theme): void {
  document.documentElement.dataset["theme"] = theme;
}

/** Detect system preference for high-contrast. */
export function detectHighContrast(): boolean {
  return window.matchMedia("(prefers-contrast: more)").matches;
}

/** Detect system preference for color scheme. */
export function detectPreferredTheme(): Theme {
  if (detectHighContrast()) return "high-contrast";
  return window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark";
}

export function initTheme(theme?: Theme): Theme {
  const resolved = theme ?? detectPreferredTheme();
  applyTheme(resolved);

  const select = document.getElementById("theme-select") as HTMLSelectElement | null;
  if (select) {
    select.value = resolved;
    select.addEventListener("change", () => {
      applyTheme(select.value as Theme);
    });
  }

  return resolved;
}
