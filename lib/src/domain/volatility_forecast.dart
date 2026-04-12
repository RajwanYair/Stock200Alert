import 'package:equatable/equatable.dart';

/// Method used to produce the volatility forecast (S455).
enum VolatilityForecastMethod { garch, ewma, historicalSimulation, impliedVol }

/// Short-term realized volatility forecast for a ticker (S455).
class VolatilityForecast extends Equatable {
  const VolatilityForecast({
    required this.ticker,
    required this.forecastHorizonDays,
    required this.forecastedAnnualizedVol,
    required this.currentRealizedVol,
    required this.method,
  });

  final String ticker;
  final int forecastHorizonDays;

  /// Forecasted annualized volatility as a percentage.
  final double forecastedAnnualizedVol;

  /// Current realized volatility as a percentage.
  final double currentRealizedVol;
  final VolatilityForecastMethod method;

  double get volChange => forecastedAnnualizedVol - currentRealizedVol;
  bool get isVolIncreasing => volChange > 0;
  bool get isHighVol => forecastedAnnualizedVol >= 40.0;

  @override
  List<Object?> get props => [
    ticker,
    forecastHorizonDays,
    forecastedAnnualizedVol,
    currentRealizedVol,
    method,
  ];
}
