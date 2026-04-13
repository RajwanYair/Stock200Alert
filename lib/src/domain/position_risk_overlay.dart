import 'package:equatable/equatable.dart';

/// Position risk overlay — declarative risk boundary overlay per position.
enum RiskOverlayType {
  stopLoss,
  takeProfit,
  maxDrawdown,
  marginCall,
  volatilityBreak,
}

class PositionRiskOverlay extends Equatable {
  const PositionRiskOverlay({
    required this.ticker,
    required this.overlayType,
    required this.triggerPrice,
    required this.currentPrice,
    required this.isActive,
  });

  final String ticker;
  final RiskOverlayType overlayType;
  final double triggerPrice;
  final double currentPrice;
  final bool isActive;

  PositionRiskOverlay copyWith({
    String? ticker,
    RiskOverlayType? overlayType,
    double? triggerPrice,
    double? currentPrice,
    bool? isActive,
  }) => PositionRiskOverlay(
    ticker: ticker ?? this.ticker,
    overlayType: overlayType ?? this.overlayType,
    triggerPrice: triggerPrice ?? this.triggerPrice,
    currentPrice: currentPrice ?? this.currentPrice,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    ticker,
    overlayType,
    triggerPrice,
    currentPrice,
    isActive,
  ];
}
