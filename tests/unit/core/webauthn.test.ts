/**
 * WebAuthn foundation tests — covers pure utility functions.
 * Browser credential API calls are mocked since happy-dom doesn't support them.
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import {
  bufferToBase64url,
  base64urlToBuffer,
  generateChallenge,
  checkWebAuthnSupport,
  registerCredential,
  authenticateCredential,
} from "../../../src/core/webauthn";

describe("bufferToBase64url", () => {
  it("encodes an ArrayBuffer to base64url without padding", () => {
    const bytes = new Uint8Array([72, 101, 108, 108, 111]); // "Hello"
    const result = bufferToBase64url(bytes.buffer);
    expect(result).toBe("SGVsbG8"); // base64url of "Hello"
    expect(result).not.toContain("+");
    expect(result).not.toContain("/");
    expect(result).not.toContain("=");
  });

  it("handles empty buffer", () => {
    expect(bufferToBase64url(new ArrayBuffer(0))).toBe("");
  });
});

describe("base64urlToBuffer", () => {
  it("decodes base64url back to ArrayBuffer", () => {
    const original = new Uint8Array([72, 101, 108, 108, 111]);
    const encoded = bufferToBase64url(original.buffer);
    const decoded = new Uint8Array(base64urlToBuffer(encoded));
    expect(decoded).toEqual(original);
  });

  it("handles URL-unsafe characters correctly", () => {
    // A buffer that would produce + and / in standard base64
    const bytes = new Uint8Array([251, 255, 254]);
    const encoded = bufferToBase64url(bytes.buffer);
    expect(encoded).not.toContain("+");
    expect(encoded).not.toContain("/");
    const decoded = new Uint8Array(base64urlToBuffer(encoded));
    expect(decoded).toEqual(bytes);
  });

  it("round-trips arbitrary data", () => {
    const original = new Uint8Array(32);
    for (let i = 0; i < 32; i++) original[i] = i * 8;
    const encoded = bufferToBase64url(original.buffer);
    const decoded = new Uint8Array(base64urlToBuffer(encoded));
    expect(decoded).toEqual(original);
  });
});

describe("generateChallenge", () => {
  it("returns a Uint8Array of 32 bytes", () => {
    const challenge = generateChallenge();
    expect(challenge).toBeInstanceOf(Uint8Array);
    expect(challenge.length).toBe(32);
  });

  it("returns different values on each call", () => {
    const c1 = generateChallenge();
    const c2 = generateChallenge();
    // Extremely unlikely to be equal
    expect(bufferToBase64url(c1.buffer)).not.toBe(bufferToBase64url(c2.buffer));
  });
});

describe("checkWebAuthnSupport", () => {
  it("detects when WebAuthn is not available", async () => {
    // happy-dom doesn't have PublicKeyCredential
    const support = await checkWebAuthnSupport();
    // In test env it may or may not be available depending on polyfills
    expect(support).toHaveProperty("available");
    expect(support).toHaveProperty("platformAuthenticator");
    expect(support).toHaveProperty("conditionalMediation");
  });

  it("returns available=true when PublicKeyCredential is present", async () => {
    Object.defineProperty(globalThis, "PublicKeyCredential", {
      value: class {
        static isUserVerifyingPlatformAuthenticatorAvailable = vi.fn().mockResolvedValue(true);
        static isConditionalMediationAvailable = vi.fn().mockResolvedValue(false);
      },
      writable: true,
      configurable: true,
    });
    Object.defineProperty(navigator, "credentials", {
      value: { create: vi.fn(), get: vi.fn() },
      writable: true,
      configurable: true,
    });

    const support = await checkWebAuthnSupport();
    expect(support.available).toBe(true);
    expect(support.platformAuthenticator).toBe(true);
  });

  it("returns conditional mediation when available", async () => {
    Object.defineProperty(globalThis, "PublicKeyCredential", {
      value: class {
        static isUserVerifyingPlatformAuthenticatorAvailable = vi.fn().mockResolvedValue(false);
        static isConditionalMediationAvailable = vi.fn().mockResolvedValue(true);
      },
      writable: true,
      configurable: true,
    });
    const support = await checkWebAuthnSupport();
    expect(support.conditionalMediation).toBe(true);
  });

  it("handles exceptions from isUserVerifyingPlatformAuthenticatorAvailable", async () => {
    Object.defineProperty(globalThis, "PublicKeyCredential", {
      value: class {
        static isUserVerifyingPlatformAuthenticatorAvailable = vi
          .fn()
          .mockRejectedValue(new Error("Not supported"));
      },
      writable: true,
      configurable: true,
    });
    const support = await checkWebAuthnSupport();
    expect(support.platformAuthenticator).toBe(false);
  });
});

describe("registerCredential", () => {
  beforeEach(() => {
    // Mock navigator.credentials.create
    Object.defineProperty(globalThis, "PublicKeyCredential", {
      value: class {
        static isUserVerifyingPlatformAuthenticatorAvailable = vi.fn().mockResolvedValue(true);
      },
      writable: true,
      configurable: true,
    });
  });

  it("returns null when credentials.create is not available", async () => {
    // Ensure navigator.credentials.create throws
    Object.defineProperty(navigator, "credentials", {
      value: {
        create: vi.fn().mockRejectedValue(new Error("Not supported")),
        get: vi.fn().mockRejectedValue(new Error("Not supported")),
      },
      writable: true,
      configurable: true,
    });

    const result = await registerCredential({
      userName: "test@example.com",
      displayName: "Test User",
    });
    expect(result).toBeNull();
  });

  it("returns null when credentials.create returns null", async () => {
    Object.defineProperty(navigator, "credentials", {
      value: {
        create: vi.fn().mockResolvedValue(null),
        get: vi.fn().mockResolvedValue(null),
      },
      writable: true,
      configurable: true,
    });
    const result = await registerCredential({
      userName: "test@example.com",
      displayName: "Test User",
    });
    expect(result).toBeNull();
  });

  it("returns credential info on success", async () => {
    const mockPublicKey = new ArrayBuffer(65);
    const mockCredential = {
      rawId: new Uint8Array([1, 2, 3, 4]).buffer,
      response: {
        getPublicKey: () => mockPublicKey,
      },
    };
    Object.defineProperty(navigator, "credentials", {
      value: {
        create: vi.fn().mockResolvedValue(mockCredential),
        get: vi.fn(),
      },
      writable: true,
      configurable: true,
    });

    const result = await registerCredential({
      userName: "user@test.com",
      displayName: "User",
      rpName: "TestApp",
      rpId: "test.com",
    });
    expect(result).not.toBeNull();
    expect(result!.credentialId).toBeTruthy();
    expect(result!.publicKey).toBe(mockPublicKey);
    expect(result!.userId).toBeTruthy();
    expect(result!.createdAt).toBeTruthy();
  });
});

describe("authenticateCredential", () => {
  beforeEach(() => {
    Object.defineProperty(navigator, "credentials", {
      value: {
        create: vi.fn().mockRejectedValue(new Error("Not supported")),
        get: vi.fn().mockRejectedValue(new Error("Not supported")),
      },
      writable: true,
      configurable: true,
    });
  });

  it("returns null when authentication fails", async () => {
    const result = await authenticateCredential({ credentialIds: ["abc123"] });
    expect(result).toBeNull();
  });

  it("returns null when get returns null", async () => {
    Object.defineProperty(navigator, "credentials", {
      value: {
        get: vi.fn().mockResolvedValue(null),
      },
      writable: true,
      configurable: true,
    });
    const result = await authenticateCredential();
    expect(result).toBeNull();
  });

  it("returns credential ID and signature on success", async () => {
    const mockSignature = new ArrayBuffer(71);
    const mockAssertion = {
      rawId: new Uint8Array([10, 20, 30]).buffer,
      response: { signature: mockSignature },
    };
    Object.defineProperty(navigator, "credentials", {
      value: {
        get: vi.fn().mockResolvedValue(mockAssertion),
      },
      writable: true,
      configurable: true,
    });

    const result = await authenticateCredential({ rpId: "test.com" });
    expect(result).not.toBeNull();
    expect(result!.credentialId).toBeTruthy();
    expect(result!.signature).toBe(mockSignature);
  });

  it("works with empty credentialIds (passkey discoverable flow)", async () => {
    Object.defineProperty(navigator, "credentials", {
      value: {
        get: vi.fn().mockRejectedValue(new Error("Cancelled")),
      },
      writable: true,
      configurable: true,
    });
    const result = await authenticateCredential({});
    expect(result).toBeNull();
  });
});
