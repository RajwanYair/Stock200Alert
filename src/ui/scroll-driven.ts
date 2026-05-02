/**
 * Scroll-driven animations utility (H4).
 *
 * Progressive enhancement helpers for the CSS Scroll-driven Animations API
 * (scroll-timeline, view-timeline).  Used for the chart time-axis scroll
 * indicator and section-reveal effects.
 *
 * Exports:
 *   - `supportsScrollDriven()` — feature-detect CSS scroll-timeline
 *   - `supportsViewTimeline()` — feature-detect view-timeline
 *   - `createScrollTimeline(source, axis)` — ScrollTimeline wrapper
 *   - `createViewTimeline(subject, axis, inset)` — ViewTimeline wrapper
 *   - `attachScrollProgress(element, onProgress)` — observe scroll %
 *   - `buildScrollTimelineCss(name, axis)` — generate CSS declaration
 *   - `buildViewTimelineCss(name, axis, inset)` — generate CSS declaration
 *   - `buildAnimationCss(name, timelineName, opts)` — CSS animation rule
 *
 * When the API is not available, helpers return null / no-op so callers
 * don't need feature-specific branches.
 *
 * Spec: https://drafts.csswg.org/scroll-animations-1/
 */

// ── Types ─────────────────────────────────────────────────────────────────

export type ScrollAxis = "block" | "inline" | "x" | "y";

export interface ScrollProgressCallback {
  (progress: number): void;
}

export interface AnimationCssOptions {
  /** Animation duration (default: "auto" for scroll-driven). */
  duration?: string;
  /** Fill mode (default: "both"). */
  fill?: string;
  /** Timing function (default: "linear"). */
  easing?: string;
  /** Animation range (e.g. "entry 0% cover 100%"). */
  range?: string;
}

export interface ScrollTimelineHandle {
  /** The underlying ScrollTimeline instance (or null). */
  timeline: unknown;
  /** Remove the timeline. */
  dispose: () => void;
}

export interface ViewTimelineHandle {
  /** The underlying ViewTimeline instance (or null). */
  timeline: unknown;
  /** Remove the timeline. */
  dispose: () => void;
}

// ── Feature detection ─────────────────────────────────────────────────────

/** Returns `true` when CSS ScrollTimeline is available. */
export function supportsScrollDriven(): boolean {
  return typeof globalThis !== "undefined" && "ScrollTimeline" in globalThis;
}

/** Returns `true` when CSS ViewTimeline is available. */
export function supportsViewTimeline(): boolean {
  return typeof globalThis !== "undefined" && "ViewTimeline" in globalThis;
}

// ── ScrollTimeline ────────────────────────────────────────────────────────

/**
 * Create a ScrollTimeline for the given scroll container element.
 * Returns null when the API is unsupported.
 */
export function createScrollTimeline(
  source: Element,
  axis: ScrollAxis = "block",
): ScrollTimelineHandle | null {
  if (!supportsScrollDriven()) return null;

  const ST = (globalThis as Record<string, unknown>)["ScrollTimeline"] as new (opts: {
    source: Element;
    axis: string;
  }) => unknown;

  const timeline = new ST({ source, axis });
  return {
    timeline,
    dispose(): void {
      // ScrollTimeline is GC'd; no explicit teardown needed.
    },
  };
}

/**
 * Create a ViewTimeline for the given subject element.
 * Returns null when the API is unsupported.
 */
export function createViewTimeline(
  subject: Element,
  axis: ScrollAxis = "block",
  inset?: string,
): ViewTimelineHandle | null {
  if (!supportsViewTimeline()) return null;

  const VT = (globalThis as Record<string, unknown>)["ViewTimeline"] as new (opts: {
    subject: Element;
    axis: string;
    inset?: string[];
  }) => unknown;

  const opts: { subject: Element; axis: string; inset?: string[] } = { subject, axis };
  if (inset) opts.inset = inset.split(" ").filter(Boolean);

  const timeline = new VT(opts);
  return {
    timeline,
    dispose(): void {
      // ViewTimeline is GC'd; no explicit teardown needed.
    },
  };
}

// ── Scroll progress observer ──────────────────────────────────────────────

/**
 * Observe scroll progress (0–1) of an element using a ScrollTimeline
 * and a zero-duration Animation.  Falls back to a scroll event listener
 * when the API is unavailable.
 *
 * @returns cleanup function.
 */
export function attachScrollProgress(
  element: Element,
  onProgress: ScrollProgressCallback,
): () => void {
  // Fallback: classic scroll event
  if (!supportsScrollDriven()) {
    const handler = (): void => {
      const el = element as HTMLElement;
      const scrollable = el.scrollHeight - el.clientHeight;
      const ratio = scrollable > 0 ? el.scrollTop / scrollable : 0;
      onProgress(Math.min(Math.max(ratio, 0), 1));
    };
    element.addEventListener("scroll", handler, { passive: true });
    return (): void => element.removeEventListener("scroll", handler);
  }

  // Native scroll-driven animation path
  const handle = createScrollTimeline(element)!;
  const anim = (element as HTMLElement).animate([{ opacity: 0 }, { opacity: 1 }], {
    duration: 1, // overridden by timeline
    fill: "both",
    timeline: handle.timeline as AnimationTimeline,
  });

  const tick = (): void => {
    if (anim.currentTime != null) {
      const ct = anim.currentTime as unknown;
      const progress = typeof ct === "number" ? ct : 0;
      onProgress(Math.min(Math.max(progress, 0), 1));
    }
    if (anim.playState !== "finished") {
      requestAnimationFrame(tick);
    }
  };
  requestAnimationFrame(tick);

  return (): void => {
    anim.cancel();
    handle.dispose();
  };
}

// ── CSS generation helpers ────────────────────────────────────────────────

/**
 * Generate a `scroll-timeline` CSS property value.
 *
 * @example buildScrollTimelineCss("chart-scroll", "x")
 * // → "scroll-timeline: --chart-scroll x;"
 */
export function buildScrollTimelineCss(name: string, axis: ScrollAxis = "block"): string {
  return `scroll-timeline: --${name} ${axis};`;
}

/**
 * Generate a `view-timeline` CSS property value.
 *
 * @example buildViewTimelineCss("card-reveal", "block", "20%")
 * // → "view-timeline: --card-reveal block; view-timeline-inset: 20%;"
 */
export function buildViewTimelineCss(
  name: string,
  axis: ScrollAxis = "block",
  inset?: string,
): string {
  let css = `view-timeline: --${name} ${axis};`;
  if (inset) css += ` view-timeline-inset: ${inset};`;
  return css;
}

/**
 * Generate CSS animation shorthand tied to a scroll timeline.
 *
 * @example buildAnimationCss("fade-in", "chart-scroll")
 * // → "animation: fade-in auto linear both; animation-timeline: --chart-scroll;"
 */
export function buildAnimationCss(
  animationName: string,
  timelineName: string,
  opts: AnimationCssOptions = {},
): string {
  const duration = opts.duration ?? "auto";
  const easing = opts.easing ?? "linear";
  const fill = opts.fill ?? "both";
  let css = `animation: ${animationName} ${duration} ${easing} ${fill};`;
  css += ` animation-timeline: --${timelineName};`;
  if (opts.range) css += ` animation-range: ${opts.range};`;
  return css;
}
