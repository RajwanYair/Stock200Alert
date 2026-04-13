import 'package:equatable/equatable.dart';

/// Portfolio tile config — home-screen portfolio card display settings.
enum TileDisplayMode { compact, standard, expanded, chart }

class PortfolioTileConfig extends Equatable {
  const PortfolioTileConfig({
    required this.portfolioId,
    required this.displayMode,
    required this.showPercentage,
    required this.showSparkline,
    required this.columnCount,
  });

  final String portfolioId;
  final TileDisplayMode displayMode;
  final bool showPercentage;
  final bool showSparkline;
  final int columnCount;

  PortfolioTileConfig copyWith({
    String? portfolioId,
    TileDisplayMode? displayMode,
    bool? showPercentage,
    bool? showSparkline,
    int? columnCount,
  }) => PortfolioTileConfig(
    portfolioId: portfolioId ?? this.portfolioId,
    displayMode: displayMode ?? this.displayMode,
    showPercentage: showPercentage ?? this.showPercentage,
    showSparkline: showSparkline ?? this.showSparkline,
    columnCount: columnCount ?? this.columnCount,
  );

  @override
  List<Object?> get props => [
    portfolioId,
    displayMode,
    showPercentage,
    showSparkline,
    columnCount,
  ];
}
