import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AchievementTier', () {
    test('creates tier correctly', () {
      const tier = AchievementTier(name: 'Bronze', requiredPoints: 100);
      expect(tier.name, 'Bronze');
      expect(tier.requiredPoints, 100);
      expect(tier.badgeIcon, isNull);
    });
  });

  group('UserAchievement', () {
    test('currentTier is null before any points', () {
      final ach = UserAchievement(
        achievementId: 'ach-1',
        title: 'Watcher',
        description: 'Track 10 tickers',
        currentPoints: 0,
        tiers: const [
          AchievementTier(name: 'Bronze', requiredPoints: 10),
          AchievementTier(name: 'Silver', requiredPoints: 50),
          AchievementTier(name: 'Gold', requiredPoints: 100),
        ],
      );
      expect(ach.currentTier, isNull);
      expect(ach.nextTier!.name, 'Bronze');
      expect(ach.isMaxTier, isFalse);
    });

    test('currentTier and nextTier update with points', () {
      final ach = UserAchievement(
        achievementId: 'ach-2',
        title: 'Trader',
        description: 'Make 50 trades',
        currentPoints: 30,
        tiers: const [
          AchievementTier(name: 'Bronze', requiredPoints: 10),
          AchievementTier(name: 'Silver', requiredPoints: 50),
        ],
      );
      expect(ach.currentTier!.name, 'Bronze');
      expect(ach.nextTier!.name, 'Silver');
      expect(ach.isMaxTier, isFalse);
    });

    test('isMaxTier true when all tiers reached', () {
      final ach = UserAchievement(
        achievementId: 'ach-3',
        title: 'Legend',
        description: 'All tiers',
        currentPoints: 200,
        tiers: const [AchievementTier(name: 'Gold', requiredPoints: 100)],
        isUnlocked: true,
      );
      expect(ach.isMaxTier, isTrue);
      expect(ach.progressToNextTier, 1.0);
    });

    test('progressToNextTier is a fraction between 0 and 1', () {
      final ach = UserAchievement(
        achievementId: 'ach-4',
        title: 'Scout',
        description: 'Check prices',
        currentPoints: 25,
        tiers: const [
          AchievementTier(name: 'Bronze', requiredPoints: 10),
          AchievementTier(name: 'Silver', requiredPoints: 50),
        ],
      );
      expect(ach.progressToNextTier, closeTo(0.375, 0.001));
    });

    test('equality holds for identical achievements', () {
      final a = UserAchievement(
        achievementId: 'x',
        title: 'T',
        description: 'D',
        currentPoints: 5,
        tiers: const [AchievementTier(name: 'A', requiredPoints: 10)],
      );
      final b = UserAchievement(
        achievementId: 'x',
        title: 'T',
        description: 'D',
        currentPoints: 5,
        tiers: const [AchievementTier(name: 'A', requiredPoints: 10)],
      );
      expect(a, equals(b));
    });
  });
}
