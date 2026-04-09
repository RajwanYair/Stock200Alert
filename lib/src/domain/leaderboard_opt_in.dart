/// Leaderboard Opt-In — user consent model for the opt-in public leaderboard
/// feature (v1.8). Governs visibility and data-sharing preferences.
library;

import 'package:equatable/equatable.dart';

/// How much of the user's identity is visible on the public leaderboard.
enum LeaderboardPrivacyLevel {
  /// Full username is shown.
  publicUsername,

  /// Only the first two characters + asterisks are shown (e.g., "Jo***").
  masked,

  /// Shown as "Anonymous User #N".
  anonymous,
}

/// A recorded consent decision (accept or revoke) with a timestamp.
class LeaderboardConsent extends Equatable {
  const LeaderboardConsent({
    required this.granted,
    required this.decidedAt,
    this.ipRegion,
  });

  /// True if the user accepted the leaderboard terms; false if revoked.
  final bool granted;
  final DateTime decidedAt;

  /// ISO 3166-1 alpha-2 region code where consent was recorded (for GDPR).
  final String? ipRegion;

  @override
  List<Object?> get props => [granted, decidedAt, ipRegion];
}

/// Manages a user's opt-in state for the public leaderboard.
class LeaderboardOptIn extends Equatable {
  const LeaderboardOptIn({
    required this.userId,
    required this.isOptedIn,
    required this.privacyLevel,
    required this.consentHistory,
    this.displayName,
  });

  /// Creates a default (opted-out, anonymous) profile for [userId].
  factory LeaderboardOptIn.defaultFor(String userId) => LeaderboardOptIn(
    userId: userId,
    isOptedIn: false,
    privacyLevel: LeaderboardPrivacyLevel.anonymous,
    consentHistory: const [],
  );

  final String userId;
  final bool isOptedIn;
  final LeaderboardPrivacyLevel privacyLevel;
  final List<LeaderboardConsent> consentHistory;

  /// Custom display name; null uses the app-derived username.
  final String? displayName;

  /// Returns the most recent consent decision, or null if none exist.
  LeaderboardConsent? get latestConsent =>
      consentHistory.isEmpty ? null : consentHistory.last;

  /// Returns a copy with [isOptedIn] set to true and [consent] appended.
  LeaderboardOptIn optIn(
    LeaderboardConsent consent, {
    LeaderboardPrivacyLevel privacyLevel = LeaderboardPrivacyLevel.masked,
  }) => LeaderboardOptIn(
    userId: userId,
    isOptedIn: true,
    privacyLevel: privacyLevel,
    consentHistory: [...consentHistory, consent],
    displayName: displayName,
  );

  /// Returns a copy with [isOptedIn] set to false and [consent] appended.
  LeaderboardOptIn optOut(LeaderboardConsent consent) => LeaderboardOptIn(
    userId: userId,
    isOptedIn: false,
    privacyLevel: privacyLevel,
    consentHistory: [...consentHistory, consent],
    displayName: displayName,
  );

  @override
  List<Object?> get props => [
    userId,
    isOptedIn,
    privacyLevel,
    consentHistory,
    displayName,
  ];
}
