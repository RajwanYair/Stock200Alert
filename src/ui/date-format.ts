/**
 * DOM-free, deterministic date formatting helpers (UTC). Matches the
 * tokens supported by most chart libraries:
 *   YYYY MM DD HH mm ss SSS
 * Plus convenience helpers for ISO date / time / time-of-day strings.
 */

const pad = (n: number, width: number): string => String(n).padStart(width, "0");

export function formatDate(d: Date | number, pattern: string): string {
  const date = typeof d === "number" ? new Date(d) : d;
  const Y = date.getUTCFullYear();
  const M = date.getUTCMonth() + 1;
  const D = date.getUTCDate();
  const H = date.getUTCHours();
  const m = date.getUTCMinutes();
  const s = date.getUTCSeconds();
  const ms = date.getUTCMilliseconds();
  return pattern
    .replace(/YYYY/g, pad(Y, 4))
    .replace(/MM/g, pad(M, 2))
    .replace(/DD/g, pad(D, 2))
    .replace(/HH/g, pad(H, 2))
    .replace(/mm/g, pad(m, 2))
    .replace(/SSS/g, pad(ms, 3))
    .replace(/ss/g, pad(s, 2));
}

export function isoDate(d: Date | number): string {
  return formatDate(d, "YYYY-MM-DD");
}

export function isoTime(d: Date | number): string {
  return formatDate(d, "HH:mm:ss");
}

export function isoDateTime(d: Date | number): string {
  return formatDate(d, "YYYY-MM-DDTHH:mm:ssZ").replace("Z", "Z");
}
