/// Ticker Detail Screen — Price chart + SMA200 overlay + alert history.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/domain.dart';
import '../providers.dart';

class TickerDetailScreen extends ConsumerStatefulWidget {
  const TickerDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  ConsumerState<TickerDetailScreen> createState() => _TickerDetailScreenState();
}

class _TickerDetailScreenState extends ConsumerState<TickerDetailScreen> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final candlesAsync = ref.watch(tickerCandlesProvider(widget.symbol));
    final alertStateAsync = ref.watch(tickerAlertStateProvider(widget.symbol));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _onRefresh,
          ),
        ],
      ),
      body: candlesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (candles) {
          if (candles.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          const smaCalc = SmaCalculator();
          final smaSeries = smaCalc.computeSeries(candles, period: 200);

          // Last 200 trading days for the chart
          final chartStart = candles.length > 250 ? candles.length - 250 : 0;
          final chartCandles = candles.sublist(chartStart);
          final chartSma = smaSeries.sublist(chartStart);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(candles, smaSeries, alertStateAsync),
                const SizedBox(height: 16),
                _buildChart(chartCandles, chartSma),
                const SizedBox(height: 16),
                _buildAlertStateCard(alertStateAsync),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    List<DailyCandle> candles,
    List<(DateTime, double?)> smaSeries,
    AsyncValue<TickerAlertState> alertStateAsync,
  ) {
    final lastCandle = candles.last;
    final lastSma = smaSeries.last.$2;
    final isAbove = lastSma != null && lastCandle.close > lastSma;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.symbol,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _metric('Close', '\$${lastCandle.close.toStringAsFixed(2)}'),
                const SizedBox(width: 24),
                _metric(
                  'SMA200',
                  lastSma != null ? '\$${lastSma.toStringAsFixed(2)}' : 'N/A',
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAbove
                        ? Colors.green.withAlpha(20)
                        : Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isAbove ? 'ABOVE' : 'BELOW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAbove ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Last trading day: ${dateFormat.format(lastCandle.date)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildChart(List<DailyCandle> candles, List<(DateTime, double?)> sma) {
    final priceSpots = <FlSpot>[];
    final smaSpots = <FlSpot>[];

    for (var i = 0; i < candles.length; i++) {
      priceSpots.add(FlSpot(i.toDouble(), candles[i].close));
      if (sma[i].$2 != null) {
        smaSpots.add(FlSpot(i.toDouble(), sma[i].$2!));
      }
    }

    // Compute y-axis bounds
    final allValues = [
      ...priceSpots.map((s) => s.y),
      ...smaSpots.map((s) => s.y),
    ];
    final minY = allValues.reduce((a, b) => a < b ? a : b) * 0.98;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) * 1.02;

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) => Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (candles.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= candles.length) return const SizedBox();
                  return Text(
                    DateFormat('M/d').format(candles[idx].date),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            // Price line
            LineChartBarData(
              spots: priceSpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            // SMA200 line
            if (smaSpots.isNotEmpty)
              LineChartBarData(
                spots: smaSpots,
                isCurved: true,
                color: Colors.orange,
                barWidth: 2,
                dashArray: [5, 3],
                dotData: const FlDotData(show: false),
              ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final color = spot.barIndex == 0 ? Colors.blue : Colors.orange;
                final label = spot.barIndex == 0 ? 'Price' : 'SMA200';
                return LineTooltipItem(
                  '$label: \$${spot.y.toStringAsFixed(2)}',
                  TextStyle(color: color, fontSize: 12),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertStateCard(AsyncValue<TickerAlertState> stateAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: stateAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error loading alert state: $e'),
          data: (state) {
            final dateFormat = DateFormat('MMM d, yyyy HH:mm');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert State',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _alertRow('Status', state.lastStatus.name.toUpperCase()),
                if (state.lastAlertedCrossUpAt != null)
                  _alertRow(
                    'Last Cross-Up Alert',
                    dateFormat.format(state.lastAlertedCrossUpAt!),
                  ),
                if (state.lastEvaluatedAt != null)
                  _alertRow(
                    'Last Evaluated',
                    dateFormat.format(state.lastEvaluatedAt!),
                  ),
                if (state.lastCloseUsed != null)
                  _alertRow(
                    'Last Close Used',
                    '\$${state.lastCloseUsed!.toStringAsFixed(2)}',
                  ),
                if (state.lastSma200 != null)
                  _alertRow(
                    'Last SMA200',
                    '\$${state.lastSma200!.toStringAsFixed(2)}',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _alertRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    try {
      final service = await ref.read(refreshServiceProvider.future);
      await service.refreshTicker(widget.symbol);
      ref.invalidate(tickerCandlesProvider(widget.symbol));
      ref.invalidate(tickerAlertStateProvider(widget.symbol));
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
}
