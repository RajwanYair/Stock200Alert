import 'package:equatable/equatable.dart';

/// How often a report is generated.
enum ReportFrequency { daily, weekly, monthly, onDemand }

/// Channel through which a report is delivered.
enum ReportDeliveryChannel { email, inApp, fileExport, webhook }

/// Scheduled delivery configuration for a named report template.
class ReportSchedule extends Equatable {
  const ReportSchedule({
    required this.id,
    required this.reportTemplateId,
    required this.frequency,
    required this.deliveryChannel,
    required this.createdAt,
    this.recipients = const [],
    this.isEnabled = true,
    this.lastRunAt,
    this.nextRunAt,
  });

  final String id;
  final String reportTemplateId;
  final ReportFrequency frequency;
  final ReportDeliveryChannel deliveryChannel;
  final DateTime createdAt;
  final List<String> recipients;
  final bool isEnabled;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;

  bool get hasRecipients => recipients.isNotEmpty;
  bool get hasRun => lastRunAt != null;

  bool isDueAt(DateTime now) =>
      isEnabled && nextRunAt != null && !now.isBefore(nextRunAt!);

  ReportSchedule withNextRun(DateTime nextRun) => ReportSchedule(
    id: id,
    reportTemplateId: reportTemplateId,
    frequency: frequency,
    deliveryChannel: deliveryChannel,
    createdAt: createdAt,
    recipients: recipients,
    isEnabled: isEnabled,
    lastRunAt: lastRunAt,
    nextRunAt: nextRun,
  );

  @override
  List<Object?> get props => [
    id,
    reportTemplateId,
    frequency,
    deliveryChannel,
    createdAt,
    recipients,
    isEnabled,
    lastRunAt,
    nextRunAt,
  ];
}
