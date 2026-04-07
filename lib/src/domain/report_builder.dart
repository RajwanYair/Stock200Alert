/// Report Builder — domain model for generating structured report data.
///
/// This is the domain-side representation, not the rendering layer.
/// Rendering to PDF/HTML happens in the application or presentation layer.
library;

import 'package:equatable/equatable.dart';

/// A complete report ready for rendering.
class TickerReport extends Equatable {
  const TickerReport({
    required this.ticker,
    required this.generatedAt,
    required this.sections,
    required this.metadata,
  });

  final String ticker;
  final DateTime generatedAt;
  final List<ReportSection> sections;
  final ReportMetadata metadata;

  @override
  List<Object?> get props => [ticker, generatedAt, sections, metadata];
}

/// One section of the report (e.g. "Technical Summary", "Signal History").
class ReportSection extends Equatable {
  const ReportSection({required this.title, required this.rows});

  final String title;
  final List<ReportRow> rows;

  @override
  List<Object?> get props => [title, rows];
}

/// A key-value row within a report section.
class ReportRow extends Equatable {
  const ReportRow({
    required this.label,
    required this.value,
    this.annotation = '',
  });

  final String label;
  final String value;

  /// Optional annotation (e.g. '▲' or '▼' or color hint).
  final String annotation;

  @override
  List<Object?> get props => [label, value, annotation];
}

/// Metadata about the report generation.
class ReportMetadata extends Equatable {
  const ReportMetadata({
    required this.dataRange,
    required this.candleCount,
    required this.providerName,
  });

  /// Human-readable date range (e.g. "2024-01-01 to 2025-04-07").
  final String dataRange;
  final int candleCount;
  final String providerName;

  @override
  List<Object?> get props => [dataRange, candleCount, providerName];
}

/// Builds a [TickerReport] from pre-computed analysis data.
class ReportBuilder {
  const ReportBuilder();

  /// Build a summary report for a ticker.
  TickerReport build({
    required String ticker,
    required DateTime generatedAt,
    required Map<String, String> technicalIndicators,
    required Map<String, String> signalHistory,
    required Map<String, String> riskMetrics,
    required ReportMetadata metadata,
  }) {
    final sections = <ReportSection>[
      ReportSection(
        title: 'Technical Indicators',
        rows: technicalIndicators.entries
            .map(
              (MapEntry<String, String> e) =>
                  ReportRow(label: e.key, value: e.value),
            )
            .toList(),
      ),
      ReportSection(
        title: 'Signal History',
        rows: signalHistory.entries
            .map(
              (MapEntry<String, String> e) =>
                  ReportRow(label: e.key, value: e.value),
            )
            .toList(),
      ),
      ReportSection(
        title: 'Risk Metrics',
        rows: riskMetrics.entries
            .map(
              (MapEntry<String, String> e) =>
                  ReportRow(label: e.key, value: e.value),
            )
            .toList(),
      ),
    ];

    return TickerReport(
      ticker: ticker,
      generatedAt: generatedAt,
      sections: sections,
      metadata: metadata,
    );
  }
}
