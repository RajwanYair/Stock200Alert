import 'package:equatable/equatable.dart';

/// Delivery channel for an alert notification.
enum AlertDeliveryChannel { push, email, sms, webhook, inApp }

/// A log entry recording the delivery of a single alert notification.
class AlertNotificationLog extends Equatable {
  const AlertNotificationLog({
    required this.logId,
    required this.alertType,
    required this.symbol,
    required this.channel,
    required this.deliveredAt,
    this.isRead = false,
    this.isDelivered = true,
    this.failureReason,
  });

  final String logId;
  final String alertType;
  final String symbol;
  final AlertDeliveryChannel channel;
  final DateTime deliveredAt;
  final bool isRead;
  final bool isDelivered;
  final String? failureReason;

  bool get isFailed => !isDelivered;

  AlertNotificationLog markRead() => AlertNotificationLog(
    logId: logId,
    alertType: alertType,
    symbol: symbol,
    channel: channel,
    deliveredAt: deliveredAt,
    isRead: true,
    isDelivered: isDelivered,
    failureReason: failureReason,
  );

  @override
  List<Object?> get props => [
    logId,
    alertType,
    symbol,
    channel,
    deliveredAt,
    isRead,
    isDelivered,
    failureReason,
  ];
}
