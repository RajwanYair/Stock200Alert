import 'package:equatable/equatable.dart';

/// A single contextual help article or tooltip entry (S490).
class ContextualHelpEntry extends Equatable {
  const ContextualHelpEntry({
    required this.helpId,
    required this.screenKey,
    required this.title,
    required this.body,
    this.learnMoreUrl = '',
    this.isPriority = false,
  });

  final String helpId;

  /// Screen or widget key this entry is associated with.
  final String screenKey;
  final String title;
  final String body;
  final String learnMoreUrl;
  final bool isPriority;

  bool get hasLearnMoreLink => learnMoreUrl.isNotEmpty;
  bool get isShortBody => body.length <= 140;

  @override
  List<Object?> get props => [
    helpId,
    screenKey,
    title,
    body,
    learnMoreUrl,
    isPriority,
  ];
}
