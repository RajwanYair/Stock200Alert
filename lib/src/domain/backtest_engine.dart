/// Backtest Engine — pure domain service.
///
/// Runs a [BacktestStrategy] against historical candle data and produces
/// a [BacktestResult] with all simulated trades.
library;

import 'backtest_result.dart';
import 'backtest_strategy.dart';
import 'entities.dart';

/// Simulates trading against historical candle data.
class BacktestEngine {
  const BacktestEngine({this.startingEquity = 10000});

  /// Starting equity for the simulation.
  final double startingEquity;

  /// Run [strategy] against [candles] for [ticker].
  ///
  /// Candles must be sorted oldest-first.
  BacktestResult run({
    required String ticker,
    required BacktestStrategy strategy,
    required List<DailyCandle> candles,
    List<String> Function(DailyCandle candle)? signalResolver,
  }) {
    if (candles.length < 2) {
      return BacktestResult(
        ticker: ticker,
        methodName: strategy.name,
        startDate: candles.isEmpty ? DateTime(1970) : candles.first.date,
        endDate: candles.isEmpty ? DateTime(1970) : candles.last.date,
        trades: const [],
        startingEquity: startingEquity,
      );
    }

    final List<BacktestTrade> trades = [];
    double? entryPrice;
    DateTime? entryDate;
    int holdingDays = 0;

    for (int i = 0; i < candles.length; i++) {
      final DailyCandle candle = candles[i];
      final List<String> signals = signalResolver != null
          ? signalResolver(candle)
          : <String>[];

      if (entryPrice == null) {
        // Looking for entry.
        for (final String sig in signals) {
          if (strategy.isEntry(sig)) {
            entryPrice = candle.close;
            entryDate = candle.date;
            holdingDays = 0;
            break;
          }
        }
      } else {
        holdingDays++;
        bool shouldExit = false;
        String exitReason = strategy.name;

        // Check exit signals.
        for (final String sig in signals) {
          if (strategy.isExit(sig)) {
            shouldExit = true;
            break;
          }
        }

        // Check stop-loss.
        if (!shouldExit && strategy.stopLossPct != null) {
          final double lossFromEntry =
              (candle.close - entryPrice) / entryPrice * 100;
          if (lossFromEntry <= -strategy.stopLossPct!) {
            shouldExit = true;
            exitReason = '${strategy.name} (stop-loss)';
          }
        }

        // Check take-profit.
        if (!shouldExit && strategy.takeProfitPct != null) {
          final double gainFromEntry =
              (candle.close - entryPrice) / entryPrice * 100;
          if (gainFromEntry >= strategy.takeProfitPct!) {
            shouldExit = true;
            exitReason = '${strategy.name} (take-profit)';
          }
        }

        // Check max holding period.
        if (!shouldExit && strategy.maxHoldingDays != null) {
          if (holdingDays >= strategy.maxHoldingDays!) {
            shouldExit = true;
            exitReason = '${strategy.name} (max-hold)';
          }
        }

        if (shouldExit) {
          trades.add(
            BacktestTrade(
              entryDate: entryDate!,
              entryPrice: entryPrice,
              exitDate: candle.date,
              exitPrice: candle.close,
              methodName: exitReason,
            ),
          );
          entryPrice = null;
          entryDate = null;
        }
      }
    }

    return BacktestResult(
      ticker: ticker,
      methodName: strategy.name,
      startDate: candles.first.date,
      endDate: candles.last.date,
      trades: trades,
      startingEquity: startingEquity,
    );
  }
}
