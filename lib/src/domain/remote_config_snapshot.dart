import 'package:equatable/equatable.dart';

/// Remote feature configuration snapshot fetched at runtime (S547).
class RemoteConfigSnapshot extends Equatable {
  const RemoteConfigSnapshot({
    required this.snapshotId,
    required this.fetchedAtMs,
    required this.configVersion,
    required this.values,
    this.isFallback = false,
  });

  final String snapshotId;

  /// Epoch milliseconds when config was fetched from the server.
  final int fetchedAtMs;
  final String configVersion;

  /// Key-value config pairs (all values serialised as strings).
  final Map<String, String> values;

  /// True when using cached/fallback config due to fetch failure.
  final bool isFallback;

  bool get isEmpty => values.isEmpty;
  bool get isFresh => !isFallback;
  int get entryCount => values.length;

  @override
  List<Object?> get props => [
    snapshotId,
    fetchedAtMs,
    configVersion,
    values,
    isFallback,
  ];
}
