/// User Engagement Event — records user interaction events for behavioral
/// profiling and smart notification timing (v1.9).
library;

import 'package:equatable/equatable.dart';

/// The type of user interaction being recorded.
enum EngagementEventType {
  /// User opened the app.
  appOpen,

  /// User dismissed an alert notification.
  alertDismissed,

  /// User tapped through an alert notification to the detail screen.
  alertActioned,

  /// User opened the watchlist screen.
  watchlistViewed,

  /// User opened a ticker detail screen.
  tickerDetailViewed,

  /// User opened the settings screen.
  settingsOpened,

  /// User changed an app setting.
  settingChanged,

  /// User performed a search.
  searchPerformed,

  /// User exported data.
  dataExported,
}

/// A single recorded user interaction event.
class UserEngagementEvent extends Equatable {
  const UserEngagementEvent({
    required this.eventId,
    required this.eventType,
    required this.occurredAt,
    this.ticker,
    this.metadata = const {},
  });

  final String eventId;
  final EngagementEventType eventType;
  final DateTime occurredAt;

  /// Associated ticker symbol, if relevant (e.g. for ticker detail views).
  final String? ticker;

  /// Arbitrary key-value metadata (e.g. screen name, setting key).
  final Map<String, String> metadata;

  @override
  List<Object?> get props => [eventId, eventType, occurredAt, ticker, metadata];
}

/// A time-bucketed session of engagement events used for timing analysis.
class EngagementSession extends Equatable {
  const EngagementSession({
    required this.sessionId,
    required this.startedAt,
    required this.events,
  });

  final String sessionId;
  final DateTime startedAt;
  final List<UserEngagementEvent> events;

  /// Session duration from first to last event (zero if < 2 events).
  Duration get duration => events.length < 2
      ? Duration.zero
      : events.last.occurredAt.difference(events.first.occurredAt);

  /// Returns the count of alert-actioned events in this session.
  int get alertActionCount => events
      .where(
        (UserEngagementEvent e) =>
            e.eventType == EngagementEventType.alertActioned,
      )
      .length;

  @override
  List<Object?> get props => [sessionId, startedAt, events];
}
