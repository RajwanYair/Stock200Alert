import { defineConfig } from "vite";
import { readFileSync } from "node:fs";
import { baseConfig } from "../tooling/vite.base.ts";

const pkg = JSON.parse(readFileSync("package.json", "utf-8")) as {
  version: string;
};

export default defineConfig({
  ...baseConfig,
  base: "./",
  define: {
    __APP_VERSION__: JSON.stringify(pkg.version),
  },
  build: {
    ...baseConfig.build,
    outDir: "dist",
  },
  server: {
    ...baseConfig.server,
    open: true,
  },
});
