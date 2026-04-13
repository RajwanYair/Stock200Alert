import 'package:cross_tide/src/domain/webhook_endpoint_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebhookEndpointConfig', () {
    test('equality', () {
      const a = WebhookEndpointConfig(
        endpointId: 'ep-1',
        url: 'https://hooks.example.com/alerts',
        authScheme: WebhookAuthScheme.bearerToken,
        isEnabled: true,
        timeoutMs: 5000,
      );
      const b = WebhookEndpointConfig(
        endpointId: 'ep-1',
        url: 'https://hooks.example.com/alerts',
        authScheme: WebhookAuthScheme.bearerToken,
        isEnabled: true,
        timeoutMs: 5000,
      );
      expect(a, b);
    });

    test('copyWith changes timeoutMs', () {
      const base = WebhookEndpointConfig(
        endpointId: 'ep-1',
        url: 'https://hooks.example.com/alerts',
        authScheme: WebhookAuthScheme.bearerToken,
        isEnabled: true,
        timeoutMs: 5000,
      );
      final updated = base.copyWith(timeoutMs: 10000);
      expect(updated.timeoutMs, 10000);
    });

    test('props length is 5', () {
      const obj = WebhookEndpointConfig(
        endpointId: 'ep-1',
        url: 'https://hooks.example.com/alerts',
        authScheme: WebhookAuthScheme.bearerToken,
        isEnabled: true,
        timeoutMs: 5000,
      );
      expect(obj.props.length, 5);
    });
  });
}
