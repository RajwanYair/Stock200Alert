import 'package:equatable/equatable.dart';

/// A named configuration profile for chart visual settings.
class ChartThemeProfile extends Equatable {
  const ChartThemeProfile({
    required this.profileId,
    required this.name,
    required this.candleUpColor,
    required this.candleDownColor,
    required this.backgroundColor,
    this.gridColor,
    this.volumeBarColor,
    this.isDefault = false,
  });

  final String profileId;
  final String name;

  /// Hex color for bullish (up) candles.
  final String candleUpColor;

  /// Hex color for bearish (down) candles.
  final String candleDownColor;
  final String backgroundColor;
  final String? gridColor;
  final String? volumeBarColor;
  final bool isDefault;

  bool get hasGridColor => gridColor != null;
  bool get hasVolumeColor => volumeBarColor != null;

  ChartThemeProfile withDefault() => ChartThemeProfile(
    profileId: profileId,
    name: name,
    candleUpColor: candleUpColor,
    candleDownColor: candleDownColor,
    backgroundColor: backgroundColor,
    gridColor: gridColor,
    volumeBarColor: volumeBarColor,
    isDefault: true,
  );

  /// Dark theme preset.
  static const ChartThemeProfile darkClassic = ChartThemeProfile(
    profileId: 'dark-classic',
    name: 'Dark Classic',
    candleUpColor: '#26A69A',
    candleDownColor: '#EF5350',
    backgroundColor: '#1C1C1E',
    gridColor: '#2C2C2E',
    isDefault: true,
  );

  /// Light theme preset.
  static const ChartThemeProfile lightClean = ChartThemeProfile(
    profileId: 'light-clean',
    name: 'Light Clean',
    candleUpColor: '#089981',
    candleDownColor: '#F23645',
    backgroundColor: '#FFFFFF',
    gridColor: '#E0E3EB',
  );

  @override
  List<Object?> get props => [
    profileId,
    name,
    candleUpColor,
    candleDownColor,
    backgroundColor,
    gridColor,
    volumeBarColor,
    isDefault,
  ];
}
