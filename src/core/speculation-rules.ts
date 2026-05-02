/**
 * Speculation Rules API module (H3).
 *
 * The Speculation Rules API lets the browser speculatively prerender or
 * prefetch pages based on JSON rules injected via a
 * `<script type="speculationrules">` element.  When available it is
 * substantially faster than `<link rel="prefetch">` because the browser
 * can prerender the full page lifecycle in a hidden tab.
 *
 * Baseline 2024 — available in Chromium 121+; gracefully skipped on
 * Firefox / Safari where we fall back to `<link rel="prefetch">`.
 *
 * ## Exported API
 * - `speculationRulesSupported()` — feature-detect without throwing.
 * - `injectSpeculationRules(rules)` — inject an arbitrary rules object.
 * - `buildPrefetchRules(hrefs)` — convenience: build a minimal prefetch rule.
 * - `buildPrerenderRules(hrefs)` — convenience: build a minimal prerender rule.
 * - `removeSpeculationRules(id?)` — remove injected rules element(s).
 * - `linkPrefetchFallback(hrefs)` — `<link rel="prefetch">` fallback.
 *
 * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script/type/speculationrules
 */

const SCRIPT_ATTR = "data-ct-speculation";

// ─── types ────────────────────────────────────────────────────────────────────

/** A single speculation source entry. */
export interface SpeculationSource {
  /** Explicit list of URLs. */
  urls?: string[];
  /** CSS selector-based dynamic list. */
  where?: Record<string, unknown>;
  /** Eagerness hint: "immediate" | "eager" | "moderate" | "conservative" */
  eagerness?: "immediate" | "eager" | "moderate" | "conservative";
}

/** The top-level speculation rules object. */
export interface SpeculationRules {
  prefetch?: SpeculationSource[];
  prerender?: SpeculationSource[];
}

// ─── feature detection ────────────────────────────────────────────────────────

/**
 * Returns `true` when `<script type="speculationrules">` is supported.
 * Uses `HTMLScriptElement.supports` without throwing on older browsers.
 */
export function speculationRulesSupported(): boolean {
  return (
    typeof HTMLScriptElement !== "undefined" &&
    typeof HTMLScriptElement.supports === "function" &&
    HTMLScriptElement.supports("speculationrules")
  );
}

// ─── inject / remove ─────────────────────────────────────────────────────────

let _idCounter = 0;

/**
 * Inject a `<script type="speculationrules">` element into `<head>`.
 *
 * @param rules  Speculation rules object.
 * @param id     Optional stable id for later removal.  Auto-generated if omitted.
 * @returns The injected `<script>` element (or `null` when unsupported).
 */
export function injectSpeculationRules(
  rules: SpeculationRules,
  id?: string,
): HTMLScriptElement | null {
  if (!speculationRulesSupported()) return null;

  const el = document.createElement("script");
  el.type = "speculationrules";
  el.textContent = JSON.stringify(rules);

  const resolvedId = id ?? `ct-sr-${++_idCounter}`;
  el.setAttribute(SCRIPT_ATTR, resolvedId);

  document.head.appendChild(el);
  return el;
}

/**
 * Remove injected speculation rules elements.
 *
 * @param id  When provided, removes only the element with that id.
 *            When omitted, removes **all** `[data-ct-speculation]` elements.
 */
export function removeSpeculationRules(id?: string): void {
  const selector = id ? `script[${SCRIPT_ATTR}="${id}"]` : `script[${SCRIPT_ATTR}]`;
  document.querySelectorAll(selector).forEach((el) => el.remove());
}

// ─── convenience builders ─────────────────────────────────────────────────────

/**
 * Build a minimal prefetch rules object for an explicit list of URLs.
 */
export function buildPrefetchRules(
  hrefs: string[],
  eagerness: SpeculationSource["eagerness"] = "moderate",
): SpeculationRules {
  return { prefetch: [{ urls: hrefs, eagerness }] };
}

/**
 * Build a minimal prerender rules object for an explicit list of URLs.
 */
export function buildPrerenderRules(
  hrefs: string[],
  eagerness: SpeculationSource["eagerness"] = "conservative",
): SpeculationRules {
  return { prerender: [{ urls: hrefs, eagerness }] };
}

// ─── link-prefetch fallback ───────────────────────────────────────────────────

/**
 * Inject `<link rel="prefetch">` elements as a fallback for browsers
 * that do not support the Speculation Rules API.
 *
 * @returns Array of injected link elements.
 */
export function linkPrefetchFallback(hrefs: string[]): HTMLLinkElement[] {
  return hrefs.map((href) => {
    const link = document.createElement("link");
    link.rel = "prefetch";
    link.href = href;
    document.head.appendChild(link);
    return link;
  });
}
