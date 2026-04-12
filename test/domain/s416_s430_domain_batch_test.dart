import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── S416: PositionRiskEntry ───────────────────────────────────────────────
  group('PositionRiskEntry', () {
    test('isHighRisk true for high category', () {
      const PositionRiskEntry entry = PositionRiskEntry(
        ticker: 'TSLA',
        positionValue: 50000,
        riskPercent: 12.0,
        betaAdjustedRisk: 14.0,
        riskCategory: PositionRiskCategory.high,
      );
      expect(entry.isHighRisk, isTrue);
      expect(entry.isExtreme, isFalse);
    });

    test('isHighRisk true for extreme category', () {
      const PositionRiskEntry entry = PositionRiskEntry(
        ticker: 'GME',
        positionValue: 10000,
        riskPercent: 22.0,
        betaAdjustedRisk: 26.0,
        riskCategory: PositionRiskCategory.extreme,
      );
      expect(entry.isHighRisk, isTrue);
      expect(entry.isExtreme, isTrue);
    });

    test('isHighRisk false for low category', () {
      const PositionRiskEntry entry = PositionRiskEntry(
        ticker: 'BND',
        positionValue: 20000,
        riskPercent: 1.5,
        betaAdjustedRisk: 1.0,
        riskCategory: PositionRiskCategory.low,
      );
      expect(entry.isHighRisk, isFalse);
    });

    test('adjustedExposure computed correctly', () {
      const PositionRiskEntry entry = PositionRiskEntry(
        ticker: 'AAPL',
        positionValue: 10000,
        riskPercent: 5.0,
        betaAdjustedRisk: 1.2,
        riskCategory: PositionRiskCategory.moderate,
      );
      expect(entry.adjustedExposure, closeTo(12000, 0.01));
    });

    test('equality and props', () {
      const PositionRiskEntry a = PositionRiskEntry(
        ticker: 'AAPL',
        positionValue: 10000,
        riskPercent: 5.0,
        betaAdjustedRisk: 1.2,
        riskCategory: PositionRiskCategory.moderate,
      );
      const PositionRiskEntry b = PositionRiskEntry(
        ticker: 'AAPL',
        positionValue: 10000,
        riskPercent: 5.0,
        betaAdjustedRisk: 1.2,
        riskCategory: PositionRiskCategory.moderate,
      );
      expect(a, equals(b));
    });
  });

  // ── S417: TradeExecutionRecord ────────────────────────────────────────────
  group('TradeExecutionRecord', () {
    test('totalValue computed correctly', () {
      final TradeExecutionRecord record = TradeExecutionRecord(
        executionId: 'ex1',
        orderId: 'ord1',
        ticker: 'MSFT',
        executedAt: DateTime(2025, 1, 10),
        executedPrice: 400.0,
        executedQuantity: 25,
        slippageBps: 3,
      );
      expect(record.totalValue, closeTo(10000.0, 0.01));
    });

    test('hasSlippage true when bps != 0', () {
      final TradeExecutionRecord record = TradeExecutionRecord(
        executionId: 'ex2',
        orderId: 'ord2',
        ticker: 'GOOG',
        executedAt: DateTime(2025, 1, 11),
        executedPrice: 150.0,
        executedQuantity: 10,
        slippageBps: -2,
      );
      expect(record.hasSlippage, isTrue);
      expect(record.hasPositiveSlippage, isFalse);
    });

    test('hasSlippage false when bps == 0', () {
      final TradeExecutionRecord record = TradeExecutionRecord(
        executionId: 'ex3',
        orderId: 'ord3',
        ticker: 'SPY',
        executedAt: DateTime(2025, 1, 12),
        executedPrice: 500.0,
        executedQuantity: 5,
        slippageBps: 0,
      );
      expect(record.hasSlippage, isFalse);
    });

    test('hasPositiveSlippage true for unfavorable slippage', () {
      final TradeExecutionRecord record = TradeExecutionRecord(
        executionId: 'ex4',
        orderId: 'ord4',
        ticker: 'AMZN',
        executedAt: DateTime(2025, 1, 13),
        executedPrice: 200.0,
        executedQuantity: 20,
        slippageBps: 5,
      );
      expect(record.hasPositiveSlippage, isTrue);
    });

    test('equality', () {
      final TradeExecutionRecord a = TradeExecutionRecord(
        executionId: 'ex1',
        orderId: 'ord1',
        ticker: 'MSFT',
        executedAt: DateTime(2025, 1, 10),
        executedPrice: 400.0,
        executedQuantity: 25,
        slippageBps: 3,
      );
      final TradeExecutionRecord b = TradeExecutionRecord(
        executionId: 'ex1',
        orderId: 'ord1',
        ticker: 'MSFT',
        executedAt: DateTime(2025, 1, 10),
        executedPrice: 400.0,
        executedQuantity: 25,
        slippageBps: 3,
      );
      expect(a, equals(b));
    });
  });

  // ── S418: PortfolioHeatmapConfig ──────────────────────────────────────────
  group('PortfolioHeatmapConfig', () {
    test('isColorBlindFriendly for blueOrange', () {
      const PortfolioHeatmapConfig config = PortfolioHeatmapConfig(
        configId: 'cfg1',
        colorScheme: HeatmapColorScheme.blueOrange,
        metric: HeatmapMetric.priceChange,
        normalizePercentile: true,
      );
      expect(config.isColorBlindFriendly, isTrue);
    });

    test('isColorBlindFriendly for grayScale', () {
      const PortfolioHeatmapConfig config = PortfolioHeatmapConfig(
        configId: 'cfg2',
        colorScheme: HeatmapColorScheme.grayScale,
        metric: HeatmapMetric.rsi,
        normalizePercentile: false,
      );
      expect(config.isColorBlindFriendly, isTrue);
    });

    test('isColorBlindFriendly false for redGreen', () {
      const PortfolioHeatmapConfig config = PortfolioHeatmapConfig(
        configId: 'cfg3',
        colorScheme: HeatmapColorScheme.redGreen,
        metric: HeatmapMetric.smaDistance,
        normalizePercentile: true,
      );
      expect(config.isColorBlindFriendly, isFalse);
    });

    test('equality', () {
      const PortfolioHeatmapConfig a = PortfolioHeatmapConfig(
        configId: 'cfg1',
        colorScheme: HeatmapColorScheme.blueOrange,
        metric: HeatmapMetric.priceChange,
        normalizePercentile: true,
      );
      const PortfolioHeatmapConfig b = PortfolioHeatmapConfig(
        configId: 'cfg1',
        colorScheme: HeatmapColorScheme.blueOrange,
        metric: HeatmapMetric.priceChange,
        normalizePercentile: true,
      );
      expect(a, equals(b));
    });
  });

  // ── S419: MultiBrokerPosition ─────────────────────────────────────────────
  group('MultiBrokerPosition', () {
    const BrokerPositionEntry brokerA = BrokerPositionEntry(
      brokerId: 'B1',
      brokerName: 'Fidelity',
      quantity: 50,
      averageCost: 200.0,
    );
    const BrokerPositionEntry brokerB = BrokerPositionEntry(
      brokerId: 'B2',
      brokerName: 'Schwab',
      quantity: 30,
      averageCost: 210.0,
    );

    test('BrokerPositionEntry totalCost computed', () {
      expect(brokerA.totalCost, closeTo(10000.0, 0.01));
    });

    test('totalQuantity aggregated', () {
      const MultiBrokerPosition pos = MultiBrokerPosition(
        ticker: 'AAPL',
        brokerPositions: [brokerA, brokerB],
      );
      expect(pos.totalQuantity, equals(80));
    });

    test('totalCost aggregated', () {
      const MultiBrokerPosition pos = MultiBrokerPosition(
        ticker: 'AAPL',
        brokerPositions: [brokerA, brokerB],
      );
      expect(pos.totalCost, closeTo(16300.0, 0.01));
    });

    test('brokerCount and isSpread', () {
      const MultiBrokerPosition pos = MultiBrokerPosition(
        ticker: 'AAPL',
        brokerPositions: [brokerA, brokerB],
      );
      expect(pos.brokerCount, equals(2));
      expect(pos.isSpread, isTrue);
    });

    test('isSpread false for single broker', () {
      const MultiBrokerPosition pos = MultiBrokerPosition(
        ticker: 'AAPL',
        brokerPositions: [brokerA],
      );
      expect(pos.isSpread, isFalse);
    });

    test('equality', () {
      const MultiBrokerPosition a = MultiBrokerPosition(
        ticker: 'AAPL',
        brokerPositions: [brokerA, brokerB],
      );
      const MultiBrokerPosition b = MultiBrokerPosition(
        ticker: 'AAPL',
        brokerPositions: [brokerA, brokerB],
      );
      expect(a, equals(b));
    });
  });

  // ── S420: RebalanceEventLog ───────────────────────────────────────────────
  group('RebalanceEventLog', () {
    test('isTerminal true for executed', () {
      final RebalanceEventLog log = RebalanceEventLog(
        eventId: 'ev1',
        portfolioId: 'p1',
        eventType: RebalanceEventType.executed,
        occurredAt: DateTime(2025, 3, 1),
        triggerReason: 'Drift exceeded 5%',
      );
      expect(log.isTerminal, isTrue);
      expect(log.hasTriggerReason, isTrue);
    });

    test('isTerminal true for cancelled', () {
      final RebalanceEventLog log = RebalanceEventLog(
        eventId: 'ev2',
        portfolioId: 'p1',
        eventType: RebalanceEventType.cancelled,
        occurredAt: DateTime(2025, 3, 2),
      );
      expect(log.isTerminal, isTrue);
    });

    test('isTerminal false for triggered', () {
      final RebalanceEventLog log = RebalanceEventLog(
        eventId: 'ev3',
        portfolioId: 'p1',
        eventType: RebalanceEventType.triggered,
        occurredAt: DateTime(2025, 3, 3),
      );
      expect(log.isTerminal, isFalse);
    });

    test('hasTriggerReason false when null', () {
      final RebalanceEventLog log = RebalanceEventLog(
        eventId: 'ev4',
        portfolioId: 'p1',
        eventType: RebalanceEventType.skipped,
        occurredAt: DateTime(2025, 3, 4),
      );
      expect(log.hasTriggerReason, isFalse);
    });

    test('equality', () {
      final RebalanceEventLog a = RebalanceEventLog(
        eventId: 'ev1',
        portfolioId: 'p1',
        eventType: RebalanceEventType.executed,
        occurredAt: DateTime(2025, 3, 1),
      );
      final RebalanceEventLog b = RebalanceEventLog(
        eventId: 'ev1',
        portfolioId: 'p1',
        eventType: RebalanceEventType.executed,
        occurredAt: DateTime(2025, 3, 1),
      );
      expect(a, equals(b));
    });
  });

  // ── S421: AllocationDriftReport ───────────────────────────────────────────
  group('AllocationDriftReport', () {
    const AllocationDriftEntry entry1 = AllocationDriftEntry(
      ticker: 'AAPL',
      targetWeight: 30.0,
      actualWeight: 37.0,
    );
    const AllocationDriftEntry entry2 = AllocationDriftEntry(
      ticker: 'GOOG',
      targetWeight: 20.0,
      actualWeight: 18.0,
    );

    test('AllocationDriftEntry drift and isOverweight', () {
      expect(entry1.drift, closeTo(7.0, 0.01));
      expect(entry1.isOverweight, isTrue);
      expect(entry2.isOverweight, isFalse);
    });

    test('maxDrift selects largest absolute drift', () {
      final AllocationDriftReport report = AllocationDriftReport(
        portfolioId: 'port1',
        reportDate: DateTime(2025, 4, 1),
        entries: const [entry1, entry2],
      );
      expect(report.maxDrift, closeTo(7.0, 0.01));
    });

    test('hasMaterialDrift true when maxDrift > 5%', () {
      final AllocationDriftReport report = AllocationDriftReport(
        portfolioId: 'port1',
        reportDate: DateTime(2025, 4, 1),
        entries: const [entry1, entry2],
      );
      expect(report.hasMaterialDrift, isTrue);
    });

    test('hasMaterialDrift false when drift within tolerance', () {
      const AllocationDriftEntry small = AllocationDriftEntry(
        ticker: 'BND',
        targetWeight: 20.0,
        actualWeight: 21.0,
      );
      final AllocationDriftReport report = AllocationDriftReport(
        portfolioId: 'port2',
        reportDate: DateTime(2025, 4, 2),
        entries: const [small],
      );
      expect(report.hasMaterialDrift, isFalse);
    });

    test('entryCount', () {
      final AllocationDriftReport report = AllocationDriftReport(
        portfolioId: 'port1',
        reportDate: DateTime(2025, 4, 1),
        entries: const [entry1, entry2],
      );
      expect(report.entryCount, equals(2));
    });
  });

  // ── S422: PortfolioRiskReport ─────────────────────────────────────────────
  group('PortfolioRiskReport', () {
    test('isHighRisk true when VaR > 10%', () {
      final PortfolioRiskReport report = PortfolioRiskReport(
        portfolioId: 'p1',
        generatedAt: DateTime(2025, 4, 5),
        valueAtRisk95: 0.12,
        expectedShortfall: 0.15,
        betaToMarket: 1.1,
        concentrationScore: 0.25,
      );
      expect(report.isHighRisk, isTrue);
      expect(report.isDiversified, isTrue);
      expect(report.isHighBeta, isFalse);
    });

    test('isHighBeta true when beta > 1.2', () {
      final PortfolioRiskReport report = PortfolioRiskReport(
        portfolioId: 'p2',
        generatedAt: DateTime(2025, 4, 5),
        valueAtRisk95: 0.05,
        expectedShortfall: 0.07,
        betaToMarket: 1.5,
        concentrationScore: 0.45,
      );
      expect(report.isHighBeta, isTrue);
      expect(report.isDiversified, isFalse);
      expect(report.isHighRisk, isFalse);
    });

    test('equality', () {
      final PortfolioRiskReport a = PortfolioRiskReport(
        portfolioId: 'p1',
        generatedAt: DateTime(2025, 4, 5),
        valueAtRisk95: 0.08,
        expectedShortfall: 0.10,
        betaToMarket: 1.0,
        concentrationScore: 0.20,
      );
      final PortfolioRiskReport b = PortfolioRiskReport(
        portfolioId: 'p1',
        generatedAt: DateTime(2025, 4, 5),
        valueAtRisk95: 0.08,
        expectedShortfall: 0.10,
        betaToMarket: 1.0,
        concentrationScore: 0.20,
      );
      expect(a, equals(b));
    });
  });

  // ── S423: MarginUsageSnapshot ─────────────────────────────────────────────
  group('MarginUsageSnapshot', () {
    test('marginUtilizationRate computed correctly', () {
      final MarginUsageSnapshot snap = MarginUsageSnapshot(
        snapshotId: 's1',
        accountId: 'acc1',
        capturedAt: DateTime(2025, 2, 1),
        totalEquity: 100000,
        usedMargin: 40000,
        availableMargin: 60000,
      );
      expect(snap.marginUtilizationRate, closeTo(0.40, 0.001));
      expect(snap.isHighUtilization, isFalse);
      expect(snap.isOverMargin, isFalse);
    });

    test('isHighUtilization true when > 80%', () {
      final MarginUsageSnapshot snap = MarginUsageSnapshot(
        snapshotId: 's2',
        accountId: 'acc2',
        capturedAt: DateTime(2025, 2, 2),
        totalEquity: 50000,
        usedMargin: 45000,
        availableMargin: 5000,
      );
      expect(snap.isHighUtilization, isTrue);
    });

    test('isOverMargin true when usedMargin > totalEquity', () {
      final MarginUsageSnapshot snap = MarginUsageSnapshot(
        snapshotId: 's3',
        accountId: 'acc3',
        capturedAt: DateTime(2025, 2, 3),
        totalEquity: 10000,
        usedMargin: 12000,
        availableMargin: 0,
      );
      expect(snap.isOverMargin, isTrue);
    });

    test('marginUtilizationRate zero when equity is zero', () {
      final MarginUsageSnapshot snap = MarginUsageSnapshot(
        snapshotId: 's4',
        accountId: 'acc4',
        capturedAt: DateTime(2025, 2, 4),
        totalEquity: 0,
        usedMargin: 0,
        availableMargin: 0,
      );
      expect(snap.marginUtilizationRate, equals(0.0));
    });
  });

  // ── S424: TaxHarvestOpportunity ───────────────────────────────────────────
  group('TaxHarvestOpportunity', () {
    test('isSignificant true when abs loss > 500', () {
      const TaxHarvestOpportunity opp = TaxHarvestOpportunity(
        ticker: 'NFLX',
        currentLoss: -1200.0,
        costBasis: 500.0,
        currentPrice: 260.0,
        holdingDays: 400,
        isLongTerm: true,
      );
      expect(opp.isSignificant, isTrue);
    });

    test('isSignificant false when loss <= 500', () {
      const TaxHarvestOpportunity opp = TaxHarvestOpportunity(
        ticker: 'SNAP',
        currentLoss: -200.0,
        costBasis: 15.0,
        currentPrice: 12.0,
        holdingDays: 90,
        isLongTerm: false,
      );
      expect(opp.isSignificant, isFalse);
    });

    test('lossPercent computed', () {
      const TaxHarvestOpportunity opp = TaxHarvestOpportunity(
        ticker: 'COIN',
        currentLoss: -500.0,
        costBasis: 2500.0,
        currentPrice: 2000.0,
        holdingDays: 200,
        isLongTerm: false,
      );
      expect(opp.lossPercent, closeTo(-20.0, 0.01));
    });

    test('washSaleWindowDays is 30', () {
      const TaxHarvestOpportunity opp = TaxHarvestOpportunity(
        ticker: 'ABC',
        currentLoss: -600.0,
        costBasis: 100.0,
        currentPrice: 90.0,
        holdingDays: 50,
        isLongTerm: false,
      );
      expect(opp.washSaleWindowDays, equals(30));
    });

    test('equality', () {
      const TaxHarvestOpportunity a = TaxHarvestOpportunity(
        ticker: 'NFLX',
        currentLoss: -1200.0,
        costBasis: 500.0,
        currentPrice: 260.0,
        holdingDays: 400,
        isLongTerm: true,
      );
      const TaxHarvestOpportunity b = TaxHarvestOpportunity(
        ticker: 'NFLX',
        currentLoss: -1200.0,
        costBasis: 500.0,
        currentPrice: 260.0,
        holdingDays: 400,
        isLongTerm: true,
      );
      expect(a, equals(b));
    });
  });

  // ── S425: PortfolioCorrelationEntry ───────────────────────────────────────
  group('PortfolioCorrelationEntry', () {
    test('isHighlyCorrelated true when abs > 0.7', () {
      const PortfolioCorrelationEntry entry = PortfolioCorrelationEntry(
        portfolioId: 'p1',
        tickerA: 'AAPL',
        tickerB: 'MSFT',
        correlation: 0.85,
        observationDays: 252,
      );
      expect(entry.isHighlyCorrelated, isTrue);
      expect(entry.isDiversifying, isFalse);
    });

    test('isNegativelyCorrelated true when < -0.3', () {
      const PortfolioCorrelationEntry entry = PortfolioCorrelationEntry(
        portfolioId: 'p1',
        tickerA: 'SPY',
        tickerB: 'TLT',
        correlation: -0.60,
        observationDays: 252,
      );
      expect(entry.isNegativelyCorrelated, isTrue);
      expect(entry.isDiversifying, isTrue);
      expect(entry.isHighlyCorrelated, isFalse);
    });

    test('isDiversifying true for negative correlation', () {
      const PortfolioCorrelationEntry entry = PortfolioCorrelationEntry(
        portfolioId: 'p1',
        tickerA: 'VXX',
        tickerB: 'SPY',
        correlation: -0.75,
        observationDays: 120,
      );
      expect(entry.isDiversifying, isTrue);
    });

    test('equality', () {
      const PortfolioCorrelationEntry a = PortfolioCorrelationEntry(
        portfolioId: 'p1',
        tickerA: 'AAPL',
        tickerB: 'MSFT',
        correlation: 0.80,
        observationDays: 252,
      );
      const PortfolioCorrelationEntry b = PortfolioCorrelationEntry(
        portfolioId: 'p1',
        tickerA: 'AAPL',
        tickerB: 'MSFT',
        correlation: 0.80,
        observationDays: 252,
      );
      expect(a, equals(b));
    });
  });

  // ── S426: TradeSignalAttribution ──────────────────────────────────────────
  group('TradeSignalAttribution', () {
    test('isConsensus true when >= 2 contributing methods', () {
      final TradeSignalAttribution attr = TradeSignalAttribution(
        tradeId: 't1',
        ticker: 'AAPL',
        primarySignalMethod: 'MichoMethod',
        contributingMethods: const ['RSI', 'MACD'],
        attributedAt: DateTime(2025, 5, 1),
      );
      expect(attr.isConsensus, isTrue);
      expect(attr.methodCount, equals(3));
      expect(attr.isPrimaryOnly, isFalse);
    });

    test('isPrimaryOnly true when no contributing methods', () {
      final TradeSignalAttribution attr = TradeSignalAttribution(
        tradeId: 't2',
        ticker: 'GOOG',
        primarySignalMethod: 'MichoMethod',
        contributingMethods: const [],
        attributedAt: DateTime(2025, 5, 2),
      );
      expect(attr.isPrimaryOnly, isTrue);
      expect(attr.methodCount, equals(1));
      expect(attr.isConsensus, isFalse);
    });

    test('isConsensus false when only 1 contributing method', () {
      final TradeSignalAttribution attr = TradeSignalAttribution(
        tradeId: 't3',
        ticker: 'META',
        primarySignalMethod: 'MichoMethod',
        contributingMethods: const ['Bollinger'],
        attributedAt: DateTime(2025, 5, 3),
      );
      expect(attr.isConsensus, isFalse);
    });

    test('equality', () {
      final TradeSignalAttribution a = TradeSignalAttribution(
        tradeId: 't1',
        ticker: 'AAPL',
        primarySignalMethod: 'MichoMethod',
        contributingMethods: const ['RSI'],
        attributedAt: DateTime(2025, 5, 1),
      );
      final TradeSignalAttribution b = TradeSignalAttribution(
        tradeId: 't1',
        ticker: 'AAPL',
        primarySignalMethod: 'MichoMethod',
        contributingMethods: const ['RSI'],
        attributedAt: DateTime(2025, 5, 1),
      );
      expect(a, equals(b));
    });
  });

  // ── S427: InvestmentThesis ────────────────────────────────────────────────
  group('InvestmentThesis', () {
    test('isBalanced true when both catalysts and risks exist', () {
      const InvestmentThesis thesis = InvestmentThesis(
        thesisId: 'th1',
        ticker: 'NVDA',
        summary: 'AI-driven growth',
        catalysts: ['AI demand', 'Data center expansion'],
        risks: ['Valuation', 'Competition'],
        targetPrice: 1200.0,
      );
      expect(thesis.isBalanced, isTrue);
      expect(thesis.hasCatalysts, isTrue);
      expect(thesis.hasRisks, isTrue);
    });

    test('isBalanced false when no risks', () {
      const InvestmentThesis thesis = InvestmentThesis(
        thesisId: 'th2',
        ticker: 'TSLA',
        summary: 'EV leader',
        catalysts: ['Robotaxi'],
        risks: <String>[],
        targetPrice: 500.0,
        isActive: false,
      );
      expect(thesis.isBalanced, isFalse);
      expect(thesis.hasRisks, isFalse);
      expect(thesis.isActive, isFalse);
    });

    test('equality', () {
      const InvestmentThesis a = InvestmentThesis(
        thesisId: 'th1',
        ticker: 'NVDA',
        summary: 'AI-driven growth',
        catalysts: ['AI demand'],
        risks: ['Valuation'],
        targetPrice: 1200.0,
      );
      const InvestmentThesis b = InvestmentThesis(
        thesisId: 'th1',
        ticker: 'NVDA',
        summary: 'AI-driven growth',
        catalysts: ['AI demand'],
        risks: ['Valuation'],
        targetPrice: 1200.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S428: PortfolioStressScenario ─────────────────────────────────────────
  group('PortfolioStressScenario', () {
    test('isSevere true when marketDropPercent > 20', () {
      const PortfolioStressScenario scenario = PortfolioStressScenario(
        scenarioId: 'sc1',
        name: '2008 Crisis',
        description: 'Financial crisis replay',
        marketDropPercent: 40.0,
        interestRateChangeBps: -150,
        volatilityMultiplier: 3.0,
      );
      expect(scenario.isSevere, isTrue);
      expect(scenario.isRateStress, isTrue);
      expect(scenario.isBearish, isTrue);
    });

    test('isSevere false and isBearish false for mild non-bear scenario', () {
      const PortfolioStressScenario scenario = PortfolioStressScenario(
        scenarioId: 'sc2',
        name: 'Rate Hike',
        description: '100bps rate increase',
        marketDropPercent: 0.0,
        interestRateChangeBps: 100,
        volatilityMultiplier: 1.2,
      );
      expect(scenario.isSevere, isFalse);
      expect(scenario.isBearish, isFalse);
      expect(scenario.isRateStress, isTrue);
    });

    test('isRateStress false when < 100 bps', () {
      const PortfolioStressScenario scenario = PortfolioStressScenario(
        scenarioId: 'sc3',
        name: 'Minor correction',
        description: '5% drawdown',
        marketDropPercent: 5.0,
        interestRateChangeBps: 25,
        volatilityMultiplier: 1.1,
      );
      expect(scenario.isRateStress, isFalse);
    });

    test('equality', () {
      const PortfolioStressScenario a = PortfolioStressScenario(
        scenarioId: 'sc1',
        name: 'Bear',
        description: 'Bear market',
        marketDropPercent: 30.0,
        interestRateChangeBps: 0,
        volatilityMultiplier: 2.0,
      );
      const PortfolioStressScenario b = PortfolioStressScenario(
        scenarioId: 'sc1',
        name: 'Bear',
        description: 'Bear market',
        marketDropPercent: 30.0,
        interestRateChangeBps: 0,
        volatilityMultiplier: 2.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S429: PositionConcentrationRisk ──────────────────────────────────────
  group('PositionConcentrationRisk', () {
    test('isAboveThreshold and excessPercent computed', () {
      const PositionConcentrationRisk risk = PositionConcentrationRisk(
        portfolioId: 'p1',
        ticker: 'AAPL',
        weightPercent: 25.0,
        thresholdPercent: 15.0,
      );
      expect(risk.isAboveThreshold, isTrue);
      expect(risk.excessPercent, closeTo(10.0, 0.01));
      expect(risk.isMaterial, isTrue);
    });

    test('excessPercent zero when within threshold', () {
      const PositionConcentrationRisk risk = PositionConcentrationRisk(
        portfolioId: 'p1',
        ticker: 'BND',
        weightPercent: 10.0,
        thresholdPercent: 15.0,
      );
      expect(risk.isAboveThreshold, isFalse);
      expect(risk.excessPercent, equals(0.0));
      expect(risk.isMaterial, isFalse);
    });

    test('isMaterial false when excess <= 5%', () {
      const PositionConcentrationRisk risk = PositionConcentrationRisk(
        portfolioId: 'p1',
        ticker: 'MSFT',
        weightPercent: 18.0,
        thresholdPercent: 15.0,
      );
      expect(risk.isAboveThreshold, isTrue);
      expect(risk.excessPercent, closeTo(3.0, 0.01));
      expect(risk.isMaterial, isFalse);
    });

    test('equality', () {
      const PositionConcentrationRisk a = PositionConcentrationRisk(
        portfolioId: 'p1',
        ticker: 'AAPL',
        weightPercent: 25.0,
        thresholdPercent: 15.0,
      );
      const PositionConcentrationRisk b = PositionConcentrationRisk(
        portfolioId: 'p1',
        ticker: 'AAPL',
        weightPercent: 25.0,
        thresholdPercent: 15.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S430: VarEstimate ─────────────────────────────────────────────────────
  group('VarEstimate', () {
    test('isConservative true for p99', () {
      const VarEstimate est = VarEstimate(
        portfolioId: 'p1',
        confidence: VarConfidenceLevel.p99,
        horizonDays: 1,
        estimatedLoss: 0.05,
        estimationMethod: 'historical',
      );
      expect(est.isConservative, isTrue);
      expect(est.isOneDay, isTrue);
    });

    test('isConservative false for p95', () {
      const VarEstimate est = VarEstimate(
        portfolioId: 'p1',
        confidence: VarConfidenceLevel.p95,
        horizonDays: 10,
        estimatedLoss: 0.08,
        estimationMethod: 'parametric',
      );
      expect(est.isConservative, isFalse);
      expect(est.isOneDay, isFalse);
    });

    test('annualizedLoss computed for 10-day VaR', () {
      const VarEstimate est = VarEstimate(
        portfolioId: 'p1',
        confidence: VarConfidenceLevel.p95,
        horizonDays: 10,
        estimatedLoss: 0.10,
        estimationMethod: 'monte_carlo',
      );
      expect(est.annualizedLoss, closeTo(2.52, 0.01));
    });

    test('equality', () {
      const VarEstimate a = VarEstimate(
        portfolioId: 'p1',
        confidence: VarConfidenceLevel.p99,
        horizonDays: 1,
        estimatedLoss: 0.05,
        estimationMethod: 'historical',
      );
      const VarEstimate b = VarEstimate(
        portfolioId: 'p1',
        confidence: VarConfidenceLevel.p99,
        horizonDays: 1,
        estimatedLoss: 0.05,
        estimationMethod: 'historical',
      );
      expect(a, equals(b));
    });
  });
}
