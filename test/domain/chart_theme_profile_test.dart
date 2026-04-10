import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartThemeProfile', () {
    test('creates custom profile', () {
      const profile = ChartThemeProfile(
        profileId: 'custom-1',
        name: 'My Theme',
        candleUpColor: '#00FF00',
        candleDownColor: '#FF0000',
        backgroundColor: '#000000',
      );
      expect(profile.name, 'My Theme');
      expect(profile.isDefault, isFalse);
      expect(profile.hasGridColor, isFalse);
      expect(profile.hasVolumeColor, isFalse);
    });

    test('withDefault sets isDefault to true', () {
      const profile = ChartThemeProfile(
        profileId: 'p1',
        name: 'Test',
        candleUpColor: '#0F0',
        candleDownColor: '#F00',
        backgroundColor: '#000',
      );
      final defaulted = profile.withDefault();
      expect(defaulted.isDefault, isTrue);
      expect(defaulted.profileId, 'p1');
    });

    test('predefined darkClassic is correct', () {
      expect(ChartThemeProfile.darkClassic.profileId, 'dark-classic');
      expect(ChartThemeProfile.darkClassic.isDefault, isTrue);
      expect(ChartThemeProfile.darkClassic.hasGridColor, isTrue);
    });

    test('predefined lightClean is correct', () {
      expect(ChartThemeProfile.lightClean.profileId, 'light-clean');
      expect(ChartThemeProfile.lightClean.isDefault, isFalse);
    });

    test('profile with grid and volume colors', () {
      const profile = ChartThemeProfile(
        profileId: 'full',
        name: 'Full',
        candleUpColor: '#0F0',
        candleDownColor: '#F00',
        backgroundColor: '#111',
        gridColor: '#333',
        volumeBarColor: '#555',
      );
      expect(profile.hasGridColor, isTrue);
      expect(profile.hasVolumeColor, isTrue);
    });

    test('equality holds for identical profiles', () {
      const a = ChartThemeProfile(
        profileId: 'x',
        name: 'X',
        candleUpColor: '#0F0',
        candleDownColor: '#F00',
        backgroundColor: '#000',
      );
      const b = ChartThemeProfile(
        profileId: 'x',
        name: 'X',
        candleUpColor: '#0F0',
        candleDownColor: '#F00',
        backgroundColor: '#000',
      );
      expect(a, equals(b));
    });
  });
}
