import 'package:cross_tide/src/domain/report_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const builder = ReportBuilder();

  group('ReportBuilder', () {
    test('builds report with three sections', () {
      final report = builder.build(
        ticker: 'AAPL',
        generatedAt: DateTime(2025, 4, 7),
        technicalIndicators: {'SMA200': '152.30', 'RSI': '55.2'},
        signalHistory: {'Last BUY': '2025-03-15', 'Last SELL': '2025-02-10'},
        riskMetrics: {'Max Drawdown': '-12.5%', 'Sharpe': '1.23'},
        metadata: const ReportMetadata(
          dataRange: '2024-01-01 to 2025-04-07',
          candleCount: 315,
          providerName: 'Yahoo Finance',
        ),
      );

      expect(report.ticker, 'AAPL');
      expect(report.sections, hasLength(3));
      expect(report.sections[0].title, 'Technical Indicators');
      expect(report.sections[0].rows, hasLength(2));
      expect(report.sections[0].rows.first.label, 'SMA200');
      expect(report.sections[0].rows.first.value, '152.30');
      expect(report.sections[1].title, 'Signal History');
      expect(report.sections[2].title, 'Risk Metrics');
      expect(report.metadata.candleCount, 315);
    });

    test('TickerReport props equality', () {
      final a = builder.build(
        ticker: 'X',
        generatedAt: DateTime(2025, 1, 1),
        technicalIndicators: {},
        signalHistory: {},
        riskMetrics: {},
        metadata: const ReportMetadata(
          dataRange: '',
          candleCount: 0,
          providerName: '',
        ),
      );
      final b = builder.build(
        ticker: 'X',
        generatedAt: DateTime(2025, 1, 1),
        technicalIndicators: {},
        signalHistory: {},
        riskMetrics: {},
        metadata: const ReportMetadata(
          dataRange: '',
          candleCount: 0,
          providerName: '',
        ),
      );
      expect(a, equals(b));
    });

    test('ReportRow annotation defaults to empty', () {
      const row = ReportRow(label: 'Key', value: 'Val');
      expect(row.annotation, '');
    });

    test('ReportSection and ReportRow props equality', () {
      const a = ReportSection(
        title: 'T',
        rows: [ReportRow(label: 'L', value: 'V')],
      );
      const b = ReportSection(
        title: 'T',
        rows: [ReportRow(label: 'L', value: 'V')],
      );
      expect(a, equals(b));
    });
  });
}
