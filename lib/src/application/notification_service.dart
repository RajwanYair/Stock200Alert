// Notification Service — Abstract interface + flutter_local_notifications impl.
//
// Choice: flutter_local_notifications (Option A).
// Justification: Supports Android channels + notification tap callbacks.
// On Windows, the plugin shows basic notifications; advanced Windows toast
// features (cancel, getActive) require MSIX package identity — handled
// gracefully with try/catch and logs.
//
// Windows limitations (documented):
//   - Repeating notifications may be unsupported.
//   - cancel() and getActiveNotifications() require MSIX package identity.
//   - Windows-specific initialization (WindowsInitializationSettings) is
//     available in flutter_local_notifications_windows plugin ≥4.0; the base
//     plugin v18 does not export these. We use platform-default behavior.
import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Abstract notification interface for testability.
abstract class INotificationService {
  Future<void> initialize({void Function(String? payload)? onTap});
  Future<void> showCrossUpAlert({
    required String ticker,
    required double close,
    required double sma200,
  });
  Future<void> cancelAll();
}

class LocalNotificationService implements INotificationService {
  LocalNotificationService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  void Function(String? payload)? _onTap;

  static const _androidChannelId = 'stock_alert_cross_up';
  static const _androidChannelName = 'SMA200 Cross-Up Alerts';
  static const _androidChannelDesc =
      'Notifications when a stock crosses above its 200-day SMA';

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {
    _onTap = onTap;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Linux settings (used as fallback on desktop platforms).
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Request Android 13+ notification permission
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }
    }

    _logger.i('Notification service initialized');
  }

  void _handleNotificationTap(NotificationResponse response) {
    _logger.d('Notification tapped: ${response.payload}');
    _onTap?.call(response.payload);
  }

  @override
  Future<void> showCrossUpAlert({
    required String ticker,
    required double close,
    required double sma200,
  }) async {
    final id = ticker.hashCode.abs() % 100000;

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.show(
        id,
        '$ticker — SMA200 Cross-Up!',
        'Close: \$${close.toStringAsFixed(2)} crossed above '
            'SMA200: \$${sma200.toStringAsFixed(2)}',
        details,
        payload: 'ticker:$ticker',
      );
      _logger.i('Notification shown for $ticker');
    } catch (e) {
      _logger.e('Failed to show notification for $ticker: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      // Windows: cancel may require MSIX package identity.
      _logger.w('cancelAll failed (expected on non-MSIX Windows): $e');
    }
  }
}
