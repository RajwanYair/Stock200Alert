import 'package:equatable/equatable.dart';

/// Category for classifying in-app feedback.
enum FeedbackCategory {
  bugReport,
  featureRequest,
  performance,
  dataAccuracy,
  uiUx,
  other,
}

/// Lifecycle state of a [FeedbackSubmission].
enum FeedbackStatus { pending, received, inProgress, resolved, dismissed }

/// An in-app user feedback submission.
class FeedbackSubmission extends Equatable {
  const FeedbackSubmission({
    required this.id,
    required this.category,
    required this.message,
    required this.appVersion,
    required this.submittedAt,
    this.status = FeedbackStatus.pending,
    this.deviceInfo,
    this.contactEmail,
    this.screenshotRef,
  }) : assert(message.length >= 10, 'message must be at least 10 characters');

  final String id;
  final FeedbackCategory category;
  final String message;
  final String appVersion;
  final DateTime submittedAt;
  final FeedbackStatus status;
  final String? deviceInfo;
  final String? contactEmail;
  final String? screenshotRef;

  bool get isPending => status == FeedbackStatus.pending;
  bool get isResolved => status == FeedbackStatus.resolved;
  bool get hasContactInfo => contactEmail != null;

  FeedbackSubmission withStatus(FeedbackStatus newStatus) => FeedbackSubmission(
    id: id,
    category: category,
    message: message,
    appVersion: appVersion,
    submittedAt: submittedAt,
    status: newStatus,
    deviceInfo: deviceInfo,
    contactEmail: contactEmail,
    screenshotRef: screenshotRef,
  );

  @override
  List<Object?> get props => [
    id,
    category,
    message,
    appVersion,
    submittedAt,
    status,
    deviceInfo,
    contactEmail,
    screenshotRef,
  ];
}
