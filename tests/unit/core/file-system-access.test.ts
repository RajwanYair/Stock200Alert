/**
 * Tests for H6 — File System Access API helpers.
 * Exercises both the native File System Access API path (mocked)
 * and the <a> fallback for environments that lack the API.
 */
import { describe, it, expect, vi, afterEach } from "vitest";
import {
  saveStrategyToDisk,
  openStrategyFromDisk,
  type StrategyFilePayload,
} from "../../../src/core/file-system-access";

// ─── helpers ─────────────────────────────────────────────────────────────────

const SAMPLE: StrategyFilePayload = {
  expression: "rsi(14) < 30",
  varsJson: '{"period":14}',
  savedAt: "2026-05-03T10:00:00.000Z",
  version: 1,
};

function makeWritable() {
  const writes: (string | Blob)[] = [];
  return {
    write: vi.fn(async (data: string | Blob) => {
      writes.push(data);
    }),
    close: vi.fn(async () => {
      /* closed */
    }),
    _writes: writes,
  };
}

function makeFileHandle(content: string) {
  return {
    getFile: vi.fn(async () => new File([content], "strategy.json", { type: "application/json" })),
    createWritable: vi.fn(async () => makeWritable()),
  };
}

// ─── saveStrategyToDisk ───────────────────────────────────────────────────────

describe("saveStrategyToDisk", () => {
  afterEach(() => {
    vi.restoreAllMocks();
    delete (window as Record<string, unknown>).showSaveFilePicker;
  });

  it("returns true via native showSaveFilePicker path", async () => {
    const writable = makeWritable();
    const handle = { createWritable: vi.fn(async () => writable) };
    (window as Record<string, unknown>).showSaveFilePicker = vi.fn(async () => handle);

    const result = await saveStrategyToDisk(SAMPLE);
    expect(result).toBe(true);
    expect(handle.createWritable).toHaveBeenCalled();
    expect(writable.write).toHaveBeenCalled();
    expect(writable.close).toHaveBeenCalled();
  });

  it("writes valid JSON via native path", async () => {
    const writable = makeWritable();
    const handle = { createWritable: vi.fn(async () => writable) };
    (window as Record<string, unknown>).showSaveFilePicker = vi.fn(async () => handle);

    await saveStrategyToDisk(SAMPLE);
    const written = writable._writes[0] as string;
    const parsed = JSON.parse(written) as StrategyFilePayload;
    expect(parsed.expression).toBe(SAMPLE.expression);
    expect(parsed.version).toBe(1);
  });

  it("returns false when user cancels (AbortError) via native path", async () => {
    (window as Record<string, unknown>).showSaveFilePicker = vi.fn(async () => {
      throw new DOMException("Aborted", "AbortError");
    });

    const result = await saveStrategyToDisk(SAMPLE);
    expect(result).toBe(false);
  });

  it("falls back to <a> link when showSaveFilePicker is absent", async () => {
    delete (window as Record<string, unknown>).showSaveFilePicker;
    vi.spyOn(URL, "createObjectURL").mockReturnValue("blob:test/123");
    vi.spyOn(URL, "revokeObjectURL").mockReturnValue(undefined);
    const clickSpy = vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {});

    const result = await saveStrategyToDisk(SAMPLE);
    expect(result).toBe(true);
    expect(clickSpy).toHaveBeenCalled();
  });

  it("fallback assigns .download attribute with json extension", async () => {
    delete (window as Record<string, unknown>).showSaveFilePicker;
    vi.spyOn(URL, "createObjectURL").mockReturnValue("blob:test/456");
    vi.spyOn(URL, "revokeObjectURL").mockReturnValue(undefined);
    const links: HTMLAnchorElement[] = [];
    const origCreate = document.createElement.bind(document);
    vi.spyOn(document, "createElement").mockImplementation((tag: string) => {
      const el = origCreate(tag);
      if (tag === "a") links.push(el as HTMLAnchorElement);
      return el;
    });
    vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {});

    await saveStrategyToDisk(SAMPLE);
    const a = links[0];
    expect(a?.download).toContain(".json");
  });

  it("includes expression in fallback Blob content", async () => {
    delete (window as Record<string, unknown>).showSaveFilePicker;
    let capturedBlob: Blob | undefined;
    vi.spyOn(URL, "createObjectURL").mockImplementation((b) => {
      capturedBlob = b instanceof Blob ? b : undefined;
      return "blob:test/789";
    });
    vi.spyOn(URL, "revokeObjectURL").mockReturnValue(undefined);
    vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {});

    await saveStrategyToDisk(SAMPLE);
    const text = await capturedBlob?.text();
    expect(text).toContain(SAMPLE.expression);
  });
});

// ─── openStrategyFromDisk ─────────────────────────────────────────────────────

describe("openStrategyFromDisk", () => {
  afterEach(() => {
    vi.restoreAllMocks();
    delete (window as Record<string, unknown>).showOpenFilePicker;
  });

  it("returns null when showOpenFilePicker is absent (no fallback open)", async () => {
    delete (window as Record<string, unknown>).showOpenFilePicker;
    const result = await openStrategyFromDisk();
    expect(result).toBeNull();
  });

  it("parses and returns a valid payload via native path", async () => {
    const content = JSON.stringify(SAMPLE);
    const handle = makeFileHandle(content);
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => [handle]);

    const result = await openStrategyFromDisk();
    expect(result).not.toBeNull();
    expect(result?.expression).toBe(SAMPLE.expression);
    expect(result?.version).toBe(1);
  });

  it("returns null when expression field is missing", async () => {
    const bad = JSON.stringify({ varsJson: "{}", savedAt: "2026-05-01" });
    const handle = makeFileHandle(bad);
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => [handle]);

    const result = await openStrategyFromDisk();
    expect(result).toBeNull();
  });

  it("falls back varsJson to '{}' when field is absent", async () => {
    const partial = JSON.stringify({ expression: "macd()", savedAt: "2026-05-01", version: 1 });
    const handle = makeFileHandle(partial);
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => [handle]);

    const result = await openStrategyFromDisk();
    expect(result?.varsJson).toBe("{}");
  });

  it("returns null when user aborts (AbortError)", async () => {
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => {
      throw new DOMException("Aborted", "AbortError");
    });

    const result = await openStrategyFromDisk();
    expect(result).toBeNull();
  });

  it("returns null when JSON is malformed", async () => {
    const handle = makeFileHandle("{{invalid json}}");
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => [handle]);

    const result = await openStrategyFromDisk();
    expect(result).toBeNull();
  });

  it("fills in savedAt when field is absent", async () => {
    const partial = JSON.stringify({ expression: "macd()", version: 1 });
    const handle = makeFileHandle(partial);
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => [handle]);

    const result = await openStrategyFromDisk();
    expect(result?.savedAt).toBeTruthy();
    expect(typeof result?.savedAt).toBe("string");
  });

  it("returns null when no handle is returned (empty array)", async () => {
    (window as Record<string, unknown>).showOpenFilePicker = vi.fn(async () => []);

    const result = await openStrategyFromDisk();
    expect(result).toBeNull();
  });
});
