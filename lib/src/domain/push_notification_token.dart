import 'package:equatable/equatable.dart';

/// Push notification token — device registration token for push delivery.
enum PushTokenPlatform { android, ios, web, windows, macOs }

class PushNotificationToken extends Equatable {
  const PushNotificationToken({
    required this.userId,
    required this.token,
    required this.platform,
    required this.isValid,
    required this.registeredAt,
  });

  final String userId;
  final String token;
  final PushTokenPlatform platform;
  final bool isValid;
  final DateTime registeredAt;

  PushNotificationToken copyWith({
    String? userId,
    String? token,
    PushTokenPlatform? platform,
    bool? isValid,
    DateTime? registeredAt,
  }) => PushNotificationToken(
    userId: userId ?? this.userId,
    token: token ?? this.token,
    platform: platform ?? this.platform,
    isValid: isValid ?? this.isValid,
    registeredAt: registeredAt ?? this.registeredAt,
  );

  @override
  List<Object?> get props => [userId, token, platform, isValid, registeredAt];
}
