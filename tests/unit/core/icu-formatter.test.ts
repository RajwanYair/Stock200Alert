import { describe, it, expect } from "vitest";
import {
  format,
  formatMessage,
  defineMessages,
  getPluralCategory,
} from "../../../src/core/icu-formatter";

// ──────────────────────────────────────────────────────────────
// format — simple substitution
// ──────────────────────────────────────────────────────────────

describe("format — simple substitution", () => {
  it("replaces a single variable", () => {
    expect(format("Hello, {name}!", { name: "World" })).toBe("Hello, World!");
  });

  it("replaces multiple variables", () => {
    expect(format("{a} + {b} = {c}", { a: 1, b: 2, c: 3 })).toBe("1 + 2 = 3");
  });

  it("uses key as fallback when variable is missing", () => {
    expect(format("Hello, {name}!", {})).toBe("Hello, name!");
  });

  it("returns the template unchanged when there are no placeholders", () => {
    expect(format("No placeholders here")).toBe("No placeholders here");
  });

  it("handles empty template", () => {
    expect(format("", {})).toBe("");
  });
});

// ──────────────────────────────────────────────────────────────
// format — plural selection
// ──────────────────────────────────────────────────────────────

describe("format — plural selection", () => {
  const tpl = "{count, plural, =0{No items} =1{One item} other{# items}}";

  it("selects =0 case", () => {
    expect(format(tpl, { count: 0 })).toBe("No items");
  });

  it("selects =1 case", () => {
    expect(format(tpl, { count: 1 })).toBe("One item");
  });

  it("selects other case and replaces #", () => {
    expect(format(tpl, { count: 5 })).toBe("5 items");
  });

  it("selects 'one' CLDR category for value 1", () => {
    const t = "{n, plural, one{singular} other{plural}}";
    expect(format(t, { n: 1 })).toBe("singular");
  });

  it("selects 'other' CLDR category for value 0", () => {
    const t = "{n, plural, one{singular} other{plural}}";
    expect(format(t, { n: 0 })).toBe("plural");
  });

  it("replaces # in nested text", () => {
    const t = "{n, plural, one{# alert} other{# alerts}}";
    expect(format(t, { n: 3 })).toBe("3 alerts");
  });

  it("handles nested interpolation inside plural case", () => {
    const t = "{n, plural, one{{label} alert} other{{label} alerts}}";
    expect(format(t, { n: 2, label: "Critical" })).toBe("Critical alerts");
  });
});

// ──────────────────────────────────────────────────────────────
// format — select (value) selection
// ──────────────────────────────────────────────────────────────

describe("format — select", () => {
  const tpl = "{gender, select, male{He likes} female{She likes} other{They like}} TypeScript.";

  it("selects male case", () => {
    expect(format(tpl, { gender: "male" })).toBe("He likes TypeScript.");
  });

  it("selects female case", () => {
    expect(format(tpl, { gender: "female" })).toBe("She likes TypeScript.");
  });

  it("falls back to other case for unknown value", () => {
    expect(format(tpl, { gender: "nonbinary" })).toBe("They like TypeScript.");
  });

  it("falls back to other when variable is missing", () => {
    expect(format(tpl, {})).toBe("They like TypeScript.");
  });
});

// ──────────────────────────────────────────────────────────────
// getPluralCategory
// ──────────────────────────────────────────────────────────────

describe("getPluralCategory", () => {
  it("returns 'one' for 1 in English", () => {
    expect(getPluralCategory(1, "en")).toBe("one");
  });

  it("returns 'other' for 0 in English", () => {
    expect(getPluralCategory(0, "en")).toBe("other");
  });

  it("returns 'other' for 2+ in English", () => {
    expect(getPluralCategory(42, "en")).toBe("other");
  });
});

// ──────────────────────────────────────────────────────────────
// defineMessages + formatMessage
// ──────────────────────────────────────────────────────────────

describe("defineMessages + formatMessage", () => {
  const messages = defineMessages({
    greeting: "Hello, {name}!",
    items: "{count, plural, =0{No items} =1{One item} other{# items}}",
    roleLabel: "{role, select, admin{Administrator} user{User} other{Guest}}",
  });

  it("defineMessages preserves the dictionary intact", () => {
    expect(messages.greeting).toBe("Hello, {name}!");
    expect(messages.items).toBeTruthy();
  });

  it("formatMessage resolves a simple message", () => {
    expect(formatMessage(messages, "greeting", { name: "Alice" })).toBe("Hello, Alice!");
  });

  it("formatMessage resolves a plural message", () => {
    expect(formatMessage(messages, "items", { count: 3 })).toBe("3 items");
  });

  it("formatMessage resolves a select message", () => {
    expect(formatMessage(messages, "roleLabel", { role: "admin" })).toBe("Administrator");
  });

  it("formatMessage returns the key for an unknown key", () => {
    // @ts-expect-error — intentionally testing unknown key runtime behaviour
    expect(formatMessage(messages, "unknownKey")).toBe("unknownKey");
  });
});
