/**
 * UI date-format re-exports from core (R8).
 *
 * All formatting logic now lives in `core/date-format.ts` so it can be
 * used from domain and worker layers. This file re-exports for backward
 * compatibility with existing UI imports.
 */
export {
  formatDate,
  isoDate,
  isoTime,
  isoDateTime,
  parseIsoDate,
  relativeTime,
  isWeekday,
  previousWeekday,
  nextWeekday,
  tradingDaysBetween,
} from "../core/date-format";
