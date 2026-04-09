import 'package:equatable/equatable.dart';

/// Algorithm used to group tickers into clusters.
enum ClusteringMethod { kMeans, hierarchical, dbscan }

/// A single correlation cluster containing related tickers.
class CorrelationCluster extends Equatable {
  const CorrelationCluster({
    required this.clusterId,
    required this.tickers,
    required this.avgIntraCorrelation,
    this.label,
  }) : assert(
         avgIntraCorrelation >= -1.0 && avgIntraCorrelation <= 1.0,
         'avgIntraCorrelation must be in [-1, 1]',
       );

  final int clusterId;
  final List<String> tickers;

  /// Mean pairwise Pearson correlation within the cluster.
  final double avgIntraCorrelation;
  final String? label;

  int get size => tickers.length;
  bool get isHighlyCorrelated => avgIntraCorrelation >= 0.7;

  @override
  List<Object?> get props => [clusterId, tickers, avgIntraCorrelation, label];
}

/// Groups a watchlist's tickers into clusters by pairwise correlation.
class TickerCorrelationCluster extends Equatable {
  const TickerCorrelationCluster({
    required this.clusters,
    required this.method,
    required this.computedAt,
    required this.windowDays,
  }) : assert(windowDays >= 2, 'windowDays must be at least 2');

  final List<CorrelationCluster> clusters;
  final ClusteringMethod method;
  final DateTime computedAt;
  final int windowDays;

  /// Returns the cluster that contains [ticker], or `null`.
  CorrelationCluster? clusterFor(String ticker) =>
      clusters.where((c) => c.tickers.contains(ticker)).firstOrNull;

  /// Returns all tickers in the same cluster as [ticker] (excluding itself).
  List<String> peersOf(String ticker) {
    final cluster = clusterFor(ticker);
    if (cluster == null) return const [];
    return cluster.tickers.where((t) => t != ticker).toList();
  }

  @override
  List<Object?> get props => [clusters, method, computedAt, windowDays];
}
