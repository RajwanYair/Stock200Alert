import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialSentimentSignal', () {
    SocialSentimentSignal buildSignal({
      SocialSentimentDirection direction =
          SocialSentimentDirection.strongBullish,
      int totalMentions = 2000,
      int bullishMentions = 1500,
      int bearishMentions = 200,
      double sentimentScore = 0.75,
    }) => SocialSentimentSignal(
      ticker: 'AAPL',
      platform: SentimentPlatform.reddit,
      direction: direction,
      observedAt: DateTime(2024, 6, 1),
      totalMentions: totalMentions,
      bullishMentions: bullishMentions,
      bearishMentions: bearishMentions,
      sentimentScore: sentimentScore,
    );

    test('bullishPct returns correct percentage', () {
      expect(
        buildSignal(totalMentions: 200, bullishMentions: 50).bullishPct,
        closeTo(25.0, 0.001),
      );
    });

    test('bullishPct is 0 when totalMentions is 0', () {
      expect(buildSignal(totalMentions: 0, bullishMentions: 0).bullishPct, 0);
    });

    test('isBullish is true for bullish direction', () {
      expect(
        buildSignal(direction: SocialSentimentDirection.bullish).isBullish,
        isTrue,
      );
    });

    test('isBullish is true for strongBullish direction', () {
      expect(
        buildSignal(
          direction: SocialSentimentDirection.strongBullish,
        ).isBullish,
        isTrue,
      );
    });

    test('isBullish is false for bearish direction', () {
      expect(
        buildSignal(direction: SocialSentimentDirection.bearish).isBullish,
        isFalse,
      );
    });

    test('isBearish is true for bearish direction', () {
      expect(
        buildSignal(direction: SocialSentimentDirection.bearish).isBearish,
        isTrue,
      );
    });

    test('isBearish is true for strongBearish direction', () {
      expect(
        buildSignal(
          direction: SocialSentimentDirection.strongBearish,
        ).isBearish,
        isTrue,
      );
    });

    test('isBearish is false for bullish direction', () {
      expect(
        buildSignal(direction: SocialSentimentDirection.bullish).isBearish,
        isFalse,
      );
    });

    test('isHighActivity is true when totalMentions >= 1000', () {
      expect(buildSignal(totalMentions: 1000).isHighActivity, isTrue);
    });

    test('isHighActivity is false when totalMentions < 1000', () {
      expect(buildSignal(totalMentions: 999).isHighActivity, isFalse);
    });

    test('equality holds for same props', () {
      expect(buildSignal(), equals(buildSignal()));
    });
  });
}
