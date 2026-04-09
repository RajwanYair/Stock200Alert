/// Data Export Manifest — defines the scope, format, and field selection for
/// a bulk data export operation (v1.7 export features).
library;

import 'package:equatable/equatable.dart';

/// Output format for the exported data.
enum ExportFormat {
  /// Comma-separated values.
  csv,

  /// JSON array of objects.
  json,

  /// Newline-delimited JSON (one object per line).
  ndjson,

  /// Parquet columnar format (for large datasets).
  parquet,
}

/// A field that can be included in an export.
enum ExportField {
  /// ISO-8601 date string.
  date,

  /// Ticker symbol.
  ticker,

  /// Closing price.
  closePrice,

  /// Volume.
  volume,

  /// SMA50 value.
  sma50,

  /// SMA150 value.
  sma150,

  /// SMA200 value.
  sma200,

  /// RSI value.
  rsi,

  /// MACD histogram value.
  macd,

  /// Alert type fired, if any.
  alertType,

  /// Consensus engine decision.
  consensusDecision,
}

/// Defines what to export, in which format, and over which date range.
class DataExportManifest extends Equatable {
  const DataExportManifest({
    required this.tickers,
    required this.fields,
    required this.format,
    required this.fromDate,
    required this.toDate,
    this.includeHeaders = true,
  }) : assert(tickers.length > 0, 'At least one ticker is required');

  final List<String> tickers;
  final List<ExportField> fields;
  final ExportFormat format;
  final DateTime fromDate;
  final DateTime toDate;

  /// For CSV: whether to include a header row.
  final bool includeHeaders;

  /// Duration covered by this export.
  Duration get dateRange => toDate.difference(fromDate);

  /// Estimated row count = tickers × trading days in range (approx 252/year).
  int get estimatedRowCount {
    final int days = dateRange.inDays;
    final int tradingDays = (days * 252 ~/ 365).clamp(0, days);
    return tickers.length * tradingDays;
  }

  @override
  List<Object?> get props => [
    tickers,
    fields,
    format,
    fromDate,
    toDate,
    includeHeaders,
  ];
}
