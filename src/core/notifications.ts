/**
 * Browser notifications — thin wrapper around the Notification API with
 * graceful degradation, permission flow, and tag-based deduplication.
 */

export type NotificationPermissionState =
  | "default"
  | "granted"
  | "denied"
  | "unsupported";

export interface AppNotificationOptions {
  readonly body?: string;
  readonly icon?: string;
  readonly tag?: string;
  readonly requireInteraction?: boolean;
  readonly silent?: boolean;
  readonly onClick?: () => void;
}

interface NotificationLike {
  close(): void;
  onclick?: ((this: unknown) => void) | null;
}

interface NotificationCtor {
  new (title: string, options?: NotificationOptions): NotificationLike;
  permission: NotificationPermission;
  requestPermission(): Promise<NotificationPermission>;
}

function getCtor(): NotificationCtor | null {
  if (typeof globalThis === "undefined") return null;
  const ctor = (globalThis as { Notification?: NotificationCtor }).Notification;
  return ctor ?? null;
}

export function isNotificationsSupported(): boolean {
  return getCtor() !== null;
}

export function getNotificationPermission(): NotificationPermissionState {
  const ctor = getCtor();
  if (!ctor) return "unsupported";
  return ctor.permission;
}

export async function requestNotificationPermission(): Promise<NotificationPermissionState> {
  const ctor = getCtor();
  if (!ctor) return "unsupported";
  const result = await ctor.requestPermission();
  return result;
}

/**
 * Show a notification. Returns a `close()` function (no-op when unsupported
 * or permission is not granted).
 */
export function showNotification(
  title: string,
  options: AppNotificationOptions = {},
): () => void {
  const ctor = getCtor();
  if (ctor?.permission !== "granted") {
    return (): void => {
      /* no-op */
    };
  }
  const n = new ctor(title, {
    body: options.body,
    icon: options.icon,
    tag: options.tag,
    requireInteraction: options.requireInteraction,
    silent: options.silent,
  });
  if (options.onClick) {
    n.onclick = options.onClick;
  }
  return (): void => {
    try {
      n.close();
    } catch {
      /* ignore */
    }
  };
}
