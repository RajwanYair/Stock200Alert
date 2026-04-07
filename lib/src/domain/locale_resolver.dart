/// Locale Resolver — resolves display strings for supported locales.
///
/// This is the domain-side abstraction. The presentation layer maps
/// these keys to actual translations or Flutter's Intl system.
library;

import 'package:equatable/equatable.dart';

/// Supported application locales.
enum AppLocale {
  en('en', 'English'),
  he('he', 'עברית'),
  es('es', 'Español'),
  de('de', 'Deutsch'),
  fr('fr', 'Français'),
  ja('ja', '日本語'),
  zh('zh', '中文');

  const AppLocale(this.code, this.displayName);

  final String code;
  final String displayName;
}

/// A localized string key with its default (English) value.
class LocalizedKey extends Equatable {
  const LocalizedKey({required this.key, required this.defaultValue});

  final String key;
  final String defaultValue;

  @override
  List<Object?> get props => [key, defaultValue];
}

/// Result of locale resolution.
class LocaleResolution extends Equatable {
  const LocaleResolution({
    required this.requestedLocale,
    required this.resolvedLocale,
    required this.isFallback,
  });

  final String requestedLocale;
  final AppLocale resolvedLocale;

  /// True if the requested locale was not found and English was used.
  final bool isFallback;

  @override
  List<Object?> get props => [requestedLocale, resolvedLocale, isFallback];
}

/// Resolves a locale code to the best matching [AppLocale].
class LocaleResolver {
  const LocaleResolver();

  /// Resolve a locale code like 'en', 'en_US', 'he_IL' to [AppLocale].
  LocaleResolution resolve(String localeCode) {
    final normalized = localeCode.toLowerCase().split(RegExp('[_-]')).first;

    for (final AppLocale locale in AppLocale.values) {
      if (locale.code == normalized) {
        return LocaleResolution(
          requestedLocale: localeCode,
          resolvedLocale: locale,
          isFallback: false,
        );
      }
    }

    return LocaleResolution(
      requestedLocale: localeCode,
      resolvedLocale: AppLocale.en,
      isFallback: true,
    );
  }

  /// Get all supported locale codes.
  List<String> supportedCodes() {
    return AppLocale.values.map((AppLocale l) => l.code).toList();
  }
}
