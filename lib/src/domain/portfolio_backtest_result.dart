import 'package:equatable/equatable.dart';

/// A single executed trade within a portfolio backtest.
class PortfolioBacktestTrade extends Equatable {
  const PortfolioBacktestTrade({
    required this.ticker,
    required this.entryDate,
    required this.exitDate,
    required this.entryPrice,
    required this.exitPrice,
    required this.shares,
  }) : assert(shares > 0, 'shares must be positive');

  final String ticker;
  final DateTime entryDate;
  final DateTime exitDate;
  final double entryPrice;
  final double exitPrice;
  final double shares;

  double get pnl => (exitPrice - entryPrice) * shares;
  double get returnPct => (exitPrice - entryPrice) / entryPrice;
  bool get isWin => pnl > 0;

  @override
  List<Object?> get props => [
    ticker,
    entryDate,
    exitDate,
    entryPrice,
    exitPrice,
    shares,
  ];
}

/// Point on the portfolio equity curve.
class PortfolioEquityPoint extends Equatable {
  const PortfolioEquityPoint({required this.date, required this.equity});

  final DateTime date;
  final double equity;

  @override
  List<Object?> get props => [date, equity];
}

/// Full result of a multi-ticker portfolio backtest.
class PortfolioBacktestResult extends Equatable {
  const PortfolioBacktestResult({
    required this.tickers,
    required this.trades,
    required this.equityCurve,
    required this.initialCapital,
    required this.fromDate,
    required this.toDate,
  }) : assert(initialCapital > 0, 'initialCapital must be positive');

  final List<String> tickers;
  final List<PortfolioBacktestTrade> trades;
  final List<PortfolioEquityPoint> equityCurve;
  final double initialCapital;
  final DateTime fromDate;
  final DateTime toDate;

  double get finalEquity =>
      equityCurve.isEmpty ? initialCapital : equityCurve.last.equity;

  double get totalReturn => (finalEquity - initialCapital) / initialCapital;

  double get winRate {
    if (trades.isEmpty) return 0.0;
    return trades.where((t) => t.isWin).length / trades.length;
  }

  double get peakEquity => equityCurve.isEmpty
      ? initialCapital
      : equityCurve.map((p) => p.equity).reduce((a, b) => a > b ? a : b);

  double get maxDrawdown {
    if (equityCurve.isEmpty) return 0.0;
    var peak = equityCurve.first.equity;
    var maxDd = 0.0;
    for (final PortfolioEquityPoint p in equityCurve) {
      if (p.equity > peak) peak = p.equity;
      final dd = (peak - p.equity) / peak;
      if (dd > maxDd) maxDd = dd;
    }
    return maxDd;
  }

  @override
  List<Object?> get props => [
    tickers,
    trades,
    equityCurve,
    initialCapital,
    fromDate,
    toDate,
  ];
}
