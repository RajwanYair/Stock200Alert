import 'package:equatable/equatable.dart';

/// Category of a stock-level corporate action.
enum CorporateActionType {
  stockSplit,
  reverseSplit,
  spinOff,
  merger,
  acquisition,
  dividendSpecial,
  tickerChange,
  delisting,
}

/// A corporate action event for a given ticker.
class CorporateActionEvent extends Equatable {
  const CorporateActionEvent({
    required this.symbol,
    required this.actionType,
    required this.effectiveDate,
    this.splitRatio,
    this.notes,
  });

  final String symbol;
  final CorporateActionType actionType;
  final DateTime effectiveDate;

  /// Applicable to splits: new-shares-per-old-share (e.g. 2.0 = 2-for-1).
  final double? splitRatio;
  final String? notes;

  bool get isSplit =>
      actionType == CorporateActionType.stockSplit ||
      actionType == CorporateActionType.reverseSplit;

  bool get isReverseSplit => actionType == CorporateActionType.reverseSplit;

  bool get isDelisting => actionType == CorporateActionType.delisting;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  List<Object?> get props => [
    symbol,
    actionType,
    effectiveDate,
    splitRatio,
    notes,
  ];
}
