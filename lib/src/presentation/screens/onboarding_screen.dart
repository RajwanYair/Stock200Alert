/// Onboarding Screen — Disclaimer + API key setup.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _apiKeyController = TextEditingController();
  bool _disclaimerAccepted = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Stock Alert')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.show_chart, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Stock Alert — SMA200 Cross-Up Monitor',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Disclaimer',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This app is for informational and educational purposes only. '
                      'It is NOT financial advice. Stock prices are volatile and past '
                      'performance does not guarantee future results. Always do your '
                      'own research and consult a financial advisor before making '
                      'investment decisions. The developers are not responsible for '
                      'any financial losses.',
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _disclaimerAccepted,
                      onChanged: (v) =>
                          setState(() => _disclaimerAccepted = v ?? false),
                      title: const Text('I understand and accept'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // API Key
            Text(
              'Market Data API Key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Alpha Vantage API key. Get a free key at '
              'alphavantage.co/support/#api-key\n'
              'Leave blank to use mock data for testing.',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'API Key (optional)',
                hintText: 'e.g. ABCDEF1234567890',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _disclaimerAccepted ? _onContinue : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    const storage = FlutterSecureStorage();
    final apiKey = _apiKeyController.text.trim();

    if (apiKey.isNotEmpty) {
      await storage.write(key: 'market_data_api_key', value: apiKey);
    }
    await storage.write(key: 'onboarding_complete', value: 'true');

    if (mounted) {
      context.go('/');
    }
  }
}
