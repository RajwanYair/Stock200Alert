/// Plugin Registry — catalog of registered `AlertHandlerPlugin` instances
/// with lifecycle state management (v2.0).
library;

import 'package:equatable/equatable.dart';

import 'alert_handler_plugin.dart';

/// Lifecycle state of a plugin registration.
enum PluginLifecycleState {
  /// Plugin has been registered but not yet initialized.
  registered,

  /// Plugin has been initialized and is ready to deliver alerts.
  active,

  /// Plugin encountered an error during initialization or delivery.
  errored,

  /// Plugin has been explicitly disabled by the user.
  disabled,

  /// Plugin has been unregistered and removed from the registry.
  removed,
}

/// Wraps a plugin with its current lifecycle state and error information.
class RegistrationEntry extends Equatable {
  const RegistrationEntry({
    required this.plugin,
    required this.lifecycleState,
    this.lastError,
    this.errorCount = 0,
  });

  final AlertHandlerPlugin plugin;
  final PluginLifecycleState lifecycleState;
  final String? lastError;
  final int errorCount;

  bool get isOperational => lifecycleState == PluginLifecycleState.active;

  /// Returns a copy with [lifecycleState] set to [PluginLifecycleState.errored].
  RegistrationEntry withError(String error) => RegistrationEntry(
    plugin: plugin,
    lifecycleState: PluginLifecycleState.errored,
    lastError: error,
    errorCount: errorCount + 1,
  );

  /// Returns a copy with [lifecycleState] set to [PluginLifecycleState.active].
  RegistrationEntry activate() => RegistrationEntry(
    plugin: plugin,
    lifecycleState: PluginLifecycleState.active,
    lastError: lastError,
    errorCount: errorCount,
  );

  @override
  List<Object?> get props => [plugin, lifecycleState, lastError, errorCount];
}

/// Manages the registry of all loaded alert handler plugins.
class PluginRegistry extends Equatable {
  const PluginRegistry({required this.entries});

  /// Creates an empty registry.
  const PluginRegistry.empty() : entries = const [];

  final List<RegistrationEntry> entries;

  /// Returns all operational (active) plugins.
  List<AlertHandlerPlugin> get activePlugins => entries
      .where((RegistrationEntry e) => e.isOperational)
      .map((RegistrationEntry e) => e.plugin)
      .toList();

  /// Returns the entry for [pluginId], or null if not registered.
  RegistrationEntry? entryFor(String pluginId) {
    for (final RegistrationEntry e in entries) {
      if (e.plugin.id == pluginId) return e;
    }
    return null;
  }

  /// Returns a copy with [entry] added.
  PluginRegistry withEntry(RegistrationEntry entry) =>
      PluginRegistry(entries: [...entries, entry]);

  @override
  List<Object?> get props => [entries];
}
