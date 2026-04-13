import 'package:equatable/equatable.dart';

/// Alert batching config — digest window and sizing for alert delivery.
enum BatchingStrategy { immediate, digest, quiet, smart }

class AlertBatchingConfig extends Equatable {
  const AlertBatchingConfig({
    required this.profileId,
    required this.strategy,
    required this.batchWindowMinutes,
    required this.maxBatchSize,
    required this.isEnabled,
  });

  final String profileId;
  final BatchingStrategy strategy;
  final int batchWindowMinutes;
  final int maxBatchSize;
  final bool isEnabled;

  AlertBatchingConfig copyWith({
    String? profileId,
    BatchingStrategy? strategy,
    int? batchWindowMinutes,
    int? maxBatchSize,
    bool? isEnabled,
  }) => AlertBatchingConfig(
    profileId: profileId ?? this.profileId,
    strategy: strategy ?? this.strategy,
    batchWindowMinutes: batchWindowMinutes ?? this.batchWindowMinutes,
    maxBatchSize: maxBatchSize ?? this.maxBatchSize,
    isEnabled: isEnabled ?? this.isEnabled,
  );

  @override
  List<Object?> get props => [
    profileId,
    strategy,
    batchWindowMinutes,
    maxBatchSize,
    isEnabled,
  ];
}
