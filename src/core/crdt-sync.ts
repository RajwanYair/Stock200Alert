/**
 * CRDT-inspired config merge for multi-device cloud sync (I7).
 *
 * Provides last-write-wins (LWW) register, grow-only set, and
 * observed-remove set primitives for conflict-free merging of
 * user config and watchlist state across devices.
 *
 * Each value carries a Lamport-style clock (monotonic counter) plus
 * a wall-clock timestamp for tie-breaking.  Merge is commutative,
 * associative, and idempotent — no coordination needed.
 *
 * Usage:
 *   const local = createLwwRegister("theme", "dark", "device-A");
 *   const remote = createLwwRegister("theme", "light", "device-B");
 *   const merged = mergeLwwRegisters(local, remote); // latest wins
 */

// ── Types ────────────────────────────────────────────────────────────────

export interface LwwRegister<T = unknown> {
  readonly key: string;
  readonly value: T;
  readonly clock: number;
  readonly timestamp: number;
  readonly deviceId: string;
}

export interface GSet<T = string> {
  readonly items: ReadonlySet<T>;
}

export interface OrSetEntry<T = string> {
  readonly value: T;
  readonly addClock: number;
  readonly removeClock: number;
}

export interface OrSet<T = string> {
  readonly entries: ReadonlyMap<string, OrSetEntry<T>>;
}

export interface SyncEnvelope {
  readonly deviceId: string;
  readonly clock: number;
  readonly timestamp: number;
  readonly registers: readonly LwwRegister[];
  readonly sets: Record<string, readonly string[]>;
}

export interface MergeReport {
  readonly conflicts: number;
  readonly updatedKeys: readonly string[];
  readonly addedItems: readonly string[];
  readonly removedItems: readonly string[];
}

// ── LWW Register ─────────────────────────────────────────────────────────

/**
 * Create a new LWW register.
 */
export function createLwwRegister<T>(
  key: string,
  value: T,
  deviceId: string,
  clock = 1,
  timestamp = Date.now(),
): LwwRegister<T> {
  return { key, value, clock, timestamp, deviceId };
}

/**
 * Update a register's value, incrementing the clock.
 */
export function updateRegister<T>(
  reg: LwwRegister<T>,
  value: T,
  timestamp = Date.now(),
): LwwRegister<T> {
  return { ...reg, value, clock: reg.clock + 1, timestamp };
}

/**
 * Merge two LWW registers. Higher clock wins; on tie, later timestamp wins;
 * on further tie, lexicographic deviceId breaks it (deterministic).
 */
export function mergeLwwRegisters<T>(a: LwwRegister<T>, b: LwwRegister<T>): LwwRegister<T> {
  if (a.clock !== b.clock) return a.clock > b.clock ? a : b;
  if (a.timestamp !== b.timestamp) return a.timestamp > b.timestamp ? a : b;
  return a.deviceId >= b.deviceId ? a : b;
}

// ── Grow-Only Set ────────────────────────────────────────────────────────

/**
 * Create a G-Set (grow-only set).
 */
export function createGSet<T = string>(items?: Iterable<T>): GSet<T> {
  return { items: new Set(items) };
}

/**
 * Add items to a G-Set (returns new G-Set).
 */
export function gSetAdd<T>(set: GSet<T>, ...items: T[]): GSet<T> {
  const next = new Set(set.items);
  for (const item of items) next.add(item);
  return { items: next };
}

/**
 * Merge two G-Sets (union).
 */
export function mergeGSets<T>(a: GSet<T>, b: GSet<T>): GSet<T> {
  const merged = new Set(a.items);
  for (const item of b.items) merged.add(item);
  return { items: merged };
}

// ── Observed-Remove Set ──────────────────────────────────────────────────

/**
 * Create an OR-Set (observed-remove set).
 */
export function createOrSet<T = string>(): OrSet<T> {
  return { entries: new Map() };
}

/**
 * Add an item to an OR-Set.
 */
export function orSetAdd<T>(set: OrSet<T>, value: T, clock: number): OrSet<T> {
  const key = String(value);
  const existing = set.entries.get(key);
  const entries = new Map(set.entries);
  if (existing) {
    entries.set(key, {
      value,
      addClock: Math.max(existing.addClock, clock),
      removeClock: existing.removeClock,
    });
  } else {
    entries.set(key, { value, addClock: clock, removeClock: 0 });
  }
  return { entries };
}

/**
 * Remove an item from an OR-Set.
 */
export function orSetRemove<T>(set: OrSet<T>, value: T, clock: number): OrSet<T> {
  const key = String(value);
  const existing = set.entries.get(key);
  if (!existing) return set;
  const entries = new Map(set.entries);
  entries.set(key, {
    ...existing,
    removeClock: Math.max(existing.removeClock, clock),
  });
  return { entries };
}

/**
 * Get active (non-removed) items from an OR-Set.
 */
export function orSetItems<T>(set: OrSet<T>): T[] {
  const result: T[] = [];
  for (const entry of set.entries.values()) {
    if (entry.addClock > entry.removeClock) {
      result.push(entry.value);
    }
  }
  return result;
}

/**
 * Merge two OR-Sets.
 */
export function mergeOrSets<T>(a: OrSet<T>, b: OrSet<T>): OrSet<T> {
  const entries = new Map(a.entries);
  for (const [key, bEntry] of b.entries) {
    const aEntry = entries.get(key);
    if (aEntry) {
      entries.set(key, {
        value: bEntry.value,
        addClock: Math.max(aEntry.addClock, bEntry.addClock),
        removeClock: Math.max(aEntry.removeClock, bEntry.removeClock),
      });
    } else {
      entries.set(key, bEntry);
    }
  }
  return { entries };
}

// ── Config merge ─────────────────────────────────────────────────────────

/**
 * Merge a map of LWW registers (keyed by register key).
 */
export function mergeRegisterMaps(
  local: ReadonlyMap<string, LwwRegister>,
  remote: ReadonlyMap<string, LwwRegister>,
): { merged: Map<string, LwwRegister>; report: MergeReport } {
  const merged = new Map(local);
  let conflicts = 0;
  const updatedKeys: string[] = [];

  for (const [key, remoteReg] of remote) {
    const localReg = merged.get(key);
    if (!localReg) {
      merged.set(key, remoteReg);
      updatedKeys.push(key);
    } else {
      const winner = mergeLwwRegisters(localReg, remoteReg);
      if (winner !== localReg) {
        merged.set(key, winner);
        updatedKeys.push(key);
        conflicts++;
      }
    }
  }

  return {
    merged,
    report: { conflicts, updatedKeys, addedItems: [], removedItems: [] },
  };
}

/**
 * Build a sync envelope for transmitting local state.
 */
export function buildSyncEnvelope(
  deviceId: string,
  registers: readonly LwwRegister[],
  sets: Record<string, readonly string[]> = {},
): SyncEnvelope {
  const maxClock = registers.reduce((m, r) => Math.max(m, r.clock), 0);
  return {
    deviceId,
    clock: maxClock,
    timestamp: Date.now(),
    registers,
    sets,
  };
}
