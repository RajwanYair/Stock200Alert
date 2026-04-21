/**
 * Extended cache tests — TTL expiry, overwrite, size tracking.
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import { Cache } from "../../../src/core/cache";

describe("Cache extended", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("overwrites existing key", () => {
    const cache = new Cache();
    cache.set("a", 1, 60_000);
    cache.set("a", 2, 60_000);
    expect(cache.get<number>("a")).toBe(2);
    expect(cache.size).toBe(1);
  });

  it("returns null after TTL expires", () => {
    const cache = new Cache();
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);

    cache.set("x", "val", 100);

    vi.spyOn(Date, "now").mockReturnValue(now + 101);
    expect(cache.get("x")).toBeNull();
  });

  it("returns value before TTL expires", () => {
    const cache = new Cache();
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);

    cache.set("x", "val", 100);

    vi.spyOn(Date, "now").mockReturnValue(now + 50);
    expect(cache.get("x")).toBe("val");
  });

  it("delete removes entry and decrements size", () => {
    const cache = new Cache();
    cache.set("a", 1, 60_000);
    cache.set("b", 2, 60_000);
    expect(cache.size).toBe(2);
    cache.delete("a");
    expect(cache.size).toBe(1);
    expect(cache.get("a")).toBeNull();
  });

  it("clear removes all entries", () => {
    const cache = new Cache();
    cache.set("a", 1, 60_000);
    cache.set("b", 2, 60_000);
    cache.clear();
    expect(cache.size).toBe(0);
  });

  it("stores various types", () => {
    const cache = new Cache();
    cache.set("str", "hello", 60_000);
    cache.set("num", 42, 60_000);
    cache.set("arr", [1, 2, 3], 60_000);
    cache.set("obj", { key: "val" }, 60_000);
    expect(cache.get<string>("str")).toBe("hello");
    expect(cache.get<number>("num")).toBe(42);
    expect(cache.get<number[]>("arr")).toEqual([1, 2, 3]);
    expect(cache.get<{ key: string }>("obj")).toEqual({ key: "val" });
  });

  it("expired entry is evicted on get", () => {
    const cache = new Cache();
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);
    cache.set("x", 1, 50);
    expect(cache.size).toBe(1);

    vi.spyOn(Date, "now").mockReturnValue(now + 51);
    cache.get("x"); // triggers eviction
    expect(cache.size).toBe(0);
  });
});
