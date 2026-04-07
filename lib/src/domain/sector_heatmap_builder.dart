/// Sector Heatmap Data Builder — aggregates ticker data into per-sector
/// performance cells for heatmap visualization.
library;

import 'package:equatable/equatable.dart';

/// One cell of a sector heatmap.
class SectorHeatmapCell extends Equatable {
  const SectorHeatmapCell({
    required this.sector,
    required this.tickerCount,
    required this.averageReturnPct,
    required this.bestTicker,
    required this.worstTicker,
  });

  final String sector;
  final int tickerCount;
  final double averageReturnPct;
  final String bestTicker;
  final String worstTicker;

  @override
  List<Object?> get props => [
    sector,
    tickerCount,
    averageReturnPct,
    bestTicker,
    worstTicker,
  ];
}

/// Input data for one ticker in the heatmap.
class TickerSectorReturn extends Equatable {
  const TickerSectorReturn({
    required this.ticker,
    required this.sector,
    required this.returnPct,
  });

  final String ticker;
  final String sector;
  final double returnPct;

  @override
  List<Object?> get props => [ticker, sector, returnPct];
}

/// Builds per-sector heatmap cells from individual ticker returns.
class SectorHeatmapBuilder {
  const SectorHeatmapBuilder();

  /// Group [tickers] by sector and compute aggregate stats.
  List<SectorHeatmapCell> build(List<TickerSectorReturn> tickers) {
    if (tickers.isEmpty) return [];

    final grouped = <String, List<TickerSectorReturn>>{};
    for (final TickerSectorReturn t in tickers) {
      grouped.putIfAbsent(t.sector, () => []).add(t);
    }

    final cells = <SectorHeatmapCell>[];
    for (final MapEntry<String, List<TickerSectorReturn>> entry
        in grouped.entries) {
      final items = entry.value;
      items.sort(
        (TickerSectorReturn a, TickerSectorReturn b) =>
            b.returnPct.compareTo(a.returnPct),
      );

      final avgReturn =
          items.fold<double>(
            0,
            (double acc, TickerSectorReturn t) => acc + t.returnPct,
          ) /
          items.length;

      cells.add(
        SectorHeatmapCell(
          sector: entry.key,
          tickerCount: items.length,
          averageReturnPct: avgReturn,
          bestTicker: items.first.ticker,
          worstTicker: items.last.ticker,
        ),
      );
    }

    cells.sort(
      (SectorHeatmapCell a, SectorHeatmapCell b) =>
          b.averageReturnPct.compareTo(a.averageReturnPct),
    );
    return cells;
  }
}
