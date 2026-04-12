import 'package:equatable/equatable.dart';

/// A/B experiment variant assignment for a user (S549).
class AbTestAssignment extends Equatable {
  const AbTestAssignment({
    required this.assignmentId,
    required this.experimentId,
    required this.userId,
    required this.variantName,
    required this.assignedAtMs,
    this.isControl = false,
  });

  final String assignmentId;
  final String experimentId;
  final String userId;

  /// Name of the assigned experiment variant (e.g. 'control', 'treatment_a').
  final String variantName;

  /// Epoch milliseconds when the assignment was made.
  final int assignedAtMs;

  /// True when this assignment is the baseline control variant.
  final bool isControl;

  bool get isTreatment => !isControl;
  bool get hasVariant => variantName.isNotEmpty;

  @override
  List<Object?> get props => [
    assignmentId,
    experimentId,
    userId,
    variantName,
    assignedAtMs,
    isControl,
  ];
}
