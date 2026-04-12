import 'package:equatable/equatable.dart';

/// A single in-sample/out-of-sample segment from walk-forward analysis (S482).
class WalkForwardSegment extends Equatable {
  const WalkForwardSegment({
    required this.segmentIndex,
    required this.trainStartDay,
    required this.trainEndDay,
    required this.testStartDay,
    required this.testEndDay,
    required this.testReturnPercent,
    required this.testSharpe,
  });

  /// Zero-based segment index within the walk-forward sequence.
  final int segmentIndex;
  final int trainStartDay;
  final int trainEndDay;
  final int testStartDay;
  final int testEndDay;

  /// Out-of-sample return for this segment.
  final double testReturnPercent;
  final double testSharpe;

  int get trainDays => trainEndDay - trainStartDay;
  int get testDays => testEndDay - testStartDay;
  bool get isProfitable => testReturnPercent > 0;
  bool get isGoodFit => testSharpe >= 0.5;

  @override
  List<Object?> get props => [
    segmentIndex,
    trainStartDay,
    trainEndDay,
    testStartDay,
    testEndDay,
    testReturnPercent,
    testSharpe,
  ];
}
