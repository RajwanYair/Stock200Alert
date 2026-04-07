/// Volume Profile Calculator — pure domain logic.
///
/// Distributes volume across price bins to identify high-volume price
/// nodes (HVN) and low-volume price nodes (LVN). Useful for finding
/// support/resistance zones based on where trading activity concentrates.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// One bin in the volume profile histogram.
class VolumeProfileBin extends Equatable {
  const VolumeProfileBin({
    required this.priceLow,
    required this.priceHigh,
    required this.volume,
  });

  /// Lower bound of this price bin.
  final double priceLow;

  /// Upper bound of this price bin.
  final double priceHigh;

  /// Total volume traded within this price range.
  final int volume;

  /// Midpoint price of this bin.
  double get midPrice => (priceLow + priceHigh) / 2;

  @override
  List<Object?> get props => [priceLow, priceHigh, volume];
}

/// Result of a volume profile computation.
class VolumeProfileResult extends Equatable {
  const VolumeProfileResult({
    required this.bins,
    required this.pocIndex,
    required this.totalVolume,
  });

  /// All price bins in ascending price order.
  final List<VolumeProfileBin> bins;

  /// Index of the Point of Control (highest-volume bin).
  final int pocIndex;

  /// Total volume across all bins.
  final int totalVolume;

  /// The Point of Control bin.
  VolumeProfileBin get poc => bins[pocIndex];

  @override
  List<Object?> get props => [bins, pocIndex, totalVolume];
}

/// Computes a volume profile from candle data.
class VolumeProfileCalculator {
  const VolumeProfileCalculator();

  /// Compute volume profile with [binCount] equal-width price bins.
  ///
  /// Returns null if [candles] is empty or all candles have the same
  /// high/low range.
  VolumeProfileResult? compute(List<DailyCandle> candles, {int binCount = 24}) {
    if (candles.isEmpty || binCount < 1) return null;

    double minLow = candles.first.low;
    double maxHigh = candles.first.high;
    for (final DailyCandle c in candles) {
      if (c.low < minLow) minLow = c.low;
      if (c.high > maxHigh) maxHigh = c.high;
    }

    final double range = maxHigh - minLow;
    if (range <= 0) return null;

    final double binWidth = range / binCount;
    final List<int> volumes = List.filled(binCount, 0);

    for (final DailyCandle c in candles) {
      // Distribute candle volume proportionally across bins it spans
      final double typicalPrice = (c.high + c.low + c.close) / 3;
      int binIndex = ((typicalPrice - minLow) / binWidth).floor();
      if (binIndex >= binCount) binIndex = binCount - 1;
      if (binIndex < 0) binIndex = 0;
      volumes[binIndex] += c.volume;
    }

    int pocIndex = 0;
    int totalVolume = 0;
    for (int i = 0; i < binCount; i++) {
      totalVolume += volumes[i];
      if (volumes[i] > volumes[pocIndex]) pocIndex = i;
    }

    final List<VolumeProfileBin> bins = List.generate(
      binCount,
      (int i) => VolumeProfileBin(
        priceLow: minLow + i * binWidth,
        priceHigh: minLow + (i + 1) * binWidth,
        volume: volumes[i],
      ),
    );

    return VolumeProfileResult(
      bins: bins,
      pocIndex: pocIndex,
      totalVolume: totalVolume,
    );
  }
}
