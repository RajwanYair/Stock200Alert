import 'package:equatable/equatable.dart';

/// Device capability snapshot — hardware feature detection record.
enum DeviceFormFactor { phone, tablet, desktop, watch, tv }

class DeviceCapabilitySnapshot extends Equatable {
  const DeviceCapabilitySnapshot({
    required this.deviceId,
    required this.formFactor,
    required this.ramMb,
    required this.hasBiometrics,
    required this.supportsNotifications,
  });

  final String deviceId;
  final DeviceFormFactor formFactor;
  final int ramMb;
  final bool hasBiometrics;
  final bool supportsNotifications;

  DeviceCapabilitySnapshot copyWith({
    String? deviceId,
    DeviceFormFactor? formFactor,
    int? ramMb,
    bool? hasBiometrics,
    bool? supportsNotifications,
  }) => DeviceCapabilitySnapshot(
    deviceId: deviceId ?? this.deviceId,
    formFactor: formFactor ?? this.formFactor,
    ramMb: ramMb ?? this.ramMb,
    hasBiometrics: hasBiometrics ?? this.hasBiometrics,
    supportsNotifications: supportsNotifications ?? this.supportsNotifications,
  );

  @override
  List<Object?> get props => [
    deviceId,
    formFactor,
    ramMb,
    hasBiometrics,
    supportsNotifications,
  ];
}
