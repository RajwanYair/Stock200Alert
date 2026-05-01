/**
 * Accessibility utilities — focus management, screen reader announcements.
 */
import { announce as ariaAnnounce } from "./aria-live";

/**
 * Announce a message to screen readers via a live region.
 * Delegates to the canonical aria-live implementation.
 */
export function announce(message: string, priority: "polite" | "assertive" = "polite"): void {
  ariaAnnounce(message, priority);
}

/**
 * Trap focus within an element. Returns a cleanup function.
 */
export function trapFocus(container: HTMLElement): () => void {
  const focusable = container.querySelectorAll<HTMLElement>(
    'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
  );
  const first = focusable[0];
  const last = focusable[focusable.length - 1];

  function handler(e: KeyboardEvent): void {
    if (e.key !== "Tab") return;
    if (focusable.length === 0) {
      e.preventDefault();
      return;
    }
    if (e.shiftKey) {
      if (document.activeElement === first) {
        e.preventDefault();
        last?.focus();
      }
    } else {
      if (document.activeElement === last) {
        e.preventDefault();
        first?.focus();
      }
    }
  }

  container.addEventListener("keydown", handler);
  first?.focus();

  return () => container.removeEventListener("keydown", handler);
}

/**
 * Check if the user prefers reduced motion.
 */
export function prefersReducedMotion(): boolean {
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}
