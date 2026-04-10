import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationTemplateConfig', () {
    const template = NotificationTemplateConfig(
      templateId: 'tmpl-001',
      name: 'BUY Signal',
      titleTemplate: '{{ticker}} — BUY signal',
      bodyTemplate: '{{method}} fired for {{ticker}} at {{price}}',
      placeholders: {'ticker', 'method', 'price'},
      channelId: 'trading_alerts',
    );

    test('isStatic is false when placeholders is non-empty', () {
      expect(template.isStatic, isFalse);
    });

    test('isStatic is true when there are no placeholders', () {
      const staticTmpl = NotificationTemplateConfig(
        templateId: 'tmpl-002',
        name: 'Static',
        titleTemplate: 'Hello',
        bodyTemplate: 'World',
        placeholders: {},
      );
      expect(staticTmpl.isStatic, isTrue);
    });

    test('resolveTitle substitutes placeholders', () {
      final title = template.resolveTitle({'ticker': 'AAPL'});
      expect(title, 'AAPL — BUY signal');
    });

    test('resolveBody substitutes all placeholders', () {
      final body = template.resolveBody({
        'method': 'Micho',
        'ticker': 'AAPL',
        'price': '175.00',
      });
      expect(body, 'Micho fired for AAPL at 175.00');
    });

    test('unresolved placeholders remain as-is', () {
      final title = template.resolveTitle({});
      expect(title, contains('{{ticker}}'));
    });

    test('channelId defaults to null when omitted', () {
      const noChannel = NotificationTemplateConfig(
        templateId: 'tmpl-003',
        name: 'No Channel',
        titleTemplate: 'X',
        bodyTemplate: 'Y',
        placeholders: {},
      );
      expect(noChannel.channelId, isNull);
    });

    test('equality holds for same props', () {
      const a = NotificationTemplateConfig(
        templateId: 'tmpl-001',
        name: 'BUY Signal',
        titleTemplate: '{{ticker}} — BUY signal',
        bodyTemplate: '{{method}} fired for {{ticker}} at {{price}}',
        placeholders: {'ticker', 'method', 'price'},
        channelId: 'trading_alerts',
      );
      expect(a, equals(template));
    });
  });
}
