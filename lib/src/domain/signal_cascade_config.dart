import 'package:equatable/equatable.dart';

/// Signal cascade config — multi-signal trigger composition rules.
enum CascadeTriggerMode { sequential, concurrent, threshold, veto }

class SignalCascadeConfig extends Equatable {
  const SignalCascadeConfig({
    required this.configId,
    required this.name,
    required this.triggerMode,
    required this.minimumSignals,
    required this.isEnabled,
  });

  final String configId;
  final String name;
  final CascadeTriggerMode triggerMode;
  final int minimumSignals;
  final bool isEnabled;

  SignalCascadeConfig copyWith({
    String? configId,
    String? name,
    CascadeTriggerMode? triggerMode,
    int? minimumSignals,
    bool? isEnabled,
  }) => SignalCascadeConfig(
    configId: configId ?? this.configId,
    name: name ?? this.name,
    triggerMode: triggerMode ?? this.triggerMode,
    minimumSignals: minimumSignals ?? this.minimumSignals,
    isEnabled: isEnabled ?? this.isEnabled,
  );

  @override
  List<Object?> get props => [
    configId,
    name,
    triggerMode,
    minimumSignals,
    isEnabled,
  ];
}
