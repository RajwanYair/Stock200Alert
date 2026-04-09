import 'package:cross_tide/src/domain/app_diagnostic_report.dart';
import 'package:cross_tide/src/domain/digest_content_block.dart';
import 'package:cross_tide/src/domain/feedback_submission.dart';
import 'package:cross_tide/src/domain/indicator_alert_config.dart';
import 'package:cross_tide/src/domain/market_holiday_calendar.dart';
import 'package:cross_tide/src/domain/onboarding_state.dart';
import 'package:cross_tide/src/domain/portfolio_backtest_result.dart';
import 'package:cross_tide/src/domain/price_trigger_rule.dart';
import 'package:cross_tide/src/domain/report_schedule.dart';
import 'package:cross_tide/src/domain/screener_preset.dart';
import 'package:cross_tide/src/domain/smart_alert_schedule.dart';
import 'package:cross_tide/src/domain/sync_conflict_resolver.dart';
import 'package:cross_tide/src/domain/ticker_correlation_cluster.dart';
import 'package:cross_tide/src/domain/user_annotation.dart';
import 'package:cross_tide/src/domain/watchlist_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── S276 MarketHolidayCalendar ────────────────────────────────────────────

  group('MarketHolidayCalendar', () {
    final holiday = MarketHoliday(
      exchange: TradingExchange.nyse,
      date: DateTime(2026, 1, 1),
      name: "New Year's Day",
    );
    final calendar = MarketHolidayCalendar(holidays: [holiday]);

    test('isHoliday returns true for matching exchange and date', () {
      expect(
        calendar.isHoliday(TradingExchange.nyse, DateTime(2026, 1, 1)),
        isTrue,
      );
    });

    test('isHoliday returns false for different exchange', () {
      expect(
        calendar.isHoliday(TradingExchange.lse, DateTime(2026, 1, 1)),
        isFalse,
      );
    });

    test('isHoliday returns false for different date', () {
      expect(
        calendar.isHoliday(TradingExchange.nyse, DateTime(2026, 1, 2)),
        isFalse,
      );
    });

    test('holidaysFor filters by exchange', () {
      final h2 = MarketHoliday(
        exchange: TradingExchange.lse,
        date: DateTime(2026, 12, 25),
        name: 'Christmas',
      );
      final cal2 = MarketHolidayCalendar(holidays: [holiday, h2]);
      expect(cal2.holidaysFor(TradingExchange.nyse).length, 1);
      expect(cal2.holidaysFor(TradingExchange.lse).length, 1);
    });

    test('holidayCountInRange counts inclusively', () {
      final h2 = MarketHoliday(
        exchange: TradingExchange.nyse,
        date: DateTime(2026, 7, 4),
        name: 'Independence Day',
      );
      final cal2 = MarketHolidayCalendar(holidays: [holiday, h2]);
      expect(
        cal2.holidayCountInRange(
          TradingExchange.nyse,
          DateTime(2026, 1, 1),
          DateTime(2026, 7, 4),
        ),
        2,
      );
    });

    test('MarketHoliday equality', () {
      final h1 = MarketHoliday(
        exchange: TradingExchange.nyse,
        date: DateTime(2026, 1, 1),
        name: "New Year's Day",
      );
      expect(holiday, equals(h1));
    });
  });

  // ── S277 PriceTriggerRule ─────────────────────────────────────────────────

  group('PriceTriggerRule', () {
    final rule = PriceTriggerRule(
      id: 'r1',
      ticker: 'AAPL',
      condition: PriceTriggerCondition.crossesAbove,
      threshold: 200.0,
      createdAt: DateTime(2026),
    );

    test('isActive is true for active status', () {
      expect(rule.isActive, isTrue);
    });

    test('hasExpiry is false when validUntil is null', () {
      expect(rule.hasExpiry, isFalse);
    });

    test('isExpiredAt returns true past validUntil', () {
      final expiring = PriceTriggerRule(
        id: 'r2',
        ticker: 'TSLA',
        condition: PriceTriggerCondition.crossesBelow,
        threshold: 150.0,
        createdAt: DateTime(2026),
        validUntil: DateTime(2026, 2),
      );
      expect(expiring.isExpiredAt(DateTime(2026, 3)), isTrue);
      expect(expiring.isExpiredAt(DateTime(2026, 1)), isFalse);
    });

    test('withStatus transitions correctly', () {
      final triggered = rule.withStatus(PriceTriggerStatus.triggered);
      expect(triggered.status, PriceTriggerStatus.triggered);
      expect(triggered.isActive, isFalse);
    });

    test('asserts positive threshold', () {
      expect(
        () => PriceTriggerRule(
          id: 'bad',
          ticker: 'X',
          condition: PriceTriggerCondition.crossesAbove,
          threshold: 0,
          createdAt: DateTime(2026),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S278 OnboardingState ──────────────────────────────────────────────────

  group('OnboardingState', () {
    test('fresh state has no completed or skipped steps', () {
      const state = OnboardingState.fresh();
      expect(state.completedSteps, isEmpty);
      expect(state.skippedSteps, isEmpty);
      expect(state.isFullyComplete, isFalse);
    });

    test('completeStep adds to completedSteps', () {
      const state = OnboardingState.fresh();
      final updated = state.completeStep(OnboardingStep.addFirstTicker);
      expect(updated.isCompleted(OnboardingStep.addFirstTicker), isTrue);
    });

    test('skipStep adds to skippedSteps', () {
      const state = OnboardingState.fresh();
      final updated = state.skipStep(OnboardingStep.enableNotifications);
      expect(updated.isSkipped(OnboardingStep.enableNotifications), isTrue);
    });

    test('completionPct is 0 for fresh state', () {
      const state = OnboardingState.fresh();
      expect(state.completionPct, 0.0);
    });

    test('isFullyComplete when all steps completed or skipped', () {
      var state = const OnboardingState.fresh();
      for (final OnboardingStep step in OnboardingStep.values) {
        state = state.completeStep(step);
      }
      expect(state.isFullyComplete, isTrue);
    });

    test('nextStep returns first incomplete non-skipped step', () {
      const state = OnboardingState.fresh();
      expect(state.nextStep, OnboardingStep.addFirstTicker);
    });

    test('nextStep is null when fully complete', () {
      var state = const OnboardingState.fresh();
      for (final OnboardingStep step in OnboardingStep.values) {
        state = state.completeStep(step);
      }
      expect(state.nextStep, isNull);
    });
  });

  // ── S279 AppDiagnosticReport ──────────────────────────────────────────────

  group('AppDiagnosticReport', () {
    const okEntry = DiagnosticEntry(
      key: 'db',
      value: '2 MB',
      severity: DiagnosticSeverity.ok,
    );
    const warnEntry = DiagnosticEntry(
      key: 'cache',
      value: 'stale',
      severity: DiagnosticSeverity.warning,
    );
    const critEntry = DiagnosticEntry(
      key: 'network',
      value: 'offline',
      severity: DiagnosticSeverity.critical,
    );

    test('isHealthy is true when no critical entries', () {
      final report = AppDiagnosticReport(
        entries: const [okEntry, warnEntry],
        generatedAt: DateTime(2026),
        appVersion: '1.9.0',
      );
      expect(report.isHealthy, isTrue);
    });

    test('isHealthy is false when critical entry exists', () {
      final report = AppDiagnosticReport(
        entries: const [okEntry, critEntry],
        generatedAt: DateTime(2026),
        appVersion: '1.9.0',
      );
      expect(report.isHealthy, isFalse);
    });

    test('overallSeverity is critical when critical entry present', () {
      final report = AppDiagnosticReport(
        entries: const [critEntry],
        generatedAt: DateTime(2026),
        appVersion: '1.9.0',
      );
      expect(report.overallSeverity, DiagnosticSeverity.critical);
    });

    test('overallSeverity is warning when only warning entries', () {
      final report = AppDiagnosticReport(
        entries: const [warnEntry],
        generatedAt: DateTime(2026),
        appVersion: '1.9.0',
      );
      expect(report.overallSeverity, DiagnosticSeverity.warning);
    });

    test('overallSeverity is ok when only ok entries', () {
      final report = AppDiagnosticReport(
        entries: const [okEntry],
        generatedAt: DateTime(2026),
        appVersion: '1.9.0',
      );
      expect(report.overallSeverity, DiagnosticSeverity.ok);
    });

    test('DiagnosticEntry isHealthy', () {
      expect(okEntry.isHealthy, isTrue);
      expect(warnEntry.isHealthy, isFalse);
    });
  });

  // ── S280 TickerCorrelationCluster ─────────────────────────────────────────

  group('TickerCorrelationCluster', () {
    const cluster1 = CorrelationCluster(
      clusterId: 0,
      tickers: ['AAPL', 'MSFT', 'GOOG'],
      avgIntraCorrelation: 0.82,
      label: 'Tech',
    );
    const cluster2 = CorrelationCluster(
      clusterId: 1,
      tickers: ['XOM', 'CVX'],
      avgIntraCorrelation: 0.91,
    );
    final clusterResult = TickerCorrelationCluster(
      clusters: const [cluster1, cluster2],
      method: ClusteringMethod.kMeans,
      computedAt: DateTime(2026),
      windowDays: 90,
    );

    test('clusterFor returns correct cluster', () {
      expect(clusterResult.clusterFor('AAPL')?.clusterId, 0);
      expect(clusterResult.clusterFor('XOM')?.clusterId, 1);
    });

    test('clusterFor returns null for unknown ticker', () {
      expect(clusterResult.clusterFor('TSLA'), isNull);
    });

    test('peersOf returns other tickers in cluster', () {
      final peers = clusterResult.peersOf('AAPL');
      expect(peers, containsAll(['MSFT', 'GOOG']));
      expect(peers, isNot(contains('AAPL')));
    });

    test('isHighlyCorrelated true when avgIntra >= 0.7', () {
      expect(cluster1.isHighlyCorrelated, isTrue);
    });

    test('CorrelationCluster asserts correlation out of range', () {
      expect(
        () => CorrelationCluster(
          clusterId: 9,
          tickers: const ['X'],
          avgIntraCorrelation: 1.5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('TickerCorrelationCluster asserts windowDays < 2', () {
      expect(
        () => TickerCorrelationCluster(
          clusters: const [],
          method: ClusteringMethod.kMeans,
          computedAt: DateTime(2026),
          windowDays: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S281 SmartAlertSchedule ───────────────────────────────────────────────

  group('SmartAlertSchedule', () {
    const morning = EngagementTimeWindow(
      startHour: 9,
      endHour: 11,
      engagementScore: 0.9,
    );
    const afternoon = EngagementTimeWindow(
      startHour: 14,
      endHour: 16,
      engagementScore: 0.5,
    );
    final schedule = SmartAlertSchedule(
      windows: const [morning, afternoon],
      updatedAt: DateTime(2026),
    );

    test('isWithinPeakWindow true for high-score window', () {
      expect(schedule.isWithinPeakWindow(9), isTrue);
      expect(schedule.isWithinPeakWindow(14), isFalse);
    });

    test('bestWindowForHour returns highest-scored matching window', () {
      expect(schedule.bestWindowForHour(9)?.engagementScore, 0.9);
      expect(schedule.bestWindowForHour(12), isNull);
    });

    test('EngagementTimeWindow containsHour', () {
      expect(morning.containsHour(10), isTrue);
      expect(morning.containsHour(11), isFalse);
    });

    test('asserts invalid engagementScore', () {
      expect(
        () => EngagementTimeWindow(
          startHour: 9,
          endHour: 10,
          engagementScore: 1.5,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts minDeliveryIntervalMinutes < 1', () {
      expect(
        () => SmartAlertSchedule(
          windows: const [],
          updatedAt: DateTime(2026),
          minDeliveryIntervalMinutes: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S282 PortfolioBacktestResult ──────────────────────────────────────────

  group('PortfolioBacktestResult', () {
    final trade = PortfolioBacktestTrade(
      ticker: 'AAPL',
      entryDate: DateTime(2026, 1, 1),
      exitDate: DateTime(2026, 3, 1),
      entryPrice: 150.0,
      exitPrice: 180.0,
      shares: 10,
    );
    final lossTrade = PortfolioBacktestTrade(
      ticker: 'TSLA',
      entryDate: DateTime(2026, 1, 1),
      exitDate: DateTime(2026, 2, 1),
      entryPrice: 300.0,
      exitPrice: 250.0,
      shares: 5,
    );
    final equityCurve = [
      PortfolioEquityPoint(date: DateTime(2026, 1, 1), equity: 10000),
      PortfolioEquityPoint(date: DateTime(2026, 2, 1), equity: 10500),
      PortfolioEquityPoint(date: DateTime(2026, 3, 1), equity: 11200),
    ];
    final result = PortfolioBacktestResult(
      tickers: const ['AAPL', 'TSLA'],
      trades: [trade, lossTrade],
      equityCurve: equityCurve,
      initialCapital: 10000,
      fromDate: DateTime(2026, 1, 1),
      toDate: DateTime(2026, 3, 1),
    );

    test('pnl and returnPct computed correctly', () {
      expect(trade.pnl, closeTo(300, 0.001));
      expect(trade.returnPct, closeTo(0.2, 0.001));
      expect(trade.isWin, isTrue);
      expect(lossTrade.isWin, isFalse);
    });

    test('finalEquity is last equity point', () {
      expect(result.finalEquity, 11200);
    });

    test('totalReturn is correct', () {
      expect(result.totalReturn, closeTo(0.12, 0.001));
    });

    test('winRate is 0.5 for 1 win + 1 loss', () {
      expect(result.winRate, 0.5);
    });

    test('maxDrawdown is 0 for monotone-up curve', () {
      expect(result.maxDrawdown, 0.0);
    });

    test('peakEquity returns highest equity', () {
      expect(result.peakEquity, 11200);
    });

    test('asserts positive initialCapital', () {
      expect(
        () => PortfolioBacktestResult(
          tickers: const [],
          trades: const [],
          equityCurve: const [],
          initialCapital: 0,
          fromDate: DateTime(2026),
          toDate: DateTime(2026, 12),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S283 ScreenerPreset ───────────────────────────────────────────────────

  group('ScreenerPreset', () {
    const cond = ScreenerCondition(
      field: ScreenerConditionField.rsi14,
      op: ScreenerCompareOp.lessThan,
      value: 30,
    );
    const preset = ScreenerPreset(
      id: 'p1',
      name: 'RSI Oversold',
      conditions: [cond],
    );

    test('hasConditions is true', () {
      expect(preset.hasConditions, isTrue);
    });

    test('empty preset hasConditions false', () {
      const empty = ScreenerPreset(id: 'e', name: 'Empty', conditions: []);
      expect(empty.hasConditions, isFalse);
    });

    test('withCondition appends a condition', () {
      const newCond = ScreenerCondition(
        field: ScreenerConditionField.adx14,
        op: ScreenerCompareOp.greaterThan,
        value: 25,
      );
      final updated = preset.withCondition(newCond);
      expect(updated.conditions.length, 2);
    });

    test('ScreenerCondition equality', () {
      const c2 = ScreenerCondition(
        field: ScreenerConditionField.rsi14,
        op: ScreenerCompareOp.lessThan,
        value: 30,
      );
      expect(cond, equals(c2));
    });
  });

  // ── S284 DigestContentBlock ───────────────────────────────────────────────

  group('DigestContentBlock', () {
    const headerBlock = DigestContentBlock(
      blockType: DigestBlockType.header,
      heading: 'Daily Summary',
      sortOrder: 0,
    );
    const alertBlock = DigestContentBlock(
      blockType: DigestBlockType.alertSummary,
      heading: 'AAPL Alert',
      tickerRef: 'AAPL',
      numericValue: 3.5,
      sortOrder: 2,
    );
    const textBlock = DigestContentBlock(
      blockType: DigestBlockType.text,
      heading: 'Market Overview',
      body: 'Markets closed higher.',
      sortOrder: 1,
    );

    test('hasTickerRef correct', () {
      expect(alertBlock.hasTickerRef, isTrue);
      expect(headerBlock.hasTickerRef, isFalse);
    });

    test('hasNumericValue correct', () {
      expect(alertBlock.hasNumericValue, isTrue);
      expect(textBlock.hasNumericValue, isFalse);
    });

    test('DigestTemplate.sorted orders by sortOrder', () {
      const tmpl = DigestTemplate(
        id: 't1',
        name: 'Daily',
        blocks: [alertBlock, textBlock, headerBlock],
      );
      final sorted = tmpl.sorted;
      expect(sorted.first.sortOrder, 0);
      expect(sorted.last.sortOrder, 2);
    });

    test('DigestTemplate isEmpty is false when blocks exist', () {
      const tmpl = DigestTemplate(
        id: 't1',
        name: 'Daily',
        blocks: [headerBlock],
      );
      expect(tmpl.isEmpty, isFalse);
    });
  });

  // ── S285 ReportSchedule ───────────────────────────────────────────────────

  group('ReportSchedule', () {
    final schedule = ReportSchedule(
      id: 'rs1',
      reportTemplateId: 'weekly_summary',
      frequency: ReportFrequency.weekly,
      deliveryChannel: ReportDeliveryChannel.email,
      createdAt: DateTime(2026, 1, 1),
      recipients: const ['user@example.com'],
    );

    test('hasRecipients is true', () {
      expect(schedule.hasRecipients, isTrue);
    });

    test('hasRun is false before first run', () {
      expect(schedule.hasRun, isFalse);
    });

    test('isDueAt true when nextRunAt in past', () {
      final due = schedule.withNextRun(DateTime(2026, 1, 5));
      expect(due.isDueAt(DateTime(2026, 1, 6)), isTrue);
    });

    test('isDueAt false when nextRunAt in future', () {
      final notDue = schedule.withNextRun(DateTime(2026, 2, 1));
      expect(notDue.isDueAt(DateTime(2026, 1, 6)), isFalse);
    });

    test('isDueAt false when disabled', () {
      final disabled = ReportSchedule(
        id: 'rs2',
        reportTemplateId: 'x',
        frequency: ReportFrequency.daily,
        deliveryChannel: ReportDeliveryChannel.inApp,
        createdAt: DateTime(2026),
        isEnabled: false,
        nextRunAt: DateTime(2026, 1, 1),
      );
      expect(disabled.isDueAt(DateTime(2026, 1, 2)), isFalse);
    });
  });

  // ── S286 WatchlistSnapshot ────────────────────────────────────────────────

  group('WatchlistSnapshot', () {
    const snap1 = WatchlistTickerSnapshot(
      ticker: 'AAPL',
      closePrice: 210.0,
      sma200: 200.0,
    );
    const snap2 = WatchlistTickerSnapshot(
      ticker: 'TSLA',
      closePrice: 180.0,
      sma200: 200.0,
    );
    final snapshot = WatchlistSnapshot(
      snapshotId: 'snap1',
      watchlistName: 'My List',
      tickers: const [snap1, snap2],
      capturedAt: DateTime(2026),
    );

    test('isAboveSma200 correct', () {
      expect(snap1.isAboveSma200, isTrue);
      expect(snap2.isAboveSma200, isFalse);
    });

    test('pctFromSma200 correct', () {
      expect(snap1.pctFromSma200, closeTo(0.05, 0.001));
    });

    test('aboveSma200 filters correctly', () {
      expect(snapshot.aboveSma200.length, 1);
      expect(snapshot.aboveSma200.first.ticker, 'AAPL');
    });

    test('pctAboveSma200 is 0.5', () {
      expect(snapshot.pctAboveSma200, 0.5);
    });

    test('tickerSnapshot returns correct entry', () {
      expect(snapshot.tickerSnapshot('TSLA')?.closePrice, 180.0);
    });

    test('tickerSnapshot returns null for unknown', () {
      expect(snapshot.tickerSnapshot('GOOG'), isNull);
    });
  });

  // ── S287 SyncConflictResolver ─────────────────────────────────────────────

  group('SyncConflictResolver', () {
    final conflict = SyncConflict(
      entityType: 'setting',
      entityId: 'alert_threshold',
      localValue: '5',
      remoteValue: '10',
      localUpdatedAt: DateTime(2026, 1, 3),
      remoteUpdatedAt: DateTime(2026, 1, 1),
    );

    test('localIsNewer correct', () {
      expect(conflict.localIsNewer, isTrue);
    });

    test('lastWriteWins picks local when local is newer', () {
      const resolver = SyncConflictResolver(
        defaultPolicy: ConflictResolutionPolicy.lastWriteWins,
      );
      final result = resolver.resolve(conflict, resolvedAt: DateTime(2026, 2));
      expect(result.resolvedValue, '5');
      expect(result.isResolved, isTrue);
    });

    test('remoteWins always picks remote', () {
      const resolver = SyncConflictResolver(
        defaultPolicy: ConflictResolutionPolicy.remoteWins,
      );
      final result = resolver.resolve(conflict, resolvedAt: DateTime(2026, 2));
      expect(result.resolvedValue, '10');
    });

    test('localWins always picks local', () {
      const resolver = SyncConflictResolver(
        defaultPolicy: ConflictResolutionPolicy.localWins,
      );
      final result = resolver.resolve(conflict, resolvedAt: DateTime(2026, 2));
      expect(result.resolvedValue, '5');
    });

    test('requireManual sets outcome to requiresManual', () {
      const resolver = SyncConflictResolver(
        defaultPolicy: ConflictResolutionPolicy.requireManual,
      );
      final result = resolver.resolve(conflict, resolvedAt: DateTime(2026, 2));
      expect(result.outcome, ConflictOutcome.requiresManual);
      expect(result.isResolved, isFalse);
    });

    test('ConflictResolution equality', () {
      const resolver = SyncConflictResolver(
        defaultPolicy: ConflictResolutionPolicy.localWins,
      );
      final r1 = resolver.resolve(conflict, resolvedAt: DateTime(2026, 2));
      final r2 = resolver.resolve(conflict, resolvedAt: DateTime(2026, 2));
      expect(r1, equals(r2));
    });
  });

  // ── S288 IndicatorAlertConfig ─────────────────────────────────────────────

  group('IndicatorAlertConfig', () {
    const threshold = IndicatorAlertThreshold(
      lowerBound: 30.0,
      upperBound: 70.0,
    );
    const config = IndicatorAlertConfig(
      indicatorId: 'rsi14',
      mode: IndicatorAlertMode.onThreshold,
      threshold: threshold,
    );

    test('threshold.contains correct', () {
      expect(threshold.contains(50.0), isTrue);
      expect(threshold.contains(29.9), isFalse);
      expect(threshold.contains(70.1), isFalse);
    });

    test('shouldAlert is true when value outside threshold', () {
      expect(config.shouldAlert(25.0), isTrue);
      expect(config.shouldAlert(75.0), isTrue);
    });

    test('shouldAlert is false when value inside threshold', () {
      expect(config.shouldAlert(50.0), isFalse);
    });

    test('shouldAlert is false when disabled', () {
      const disabled = IndicatorAlertConfig(
        indicatorId: 'rsi14',
        mode: IndicatorAlertMode.onThreshold,
        threshold: threshold,
        isEnabled: false,
      );
      expect(disabled.shouldAlert(10.0), isFalse);
    });

    test('asserts invalid threshold order', () {
      expect(
        () => IndicatorAlertThreshold(lowerBound: 70, upperBound: 30),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts negative cooldownMinutes', () {
      expect(
        () => IndicatorAlertConfig(
          indicatorId: 'x',
          mode: IndicatorAlertMode.onCross,
          threshold: threshold,
          cooldownMinutes: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S289 UserAnnotation ───────────────────────────────────────────────────

  group('UserAnnotation', () {
    final annotation = UserAnnotation(
      id: 'a1',
      target: AnnotationTarget.candle,
      targetId: 'AAPL-2026-01-15',
      text: 'Golden cross spotted!',
      createdAt: DateTime(2026, 1, 15),
      tags: const ['signal', 'golden-cross'],
    );

    test('hasTags is true', () {
      expect(annotation.hasTags, isTrue);
    });

    test('hasBeenEdited is false initially', () {
      expect(annotation.hasBeenEdited, isFalse);
    });

    test('withText creates edited copy', () {
      final edited = annotation.withText('Edited note', DateTime(2026, 2));
      expect(edited.text, 'Edited note');
      expect(edited.hasBeenEdited, isTrue);
      expect(edited.id, annotation.id);
    });

    test('hide sets isVisible to false', () {
      final hidden = annotation.hide();
      expect(hidden.isVisible, isFalse);
    });

    test('asserts empty text', () {
      expect(
        () => UserAnnotation(
          id: 'a2',
          target: AnnotationTarget.ticker,
          targetId: 'X',
          text: '',
          createdAt: DateTime(2026),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── S290 FeedbackSubmission ───────────────────────────────────────────────

  group('FeedbackSubmission', () {
    final feedback = FeedbackSubmission(
      id: 'fb1',
      category: FeedbackCategory.bugReport,
      message: 'The app crashes on startup when no network is available.',
      appVersion: '1.9.0',
      submittedAt: DateTime(2026, 4),
      contactEmail: 'user@example.com',
    );

    test('isPending is true initially', () {
      expect(feedback.isPending, isTrue);
    });

    test('isResolved is false initially', () {
      expect(feedback.isResolved, isFalse);
    });

    test('hasContactInfo is true when email provided', () {
      expect(feedback.hasContactInfo, isTrue);
    });

    test('withStatus transitions correctly', () {
      final resolved = feedback.withStatus(FeedbackStatus.resolved);
      expect(resolved.isResolved, isTrue);
      expect(resolved.id, feedback.id);
    });

    test('asserts message too short', () {
      expect(
        () => FeedbackSubmission(
          id: 'fb2',
          category: FeedbackCategory.other,
          message: 'Short',
          appVersion: '1.9.0',
          submittedAt: DateTime(2026),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('FeedbackSubmission equality', () {
      final f2 = FeedbackSubmission(
        id: 'fb1',
        category: FeedbackCategory.bugReport,
        message: 'The app crashes on startup when no network is available.',
        appVersion: '1.9.0',
        submittedAt: DateTime(2026, 4),
        contactEmail: 'user@example.com',
      );
      expect(feedback, equals(f2));
    });
  });
}
