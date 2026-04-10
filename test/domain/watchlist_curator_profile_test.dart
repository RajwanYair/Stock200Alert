import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurationStyle', () {
    test('has 4 values', () {
      expect(CurationStyle.values.length, 4);
    });
  });

  group('WatchlistCuratorProfile', () {
    WatchlistCuratorProfile buildProfile({
      CurationStyle style = CurationStyle.fullCuration,
      bool isEnabled = true,
    }) {
      return WatchlistCuratorProfile(
        profileId: 'cp1',
        watchlistId: 'wl1',
        curationStyle: style,
        maxSize: 50,
        lastCuratedAt: DateTime(2024, 6, 1),
        filterTagKeys: const ['momentum', 'largecap'],
        isEnabled: isEnabled,
      );
    }

    test('isActive is true when enabled with non-manual style', () {
      expect(buildProfile().isActive, isTrue);
    });

    test('isActive is false when style is manual', () {
      expect(buildProfile(style: CurationStyle.manual).isActive, isFalse);
    });

    test('isActive is false when disabled', () {
      expect(buildProfile(isEnabled: false).isActive, isFalse);
    });

    test('isEnabled defaults to true', () {
      final p = WatchlistCuratorProfile(
        profileId: 'cp2',
        watchlistId: 'wl2',
        curationStyle: CurationStyle.addOnly,
        maxSize: 20,
        lastCuratedAt: DateTime(2024, 1, 1),
      );
      expect(p.isEnabled, isTrue);
    });

    test('equality holds for same props', () {
      expect(buildProfile(), equals(buildProfile()));
    });
  });
}
