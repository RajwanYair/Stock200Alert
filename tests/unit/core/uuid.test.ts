import { describe, it, expect } from "vitest";
import { uuidV4, isUuidV4, nanoId } from "../../../src/core/uuid";

describe("uuidV4", () => {
  it("produces a valid v4 UUID", () => {
    const id = uuidV4();
    expect(isUuidV4(id)).toBe(true);
  });
  it("produces unique ids", () => {
    const set = new Set(Array.from({ length: 200 }, () => uuidV4()));
    expect(set.size).toBe(200);
  });
});

describe("isUuidV4", () => {
  it("rejects non-UUID strings", () => {
    expect(isUuidV4("not-a-uuid")).toBe(false);
    expect(isUuidV4("00000000-0000-1000-8000-000000000000")).toBe(false); // version 1
  });
  it("accepts canonical v4", () => {
    expect(isUuidV4("550e8400-e29b-41d4-a716-446655440000")).toBe(true);
  });
});

describe("nanoId", () => {
  it("default length is 21", () => {
    expect(nanoId().length).toBe(21);
  });
  it("respects custom size", () => {
    expect(nanoId(10).length).toBe(10);
  });
  it("uses URL-safe characters only", () => {
    const id = nanoId(64);
    expect(/^[A-Za-z0-9_-]+$/.test(id)).toBe(true);
  });
  it("produces unique ids", () => {
    const set = new Set(Array.from({ length: 200 }, () => nanoId()));
    expect(set.size).toBe(200);
  });
});
