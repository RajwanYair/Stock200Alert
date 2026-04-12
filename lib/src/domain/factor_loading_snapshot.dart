import 'package:equatable/equatable.dart';

/// Multi-factor model loading snapshot for a security (S532).
class FactorLoadingSnapshot extends Equatable {
  const FactorLoadingSnapshot({
    required this.ticker,
    required this.modelName,
    required this.marketBeta,
    required this.sizeBeta,
    required this.valueBeta,
    required this.momentumBeta,
    required this.qualityBeta,
    required this.specificRiskPercent,
  });

  final String ticker;

  /// Factor model name, e.g. 'Fama-French 5', 'Barra US'.
  final String modelName;
  final double marketBeta;
  final double sizeBeta;
  final double valueBeta;
  final double momentumBeta;
  final double qualityBeta;

  /// Idiosyncratic (specific) risk as % of total variance.
  final double specificRiskPercent;

  bool get isHighMarketBeta => marketBeta >= 1.3;
  bool get isSmallCapTilted => sizeBeta <= -0.3;
  bool get isHighSpecificRisk => specificRiskPercent >= 40;

  @override
  List<Object?> get props => [
    ticker,
    modelName,
    marketBeta,
    sizeBeta,
    valueBeta,
    momentumBeta,
    qualityBeta,
    specificRiskPercent,
  ];
}
