import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── S466: SignalExpiryConfig ──────────────────────────────────────────────
  group('SignalExpiryConfig', () {
    test('isAggressiveExpiry true for short maxAge', () {
      const SignalExpiryConfig cfg = SignalExpiryConfig(
        configId: 'se1',
        methodName: 'rsi',
        maxAgeSeconds: 1800,
        invalidateOnOppositeSignal: true,
      );
      expect(cfg.isAggressiveExpiry, isTrue);
      expect(cfg.requiresCandelAlignment, isTrue);
    });

    test('isAggressiveExpiry false for long maxAge without opposite', () {
      const SignalExpiryConfig cfg = SignalExpiryConfig(
        configId: 'se2',
        methodName: 'macd',
        maxAgeSeconds: 7200,
        invalidateOnOppositeSignal: false,
      );
      expect(cfg.isAggressiveExpiry, isFalse);
    });

    test('equality', () {
      const SignalExpiryConfig a = SignalExpiryConfig(
        configId: 'se1',
        methodName: 'rsi',
        maxAgeSeconds: 3600,
      );
      const SignalExpiryConfig b = SignalExpiryConfig(
        configId: 'se1',
        methodName: 'rsi',
        maxAgeSeconds: 3600,
      );
      expect(a, equals(b));
    });
  });

  // ── S467: MethodOverrideConfig ────────────────────────────────────────────
  group('MethodOverrideConfig', () {
    test('isDisabled true when mode is disabled', () {
      const MethodOverrideConfig cfg = MethodOverrideConfig(
        configId: 'mo1',
        ticker: 'TSLA',
        methodName: 'bollinger',
        mode: MethodOverrideMode.disabled,
        reason: 'Too noisy for this ticker',
      );
      expect(cfg.isDisabled, isTrue);
      expect(cfg.hasReason, isTrue);
      expect(cfg.hasThresholdAdjustment, isFalse);
    });

    test('hasThresholdAdjustment true for non-zero delta', () {
      const MethodOverrideConfig cfg = MethodOverrideConfig(
        configId: 'mo2',
        ticker: 'AAPL',
        methodName: 'rsi',
        mode: MethodOverrideMode.adjustThreshold,
        thresholdAdjustment: 5.0,
      );
      expect(cfg.hasThresholdAdjustment, isTrue);
      expect(cfg.isDisabled, isFalse);
    });

    test('equality', () {
      const MethodOverrideConfig a = MethodOverrideConfig(
        configId: 'mo1',
        ticker: 'SPY',
        methodName: 'macd',
        mode: MethodOverrideMode.forceEnable,
      );
      const MethodOverrideConfig b = MethodOverrideConfig(
        configId: 'mo1',
        ticker: 'SPY',
        methodName: 'macd',
        mode: MethodOverrideMode.forceEnable,
      );
      expect(a, equals(b));
    });
  });

  // ── S468: AlertEscalationChain ────────────────────────────────────────────
  group('AlertEscalationChain', () {
    test('isMultiChannel true when channel count > 1', () {
      const AlertEscalationChain chain = AlertEscalationChain(
        chainId: 'aec1',
        ticker: 'AAPL',
        channels: ['push', 'telegram', 'email'],
        escalationDelaySeconds: 180,
      );
      expect(chain.isMultiChannel, isTrue);
      expect(chain.channelCount, equals(3));
      expect(chain.isAggressiveEscalation, isTrue);
    });

    test('isAggressiveEscalation false for slow escalation', () {
      const AlertEscalationChain chain = AlertEscalationChain(
        chainId: 'aec2',
        ticker: 'MSFT',
        channels: ['push'],
        escalationDelaySeconds: 600,
      );
      expect(chain.isAggressiveEscalation, isFalse);
      expect(chain.isMultiChannel, isFalse);
    });

    test('equality', () {
      const AlertEscalationChain a = AlertEscalationChain(
        chainId: 'aec1',
        ticker: 'SPY',
        channels: ['push', 'email'],
        escalationDelaySeconds: 300,
      );
      const AlertEscalationChain b = AlertEscalationChain(
        chainId: 'aec1',
        ticker: 'SPY',
        channels: ['push', 'email'],
        escalationDelaySeconds: 300,
      );
      expect(a, equals(b));
    });
  });

  // ── S469: ConsensusOverrideRecord ─────────────────────────────────────────
  group('ConsensusOverrideRecord', () {
    test('isEscalated true when neutral becomes BUY', () {
      const ConsensusOverrideRecord r = ConsensusOverrideRecord(
        recordId: 'cor1',
        ticker: 'AAPL',
        originalSignal: 'NEUTRAL',
        overriddenSignal: 'BUY',
        overriddenBy: 'trader1',
        reason: 'Earnings imminent',
      );
      expect(r.isEscalated, isTrue);
      expect(r.isDemoted, isFalse);
      expect(r.hasReason, isTrue);
    });

    test('isDemoted true when BUY becomes NEUTRAL', () {
      const ConsensusOverrideRecord r = ConsensusOverrideRecord(
        recordId: 'cor2',
        ticker: 'TSLA',
        originalSignal: 'BUY',
        overriddenSignal: 'NEUTRAL',
        overriddenBy: 'trader2',
      );
      expect(r.isDemoted, isTrue);
      expect(r.isEscalated, isFalse);
    });

    test('equality', () {
      const ConsensusOverrideRecord a = ConsensusOverrideRecord(
        recordId: 'cor1',
        ticker: 'SPY',
        originalSignal: 'SELL',
        overriddenSignal: 'NEUTRAL',
        overriddenBy: 'u1',
      );
      const ConsensusOverrideRecord b = ConsensusOverrideRecord(
        recordId: 'cor1',
        ticker: 'SPY',
        originalSignal: 'SELL',
        overriddenSignal: 'NEUTRAL',
        overriddenBy: 'u1',
      );
      expect(a, equals(b));
    });
  });

  // ── S470: SignalReplayCursor ──────────────────────────────────────────────
  group('SignalReplayCursor', () {
    test('progressPercent computed correctly', () {
      const SignalReplayCursor cursor = SignalReplayCursor(
        sessionId: 's1',
        ticker: 'AAPL',
        totalCandles: 200,
        currentIndex: 50,
        signalsFiredCount: 3,
      );
      expect(cursor.progressPercent, closeTo(25.0, 0.01));
      expect(cursor.isComplete, isFalse);
      expect(cursor.isRunning, isTrue);
    });

    test('isComplete true when index reaches totalCandles', () {
      const SignalReplayCursor cursor = SignalReplayCursor(
        sessionId: 's2',
        ticker: 'MSFT',
        totalCandles: 100,
        currentIndex: 100,
        signalsFiredCount: 10,
      );
      expect(cursor.isComplete, isTrue);
      expect(cursor.isRunning, isFalse);
    });

    test('equality', () {
      const SignalReplayCursor a = SignalReplayCursor(
        sessionId: 's1',
        ticker: 'SPY',
        totalCandles: 252,
        currentIndex: 126,
        signalsFiredCount: 5,
      );
      const SignalReplayCursor b = SignalReplayCursor(
        sessionId: 's1',
        ticker: 'SPY',
        totalCandles: 252,
        currentIndex: 126,
        signalsFiredCount: 5,
      );
      expect(a, equals(b));
    });
  });

  // ── S471: FeedSubscriptionConfig ─────────────────────────────────────────
  group('FeedSubscriptionConfig', () {
    test('isStreaming true for websocket', () {
      const FeedSubscriptionConfig cfg = FeedSubscriptionConfig(
        subscriptionId: 'sub1',
        feedName: 'AlphaVantage',
        protocol: FeedProtocol.websocket,
        tickerSymbols: ['AAPL', 'TSLA', 'SPY'],
      );
      expect(cfg.isStreaming, isTrue);
      expect(cfg.isPolling, isFalse);
      expect(cfg.symbolCount, equals(3));
    });

    test('isPolling true for polling protocol', () {
      const FeedSubscriptionConfig cfg = FeedSubscriptionConfig(
        subscriptionId: 'sub2',
        feedName: 'Yahoo',
        protocol: FeedProtocol.polling,
        tickerSymbols: ['AAPL'],
        isActive: false,
      );
      expect(cfg.isPolling, isTrue);
      expect(cfg.isStreaming, isFalse);
      expect(cfg.isActive, isFalse);
    });

    test('equality', () {
      const FeedSubscriptionConfig a = FeedSubscriptionConfig(
        subscriptionId: 's1',
        feedName: 'Yahoo',
        protocol: FeedProtocol.sse,
        tickerSymbols: ['AAPL'],
      );
      const FeedSubscriptionConfig b = FeedSubscriptionConfig(
        subscriptionId: 's1',
        feedName: 'Yahoo',
        protocol: FeedProtocol.sse,
        tickerSymbols: ['AAPL'],
      );
      expect(a, equals(b));
    });
  });

  // ── S472: QuoteCacheEntry ─────────────────────────────────────────────────
  group('QuoteCacheEntry', () {
    test('midPrice computed correctly', () {
      const QuoteCacheEntry entry = QuoteCacheEntry(
        ticker: 'SPY',
        bidPrice: 499.90,
        askPrice: 500.10,
        lastPrice: 500.00,
        cachedAtMs: 1000000,
        ttlSeconds: 60,
      );
      expect(entry.midPrice, closeTo(500.0, 0.01));
      expect(entry.hasSpread, isTrue);
      expect(entry.isStale(1000000 + 61000), isTrue);
      expect(entry.isStale(1000000 + 30000), isFalse);
    });

    test('equality', () {
      const QuoteCacheEntry a = QuoteCacheEntry(
        ticker: 'AAPL',
        bidPrice: 180.0,
        askPrice: 180.5,
        lastPrice: 180.25,
        cachedAtMs: 2000000,
        ttlSeconds: 30,
      );
      const QuoteCacheEntry b = QuoteCacheEntry(
        ticker: 'AAPL',
        bidPrice: 180.0,
        askPrice: 180.5,
        lastPrice: 180.25,
        cachedAtMs: 2000000,
        ttlSeconds: 30,
      );
      expect(a, equals(b));
    });
  });

  // ── S473: DataSyncCheckpoint ──────────────────────────────────────────────
  group('DataSyncCheckpoint', () {
    test('isUpToDate true when consistent and no pending', () {
      const DataSyncCheckpoint cp = DataSyncCheckpoint(
        checkpointId: 'cp1',
        sourceId: 'yahoo',
        lastSyncedSequence: 1000,
        lastSyncedVersion: '1.2.3',
      );
      expect(cp.isUpToDate, isTrue);
      expect(cp.hasPendingChanges, isFalse);
    });

    test('isUpToDate false when has pending changes', () {
      const DataSyncCheckpoint cp = DataSyncCheckpoint(
        checkpointId: 'cp2',
        sourceId: 'av',
        lastSyncedSequence: 500,
        lastSyncedVersion: '1.0.0',
        pendingCount: 10,
      );
      expect(cp.hasPendingChanges, isTrue);
      expect(cp.isUpToDate, isFalse);
    });

    test('equality', () {
      const DataSyncCheckpoint a = DataSyncCheckpoint(
        checkpointId: 'cp1',
        sourceId: 'src1',
        lastSyncedSequence: 42,
        lastSyncedVersion: '2.0.0',
      );
      const DataSyncCheckpoint b = DataSyncCheckpoint(
        checkpointId: 'cp1',
        sourceId: 'src1',
        lastSyncedSequence: 42,
        lastSyncedVersion: '2.0.0',
      );
      expect(a, equals(b));
    });
  });

  // ── S474: DataSchemaVersion ───────────────────────────────────────────────
  group('DataSchemaVersion', () {
    test('requiresMigration true when isBreakingChange', () {
      const DataSchemaVersion v = DataSchemaVersion(
        schemaId: 'schema1',
        version: 16,
        minAppVersion: '2.13.0',
        tableCount: 18,
        isBreakingChange: true,
        description: 'Added FeedSubscription table',
      );
      expect(v.requiresMigration, isTrue);
      expect(v.hasDescription, isTrue);
    });

    test('requiresMigration false for non-breaking change', () {
      const DataSchemaVersion v = DataSchemaVersion(
        schemaId: 'schema2',
        version: 17,
        minAppVersion: '2.14.0',
        tableCount: 19,
      );
      expect(v.requiresMigration, isFalse);
      expect(v.hasDescription, isFalse);
    });

    test('equality', () {
      const DataSchemaVersion a = DataSchemaVersion(
        schemaId: 'sv1',
        version: 15,
        minAppVersion: '2.12.0',
        tableCount: 17,
      );
      const DataSchemaVersion b = DataSchemaVersion(
        schemaId: 'sv1',
        version: 15,
        minAppVersion: '2.12.0',
        tableCount: 17,
      );
      expect(a, equals(b));
    });
  });

  // ── S475: DataProviderHealthStatus ───────────────────────────────────────
  group('DataProviderHealthStatus', () {
    test('isHealthy true for healthy level', () {
      const DataProviderHealthStatus s = DataProviderHealthStatus(
        providerId: 'yahoo',
        providerName: 'Yahoo Finance',
        level: DataProviderHealthLevel.healthy,
        latencyMs: 250,
        successRateLast100: 0.99,
      );
      expect(s.isHealthy, isTrue);
      expect(s.isUnavailable, isFalse);
      expect(s.isHighLatency, isFalse);
      expect(s.hasError, isFalse);
    });

    test('isHighLatency and isUnavailable', () {
      const DataProviderHealthStatus s = DataProviderHealthStatus(
        providerId: 'av',
        providerName: 'AlphaVantage',
        level: DataProviderHealthLevel.unavailable,
        latencyMs: 5000,
        successRateLast100: 0.1,
        errorMessage: 'Rate limit exceeded',
      );
      expect(s.isUnavailable, isTrue);
      expect(s.isHighLatency, isTrue);
      expect(s.hasError, isTrue);
    });

    test('equality', () {
      const DataProviderHealthStatus a = DataProviderHealthStatus(
        providerId: 'src1',
        providerName: 'Stooq',
        level: DataProviderHealthLevel.degraded,
        latencyMs: 1200,
        successRateLast100: 0.85,
      );
      const DataProviderHealthStatus b = DataProviderHealthStatus(
        providerId: 'src1',
        providerName: 'Stooq',
        level: DataProviderHealthLevel.degraded,
        latencyMs: 1200,
        successRateLast100: 0.85,
      );
      expect(a, equals(b));
    });
  });

  // ── S476: AlphaDecayEstimate ──────────────────────────────────────────────
  group('AlphaDecayEstimate', () {
    test('isDecayed true when residual < 20% of initial', () {
      const AlphaDecayEstimate est = AlphaDecayEstimate(
        ticker: 'AAPL',
        methodName: 'micho',
        halfLifeDays: 3.0,
        initialAlphaBps: 100.0,
        residualAlphaBps: 15.0,
      );
      expect(est.isDecayed, isTrue);
      expect(est.isViable, isFalse);
      expect(est.decayPercent, closeTo(85.0, 0.01));
    });

    test('isViable true when residual > 20', () {
      const AlphaDecayEstimate est = AlphaDecayEstimate(
        ticker: 'SPY',
        methodName: 'rsi',
        halfLifeDays: 10.0,
        initialAlphaBps: 80.0,
        residualAlphaBps: 50.0,
      );
      expect(est.isViable, isTrue);
      expect(est.isDecayed, isFalse);
    });

    test('equality', () {
      const AlphaDecayEstimate a = AlphaDecayEstimate(
        ticker: 'MSFT',
        methodName: 'macd',
        halfLifeDays: 5.0,
        initialAlphaBps: 60.0,
        residualAlphaBps: 30.0,
      );
      const AlphaDecayEstimate b = AlphaDecayEstimate(
        ticker: 'MSFT',
        methodName: 'macd',
        halfLifeDays: 5.0,
        initialAlphaBps: 60.0,
        residualAlphaBps: 30.0,
      );
      expect(a, equals(b));
    });
  });

  // ── S477: InformationRatioResult ──────────────────────────────────────────
  group('InformationRatioResult', () {
    test('isExcellent true when IR >= 1.0', () {
      const InformationRatioResult r = InformationRatioResult(
        portfolioId: 'p1',
        benchmarkTicker: 'SPY',
        informationRatio: 1.3,
        activeReturnPercent: 6.5,
        trackingErrorPercent: 5.0,
        periodDays: 252,
      );
      expect(r.isExcellent, isTrue);
      expect(r.isGood, isTrue);
      expect(r.isPositiveAlpha, isTrue);
    });

    test('isGood true when IR >= 0.5 but < 1.0', () {
      const InformationRatioResult r = InformationRatioResult(
        portfolioId: 'p2',
        benchmarkTicker: 'QQQ',
        informationRatio: 0.7,
        activeReturnPercent: 3.5,
        trackingErrorPercent: 5.0,
        periodDays: 126,
      );
      expect(r.isGood, isTrue);
      expect(r.isExcellent, isFalse);
    });

    test('equality', () {
      const InformationRatioResult a = InformationRatioResult(
        portfolioId: 'p1',
        benchmarkTicker: 'SPY',
        informationRatio: 0.8,
        activeReturnPercent: 4.0,
        trackingErrorPercent: 5.0,
        periodDays: 252,
      );
      const InformationRatioResult b = InformationRatioResult(
        portfolioId: 'p1',
        benchmarkTicker: 'SPY',
        informationRatio: 0.8,
        activeReturnPercent: 4.0,
        trackingErrorPercent: 5.0,
        periodDays: 252,
      );
      expect(a, equals(b));
    });
  });

  // ── S478: CalmarRatioResult ───────────────────────────────────────────────
  group('CalmarRatioResult', () {
    test('isStrong true when calmar >= 1.0', () {
      const CalmarRatioResult r = CalmarRatioResult(
        portfolioId: 'p1',
        annualizedReturnPercent: 25.0,
        maxDrawdownPercent: 12.0,
        calmarRatio: 2.08,
        periodDays: 365,
      );
      expect(r.isStrong, isTrue);
      expect(r.isAcceptable, isTrue);
      expect(r.isNegativeReturn, isFalse);
    });

    test('isNegativeReturn true when return < 0', () {
      const CalmarRatioResult r = CalmarRatioResult(
        portfolioId: 'p2',
        annualizedReturnPercent: -5.0,
        maxDrawdownPercent: 20.0,
        calmarRatio: -0.25,
        periodDays: 252,
      );
      expect(r.isNegativeReturn, isTrue);
      expect(r.isAcceptable, isFalse);
    });

    test('equality', () {
      const CalmarRatioResult a = CalmarRatioResult(
        portfolioId: 'p1',
        annualizedReturnPercent: 15.0,
        maxDrawdownPercent: 10.0,
        calmarRatio: 1.5,
        periodDays: 252,
      );
      const CalmarRatioResult b = CalmarRatioResult(
        portfolioId: 'p1',
        annualizedReturnPercent: 15.0,
        maxDrawdownPercent: 10.0,
        calmarRatio: 1.5,
        periodDays: 252,
      );
      expect(a, equals(b));
    });
  });

  // ── S479: OmegaRatioResult ────────────────────────────────────────────────
  group('OmegaRatioResult', () {
    test('isFavorable true when omega > 1.0', () {
      const OmegaRatioResult r = OmegaRatioResult(
        portfolioId: 'p1',
        omegaRatio: 1.8,
        thresholdReturnPercent: 0.0,
        gainsProbabilityMass: 0.65,
        lossesProbabilityMass: 0.35,
        periodDays: 252,
      );
      expect(r.isFavorable, isTrue);
      expect(r.isStrong, isFalse);
    });

    test('isStrong true when omega >= 2.0', () {
      const OmegaRatioResult r = OmegaRatioResult(
        portfolioId: 'p2',
        omegaRatio: 2.5,
        thresholdReturnPercent: 0.5,
        gainsProbabilityMass: 0.70,
        lossesProbabilityMass: 0.30,
        periodDays: 365,
      );
      expect(r.isStrong, isTrue);
      expect(r.isFavorable, isTrue);
    });

    test('equality', () {
      const OmegaRatioResult a = OmegaRatioResult(
        portfolioId: 'p1',
        omegaRatio: 1.2,
        thresholdReturnPercent: 0.0,
        gainsProbabilityMass: 0.55,
        lossesProbabilityMass: 0.45,
        periodDays: 252,
      );
      const OmegaRatioResult b = OmegaRatioResult(
        portfolioId: 'p1',
        omegaRatio: 1.2,
        thresholdReturnPercent: 0.0,
        gainsProbabilityMass: 0.55,
        lossesProbabilityMass: 0.45,
        periodDays: 252,
      );
      expect(a, equals(b));
    });
  });

  // ── S480: TrackingErrorResult ─────────────────────────────────────────────
  group('TrackingErrorResult', () {
    test('isActivelyManaged true when TE >= 5%', () {
      const TrackingErrorResult r = TrackingErrorResult(
        portfolioId: 'p1',
        benchmarkTicker: 'SPY',
        trackingErrorPercent: 7.5,
        activeReturnPercent: 3.0,
        correlationWithBenchmark: 0.85,
        periodDays: 252,
      );
      expect(r.isActivelyManaged, isTrue);
      expect(r.isLowTracking, isFalse);
      expect(r.isHighlyCorrelated, isFalse);
    });

    test('isLowTracking and isHighlyCorrelated for index fund', () {
      const TrackingErrorResult r = TrackingErrorResult(
        portfolioId: 'idx1',
        benchmarkTicker: 'SPY',
        trackingErrorPercent: 0.1,
        activeReturnPercent: 0.0,
        correlationWithBenchmark: 0.999,
        periodDays: 252,
      );
      expect(r.isLowTracking, isTrue);
      expect(r.isHighlyCorrelated, isTrue);
      expect(r.isActivelyManaged, isFalse);
    });

    test('equality', () {
      const TrackingErrorResult a = TrackingErrorResult(
        portfolioId: 'p1',
        benchmarkTicker: 'SPY',
        trackingErrorPercent: 3.0,
        activeReturnPercent: 1.5,
        correlationWithBenchmark: 0.92,
        periodDays: 252,
      );
      const TrackingErrorResult b = TrackingErrorResult(
        portfolioId: 'p1',
        benchmarkTicker: 'SPY',
        trackingErrorPercent: 3.0,
        activeReturnPercent: 1.5,
        correlationWithBenchmark: 0.92,
        periodDays: 252,
      );
      expect(a, equals(b));
    });
  });
}
