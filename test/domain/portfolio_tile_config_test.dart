import 'package:cross_tide/src/domain/portfolio_tile_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PortfolioTileConfig', () {
    test('equality', () {
      const a = PortfolioTileConfig(
        portfolioId: 'p-1',
        displayMode: TileDisplayMode.standard,
        showPercentage: true,
        showSparkline: true,
        columnCount: 2,
      );
      const b = PortfolioTileConfig(
        portfolioId: 'p-1',
        displayMode: TileDisplayMode.standard,
        showPercentage: true,
        showSparkline: true,
        columnCount: 2,
      );
      expect(a, b);
    });

    test('copyWith changes columnCount', () {
      const base = PortfolioTileConfig(
        portfolioId: 'p-1',
        displayMode: TileDisplayMode.standard,
        showPercentage: true,
        showSparkline: true,
        columnCount: 2,
      );
      final updated = base.copyWith(columnCount: 3);
      expect(updated.columnCount, 3);
    });

    test('props length is 5', () {
      const obj = PortfolioTileConfig(
        portfolioId: 'p-1',
        displayMode: TileDisplayMode.standard,
        showPercentage: true,
        showSparkline: true,
        columnCount: 2,
      );
      expect(obj.props.length, 5);
    });
  });
}
