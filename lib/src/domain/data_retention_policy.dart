import 'package:equatable/equatable.dart';

/// Categories of data subject to retention policies.
enum DataRetentionCategory {
  priceHistory,
  alertHistory,
  tradeJournal,
  auditLog,
  userAnnotations,
  notificationLog,
}

/// Retention policy for a specific data category.
class DataRetentionPolicy extends Equatable {
  const DataRetentionPolicy({
    required this.category,
    required this.retentionDays,
    this.archiveAfterDays,
    this.compressArchive = false,
  });

  final DataRetentionCategory category;

  /// Number of days to keep active data. -1 = keep forever.
  final int retentionDays;

  /// Days before moving to cold/archived storage. Null = never archive.
  final int? archiveAfterDays;

  /// Whether archived data should be compressed.
  final bool compressArchive;

  /// Returns true when data is kept forever.
  bool get isForever => retentionDays == -1;

  /// Returns true when an archive tier is configured.
  bool get hasArchive => archiveAfterDays != null;

  @override
  List<Object?> get props => [
    category,
    retentionDays,
    archiveAfterDays,
    compressArchive,
  ];
}
