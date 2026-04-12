import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // S501 — OrderRoutingPreference
  group('OrderRoutingPreference', () {
    const pref = OrderRoutingPreference(
      preferenceId: 'p1',
      userId: 'u1',
      strategy: OrderRoutingStrategy.algorithmicTwap,
      preferredVenueId: 'NYSE',
      maxSlippageBps: 4,
    );

    test('hasVenuePreference true when venueId non-empty', () {
      expect(pref.hasVenuePreference, isTrue);
    });

    test('isAlgorithmic true for TWAP', () {
      expect(pref.isAlgorithmic, isTrue);
    });

    test('isTightSlippage for <= 5 bps', () {
      expect(pref.isTightSlippage, isTrue);
    });

    test('isAlgorithmic false for smart routing', () {
      const p = OrderRoutingPreference(
        preferenceId: 'p2',
        userId: 'u2',
        strategy: OrderRoutingStrategy.smart,
      );
      expect(p.isAlgorithmic, isFalse);
      expect(p.hasVenuePreference, isFalse);
    });

    test('equality', () {
      const p2 = OrderRoutingPreference(
        preferenceId: 'p1',
        userId: 'u1',
        strategy: OrderRoutingStrategy.algorithmicTwap,
        preferredVenueId: 'NYSE',
        maxSlippageBps: 4,
      );
      expect(pref, equals(p2));
    });
  });

  // S502 — SlippageEstimate
  group('SlippageEstimate', () {
    const est = SlippageEstimate(
      orderId: 'o1',
      ticker: 'AAPL',
      orderSizeShares: 1000,
      estimatedSlippageBps: 25,
      marketImpactBps: 20,
      spreadCostBps: 3,
    );

    test('totalCostBps sums slippage and spread', () {
      expect(est.totalCostBps, equals(28));
    });

    test('isHighSlippage true when >= 20 bps', () {
      expect(est.isHighSlippage, isTrue);
    });

    test('isDominatedByImpact when impact > spread', () {
      expect(est.isDominatedByImpact, isTrue);
    });

    test('low slippage flags correctly', () {
      const low = SlippageEstimate(
        orderId: 'o2',
        ticker: 'MSFT',
        orderSizeShares: 100,
        estimatedSlippageBps: 5,
        marketImpactBps: 2,
        spreadCostBps: 4,
      );
      expect(low.isHighSlippage, isFalse);
      expect(low.isDominatedByImpact, isFalse);
    });
  });

  // S503 — ExecutionVenueConfig
  group('ExecutionVenueConfig', () {
    const venue = ExecutionVenueConfig(
      venueId: 'v1',
      venueName: 'IEX',
      venueType: ExecutionVenueType.exchange,
      takerFeeBps: 3,
      makerFeeBps: -2,
    );

    test('hasMakerRebate true for negative maker fee', () {
      expect(venue.hasMakerRebate, isTrue);
    });

    test('isDarkPool false for exchange', () {
      expect(venue.isDarkPool, isFalse);
    });

    test('isLowCost true for taker <= 5 bps', () {
      expect(venue.isLowCost, isTrue);
    });

    test('dark pool venue', () {
      const dp = ExecutionVenueConfig(
        venueId: 'dp1',
        venueName: 'Liquidnet',
        venueType: ExecutionVenueType.darkPool,
        takerFeeBps: 10,
        makerFeeBps: 10,
      );
      expect(dp.isDarkPool, isTrue);
      expect(dp.hasMakerRebate, isFalse);
      expect(dp.isLowCost, isFalse);
    });
  });

  // S504 — DarkPoolIndicator
  group('DarkPoolIndicator', () {
    const ind = DarkPoolIndicator(
      ticker: 'AAPL',
      darkPoolVolumePercent: 45,
      blockTradeCount: 3,
      estimatedNotionalUsd: 5000000,
      isBullishFlow: true,
    );

    test('isHighDarkActivity for >= 40%', () {
      expect(ind.isHighDarkActivity, isTrue);
    });

    test('hasBlockTrades when count > 0', () {
      expect(ind.hasBlockTrades, isTrue);
    });

    test(r'isLargeNotional for >= $1M', () {
      expect(ind.isLargeNotional, isTrue);
    });

    test('low activity flags', () {
      const low = DarkPoolIndicator(
        ticker: 'XYZ',
        darkPoolVolumePercent: 10,
        blockTradeCount: 0,
        estimatedNotionalUsd: 50000,
        isBullishFlow: false,
      );
      expect(low.isHighDarkActivity, isFalse);
      expect(low.hasBlockTrades, isFalse);
      expect(low.isLargeNotional, isFalse);
    });
  });

  // S505 — TickSizeRule
  group('TickSizeRule', () {
    const rule = TickSizeRule(
      ruleId: 'r1',
      exchange: 'NYSE',
      minPrice: 1.0,
      maxPrice: double.infinity,
      tickSizeUsd: 0.01,
    );

    test('appliesTo price in range', () {
      expect(rule.appliesTo(50.0), isTrue);
    });

    test('does not apply to price below min', () {
      expect(rule.appliesTo(0.5), isFalse);
    });

    test('appliesToPennies false for 1-cent tick', () {
      expect(rule.appliesToPennies, isFalse);
    });

    test('sub-penny rule', () {
      const subPenny = TickSizeRule(
        ruleId: 'r2',
        exchange: 'OTC',
        minPrice: 0.0,
        maxPrice: 1.0,
        tickSizeUsd: 0.001,
      );
      expect(subPenny.isSubPenny, isTrue);
      expect(subPenny.appliesTo(0.5), isTrue);
      expect(subPenny.appliesTo(1.0), isFalse);
    });
  });

  // S506 — OrderBookImbalance
  group('OrderBookImbalance', () {
    const imb = OrderBookImbalance(
      ticker: 'AAPL',
      bidVolume: 8000,
      askVolume: 2000,
      levels: 5,
      isBuyPressure: true,
    );

    test('imbalanceRatio reflects bid dominance', () {
      expect(imb.imbalanceRatio, closeTo(0.8, 0.001));
    });

    test('isStrongImbalance true for >= 0.65', () {
      expect(imb.isStrongImbalance, isTrue);
    });

    test('zero volume returns 0.5 ratio', () {
      const zero = OrderBookImbalance(
        ticker: 'X',
        bidVolume: 0,
        askVolume: 0,
        levels: 1,
        isBuyPressure: false,
      );
      expect(zero.imbalanceRatio, equals(0.5));
    });

    test('balanced book is not strong imbalance', () {
      const bal = OrderBookImbalance(
        ticker: 'Y',
        bidVolume: 5000,
        askVolume: 5000,
        levels: 5,
        isBuyPressure: false,
      );
      expect(bal.isStrongImbalance, isFalse);
    });
  });

  // S507 — LatencyArbitrageFlag
  group('LatencyArbitrageFlag', () {
    const flag = LatencyArbitrageFlag(
      ticker: 'SPY',
      flagId: 'f1',
      detectedAtMs: 1000000,
      priceDiscrepancyBps: 8,
      affectedVenueCount: 2,
    );

    test('isSignificant for >= 5 bps', () {
      expect(flag.isSignificant, isTrue);
    });

    test('isMultiVenue for >= 2 venues', () {
      expect(flag.isMultiVenue, isTrue);
    });

    test('default isActive is true', () {
      expect(flag.isActive, isTrue);
    });

    test('small discrepancy not significant', () {
      const small = LatencyArbitrageFlag(
        ticker: 'X',
        flagId: 'f2',
        detectedAtMs: 2000000,
        priceDiscrepancyBps: 2,
        affectedVenueCount: 1,
      );
      expect(small.isSignificant, isFalse);
      expect(small.isMultiVenue, isFalse);
    });
  });

  // S508 — FillQualityReport
  group('FillQualityReport', () {
    const rep = FillQualityReport(
      orderId: 'o1',
      ticker: 'AAPL',
      requestedShares: 100,
      filledShares: 100,
      averageFillPrice: 150.05,
      referenceMidPrice: 150.00,
      slippageBps: 3,
    );

    test('fillRatePercent 100 for full fill', () {
      expect(rep.fillRatePercent, equals(100));
    });

    test('isFullFill true when filled == requested', () {
      expect(rep.isFullFill, isTrue);
    });

    test('isGoodFill for slippage <= 5 bps', () {
      expect(rep.isGoodFill, isTrue);
    });

    test('high slippage report', () {
      const bad = FillQualityReport(
        orderId: 'o2',
        ticker: 'TSLA',
        requestedShares: 200,
        filledShares: 150,
        averageFillPrice: 700.0,
        referenceMidPrice: 695.0,
        slippageBps: 25,
      );
      expect(bad.isHighSlippage, isTrue);
      expect(bad.isFullFill, isFalse);
      expect(bad.fillRatePercent, closeTo(75, 0.01));
    });
  });

  // S509 — CircuitBreakerStatus
  group('CircuitBreakerStatus', () {
    const status = CircuitBreakerStatus(
      marketId: 'NYSE',
      isTriggered: true,
      level: CircuitBreakerLevel.level3,
      haltDurationSeconds: 1200,
      resumeAtMs: 1700000000000,
    );

    test('isTriggered true', () {
      expect(status.isTriggered, isTrue);
    });

    test('isLevel3 true', () {
      expect(status.isLevel3, isTrue);
    });

    test('isLongHalt for >= 900 seconds', () {
      expect(status.isLongHalt, isTrue);
    });

    test('hasKnownResumeTime when resumeAtMs set', () {
      expect(status.hasKnownResumeTime, isTrue);
    });

    test('not triggered status', () {
      const off = CircuitBreakerStatus(
        marketId: 'NASDAQ',
        isTriggered: false,
        haltDurationSeconds: 0,
      );
      expect(off.isLevel3, isFalse);
      expect(off.hasKnownResumeTime, isFalse);
    });
  });

  // S510 — CrossListingEntry
  group('CrossListingEntry', () {
    const entry = CrossListingEntry(
      primaryTicker: 'BABA',
      foreignTicker: 'BABA.HK',
      primaryExchange: 'NYSE',
      foreignExchange: 'HKEX',
      foreignCurrency: 'HKD',
      conversionRatio: 8.0,
    );

    test('isOneToOne false for 8:1 ratio', () {
      expect(entry.isOneToOne, isFalse);
    });

    test('isMultiShareAds true for ratio > 1', () {
      expect(entry.isMultiShareAds, isTrue);
    });

    test('one-to-one listing', () {
      const one = CrossListingEntry(
        primaryTicker: 'RY',
        foreignTicker: 'RY.TO',
        primaryExchange: 'NYSE',
        foreignExchange: 'TSX',
        foreignCurrency: 'CAD',
        conversionRatio: 1.0,
      );
      expect(one.isOneToOne, isTrue);
    });
  });

  // S511 — CustodyAccountSummary
  group('CustodyAccountSummary', () {
    const summary = CustodyAccountSummary(
      accountId: 'a1',
      custodianName: 'Fidelity',
      totalValueUsd: 100000,
      cashBalanceUsd: 25000,
      securitiesValueUsd: 75000,
      positionCount: 10,
      marginUsedUsd: 5000,
    );

    test('cashPercent computes correctly', () {
      expect(summary.cashPercent, equals(25));
    });

    test('isMarginAccount when margin > 0', () {
      expect(summary.isMarginAccount, isTrue);
    });

    test('isLargeCash when cash >= 20%', () {
      expect(summary.isLargeCash, isTrue);
    });

    test('zero total returns 0 cashPercent', () {
      const zero = CustodyAccountSummary(
        accountId: 'a2',
        custodianName: 'X',
        totalValueUsd: 0,
        cashBalanceUsd: 0,
        securitiesValueUsd: 0,
        positionCount: 0,
      );
      expect(zero.cashPercent, equals(0));
      expect(zero.isMarginAccount, isFalse);
    });
  });

  // S512 — SettlementCycleConfig
  group('SettlementCycleConfig', () {
    const cfg = SettlementCycleConfig(
      configId: 'c1',
      marketId: 'NYSE',
      settlementDays: 1,
      currency: 'USD',
    );

    test('isNextDay true for 1 day', () {
      expect(cfg.isNextDay, isTrue);
    });

    test('isStandardUS true for T+1', () {
      expect(cfg.isStandardUS, isTrue);
    });

    test('isSameDay false for T+1', () {
      expect(cfg.isSameDay, isFalse);
    });

    test('same-day settlement', () {
      const sd = SettlementCycleConfig(
        configId: 'c2',
        marketId: 'FX',
        settlementDays: 0,
        currency: 'EUR',
      );
      expect(sd.isSameDay, isTrue);
    });
  });

  // S513 — ClearingHouseMargin
  group('ClearingHouseMargin', () {
    const margin = ClearingHouseMargin(
      instrumentId: 'ES',
      clearingHouseName: 'CME',
      initialMarginPercent: 25,
      maintenanceMarginPercent: 20,
      stressMarginPercent: 40,
      concentrationSurchargePercent: 5,
    );

    test('hasConcentrationSurcharge true when surcharge > 0', () {
      expect(margin.hasConcentrationSurcharge, isTrue);
    });

    test('isHighMargin for >= 20%', () {
      expect(margin.isHighMargin, isTrue);
    });

    test('marginCallThreshold', () {
      expect(margin.marginCallThreshold, equals(15));
    });

    test('no surcharge case', () {
      const low = ClearingHouseMargin(
        instrumentId: 'SPY',
        clearingHouseName: 'OCC',
        initialMarginPercent: 10,
        maintenanceMarginPercent: 7,
        stressMarginPercent: 15,
      );
      expect(low.hasConcentrationSurcharge, isFalse);
      expect(low.isHighMargin, isFalse);
    });
  });

  // S514 — TradeConfirmationRecord
  group('TradeConfirmationRecord', () {
    const rec = TradeConfirmationRecord(
      confirmationId: 'conf1',
      orderId: 'ord1',
      ticker: 'AAPL',
      executedShares: 100,
      executedPriceUsd: 150.0,
      feesUsd: 1.0,
      settlementDateMs: 1700000000000,
    );

    test('grossValueUsd computes shares * price', () {
      expect(rec.grossValueUsd, equals(15000));
    });

    test('netValueUsd adds fees', () {
      expect(rec.netValueUsd, equals(15001));
    });

    test('hasSignificantFees false for tiny fees', () {
      expect(rec.hasSignificantFees, isFalse);
    });

    test('isCancelled defaults to false', () {
      expect(rec.isCancelled, isFalse);
    });
  });

  // S515 — MarketMicrostructureSnapshot
  group('MarketMicrostructureSnapshot', () {
    const snap = MarketMicrostructureSnapshot(
      ticker: 'AAPL',
      bidPrice: 149.99,
      askPrice: 150.01,
      lastTradePrice: 150.00,
      bidSizeShares: 200,
      askSizeShares: 300,
      tradedVolumeShares: 1000000,
      capturedAtMs: 1700000000000,
    );

    test('midPrice is average of bid and ask', () {
      expect(snap.midPrice, closeTo(150.00, 0.001));
    });

    test('spreadUsd equals ask minus bid', () {
      expect(snap.spreadUsd, closeTo(0.02, 0.001));
    });

    test('isTightSpread for <= 5 bps', () {
      // 0.02 / 150.00 * 10000 ≈ 1.33 bps
      expect(snap.isTightSpread, isTrue);
    });

    test('isLargeSpread false for tight spread', () {
      expect(snap.isLargeSpread, isFalse);
    });

    test('wide spread detection', () {
      const wide = MarketMicrostructureSnapshot(
        ticker: 'PENNY',
        bidPrice: 0.50,
        askPrice: 0.75,
        lastTradePrice: 0.60,
        bidSizeShares: 100,
        askSizeShares: 100,
        tradedVolumeShares: 5000,
        capturedAtMs: 1000000,
      );
      expect(wide.isLargeSpread, isTrue);
    });
  });
}
