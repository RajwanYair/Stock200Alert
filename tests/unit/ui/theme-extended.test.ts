/**
 * Extended theme tests — detection, application.
 */
import { describe, it, expect, afterEach } from "vitest";
import { applyTheme, initTheme } from "../../../src/ui/theme";

describe("theme extended", () => {
  afterEach(() => {
    delete document.documentElement.dataset["theme"];
  });

  it("applyTheme sets data-theme attribute on documentElement", () => {
    applyTheme("dark");
    expect(document.documentElement.dataset["theme"]).toBe("dark");
  });

  it("applyTheme switches between themes", () => {
    applyTheme("dark");
    expect(document.documentElement.dataset["theme"]).toBe("dark");
    applyTheme("light");
    expect(document.documentElement.dataset["theme"]).toBe("light");
    applyTheme("high-contrast");
    expect(document.documentElement.dataset["theme"]).toBe("high-contrast");
  });

  it("initTheme returns the resolved theme", () => {
    const result = initTheme("light");
    expect(result).toBe("light");
    expect(document.documentElement.dataset["theme"]).toBe("light");
  });

  it("initTheme applies provided theme", () => {
    initTheme("dark");
    expect(document.documentElement.dataset["theme"]).toBe("dark");
  });
});
