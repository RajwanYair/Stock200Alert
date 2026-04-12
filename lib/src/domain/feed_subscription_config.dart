import 'package:equatable/equatable.dart';

/// Protocol used for a market data feed subscription (S471).
enum FeedProtocol { websocket, sse, polling, grpc }

/// Configuration for subscribing to a market data feed (S471).
class FeedSubscriptionConfig extends Equatable {
  const FeedSubscriptionConfig({
    required this.subscriptionId,
    required this.feedName,
    required this.protocol,
    required this.tickerSymbols,
    this.heartbeatIntervalSeconds = 30,
    this.isActive = true,
  });

  final String subscriptionId;
  final String feedName;
  final FeedProtocol protocol;
  final List<String> tickerSymbols;
  final int heartbeatIntervalSeconds;
  final bool isActive;

  bool get isStreaming =>
      protocol == FeedProtocol.websocket ||
      protocol == FeedProtocol.sse ||
      protocol == FeedProtocol.grpc;
  bool get isPolling => protocol == FeedProtocol.polling;
  int get symbolCount => tickerSymbols.length;

  @override
  List<Object?> get props => [
    subscriptionId,
    feedName,
    protocol,
    tickerSymbols,
    heartbeatIntervalSeconds,
    isActive,
  ];
}
