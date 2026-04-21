/**
 * Extended router tests — navigation, route changes, defaults.
 */
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { getCurrentRoute, navigateTo, onRouteChange, initRouter } from "../../../src/ui/router";

describe("router extended", () => {
  beforeEach(() => {
    window.location.hash = "";
  });

  afterEach(() => {
    window.location.hash = "";
  });

  it("getCurrentRoute defaults to watchlist when hash is empty", () => {
    window.location.hash = "";
    expect(getCurrentRoute()).toBe("watchlist");
  });

  it("getCurrentRoute returns watchlist for invalid hash", () => {
    window.location.hash = "nonexistent-route";
    expect(getCurrentRoute()).toBe("watchlist");
  });

  it("getCurrentRoute returns correct route for valid hash", () => {
    window.location.hash = "settings";
    expect(getCurrentRoute()).toBe("settings");
  });

  it("navigateTo sets window hash", () => {
    navigateTo("consensus");
    expect(window.location.hash).toBe("#consensus");
  });

  it("onRouteChange listener is called on hash change", async () => {
    const spy = vi.fn();
    const unsub = onRouteChange(spy);
    initRouter();
    navigateTo("chart");
    window.dispatchEvent(new HashChangeEvent("hashchange"));
    expect(spy).toHaveBeenCalled();
    unsub();
  });

  it("onRouteChange unsubscribe stops notifications", () => {
    const spy = vi.fn();
    const unsub = onRouteChange(spy);
    initRouter();
    unsub();
    navigateTo("alerts");
    window.dispatchEvent(new HashChangeEvent("hashchange"));
    // spy may still be called from initRouter's initial call, but not from the navigation
    const callCountAfterUnsub = spy.mock.calls.length;
    navigateTo("settings");
    window.dispatchEvent(new HashChangeEvent("hashchange"));
    expect(spy.mock.calls.length).toBe(callCountAfterUnsub);
  });
});
