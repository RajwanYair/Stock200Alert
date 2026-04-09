import 'package:equatable/equatable.dart';

/// Major exchanges used in holiday lookups.
enum TradingExchange { nyse, nasdaq, lse, tsx, asx, euronext, hkex }

/// A single market holiday for a specific exchange.
class MarketHoliday extends Equatable {
  const MarketHoliday({
    required this.exchange,
    required this.date,
    required this.name,
  });

  final TradingExchange exchange;
  final DateTime date;
  final String name;

  @override
  List<Object?> get props => [exchange, date, name];
}

/// A calendar of market holidays indexed by exchange.
class MarketHolidayCalendar extends Equatable {
  const MarketHolidayCalendar({required this.holidays});

  final List<MarketHoliday> holidays;

  /// Returns `true` if [date] is a holiday for [exchange].
  bool isHoliday(TradingExchange exchange, DateTime date) => holidays.any(
    (h) =>
        h.exchange == exchange &&
        h.date.year == date.year &&
        h.date.month == date.month &&
        h.date.day == date.day,
  );

  /// All holidays for a given [exchange].
  List<MarketHoliday> holidaysFor(TradingExchange exchange) =>
      holidays.where((h) => h.exchange == exchange).toList();

  /// Count of holidays for [exchange] within [from]..[to] (inclusive).
  int holidayCountInRange(
    TradingExchange exchange,
    DateTime from,
    DateTime to,
  ) => holidays
      .where(
        (h) =>
            h.exchange == exchange &&
            !h.date.isBefore(from) &&
            !h.date.isAfter(to),
      )
      .length;

  @override
  List<Object?> get props => [holidays];
}
