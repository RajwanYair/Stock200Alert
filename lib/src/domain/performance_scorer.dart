/// Performance Scorer — measures and scores application performance metrics.
///
/// Tracks refresh times, data load latency, and UI responsiveness
/// to produce a composite 0–100 performance score.
library;

import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// A single timing sample.
class PerformanceSample extends Equatable {
  const PerformanceSample({
    required this.operation,
    required this.durationMs,
    required this.timestamp,
  });

  final String operation;
  final int durationMs;
  final DateTime timestamp;

  @override
  List<Object?> get props => [operation, durationMs, timestamp];
}

/// Statistical summary for one operation type.
class OperationStats extends Equatable {
  const OperationStats({
    required this.operation,
    required this.count,
    required this.meanMs,
    required this.medianMs,
    required this.p95Ms,
    required this.maxMs,
  });

  final String operation;
  final int count;
  final double meanMs;
  final double medianMs;
  final double p95Ms;
  final int maxMs;

  @override
  List<Object?> get props => [operation, count, meanMs, medianMs, p95Ms, maxMs];
}

/// Composite performance score result.
class PerformanceScore extends Equatable {
  const PerformanceScore({
    required this.overallScore,
    required this.refreshScore,
    required this.dataLoadScore,
    required this.operationStats,
    required this.sampleCount,
  });

  /// Composite 0–100 score (100 = excellent).
  final double overallScore;

  /// Refresh-cycle score component.
  final double refreshScore;

  /// Data-load latency score component.
  final double dataLoadScore;

  /// Per-operation statistics.
  final List<OperationStats> operationStats;

  final int sampleCount;

  /// 'EXCELLENT', 'GOOD', 'FAIR', or 'POOR'.
  String get rating => switch (overallScore) {
    >= 80 => 'EXCELLENT',
    >= 60 => 'GOOD',
    >= 40 => 'FAIR',
    _ => 'POOR',
  };

  @override
  List<Object?> get props => [
    overallScore,
    refreshScore,
    dataLoadScore,
    operationStats,
    sampleCount,
  ];
}

/// Computes performance scores from timing samples.
class PerformanceScorer {
  const PerformanceScorer();

  /// Score all performance samples.
  PerformanceScore score(List<PerformanceSample> samples) {
    if (samples.isEmpty) {
      return const PerformanceScore(
        overallScore: 100,
        refreshScore: 100,
        dataLoadScore: 100,
        operationStats: [],
        sampleCount: 0,
      );
    }

    // Group by operation
    final grouped = <String, List<int>>{};
    for (final PerformanceSample s in samples) {
      grouped.putIfAbsent(s.operation, () => []).add(s.durationMs);
    }

    final stats = <OperationStats>[];
    for (final MapEntry<String, List<int>> entry in grouped.entries) {
      stats.add(_computeStats(entry.key, entry.value));
    }

    final refreshScore = _scoreOperation(grouped['refresh']);
    final dataLoadScore = _scoreOperation(grouped['dataLoad']);

    final overall = (refreshScore + dataLoadScore) / 2;

    return PerformanceScore(
      overallScore: overall,
      refreshScore: refreshScore,
      dataLoadScore: dataLoadScore,
      operationStats: stats,
      sampleCount: samples.length,
    );
  }

  double _scoreOperation(List<int>? durations) {
    if (durations == null || durations.isEmpty) return 100;

    final sorted = durations.toList()..sort();
    final p95Index = (sorted.length * 0.95).floor().clamp(0, sorted.length - 1);
    final p95 = sorted[p95Index];

    // Default target 3000ms
    const target = 3000;
    if (p95 <= target) return 100;
    if (p95 >= target * 3) return 0;
    return ((1 - (p95 - target) / (target * 2)) * 100).clamp(0, 100);
  }

  OperationStats _computeStats(String operation, List<int> durations) {
    final sorted = durations.toList()..sort();
    final count = sorted.length;
    final mean = sorted.fold<int>(0, (int a, int b) => a + b) / count;
    final median = count.isOdd
        ? sorted[count ~/ 2].toDouble()
        : (sorted[count ~/ 2 - 1] + sorted[count ~/ 2]) / 2;
    final p95Index = math.min((count * 0.95).floor(), count - 1);

    return OperationStats(
      operation: operation,
      count: count,
      meanMs: mean,
      medianMs: median,
      p95Ms: sorted[p95Index].toDouble(),
      maxMs: sorted.last,
    );
  }
}
