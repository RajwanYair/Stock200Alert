import 'package:equatable/equatable.dart';

/// A single broker account's position in a ticker.
class BrokerPositionEntry extends Equatable {
  /// Creates a [BrokerPositionEntry].
  const BrokerPositionEntry({
    required this.brokerId,
    required this.brokerName,
    required this.quantity,
    required this.averageCost,
  });

  /// Broker account identifier.
  final String brokerId;

  /// Human-readable broker name.
  final String brokerName;

  /// Number of shares held at this broker.
  final double quantity;

  /// Average cost per share at this broker.
  final double averageCost;

  /// Total cost basis for this broker position.
  double get totalCost => quantity * averageCost;

  @override
  List<Object?> get props => [brokerId, brokerName, quantity, averageCost];
}

/// Aggregated view of a ticker's position across multiple broker accounts.
class MultiBrokerPosition extends Equatable {
  /// Creates a [MultiBrokerPosition].
  const MultiBrokerPosition({
    required this.ticker,
    required this.brokerPositions,
  });

  /// Ticker symbol.
  final String ticker;

  /// Individual position entry per broker account.
  final List<BrokerPositionEntry> brokerPositions;

  /// Total shares across all brokers.
  double get totalQuantity => brokerPositions.fold(
    0.0,
    (double sum, BrokerPositionEntry b) => sum + b.quantity,
  );

  /// Total cost basis across all brokers.
  double get totalCost => brokerPositions.fold(
    0.0,
    (double sum, BrokerPositionEntry b) => sum + b.totalCost,
  );

  /// Number of distinct broker accounts.
  int get brokerCount => brokerPositions.length;

  /// Returns `true` when there is more than one broker.
  bool get isSpread => brokerCount > 1;

  @override
  List<Object?> get props => [ticker, brokerPositions];
}
