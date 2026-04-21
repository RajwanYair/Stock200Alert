/**
 * Hash-based router for single-page navigation.
 */

export type RouteName = "watchlist" | "consensus" | "chart" | "alerts" | "settings";

const VALID_ROUTES = new Set<RouteName>(["watchlist", "consensus", "chart", "alerts", "settings"]);

export type RouteChangeHandler = (route: RouteName) => void;

const listeners: RouteChangeHandler[] = [];

export function onRouteChange(handler: RouteChangeHandler): () => void {
  listeners.push(handler);
  return () => {
    const idx = listeners.indexOf(handler);
    if (idx !== -1) listeners.splice(idx, 1);
  };
}

export function navigateTo(route: RouteName): void {
  window.location.hash = route;
}

export function getCurrentRoute(): RouteName {
  const hash = window.location.hash.slice(1) || "watchlist";
  return VALID_ROUTES.has(hash as RouteName) ? (hash as RouteName) : "watchlist";
}

export function initRouter(): void {
  window.addEventListener("hashchange", handleRoute);
  handleRoute();
}

function handleRoute(): void {
  const route = getCurrentRoute();
  activateView(route);
  for (const fn of listeners) fn(route);
}

function activateView(route: RouteName): void {
  // Update nav links
  document.querySelectorAll<HTMLAnchorElement>(".nav-link").forEach((link) => {
    link.classList.toggle("active", link.dataset["route"] === route);
  });

  // Update views
  document.querySelectorAll<HTMLElement>(".view").forEach((view) => {
    view.classList.toggle("active", view.id === `view-${route}`);
  });
}
