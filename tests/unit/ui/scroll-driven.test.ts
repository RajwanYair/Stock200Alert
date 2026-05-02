/**
 * Unit tests for scroll-driven animations utility (H4).
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import {
  supportsScrollDriven,
  supportsViewTimeline,
  createScrollTimeline,
  createViewTimeline,
  attachScrollProgress,
  buildScrollTimelineCss,
  buildViewTimelineCss,
  buildAnimationCss,
} from "../../../src/ui/scroll-driven";

// ── Feature detection ─────────────────────────────────────────────────────

describe("supportsScrollDriven", () => {
  afterEach(() => {
    delete (globalThis as Record<string, unknown>)["ScrollTimeline"];
  });

  it("returns false when ScrollTimeline is absent", () => {
    expect(supportsScrollDriven()).toBe(false);
  });

  it("returns true when ScrollTimeline exists", () => {
    (globalThis as Record<string, unknown>)["ScrollTimeline"] = class {};
    expect(supportsScrollDriven()).toBe(true);
  });
});

describe("supportsViewTimeline", () => {
  afterEach(() => {
    delete (globalThis as Record<string, unknown>)["ViewTimeline"];
  });

  it("returns false when ViewTimeline is absent", () => {
    expect(supportsViewTimeline()).toBe(false);
  });

  it("returns true when ViewTimeline exists", () => {
    (globalThis as Record<string, unknown>)["ViewTimeline"] = class {};
    expect(supportsViewTimeline()).toBe(true);
  });
});

// ── createScrollTimeline ──────────────────────────────────────────────────

describe("createScrollTimeline", () => {
  afterEach(() => {
    delete (globalThis as Record<string, unknown>)["ScrollTimeline"];
  });

  it("returns null when unsupported", () => {
    const el = document.createElement("div");
    expect(createScrollTimeline(el)).toBeNull();
  });

  it("creates a timeline when supported", () => {
    const mockTimeline = {};
    (globalThis as Record<string, unknown>)["ScrollTimeline"] = class {
      constructor() {
        return mockTimeline;
      }
    };
    const el = document.createElement("div");
    const handle = createScrollTimeline(el, "x");
    expect(handle).not.toBeNull();
    expect(handle!.timeline).toBe(mockTimeline);
  });

  it("passes source and axis to constructor", () => {
    let captured: unknown;
    (globalThis as Record<string, unknown>)["ScrollTimeline"] = class {
      constructor(opts: unknown) {
        captured = opts;
      }
    };
    const el = document.createElement("div");
    createScrollTimeline(el, "inline");
    expect(captured).toEqual({ source: el, axis: "inline" });
  });

  it("defaults axis to block", () => {
    let captured: unknown;
    (globalThis as Record<string, unknown>)["ScrollTimeline"] = class {
      constructor(opts: unknown) {
        captured = opts;
      }
    };
    const el = document.createElement("div");
    createScrollTimeline(el);
    expect(captured).toEqual({ source: el, axis: "block" });
  });

  it("dispose is a no-op function", () => {
    (globalThis as Record<string, unknown>)["ScrollTimeline"] = class {};
    const el = document.createElement("div");
    const handle = createScrollTimeline(el)!;
    expect(() => handle.dispose()).not.toThrow();
  });
});

// ── createViewTimeline ────────────────────────────────────────────────────

describe("createViewTimeline", () => {
  afterEach(() => {
    delete (globalThis as Record<string, unknown>)["ViewTimeline"];
  });

  it("returns null when unsupported", () => {
    const el = document.createElement("div");
    expect(createViewTimeline(el)).toBeNull();
  });

  it("creates a timeline when supported", () => {
    const mockTimeline = {};
    (globalThis as Record<string, unknown>)["ViewTimeline"] = class {
      constructor() {
        return mockTimeline;
      }
    };
    const el = document.createElement("div");
    const handle = createViewTimeline(el, "block", "20%");
    expect(handle).not.toBeNull();
    expect(handle!.timeline).toBe(mockTimeline);
  });

  it("passes inset as array", () => {
    let captured: unknown;
    (globalThis as Record<string, unknown>)["ViewTimeline"] = class {
      constructor(opts: unknown) {
        captured = opts;
      }
    };
    const el = document.createElement("div");
    createViewTimeline(el, "y", "10% 20%");
    expect(captured).toEqual({
      subject: el,
      axis: "y",
      inset: ["10%", "20%"],
    });
  });

  it("omits inset when not provided", () => {
    let captured: unknown;
    (globalThis as Record<string, unknown>)["ViewTimeline"] = class {
      constructor(opts: unknown) {
        captured = opts;
      }
    };
    const el = document.createElement("div");
    createViewTimeline(el);
    expect(captured).toEqual({ subject: el, axis: "block" });
  });
});

// ── attachScrollProgress ──────────────────────────────────────────────────

describe("attachScrollProgress", () => {
  afterEach(() => {
    delete (globalThis as Record<string, unknown>)["ScrollTimeline"];
  });

  it("falls back to scroll event when unsupported", () => {
    const el = document.createElement("div");
    const spy = vi.fn();
    const cleanup = attachScrollProgress(el, spy);
    expect(typeof cleanup).toBe("function");
    cleanup();
  });

  it("cleanup removes scroll listener", () => {
    const el = document.createElement("div");
    const removeSpy = vi.spyOn(el, "removeEventListener");
    const cleanup = attachScrollProgress(el, vi.fn());
    cleanup();
    expect(removeSpy).toHaveBeenCalledWith("scroll", expect.any(Function));
  });
});

// ── CSS generation ────────────────────────────────────────────────────────

describe("buildScrollTimelineCss", () => {
  it("generates scroll-timeline property", () => {
    expect(buildScrollTimelineCss("chart-scroll", "x")).toBe("scroll-timeline: --chart-scroll x;");
  });

  it("defaults to block axis", () => {
    expect(buildScrollTimelineCss("main")).toBe("scroll-timeline: --main block;");
  });
});

describe("buildViewTimelineCss", () => {
  it("generates view-timeline property", () => {
    expect(buildViewTimelineCss("card-reveal", "block")).toBe(
      "view-timeline: --card-reveal block;",
    );
  });

  it("includes inset when provided", () => {
    const css = buildViewTimelineCss("reveal", "block", "20%");
    expect(css).toContain("view-timeline-inset: 20%;");
  });

  it("omits inset when not provided", () => {
    const css = buildViewTimelineCss("reveal");
    expect(css).not.toContain("inset");
  });
});

describe("buildAnimationCss", () => {
  it("generates animation + timeline CSS", () => {
    const css = buildAnimationCss("fade-in", "chart-scroll");
    expect(css).toContain("animation: fade-in auto linear both;");
    expect(css).toContain("animation-timeline: --chart-scroll;");
  });

  it("applies custom duration and easing", () => {
    const css = buildAnimationCss("slide", "main", {
      duration: "300ms",
      easing: "ease-out",
    });
    expect(css).toContain("300ms");
    expect(css).toContain("ease-out");
  });

  it("includes animation-range when provided", () => {
    const css = buildAnimationCss("reveal", "view", {
      range: "entry 0% cover 100%",
    });
    expect(css).toContain("animation-range: entry 0% cover 100%;");
  });

  it("omits animation-range when not provided", () => {
    const css = buildAnimationCss("fade", "scroll");
    expect(css).not.toContain("animation-range");
  });
});
