import 'package:equatable/equatable.dart';

/// Signal filter config — declarative field filter for signal stream.
enum SignalFilterField { ticker, method, alertType, confidence, direction }

class SignalFilterConfig extends Equatable {
  const SignalFilterConfig({
    required this.filterId,
    required this.filterField,
    required this.filterOperator,
    required this.value,
    required this.isActive,
  });

  final String filterId;
  final SignalFilterField filterField;
  final String filterOperator;
  final String value;
  final bool isActive;

  SignalFilterConfig copyWith({
    String? filterId,
    SignalFilterField? filterField,
    String? filterOperator,
    String? value,
    bool? isActive,
  }) => SignalFilterConfig(
    filterId: filterId ?? this.filterId,
    filterField: filterField ?? this.filterField,
    filterOperator: filterOperator ?? this.filterOperator,
    value: value ?? this.value,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    filterId,
    filterField,
    filterOperator,
    value,
    isActive,
  ];
}
