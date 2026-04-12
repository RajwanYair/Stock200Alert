import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // S531 — ReturnAttributionResult
  group('ReturnAttributionResult', () {
    const r = ReturnAttributionResult(
      portfolioId: 'p1',
      periodLabel: '2025-Q1',
      allocationEffectPercent: 0.8,
      selectionEffectPercent: 1.5,
      interactionEffectPercent: 0.2,
      totalActiveReturnPercent: 2.5,
    );

    test('isSelectionDriven when selection > allocation', () {
      expect(r.isSelectionDriven, isTrue);
    });
    test('isOutperforming for positive total active return', () {
      expect(r.isOutperforming, isTrue);
    });
    test('isSignificantAlpha for abs >= 1%', () {
      expect(r.isSignificantAlpha, isTrue);
    });
    test('underperforming attribution', () {
      const under = ReturnAttributionResult(
        portfolioId: 'p2',
        periodLabel: 'Q2',
        allocationEffectPercent: -0.5,
        selectionEffectPercent: -0.3,
        interactionEffectPercent: 0.0,
        totalActiveReturnPercent: -0.8,
      );
      expect(under.isOutperforming, isFalse);
      expect(under.isSignificantAlpha, isFalse);
    });
  });

  // S532 — FactorLoadingSnapshot
  group('FactorLoadingSnapshot', () {
    const snap = FactorLoadingSnapshot(
      ticker: 'TSLA',
      modelName: 'Fama-French 5',
      marketBeta: 1.6,
      sizeBeta: -0.5,
      valueBeta: -0.2,
      momentumBeta: 0.4,
      qualityBeta: 0.1,
      specificRiskPercent: 55,
    );

    test('isHighMarketBeta for >= 1.3', () {
      expect(snap.isHighMarketBeta, isTrue);
    });
    test('isSmallCapTilted for SMB <= -0.3', () {
      expect(snap.isSmallCapTilted, isTrue);
    });
    test('isHighSpecificRisk for >= 40%', () {
      expect(snap.isHighSpecificRisk, isTrue);
    });
    test('low beta snapshot', () {
      const low = FactorLoadingSnapshot(
        ticker: 'JNJ',
        modelName: 'Barra',
        marketBeta: 0.6,
        sizeBeta: 0.1,
        valueBeta: 0.3,
        momentumBeta: -0.1,
        qualityBeta: 0.8,
        specificRiskPercent: 20,
      );
      expect(low.isHighMarketBeta, isFalse);
      expect(low.isSmallCapTilted, isFalse);
    });
  });

  // S533 — YieldCurveSnapshot
  group('YieldCurveSnapshot', () {
    const normal = YieldCurveSnapshot(
      currency: 'USD',
      rate1m: 4.5,
      rate3m: 4.6,
      rate6m: 4.7,
      rate1y: 4.8,
      rate2y: 4.5,
      rate5y: 4.2,
      rate10y: 4.6,
      rate30y: 4.9,
      capturedAtMs: 1700000000000,
    );

    test('twosToTensSpreadBps positive for normal curve', () {
      expect(normal.twosToTensSpreadBps, closeTo(10, 0.5));
    });
    test('isInverted false when 10y > 2y', () {
      expect(normal.isInverted, isFalse);
    });
    test('inverted curve detection', () {
      const inv = YieldCurveSnapshot(
        currency: 'USD',
        rate1m: 5.5,
        rate3m: 5.4,
        rate6m: 5.3,
        rate1y: 5.1,
        rate2y: 5.0,
        rate5y: 4.5,
        rate10y: 4.3,
        rate30y: 4.2,
        capturedAtMs: 0,
      );
      expect(inv.isInverted, isTrue);
    });
    test('isFlat when spread within 20 bps', () {
      expect(normal.isFlat, isTrue);
    });
  });

  // S534 — CreditSpreadSnapshot
  group('CreditSpreadSnapshot', () {
    const snapshot = CreditSpreadSnapshot(
      currency: 'USD',
      igOasSpreadBps: 120,
      hyOasSpreadBps: 700,
      emSpreadBps: 350,
      capturedAtMs: 1700000000000,
    );

    test('isWideningCredit for HY >= 600 bps', () {
      expect(snapshot.isWideningCredit, isTrue);
    });
    test('isNarrowingCredit false for HY = 700', () {
      expect(snapshot.isNarrowingCredit, isFalse);
    });
    test('igHyRatioSpread computes difference', () {
      expect(snapshot.igHyRatioSpread, equals(580));
    });
    test('tight spreads', () {
      const tight = CreditSpreadSnapshot(
        currency: 'EUR',
        igOasSpreadBps: 80,
        hyOasSpreadBps: 250,
        emSpreadBps: 200,
        capturedAtMs: 0,
      );
      expect(tight.isNarrowingCredit, isTrue);
      expect(tight.isWideningCredit, isFalse);
    });
  });

  // S535 — MacroRegimeIndicator
  group('MacroRegimeIndicator', () {
    const ind = MacroRegimeIndicator(
      regionCode: 'US',
      phase: MacroRegimePhase.goldilocks,
      growthScore: 60,
      inflationScore: -20,
      confidencePercent: 80,
      assessedAtMs: 1700000000000,
    );

    test('isGoldilocks true for goldilocks phase', () {
      expect(ind.isGoldilocks, isTrue);
    });
    test('isStagflation false', () => expect(ind.isStagflation, isFalse));
    test('isHighConfidence for >= 70%', () {
      expect(ind.isHighConfidence, isTrue);
    });
    test('stagflation regime', () {
      const stag = MacroRegimeIndicator(
        regionCode: 'EU',
        phase: MacroRegimePhase.stagflation,
        growthScore: -30,
        inflationScore: 50,
        confidencePercent: 60,
        assessedAtMs: 0,
      );
      expect(stag.isStagflation, isTrue);
      expect(stag.isGoldilocks, isFalse);
      expect(stag.isHighConfidence, isFalse);
    });
  });

  // S536 — CarryTradeSignal
  group('CarryTradeSignal', () {
    const sig = CarryTradeSignal(
      signalId: 's1',
      longCurrency: 'AUD',
      shortCurrency: 'JPY',
      interestRateDifferentialBps: 400,
      expectedAnnualisedCarryPercent: 6.5,
      isBuy: true,
    );

    test('isHighCarry for >= 5%', () => expect(sig.isHighCarry, isTrue));
    test('isWideDifferential for >= 200 bps', () {
      expect(sig.isWideDifferential, isTrue);
    });
    test('isBuy true', () => expect(sig.isBuy, isTrue));
    test('low carry signal', () {
      const low = CarryTradeSignal(
        signalId: 's2',
        longCurrency: 'GBP',
        shortCurrency: 'CHF',
        interestRateDifferentialBps: 100,
        expectedAnnualisedCarryPercent: 2.0,
        isBuy: false,
      );
      expect(low.isHighCarry, isFalse);
      expect(low.isWideDifferential, isFalse);
    });
  });

  // S537 — MomentumFactorSignal
  group('MomentumFactorSignal', () {
    const sig = MomentumFactorSignal(
      ticker: 'NVDA',
      return12m1mPercent: 35,
      universePercentileRank: 95,
      isBuy: true,
    );

    test('isTopDecile for rank >= 90', () {
      expect(sig.isTopDecile, isTrue);
    });
    test('isStrongMomentum for >= 20%', () {
      expect(sig.isStrongMomentum, isTrue);
    });
    test('isBottomDecile false', () => expect(sig.isBottomDecile, isFalse));
    test('bottom decile signal', () {
      const bottom = MomentumFactorSignal(
        ticker: 'X',
        return12m1mPercent: -15,
        universePercentileRank: 5,
        isBuy: false,
      );
      expect(bottom.isBottomDecile, isTrue);
      expect(bottom.isStrongMomentum, isFalse);
    });
  });

  // S538 — ValueFactorSignal
  group('ValueFactorSignal', () {
    const sig = ValueFactorSignal(
      ticker: 'BRK.B',
      bookToMarketRatio: 0.8,
      earningsYieldPercent: 8,
      universePercentileRank: 85,
      isBuy: true,
    );

    test('isCheap for rank >= 80', () => expect(sig.isCheap, isTrue));
    test('isHighEarningsYield for >= 6%', () {
      expect(sig.isHighEarningsYield, isTrue);
    });
    test('isExpensive false for cheap stock', () {
      expect(sig.isExpensive, isFalse);
    });
    test('expensive growth stock', () {
      const exp = ValueFactorSignal(
        ticker: 'AMZN',
        bookToMarketRatio: 0.1,
        earningsYieldPercent: 1.5,
        universePercentileRank: 10,
        isBuy: false,
      );
      expect(exp.isExpensive, isTrue);
      expect(exp.isCheap, isFalse);
    });
  });

  // S539 — QualityFactorSignal
  group('QualityFactorSignal', () {
    const sig = QualityFactorSignal(
      ticker: 'MSFT',
      returnOnEquityPercent: 45,
      debtToEquityRatio: 0.3,
      grossProfitMarginPercent: 68,
      universePercentileRank: 90,
      isBuy: true,
    );

    test('isHighQuality for rank >= 80', () {
      expect(sig.isHighQuality, isTrue);
    });
    test('isLowDebt for D/E <= 0.5', () => expect(sig.isLowDebt, isTrue));
    test('isHighRoe for ROE >= 15%', () => expect(sig.isHighRoe, isTrue));
    test('low quality detection', () {
      const low = QualityFactorSignal(
        ticker: 'X',
        returnOnEquityPercent: 5,
        debtToEquityRatio: 2.0,
        grossProfitMarginPercent: 10,
        universePercentileRank: 15,
        isBuy: false,
      );
      expect(low.isHighQuality, isFalse);
      expect(low.isLowDebt, isFalse);
      expect(low.isHighRoe, isFalse);
    });
  });

  // S540 — SizeFactorSignal
  group('SizeFactorSignal', () {
    const sig = SizeFactorSignal(
      ticker: 'XYZ',
      marketCapUsd: 150000000,
      smbExposure: 0.6,
      universePercentileRank: 90,
      isBuy: true,
    );

    test('isMicroCap for < 300M', () => expect(sig.isMicroCap, isTrue));
    test('isSmallCap false for micro', () => expect(sig.isSmallCap, isFalse));
    test('isPositiveSmbTilt for SMB >= 0.3', () {
      expect(sig.isPositiveSmbTilt, isTrue);
    });
    test('small cap range', () {
      const small = SizeFactorSignal(
        ticker: 'ABC',
        marketCapUsd: 1000000000,
        smbExposure: 0.2,
        universePercentileRank: 70,
        isBuy: true,
      );
      expect(small.isSmallCap, isTrue);
      expect(small.isMicroCap, isFalse);
      expect(small.isPositiveSmbTilt, isFalse);
    });
  });

  // S541 — VolatilityFactorSignal
  group('VolatilityFactorSignal', () {
    const sig = VolatilityFactorSignal(
      ticker: 'PG',
      annualisedVolatilityPercent: 12,
      betaToMarket: 0.5,
      universePercentileRank: 85,
      isBuy: true,
    );

    test('isLowVolatility for rank >= 70', () {
      expect(sig.isLowVolatility, isTrue);
    });
    test('isDefensive for beta <= 0.7', () => expect(sig.isDefensive, isTrue));
    test('isHighVolatility false for 12%', () {
      expect(sig.isHighVolatility, isFalse);
    });
    test('high volatile stock', () {
      const high = VolatilityFactorSignal(
        ticker: 'MEME',
        annualisedVolatilityPercent: 80,
        betaToMarket: 2.5,
        universePercentileRank: 5,
        isBuy: false,
      );
      expect(high.isHighVolatility, isTrue);
      expect(high.isDefensive, isFalse);
      expect(high.isLowVolatility, isFalse);
    });
  });

  // S542 — DividendGrowthEstimate
  group('DividendGrowthEstimate', () {
    const est = DividendGrowthEstimate(
      ticker: 'JNJ',
      currentAnnualDividendUsd: 4.84,
      estimatedGrowthRate3yPercent: 6,
      estimatedGrowthRate5yPercent: 9,
      dividendPayoutRatioPercent: 45,
      currentYieldPercent: 3.0,
    );

    test('isStrongGrowth for 5y rate >= 8%', () {
      expect(est.isStrongGrowth, isTrue);
    });
    test('isSustainablePayout for ratio <= 70%', () {
      expect(est.isSustainablePayout, isTrue);
    });
    test('isHighYield false for 3%', () => expect(est.isHighYield, isFalse));
    test('high yield unsustainable payout', () {
      const hy = DividendGrowthEstimate(
        ticker: 'X',
        currentAnnualDividendUsd: 5.0,
        estimatedGrowthRate3yPercent: 1,
        estimatedGrowthRate5yPercent: 2,
        dividendPayoutRatioPercent: 90,
        currentYieldPercent: 6.0,
      );
      expect(hy.isHighYield, isTrue);
      expect(hy.isSustainablePayout, isFalse);
    });
  });

  // S543 — FreeCashFlowYield
  group('FreeCashFlowYield', () {
    const fcf = FreeCashFlowYield(
      ticker: 'AAPL',
      freeCashFlowUsd: 100000000000,
      marketCapUsd: 2000000000000,
      enterpriseValueUsd: 2050000000000,
      fcfYieldPercent: 5.0,
      evFcfMultiple: 20.5,
    );

    test('isHighYield for >= 5%', () => expect(fcf.isHighYield, isTrue));
    test('isCheapOnFcf false for multiple > 15', () {
      expect(fcf.isCheapOnFcf, isFalse);
    });
    test('isNegativeFcf false', () => expect(fcf.isNegativeFcf, isFalse));
    test('cheap FCF valuation', () {
      const cheap = FreeCashFlowYield(
        ticker: 'X',
        freeCashFlowUsd: 5000000000,
        marketCapUsd: 50000000000,
        enterpriseValueUsd: 55000000000,
        fcfYieldPercent: 10,
        evFcfMultiple: 11,
      );
      expect(cheap.isCheapOnFcf, isTrue);
      expect(cheap.isNegativeFcf, isFalse);
    });
  });

  // S544 — EnterpriseValueEstimate
  group('EnterpriseValueEstimate', () {
    const ev = EnterpriseValueEstimate(
      ticker: 'AAPL',
      marketCapUsd: 3000000000000,
      totalDebtUsd: 100000000000,
      cashUsd: 60000000000,
      ebitdaUsd: 130000000000,
      evToEbitdaMultiple: 23.4,
    );

    test('enterpriseValueUsd computes correctly', () {
      expect(ev.enterpriseValueUsd, equals(3040000000000));
    });
    test('isCheap false for multiple > 12', () {
      expect(ev.isCheap, isFalse);
    });
    test('isExpensive true for multiple >= 25', () {
      expect(ev.isExpensive, isFalse);
    });
    test('cheap EV', () {
      const cheap = EnterpriseValueEstimate(
        ticker: 'Y',
        marketCapUsd: 1000000000,
        totalDebtUsd: 200000000,
        cashUsd: 100000000,
        ebitdaUsd: 100000000,
        evToEbitdaMultiple: 11,
      );
      expect(cheap.isCheap, isTrue);
      expect(cheap.isExpensive, isFalse);
    });
  });

  // S545 — IntrinsicValueEstimate
  group('IntrinsicValueEstimate', () {
    const iv = IntrinsicValueEstimate(
      ticker: 'AAPL',
      currentPriceUsd: 150,
      intrinsicValueUsd: 200,
      discountRatePercent: 9,
      terminalGrowthRatePercent: 3,
      projectionYears: 10,
    );

    test('marginOfSafetyPercent is 33% approximately', () {
      expect(iv.marginOfSafetyPercent, closeTo(33.33, 0.1));
    });
    test('isUndervalued for margin >= 20%', () {
      expect(iv.isUndervalued, isTrue);
    });
    test('isOvervalued false', () => expect(iv.isOvervalued, isFalse));
    test('overvalued stock', () {
      const over = IntrinsicValueEstimate(
        ticker: 'X',
        currentPriceUsd: 200,
        intrinsicValueUsd: 120,
        discountRatePercent: 10,
        terminalGrowthRatePercent: 2,
        projectionYears: 5,
      );
      expect(over.isOvervalued, isTrue);
      expect(over.isUndervalued, isFalse);
    });
    test('zero price returns 0 margin', () {
      const zero = IntrinsicValueEstimate(
        ticker: 'X',
        currentPriceUsd: 0,
        intrinsicValueUsd: 50,
        discountRatePercent: 10,
        terminalGrowthRatePercent: 3,
        projectionYears: 10,
      );
      expect(zero.marginOfSafetyPercent, equals(0));
    });
  });
}
