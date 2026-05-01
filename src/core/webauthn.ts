/**
 * WebAuthn Foundation (D1) — client-side passkey credential management.
 *
 * Provides registration (create) and authentication (get) flows using
 * the Web Authentication API. Since there's no server yet, challenges
 * are generated client-side (suitable for local-first / demo mode).
 *
 * In production, challenges must come from a server to prevent replay.
 * This module is structured to be easily wired to a server endpoint.
 */

export interface WebAuthnCredentialInfo {
  readonly credentialId: string;
  readonly publicKey: ArrayBuffer;
  readonly userId: string;
  readonly createdAt: string;
}

export interface WebAuthnSupport {
  readonly available: boolean;
  readonly platformAuthenticator: boolean;
  readonly conditionalMediation: boolean;
}

/**
 * Check WebAuthn availability and capabilities.
 */
export async function checkWebAuthnSupport(): Promise<WebAuthnSupport> {
  const available =
    typeof window !== "undefined" &&
    typeof window.PublicKeyCredential !== "undefined" &&
    typeof navigator.credentials !== "undefined";

  if (!available) {
    return { available: false, platformAuthenticator: false, conditionalMediation: false };
  }

  let platformAuthenticator = false;
  let conditionalMediation = false;

  try {
    platformAuthenticator =
      await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
  } catch {
    // Not supported
  }

  try {
    const cm = PublicKeyCredential as unknown as {
      isConditionalMediationAvailable?: () => Promise<boolean>;
    };
    if (typeof cm.isConditionalMediationAvailable === "function") {
      conditionalMediation = await cm.isConditionalMediationAvailable();
    }
  } catch {
    // Not supported
  }

  return { available, platformAuthenticator, conditionalMediation };
}

/**
 * Generate a cryptographically random challenge (32 bytes).
 * In production, this would come from the server.
 */
export function generateChallenge(): Uint8Array {
  return crypto.getRandomValues(new Uint8Array(32));
}

/**
 * Convert ArrayBuffer to base64url string (URL-safe, no padding).
 */
export function bufferToBase64url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  for (const b of bytes) {
    binary += String.fromCharCode(b);
  }
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/**
 * Convert base64url string back to ArrayBuffer.
 */
export function base64urlToBuffer(base64url: string): ArrayBuffer {
  const base64 = base64url.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64 + "=".repeat((4 - (base64.length % 4)) % 4);
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

export interface RegisterOptions {
  readonly userName: string;
  readonly displayName: string;
  readonly rpName?: string;
  readonly rpId?: string;
}

/**
 * Register a new passkey credential.
 * Returns the credential info on success, or null if user cancelled.
 */
export async function registerCredential(
  options: RegisterOptions,
): Promise<WebAuthnCredentialInfo | null> {
  const userId = crypto.getRandomValues(new Uint8Array(16));
  const challenge = generateChallenge();

  const createOptions: CredentialCreationOptions = {
    publicKey: {
      rp: {
        name: options.rpName ?? "CrossTide",
        id: options.rpId ?? window.location.hostname,
      },
      user: {
        id: userId,
        name: options.userName,
        displayName: options.displayName,
      },
      challenge: challenge as BufferSource,
      pubKeyCredParams: [
        { type: "public-key", alg: -7 }, // ES256
        { type: "public-key", alg: -257 }, // RS256
      ],
      authenticatorSelection: {
        authenticatorAttachment: "platform",
        residentKey: "preferred",
        userVerification: "preferred",
      },
      timeout: 60000,
      attestation: "none",
    },
  };

  try {
    const credential = (await navigator.credentials.create(
      createOptions,
    )) as PublicKeyCredential | null;
    if (!credential) return null;

    const response = credential.response as AuthenticatorAttestationResponse;
    return {
      credentialId: bufferToBase64url(credential.rawId),
      publicKey: response.getPublicKey?.() ?? new ArrayBuffer(0),
      userId: bufferToBase64url(userId.buffer),
      createdAt: new Date().toISOString(),
    };
  } catch {
    return null;
  }
}

export interface AuthenticateOptions {
  readonly credentialIds?: readonly string[];
  readonly rpId?: string;
}

/**
 * Authenticate with an existing passkey.
 * Returns the credential ID used, or null if user cancelled.
 */
export async function authenticateCredential(
  options: AuthenticateOptions = {},
): Promise<{ credentialId: string; signature: ArrayBuffer } | null> {
  const challenge = generateChallenge();

  const allowCredentials: PublicKeyCredentialDescriptor[] = (options.credentialIds ?? []).map(
    (id) => ({
      type: "public-key",
      id: base64urlToBuffer(id),
    }),
  );

  const getOptions: CredentialRequestOptions = {
    publicKey: {
      challenge: challenge as BufferSource,
      rpId: options.rpId ?? window.location.hostname,
      ...(allowCredentials.length > 0 ? { allowCredentials } : {}),
      userVerification: "preferred",
      timeout: 60000,
    },
  };

  try {
    const assertion = (await navigator.credentials.get(getOptions)) as PublicKeyCredential | null;
    if (!assertion) return null;

    const response = assertion.response as AuthenticatorAssertionResponse;
    return {
      credentialId: bufferToBase64url(assertion.rawId),
      signature: response.signature,
    };
  } catch {
    return null;
  }
}
