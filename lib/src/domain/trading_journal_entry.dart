import 'package:equatable/equatable.dart';

/// Trader emotional state at time of journal entry.
enum TraderEmotion {
  confident,
  fearful,
  greedy,
  neutral,
  anxious,
  disciplined,
  impulsive,
}

/// Outcome classification for a completed trade.
enum TradeOutcome { win, loss, breakeven, open }

/// A rich trade journal entry capturing context, psychology, and outcome.
class TradingJournalEntry extends Equatable {
  const TradingJournalEntry({
    required this.entryId,
    required this.symbol,
    required this.setupType,
    required this.emotion,
    required this.outcome,
    required this.recordedAt,
    this.reflection,
    this.pnl,
    this.riskRewardRatio,
    this.tags = const [],
  });

  final String entryId;
  final String symbol;

  /// Short label for the trade setup (e.g. 'Micho BUY', 'RSI oversold').
  final String setupType;
  final TraderEmotion emotion;
  final TradeOutcome outcome;
  final DateTime recordedAt;

  /// Free-form post-trade reflection.
  final String? reflection;
  final double? pnl;
  final double? riskRewardRatio;
  final List<String> tags;

  bool get isWin => outcome == TradeOutcome.win;
  bool get isLoss => outcome == TradeOutcome.loss;
  bool get isOpen => outcome == TradeOutcome.open;
  bool get isEmotional =>
      emotion == TraderEmotion.fearful ||
      emotion == TraderEmotion.greedy ||
      emotion == TraderEmotion.impulsive ||
      emotion == TraderEmotion.anxious;
  bool get hasPnl => pnl != null;

  @override
  List<Object?> get props => [
    entryId,
    symbol,
    setupType,
    emotion,
    outcome,
    recordedAt,
    reflection,
    pnl,
    riskRewardRatio,
    tags,
  ];
}
