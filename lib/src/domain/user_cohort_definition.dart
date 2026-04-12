import 'package:equatable/equatable.dart';

/// User segmentation cohort definition for analytics and targeting (S550).
class UserCohortDefinition extends Equatable {
  const UserCohortDefinition({
    required this.cohortId,
    required this.cohortName,
    required this.description,
    required this.memberCount,
    required this.filterExpression,
    this.isActive = true,
  });

  final String cohortId;
  final String cohortName;
  final String description;

  /// Current number of users in this cohort.
  final int memberCount;

  /// Declarative filter expression used to include users.
  final String filterExpression;
  final bool isActive;

  bool get isEmpty => memberCount == 0;
  bool get isLargeCohort => memberCount >= 1000;
  bool get hasDescription => description.isNotEmpty;

  @override
  List<Object?> get props => [
    cohortId,
    cohortName,
    description,
    memberCount,
    filterExpression,
    isActive,
  ];
}
