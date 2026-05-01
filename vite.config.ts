import { defineConfig } from "vite";
import { readFileSync } from "node:fs";

const pkg = JSON.parse(readFileSync("package.json", "utf-8")) as {
  version: string;
};

export default defineConfig({
  base: "./",
  define: {
    __APP_VERSION__: JSON.stringify(pkg.version),
  },
  build: {
    target: "es2022",
    sourcemap: true,
    minify: "oxc",
    outDir: "dist",
    rollupOptions: {
      output: {
        manualChunks: undefined,
      },
    },
  },
  server: {
    port: 5173,
    strictPort: false,
    open: true,
  },
  preview: {
    port: 4173,
    strictPort: false,
  },
});
