import 'package:cross_tide/src/domain/app_session_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSessionMetrics', () {
    test('equality', () {
      const a = AppSessionMetrics(
        sessionId: 'sess-1',
        pageViews: 12,
        interactionCount: 45,
        engagementLevel: SessionEngagementLevel.high,
        durationSeconds: 360,
      );
      const b = AppSessionMetrics(
        sessionId: 'sess-1',
        pageViews: 12,
        interactionCount: 45,
        engagementLevel: SessionEngagementLevel.high,
        durationSeconds: 360,
      );
      expect(a, b);
    });

    test('copyWith changes pageViews', () {
      const base = AppSessionMetrics(
        sessionId: 'sess-1',
        pageViews: 12,
        interactionCount: 45,
        engagementLevel: SessionEngagementLevel.high,
        durationSeconds: 360,
      );
      final updated = base.copyWith(pageViews: 15);
      expect(updated.pageViews, 15);
    });

    test('props length is 5', () {
      const obj = AppSessionMetrics(
        sessionId: 'sess-1',
        pageViews: 12,
        interactionCount: 45,
        engagementLevel: SessionEngagementLevel.high,
        durationSeconds: 360,
      );
      expect(obj.props.length, 5);
    });
  });
}
