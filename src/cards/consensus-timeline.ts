/**
 * Consensus History Timeline — tracks consensus direction over time.
 *
 * Stores snapshots and renders a visual timeline of BUY/SELL/NEUTRAL transitions.
 */
import type { SignalDirection } from "../types/domain";

export interface ConsensusSnapshot {
  readonly ticker: string;
  readonly direction: SignalDirection;
  readonly strength: number; // 0-1
  readonly timestamp: string; // ISO 8601
}

/**
 * Detect direction changes in a sorted (ascending) timeline.
 */
export function detectTransitions(
  snapshots: readonly ConsensusSnapshot[],
): { from: SignalDirection; to: SignalDirection; at: string }[] {
  const transitions: { from: SignalDirection; to: SignalDirection; at: string }[] = [];
  for (let i = 1; i < snapshots.length; i++) {
    if (snapshots[i].direction !== snapshots[i - 1].direction) {
      transitions.push({
        from: snapshots[i - 1].direction,
        to: snapshots[i].direction,
        at: snapshots[i].timestamp,
      });
    }
  }
  return transitions;
}

/**
 * Compute streak length — how many consecutive snapshots have the same direction as the latest.
 */
export function currentStreak(snapshots: readonly ConsensusSnapshot[]): number {
  if (snapshots.length === 0) return 0;
  const last = snapshots[snapshots.length - 1].direction;
  let count = 0;
  for (let i = snapshots.length - 1; i >= 0; i--) {
    if (snapshots[i].direction !== last) break;
    count++;
  }
  return count;
}

/**
 * Render the consensus timeline into a container.
 */
export function renderConsensusTimeline(
  container: HTMLElement,
  ticker: string,
  snapshots: readonly ConsensusSnapshot[],
): void {
  if (snapshots.length === 0) {
    container.innerHTML = `<p class="empty-state">No consensus history for ${escapeHtml(ticker)}.</p>`;
    return;
  }

  const streak = currentStreak(snapshots);
  const latest = snapshots[snapshots.length - 1];
  const transitions = detectTransitions(snapshots);

  const dots = snapshots
    .map((s) => {
      const cls =
        s.direction === "BUY" ? "dot-buy" : s.direction === "SELL" ? "dot-sell" : "dot-neutral";
      const strengthPct = (s.strength * 100).toFixed(0);
      return `<span class="timeline-dot ${cls}" title="${escapeAttr(s.timestamp)} ${s.direction} ${strengthPct}%"></span>`;
    })
    .join("");

  container.innerHTML = `
    <div class="consensus-timeline" aria-label="Consensus timeline for ${escapeAttr(ticker)}">
      <div class="timeline-header">
        <h4>${escapeHtml(ticker)}</h4>
        <span class="badge badge-${latest.direction.toLowerCase()}">${latest.direction}</span>
        <span class="text-secondary">${streak}-day streak</span>
      </div>
      <div class="timeline-track">${dots}</div>
      <p class="text-secondary">${transitions.length} transition${transitions.length !== 1 ? "s" : ""} over ${snapshots.length} snapshots</p>
    </div>
  `;
}

function escapeHtml(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function escapeAttr(s: string): string {
  return escapeHtml(s).replace(/"/g, "&quot;");
}
