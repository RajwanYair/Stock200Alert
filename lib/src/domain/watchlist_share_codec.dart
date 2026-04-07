/// Watchlist Share Codec — encodes/decodes a watchlist as a compact
/// shareable deep-link URL.
///
/// URL format: `crosstide://share?v=1&t=AAPL,MSFT,GOOG&p=balanced`
library;

import 'package:equatable/equatable.dart';

/// Decoded watchlist share payload.
class WatchlistSharePayload extends Equatable {
  const WatchlistSharePayload({
    required this.tickers,
    this.profileName = '',
    this.version = 1,
  });

  final List<String> tickers;
  final String profileName;
  final int version;

  @override
  List<Object?> get props => [tickers, profileName, version];
}

/// Encodes and decodes watchlist data for sharing via deep links.
class WatchlistShareCodec {
  const WatchlistShareCodec();

  static const _scheme = 'crosstide';
  static const _host = 'share';

  /// Encode a list of tickers and optional profile into a shareable URL.
  String encode(WatchlistSharePayload payload) {
    if (payload.tickers.isEmpty) return '';

    final tickerParam = payload.tickers.join(',');
    final buffer = StringBuffer('$_scheme://$_host?v=${payload.version}');
    buffer.write('&t=$tickerParam');
    if (payload.profileName.isNotEmpty) {
      buffer.write('&p=${payload.profileName}');
    }
    return buffer.toString();
  }

  /// Decode a share URL into a [WatchlistSharePayload].
  /// Returns `null` if the URL is invalid.
  WatchlistSharePayload? decode(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.scheme != _scheme || uri.host != _host) return null;

    final tickerParam = uri.queryParameters['t'];
    if (tickerParam == null || tickerParam.isEmpty) return null;

    final tickers = tickerParam
        .split(',')
        .map((String s) => s.trim().toUpperCase())
        .where((String s) => s.isNotEmpty)
        .toList();

    if (tickers.isEmpty) return null;

    final version = int.tryParse(uri.queryParameters['v'] ?? '1') ?? 1;
    final profile = uri.queryParameters['p'] ?? '';

    return WatchlistSharePayload(
      tickers: tickers,
      profileName: profile,
      version: version,
    );
  }

  /// Validate a share URL without fully parsing it.
  bool isValid(String url) => decode(url) != null;
}
