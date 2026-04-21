/**
 * Extended state store tests — pub/sub, snapshot immutability.
 */
import { describe, it, expect, vi } from "vitest";
import { createStore } from "../../../src/core/state";

describe("Store extended", () => {
  it("snapshot returns a copy of current state", () => {
    const store = createStore({ count: 0, name: "test" });
    const snap = store.snapshot();
    expect(snap).toEqual({ count: 0, name: "test" });
  });

  it("snapshot is not mutated by subsequent sets", () => {
    const store = createStore({ count: 0 });
    const snap1 = store.snapshot();
    store.set("count", 5);
    expect(snap1.count).toBe(0);
    expect(store.get("count")).toBe(5);
  });

  it("listener is called on set", () => {
    const store = createStore({ val: "a" });
    const spy = vi.fn();
    store.on("val", spy);
    store.set("val", "b");
    expect(spy).toHaveBeenCalledWith("b");
  });

  it("unsubscribe stops future notifications", () => {
    const store = createStore({ val: 0 });
    const spy = vi.fn();
    const unsub = store.on("val", spy);
    store.set("val", 1);
    expect(spy).toHaveBeenCalledTimes(1);

    unsub();
    store.set("val", 2);
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it("multiple listeners on same key all fire", () => {
    const store = createStore({ x: 0 });
    const spy1 = vi.fn();
    const spy2 = vi.fn();
    store.on("x", spy1);
    store.on("x", spy2);
    store.set("x", 10);
    expect(spy1).toHaveBeenCalledWith(10);
    expect(spy2).toHaveBeenCalledWith(10);
  });

  it("listener on key A not called when key B changes", () => {
    const store = createStore({ a: 1, b: 2 });
    const spy = vi.fn();
    store.on("a", spy);
    store.set("b", 99);
    expect(spy).not.toHaveBeenCalled();
  });

  it("set with same value still notifies listeners", () => {
    const store = createStore({ val: 42 });
    const spy = vi.fn();
    store.on("val", spy);
    store.set("val", 42);
    expect(spy).toHaveBeenCalledWith(42);
  });
});
