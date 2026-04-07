/// Accessibility Checker — domain logic for checking accessibility
/// compliance of UI component descriptions.
library;

import 'package:equatable/equatable.dart';

/// Severity of an accessibility finding.
enum A11ySeverity { error, warning, info }

/// An accessibility finding in a UI component.
class A11yFinding extends Equatable {
  const A11yFinding({
    required this.componentId,
    required this.rule,
    required this.message,
    required this.severity,
  });

  final String componentId;
  final String rule;
  final String message;
  final A11ySeverity severity;

  @override
  List<Object?> get props => [componentId, rule, message, severity];
}

/// A UI component descriptor for accessibility checking.
class ComponentDescriptor extends Equatable {
  const ComponentDescriptor({
    required this.id,
    required this.type,
    this.semanticLabel,
    this.hasTooltip = false,
    this.minTapTargetSize = 0,
    this.contrastRatio = 0,
  });

  final String id;
  final String type;
  final String? semanticLabel;
  final bool hasTooltip;

  /// Minimum dimension of the tap target in logical pixels.
  final double minTapTargetSize;

  /// Foreground/background contrast ratio (e.g. 4.5).
  final double contrastRatio;

  @override
  List<Object?> get props => [
    id,
    type,
    semanticLabel,
    hasTooltip,
    minTapTargetSize,
    contrastRatio,
  ];
}

/// Summary of an accessibility audit.
class A11yAuditResult extends Equatable {
  const A11yAuditResult({
    required this.findings,
    required this.errorCount,
    required this.warningCount,
    required this.infoCount,
    required this.passedCount,
    required this.totalChecked,
  });

  final List<A11yFinding> findings;
  final int errorCount;
  final int warningCount;
  final int infoCount;
  final int passedCount;
  final int totalChecked;

  /// True if no errors were found.
  bool get passed => errorCount == 0;

  @override
  List<Object?> get props => [
    findings,
    errorCount,
    warningCount,
    infoCount,
    passedCount,
    totalChecked,
  ];
}

/// Checks component descriptors for common accessibility issues.
class AccessibilityChecker {
  const AccessibilityChecker();

  /// Minimum tap target size per WCAG (48dp).
  static const double _minTapTarget = 48;

  /// Minimum contrast ratio for normal text per WCAG AA.
  static const double _minContrastAA = 4.5;

  /// Audit a list of components.
  A11yAuditResult audit(List<ComponentDescriptor> components) {
    final findings = <A11yFinding>[];
    var passed = 0;

    for (final ComponentDescriptor c in components) {
      var hasIssue = false;

      // Check semantic label
      if (c.semanticLabel == null || c.semanticLabel!.isEmpty) {
        findings.add(
          A11yFinding(
            componentId: c.id,
            rule: 'semantic-label',
            message: '${c.type} "${c.id}" is missing a semantic label',
            severity: A11ySeverity.error,
          ),
        );
        hasIssue = true;
      }

      // Check tap target size for interactive elements
      if (_isInteractive(c.type) && c.minTapTargetSize < _minTapTarget) {
        findings.add(
          A11yFinding(
            componentId: c.id,
            rule: 'tap-target-size',
            message:
                '${c.type} "${c.id}" tap target is '
                '${c.minTapTargetSize}dp, minimum is ${_minTapTarget}dp',
            severity: A11ySeverity.warning,
          ),
        );
        hasIssue = true;
      }

      // Check contrast ratio for text elements
      if (_isTextElement(c.type) && c.contrastRatio < _minContrastAA) {
        findings.add(
          A11yFinding(
            componentId: c.id,
            rule: 'contrast-ratio',
            message:
                '${c.type} "${c.id}" contrast ratio is '
                '${c.contrastRatio}, minimum AA is $_minContrastAA',
            severity: A11ySeverity.error,
          ),
        );
        hasIssue = true;
      }

      // Check tooltip for icon-only buttons
      if (c.type == 'IconButton' && !c.hasTooltip) {
        findings.add(
          A11yFinding(
            componentId: c.id,
            rule: 'icon-tooltip',
            message: 'IconButton "${c.id}" should have a tooltip',
            severity: A11ySeverity.info,
          ),
        );
        hasIssue = true;
      }

      if (!hasIssue) passed++;
    }

    return A11yAuditResult(
      findings: findings,
      errorCount: findings
          .where((A11yFinding f) => f.severity == A11ySeverity.error)
          .length,
      warningCount: findings
          .where((A11yFinding f) => f.severity == A11ySeverity.warning)
          .length,
      infoCount: findings
          .where((A11yFinding f) => f.severity == A11ySeverity.info)
          .length,
      passedCount: passed,
      totalChecked: components.length,
    );
  }

  bool _isInteractive(String type) {
    return const {
      'Button',
      'IconButton',
      'TextButton',
      'ElevatedButton',
      'Checkbox',
      'Switch',
      'Slider',
      'DropdownButton',
    }.contains(type);
  }

  bool _isTextElement(String type) {
    return const {'Text', 'RichText', 'Label', 'TextField'}.contains(type);
  }
}
