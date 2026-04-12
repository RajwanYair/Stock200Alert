import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // S546 — AppUpdateManifest
  group('AppUpdateManifest', () {
    const manifest = AppUpdateManifest(
      currentVersion: '2.16.0',
      latestVersion: '2.20.0',
      minRequiredVersion: '2.10.0',
      releaseNotes: 'New domain entities and performance improvements.',
      downloadUrlAndroid: 'https://play.google.com/store/apps/CrossTide',
      downloadUrlWindows: 'https://github.com/CrossTide/releases/latest',
    );

    test('isUpdateAvailable when versions differ', () {
      expect(manifest.isUpdateAvailable, isTrue);
    });
    test('hasReleaseNotes when non-empty', () {
      expect(manifest.hasReleaseNotes, isTrue);
    });
    test('hasAndroidDownload when URL set', () {
      expect(manifest.hasAndroidDownload, isTrue);
    });
    test('no update when versions match', () {
      const noUp = AppUpdateManifest(
        currentVersion: '2.20.0',
        latestVersion: '2.20.0',
        minRequiredVersion: '2.10.0',
        releaseNotes: '',
        downloadUrlAndroid: '',
        downloadUrlWindows: '',
      );
      expect(noUp.isUpdateAvailable, isFalse);
      expect(noUp.hasReleaseNotes, isFalse);
      expect(noUp.hasAndroidDownload, isFalse);
    });
    test('isMandatory defaults to false', () {
      expect(manifest.isMandatory, isFalse);
    });
  });

  // S547 — RemoteConfigSnapshot
  group('RemoteConfigSnapshot', () {
    const snap = RemoteConfigSnapshot(
      snapshotId: 's1',
      fetchedAtMs: 1700000000000,
      configVersion: 'v3',
      values: {'darkMode': 'true', 'maxTickers': '50'},
    );

    test('entryCount reflects values map size', () {
      expect(snap.entryCount, equals(2));
    });
    test('isFresh when not fallback', () => expect(snap.isFresh, isTrue));
    test('isEmpty false when values present', () {
      expect(snap.isEmpty, isFalse);
    });
    test('fallback snapshot', () {
      const fallback = RemoteConfigSnapshot(
        snapshotId: 's2',
        fetchedAtMs: 0,
        configVersion: 'v1',
        values: {},
        isFallback: true,
      );
      expect(fallback.isFallback, isTrue);
      expect(fallback.isFresh, isFalse);
      expect(fallback.isEmpty, isTrue);
    });
  });

  // S548 — CrashReportSummary
  group('CrashReportSummary', () {
    const summary = CrashReportSummary(
      periodLabel: '2026-W14',
      appVersion: '2.19.0',
      totalCrashes: 3,
      affectedUsers: 2,
      crashFreeUserPercent: 99.8,
      topCrashReason: 'NullPointerException',
      generatedAtMs: 1700000000000,
    );

    test('isStable for crash-free >= 99.5%', () {
      expect(summary.isStable, isTrue);
    });
    test('hasCriticalInstability false for 99.8%', () {
      expect(summary.hasCriticalInstability, isFalse);
    });
    test('hasHighVolume false for < 100 crashes', () {
      expect(summary.hasHighVolume, isFalse);
    });
    test('critical instability', () {
      const critical = CrashReportSummary(
        periodLabel: '2026-W13',
        appVersion: '2.18.0',
        totalCrashes: 500,
        affectedUsers: 200,
        crashFreeUserPercent: 90.0,
        topCrashReason: 'OutOfMemoryError',
        generatedAtMs: 0,
      );
      expect(critical.hasCriticalInstability, isTrue);
      expect(critical.isStable, isFalse);
      expect(critical.hasHighVolume, isTrue);
    });
  });

  // S549 — AbTestAssignment
  group('AbTestAssignment', () {
    const assignment = AbTestAssignment(
      assignmentId: 'a1',
      experimentId: 'exp_01',
      userId: 'u123',
      variantName: 'treatment_b',
      assignedAtMs: 1700000000000,
    );

    test('isTreatment true when not control', () {
      expect(assignment.isTreatment, isTrue);
    });
    test('isControl defaults to false', () {
      expect(assignment.isControl, isFalse);
    });
    test('hasVariant when variantName non-empty', () {
      expect(assignment.hasVariant, isTrue);
    });
    test('control group assignment', () {
      const control = AbTestAssignment(
        assignmentId: 'a2',
        experimentId: 'exp_01',
        userId: 'u456',
        variantName: 'control',
        assignedAtMs: 0,
        isControl: true,
      );
      expect(control.isControl, isTrue);
      expect(control.isTreatment, isFalse);
    });
  });

  // S550 — UserCohortDefinition
  group('UserCohortDefinition', () {
    const cohort = UserCohortDefinition(
      cohortId: 'c1',
      cohortName: 'Power Users',
      description: 'Users with >= 10 alerts configured',
      memberCount: 1500,
      filterExpression: 'alertCount >= 10',
    );

    test('isLargeCohort for >= 1000 members', () {
      expect(cohort.isLargeCohort, isTrue);
    });
    test('isEmpty false when members present', () {
      expect(cohort.isEmpty, isFalse);
    });
    test('hasDescription when non-empty', () {
      expect(cohort.hasDescription, isTrue);
    });
    test('isActive defaults to true', () {
      expect(cohort.isActive, isTrue);
    });
    test('empty small cohort', () {
      const empty = UserCohortDefinition(
        cohortId: 'c2',
        cohortName: 'Beta',
        description: '',
        memberCount: 0,
        filterExpression: 'betaFlag == true',
        isActive: false,
      );
      expect(empty.isEmpty, isTrue);
      expect(empty.isLargeCohort, isFalse);
      expect(empty.hasDescription, isFalse);
      expect(empty.isActive, isFalse);
    });
  });
}
