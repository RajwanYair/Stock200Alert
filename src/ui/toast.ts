/**
 * Toast notification system — auto-dismiss notifications.
 *
 * Creates a container once, appends toast elements that self-remove.
 * No external dependencies.
 */

export type ToastType = "info" | "success" | "warning" | "error";

export interface ToastOptions {
  readonly message: string;
  readonly type?: ToastType;
  /** Auto-dismiss delay in ms. 0 = manual dismiss only. Default 4000. */
  readonly durationMs?: number;
}

interface ActiveToast {
  readonly el: HTMLElement;
  readonly timer: ReturnType<typeof setTimeout> | null;
}

const CONTAINER_ID = "toast-container";
const DEFAULT_DURATION = 4000;

let container: HTMLElement | null = null;
const activeToasts: ActiveToast[] = [];

function ensureContainer(): HTMLElement {
  if (container && document.body.contains(container)) return container;
  container = document.createElement("div");
  container.id = CONTAINER_ID;
  container.setAttribute("aria-live", "polite");
  container.setAttribute("role", "status");
  document.body.appendChild(container);
  return container;
}

function dismiss(toast: ActiveToast): void {
  if (toast.timer !== null) clearTimeout(toast.timer);
  toast.el.classList.add("toast-exit");

  const idx = activeToasts.indexOf(toast);
  if (idx !== -1) activeToasts.splice(idx, 1);

  // Remove from DOM after animation (or immediately if no animation support)
  const onEnd = (): void => {
    toast.el.remove();
  };
  if (typeof toast.el.getAnimations === "function" && toast.el.getAnimations().length > 0) {
    toast.el.addEventListener("animationend", onEnd, { once: true });
  } else {
    onEnd();
  }
}

export function showToast(options: ToastOptions): () => void {
  const parent = ensureContainer();
  const type = options.type ?? "info";
  const duration = options.durationMs ?? DEFAULT_DURATION;

  const el = document.createElement("div");
  el.className = `toast toast-${type}`;
  el.setAttribute("role", "alert");
  el.textContent = options.message;

  const closeBtn = document.createElement("button");
  closeBtn.className = "toast-close";
  closeBtn.setAttribute("aria-label", "Dismiss");
  closeBtn.textContent = "\u00d7";
  el.appendChild(closeBtn);

  parent.appendChild(el);

  const timer = duration > 0 ? setTimeout(() => dismiss(toast), duration) : null;
  const toast: ActiveToast = { el, timer };
  activeToasts.push(toast);

  closeBtn.addEventListener("click", () => dismiss(toast));

  return () => dismiss(toast);
}

export function clearAllToasts(): void {
  for (const t of [...activeToasts]) dismiss(t);
}

/** Returns the number of currently visible toasts. */
export function toastCount(): number {
  return activeToasts.length;
}
