import 'package:equatable/equatable.dart';

/// App rating prompt — in-app store rating prompt outcome record.
enum RatingPromptOutcome { rated, dismissed, deferred, notShown }

class AppRatingPrompt extends Equatable {
  const AppRatingPrompt({
    required this.promptId,
    required this.outcome,
    required this.shownAt,
    required this.sessionCount,
    required this.starRating,
  });

  final String promptId;
  final RatingPromptOutcome outcome;
  final DateTime shownAt;
  final int sessionCount;

  /// Null when outcome is not 'rated'.
  final int? starRating;

  AppRatingPrompt copyWith({
    String? promptId,
    RatingPromptOutcome? outcome,
    DateTime? shownAt,
    int? sessionCount,
    int? starRating,
  }) => AppRatingPrompt(
    promptId: promptId ?? this.promptId,
    outcome: outcome ?? this.outcome,
    shownAt: shownAt ?? this.shownAt,
    sessionCount: sessionCount ?? this.sessionCount,
    starRating: starRating ?? this.starRating,
  );

  @override
  List<Object?> get props => [
    promptId,
    outcome,
    shownAt,
    sessionCount,
    starRating,
  ];
}
