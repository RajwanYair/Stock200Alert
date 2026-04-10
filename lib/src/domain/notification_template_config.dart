import 'package:equatable/equatable.dart';

/// A parameterised template for notification messages.
///
/// Templates contain named placeholders (e.g. `{{ticker}}`) which are
/// resolved at dispatch time via the [resolve] method.
class NotificationTemplateConfig extends Equatable {
  /// Creates a [NotificationTemplateConfig].
  const NotificationTemplateConfig({
    required this.templateId,
    required this.name,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.placeholders,
    this.channelId,
  });

  /// Unique identifier for this template.
  final String templateId;

  /// Human-readable name (e.g. `'BUY Signal Alert'`).
  final String name;

  /// Title string with `{{placeholder}}` markers.
  final String titleTemplate;

  /// Body string with `{{placeholder}}` markers.
  final String bodyTemplate;

  /// Set of expected placeholder names (without delimiters).
  final Set<String> placeholders;

  /// Optional notification channel ID to associate with this template.
  final String? channelId;

  /// Returns `true` when the template has no placeholders.
  bool get isStatic => placeholders.isEmpty;

  /// Resolves all `{{key}}` placeholders in [template] using [values].
  ///
  /// Unresolved placeholders are left as-is.
  String _render(String template, Map<String, String> values) {
    var result = template;
    for (final MapEntry<String, String> entry in values.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    return result;
  }

  /// Returns a resolved title string for this template given [values].
  String resolveTitle(Map<String, String> values) =>
      _render(titleTemplate, values);

  /// Returns a resolved body string for this template given [values].
  String resolveBody(Map<String, String> values) =>
      _render(bodyTemplate, values);

  @override
  List<Object?> get props => [
    templateId,
    name,
    titleTemplate,
    bodyTemplate,
    placeholders,
    channelId,
  ];
}
