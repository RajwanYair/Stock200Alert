/**
 * Router tests.
 */
import { describe, it, expect, beforeEach } from "vitest";
import {
  initRouter,
  navigateTo,
  getCurrentRoute,
  onRouteChange,
} from "../../../src/ui/router";

function setupDOM(): void {
  document.body.innerHTML = `
    <nav>
      <a class="nav-link" data-route="watchlist" href="#watchlist">Watchlist</a>
      <a class="nav-link" data-route="consensus" href="#consensus">Consensus</a>
      <a class="nav-link" data-route="chart" href="#chart">Chart</a>
      <a class="nav-link" data-route="alerts" href="#alerts">Alerts</a>
      <a class="nav-link" data-route="settings" href="#settings">Settings</a>
    </nav>
    <div id="view-watchlist" class="view"></div>
    <div id="view-consensus" class="view"></div>
    <div id="view-chart" class="view"></div>
    <div id="view-alerts" class="view"></div>
    <div id="view-settings" class="view"></div>
  `;
}

describe("initRouter", () => {
  beforeEach(() => {
    setupDOM();
    window.location.hash = "";
  });

  it("activates watchlist view by default when no hash", () => {
    initRouter();

    const view = document.getElementById("view-watchlist");
    expect(view?.classList.contains("active")).toBe(true);
  });

  it("activates correct view from hash", () => {
    window.location.hash = "#settings";
    initRouter();

    const view = document.getElementById("view-settings");
    expect(view?.classList.contains("active")).toBe(true);
  });

  it("falls back to watchlist for invalid hash", () => {
    window.location.hash = "#invalid";
    initRouter();

    const view = document.getElementById("view-watchlist");
    expect(view?.classList.contains("active")).toBe(true);
  });

  it("updates nav link active class", () => {
    window.location.hash = "#consensus";
    initRouter();

    const link = document.querySelector('[data-route="consensus"]');
    expect(link?.classList.contains("active")).toBe(true);

    const other = document.querySelector('[data-route="watchlist"]');
    expect(other?.classList.contains("active")).toBe(false);
  });

  it("responds to hashchange events", () => {
    initRouter();
    window.location.hash = "#settings";
    window.dispatchEvent(new Event("hashchange"));

    const view = document.getElementById("view-settings");
    expect(view?.classList.contains("active")).toBe(true);
  });
});

describe("navigateTo", () => {
  it("sets the hash", () => {
    navigateTo("alerts");
    expect(window.location.hash).toBe("#alerts");
  });
});

describe("getCurrentRoute", () => {
  it("returns current route from hash", () => {
    window.location.hash = "#chart";
    expect(getCurrentRoute()).toBe("chart");
  });

  it("returns watchlist for empty hash", () => {
    window.location.hash = "";
    expect(getCurrentRoute()).toBe("watchlist");
  });
});

describe("onRouteChange", () => {
  beforeEach(() => {
    setupDOM();
    window.location.hash = "";
  });

  it("calls handler on route change", () => {
    initRouter();
    const routes: string[] = [];
    onRouteChange((r) => routes.push(r));
    window.location.hash = "#alerts";
    window.dispatchEvent(new Event("hashchange"));
    expect(routes).toContain("alerts");
  });

  it("returns unsubscribe function", () => {
    initRouter();
    const routes: string[] = [];
    const unsub = onRouteChange((r) => routes.push(r));
    unsub();
    window.location.hash = "#settings";
    window.dispatchEvent(new Event("hashchange"));
    expect(routes).toHaveLength(0);
  });
});
