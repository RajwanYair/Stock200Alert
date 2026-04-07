/// Earnings Calendar — domain entities and date-proximity helpers.
library;

import 'package:equatable/equatable.dart';

/// A scheduled earnings release.
class EarningsEvent extends Equatable {
  const EarningsEvent({
    required this.ticker,
    required this.reportDate,
    required this.estimatedEps,
    this.actualEps,
    this.fiscalQuarter = '',
    this.timing = EarningsTiming.unknown,
  });

  final String ticker;
  final DateTime reportDate;
  final double? estimatedEps;
  final double? actualEps;
  final String fiscalQuarter;
  final EarningsTiming timing;

  /// Whether actual results have been reported.
  bool get isReported => actualEps != null;

  /// EPS surprise (actual − estimate). Null if not yet reported.
  double? get epsSurprise {
    if (actualEps == null || estimatedEps == null) return null;
    return actualEps! - estimatedEps!;
  }

  /// EPS surprise as a percentage of the estimate. Null if not available.
  double? get epsSurprisePct {
    if (estimatedEps == null || estimatedEps == 0 || actualEps == null) {
      return null;
    }
    return ((actualEps! - estimatedEps!) / estimatedEps!.abs()) * 100;
  }

  @override
  List<Object?> get props => [
    ticker,
    reportDate,
    estimatedEps,
    actualEps,
    fiscalQuarter,
    timing,
  ];
}

/// When during the trading day the earnings are released.
enum EarningsTiming { beforeOpen, afterClose, unknown }

/// Result of checking upcoming earnings proximity.
class EarningsProximity extends Equatable {
  const EarningsProximity({
    required this.ticker,
    required this.daysUntilEarnings,
    required this.nextEarningsDate,
    required this.isWithinAlertWindow,
  });

  final String ticker;
  final int daysUntilEarnings;
  final DateTime nextEarningsDate;

  /// True if earnings are within the alert window (e.g. 7 days).
  final bool isWithinAlertWindow;

  @override
  List<Object?> get props => [
    ticker,
    daysUntilEarnings,
    nextEarningsDate,
    isWithinAlertWindow,
  ];
}

/// Computes earnings proximity and upcoming schedule.
class EarningsCalendarCalculator {
  const EarningsCalendarCalculator({this.alertWindowDays = 7});

  /// Number of calendar days before earnings to flag proximity.
  final int alertWindowDays;

  /// Find the next upcoming earnings for [ticker].
  /// Returns `null` if no future events exist.
  EarningsProximity? nextEarnings({
    required String ticker,
    required List<EarningsEvent> events,
    required DateTime asOf,
  }) {
    final future =
        events
            .where(
              (EarningsEvent e) =>
                  e.ticker == ticker && !e.reportDate.isBefore(asOf),
            )
            .toList()
          ..sort(
            (EarningsEvent a, EarningsEvent b) =>
                a.reportDate.compareTo(b.reportDate),
          );

    if (future.isEmpty) return null;

    final next = future.first;
    final days = next.reportDate.difference(asOf).inDays;

    return EarningsProximity(
      ticker: ticker,
      daysUntilEarnings: days,
      nextEarningsDate: next.reportDate,
      isWithinAlertWindow: days <= alertWindowDays,
    );
  }

  /// Get all tickers with earnings in the next [days] calendar days.
  List<EarningsProximity> upcomingEarnings({
    required List<EarningsEvent> events,
    required DateTime asOf,
    int days = 7,
  }) {
    final cutoff = asOf.add(Duration(days: days));
    final tickers = <String>{};
    final results = <EarningsProximity>[];

    final sorted =
        events
            .where(
              (EarningsEvent e) =>
                  !e.reportDate.isBefore(asOf) && e.reportDate.isBefore(cutoff),
            )
            .toList()
          ..sort(
            (EarningsEvent a, EarningsEvent b) =>
                a.reportDate.compareTo(b.reportDate),
          );

    for (final EarningsEvent event in sorted) {
      if (tickers.contains(event.ticker)) continue;
      tickers.add(event.ticker);

      final d = event.reportDate.difference(asOf).inDays;
      results.add(
        EarningsProximity(
          ticker: event.ticker,
          daysUntilEarnings: d,
          nextEarningsDate: event.reportDate,
          isWithinAlertWindow: d <= alertWindowDays,
        ),
      );
    }
    return results;
  }
}
