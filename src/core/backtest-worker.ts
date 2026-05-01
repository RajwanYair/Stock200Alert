/**
 * Backtest worker facade — typed helper for spawning the compute worker
 * and calling runBacktest via RPC.
 *
 * Lazily creates one shared worker instance (singleton). Callers should
 * call `disposeBacktestWorker()` on app teardown.
 */
import { createWorkerClient, type WorkerClient } from "./worker-rpc";
import type { ComputeApi } from "./compute-worker";
import type { DailyCandle } from "../types/domain";
import type { BacktestConfig, BacktestResult } from "../domain/backtest-engine";

let _worker: Worker | null = null;
let _client: WorkerClient<ComputeApi> | null = null;

function getClient(): WorkerClient<ComputeApi> {
  if (!_client) {
    _worker = new Worker(new URL("./compute-worker.ts", import.meta.url), {
      type: "module",
    });
    _client = createWorkerClient<ComputeApi>(_worker);
  }
  return _client;
}

/**
 * Run a backtest asynchronously in the compute worker.
 * Falls back to synchronous execution if Worker API is unavailable (SSR/test).
 */
export async function runBacktestAsync(
  config: BacktestConfig,
  candles: readonly DailyCandle[],
): Promise<BacktestResult> {
  if (typeof Worker === "undefined") {
    // Synchronous fallback (e.g. in test environments)
    const { runBacktest } = await import("../domain/backtest-engine");
    return runBacktest(candles, config);
  }
  return getClient().call("runBacktest", config, candles);
}

export function disposeBacktestWorker(): void {
  _client?.terminate();
  _client = null;
  _worker = null;
}
