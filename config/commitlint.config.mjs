/** @type {import('@commitlint/types').UserConfig} */
export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Enforce types used in this project
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "perf",
        "test",
        "build",
        "ci",
        "chore",
        "revert",
      ],
    ],
    // Subject may start with capital (our sprint commit style)
    "subject-case": [0],
    // Allow long subject lines for sprint commits
    "header-max-length": [1, "always", 120],
  },
};
