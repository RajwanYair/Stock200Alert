/**
 * Compression Streams helpers (G11).
 *
 * Uses the browser-native `CompressionStream` API (Baseline 2023, all major
 * browsers) to gzip arbitrary string data before download.  Falls back to a
 * plain `Blob` when `CompressionStream` is unavailable so the code is safe
 * in all environments.
 *
 * Typical use:
 *   const blob = await compressStringToGzip(jsonText);
 *   triggerDownload(blob, "export.json.gz");
 *
 * Bundle cost: zero bytes — this is a thin wrapper around a built-in API.
 */

/** Returns `true` when the runtime supports `CompressionStream`. */
export function compressionStreamSupported(): boolean {
  return typeof CompressionStream !== "undefined";
}

/**
 * Compress a UTF-8 string using gzip via the Compression Streams API.
 *
 * Returns a `Blob` of type `application/gzip` when compression is
 * supported, or a plain-text `Blob` as a fallback.
 */
export async function compressStringToGzip(text: string): Promise<Blob> {
  if (!compressionStreamSupported()) {
    // Fallback: return uncompressed blob (no import needed — plain Blob)
    return new Blob([text], { type: "text/plain" });
  }

  const encoder = new TextEncoder();
  const bytes = encoder.encode(text);
  const readableStream = new ReadableStream<Uint8Array>({
    start(controller): void {
      controller.enqueue(bytes);
      controller.close();
    },
  });

  const compressionStream = new CompressionStream("gzip");
  const compressedStream = readableStream.pipeThrough(
    compressionStream as unknown as ReadableWritablePair<
      Uint8Array<ArrayBuffer>,
      Uint8Array<ArrayBuffer>
    >,
  );
  const chunks: Uint8Array<ArrayBuffer>[] = [];

  const reader = compressedStream.getReader();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
  }

  return new Blob(chunks, { type: "application/gzip" });
}

/**
 * Estimate the compression ratio.  Reads back the Blob bytes and compares.
 *
 * Useful in tests / diagnostics; not for production hot paths.
 */
export async function estimateGzipRatio(text: string): Promise<number> {
  if (!compressionStreamSupported()) return 1;
  const compressed = await compressStringToGzip(text);
  const uncompressedSize = new TextEncoder().encode(text).byteLength;
  if (uncompressedSize === 0) return 1;
  return compressed.size / uncompressedSize;
}

/**
 * Produce a suggested filename for a gzip-compressed export.
 *
 * @param base - Base filename without extension (e.g. "crosstide-export")
 * @param originalExt - Original file extension (e.g. ".json" or ".csv")
 */
export function gzipFilename(base: string, originalExt: string): string {
  const clean = originalExt.startsWith(".") ? originalExt : `.${originalExt}`;
  return `${base}${clean}.gz`;
}
