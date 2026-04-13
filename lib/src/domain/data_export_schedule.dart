import 'package:equatable/equatable.dart';

/// Data export schedule — recurring data export job configuration.
enum ExportDataScope { alerts, watchlist, portfolio, all, custom }

class DataExportSchedule extends Equatable {
  const DataExportSchedule({
    required this.scheduleId,
    required this.dataScope,
    required this.cronExpression,
    required this.destinationPath,
    required this.isEnabled,
  });

  final String scheduleId;
  final ExportDataScope dataScope;
  final String cronExpression;
  final String destinationPath;
  final bool isEnabled;

  DataExportSchedule copyWith({
    String? scheduleId,
    ExportDataScope? dataScope,
    String? cronExpression,
    String? destinationPath,
    bool? isEnabled,
  }) => DataExportSchedule(
    scheduleId: scheduleId ?? this.scheduleId,
    dataScope: dataScope ?? this.dataScope,
    cronExpression: cronExpression ?? this.cronExpression,
    destinationPath: destinationPath ?? this.destinationPath,
    isEnabled: isEnabled ?? this.isEnabled,
  );

  @override
  List<Object?> get props => [
    scheduleId,
    dataScope,
    cronExpression,
    destinationPath,
    isEnabled,
  ];
}
