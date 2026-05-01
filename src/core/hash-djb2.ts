/**
 * Tiny non-cryptographic string hash utilities. Stable across runs, fast,
 * and safe for cache keys / colour seeding.
 *  - djb2: classic Bernstein hash, 32-bit unsigned int.
 *  - djb2Hex: same value as 8-char zero-padded hex.
 *  - fnv1a32: 32-bit FNV-1a hash, distinct distribution.
 * Not suitable for security or password storage.
 */

export function djb2(input: string): number {
  let hash = 5381;
  for (let i = 0; i < input.length; i++) {
    hash = (hash * 33) ^ input.charCodeAt(i);
  }
  return hash >>> 0;
}

export function djb2Hex(input: string): string {
  return djb2(input).toString(16).padStart(8, "0");
}

export function fnv1a32(input: string): number {
  let hash = 0x811c9dc5;
  for (let i = 0; i < input.length; i++) {
    hash ^= input.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}
