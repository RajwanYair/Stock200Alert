import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import {
  sortRows,
  toggleSort,
  ariaSort,
  bindSortableTable,
  persistSort,
  loadSort,
} from "../../../src/ui/sortable";

describe("sortRows", () => {
  const data = [
    { name: "AAPL", price: 150, volume: 5000 },
    { name: "MSFT", price: 300, volume: 3000 },
    { name: "GOOG", price: 100, volume: 2000 },
    { name: "AMZN", price: 200, volume: 4000 },
  ];

  it("sorts numerically ascending", () => {
    const sorted = sortRows(data, { column: "price", direction: "asc" });
    expect(sorted.map((r) => r.price)).toEqual([100, 150, 200, 300]);
  });

  it("sorts numerically descending", () => {
    const sorted = sortRows(data, { column: "price", direction: "desc" });
    expect(sorted.map((r) => r.price)).toEqual([300, 200, 150, 100]);
  });

  it("sorts strings alphabetically ascending", () => {
    const sorted = sortRows(data, { column: "name", direction: "asc" });
    expect(sorted.map((r) => r.name)).toEqual(["AAPL", "AMZN", "GOOG", "MSFT"]);
  });

  it("sorts strings alphabetically descending", () => {
    const sorted = sortRows(data, { column: "name", direction: "desc" });
    expect(sorted.map((r) => r.name)).toEqual(["MSFT", "GOOG", "AMZN", "AAPL"]);
  });

  it("does not mutate the original array", () => {
    const original = [...data];
    sortRows(data, { column: "price", direction: "asc" });
    expect(data).toEqual(original);
  });

  it("handles null values (pushes to end)", () => {
    const withNulls = [
      { name: "A", price: 10 as number | null },
      { name: "B", price: null },
      { name: "C", price: 5 },
    ];
    const sorted = sortRows(withNulls, { column: "price", direction: "asc" });
    expect(sorted.map((r) => r.price)).toEqual([5, 10, null]);
  });

  it("handles empty array", () => {
    expect(sortRows([], { column: "x", direction: "asc" })).toEqual([]);
  });
});

describe("toggleSort", () => {
  it("toggles direction on same column", () => {
    const result = toggleSort({ column: "price", direction: "asc" }, "price");
    expect(result).toEqual({ column: "price", direction: "desc" });
  });

  it("toggles back to asc", () => {
    const result = toggleSort({ column: "price", direction: "desc" }, "price");
    expect(result).toEqual({ column: "price", direction: "asc" });
  });

  it("defaults to asc on new column", () => {
    const result = toggleSort({ column: "price", direction: "desc" }, "name");
    expect(result).toEqual({ column: "name", direction: "asc" });
  });
});

describe("ariaSort", () => {
  it("returns ascending for the active asc column", () => {
    expect(ariaSort({ column: "price", direction: "asc" }, "price")).toBe("ascending");
  });

  it("returns descending for the active desc column", () => {
    expect(ariaSort({ column: "price", direction: "desc" }, "price")).toBe("descending");
  });

  it("returns none for an inactive column", () => {
    expect(ariaSort({ column: "price", direction: "asc" }, "name")).toBe("none");
  });
});

describe("bindSortableTable", () => {
  let thead: HTMLElement;
  beforeEach(() => {
    thead = document.createElement("thead");
    const tr = document.createElement("tr");
    const th = document.createElement("th");
    th.dataset["sort"] = "price";
    th.setAttribute("tabindex", "0");
    tr.appendChild(th);
    thead.appendChild(tr);
    document.body.appendChild(thead);
  });

  afterEach(() => {
    document.body.removeChild(thead);
    vi.restoreAllMocks();
  });

  it("fires onSort with column key on Enter key", () => {
    const onSort = vi.fn();
    bindSortableTable(thead, onSort);
    const th = thead.querySelector<HTMLElement>("[data-sort]")!;
    th.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", bubbles: true }));
    expect(onSort).toHaveBeenCalledWith("price");
  });

  it("fires onSort with column key on Space key", () => {
    const onSort = vi.fn();
    bindSortableTable(thead, onSort);
    const th = thead.querySelector<HTMLElement>("[data-sort]")!;
    th.dispatchEvent(new KeyboardEvent("keydown", { key: " ", bubbles: true }));
    expect(onSort).toHaveBeenCalledWith("price");
  });

  it("does not fire onSort on other keys", () => {
    const onSort = vi.fn();
    bindSortableTable(thead, onSort);
    const th = thead.querySelector<HTMLElement>("[data-sort]")!;
    th.dispatchEvent(new KeyboardEvent("keydown", { key: "Tab", bubbles: true }));
    expect(onSort).not.toHaveBeenCalled();
  });

  it("updates live region text when getAria is provided", () => {
    const onSort = vi.fn();
    const liveRegion = document.createElement("div");
    const getAria = vi.fn().mockReturnValue("ascending");
    bindSortableTable(thead, onSort, liveRegion, getAria);
    const th = thead.querySelector<HTMLElement>("[data-sort]")!;
    th.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", bubbles: true }));
    expect(liveRegion.textContent).toBe("Sorted by price ascending");
  });

  it("handles null thead gracefully", () => {
    expect(() => bindSortableTable(null, vi.fn())).not.toThrow();
  });
});

// ── localStorage sort persistence (B14) ───────────────────────────────────────

function createStorageMock(): Storage {
  const store = new Map<string, string>();
  return {
    get length() {
      return store.size;
    },
    key(i: number) {
      return [...store.keys()][i] ?? null;
    },
    getItem(k: string) {
      return store.get(k) ?? null;
    },
    setItem(k: string, v: string) {
      store.set(k, v);
    },
    removeItem(k: string) {
      store.delete(k);
    },
    clear() {
      store.clear();
    },
  };
}

describe("persistSort / loadSort", () => {
  beforeEach(() => {
    vi.stubGlobal("localStorage", createStorageMock());
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  describe("persistSort", () => {
    it("saves a sort config under a prefixed key", () => {
      persistSort("watchlist", { column: "price", direction: "desc" });
      const raw = localStorage.getItem("ct_sort_watchlist");
      expect(raw).not.toBeNull();
      const parsed = JSON.parse(raw!) as unknown;
      expect(parsed).toEqual({ column: "price", direction: "desc" });
    });

    it("overwrites an existing entry", () => {
      persistSort("watchlist", { column: "price", direction: "asc" });
      persistSort("watchlist", { column: "name", direction: "desc" });
      const raw = localStorage.getItem("ct_sort_watchlist");
      expect(JSON.parse(raw!)).toEqual({ column: "name", direction: "desc" });
    });

    it("uses different keys for different tables", () => {
      persistSort("watchlist", { column: "price", direction: "asc" });
      persistSort("screener", { column: "name", direction: "desc" });
      expect(localStorage.getItem("ct_sort_watchlist")).not.toBeNull();
      expect(localStorage.getItem("ct_sort_screener")).not.toBeNull();
      expect(localStorage.getItem("ct_sort_watchlist")).not.toBe(
        localStorage.getItem("ct_sort_screener"),
      );
    });

    it("does not throw when localStorage is unavailable", () => {
      vi.stubGlobal("localStorage", {
        getItem: () => {
          throw new Error("unavailable");
        },
        setItem: () => {
          throw new Error("unavailable");
        },
        removeItem: () => null,
        key: () => null,
        clear: () => null,
        length: 0,
      });
      expect(() => persistSort("x", { column: "c", direction: "asc" })).not.toThrow();
    });
  });

  describe("loadSort", () => {
    it("returns null when no entry exists", () => {
      expect(loadSort("watchlist")).toBeNull();
    });

    it("returns the saved sort config", () => {
      persistSort("watchlist", { column: "change", direction: "asc" });
      const loaded = loadSort("watchlist");
      expect(loaded).toEqual({ column: "change", direction: "asc" });
    });

    it("returns null for malformed JSON", () => {
      localStorage.setItem("ct_sort_bad", "{not-valid-json");
      expect(loadSort("bad")).toBeNull();
    });

    it("returns null for stored object missing column", () => {
      localStorage.setItem("ct_sort_bad2", JSON.stringify({ direction: "asc" }));
      expect(loadSort("bad2")).toBeNull();
    });

    it("returns null for stored object with invalid direction", () => {
      localStorage.setItem("ct_sort_bad3", JSON.stringify({ column: "price", direction: "up" }));
      expect(loadSort("bad3")).toBeNull();
    });

    it("roundtrips asc and desc directions correctly", () => {
      persistSort("t1", { column: "col", direction: "asc" });
      persistSort("t2", { column: "col", direction: "desc" });
      expect(loadSort("t1")?.direction).toBe("asc");
      expect(loadSort("t2")?.direction).toBe("desc");
    });

    it("does not throw when localStorage is unavailable", () => {
      vi.stubGlobal("localStorage", {
        getItem: () => {
          throw new Error("unavailable");
        },
        setItem: () => null,
        removeItem: () => null,
        key: () => null,
        clear: () => null,
        length: 0,
      });
      expect(() => loadSort("x")).not.toThrow();
      expect(loadSort("x")).toBeNull();
    });
  });
});
