/**
 * Post-build script: injects the Workbox precache manifest into dist/sw.js.
 *
 * Replaces the `self.__WB_MANIFEST` placeholder in the compiled SW bundle
 * with an array of { url, revision } objects for all versioned build assets.
 *
 * Run automatically after `vite build` via the `build` npm script.
 */
import { injectManifest } from "workbox-build";
import { existsSync } from "node:fs";

const SW_DIST = "dist/sw.js";

if (!existsSync(SW_DIST)) {
  console.error("workbox-inject: dist/sw.js not found — run `vite build` first.");
  process.exit(1);
}

try {
  const result = await injectManifest({
    swSrc: SW_DIST,
    swDest: SW_DIST,
    globDirectory: "dist",
    globPatterns: ["**/*.{js,css,html,ico,png,svg,woff2,webp}"],
    globIgnores: ["sw.js"],
    injectionPoint: "self.__WB_MANIFEST",
  });

  const kb = (result.size / 1024).toFixed(1);
  console.log(`✓ Precache manifest: ${result.count} entries, ${kb} KB`);
} catch (err) {
  if (err instanceof Error && err.message.includes("injectionPoint")) {
    // Injection point not present (e.g. minifier renamed it) — non-fatal warning.
    console.warn("workbox-inject: injection point not found in dist/sw.js — skipping.");
  } else {
    console.error("workbox-inject failed:", err);
    process.exit(1);
  }
}
