/**
 * Unit tests for CRDT config merge (I7).
 */
import { describe, it, expect } from "vitest";
import {
  createLwwRegister,
  updateRegister,
  mergeLwwRegisters,
  createGSet,
  gSetAdd,
  mergeGSets,
  createOrSet,
  orSetAdd,
  orSetRemove,
  orSetItems,
  mergeOrSets,
  mergeRegisterMaps,
  buildSyncEnvelope,
} from "../../../src/core/crdt-sync";

// ── LWW Register ─────────────────────────────────────────────────────────

describe("createLwwRegister", () => {
  it("creates register with default clock", () => {
    const r = createLwwRegister("theme", "dark", "d1");
    expect(r.key).toBe("theme");
    expect(r.value).toBe("dark");
    expect(r.clock).toBe(1);
    expect(r.deviceId).toBe("d1");
  });

  it("accepts custom clock and timestamp", () => {
    const r = createLwwRegister("k", "v", "d", 5, 1000);
    expect(r.clock).toBe(5);
    expect(r.timestamp).toBe(1000);
  });
});

describe("updateRegister", () => {
  it("increments clock", () => {
    const r = createLwwRegister("k", "a", "d", 1, 1000);
    const u = updateRegister(r, "b", 2000);
    expect(u.value).toBe("b");
    expect(u.clock).toBe(2);
    expect(u.timestamp).toBe(2000);
    expect(u.deviceId).toBe("d");
  });
});

describe("mergeLwwRegisters", () => {
  it("higher clock wins", () => {
    const a = createLwwRegister("k", "A", "d1", 3, 1000);
    const b = createLwwRegister("k", "B", "d2", 5, 500);
    expect(mergeLwwRegisters(a, b).value).toBe("B");
  });

  it("same clock: later timestamp wins", () => {
    const a = createLwwRegister("k", "A", "d1", 3, 2000);
    const b = createLwwRegister("k", "B", "d2", 3, 1000);
    expect(mergeLwwRegisters(a, b).value).toBe("A");
  });

  it("same clock + timestamp: higher deviceId wins", () => {
    const a = createLwwRegister("k", "A", "d1", 3, 1000);
    const b = createLwwRegister("k", "B", "d2", 3, 1000);
    expect(mergeLwwRegisters(a, b).value).toBe("B"); // "d2" > "d1"
  });

  it("is commutative", () => {
    const a = createLwwRegister("k", "A", "d1", 2, 1000);
    const b = createLwwRegister("k", "B", "d2", 3, 500);
    expect(mergeLwwRegisters(a, b).value).toBe(mergeLwwRegisters(b, a).value);
  });

  it("is idempotent", () => {
    const a = createLwwRegister("k", "A", "d1", 3, 1000);
    expect(mergeLwwRegisters(a, a)).toEqual(a);
  });
});

// ── G-Set ────────────────────────────────────────────────────────────────

describe("createGSet", () => {
  it("creates empty set by default", () => {
    const s = createGSet();
    expect(s.items.size).toBe(0);
  });

  it("initializes from iterable", () => {
    const s = createGSet(["a", "b"]);
    expect(s.items.size).toBe(2);
  });
});

describe("gSetAdd", () => {
  it("adds items", () => {
    const s = gSetAdd(createGSet(), "a", "b");
    expect(s.items.has("a")).toBe(true);
    expect(s.items.has("b")).toBe(true);
  });

  it("ignores duplicates", () => {
    const s = gSetAdd(createGSet(["a"]), "a");
    expect(s.items.size).toBe(1);
  });
});

describe("mergeGSets", () => {
  it("computes union", () => {
    const a = createGSet(["a", "b"]);
    const b = createGSet(["b", "c"]);
    const merged = mergeGSets(a, b);
    expect(merged.items.size).toBe(3);
    expect(merged.items.has("c")).toBe(true);
  });

  it("is commutative", () => {
    const a = createGSet(["a", "b"]);
    const b = createGSet(["c"]);
    expect(mergeGSets(a, b).items.size).toBe(mergeGSets(b, a).items.size);
  });
});

// ── OR-Set ───────────────────────────────────────────────────────────────

describe("OR-Set", () => {
  it("adds items", () => {
    let s = createOrSet();
    s = orSetAdd(s, "a", 1);
    expect(orSetItems(s)).toEqual(["a"]);
  });

  it("removes items", () => {
    let s = createOrSet<string>();
    s = orSetAdd(s, "a", 1);
    s = orSetRemove(s, "a", 2);
    expect(orSetItems(s)).toEqual([]);
  });

  it("re-add after remove works if add clock is higher", () => {
    let s = createOrSet<string>();
    s = orSetAdd(s, "a", 1);
    s = orSetRemove(s, "a", 2);
    s = orSetAdd(s, "a", 3);
    expect(orSetItems(s)).toEqual(["a"]);
  });

  it("remove with lower clock does not remove", () => {
    let s = createOrSet<string>();
    s = orSetAdd(s, "a", 3);
    s = orSetRemove(s, "a", 2);
    expect(orSetItems(s)).toEqual(["a"]);
  });

  it("remove of nonexistent is no-op", () => {
    const s = orSetRemove(createOrSet(), "x", 1);
    expect(orSetItems(s)).toEqual([]);
  });
});

describe("mergeOrSets", () => {
  it("merges concurrent adds", () => {
    const a = orSetAdd(createOrSet<string>(), "x", 1);
    const b = orSetAdd(createOrSet<string>(), "y", 1);
    const merged = mergeOrSets(a, b);
    expect(orSetItems(merged).sort()).toEqual(["x", "y"]);
  });

  it("add on one side + remove on other: higher clock wins", () => {
    let a = createOrSet<string>();
    a = orSetAdd(a, "x", 1);
    let b = createOrSet<string>();
    b = orSetAdd(b, "x", 1);
    b = orSetRemove(b, "x", 2);
    const merged = mergeOrSets(a, b);
    expect(orSetItems(merged)).toEqual([]);
  });

  it("is commutative", () => {
    const a = orSetAdd(createOrSet<string>(), "x", 1);
    const b = orSetAdd(createOrSet<string>(), "y", 2);
    expect(orSetItems(mergeOrSets(a, b)).sort()).toEqual(orSetItems(mergeOrSets(b, a)).sort());
  });

  it("is idempotent", () => {
    const s = orSetAdd(createOrSet<string>(), "x", 1);
    const m = mergeOrSets(s, s);
    expect(orSetItems(m)).toEqual(orSetItems(s));
  });
});

// ── mergeRegisterMaps ────────────────────────────────────────────────────

describe("mergeRegisterMaps", () => {
  it("merges non-overlapping keys", () => {
    const local = new Map([["a", createLwwRegister("a", 1, "d1")]]);
    const remote = new Map([["b", createLwwRegister("b", 2, "d2")]]);
    const { merged, report } = mergeRegisterMaps(local, remote);
    expect(merged.size).toBe(2);
    expect(report.updatedKeys).toContain("b");
    expect(report.conflicts).toBe(0);
  });

  it("resolves conflicts with higher clock", () => {
    const local = new Map([["k", createLwwRegister("k", "old", "d1", 1, 1000)]]);
    const remote = new Map([["k", createLwwRegister("k", "new", "d2", 3, 500)]]);
    const { merged, report } = mergeRegisterMaps(local, remote);
    expect(merged.get("k")!.value).toBe("new");
    expect(report.conflicts).toBe(1);
  });

  it("keeps local when local wins", () => {
    const local = new Map([["k", createLwwRegister("k", "loc", "d1", 5, 1000)]]);
    const remote = new Map([["k", createLwwRegister("k", "rem", "d2", 2, 1000)]]);
    const { merged, report } = mergeRegisterMaps(local, remote);
    expect(merged.get("k")!.value).toBe("loc");
    expect(report.conflicts).toBe(0);
  });
});

// ── buildSyncEnvelope ────────────────────────────────────────────────────

describe("buildSyncEnvelope", () => {
  it("builds envelope with max clock", () => {
    const regs = [
      createLwwRegister("a", 1, "d1", 3, 1000),
      createLwwRegister("b", 2, "d1", 7, 2000),
    ];
    const env = buildSyncEnvelope("d1", regs, { tickers: ["AAPL"] });
    expect(env.deviceId).toBe("d1");
    expect(env.clock).toBe(7);
    expect(env.registers).toHaveLength(2);
    expect(env.sets.tickers).toEqual(["AAPL"]);
  });

  it("handles empty registers", () => {
    const env = buildSyncEnvelope("d1", []);
    expect(env.clock).toBe(0);
    expect(env.registers).toHaveLength(0);
  });
});
