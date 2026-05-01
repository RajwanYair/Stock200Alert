/**
 * Subresource Integrity (SRI) helper. Computes integrity attribute values
 * for static assets, generates HTML attribute strings, and validates the
 * format of existing SRI tokens.
 */

export type SriAlgorithm = "sha256" | "sha384" | "sha512";

const ALGO_TO_NAME: Record<SriAlgorithm, string> = {
  sha256: "SHA-256",
  sha384: "SHA-384",
  sha512: "SHA-512",
};

function bytesToBase64(bytes: Uint8Array): string {
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin);
}

/**
 * Hash content and return an SRI integrity value.
 * Defaults to sha384 (a sensible balance for HTML SRI).
 */
export async function computeIntegrity(
  content: ArrayBuffer | Uint8Array | string,
  algorithm: SriAlgorithm = "sha384",
): Promise<string> {
  const data: Uint8Array<ArrayBuffer> =
    typeof content === "string"
      ? new TextEncoder().encode(content)
      : content instanceof Uint8Array
        ? new Uint8Array(content)
        : new Uint8Array(content);
  const hash = await crypto.subtle.digest(ALGO_TO_NAME[algorithm], data);
  return `${algorithm}-${bytesToBase64(new Uint8Array(hash))}`;
}

/** Format an integrity attribute for a `<script>` or `<link>` tag. */
export function integrityAttr(value: string): string {
  return `integrity="${value}" crossorigin="anonymous"`;
}

/** Validate the textual shape of an SRI value. */
export function isValidSriValue(value: string): boolean {
  return /^(sha256|sha384|sha512)-[A-Za-z0-9+/]+=*$/.test(value);
}

/**
 * Compute integrity values for a manifest of files (filename → bytes).
 * Useful in build steps.
 */
export async function buildSriManifest(
  files: ReadonlyMap<string, ArrayBuffer | Uint8Array | string>,
  algorithm: SriAlgorithm = "sha384",
): Promise<Map<string, string>> {
  const out = new Map<string, string>();
  for (const [name, content] of files) {
    out.set(name, await computeIntegrity(content, algorithm));
  }
  return out;
}
