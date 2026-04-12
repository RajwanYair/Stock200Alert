import 'package:equatable/equatable.dart';

/// A signal fired when daily price range expands significantly (S464).
class RangeExpansionSignal extends Equatable {
  const RangeExpansionSignal({
    required this.ticker,
    required this.currentRange,
    required this.averageRange,
    required this.expansionMultiple,
    this.isBullishExpansion = true,
  });

  final String ticker;

  /// Today's high − low range in absolute price.
  final double currentRange;

  /// Average range over the lookback period.
  final double averageRange;

  /// Ratio of current range to average range.
  final double expansionMultiple;

  /// True when price closed in the upper half of the range.
  final bool isBullishExpansion;

  bool get isBearishExpansion => !isBullishExpansion;
  bool get isSignificant => expansionMultiple >= 2.0;
  bool get isExtreme => expansionMultiple >= 3.0;

  @override
  List<Object?> get props => [
    ticker,
    currentRange,
    averageRange,
    expansionMultiple,
    isBullishExpansion,
  ];
}
