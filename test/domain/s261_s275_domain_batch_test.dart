// S261–S275 domain batch tests.
import 'package:cross_tide/src/domain/alert_delivery_trace.dart';
import 'package:cross_tide/src/domain/alert_handler_plugin.dart';
import 'package:cross_tide/src/domain/alert_rule_template.dart';
import 'package:cross_tide/src/domain/community_watchlist_subscription.dart';
import 'package:cross_tide/src/domain/data_export_manifest.dart';
import 'package:cross_tide/src/domain/leaderboard_opt_in.dart';
import 'package:cross_tide/src/domain/news_article.dart';
import 'package:cross_tide/src/domain/news_feed_aggregator.dart';
import 'package:cross_tide/src/domain/pattern_signal_library.dart';
import 'package:cross_tide/src/domain/plugin_registry.dart';
import 'package:cross_tide/src/domain/prometheus_alert_collector.dart';
import 'package:cross_tide/src/domain/rest_api_request_log.dart';
import 'package:cross_tide/src/domain/signal_explanation.dart';
import 'package:cross_tide/src/domain/subscription_tier.dart';
import 'package:cross_tide/src/domain/technical_summary_snapshot.dart';
import 'package:cross_tide/src/domain/tier_feature_gate.dart';
import 'package:cross_tide/src/domain/user_defined_indicator.dart';
import 'package:cross_tide/src/domain/user_engagement_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── S261 PrometheusAlertCollector ─────────────────────────────────────────

  group('PrometheusAlertCollector', () {
    test('AlertMetricPoint alertsPerHour is normalised for 24h window', () {
      final p = AlertMetricPoint(
        ticker: 'AAPL',
        window: AlertRateWindow.twentyFourHours,
        alertCount: 48,
        sampledAt: DateTime(2026),
      );
      expect(p.alertsPerHour, 2.0);
    });

    test('AlertMetricPoint alertsPerHour equals count for 1h window', () {
      final p = AlertMetricPoint(
        ticker: 'TSLA',
        window: AlertRateWindow.oneHour,
        alertCount: 5,
        sampledAt: DateTime(2026),
      );
      expect(p.alertsPerHour, 5.0);
    });

    test('totalAlertsForWindow sums correct window', () {
      final p1 = AlertMetricPoint(
        ticker: 'AAPL',
        window: AlertRateWindow.oneHour,
        alertCount: 3,
        sampledAt: DateTime(2026),
      );
      final p2 = AlertMetricPoint(
        ticker: 'MSFT',
        window: AlertRateWindow.oneHour,
        alertCount: 2,
        sampledAt: DateTime(2026),
      );
      final p3 = AlertMetricPoint(
        ticker: 'TSLA',
        window: AlertRateWindow.twentyFourHours,
        alertCount: 10,
        sampledAt: DateTime(2026),
      );
      final collector = PrometheusAlertCollector(
        points: [p1, p2, p3],
        collectedAt: DateTime(2026),
      );
      expect(collector.totalAlertsForWindow(AlertRateWindow.oneHour), 5);
    });

    test('pointsForTicker filters by ticker', () {
      final p1 = AlertMetricPoint(
        ticker: 'AAPL',
        window: AlertRateWindow.oneHour,
        alertCount: 1,
        sampledAt: DateTime(2026),
      );
      final p2 = AlertMetricPoint(
        ticker: 'MSFT',
        window: AlertRateWindow.oneHour,
        alertCount: 1,
        sampledAt: DateTime(2026),
      );
      final collector = PrometheusAlertCollector(
        points: [p1, p2],
        collectedAt: DateTime(2026),
      );
      expect(collector.pointsForTicker('AAPL').length, 1);
    });

    test('AlertMetricPoint equality', () {
      final p1 = AlertMetricPoint(
        ticker: 'X',
        window: AlertRateWindow.sevenDays,
        alertCount: 7,
        sampledAt: DateTime(2026),
      );
      final p2 = AlertMetricPoint(
        ticker: 'X',
        window: AlertRateWindow.sevenDays,
        alertCount: 7,
        sampledAt: DateTime(2026),
      );
      expect(p1, equals(p2));
    });
  });

  // ── S262 AlertDeliveryTrace ───────────────────────────────────────────────

  group('AlertDeliveryTrace', () {
    test('allDelivered true when all sinks succeeded', () {
      final sink = DeliverySinkResult(
        sinkId: 'discord',
        sinkName: 'Discord',
        status: DeliveryStatus.delivered,
        attemptedAt: DateTime(2026),
      );
      final trace = AlertDeliveryTrace(
        alertId: 'a1',
        ticker: 'AAPL',
        firedAt: DateTime(2026),
        sinkResults: [sink],
      );
      expect(trace.allDelivered, isTrue);
    });

    test('allDelivered false when at least one sink failed', () {
      final ok = DeliverySinkResult(
        sinkId: 's1',
        sinkName: 'Slack',
        status: DeliveryStatus.delivered,
        attemptedAt: DateTime(2026),
      );
      final fail = DeliverySinkResult(
        sinkId: 's2',
        sinkName: 'Email',
        status: DeliveryStatus.failed,
        attemptedAt: DateTime(2026),
        errorMessage: 'SMTP error',
      );
      final trace = AlertDeliveryTrace(
        alertId: 'a2',
        ticker: 'MSFT',
        firedAt: DateTime(2026),
        sinkResults: [ok, fail],
      );
      expect(trace.allDelivered, isFalse);
    });

    test('pendingRetries returns only retrying sinks', () {
      final retrying = DeliverySinkResult(
        sinkId: 'webhook',
        sinkName: 'Webhook',
        status: DeliveryStatus.retrying,
        attemptedAt: DateTime(2026),
        attemptCount: 2,
      );
      final done = DeliverySinkResult(
        sinkId: 'inapp',
        sinkName: 'In-App',
        status: DeliveryStatus.delivered,
        attemptedAt: DateTime(2026),
      );
      final trace = AlertDeliveryTrace(
        alertId: 'a3',
        ticker: 'TSLA',
        firedAt: DateTime(2026),
        sinkResults: [retrying, done],
      );
      expect(trace.pendingRetries.length, 1);
      expect(trace.pendingRetries.first.sinkId, 'webhook');
    });

    test('DeliverySinkResult wasSuccessful is true for delivered status', () {
      final sink = DeliverySinkResult(
        sinkId: 'x',
        sinkName: 'X',
        status: DeliveryStatus.delivered,
        attemptedAt: DateTime(2026),
      );
      expect(sink.wasSuccessful, isTrue);
    });

    test('DeliverySinkResult wasSuccessful is false for failed status', () {
      final errored = DeliverySinkResult(
        sinkId: 'y',
        sinkName: 'Y',
        status: DeliveryStatus.failed,
        attemptedAt: DateTime(2026),
        errorMessage: 'timeout',
        attemptCount: 3,
      );
      expect(errored.wasSuccessful, isFalse);
      expect(errored.attemptCount, 3);
    });
  });

  // ── S263 NewsFeedAggregator ───────────────────────────────────────────────

  group('NewsFeedAggregator', () {
    NewsArticle makeArticle(
      String id, {
      bool highRelevance = false,
      DateTime? publishedAt,
    }) => NewsArticle(
      id: id,
      headline: id,
      source: NewsSource.rss,
      publishedAt: publishedAt ?? DateTime(2026),
      ticker: 'AAPL',
      sentimentHint: NewsSentimentHint.neutral,
      relevanceScore: highRelevance ? 0.9 : 0.3,
    );

    test('isEmpty true when no articles', () {
      const filter = FeedFilter(ticker: 'AAPL');
      final feed = NewsFeedAggregator(
        filter: filter,
        articles: const [],
        aggregatedAt: DateTime(2026),
      );
      expect(feed.isEmpty, isTrue);
    });

    test('latestArticle returns most recent', () {
      final a1 = makeArticle('old', publishedAt: DateTime(2026, 1, 1));
      final a2 = makeArticle('new', publishedAt: DateTime(2026, 6, 1));
      const filter = FeedFilter(ticker: 'AAPL');
      final feed = NewsFeedAggregator(
        filter: filter,
        articles: [a1, a2],
        aggregatedAt: DateTime(2026),
      );
      expect(feed.latestArticle?.id, 'new');
    });

    test('highRelevanceArticles filters below 0.7 threshold', () {
      final low = makeArticle('low');
      final high = makeArticle('high', highRelevance: true);
      const filter = FeedFilter(ticker: 'AAPL');
      final feed = NewsFeedAggregator(
        filter: filter,
        articles: [low, high],
        aggregatedAt: DateTime(2026),
      );
      expect(feed.highRelevanceArticles.length, 1);
      expect(feed.highRelevanceArticles.first.id, 'high');
    });

    test('FeedFilter equality', () {
      const f1 = FeedFilter(ticker: 'AAPL', maxAgeHours: 24);
      const f2 = FeedFilter(ticker: 'AAPL', maxAgeHours: 24);
      expect(f1, equals(f2));
    });
  });

  // ── S264 LeaderboardOptIn ─────────────────────────────────────────────────

  group('LeaderboardOptIn', () {
    test('defaultFor creates opted-out anonymous profile', () {
      final profile = LeaderboardOptIn.defaultFor('user1');
      expect(profile.isOptedIn, isFalse);
      expect(profile.privacyLevel, LeaderboardPrivacyLevel.anonymous);
      expect(profile.consentHistory, isEmpty);
    });

    test('optIn returns opted-in copy', () {
      final profile = LeaderboardOptIn.defaultFor('user1');
      final consent = LeaderboardConsent(
        granted: true,
        decidedAt: DateTime(2026),
      );
      final opted = profile.optIn(consent);
      expect(opted.isOptedIn, isTrue);
      expect(opted.privacyLevel, LeaderboardPrivacyLevel.masked);
      expect(opted.latestConsent?.granted, isTrue);
    });

    test('optOut after optIn sets isOptedIn false', () {
      final profile = LeaderboardOptIn.defaultFor('user1');
      final consentIn = LeaderboardConsent(
        granted: true,
        decidedAt: DateTime(2026, 1),
      );
      final consentOut = LeaderboardConsent(
        granted: false,
        decidedAt: DateTime(2026, 2),
      );
      final opted = profile.optIn(consentIn).optOut(consentOut);
      expect(opted.isOptedIn, isFalse);
      expect(opted.consentHistory.length, 2);
    });

    test('latestConsent is null when no history', () {
      final profile = LeaderboardOptIn.defaultFor('u');
      expect(profile.latestConsent, isNull);
    });
  });

  // ── S265 CommunityWatchlistSubscription ───────────────────────────────────

  group('CommunityWatchlistSubscription', () {
    final sub = CommunityWatchlistSubscription(
      subscriptionId: 'sub1',
      watchlistId: 'wl1',
      watchlistName: 'ARK Picks',
      subscribedAt: DateTime(1970),
      state: SubscriptionState.active,
    );

    test('isActive is true for active state', () {
      expect(sub.isActive, isTrue);
    });

    test('pause() sets state to paused', () {
      final paused = sub.pause();
      expect(paused.state, SubscriptionState.paused);
      expect(paused.isActive, isFalse);
    });

    test('markSynced updates lastSyncedAt', () {
      final synced = sub.markSynced(DateTime(2026, 5));
      expect(synced.lastSyncedAt, DateTime(2026, 5));
    });

    test('equality on identical objects', () {
      final sub2 = CommunityWatchlistSubscription(
        subscriptionId: 'sub1',
        watchlistId: 'wl1',
        watchlistName: 'ARK Picks',
        subscribedAt: DateTime(1970),
        state: SubscriptionState.active,
      );
      expect(sub, equals(sub2));
    });
  });

  // ── S266 PatternSignalLibrary ─────────────────────────────────────────────

  group('PatternSignalLibrary', () {
    const upSetup = SignalSetup(
      id: 'sma200_cross',
      name: 'SMA200 Cross-Up',
      trendContext: SetupTrendContext.uptrend,
      outcome: SetupOutcome(
        winRate: 0.65,
        avgGainPct: 8.0,
        avgLossPct: 3.0,
        sampleCount: 50,
      ),
      conditionSummary: 'Close crosses above SMA200',
    );
    const anySetup = SignalSetup(
      id: 'rsi_oversold',
      name: 'RSI Oversold Exit',
      trendContext: SetupTrendContext.any,
      outcome: SetupOutcome(
        winRate: 0.55,
        avgGainPct: 5.0,
        avgLossPct: 4.0,
        sampleCount: 120,
      ),
      conditionSummary: 'RSI exits below 30',
    );

    test('setupsForContext returns matching + any entries', () {
      const lib = PatternSignalLibrary(setups: [upSetup, anySetup]);
      final results = lib.setupsForContext(SetupTrendContext.uptrend);
      expect(results.length, 2); // uptrend + any
    });

    test(
      'highConfidenceSetups filters by win rate >= 0.6 and sampleCount >= 30',
      () {
        const lib = PatternSignalLibrary(setups: [upSetup, anySetup]);
        expect(lib.highConfidenceSetups.length, 1);
        expect(lib.highConfidenceSetups.first.id, 'sma200_cross');
      },
    );

    test('SetupOutcome expectedValue is computed correctly', () {
      const outcome = SetupOutcome(
        winRate: 0.65,
        avgGainPct: 8.0,
        avgLossPct: 3.0,
        sampleCount: 50,
      );
      expect(outcome.expectedValue, closeTo(0.65 * 8.0 - 0.35 * 3.0, 0.001));
    });

    test('SetupOutcome asserts invalid winRate', () {
      expect(
        () => SetupOutcome(
          winRate: 1.5,
          avgGainPct: 5,
          avgLossPct: 2,
          sampleCount: 10,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S267 SignalExplanation ────────────────────────────────────────────────

  group('SignalExplanation', () {
    const bullFactor = ExplanationFactor(
      label: 'RSI exit',
      description: 'RSI crossed above 30',
      isBullish: true,
      weight: 0.8,
    );
    const bearFactor = ExplanationFactor(
      label: 'Volume low',
      description: 'Volume below average',
      isBullish: false,
      weight: 0.3,
    );

    test('supportingFactors returns only bullish factors', () {
      final exp = SignalExplanation(
        ticker: 'AAPL',
        methodName: 'RSI',
        summary: 'RSI oversold exit',
        factors: const [bullFactor, bearFactor],
        confidenceLevel: ExplanationConfidenceLevel.moderate,
        explainedAt: DateTime(2026),
      );
      expect(exp.supportingFactors.length, 1);
      expect(exp.conflictingFactors.length, 1);
    });

    test('isHighConfidence true for high level', () {
      final exp = SignalExplanation(
        ticker: 'X',
        methodName: 'Micho',
        summary: 's',
        factors: const [],
        confidenceLevel: ExplanationConfidenceLevel.high,
        explainedAt: DateTime(2026),
      );
      expect(exp.isHighConfidence, isTrue);
    });

    test('ExplanationFactor asserts invalid weight', () {
      expect(
        () => ExplanationFactor(
          label: 'l',
          description: 'd',
          isBullish: true,
          weight: 1.5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S268 PluginRegistry ───────────────────────────────────────────────────

  group('PluginRegistry', () {
    final plugin = AlertHandlerPlugin.disabled(
      PluginSinkType.discord,
      'Discord',
    );
    final entry = RegistrationEntry(
      plugin: plugin,
      lifecycleState: PluginLifecycleState.registered,
    );

    test('empty registry has no active plugins', () {
      const registry = PluginRegistry.empty();
      expect(registry.activePlugins, isEmpty);
    });

    test('withEntry adds entry', () {
      const registry = PluginRegistry.empty();
      final updated = registry.withEntry(entry);
      expect(updated.entries.length, 1);
    });

    test('activePlugins returns only active entries', () {
      final active = entry.activate();
      final registry = PluginRegistry(entries: [entry, active]);
      expect(registry.activePlugins.length, 1);
    });

    test('entryFor returns null for unknown id', () {
      const registry = PluginRegistry.empty();
      expect(registry.entryFor('not_found'), isNull);
    });

    test('RegistrationEntry.withError increments errorCount', () {
      final errored = entry.withError('init failed');
      expect(errored.lifecycleState, PluginLifecycleState.errored);
      expect(errored.errorCount, 1);
    });
  });

  // ── S269 AlertRuleTemplate ────────────────────────────────────────────────

  group('AlertRuleTemplate', () {
    const param = TemplateParameter(
      key: 'smaPeriod',
      label: 'SMA Period',
      defaultValue: 200,
      minValue: 10,
      maxValue: 500,
    );
    const template = AlertRuleTemplate(
      id: 'sma_cross',
      name: 'SMA Cross',
      category: RuleTemplateCategory.movingAverageCrossover,
      conditionExpression: 'sma(smaPeriod) crossAbove',
      parameters: [param],
      isBuiltIn: true,
    );

    test('defaultParameters returns a map of key→defaultValue', () {
      expect(template.defaultParameters, {'smaPeriod': 200.0});
    });

    test('TemplateParameter hasRange true when both bounds set', () {
      expect(param.hasRange, isTrue);
    });

    test('isBuiltIn is preserved', () {
      expect(template.isBuiltIn, isTrue);
    });

    test('equality on identical objects', () {
      const t2 = AlertRuleTemplate(
        id: 'sma_cross',
        name: 'SMA Cross',
        category: RuleTemplateCategory.movingAverageCrossover,
        conditionExpression: 'sma(smaPeriod) crossAbove',
        parameters: [param],
        isBuiltIn: true,
      );
      expect(template, equals(t2));
    });
  });

  // ── S270 UserDefinedIndicator ─────────────────────────────────────────────

  group('UserDefinedIndicator', () {
    final indicator = UserDefinedIndicator(
      id: 'my_sma50',
      name: 'My SMA50',
      formulaId: 'formula_sma50',
      displayStyle: IndicatorDisplayStyle.overlayLine,
      createdAt: DateTime(2026),
      colorHex: '#FF6600',
    );

    test('isVisible defaults to true', () {
      expect(indicator.isVisible, isTrue);
    });

    test('toggleVisibility inverts isVisible', () {
      final hidden = indicator.toggleVisibility();
      expect(hidden.isVisible, isFalse);
    });

    test('equality based on all fields', () {
      final i2 = UserDefinedIndicator(
        id: 'my_sma50',
        name: 'My SMA50',
        formulaId: 'formula_sma50',
        displayStyle: IndicatorDisplayStyle.overlayLine,
        createdAt: DateTime(2026),
        colorHex: '#FF6600',
      );
      expect(indicator, equals(i2));
    });
  });

  // ── S271 TierFeatureGate ──────────────────────────────────────────────────

  group('TierFeatureGate', () {
    test('free tier allows nothing from pro features', () {
      final gate = TierFeatureGate(tier: SubscriptionTier.free());
      final decision = gate.evaluate(TierFeature.customIndicators);
      expect(decision.allowed, isFalse);
      expect(decision.upgradeReason, UpgradeReason.requiresPro);
    });

    test('pro tier allows pro features', () {
      final gate = TierFeatureGate(tier: SubscriptionTier.pro());
      final decision = gate.evaluate(TierFeature.customIndicators);
      expect(decision.allowed, isTrue);
    });

    test('GateDecision.allowed has no upgradeReason', () {
      final d = GateDecision.allowed(TierFeature.webhooks);
      expect(d.allowed, isTrue);
      expect(d.upgradeReason, isNull);
    });

    test('GateDecision.denied has upgradeReason and prompt', () {
      final d = GateDecision.denied(
        TierFeature.aiSignals,
        upgradeReason: UpgradeReason.requiresEnterprise,
        upgradePrompt: 'Upgrade to Enterprise',
      );
      expect(d.allowed, isFalse);
      expect(d.upgradePrompt, 'Upgrade to Enterprise');
    });
  });

  // ── S272 RestApiRequestLog ────────────────────────────────────────────────

  group('RestApiRequestLog', () {
    test('empty log has successRate 1.0 and avgDurationMs 0', () {
      final log = RestApiRequestLog.empty();
      expect(log.successRate, 1.0);
      expect(log.avgDurationMs, 0.0);
    });

    test('successRate computes fraction of 2xx responses', () {
      final e1 = ApiRequestEntry(
        requestId: 'r1',
        method: ApiHttpMethod.get,
        path: '/api/alerts',
        statusCode: 200,
        durationMs: 100,
        requestedAt: DateTime(2026),
      );
      final e2 = ApiRequestEntry(
        requestId: 'r2',
        method: ApiHttpMethod.post,
        path: '/api/config',
        statusCode: 404,
        durationMs: 50,
        requestedAt: DateTime(2026),
      );
      final log = RestApiRequestLog.empty().withEntry(e1).withEntry(e2);
      expect(log.successRate, 0.5);
    });

    test('withEntry trims to maxEntries', () {
      var log = RestApiRequestLog.empty(maxEntries: 2);
      for (int i = 0; i < 5; i++) {
        log = log.withEntry(
          ApiRequestEntry(
            requestId: 'r$i',
            method: ApiHttpMethod.get,
            path: '/test',
            statusCode: 200,
            durationMs: 10,
            requestedAt: DateTime(2026),
          ),
        );
      }
      expect(log.entries.length, 2);
    });
  });

  // ── S273 DataExportManifest ───────────────────────────────────────────────

  group('DataExportManifest', () {
    final manifest = DataExportManifest(
      tickers: const ['AAPL', 'MSFT'],
      fields: const [ExportField.date, ExportField.closePrice],
      format: ExportFormat.csv,
      fromDate: DateTime(2025, 1, 1),
      toDate: DateTime(2026, 1, 1),
    );

    test('dateRange is one year', () {
      expect(manifest.dateRange.inDays, greaterThanOrEqualTo(365));
    });

    test('estimatedRowCount is positive for two tickers', () {
      expect(manifest.estimatedRowCount, greaterThan(0));
    });

    test('equality on identical manifests', () {
      final m2 = DataExportManifest(
        tickers: const ['AAPL', 'MSFT'],
        fields: const [ExportField.date, ExportField.closePrice],
        format: ExportFormat.csv,
        fromDate: DateTime(2025, 1, 1),
        toDate: DateTime(2026, 1, 1),
      );
      expect(manifest, equals(m2));
    });
  });

  // ── S274 TechnicalSummarySnapshot ────────────────────────────────────────

  group('TechnicalSummarySnapshot', () {
    test('pctFromSma200 computes percentage distance', () {
      final snapshot = TechnicalSummarySnapshot(
        ticker: 'AAPL',
        closePrice: 210.0,
        readings: const IndicatorReadings(sma200: 200.0),
        snapshotAt: DateTime(2026),
      );
      expect(snapshot.pctFromSma200, closeTo(5.0, 0.001));
    });

    test('isAboveSma200 true when close > SMA200', () {
      final snapshot = TechnicalSummarySnapshot(
        ticker: 'AAPL',
        closePrice: 210.0,
        readings: const IndicatorReadings(sma200: 200.0),
        snapshotAt: DateTime(2026),
      );
      expect(snapshot.isAboveSma200, isTrue);
    });

    test('pctFromSma200 null when SMA200 not available', () {
      final snapshot = TechnicalSummarySnapshot(
        ticker: 'X',
        closePrice: 100.0,
        readings: const IndicatorReadings(),
        snapshotAt: DateTime(2026),
      );
      expect(snapshot.pctFromSma200, isNull);
    });

    test('IndicatorReadings hasSufficientData requires sma200+rsi+macd', () {
      const r = IndicatorReadings(sma200: 200, rsi14: 45, macd: 1.2);
      expect(r.hasSufficientData, isTrue);
    });

    test('hasSufficientData false when any key indicator missing', () {
      const r = IndicatorReadings(sma200: 200, rsi14: 45);
      expect(r.hasSufficientData, isFalse);
    });
  });

  // ── S275 UserEngagementEvent ──────────────────────────────────────────────

  group('UserEngagementEvent', () {
    test('AppOpen event has no ticker', () {
      final event = UserEngagementEvent(
        eventId: 'e1',
        eventType: EngagementEventType.appOpen,
        occurredAt: DateTime(1970),
      );
      expect(event.ticker, isNull);
    });

    test('alertActioned event can carry ticker', () {
      final event = UserEngagementEvent(
        eventId: 'e2',
        eventType: EngagementEventType.alertActioned,
        occurredAt: DateTime(1970),
        ticker: 'AAPL',
      );
      expect(event.ticker, 'AAPL');
    });

    test('EngagementSession duration covers first to last event', () {
      final e1 = UserEngagementEvent(
        eventId: 'e1',
        eventType: EngagementEventType.appOpen,
        occurredAt: DateTime(2026, 1, 1, 10, 0),
      );
      final e2 = UserEngagementEvent(
        eventId: 'e2',
        eventType: EngagementEventType.alertActioned,
        occurredAt: DateTime(2026, 1, 1, 10, 5),
      );
      final session = EngagementSession(
        sessionId: 's1',
        startedAt: DateTime(2026, 1, 1, 10, 0),
        events: [e1, e2],
      );
      expect(session.duration.inMinutes, 5);
    });

    test('alertActionCount counts only actioned events', () {
      final events = [
        UserEngagementEvent(
          eventId: 'e1',
          eventType: EngagementEventType.alertActioned,
          occurredAt: DateTime(2026),
        ),
        UserEngagementEvent(
          eventId: 'e2',
          eventType: EngagementEventType.alertDismissed,
          occurredAt: DateTime(2026),
        ),
        UserEngagementEvent(
          eventId: 'e3',
          eventType: EngagementEventType.alertActioned,
          occurredAt: DateTime(2026),
        ),
      ];
      final session = EngagementSession(
        sessionId: 's2',
        startedAt: DateTime(2026),
        events: events,
      );
      expect(session.alertActionCount, 2);
    });

    test('empty session has zero duration', () {
      final session = EngagementSession(
        sessionId: 's3',
        startedAt: DateTime(2026),
        events: const [],
      );
      expect(session.duration, Duration.zero);
    });
  });
}
