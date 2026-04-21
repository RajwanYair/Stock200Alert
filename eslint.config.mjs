import { createWebTsAppEslintConfig } from "../tooling/eslint/web-ts-app.mjs";

export default createWebTsAppEslintConfig({
  ignores: ["node_modules/**", "dist/**", "coverage/**", "scripts/**"],
  sourceFiles: ["src/**/*.ts"],
  sourceProject: "./tsconfig.json",
  tsconfigRootDir: import.meta.dirname,
  testFiles: ["tests/**/*.ts"],
  swFiles: [],
  sourceRules: {
    "@typescript-eslint/explicit-function-return-type": "error",
    "no-console": ["error", { allow: ["warn", "error"] }],
  },
});
