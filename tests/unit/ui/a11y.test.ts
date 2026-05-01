import { describe, it, expect, beforeEach, vi, afterEach } from "vitest";
import { announce, trapFocus, prefersReducedMotion } from "../../../src/ui/a11y";

describe("announce", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  it("creates a live region", () => {
    announce("hello");
    const el = document.getElementById("ct-aria-live-region");
    expect(el).not.toBeNull();
    expect(el!.getAttribute("aria-live")).toBe("polite");
    expect(el!.textContent).toBe("hello");
  });

  it("supports assertive priority", () => {
    announce("urgent", "assertive");
    const el = document.getElementById("ct-aria-live-assertive");
    expect(el!.getAttribute("aria-live")).toBe("assertive");
  });

  it("reuses existing live region", () => {
    announce("first");
    announce("second");
    const els = document.querySelectorAll("#ct-aria-live-region");
    expect(els).toHaveLength(1);
    expect(els[0]!.textContent).toBe("second");
  });
});

describe("trapFocus", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  it("returns a cleanup function", () => {
    const container = document.createElement("div");
    container.innerHTML = "<button>A</button><button>B</button>";
    document.body.appendChild(container);
    const cleanup = trapFocus(container);
    expect(typeof cleanup).toBe("function");
    cleanup();
  });

  it("focuses the first focusable element", () => {
    const container = document.createElement("div");
    const btn = document.createElement("button");
    btn.textContent = "First";
    container.appendChild(btn);
    document.body.appendChild(container);

    trapFocus(container);
    expect(document.activeElement).toBe(btn);
  });

  it("Tab on last element wraps focus to first", () => {
    const container = document.createElement("div");
    container.innerHTML = "<button id='b1'>A</button><button id='b2'>B</button>";
    document.body.appendChild(container);

    trapFocus(container);

    const last = container.querySelector<HTMLElement>("#b2")!;
    last.focus();
    expect(document.activeElement).toBe(last);

    const tabEvent = new KeyboardEvent("keydown", { key: "Tab", bubbles: true, cancelable: true });
    container.dispatchEvent(tabEvent);

    // defaultPrevented means the handler wrapped focus
    expect(tabEvent.defaultPrevented).toBe(true);
  });

  it("Shift+Tab on first element wraps focus to last", () => {
    const container = document.createElement("div");
    container.innerHTML = "<button id='b1'>A</button><button id='b2'>B</button>";
    document.body.appendChild(container);

    trapFocus(container);

    const first = container.querySelector<HTMLElement>("#b1")!;
    first.focus();

    const shiftTab = new KeyboardEvent("keydown", {
      key: "Tab",
      shiftKey: true,
      bubbles: true,
      cancelable: true,
    });
    container.dispatchEvent(shiftTab);

    expect(shiftTab.defaultPrevented).toBe(true);
  });

  it("Tab on non-last/non-first element does not prevent default", () => {
    const container = document.createElement("div");
    container.innerHTML =
      "<button id='b1'>A</button><button id='b2'>B</button><button id='b3'>C</button>";
    document.body.appendChild(container);

    trapFocus(container);

    const middle = container.querySelector<HTMLElement>("#b2")!;
    middle.focus();

    const tabEvent = new KeyboardEvent("keydown", { key: "Tab", bubbles: true, cancelable: true });
    container.dispatchEvent(tabEvent);

    expect(tabEvent.defaultPrevented).toBe(false);
  });

  it("empty container: Tab is prevented and no crash", () => {
    const container = document.createElement("div"); // no focusable children
    document.body.appendChild(container);

    trapFocus(container);

    const tabEvent = new KeyboardEvent("keydown", { key: "Tab", bubbles: true, cancelable: true });
    container.dispatchEvent(tabEvent);

    expect(tabEvent.defaultPrevented).toBe(true);
  });

  it("non-Tab key events are ignored", () => {
    const container = document.createElement("div");
    container.innerHTML = "<button>A</button>";
    document.body.appendChild(container);

    trapFocus(container);

    const enterEvent = new KeyboardEvent("keydown", {
      key: "Enter",
      bubbles: true,
      cancelable: true,
    });
    container.dispatchEvent(enterEvent);

    expect(enterEvent.defaultPrevented).toBe(false);
  });

  it("cleanup removes the keydown listener", () => {
    const container = document.createElement("div");
    container.innerHTML = "<button id='b1'>A</button><button id='b2'>B</button>";
    document.body.appendChild(container);

    const cleanup = trapFocus(container);
    cleanup();

    const last = container.querySelector<HTMLElement>("#b2")!;
    last.focus();

    const tabEvent = new KeyboardEvent("keydown", { key: "Tab", bubbles: true, cancelable: true });
    container.dispatchEvent(tabEvent);

    // After cleanup, Tab should NOT be prevented
    expect(tabEvent.defaultPrevented).toBe(false);
  });
});

describe("prefersReducedMotion", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("returns a boolean", () => {
    expect(typeof prefersReducedMotion()).toBe("boolean");
  });

  it("returns true when media query matches", () => {
    vi.spyOn(window, "matchMedia").mockReturnValue({
      matches: true,
    } as MediaQueryList);
    expect(prefersReducedMotion()).toBe(true);
  });

  it("returns false when media query does not match", () => {
    vi.spyOn(window, "matchMedia").mockReturnValue({
      matches: false,
    } as MediaQueryList);
    expect(prefersReducedMotion()).toBe(false);
  });
});
