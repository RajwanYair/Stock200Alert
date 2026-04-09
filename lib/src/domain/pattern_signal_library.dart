/// Pattern Signal Library — catalog of named historical signal setups with
/// empirical win-rate statistics for AI-assisted pattern recognition (v1.9).
library;

import 'package:equatable/equatable.dart';

/// The trend direction context in which this signal setup is observed.
enum SetupTrendContext {
  /// Setup occurs during an uptrend.
  uptrend,

  /// Setup occurs during a downtrend.
  downtrend,

  /// Setup occurs in a sideways or consolidating market.
  sideways,

  /// Setup is trend-agnostic.
  any,
}

/// Empirical outcome statistics for a [SignalSetup].
class SetupOutcome extends Equatable {
  const SetupOutcome({
    required this.winRate,
    required this.avgGainPct,
    required this.avgLossPct,
    required this.sampleCount,
  }) : assert(
         winRate >= 0.0 && winRate <= 1.0,
         'winRate must be between 0.0 and 1.0',
       ),
       assert(sampleCount >= 0, 'sampleCount must be non-negative');

  /// Fraction of occurrences where the setup led to a profitable outcome.
  final double winRate;

  /// Average percentage gain on winning trades.
  final double avgGainPct;

  /// Average percentage loss on losing trades (magnitude, positive value).
  final double avgLossPct;

  /// Number of historical occurrences used to compute these statistics.
  final int sampleCount;

  /// Expected value per occurrence: (winRate × avgGain) − (lossRate × avgLoss).
  double get expectedValue =>
      winRate * avgGainPct - (1.0 - winRate) * avgLossPct;

  bool get isHighConfidence => winRate >= 0.6 && sampleCount >= 30;

  @override
  List<Object?> get props => [winRate, avgGainPct, avgLossPct, sampleCount];
}

/// A named signal setup combining one or more indicator conditions with
/// historical outcome statistics.
class SignalSetup extends Equatable {
  const SignalSetup({
    required this.id,
    required this.name,
    required this.trendContext,
    required this.outcome,
    required this.conditionSummary,
    this.tags = const [],
  });

  final String id;
  final String name;
  final SetupTrendContext trendContext;
  final SetupOutcome outcome;

  /// Brief human-readable summary of the entry conditions.
  final String conditionSummary;
  final List<String> tags;

  @override
  List<Object?> get props => [
    id,
    name,
    trendContext,
    outcome,
    conditionSummary,
    tags,
  ];
}

/// Immutable catalog of [SignalSetup] entries used by the AI pattern matcher.
class PatternSignalLibrary extends Equatable {
  const PatternSignalLibrary({required this.setups});

  final List<SignalSetup> setups;

  /// Returns all setups that match [context] (including [SetupTrendContext.any]).
  List<SignalSetup> setupsForContext(SetupTrendContext context) => setups
      .where(
        (SignalSetup s) =>
            s.trendContext == context ||
            s.trendContext == SetupTrendContext.any,
      )
      .toList();

  /// Returns all high-confidence setups.
  List<SignalSetup> get highConfidenceSetups =>
      setups.where((SignalSetup s) => s.outcome.isHighConfidence).toList();

  @override
  List<Object?> get props => [setups];
}
