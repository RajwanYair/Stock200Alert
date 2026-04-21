import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { createShortcutManager } from "../../../src/core/keyboard";

describe("createShortcutManager", () => {
  let mgr: ReturnType<typeof createShortcutManager>;

  beforeEach(() => {
    mgr = createShortcutManager();
  });

  afterEach(() => {
    mgr.destroy();
  });

  it("calls handler on matching key", () => {
    const handler = vi.fn();
    mgr.register({ key: "r", description: "Refresh", handler });
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "r" }));
    expect(handler).toHaveBeenCalledOnce();
  });

  it("does not call handler for non-matching key", () => {
    const handler = vi.fn();
    mgr.register({ key: "r", description: "Refresh", handler });
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "x" }));
    expect(handler).not.toHaveBeenCalled();
  });

  it("respects Ctrl modifier", () => {
    const handler = vi.fn();
    mgr.register({ key: "r", ctrl: true, description: "Hard refresh", handler });
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "r" }));
    expect(handler).not.toHaveBeenCalled();
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "r", ctrlKey: true }));
    expect(handler).toHaveBeenCalledOnce();
  });

  it("unregister removes shortcut", () => {
    const handler = vi.fn();
    const unreg = mgr.register({ key: "r", description: "Refresh", handler });
    unreg();
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "r" }));
    expect(handler).not.toHaveBeenCalled();
  });

  it("list returns registered shortcuts", () => {
    mgr.register({ key: "r", description: "Refresh", handler: vi.fn() });
    mgr.register({ key: "/", description: "Search", handler: vi.fn() });
    const list = mgr.list();
    expect(list.length).toBe(2);
    expect(list.map((s) => s.description)).toContain("Refresh");
    expect(list.map((s) => s.description)).toContain("Search");
  });

  it("ignores keys when input is focused", () => {
    const handler = vi.fn();
    mgr.register({ key: "r", description: "Refresh", handler });
    const input = document.createElement("input");
    document.body.appendChild(input);
    input.focus();
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "r" }));
    expect(handler).not.toHaveBeenCalled();
    document.body.removeChild(input);
  });

  it("destroy removes global listener", () => {
    const handler = vi.fn();
    mgr.register({ key: "r", description: "Refresh", handler });
    mgr.destroy();
    document.dispatchEvent(new KeyboardEvent("keydown", { key: "r" }));
    expect(handler).not.toHaveBeenCalled();
  });
});
