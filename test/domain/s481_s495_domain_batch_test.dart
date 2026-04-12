import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── S481: StrategyComparisonResult ───────────────────────────────────────
  group('StrategyComparisonResult', () {
    test('compareOutperforms true when compare return > base return', () {
      const StrategyComparisonResult r = StrategyComparisonResult(
        baseStrategyId: 'micho',
        compareStrategyId: 'macd',
        baseReturnPercent: 12.0,
        compareReturnPercent: 18.0,
        baseSharpe: 0.9,
        compareSharpe: 1.2,
        periodDays: 252,
      );
      expect(r.compareOutperforms, isTrue);
      expect(r.compareHasBetterSharpe, isTrue);
      expect(r.returnDeltaPercent, closeTo(6.0, 0.01));
    });

    test('compareOutperforms false when base return > compare return', () {
      const StrategyComparisonResult r = StrategyComparisonResult(
        baseStrategyId: 'micho',
        compareStrategyId: 'rsi',
        baseReturnPercent: 20.0,
        compareReturnPercent: 10.0,
        baseSharpe: 1.5,
        compareSharpe: 0.7,
        periodDays: 126,
      );
      expect(r.compareOutperforms, isFalse);
      expect(r.compareHasBetterSharpe, isFalse);
      expect(r.returnDeltaPercent, closeTo(-10.0, 0.01));
    });

    test('equality', () {
      const StrategyComparisonResult a = StrategyComparisonResult(
        baseStrategyId: 'a',
        compareStrategyId: 'b',
        baseReturnPercent: 5.0,
        compareReturnPercent: 7.0,
        baseSharpe: 0.8,
        compareSharpe: 1.0,
        periodDays: 252,
      );
      const StrategyComparisonResult b = StrategyComparisonResult(
        baseStrategyId: 'a',
        compareStrategyId: 'b',
        baseReturnPercent: 5.0,
        compareReturnPercent: 7.0,
        baseSharpe: 0.8,
        compareSharpe: 1.0,
        periodDays: 252,
      );
      expect(a, equals(b));
    });
  });

  // ── S482: WalkForwardSegment ───────────────────────────────────────────────
  group('WalkForwardSegment', () {
    test('trainDays and testDays computed correctly', () {
      const WalkForwardSegment seg = WalkForwardSegment(
        segmentIndex: 0,
        trainStartDay: 0,
        trainEndDay: 200,
        testStartDay: 200,
        testEndDay: 252,
        testReturnPercent: 8.5,
        testSharpe: 0.75,
      );
      expect(seg.trainDays, equals(200));
      expect(seg.testDays, equals(52));
      expect(seg.isProfitable, isTrue);
      expect(seg.isGoodFit, isTrue);
    });

    test('isProfitable false for negative out-of-sample return', () {
      const WalkForwardSegment seg = WalkForwardSegment(
        segmentIndex: 1,
        trainStartDay: 200,
        trainEndDay: 400,
        testStartDay: 400,
        testEndDay: 452,
        testReturnPercent: -2.0,
        testSharpe: 0.3,
      );
      expect(seg.isProfitable, isFalse);
      expect(seg.isGoodFit, isFalse);
    });

    test('equality', () {
      const WalkForwardSegment a = WalkForwardSegment(
        segmentIndex: 0,
        trainStartDay: 0,
        trainEndDay: 100,
        testStartDay: 100,
        testEndDay: 130,
        testReturnPercent: 5.0,
        testSharpe: 1.0,
      );
      const WalkForwardSegment b = WalkForwardSegment(
        segmentIndex: 0,
        trainStartDay: 0,
        trainEndDay: 100,
        testStartDay: 100,
        testEndDay: 130,
        testReturnPercent: 5.0,
        testSharpe: 1.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S483: MonteCarloPercentile ────────────────────────────────────────────
  group('MonteCarloPercentile', () {
    test('isTopDecile true when percentile >= 90', () {
      const MonteCarloPercentile p = MonteCarloPercentile(
        runId: 'sim1',
        percentile: 95.0,
        finalEquity: 150000.0,
        maxDrawdownPercent: 8.0,
        totalReturnPercent: 50.0,
      );
      expect(p.isTopDecile, isTrue);
      expect(p.isBottomDecile, isFalse);
      expect(p.isProfitable, isTrue);
    });

    test('isBottomDecile true when percentile <= 10', () {
      const MonteCarloPercentile p = MonteCarloPercentile(
        runId: 'sim1',
        percentile: 5.0,
        finalEquity: 80000.0,
        maxDrawdownPercent: 35.0,
        totalReturnPercent: -20.0,
      );
      expect(p.isBottomDecile, isTrue);
      expect(p.isProfitable, isFalse);
    });

    test('equality', () {
      const MonteCarloPercentile a = MonteCarloPercentile(
        runId: 'r1',
        percentile: 50.0,
        finalEquity: 100000.0,
        maxDrawdownPercent: 15.0,
        totalReturnPercent: 0.0,
      );
      const MonteCarloPercentile b = MonteCarloPercentile(
        runId: 'r1',
        percentile: 50.0,
        finalEquity: 100000.0,
        maxDrawdownPercent: 15.0,
        totalReturnPercent: 0.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S484: BacktestEquityPoint ─────────────────────────────────────────────
  group('BacktestEquityPoint', () {
    test('isDeepDrawdown true when drawdown >= 20%', () {
      const BacktestEquityPoint pt = BacktestEquityPoint(
        backtestId: 'bt1',
        dayIndex: 100,
        equity: 80000.0,
        drawdownPercent: 20.0,
        cumulativeReturnPercent: -20.0,
      );
      expect(pt.isDeepDrawdown, isTrue);
      expect(pt.isDrawdown, isTrue);
      expect(pt.isProfitable, isFalse);
    });

    test('isDrawdown false at peak equity', () {
      const BacktestEquityPoint pt = BacktestEquityPoint(
        backtestId: 'bt1',
        dayIndex: 50,
        equity: 120000.0,
        drawdownPercent: 0.0,
        cumulativeReturnPercent: 20.0,
      );
      expect(pt.isDrawdown, isFalse);
      expect(pt.isProfitable, isTrue);
    });

    test('equality', () {
      const BacktestEquityPoint a = BacktestEquityPoint(
        backtestId: 'bt1',
        dayIndex: 0,
        equity: 100000.0,
        drawdownPercent: 0.0,
        cumulativeReturnPercent: 0.0,
      );
      const BacktestEquityPoint b = BacktestEquityPoint(
        backtestId: 'bt1',
        dayIndex: 0,
        equity: 100000.0,
        drawdownPercent: 0.0,
        cumulativeReturnPercent: 0.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S485: ExitRuleConfig ──────────────────────────────────────────────────
  group('ExitRuleConfig', () {
    test('isStopBased true for trailing stop', () {
      const ExitRuleConfig cfg = ExitRuleConfig(
        ruleId: 'er1',
        trigger: ExitTriggerType.trailingStop,
        triggerValue: 5.0,
        description: '5% trailing stop',
      );
      expect(cfg.isStopBased, isTrue);
      expect(cfg.isTimeBased, isFalse);
      expect(cfg.hasDescription, isTrue);
    });

    test('isTimeBased true for time exit', () {
      const ExitRuleConfig cfg = ExitRuleConfig(
        ruleId: 'er2',
        trigger: ExitTriggerType.timeExit,
        triggerValue: 20.0,
      );
      expect(cfg.isTimeBased, isTrue);
      expect(cfg.isStopBased, isFalse);
      expect(cfg.hasDescription, isFalse);
    });

    test('equality', () {
      const ExitRuleConfig a = ExitRuleConfig(
        ruleId: 'er1',
        trigger: ExitTriggerType.takeProfitTarget,
        triggerValue: 15.0,
      );
      const ExitRuleConfig b = ExitRuleConfig(
        ruleId: 'er1',
        trigger: ExitTriggerType.takeProfitTarget,
        triggerValue: 15.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S486: TutorialStepState ───────────────────────────────────────────────
  group('TutorialStepState', () {
    test('isFirstStep true at index 0', () {
      const TutorialStepState s = TutorialStepState(
        stepId: 'ts1',
        tutorialId: 'onboard',
        stepIndex: 0,
        isCompleted: false,
        timesViewed: 2,
      );
      expect(s.isFirstStep, isTrue);
      expect(s.wasEngaged, isTrue);
      expect(s.isDismissed, isFalse);
    });

    test('isDismissed true when skipped and not completed', () {
      const TutorialStepState s = TutorialStepState(
        stepId: 'ts2',
        tutorialId: 'onboard',
        stepIndex: 3,
        isCompleted: false,
        skippedByUser: true,
      );
      expect(s.isDismissed, isTrue);
      expect(s.isFirstStep, isFalse);
    });

    test('equality', () {
      const TutorialStepState a = TutorialStepState(
        stepId: 'ts1',
        tutorialId: 't1',
        stepIndex: 1,
        isCompleted: true,
      );
      const TutorialStepState b = TutorialStepState(
        stepId: 'ts1',
        tutorialId: 't1',
        stepIndex: 1,
        isCompleted: true,
      );
      expect(a, equals(b));
    });
  });

  // ── S487: FeatureTourConfig ───────────────────────────────────────────────
  group('FeatureTourConfig', () {
    test('isMultiStep true for stepCount > 1', () {
      const FeatureTourConfig cfg = FeatureTourConfig(
        tourId: 'ft1',
        tourName: 'Watchlist Tour',
        stepCount: 5,
        repeatOnVersionUpgrade: true,
      );
      expect(cfg.isMultiStep, isTrue);
      expect(cfg.isSingleStep, isFalse);
      expect(cfg.repeatOnVersionUpgrade, isTrue);
    });

    test('isSingleStep true for stepCount of 1', () {
      const FeatureTourConfig cfg = FeatureTourConfig(
        tourId: 'ft2',
        tourName: 'Quick Intro',
        stepCount: 1,
      );
      expect(cfg.isSingleStep, isTrue);
      expect(cfg.isMultiStep, isFalse);
    });

    test('equality', () {
      const FeatureTourConfig a = FeatureTourConfig(
        tourId: 'ft1',
        tourName: 'My Tour',
        stepCount: 3,
      );
      const FeatureTourConfig b = FeatureTourConfig(
        tourId: 'ft1',
        tourName: 'My Tour',
        stepCount: 3,
      );
      expect(a, equals(b));
    });
  });

  // ── S488: AppNotificationBadge ────────────────────────────────────────────
  group('AppNotificationBadge', () {
    test('shouldDisplay true when visible and has items', () {
      const AppNotificationBadge badge = AppNotificationBadge(
        badgeId: 'nb1',
        section: 'alerts',
        count: 5,
        isPriority: true,
      );
      expect(badge.shouldDisplay, isTrue);
      expect(badge.hasItems, isTrue);
      expect(badge.isHighCount, isFalse);
    });

    test('shouldDisplay false when count is zero', () {
      const AppNotificationBadge badge = AppNotificationBadge(
        badgeId: 'nb2',
        section: 'watchlist',
        count: 0,
      );
      expect(badge.shouldDisplay, isFalse);
      expect(badge.hasItems, isFalse);
    });

    test('isHighCount true when count >= 10', () {
      const AppNotificationBadge badge = AppNotificationBadge(
        badgeId: 'nb3',
        section: 'digest',
        count: 15,
      );
      expect(badge.isHighCount, isTrue);
    });

    test('equality', () {
      const AppNotificationBadge a = AppNotificationBadge(
        badgeId: 'nb1',
        section: 'alerts',
        count: 3,
      );
      const AppNotificationBadge b = AppNotificationBadge(
        badgeId: 'nb1',
        section: 'alerts',
        count: 3,
      );
      expect(a, equals(b));
    });
  });

  // ── S489: UserOnboardingProgress ─────────────────────────────────────────
  group('UserOnboardingProgress', () {
    test('progressPercent computed correctly', () {
      const UserOnboardingProgress p = UserOnboardingProgress(
        userId: 'u1',
        totalSteps: 5,
        completedSteps: 2,
        hasAddedFirstTicker: true,
      );
      expect(p.progressPercent, closeTo(40.0, 0.01));
      expect(p.isStarted, isTrue);
      expect(p.isComplete, isFalse);
    });

    test('isComplete true when all steps completed', () {
      const UserOnboardingProgress p = UserOnboardingProgress(
        userId: 'u2',
        totalSteps: 4,
        completedSteps: 4,
      );
      expect(p.isComplete, isTrue);
      expect(p.progressPercent, closeTo(100.0, 0.01));
    });

    test('progressPercent is 100 when totalSteps is zero', () {
      const UserOnboardingProgress p = UserOnboardingProgress(
        userId: 'u3',
        totalSteps: 0,
        completedSteps: 0,
      );
      expect(p.progressPercent, equals(100.0));
    });

    test('equality', () {
      const UserOnboardingProgress a = UserOnboardingProgress(
        userId: 'u1',
        totalSteps: 5,
        completedSteps: 3,
      );
      const UserOnboardingProgress b = UserOnboardingProgress(
        userId: 'u1',
        totalSteps: 5,
        completedSteps: 3,
      );
      expect(a, equals(b));
    });
  });

  // ── S490: ContextualHelpEntry ─────────────────────────────────────────────
  group('ContextualHelpEntry', () {
    test('hasLearnMoreLink true when URL provided', () {
      const ContextualHelpEntry entry = ContextualHelpEntry(
        helpId: 'h1',
        screenKey: 'watchlist',
        title: 'How Watchlists Work',
        body: 'Add tickers to track SMA crossovers.',
        learnMoreUrl: 'https://docs.crosstide.app/watchlist',
        isPriority: true,
      );
      expect(entry.hasLearnMoreLink, isTrue);
      expect(entry.isShortBody, isTrue);
    });

    test('hasLearnMoreLink false without URL', () {
      const ContextualHelpEntry entry = ContextualHelpEntry(
        helpId: 'h2',
        screenKey: 'alerts',
        title: 'Alert Types',
        body: 'Alerts fire when SMA cross conditions are met.',
      );
      expect(entry.hasLearnMoreLink, isFalse);
    });

    test('equality', () {
      const ContextualHelpEntry a = ContextualHelpEntry(
        helpId: 'h1',
        screenKey: 'home',
        title: 'Welcome',
        body: 'Quick intro text.',
      );
      const ContextualHelpEntry b = ContextualHelpEntry(
        helpId: 'h1',
        screenKey: 'home',
        title: 'Welcome',
        body: 'Quick intro text.',
      );
      expect(a, equals(b));
    });
  });

  // ── S491: DefiPoolSnapshot ────────────────────────────────────────────────
  group('DefiPoolSnapshot', () {
    test('isHighYield and isHighLiquidity for large pool', () {
      const DefiPoolSnapshot pool = DefiPoolSnapshot(
        poolId: 'pool1',
        protocolName: 'Uniswap v3',
        tokenPair: 'ETH/USDC',
        totalValueLockedUsd: 5000000.0,
        apyPercent: 25.0,
        volumeLast24hUsd: 1000000.0,
      );
      expect(pool.isHighYield, isTrue);
      expect(pool.isHighLiquidity, isTrue);
      expect(pool.isActivePool, isTrue);
    });

    test('isHighYield false for low APY pool', () {
      const DefiPoolSnapshot pool = DefiPoolSnapshot(
        poolId: 'pool2',
        protocolName: 'Curve',
        tokenPair: 'USDC/DAI',
        totalValueLockedUsd: 500000.0,
        apyPercent: 3.0,
        volumeLast24hUsd: 0.0,
      );
      expect(pool.isHighYield, isFalse);
      expect(pool.isActivePool, isFalse);
    });

    test('equality', () {
      const DefiPoolSnapshot a = DefiPoolSnapshot(
        poolId: 'p1',
        protocolName: 'Aave',
        tokenPair: 'WBTC/ETH',
        totalValueLockedUsd: 1000000.0,
        apyPercent: 10.0,
        volumeLast24hUsd: 50000.0,
      );
      const DefiPoolSnapshot b = DefiPoolSnapshot(
        poolId: 'p1',
        protocolName: 'Aave',
        tokenPair: 'WBTC/ETH',
        totalValueLockedUsd: 1000000.0,
        apyPercent: 10.0,
        volumeLast24hUsd: 50000.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S492: NftFloorPriceEntry ──────────────────────────────────────────────
  group('NftFloorPriceEntry', () {
    test('isBlueChip true for floor >= 1 ETH', () {
      const NftFloorPriceEntry entry = NftFloorPriceEntry(
        collectionSlug: 'bored-apes',
        collectionName: 'Bored Ape Yacht Club',
        floorPriceEth: 15.0,
        floorPriceUsd: 30000.0,
        volume24hEth: 500.0,
        holderCount: 6000,
      );
      expect(entry.isBlueChip, isTrue);
      expect(entry.isHighVolume, isTrue);
      expect(entry.hasLargeHolder, isTrue);
    });

    test('isBlueChip false for sub-1-ETH floor', () {
      const NftFloorPriceEntry entry = NftFloorPriceEntry(
        collectionSlug: 'micro-nft',
        collectionName: 'MicroNFT',
        floorPriceEth: 0.05,
        floorPriceUsd: 100.0,
        volume24hEth: 2.0,
        holderCount: 300,
      );
      expect(entry.isBlueChip, isFalse);
      expect(entry.isHighVolume, isFalse);
      expect(entry.hasLargeHolder, isFalse);
    });

    test('equality', () {
      const NftFloorPriceEntry a = NftFloorPriceEntry(
        collectionSlug: 'slug1',
        collectionName: 'Test Collection',
        floorPriceEth: 1.0,
        floorPriceUsd: 2000.0,
        volume24hEth: 50.0,
        holderCount: 1000,
      );
      const NftFloorPriceEntry b = NftFloorPriceEntry(
        collectionSlug: 'slug1',
        collectionName: 'Test Collection',
        floorPriceEth: 1.0,
        floorPriceUsd: 2000.0,
        volume24hEth: 50.0,
        holderCount: 1000,
      );
      expect(a, equals(b));
    });
  });

  // ── S493: StakingRewardRecord ─────────────────────────────────────────────
  group('StakingRewardRecord', () {
    test('isHighApr and hasSignificantReward for good staking position', () {
      const StakingRewardRecord r = StakingRewardRecord(
        recordId: 'sr1',
        validatorId: 'val1',
        assetSymbol: 'ETH',
        rewardAmount: 0.05,
        epochNumber: 200,
        aprPercent: 12.0,
      );
      expect(r.isHighApr, isTrue);
      expect(r.isPending, isTrue);
      expect(r.hasSignificantReward, isTrue);
    });

    test('isPending false when claimed', () {
      const StakingRewardRecord r = StakingRewardRecord(
        recordId: 'sr2',
        validatorId: 'val2',
        assetSymbol: 'SOL',
        rewardAmount: 2.0,
        epochNumber: 500,
        aprPercent: 7.0,
        isClaimed: true,
      );
      expect(r.isPending, isFalse);
      expect(r.isHighApr, isFalse);
    });

    test('equality', () {
      const StakingRewardRecord a = StakingRewardRecord(
        recordId: 'sr1',
        validatorId: 'v1',
        assetSymbol: 'ETH',
        rewardAmount: 0.1,
        epochNumber: 100,
        aprPercent: 5.0,
      );
      const StakingRewardRecord b = StakingRewardRecord(
        recordId: 'sr1',
        validatorId: 'v1',
        assetSymbol: 'ETH',
        rewardAmount: 0.1,
        epochNumber: 100,
        aprPercent: 5.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S494: CacheEvictionPolicy ─────────────────────────────────────────────
  group('CacheEvictionPolicy', () {
    test('isAggressiveEviction true for short TTL', () {
      const CacheEvictionPolicy pol = CacheEvictionPolicy(
        policyId: 'cep1',
        cacheName: 'quote_cache',
        strategy: EvictionStrategy.lru,
        maxEntries: 200,
        ttlSeconds: 30,
      );
      expect(pol.isAggressiveEviction, isTrue);
      expect(pol.isLruOrLfu, isTrue);
    });

    test('isAggressiveEviction true for small maxEntries', () {
      const CacheEvictionPolicy pol = CacheEvictionPolicy(
        policyId: 'cep2',
        cacheName: 'candle_cache',
        strategy: EvictionStrategy.fifo,
        maxEntries: 10,
        ttlSeconds: 300,
      );
      expect(pol.isAggressiveEviction, isTrue);
      expect(pol.isLruOrLfu, isFalse);
    });

    test('isAggressiveEviction false for relaxed policy', () {
      const CacheEvictionPolicy pol = CacheEvictionPolicy(
        policyId: 'cep3',
        cacheName: 'news_cache',
        strategy: EvictionStrategy.lfu,
        maxEntries: 1000,
        ttlSeconds: 3600,
      );
      expect(pol.isAggressiveEviction, isFalse);
      expect(pol.isLruOrLfu, isTrue);
    });

    test('equality', () {
      const CacheEvictionPolicy a = CacheEvictionPolicy(
        policyId: 'cep1',
        cacheName: 'c1',
        strategy: EvictionStrategy.ttlOnly,
        maxEntries: 500,
        ttlSeconds: 120,
      );
      const CacheEvictionPolicy b = CacheEvictionPolicy(
        policyId: 'cep1',
        cacheName: 'c1',
        strategy: EvictionStrategy.ttlOnly,
        maxEntries: 500,
        ttlSeconds: 120,
      );
      expect(a, equals(b));
    });
  });

  // ── S495: DatabaseMigrationLog ────────────────────────────────────────────
  group('DatabaseMigrationLog', () {
    test('isSuccess and isSlowMigration for completed slow migration', () {
      const DatabaseMigrationLog log = DatabaseMigrationLog(
        migrationId: 'mig1',
        fromVersion: 15,
        toVersion: 16,
        status: MigrationStatus.completed,
        durationMs: 8000,
      );
      expect(log.isSuccess, isTrue);
      expect(log.isSlowMigration, isTrue);
      expect(log.isFailed, isFalse);
      expect(log.hasError, isFalse);
    });

    test('isFailed and hasError for failed migration', () {
      const DatabaseMigrationLog log = DatabaseMigrationLog(
        migrationId: 'mig2',
        fromVersion: 14,
        toVersion: 15,
        status: MigrationStatus.failed,
        durationMs: 200,
        errorMessage: 'Constraint violation on table ticker_alert',
      );
      expect(log.isFailed, isTrue);
      expect(log.hasError, isTrue);
      expect(log.isSuccess, isFalse);
    });

    test('equality', () {
      const DatabaseMigrationLog a = DatabaseMigrationLog(
        migrationId: 'mig1',
        fromVersion: 1,
        toVersion: 2,
        status: MigrationStatus.skipped,
        durationMs: 0,
      );
      const DatabaseMigrationLog b = DatabaseMigrationLog(
        migrationId: 'mig1',
        fromVersion: 1,
        toVersion: 2,
        status: MigrationStatus.skipped,
        durationMs: 0,
      );
      expect(a, equals(b));
    });
  });
}
