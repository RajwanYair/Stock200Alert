/// Alert Event — pure domain value object.
///
/// Structured record of a single alert event, capturing all context
/// needed for analytics and audit.
library;

import 'package:equatable/equatable.dart';

/// A recorded alert event.
class AlertEvent extends Equatable {
  const AlertEvent({
    required this.ticker,
    required this.alertType,
    required this.firedAt,
    required this.price,
    this.sma200,
    this.methodName,
    this.description,
    this.acknowledged = false,
  });

  /// Ticker symbol.
  final String ticker;

  /// The alert type name (e.g. 'michoMethodBuy').
  final String alertType;

  /// When the alert was fired.
  final DateTime firedAt;

  /// Price at the time of alert.
  final double price;

  /// SMA-200 value at the time of alert (if available).
  final double? sma200;

  /// Method that produced the signal.
  final String? methodName;

  /// Human-readable description.
  final String? description;

  /// Whether the user has acknowledged this event.
  final bool acknowledged;

  /// Mark this event as acknowledged.
  AlertEvent acknowledge() => AlertEvent(
    ticker: ticker,
    alertType: alertType,
    firedAt: firedAt,
    price: price,
    sma200: sma200,
    methodName: methodName,
    description: description,
    acknowledged: true,
  );

  /// Convert to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
    'ticker': ticker,
    'alertType': alertType,
    'firedAt': firedAt.toIso8601String(),
    'price': price,
    if (sma200 != null) 'sma200': sma200,
    if (methodName != null) 'methodName': methodName,
    if (description != null) 'description': description,
    'acknowledged': acknowledged,
  };

  @override
  List<Object?> get props => [
    ticker,
    alertType,
    firedAt,
    price,
    sma200,
    methodName,
    description,
    acknowledged,
  ];
}
