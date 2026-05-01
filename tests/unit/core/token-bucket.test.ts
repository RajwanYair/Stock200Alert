import { describe, it, expect } from "vitest";
import { createTokenBucket } from "../../../src/core/token-bucket";

describe("token-bucket", () => {
  it("starts at capacity", () => {
    const b = createTokenBucket({ capacity: 5, ratePerSec: 1 });
    expect(b.tokens(0)).toBe(5);
  });

  it("consumes tokens", () => {
    const b = createTokenBucket({ capacity: 3, ratePerSec: 1 });
    expect(b.tryConsume(1, 0)).toBe(true);
    expect(b.tryConsume(1, 0)).toBe(true);
    expect(b.tryConsume(1, 0)).toBe(true);
    expect(b.tryConsume(1, 0)).toBe(false);
  });

  it("refills over time", () => {
    const b = createTokenBucket({ capacity: 10, ratePerSec: 5, initialTokens: 0 });
    expect(b.tryConsume(1, 0)).toBe(false);
    expect(b.tokens(1000)).toBe(5);
    expect(b.tryConsume(5, 1000)).toBe(true);
  });

  it("caps at capacity", () => {
    const b = createTokenBucket({ capacity: 3, ratePerSec: 100 });
    expect(b.tokens(10_000)).toBe(3);
  });

  it("waitMs returns 0 when available", () => {
    const b = createTokenBucket({ capacity: 5, ratePerSec: 1 });
    expect(b.waitMs(1, 0)).toBe(0);
  });

  it("waitMs estimates time until refill", () => {
    const b = createTokenBucket({ capacity: 5, ratePerSec: 2, initialTokens: 0 });
    // need 1 token at rate 2/sec -> 500ms
    expect(b.waitMs(1, 0)).toBe(500);
  });

  it("rejects invalid config", () => {
    expect(() => createTokenBucket({ capacity: 0, ratePerSec: 1 })).toThrow();
    expect(() => createTokenBucket({ capacity: 1, ratePerSec: 0 })).toThrow();
  });

  it("supports custom cost", () => {
    const b = createTokenBucket({ capacity: 10, ratePerSec: 1 });
    expect(b.tryConsume(3, 0)).toBe(true);
    expect(b.tokens(0)).toBe(7);
  });
});
