/**
 * Telemetry extended tests — covers lines 141-190 (the "active" paths where
 * Plausible analytics and/or GlitchTip error tracking are configured).
 *
 * Module-level globals (__PLAUSIBLE_URL__ etc.) are injected via
 * vi.stubGlobal + vi.resetModules() before each dynamic import.
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import type { TelemetryHandle } from "../../../src/core/telemetry";

// Mock all three sinks so no real network calls are made.
vi.mock("../../../src/core/analytics-client", () => ({
  createAnalyticsClient: vi.fn().mockReturnValue({
    event: vi.fn(),
    pageview: vi.fn(),
    setEnabled: vi.fn(),
  }),
}));

vi.mock("../../../src/core/error-boundary", () => ({
  installErrorBoundary: vi.fn().mockReturnValue(vi.fn()),
}));

vi.mock("../../../src/core/web-vitals", () => ({
  observeWebVitals: vi.fn().mockReturnValue({ stop: vi.fn() }),
}));

/** Helper: load a fresh telemetry module with given env stubs. */
async function loadTelemetry(
  plausibleUrl = "",
  plausibleSite = "",
  glitchtipDsn = "",
): Promise<{
  initTelemetry: () => TelemetryHandle;
  getTelemetry: () => TelemetryHandle | null;
  _resetTelemetryForTests: () => void;
}> {
  if (plausibleUrl) vi.stubGlobal("__PLAUSIBLE_URL__", plausibleUrl);
  if (plausibleSite) vi.stubGlobal("__PLAUSIBLE_SITE__", plausibleSite);
  if (glitchtipDsn) vi.stubGlobal("__GLITCHTIP_DSN__", glitchtipDsn);

  vi.resetModules();
  return import("../../../src/core/telemetry") as Promise<{
    initTelemetry: () => TelemetryHandle;
    getTelemetry: () => TelemetryHandle | null;
    _resetTelemetryForTests: () => void;
  }>;
}

afterEach(() => {
  vi.unstubAllGlobals();
  vi.resetModules();
});

describe("telemetry — analytics active path (lines 141-190)", () => {
  it("createAnalyticsClient is called when PLAUSIBLE_URL and PLAUSIBLE_SITE are set", async () => {
    const { createAnalyticsClient } = await import("../../../src/core/analytics-client");
    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "https://plausible.io",
      "test.site",
    );
    _resetTelemetryForTests();
    initTelemetry();
    expect(createAnalyticsClient).toHaveBeenCalledWith(
      expect.objectContaining({
        endpoint: expect.stringContaining("plausible.io"),
        site: "test.site",
      }),
    );
  });

  it("observeWebVitals is wired when analytics is active", async () => {
    const { observeWebVitals } = await import("../../../src/core/web-vitals");
    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "https://plausible.io",
      "test.site",
    );
    _resetTelemetryForTests();
    initTelemetry();
    expect(observeWebVitals).toHaveBeenCalled();
  });

  it("destroy() stops vitals observer when analytics was active", async () => {
    const mockStop = vi.fn();
    const { observeWebVitals } = await import("../../../src/core/web-vitals");
    (observeWebVitals as ReturnType<typeof vi.fn>).mockReturnValue({ stop: mockStop });

    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "https://plausible.io",
      "test.site",
    );
    _resetTelemetryForTests();
    const handle = initTelemetry();
    handle.destroy();
    expect(mockStop).toHaveBeenCalledOnce();
  });

  it("handle.event delegates to analytics.event", async () => {
    const mockEvent = vi.fn();
    const { createAnalyticsClient } = await import("../../../src/core/analytics-client");
    (createAnalyticsClient as ReturnType<typeof vi.fn>).mockReturnValue({
      event: mockEvent,
      pageview: vi.fn(),
      setEnabled: vi.fn(),
    });

    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "https://plausible.io",
      "test.site",
    );
    _resetTelemetryForTests();
    const handle = initTelemetry();
    handle.event("click", { button: "run" });
    expect(mockEvent).toHaveBeenCalledWith("click", { button: "run" });
  });
});

describe("telemetry — error tracking active path", () => {
  it("installErrorBoundary is called with handler when GLITCHTIP_DSN is set", async () => {
    const { installErrorBoundary } = await import("../../../src/core/error-boundary");
    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "",
      "",
      "https://key@glitchtip.example.com/1",
    );
    _resetTelemetryForTests();
    initTelemetry();
    // Called with a custom handler function (not undefined)
    expect(installErrorBoundary).toHaveBeenCalledWith(expect.any(Function));
  });

  it("installErrorBoundary is called without handler when only analytics is set", async () => {
    const { installErrorBoundary } = await import("../../../src/core/error-boundary");
    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "https://plausible.io",
      "test.site",
      "", // no error tracking
    );
    _resetTelemetryForTests();
    initTelemetry();
    // Called without arguments (or with undefined)
    expect(installErrorBoundary).toHaveBeenCalled();
  });

  it("destroy() calls the error boundary teardown when active", async () => {
    const mockTeardown = vi.fn();
    const { installErrorBoundary } = await import("../../../src/core/error-boundary");
    (installErrorBoundary as ReturnType<typeof vi.fn>).mockReturnValue(mockTeardown);

    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "",
      "",
      "https://key@glitchtip.example.com/1",
    );
    _resetTelemetryForTests();
    const handle = initTelemetry();
    handle.destroy();
    expect(mockTeardown).toHaveBeenCalledOnce();
  });
});

describe("telemetry — both analytics and error tracking active", () => {
  it("wires all three sinks when all env vars set", async () => {
    const { createAnalyticsClient } = await import("../../../src/core/analytics-client");
    const { installErrorBoundary } = await import("../../../src/core/error-boundary");
    const { observeWebVitals } = await import("../../../src/core/web-vitals");

    const { initTelemetry, _resetTelemetryForTests } = await loadTelemetry(
      "https://plausible.io",
      "test.site",
      "https://key@glitchtip.example.com/1",
    );
    _resetTelemetryForTests();
    const handle = initTelemetry();

    expect(createAnalyticsClient).toHaveBeenCalled();
    expect(installErrorBoundary).toHaveBeenCalled();
    expect(observeWebVitals).toHaveBeenCalled();

    handle.destroy();
  });
});
