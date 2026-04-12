import 'package:equatable/equatable.dart';

/// A database schema version record (S474).
class DataSchemaVersion extends Equatable {
  const DataSchemaVersion({
    required this.schemaId,
    required this.version,
    required this.minAppVersion,
    required this.tableCount,
    this.isBreakingChange = false,
    this.description = '',
  });

  final String schemaId;
  final int version;

  /// Minimum app version required to support this schema.
  final String minAppVersion;
  final int tableCount;
  final bool isBreakingChange;
  final String description;

  bool get requiresMigration => isBreakingChange;
  bool get hasDescription => description.isNotEmpty;

  @override
  List<Object?> get props => [
    schemaId,
    version,
    minAppVersion,
    tableCount,
    isBreakingChange,
    description,
  ];
}
