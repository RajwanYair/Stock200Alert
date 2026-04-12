import 'package:equatable/equatable.dart';

/// Roll-up of all active technical method alerts for a single ticker.
class TechnicalAlertSummary extends Equatable {
  const TechnicalAlertSummary({
    required this.ticker,
    required this.activeBuyAlerts,
    required this.activeSellAlerts,
    required this.methodNames,
    required this.consensusBuy,
    required this.consensusSell,
    required this.summarisedAt,
  });

  final String ticker;

  /// Number of currently active BUY signals across all methods.
  final int activeBuyAlerts;

  /// Number of currently active SELL signals across all methods.
  final int activeSellAlerts;

  /// Methods contributing at least one active alert.
  final List<String> methodNames;

  /// `true` when the consensus engine has issued a BUY consensus.
  final bool consensusBuy;

  /// `true` when the consensus engine has issued a SELL consensus.
  final bool consensusSell;

  final DateTime summarisedAt;

  TechnicalAlertSummary copyWith({
    String? ticker,
    int? activeBuyAlerts,
    int? activeSellAlerts,
    List<String>? methodNames,
    bool? consensusBuy,
    bool? consensusSell,
    DateTime? summarisedAt,
  }) => TechnicalAlertSummary(
    ticker: ticker ?? this.ticker,
    activeBuyAlerts: activeBuyAlerts ?? this.activeBuyAlerts,
    activeSellAlerts: activeSellAlerts ?? this.activeSellAlerts,
    methodNames: methodNames ?? this.methodNames,
    consensusBuy: consensusBuy ?? this.consensusBuy,
    consensusSell: consensusSell ?? this.consensusSell,
    summarisedAt: summarisedAt ?? this.summarisedAt,
  );

  @override
  List<Object?> get props => [
    ticker,
    activeBuyAlerts,
    activeSellAlerts,
    methodNames,
    consensusBuy,
    consensusSell,
    summarisedAt,
  ];
}
