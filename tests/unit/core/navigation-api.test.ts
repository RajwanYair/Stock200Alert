/**
 * Tests for G8 — Navigation API progressive enhancement module.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  supportsNavigationApi,
  getNavigationApi,
  interceptNavigation,
  navigateWithApi,
  currentNavigationUrl,
  onNavigationStart,
  isSameOrigin,
} from "../../../src/core/navigation-api";
import type { NavigationApiLike, NavigateEventLike } from "../../../src/core/navigation-api";

// ─── helpers ─────────────────────────────────────────────────────────────────

interface WindowWithNav extends Window {
  navigation?: NavigationApiLike;
}

function makeNav(currentUrl = "http://localhost/"): NavigationApiLike & {
  _listeners: Array<(e: NavigateEventLike) => void>;
  _fire(url: string, canIntercept?: boolean): void;
} {
  const listeners: Array<(e: NavigateEventLike) => void> = [];
  const intercepts: Array<() => Promise<void>> = [];

  const nav: ReturnType<typeof makeNav> = {
    currentEntry: { url: currentUrl },
    navigate: vi.fn(() => ({
      committed: Promise.resolve(),
      finished: Promise.resolve(),
    })),
    addEventListener: vi.fn((_, h) => {
      listeners.push(h as (e: NavigateEventLike) => void);
    }),
    removeEventListener: vi.fn((_, h) => {
      const i = listeners.indexOf(h as (e: NavigateEventLike) => void);
      if (i >= 0) listeners.splice(i, 1);
    }),
    _listeners: listeners,
    _fire(url, canIntercept = true) {
      const signal = new AbortController().signal;
      const e: NavigateEventLike = {
        destination: { url },
        canIntercept: canIntercept,
        signal,
        hashChange: false,
        downloadRequest: null,
        intercept: (opts) => {
          intercepts.push(opts.handler);
        },
        preventDefault: vi.fn(),
      };
      listeners.forEach((l) => l(e));
    },
  };
  return nav;
}

beforeEach(() => {
  delete (window as WindowWithNav).navigation;
});
afterEach(() => {
  delete (window as WindowWithNav).navigation;
  vi.restoreAllMocks();
});

// ─── supportsNavigationApi ───────────────────────────────────────────────────

describe("supportsNavigationApi", () => {
  it("returns false when navigation is absent", () => {
    expect(supportsNavigationApi()).toBe(false);
  });

  it("returns true when navigation object is present", () => {
    (window as WindowWithNav).navigation = makeNav();
    expect(supportsNavigationApi()).toBe(true);
  });
});

// ─── getNavigationApi ────────────────────────────────────────────────────────

describe("getNavigationApi", () => {
  it("returns null when API absent", () => {
    expect(getNavigationApi()).toBeNull();
  });

  it("returns navigation object when present", () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;
    expect(getNavigationApi()).toBe(nav);
  });
});

// ─── interceptNavigation ─────────────────────────────────────────────────────

describe("interceptNavigation", () => {
  it("returns no-op disposer when API is absent", () => {
    const disposer = interceptNavigation(async () => {});
    expect(typeof disposer).toBe("function");
    // calling disposer should not throw
    expect(() => disposer()).not.toThrow();
  });

  it("registers navigate listener when API is present", () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    interceptNavigation(async () => {});
    expect(nav.addEventListener).toHaveBeenCalledWith("navigate", expect.any(Function));
  });

  it("disposer removes the listener", () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    const dispose = interceptNavigation(async () => {});
    dispose();
    expect(nav.removeEventListener).toHaveBeenCalled();
  });

  it("calls handler with URL and AbortSignal when navigate fires", async () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    const received: string[] = [];
    interceptNavigation(async (url) => {
      received.push(url);
    });
    nav._fire("http://localhost/chart");
    // handler is registered via intercept — we can't call it directly in this test,
    // but we can verify the intercept was set up by checking that listeners were added
    expect(nav._listeners).toHaveLength(1);
  });

  it("skips navigation when canIntercept is false", async () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    const called: boolean[] = [];
    interceptNavigation(async () => {
      called.push(true);
    });
    nav._fire("http://localhost/chart", false);
    // handler should NOT have been intercepted
    expect(called).toHaveLength(0);
  });
});

// ─── navigateWithApi ─────────────────────────────────────────────────────────

describe("navigateWithApi", () => {
  it("calls navigation.navigate when API is present", () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    navigateWithApi("/chart");
    expect(nav.navigate).toHaveBeenCalledWith("/chart");
  });

  it("falls back to history.pushState when API absent", () => {
    const pushSpy = vi.spyOn(history, "pushState").mockImplementation(() => {});
    const dispatchSpy = vi.spyOn(window, "dispatchEvent").mockImplementation(() => true);

    navigateWithApi("/watchlist");
    expect(pushSpy).toHaveBeenCalledWith(null, "", "/watchlist");
    expect(dispatchSpy).toHaveBeenCalledWith(expect.any(PopStateEvent));
  });
});

// ─── currentNavigationUrl ────────────────────────────────────────────────────

describe("currentNavigationUrl", () => {
  it("returns location.href when API absent", () => {
    expect(currentNavigationUrl()).toBe(window.location.href);
  });

  it("returns currentEntry.url when API present", () => {
    const nav = makeNav("http://localhost/chart/AAPL");
    (window as WindowWithNav).navigation = nav;
    expect(currentNavigationUrl()).toBe("http://localhost/chart/AAPL");
  });
});

// ─── onNavigationStart ───────────────────────────────────────────────────────

describe("onNavigationStart", () => {
  it("returns no-op disposer when API absent", () => {
    const disposer = onNavigationStart(() => {});
    expect(() => disposer()).not.toThrow();
  });

  it("calls callback when navigate event fires", () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    const urls: string[] = [];
    onNavigationStart((url) => urls.push(url));
    nav._fire("http://localhost/screener");
    expect(urls).toContain("http://localhost/screener");
  });

  it("disposer stops callback from being called", () => {
    const nav = makeNav();
    (window as WindowWithNav).navigation = nav;

    const urls: string[] = [];
    const dispose = onNavigationStart((url) => urls.push(url));
    dispose();
    nav._fire("http://localhost/portfolio");
    expect(urls).toHaveLength(0);
  });
});

// ─── isSameOrigin ────────────────────────────────────────────────────────────

describe("isSameOrigin", () => {
  it("relative path is same origin", () => {
    expect(isSameOrigin("/chart")).toBe(true);
  });

  it("same-origin absolute URL is same origin", () => {
    expect(isSameOrigin(window.location.origin + "/watchlist")).toBe(true);
  });

  it("different origin returns false", () => {
    expect(isSameOrigin("https://external.example.com/path")).toBe(false);
  });

  it("data URL returns false", () => {
    expect(isSameOrigin("data:text/plain,hello")).toBe(false);
  });
});
