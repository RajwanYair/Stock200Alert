import 'package:equatable/equatable.dart';

/// Data quality tier for a lineage record.
enum DataQualityTier { raw, validated, enriched, canonical }

/// Tracks the provenance and transformation lineage of a data record
/// through the data pipeline stages.
class DataLineageRecord extends Equatable {
  const DataLineageRecord({
    required this.recordId,
    required this.sourceProvider,
    required this.ticker,
    required this.qualityTier,
    required this.transformationSteps,
    required this.checksum,
    required this.ingestedAt,
  });

  final String recordId;
  final String sourceProvider;
  final String ticker;
  final DataQualityTier qualityTier;

  /// Ordered list of transformation stage names applied to the data.
  final List<String> transformationSteps;

  /// SHA-256 checksum of the canonical record for deduplication.
  final String checksum;

  final DateTime ingestedAt;

  DataLineageRecord copyWith({
    String? recordId,
    String? sourceProvider,
    String? ticker,
    DataQualityTier? qualityTier,
    List<String>? transformationSteps,
    String? checksum,
    DateTime? ingestedAt,
  }) => DataLineageRecord(
    recordId: recordId ?? this.recordId,
    sourceProvider: sourceProvider ?? this.sourceProvider,
    ticker: ticker ?? this.ticker,
    qualityTier: qualityTier ?? this.qualityTier,
    transformationSteps: transformationSteps ?? this.transformationSteps,
    checksum: checksum ?? this.checksum,
    ingestedAt: ingestedAt ?? this.ingestedAt,
  );

  @override
  List<Object?> get props => [
    recordId,
    sourceProvider,
    ticker,
    qualityTier,
    transformationSteps,
    checksum,
    ingestedAt,
  ];
}
