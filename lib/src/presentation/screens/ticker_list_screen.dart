/// Ticker List Screen — Main screen showing all monitored tickers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers.dart';

class TickerListScreen extends ConsumerStatefulWidget {
  const TickerListScreen({super.key});

  @override
  ConsumerState<TickerListScreen> createState() => _TickerListScreenState();
}

class _TickerListScreenState extends ConsumerState<TickerListScreen> {
  final _tickerController = TextEditingController();
  bool _isRefreshing = false;

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickersAsync = ref.watch(tickerListProvider);
    final dateFormat = DateFormat('MMM d, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Alert'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _onRefreshAll,
            tooltip: 'Refresh all tickers',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: tickersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tickers) {
          if (tickers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No tickers added yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to add a stock ticker'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tickers.length,
            itemBuilder: (context, index) {
              final t = tickers[index];
              final statusColor = t.sma200 != null && t.lastClose != null
                  ? (t.lastClose! > t.sma200! ? Colors.green : Colors.red)
                  : Colors.grey;
              final statusLabel = t.sma200 != null && t.lastClose != null
                  ? (t.lastClose! > t.sma200! ? 'Above SMA200' : 'Below SMA200')
                  : 'No data';

              return Dismissible(
                key: ValueKey(t.symbol),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _removeTicker(t.symbol),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withAlpha(30),
                    child: Icon(Icons.show_chart, color: statusColor),
                  ),
                  title: Text(
                    t.symbol,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t.lastClose != null)
                        Text(
                          'Close: \$${t.lastClose!.toStringAsFixed(2)}  '
                          'SMA200: ${t.sma200 != null ? "\$${t.sma200!.toStringAsFixed(2)}" : "—"}',
                        ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (t.lastRefreshAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              dateFormat.format(t.lastRefreshAt!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                      if (t.error != null)
                        Text(
                          t.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/ticker/${t.symbol}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    _tickerController.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ticker'),
        content: TextField(
          controller: _tickerController,
          decoration: const InputDecoration(
            labelText: 'Ticker Symbol',
            hintText: 'e.g. AAPL, MSFT',
          ),
          textCapitalization: TextCapitalization.characters,
          autofocus: true,
          onSubmitted: (_) => _addTicker(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _addTicker(ctx),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTicker(BuildContext dialogContext) async {
    final symbol = _tickerController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    Navigator.pop(dialogContext);
    final repo = await ref.read(repositoryProvider.future);
    await repo.addTicker(symbol);
  }

  Future<void> _removeTicker(String symbol) async {
    final repo = await ref.read(repositoryProvider.future);
    await repo.removeTicker(symbol);
  }

  Future<void> _onRefreshAll() async {
    setState(() => _isRefreshing = true);
    try {
      final service = await ref.read(refreshServiceProvider.future);
      await service.refreshAll();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
}
