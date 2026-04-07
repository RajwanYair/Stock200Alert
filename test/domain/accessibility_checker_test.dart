import 'package:cross_tide/src/domain/accessibility_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const checker = AccessibilityChecker();

  group('AccessibilityChecker.audit', () {
    test('passes a well-configured component', () {
      final descriptors = [
        const ComponentDescriptor(
          id: 'buy-btn',
          type: 'Button',
          semanticLabel: 'Buy AAPL stock',
          minTapTargetSize: 48,
          contrastRatio: 7.0,
        ),
      ];

      final result = checker.audit(descriptors);
      expect(result.findings, isEmpty);
      expect(result.passedCount, 1);
      expect(result.passed, isTrue);
    });

    test('flags missing semantic label', () {
      final descriptors = [
        const ComponentDescriptor(
          id: 'icon-btn',
          type: 'Button',
          minTapTargetSize: 48,
          contrastRatio: 7.0,
        ),
      ];

      final result = checker.audit(descriptors);
      expect(result.errorCount, greaterThan(0));
      expect(
        result.findings.any((A11yFinding f) => f.rule.contains('semantic')),
        isTrue,
      );
    });

    test('flags small tap target on interactive element', () {
      final descriptors = [
        const ComponentDescriptor(
          id: 'tiny-btn',
          type: 'Button',
          semanticLabel: 'Tap',
          minTapTargetSize: 30,
          contrastRatio: 7.0,
        ),
      ];

      final result = checker.audit(descriptors);
      expect(
        result.findings.any((A11yFinding f) => f.rule.contains('tap-target')),
        isTrue,
      );
    });

    test('flags low contrast ratio on text', () {
      final descriptors = [
        const ComponentDescriptor(
          id: 'low-text',
          type: 'Text',
          semanticLabel: 'Label',
          minTapTargetSize: 48,
          contrastRatio: 2.0,
        ),
      ];

      final result = checker.audit(descriptors);
      expect(
        result.findings.any((A11yFinding f) => f.rule.contains('contrast')),
        isTrue,
      );
    });

    test('flags IconButton without tooltip', () {
      final descriptors = [
        const ComponentDescriptor(
          id: 'help-icon',
          type: 'IconButton',
          semanticLabel: 'Help',
          minTapTargetSize: 48,
          contrastRatio: 7.0,
          hasTooltip: false,
        ),
      ];

      final result = checker.audit(descriptors);
      expect(
        result.findings.any((A11yFinding f) => f.rule.contains('tooltip')),
        isTrue,
      );
    });

    test('IconButton with tooltip passes tooltip check', () {
      final descriptors = [
        const ComponentDescriptor(
          id: 'help-icon',
          type: 'IconButton',
          semanticLabel: 'Help',
          minTapTargetSize: 48,
          contrastRatio: 7.0,
          hasTooltip: true,
        ),
      ];

      final result = checker.audit(descriptors);
      expect(
        result.findings.where((A11yFinding f) => f.rule.contains('tooltip')),
        isEmpty,
      );
    });

    test('empty descriptors is fully passing', () {
      final result = checker.audit([]);
      expect(result.passed, isTrue);
      expect(result.passedCount, 0);
      expect(result.totalChecked, 0);
    });

    test('A11yFinding props equality', () {
      const a = A11yFinding(
        componentId: 'X',
        rule: 'semantic-label',
        severity: A11ySeverity.error,
        message: 'Missing',
      );
      const b = A11yFinding(
        componentId: 'X',
        rule: 'semantic-label',
        severity: A11ySeverity.error,
        message: 'Missing',
      );
      expect(a, equals(b));
    });

    test('A11yAuditResult props equality', () {
      const a = A11yAuditResult(
        findings: [],
        errorCount: 0,
        warningCount: 0,
        infoCount: 0,
        passedCount: 1,
        totalChecked: 1,
      );
      const b = A11yAuditResult(
        findings: [],
        errorCount: 0,
        warningCount: 0,
        infoCount: 0,
        passedCount: 1,
        totalChecked: 1,
      );
      expect(a, equals(b));
    });
  });
}
