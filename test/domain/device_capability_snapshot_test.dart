import 'package:cross_tide/src/domain/device_capability_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceCapabilitySnapshot', () {
    test('equality', () {
      const a = DeviceCapabilitySnapshot(
        deviceId: 'dev-1',
        formFactor: DeviceFormFactor.phone,
        ramMb: 4096,
        hasBiometrics: true,
        supportsNotifications: true,
      );
      const b = DeviceCapabilitySnapshot(
        deviceId: 'dev-1',
        formFactor: DeviceFormFactor.phone,
        ramMb: 4096,
        hasBiometrics: true,
        supportsNotifications: true,
      );
      expect(a, b);
    });

    test('copyWith changes ramMb', () {
      const base = DeviceCapabilitySnapshot(
        deviceId: 'dev-1',
        formFactor: DeviceFormFactor.phone,
        ramMb: 4096,
        hasBiometrics: true,
        supportsNotifications: true,
      );
      final updated = base.copyWith(ramMb: 8192);
      expect(updated.ramMb, 8192);
    });

    test('props length is 5', () {
      const obj = DeviceCapabilitySnapshot(
        deviceId: 'dev-1',
        formFactor: DeviceFormFactor.phone,
        ramMb: 4096,
        hasBiometrics: true,
        supportsNotifications: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
