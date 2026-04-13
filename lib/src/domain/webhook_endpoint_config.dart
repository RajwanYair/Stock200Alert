import 'package:equatable/equatable.dart';

/// Webhook endpoint config — outbound webhook URL and auth scheme.
enum WebhookAuthScheme { none, bearerToken, hmacSha256, apiKey, basic }

class WebhookEndpointConfig extends Equatable {
  const WebhookEndpointConfig({
    required this.endpointId,
    required this.url,
    required this.authScheme,
    required this.isEnabled,
    required this.timeoutMs,
  });

  final String endpointId;
  final String url;
  final WebhookAuthScheme authScheme;
  final bool isEnabled;
  final int timeoutMs;

  WebhookEndpointConfig copyWith({
    String? endpointId,
    String? url,
    WebhookAuthScheme? authScheme,
    bool? isEnabled,
    int? timeoutMs,
  }) => WebhookEndpointConfig(
    endpointId: endpointId ?? this.endpointId,
    url: url ?? this.url,
    authScheme: authScheme ?? this.authScheme,
    isEnabled: isEnabled ?? this.isEnabled,
    timeoutMs: timeoutMs ?? this.timeoutMs,
  );

  @override
  List<Object?> get props => [
    endpointId,
    url,
    authScheme,
    isEnabled,
    timeoutMs,
  ];
}
