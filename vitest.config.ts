import { defineConfig } from "vitest/config";
import { happyDomVitestConfig } from "../tooling/vitest/happy-dom.mjs";

export default defineConfig({
  test: {
    ...happyDomVitestConfig,
    include: ["tests/**/*.test.ts"],
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      exclude: ["src/main.ts", "src/**/*.d.ts", "src/**/index.ts", "src/types/**"],
      thresholds: {
        statements: 90,
        branches: 80,
        functions: 90,
        lines: 90,
      },
      reporter: ["text", "lcov", "json-summary"],
      reportsDirectory: "coverage",
    },
  },
});
