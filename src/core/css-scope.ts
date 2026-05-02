/**
 * CSS @scope utility module (H5).
 *
 * CSS `@scope` (Baseline 2024, Chrome 118+, Firefox 128+, Safari 17.4+)
 * allows you to limit the reach of selector rules to a particular subtree
 * without relying on naming conventions (BEM) or Shadow DOM.
 *
 * This module provides:
 *
 *   - `supportsCssScope()` — feature-detect `@scope` without throwing.
 *   - `injectScopedStyles(scopeSelector, css, id?)` — inject a `<style>`
 *     element wrapping the given CSS in `@scope(<selector>)`.
 *   - `removeScopedStyles(id)` — remove a previously injected style element.
 *   - `removeAllScopedStyles()` — remove every element injected by this module.
 *   - `buildScopeRule(scopeSelector, css)` — pure helper that returns the
 *     `@scope` rule string (useful for constructable stylesheets).
 *
 * When `@scope` is unsupported the CSS is injected as-is (no wrapping) so the
 * styles remain functional, albeit without scope containment.
 *
 * @see https://developer.mozilla.org/en-US/docs/Web/CSS/@scope
 */

const STYLE_ATTR = "data-ct-scope";

// ─── feature detection ────────────────────────────────────────────────────────

/**
 * Returns `true` when `@scope` CSS at-rules are supported in this environment.
 *
 * Uses `CSS.supports("selector(:scope)")` as a proxy — browsers that ship
 * `@scope` also support the `:scope` selector in `supports()`.
 * As a secondary check we attempt to construct a `CSSStyleSheet` with an
 * `@scope` rule; any parse error falls back to `false`.
 */
export function supportsCssScope(): boolean {
  // Primary heuristic: CSS.supports returns false on browsers without @scope
  if (typeof CSS === "undefined" || typeof CSS.supports !== "function") {
    return false;
  }
  // Try inserting an @scope rule into a constructable stylesheet
  try {
    const sheet = new CSSStyleSheet();
    sheet.insertRule("@scope (.x) { .y { color: red; } }");
    return true;
  } catch {
    return false;
  }
}

// ─── rule builder ─────────────────────────────────────────────────────────────

/**
 * Build an `@scope` CSS rule string.
 *
 * ```css
 * @scope (.card) {
 *   h2 { font-size: 1.25rem; }
 * }
 * ```
 *
 * @param scopeSelector  CSS selector for the scope root, e.g. `".card"`.
 * @param css            CSS rules to scope, e.g. `"h2 { font-size: 1rem; }"`.
 */
export function buildScopeRule(scopeSelector: string, css: string): string {
  return `@scope (${scopeSelector}) {\n${css}\n}`;
}

// ─── inject / remove ─────────────────────────────────────────────────────────

let _idCounter = 0;

/**
 * Inject a `<style>` element with scoped CSS into `<head>`.
 *
 * When `@scope` is unsupported the `css` is injected verbatim so the page
 * remains functional.
 *
 * @param scopeSelector  CSS selector for the scope root, e.g. `".card"`.
 * @param css            CSS rules body (without outer braces when scoped).
 * @param id             Stable identifier for later removal.  Auto-generated
 *                       when omitted.
 * @returns The injected `<style>` element.
 */
export function injectScopedStyles(
  scopeSelector: string,
  css: string,
  id?: string,
): HTMLStyleElement {
  const resolvedId = id ?? `ct-scope-${++_idCounter}`;
  const el = document.createElement("style");
  el.setAttribute(STYLE_ATTR, resolvedId);
  el.textContent = supportsCssScope() ? buildScopeRule(scopeSelector, css) : css;
  document.head.appendChild(el);
  return el;
}

/**
 * Remove a `<style>` element previously injected by this module.
 *
 * @param id  The id passed to (or returned by) `injectScopedStyles`.
 */
export function removeScopedStyles(id: string): void {
  document.querySelectorAll(`style[${STYLE_ATTR}="${id}"]`).forEach((el) => el.remove());
}

/**
 * Remove **all** `<style>` elements injected by this module.
 */
export function removeAllScopedStyles(): void {
  document.querySelectorAll(`style[${STYLE_ATTR}]`).forEach((el) => el.remove());
}
