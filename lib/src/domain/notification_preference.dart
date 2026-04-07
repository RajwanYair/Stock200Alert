/// Notification Preference — pure domain value object.
///
/// Per-ticker notification delivery preferences. Controls which alert types
/// trigger notifications and through which channels.
library;

import 'package:equatable/equatable.dart';

/// The delivery channel for a notification.
enum NotificationChannel {
  /// Local push notification (flutter_local_notifications).
  push,

  /// In-app banner / toast.
  inApp,

  /// Silent — recorded but not surfaced to the user.
  silent;

  /// Human-readable label.
  String get label => switch (this) {
    NotificationChannel.push => 'Push',
    NotificationChannel.inApp => 'In-App',
    NotificationChannel.silent => 'Silent',
  };
}

/// Per-ticker or global notification preferences.
class NotificationPreference extends Equatable {
  const NotificationPreference({
    required this.symbol,
    this.enabledAlertTypes = const {},
    this.channel = NotificationChannel.push,
    this.mutedUntil,
  });

  /// Ticker symbol this preference applies to. Use `'*'` for global default.
  final String symbol;

  /// Set of [AlertType.name] strings that are enabled. Empty = all enabled.
  final Set<String> enabledAlertTypes;

  /// Preferred delivery channel.
  final NotificationChannel channel;

  /// Temporarily mute notifications until this time.
  final DateTime? mutedUntil;

  /// Whether this preference is currently muted at [now].
  bool isMuted(DateTime now) => mutedUntil != null && now.isBefore(mutedUntil!);

  /// Whether [alertTypeName] is enabled (empty set means all are enabled).
  bool isAlertEnabled(String alertTypeName) =>
      enabledAlertTypes.isEmpty || enabledAlertTypes.contains(alertTypeName);

  /// Return a copy with updated fields.
  NotificationPreference copyWith({
    String? symbol,
    Set<String>? enabledAlertTypes,
    NotificationChannel? channel,
    DateTime? Function()? mutedUntil,
  }) => NotificationPreference(
    symbol: symbol ?? this.symbol,
    enabledAlertTypes: enabledAlertTypes ?? this.enabledAlertTypes,
    channel: channel ?? this.channel,
    mutedUntil: mutedUntil != null ? mutedUntil() : this.mutedUntil,
  );

  @override
  List<Object?> get props => [symbol, enabledAlertTypes, channel, mutedUntil];
}
