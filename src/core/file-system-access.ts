/**
 * File System Access helpers (H6) with browser-safe fallbacks.
 */

export interface StrategyFilePayload {
  expression: string;
  varsJson: string;
  savedAt: string;
  version: 1;
}

interface FilePickerAcceptType {
  description?: string;
  accept: Record<string, string[]>;
}

interface SaveFilePickerOptions {
  suggestedName?: string;
  types?: FilePickerAcceptType[];
  excludeAcceptAllOption?: boolean;
}

interface OpenFilePickerOptions {
  multiple?: boolean;
  types?: FilePickerAcceptType[];
  excludeAcceptAllOption?: boolean;
}

interface FileSystemWritableFileStream {
  write(data: Blob | string): Promise<void>;
  close(): Promise<void>;
}

interface FileSystemFileHandle {
  getFile(): Promise<File>;
  createWritable(): Promise<FileSystemWritableFileStream>;
}

interface WindowWithFS extends Window {
  showSaveFilePicker?: (options?: SaveFilePickerOptions) => Promise<FileSystemFileHandle>;
  showOpenFilePicker?: (options?: OpenFilePickerOptions) => Promise<FileSystemFileHandle[]>;
}

const JSON_FILE_TYPES: FilePickerAcceptType[] = [
  {
    description: "Signal Strategy JSON",
    accept: { "application/json": [".json"] },
  },
];

function isAbortError(err: unknown): boolean {
  return err instanceof DOMException && err.name === "AbortError";
}

export async function saveStrategyToDisk(payload: StrategyFilePayload): Promise<boolean> {
  const win = window as WindowWithFS;
  const text = JSON.stringify(payload, null, 2);
  try {
    if (typeof win.showSaveFilePicker === "function") {
      const handle = await win.showSaveFilePicker({
        suggestedName: "signal-strategy.json",
        types: JSON_FILE_TYPES,
        excludeAcceptAllOption: false,
      });
      const writable = await handle.createWritable();
      await writable.write(text);
      await writable.close();
      return true;
    }
  } catch (err) {
    if (isAbortError(err)) return false;
  }

  // Fallback download for browsers without File System Access API.
  const blob = new Blob([text], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "signal-strategy.json";
  a.click();
  URL.revokeObjectURL(url);
  return true;
}

export async function openStrategyFromDisk(): Promise<StrategyFilePayload | null> {
  const win = window as WindowWithFS;
  try {
    if (typeof win.showOpenFilePicker === "function") {
      const [handle] = await win.showOpenFilePicker({
        multiple: false,
        types: JSON_FILE_TYPES,
        excludeAcceptAllOption: false,
      });
      if (!handle) return null;
      const file = await handle.getFile();
      const text = await file.text();
      const raw = JSON.parse(text) as Partial<StrategyFilePayload>;
      if (typeof raw.expression !== "string") return null;
      return {
        expression: raw.expression,
        varsJson: typeof raw.varsJson === "string" ? raw.varsJson : "{}",
        savedAt: typeof raw.savedAt === "string" ? raw.savedAt : new Date().toISOString(),
        version: 1,
      };
    }
  } catch (err) {
    if (isAbortError(err)) return null;
    return null;
  }

  // No generic fallback for open() without user file input UX here.
  return null;
}
