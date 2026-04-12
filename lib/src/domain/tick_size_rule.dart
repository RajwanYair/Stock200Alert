import 'package:equatable/equatable.dart';

/// Exchange tick size rule for a price range (S505).
class TickSizeRule extends Equatable {
  const TickSizeRule({
    required this.ruleId,
    required this.exchange,
    required this.minPrice,
    required this.maxPrice,
    required this.tickSizeUsd,
  });

  final String ruleId;
  final String exchange;

  /// Lower bound of the price range this rule applies to.
  final double minPrice;

  /// Upper bound of the price range (use double.infinity for no upper limit).
  final double maxPrice;

  /// Minimum price increment in USD.
  final double tickSizeUsd;

  bool get appliesToPennies => tickSizeUsd < 0.01;
  bool get isSubPenny => tickSizeUsd < 0.01;

  /// Returns true if [price] falls within the applicable range.
  bool appliesTo(double price) => price >= minPrice && price < maxPrice;

  @override
  List<Object?> get props => [
    ruleId,
    exchange,
    minPrice,
    maxPrice,
    tickSizeUsd,
  ];
}
