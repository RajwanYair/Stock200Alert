/// Chart Time Range — pure domain value object.
///
/// Defines standard time ranges for chart display and provides
/// candle filtering logic.
library;

import 'entities.dart';

/// Standard chart time ranges.
enum ChartTimeRange {
  /// Three months of data.
  threeMonths(label: '3M', days: 90),

  /// Six months of data.
  sixMonths(label: '6M', days: 180),

  /// One year of data.
  oneYear(label: '1Y', days: 365),

  /// Two years of data.
  twoYears(label: '2Y', days: 730),

  /// Five years of data.
  fiveYears(label: '5Y', days: 1825),

  /// All available data.
  max(label: 'Max', days: 0);

  const ChartTimeRange({required this.label, required this.days});

  /// Display label for this range.
  final String label;

  /// Approximate number of calendar days. Zero means unbounded.
  final int days;
}

/// Filters candle lists by [ChartTimeRange].
class CandleRangeFilter {
  const CandleRangeFilter();

  /// Return candles within the given [range] relative to [asOf].
  ///
  /// If [range] is [ChartTimeRange.max], all candles are returned.
  /// The returned list preserves the original ordering.
  List<DailyCandle> filter(
    List<DailyCandle> candles,
    ChartTimeRange range, {
    required DateTime asOf,
  }) {
    if (candles.isEmpty || range == ChartTimeRange.max) {
      return candles;
    }
    final DateTime cutoff = asOf.subtract(Duration(days: range.days));
    return candles.where((DailyCandle c) => !c.date.isBefore(cutoff)).toList();
  }
}
