import 'package:cross_tide/src/domain/locale_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = LocaleResolver();

  group('LocaleResolver.resolve', () {
    test('resolves known locale code', () {
      final result = resolver.resolve('en');
      expect(result.resolvedLocale, AppLocale.en);
      expect(result.isFallback, isFalse);
    });

    test('resolves with country suffix', () {
      final result = resolver.resolve('en_US');
      expect(result.resolvedLocale, AppLocale.en);
      expect(result.isFallback, isFalse);
    });

    test('resolves Hebrew', () {
      final result = resolver.resolve('he');
      expect(result.resolvedLocale, AppLocale.he);
      expect(result.isFallback, isFalse);
    });

    test('resolves case-insensitively', () {
      final result = resolver.resolve('ES');
      expect(result.resolvedLocale, AppLocale.es);
      expect(result.isFallback, isFalse);
    });

    test('falls back to English for unknown locale', () {
      final result = resolver.resolve('xx');
      expect(result.resolvedLocale, AppLocale.en);
      expect(result.isFallback, isTrue);
    });

    test('handles empty string', () {
      final result = resolver.resolve('');
      expect(result.resolvedLocale, AppLocale.en);
      expect(result.isFallback, isTrue);
    });
  });

  group('LocaleResolver.supportedCodes', () {
    test('returns all locale codes', () {
      final codes = resolver.supportedCodes();
      expect(codes, contains('en'));
      expect(codes, contains('he'));
      expect(codes, contains('ja'));
      expect(codes.length, AppLocale.values.length);
    });
  });

  group('AppLocale', () {
    test('code getter returns string code', () {
      expect(AppLocale.en.code, 'en');
      expect(AppLocale.ja.code, 'ja');
    });

    test('displayName getter returns localised name', () {
      expect(AppLocale.en.displayName, 'English');
      expect(AppLocale.he.displayName, 'עברית');
    });
  });

  group('LocaleResolution props equality', () {
    test('equal instances match', () {
      const a = LocaleResolution(
        requestedLocale: 'en',
        resolvedLocale: AppLocale.en,
        isFallback: false,
      );
      const b = LocaleResolution(
        requestedLocale: 'en',
        resolvedLocale: AppLocale.en,
        isFallback: false,
      );
      expect(a, equals(b));
    });
  });

  group('LocalizedKey props equality', () {
    test('equal instances match', () {
      const a = LocalizedKey(key: 'label.ok', defaultValue: 'OK');
      const b = LocalizedKey(key: 'label.ok', defaultValue: 'OK');
      expect(a, equals(b));
    });
  });
}
