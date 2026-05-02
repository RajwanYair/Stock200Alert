/**
 * Font loading helpers (G16).
 *
 * Provides lightweight wrappers over the `document.fonts` (FontFaceSet) API
 * for Inter Variable and JetBrains Mono.
 *
 * ## Exported API
 * - `fontLoadingSupported()` — feature-detect `document.fonts` + `FontFace`.
 * - `isFontLoaded(family)` — check if a font family is already loaded.
 * - `waitForFont(family, timeout?)` — resolve when the font is loaded or
 *   the timeout expires, whichever comes first.
 * - `preloadFont(url, family, weight?, style?)` — imperatively load a font
 *   without relying on CSS `@font-face`.
 * - `observeFontLoad(family, callback)` — subscribe to the next load event
 *   for the given family and call `callback(loaded)`.
 *
 * All functions degrade gracefully when `document.fonts` is unavailable
 * (e.g. in non-browser environments or older engines).
 *
 * @see https://developer.mozilla.org/en-US/docs/Web/API/FontFaceSet
 */

// ─── feature detection ────────────────────────────────────────────────────────

/**
 * Returns `true` when the FontFaceSet (`document.fonts`) API is available.
 */
export function fontLoadingSupported(): boolean {
  return (
    typeof document !== "undefined" &&
    typeof document.fonts !== "undefined" &&
    typeof document.fonts.load === "function"
  );
}

// ─── status checks ────────────────────────────────────────────────────────────

/**
 * Returns `true` when at least one face from `family` is loaded and ready.
 *
 * Relies on `document.fonts.check()` which returns `true` when the font
 * can be used for rendering.  Falls back to `false` when unsupported.
 *
 * @param family  CSS font-family name, e.g. `"Inter Variable"`.
 * @param size    Optional test font size (default `"1em"`).
 */
export function isFontLoaded(family: string, size = "1em"): boolean {
  if (!fontLoadingSupported()) return false;
  try {
    return document.fonts.check(`${size} "${family}"`);
  } catch {
    return false;
  }
}

/**
 * Returns a `Promise<boolean>` that resolves when the font is loaded (`true`)
 * or the timeout expires (`false`).
 *
 * @param family   CSS font-family name.
 * @param timeout  Max wait time in milliseconds (default 3000 ms).
 */
export function waitForFont(family: string, timeout = 3000): Promise<boolean> {
  if (!fontLoadingSupported()) return Promise.resolve(false);

  const loadPromise = document.fonts.load(`1em "${family}"`).then(() => true);
  const timeoutPromise = new Promise<boolean>((resolve) =>
    setTimeout(() => resolve(false), timeout),
  );
  return Promise.race([loadPromise, timeoutPromise]);
}

// ─── imperative font loading ──────────────────────────────────────────────────

/**
 * Imperatively load a font from `url` and add it to `document.fonts`.
 *
 * This bypasses CSS `@font-face` and is useful for on-demand loading of
 * variable font subsets after user interaction.
 *
 * @param url     URL to the `.woff2` / `.ttf` font file.
 * @param family  Font family name to register, e.g. `"Inter Variable"`.
 * @param weight  CSS font-weight descriptor (default `"100 900"`).
 * @param style   CSS font-style descriptor (default `"normal"`).
 * @returns The loaded `FontFace` instance, or `null` when unsupported.
 */
export async function preloadFont(
  url: string,
  family: string,
  weight = "100 900",
  style = "normal",
): Promise<FontFace | null> {
  if (!fontLoadingSupported() || typeof FontFace === "undefined") return null;
  const face = new FontFace(family, `url(${url})`, { weight, style });
  const loaded = await face.load();
  document.fonts.add(loaded);
  return loaded;
}

// ─── event subscription ───────────────────────────────────────────────────────

/**
 * Subscribe to the next `loadingdone` event on `document.fonts` and call
 * `callback(true)` when all pending fonts have loaded.
 * Calls `callback(false)` immediately when unsupported.
 *
 * @returns Cleanup function that removes the listener.
 */
export function observeFontLoad(callback: (loaded: boolean) => void): () => void {
  if (!fontLoadingSupported()) {
    callback(false);
    return (): void => {
      /* no-op */
    };
  }

  const handler = (): void => callback(true);
  document.fonts.addEventListener("loadingdone", handler);
  return (): void => document.fonts.removeEventListener("loadingdone", handler);
}
