import 'package:equatable/equatable.dart';

/// Direction of the earnings surprise.
enum EarningsSurpriseDirection { beat, miss, inline }

/// Records the actual EPS result vs. the analyst consensus estimate
/// for a single ticker's earnings event.
class EarningsSurpriseRecord extends Equatable {
  const EarningsSurpriseRecord({
    required this.ticker,
    required this.fiscalQuarter,
    required this.actualEps,
    required this.estimatedEps,
    required this.surprisePercent,
    required this.direction,
    required this.reportedAt,
  });

  final String ticker;

  /// e.g. "Q3 2025"
  final String fiscalQuarter;

  final double actualEps;
  final double estimatedEps;

  /// (actual - estimate) / |estimate| × 100
  final double surprisePercent;

  final EarningsSurpriseDirection direction;
  final DateTime reportedAt;

  EarningsSurpriseRecord copyWith({
    String? ticker,
    String? fiscalQuarter,
    double? actualEps,
    double? estimatedEps,
    double? surprisePercent,
    EarningsSurpriseDirection? direction,
    DateTime? reportedAt,
  }) => EarningsSurpriseRecord(
    ticker: ticker ?? this.ticker,
    fiscalQuarter: fiscalQuarter ?? this.fiscalQuarter,
    actualEps: actualEps ?? this.actualEps,
    estimatedEps: estimatedEps ?? this.estimatedEps,
    surprisePercent: surprisePercent ?? this.surprisePercent,
    direction: direction ?? this.direction,
    reportedAt: reportedAt ?? this.reportedAt,
  );

  @override
  List<Object?> get props => [
    ticker,
    fiscalQuarter,
    actualEps,
    estimatedEps,
    surprisePercent,
    direction,
    reportedAt,
  ];
}
