/**
 * OHLCV Transferable helpers (G4).
 *
 * Pack `DailyCandle[]` into a `Float64Array` so it can be sent to the compute
 * worker as a zero-copy `Transferable` instead of a JSON-serialised object
 * graph.
 *
 * Layout (6 float64 values per candle, oldest-first):
 *   [dateMs, open, high, low, close, volume]
 *
 * Packing:
 *   dateMs  = Date.parse(candle.date)   (UTC midnight milliseconds)
 *   volume  = stored as float64 (Stooq volumes fit without precision loss
 *             up to ~9 × 10^15, well above any real equity volume)
 *
 * Transferring the buffer to the worker:
 *   const buf = candlesToBuffer(candles);
 *   worker.postMessage({ buf }, [buf.buffer]);   // zero-copy
 *
 * In the worker, reconstruct with:
 *   const candles = bufferToCandles(buf);
 */
import type { DailyCandle } from "../types/domain";

/** Number of float64 values stored per candle. */
export const OHLCV_STRIDE = 6;

/**
 * Pack an array of DailyCandles into a flat `Float64Array` suitable for
 * zero-copy transfer to a Web Worker.
 */
export function candlesToBuffer(candles: readonly DailyCandle[]): Float64Array {
  const buf = new Float64Array(candles.length * OHLCV_STRIDE);
  for (let i = 0; i < candles.length; i++) {
    const c = candles[i]!;
    const base = i * OHLCV_STRIDE;
    buf[base] = Date.parse(c.date);
    buf[base + 1] = c.open;
    buf[base + 2] = c.high;
    buf[base + 3] = c.low;
    buf[base + 4] = c.close;
    buf[base + 5] = c.volume;
  }
  return buf;
}

/**
 * Reconstruct a `DailyCandle[]` array from a packed `Float64Array`.
 * Inverse of `candlesToBuffer`.
 */
export function bufferToCandles(buf: Float64Array): DailyCandle[] {
  const n = Math.floor(buf.length / OHLCV_STRIDE);
  const candles: DailyCandle[] = [];
  for (let i = 0; i < n; i++) {
    const base = i * OHLCV_STRIDE;
    candles.push({
      date: new Date(buf[base]!).toISOString().slice(0, 10),
      open: buf[base + 1]!,
      high: buf[base + 2]!,
      low: buf[base + 3]!,
      close: buf[base + 4]!,
      volume: buf[base + 5]!,
    });
  }
  return candles;
}
