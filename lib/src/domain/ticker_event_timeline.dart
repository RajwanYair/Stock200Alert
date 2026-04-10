import 'package:equatable/equatable.dart';

/// Type of event in a ticker's timeline.
enum TickerEventType {
  earningsRelease,
  dividendEx,
  dividendPay,
  split,
  indexAddition,
  indexRemoval,
  alertFired,
  signalChange,
  custom,
}

/// A single dated event on a ticker's timeline.
class TickerTimelineEvent extends Equatable {
  const TickerTimelineEvent({
    required this.eventType,
    required this.eventDate,
    required this.description,
    this.value,
    this.metadata,
  });

  final TickerEventType eventType;
  final DateTime eventDate;
  final String description;

  /// Optional numeric value associated with the event (e.g. EPS, split ratio).
  final double? value;

  /// Optional key-value metadata (e.g. {'symbol': 'AAPL'}).
  final Map<String, String>? metadata;

  @override
  List<Object?> get props => [
    eventType,
    eventDate,
    description,
    value,
    metadata,
  ];
}

/// An ordered timeline of events for a single ticker.
class TickerEventTimeline extends Equatable {
  const TickerEventTimeline({required this.ticker, required this.events});

  final String ticker;

  /// Events ordered chronologically (ascending date).
  final List<TickerTimelineEvent> events;

  /// Returns only events of the given type.
  List<TickerTimelineEvent> ofType(TickerEventType type) =>
      events.where((e) => e.eventType == type).toList();

  /// Most recent event, or null if the timeline is empty.
  TickerTimelineEvent? get latestEvent => events.isEmpty ? null : events.last;

  @override
  List<Object?> get props => [ticker, events];
}
