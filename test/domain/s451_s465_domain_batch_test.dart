import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── S451: TaxYearSummary ──────────────────────────────────────────────────
  group('TaxYearSummary', () {
    test('netShortTerm and netLongTerm computed correctly', () {
      const TaxYearSummary s = TaxYearSummary(
        taxYear: 2025,
        shortTermGains: 5000,
        longTermGains: 8000,
        shortTermLosses: 2000,
        longTermLosses: 1000,
        dividendIncome: 300,
      );
      expect(s.netShortTerm, equals(3000));
      expect(s.netLongTerm, equals(7000));
      expect(s.totalNetGain, equals(10000));
      expect(s.isNetPositive, isTrue);
      expect(s.hasNetLoss, isFalse);
    });

    test('hasNetLoss true when net negative', () {
      const TaxYearSummary s = TaxYearSummary(
        taxYear: 2024,
        shortTermGains: 1000,
        longTermGains: 500,
        shortTermLosses: 3000,
        longTermLosses: 2000,
        dividendIncome: 0,
      );
      expect(s.hasNetLoss, isTrue);
      expect(s.isNetPositive, isFalse);
    });

    test('equality', () {
      const TaxYearSummary a = TaxYearSummary(
        taxYear: 2025,
        shortTermGains: 1000,
        longTermGains: 2000,
        shortTermLosses: 500,
        longTermLosses: 200,
        dividendIncome: 100,
      );
      const TaxYearSummary b = TaxYearSummary(
        taxYear: 2025,
        shortTermGains: 1000,
        longTermGains: 2000,
        shortTermLosses: 500,
        longTermLosses: 200,
        dividendIncome: 100,
      );
      expect(a, equals(b));
    });
  });

  // ── S452: PriceLevelCluster ───────────────────────────────────────────────
  group('PriceLevelCluster', () {
    test('isStrongLevel true when touchCount >= 3', () {
      const PriceLevelCluster cluster = PriceLevelCluster(
        ticker: 'AAPL',
        priceLevel: 175.0,
        volumeConcentration: 0.20,
        clusterWidth: 2.0,
        touchCount: 4,
        isSupport: true,
      );
      expect(cluster.isStrongLevel, isTrue);
      expect(cluster.isHighConcentration, isTrue);
      expect(cluster.isResistance, isFalse);
    });

    test('isHighConcentration false below threshold', () {
      const PriceLevelCluster cluster = PriceLevelCluster(
        ticker: 'MSFT',
        priceLevel: 400.0,
        volumeConcentration: 0.10,
        clusterWidth: 3.0,
        touchCount: 1,
        isSupport: false,
      );
      expect(cluster.isHighConcentration, isFalse);
      expect(cluster.isStrongLevel, isFalse);
      expect(cluster.isResistance, isTrue);
    });

    test('equality', () {
      const PriceLevelCluster a = PriceLevelCluster(
        ticker: 'SPY',
        priceLevel: 500.0,
        volumeConcentration: 0.18,
        clusterWidth: 1.5,
        touchCount: 5,
      );
      const PriceLevelCluster b = PriceLevelCluster(
        ticker: 'SPY',
        priceLevel: 500.0,
        volumeConcentration: 0.18,
        clusterWidth: 1.5,
        touchCount: 5,
      );
      expect(a, equals(b));
    });
  });

  // ── S453: MarketRegimeClassification ─────────────────────────────────────
  group('MarketRegimeClassification', () {
    test('isTrending true for bull/bear regimes', () {
      const MarketRegimeClassification mc = MarketRegimeClassification(
        ticker: 'SPY',
        regime: RegimeClassificationType.bullTrending,
        confidenceScore: 0.85,
        adxValue: 32.0,
        atrPercent: 1.2,
      );
      expect(mc.isTrending, isTrue);
      expect(mc.isRangebound, isFalse);
      expect(mc.isHighConfidence, isTrue);
    });

    test('isRangebound true for rangebound regime', () {
      const MarketRegimeClassification mc = MarketRegimeClassification(
        ticker: 'AAPL',
        regime: RegimeClassificationType.rangebound,
        confidenceScore: 0.60,
        adxValue: 18.0,
        atrPercent: 0.8,
      );
      expect(mc.isRangebound, isTrue);
      expect(mc.isTrending, isFalse);
      expect(mc.isHighConfidence, isFalse);
    });

    test('equality', () {
      const MarketRegimeClassification a = MarketRegimeClassification(
        ticker: 'QQQ',
        regime: RegimeClassificationType.highVolatility,
        confidenceScore: 0.70,
        adxValue: 25.0,
        atrPercent: 2.5,
      );
      const MarketRegimeClassification b = MarketRegimeClassification(
        ticker: 'QQQ',
        regime: RegimeClassificationType.highVolatility,
        confidenceScore: 0.70,
        adxValue: 25.0,
        atrPercent: 2.5,
      );
      expect(a, equals(b));
    });
  });

  // ── S454: PortfolioMarginCall ─────────────────────────────────────────────
  group('PortfolioMarginCall', () {
    test('marginDeficit and isUrgent computed correctly', () {
      const PortfolioMarginCall call = PortfolioMarginCall(
        portfolioId: 'p1',
        marginCallAmount: 5000,
        currentMarginLevel: 20.0,
        minimumMarginLevel: 35.0,
        affectedTickers: ['AAPL', 'TSLA'],
      );
      expect(call.marginDeficit, closeTo(15.0, 0.01));
      expect(call.isUrgent, isTrue);
      expect(call.isActive, isTrue);
    });

    test('isActive false when resolved', () {
      const PortfolioMarginCall call = PortfolioMarginCall(
        portfolioId: 'p2',
        marginCallAmount: 1000,
        currentMarginLevel: 40.0,
        minimumMarginLevel: 45.0,
        affectedTickers: ['MSFT'],
        isResolved: true,
      );
      expect(call.isActive, isFalse);
      expect(call.isUrgent, isFalse);
    });

    test('equality', () {
      const PortfolioMarginCall a = PortfolioMarginCall(
        portfolioId: 'p1',
        marginCallAmount: 2000,
        currentMarginLevel: 25.0,
        minimumMarginLevel: 30.0,
        affectedTickers: ['AAPL'],
      );
      const PortfolioMarginCall b = PortfolioMarginCall(
        portfolioId: 'p1',
        marginCallAmount: 2000,
        currentMarginLevel: 25.0,
        minimumMarginLevel: 30.0,
        affectedTickers: ['AAPL'],
      );
      expect(a, equals(b));
    });
  });

  // ── S455: VolatilityForecast ──────────────────────────────────────────────
  group('VolatilityForecast', () {
    test('isHighVol true when forecast >= 40%', () {
      const VolatilityForecast vf = VolatilityForecast(
        ticker: 'TSLA',
        forecastHorizonDays: 10,
        forecastedAnnualizedVol: 65.0,
        currentRealizedVol: 50.0,
        method: VolatilityForecastMethod.garch,
      );
      expect(vf.isHighVol, isTrue);
      expect(vf.isVolIncreasing, isTrue);
      expect(vf.volChange, closeTo(15.0, 0.01));
    });

    test('isVolIncreasing false when forecast < current', () {
      const VolatilityForecast vf = VolatilityForecast(
        ticker: 'SPY',
        forecastHorizonDays: 5,
        forecastedAnnualizedVol: 15.0,
        currentRealizedVol: 20.0,
        method: VolatilityForecastMethod.ewma,
      );
      expect(vf.isVolIncreasing, isFalse);
      expect(vf.isHighVol, isFalse);
    });

    test('equality', () {
      const VolatilityForecast a = VolatilityForecast(
        ticker: 'AAPL',
        forecastHorizonDays: 5,
        forecastedAnnualizedVol: 30.0,
        currentRealizedVol: 25.0,
        method: VolatilityForecastMethod.historicalSimulation,
      );
      const VolatilityForecast b = VolatilityForecast(
        ticker: 'AAPL',
        forecastHorizonDays: 5,
        forecastedAnnualizedVol: 30.0,
        currentRealizedVol: 25.0,
        method: VolatilityForecastMethod.historicalSimulation,
      );
      expect(a, equals(b));
    });
  });

  // ── S456: BetaCalculationResult ───────────────────────────────────────────
  group('BetaCalculationResult', () {
    test('isHighBeta true above 1.5', () {
      const BetaCalculationResult b = BetaCalculationResult(
        ticker: 'TSLA',
        benchmarkTicker: 'SPY',
        beta: 2.1,
        rSquared: 0.80,
        periodDays: 252,
      );
      expect(b.isHighBeta, isTrue);
      expect(b.isLowBeta, isFalse);
      expect(b.isNegativeBeta, isFalse);
      expect(b.isStatisticallySignificant, isTrue);
    });

    test('isNegativeBeta true for inverse products', () {
      const BetaCalculationResult b = BetaCalculationResult(
        ticker: 'SQQQ',
        benchmarkTicker: 'QQQ',
        beta: -2.8,
        rSquared: 0.92,
        periodDays: 126,
      );
      expect(b.isNegativeBeta, isTrue);
      expect(b.isHighBeta, isFalse);
    });

    test('equality', () {
      const BetaCalculationResult a = BetaCalculationResult(
        ticker: 'AAPL',
        benchmarkTicker: 'SPY',
        beta: 1.2,
        rSquared: 0.75,
        periodDays: 252,
      );
      const BetaCalculationResult bItem = BetaCalculationResult(
        ticker: 'AAPL',
        benchmarkTicker: 'SPY',
        beta: 1.2,
        rSquared: 0.75,
        periodDays: 252,
      );
      expect(a, equals(bItem));
    });
  });

  // ── S457: ConditionalOrderEntry ───────────────────────────────────────────
  group('ConditionalOrderEntry', () {
    test('isPriceTrigger true for price triggers', () {
      const ConditionalOrderEntry order = ConditionalOrderEntry(
        orderId: 'ord1',
        ticker: 'AAPL',
        trigger: ConditionalOrderTrigger.priceAbove,
        triggerValue: 200.0,
        orderQuantity: 10,
      );
      expect(order.isPriceTrigger, isTrue);
      expect(order.isSellOrder, isFalse);
      expect(order.isActive, isTrue);
    });

    test('isSellOrder true when isBuyOrder is false', () {
      const ConditionalOrderEntry order = ConditionalOrderEntry(
        orderId: 'ord2',
        ticker: 'TSLA',
        trigger: ConditionalOrderTrigger.priceBelow,
        triggerValue: 150.0,
        orderQuantity: 5,
        isBuyOrder: false,
      );
      expect(order.isSellOrder, isTrue);
      expect(order.isPriceTrigger, isTrue);
    });

    test('equality', () {
      const ConditionalOrderEntry a = ConditionalOrderEntry(
        orderId: 'o1',
        ticker: 'AAPL',
        trigger: ConditionalOrderTrigger.percentMove,
        triggerValue: 5.0,
        orderQuantity: 10,
      );
      const ConditionalOrderEntry b = ConditionalOrderEntry(
        orderId: 'o1',
        ticker: 'AAPL',
        trigger: ConditionalOrderTrigger.percentMove,
        triggerValue: 5.0,
        orderQuantity: 10,
      );
      expect(a, equals(b));
    });
  });

  // ── S458: OrderExecutionSummary ───────────────────────────────────────────
  group('OrderExecutionSummary', () {
    test('isFullyFilled true for complete fill', () {
      const OrderExecutionSummary s = OrderExecutionSummary(
        executionId: 'ex1',
        ticker: 'SPY',
        requestedQuantity: 100,
        filledQuantity: 100,
        averageFillPrice: 500.0,
        status: OrderExecutionStatus.filled,
        commissionPaid: 1.0,
      );
      expect(s.isFullyFilled, isTrue);
      expect(s.fillRate, equals(1.0));
      expect(s.totalCost, closeTo(50001.0, 0.01));
    });

    test('isPartial true for partial fill', () {
      const OrderExecutionSummary s = OrderExecutionSummary(
        executionId: 'ex2',
        ticker: 'AAPL',
        requestedQuantity: 50,
        filledQuantity: 20,
        averageFillPrice: 180.0,
        status: OrderExecutionStatus.partialFill,
      );
      expect(s.isPartial, isTrue);
      expect(s.isFullyFilled, isFalse);
      expect(s.fillRate, closeTo(0.4, 0.01));
    });

    test('equality', () {
      const OrderExecutionSummary a = OrderExecutionSummary(
        executionId: 'ex1',
        ticker: 'SPY',
        requestedQuantity: 10,
        filledQuantity: 10,
        averageFillPrice: 500.0,
        status: OrderExecutionStatus.filled,
      );
      const OrderExecutionSummary b = OrderExecutionSummary(
        executionId: 'ex1',
        ticker: 'SPY',
        requestedQuantity: 10,
        filledQuantity: 10,
        averageFillPrice: 500.0,
        status: OrderExecutionStatus.filled,
      );
      expect(a, equals(b));
    });
  });

  // ── S459: BracketOrderConfig ──────────────────────────────────────────────
  group('BracketOrderConfig', () {
    test('riskRewardRatio and isFavorableRiskReward', () {
      const BracketOrderConfig boc = BracketOrderConfig(
        bracketId: 'br1',
        ticker: 'AAPL',
        entryPrice: 180.0,
        profitTargetPrice: 190.0,
        stopLossPrice: 175.0,
        quantity: 10,
      );
      expect(boc.riskPerShare, closeTo(5.0, 0.01));
      expect(boc.rewardPerShare, closeTo(10.0, 0.01));
      expect(boc.riskRewardRatio, closeTo(2.0, 0.01));
      expect(boc.isFavorableRiskReward, isTrue);
    });

    test('isFavorableRiskReward false for poor ratio', () {
      const BracketOrderConfig boc = BracketOrderConfig(
        bracketId: 'br2',
        ticker: 'TSLA',
        entryPrice: 200.0,
        profitTargetPrice: 205.0,
        stopLossPrice: 190.0,
        quantity: 5,
        isLong: false,
      );
      expect(boc.riskRewardRatio, closeTo(0.5, 0.01));
      expect(boc.isFavorableRiskReward, isFalse);
    });

    test('equality', () {
      const BracketOrderConfig a = BracketOrderConfig(
        bracketId: 'br1',
        ticker: 'AAPL',
        entryPrice: 180.0,
        profitTargetPrice: 200.0,
        stopLossPrice: 170.0,
        quantity: 10,
      );
      const BracketOrderConfig b = BracketOrderConfig(
        bracketId: 'br1',
        ticker: 'AAPL',
        entryPrice: 180.0,
        profitTargetPrice: 200.0,
        stopLossPrice: 170.0,
        quantity: 10,
      );
      expect(a, equals(b));
    });
  });

  // ── S460: SectorValuationSnapshot ────────────────────────────────────────
  group('SectorValuationSnapshot', () {
    test('isExpensive true when PE > 25', () {
      const SectorValuationSnapshot s = SectorValuationSnapshot(
        sectorName: 'Technology',
        medianPeRatio: 32.0,
        medianPbRatio: 5.5,
        forwardPeRatio: 28.0,
        dividendYieldPercent: 0.8,
        revenueGrowthPercent: 18.0,
      );
      expect(s.isExpensive, isTrue);
      expect(s.isCheap, isFalse);
      expect(s.isGrowthSector, isTrue);
      expect(s.isHighYield, isFalse);
    });

    test('isCheap true when PE < 12', () {
      const SectorValuationSnapshot s = SectorValuationSnapshot(
        sectorName: 'Energy',
        medianPeRatio: 8.0,
        medianPbRatio: 1.2,
        forwardPeRatio: 7.5,
        dividendYieldPercent: 5.5,
        revenueGrowthPercent: 5.0,
      );
      expect(s.isCheap, isTrue);
      expect(s.isHighYield, isTrue);
      expect(s.isGrowthSector, isFalse);
    });

    test('equality', () {
      const SectorValuationSnapshot a = SectorValuationSnapshot(
        sectorName: 'Health',
        medianPeRatio: 20.0,
        medianPbRatio: 3.0,
        forwardPeRatio: 18.0,
        dividendYieldPercent: 2.0,
        revenueGrowthPercent: 8.0,
      );
      const SectorValuationSnapshot b = SectorValuationSnapshot(
        sectorName: 'Health',
        medianPeRatio: 20.0,
        medianPbRatio: 3.0,
        forwardPeRatio: 18.0,
        dividendYieldPercent: 2.0,
        revenueGrowthPercent: 8.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S461: MarketBreadthAlert ──────────────────────────────────────────────
  group('MarketBreadthAlert', () {
    test('isBullish true for advance/decline extreme up', () {
      const MarketBreadthAlert alert = MarketBreadthAlert(
        alertId: 'ba1',
        type: BreadthAlertType.advanceDeclineExtremeUp,
        breadthValue: 4.5,
        threshold: 3.0,
        exchange: 'NYSE',
      );
      expect(alert.isBullish, isTrue);
      expect(alert.isBearish, isFalse);
      expect(alert.deviationFromThreshold, closeTo(1.5, 0.01));
    });

    test('isBearish true for extreme down', () {
      const MarketBreadthAlert alert = MarketBreadthAlert(
        alertId: 'ba2',
        type: BreadthAlertType.advanceDeclineExtremeDown,
        breadthValue: 0.3,
        threshold: 1.0,
        exchange: 'NASDAQ',
      );
      expect(alert.isBearish, isTrue);
      expect(alert.isBullish, isFalse);
    });

    test('equality', () {
      const MarketBreadthAlert a = MarketBreadthAlert(
        alertId: 'ba1',
        type: BreadthAlertType.newHighsExpanding,
        breadthValue: 150.0,
        threshold: 100.0,
        exchange: 'NYSE',
      );
      const MarketBreadthAlert b = MarketBreadthAlert(
        alertId: 'ba1',
        type: BreadthAlertType.newHighsExpanding,
        breadthValue: 150.0,
        threshold: 100.0,
        exchange: 'NYSE',
      );
      expect(a, equals(b));
    });
  });

  // ── S462: MacroSurpriseIndex ──────────────────────────────────────────────
  group('MacroSurpriseIndex', () {
    test('isSignificant true when abs score >= 25', () {
      const MacroSurpriseIndex idx = MacroSurpriseIndex(
        indexId: 'msi1',
        region: 'US',
        compositeScore: 40.0,
        direction: MacroSurpriseDirection.positiveSuprise,
        contributingIndicators: ['CPI', 'NFP', 'GDP'],
      );
      expect(idx.isPositiveSurprise, isTrue);
      expect(idx.isSignificant, isTrue);
      expect(idx.isNegativeSurprise, isFalse);
    });

    test('isNegativeSurprise true for negative score', () {
      const MacroSurpriseIndex idx = MacroSurpriseIndex(
        indexId: 'msi2',
        region: 'EU',
        compositeScore: -30.0,
        direction: MacroSurpriseDirection.negativeSuprise,
        contributingIndicators: ['CPI'],
      );
      expect(idx.isNegativeSurprise, isTrue);
      expect(idx.isSignificant, isTrue);
    });

    test('equality', () {
      const MacroSurpriseIndex a = MacroSurpriseIndex(
        indexId: 'msi1',
        region: 'US',
        compositeScore: 15.0,
        direction: MacroSurpriseDirection.inline,
        contributingIndicators: ['NFP'],
      );
      const MacroSurpriseIndex b = MacroSurpriseIndex(
        indexId: 'msi1',
        region: 'US',
        compositeScore: 15.0,
        direction: MacroSurpriseDirection.inline,
        contributingIndicators: ['NFP'],
      );
      expect(a, equals(b));
    });
  });

  // ── S463: TickChartConfig ─────────────────────────────────────────────────
  group('TickChartConfig', () {
    test('isRenko true for renko type', () {
      const TickChartConfig cfg = TickChartConfig(
        configId: 'tc1',
        ticker: 'AAPL',
        type: TickChartType.renko,
        brickSize: 1.0,
      );
      expect(cfg.isRenko, isTrue);
      expect(cfg.isVolumeBased, isFalse);
    });

    test('isVolumeBased true for volumeBar', () {
      const TickChartConfig cfg = TickChartConfig(
        configId: 'tc2',
        ticker: 'TSLA',
        type: TickChartType.volumeBar,
        brickSize: 10000.0,
        showWicks: false,
      );
      expect(cfg.isVolumeBased, isTrue);
      expect(cfg.isRenko, isFalse);
    });

    test('equality', () {
      const TickChartConfig a = TickChartConfig(
        configId: 'tc1',
        ticker: 'SPY',
        type: TickChartType.tickBar,
        brickSize: 100.0,
      );
      const TickChartConfig b = TickChartConfig(
        configId: 'tc1',
        ticker: 'SPY',
        type: TickChartType.tickBar,
        brickSize: 100.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S464: RangeExpansionSignal ────────────────────────────────────────────
  group('RangeExpansionSignal', () {
    test('isSignificant true when multiple >= 2.0', () {
      const RangeExpansionSignal sig = RangeExpansionSignal(
        ticker: 'AAPL',
        currentRange: 10.0,
        averageRange: 4.0,
        expansionMultiple: 2.5,
      );
      expect(sig.isSignificant, isTrue);
      expect(sig.isExtreme, isFalse);
      expect(sig.isBearishExpansion, isFalse);
    });

    test('isExtreme true when multiple >= 3.0', () {
      const RangeExpansionSignal sig = RangeExpansionSignal(
        ticker: 'NVDA',
        currentRange: 30.0,
        averageRange: 8.0,
        expansionMultiple: 3.75,
        isBullishExpansion: false,
      );
      expect(sig.isExtreme, isTrue);
      expect(sig.isSignificant, isTrue);
      expect(sig.isBearishExpansion, isTrue);
    });

    test('equality', () {
      const RangeExpansionSignal a = RangeExpansionSignal(
        ticker: 'SPY',
        currentRange: 5.0,
        averageRange: 2.0,
        expansionMultiple: 2.5,
      );
      const RangeExpansionSignal b = RangeExpansionSignal(
        ticker: 'SPY',
        currentRange: 5.0,
        averageRange: 2.0,
        expansionMultiple: 2.5,
      );
      expect(a, equals(b));
    });
  });

  // ── S465: UserWatchlistPreference ─────────────────────────────────────────
  group('UserWatchlistPreference', () {
    test('hasCustomDisplay true when non-default options', () {
      const UserWatchlistPreference pref = UserWatchlistPreference(
        userId: 'u1',
        watchlistId: 'w1',
        defaultSortField: 'sma_distance',
        showVolume: true,
      );
      expect(pref.hasCustomDisplay, isTrue);
      expect(pref.isFullyEnabled, isTrue);
    });

    test('isFullyEnabled false when notifications disabled', () {
      const UserWatchlistPreference pref = UserWatchlistPreference(
        userId: 'u2',
        watchlistId: 'w2',
        defaultSortField: 'alphabetical',
        notificationsEnabled: false,
      );
      expect(pref.isFullyEnabled, isFalse);
    });

    test('equality', () {
      const UserWatchlistPreference a = UserWatchlistPreference(
        userId: 'u1',
        watchlistId: 'w1',
        defaultSortField: 'price',
      );
      const UserWatchlistPreference b = UserWatchlistPreference(
        userId: 'u1',
        watchlistId: 'w1',
        defaultSortField: 'price',
      );
      expect(a, equals(b));
    });
  });
}
