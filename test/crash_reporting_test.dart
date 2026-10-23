import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_generator/observability/crash_reporting.dart';
import 'package:invoice_generator/screens/about_screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('crashReportingEnabled', () {
    test('is off without a DSN', () {
      expect(crashReportingEnabled(''), isFalse);
      expect(crashReportingEnabled('   '), isFalse);
    });

    test('is on with a DSN', () {
      expect(crashReportingEnabled('https://key@example.invalid/1'), isTrue);
    });
  });

  group('configureCrashReporting', () {
    test('sends errors only, with no default PII and no tracing', () {
      final options = SentryFlutterOptions();
      configureCrashReporting(options, dsn: 'https://key@example.invalid/1');

      expect(options.dsn, 'https://key@example.invalid/1');
      expect(options.sendDefaultPii, isFalse);
      expect(options.tracesSampleRate, isNull);
      expect(options.tracesSampler, isNull);
      expect(options.attachScreenshot, isFalse);
      // ignore: experimental_member_use
      expect(options.attachViewHierarchy, isFalse);
      expect(options.beforeSend, isNotNull);
      expect(options.beforeBreadcrumb, isNotNull);
    });

    test('drops every breadcrumb before it is recorded', () {
      final options = SentryFlutterOptions();
      configureCrashReporting(options, dsn: 'https://key@example.invalid/1');

      final kept = options.beforeBreadcrumb!(
        Breadcrumb(message: 'Invoice for ACME Co.'),
        Hint(),
      );
      expect(kept, isNull);
    });
  });

  group('scrubEvent', () {
    SentryEvent eventWithPersonalData() => SentryEvent(
          message: SentryMessage('Could not save'),
          user: SentryUser(id: 'u-1', email: 'client@example.com'),
          request: SentryRequest(url: 'https://example.com/?client=ACME'),
          breadcrumbs: [Breadcrumb(message: 'typed ACME Co.')],
          // ignore: deprecated_member_use
          extra: {'clientName': 'ACME Co.'},
          serverName: 'device-name',
          exceptions: [
            SentryException(
              type: 'FormatException',
              value: 'Unexpected character in "ACME Co. 1,200.00"',
            ),
          ],
        );

    test('strips user, request, breadcrumbs, extra and server name', () {
      final scrubbed = scrubEvent(eventWithPersonalData(), Hint())!;

      expect(scrubbed.user, isNull);
      expect(scrubbed.request, isNull);
      expect(scrubbed.breadcrumbs, anyOf(isNull, isEmpty));
      // ignore: deprecated_member_use
      expect(scrubbed.extra, anyOf(isNull, isEmpty));
      expect(scrubbed.serverName, isNull);
    });

    test(
        'keeps the exception type but drops its value, which can quote '
        'what the user typed', () {
      final scrubbed = scrubEvent(eventWithPersonalData(), Hint())!;

      expect(scrubbed.exceptions, hasLength(1));
      expect(scrubbed.exceptions!.single.type, 'FormatException');
      expect(scrubbed.exceptions!.single.value, isNull);
      expect(scrubbed.message?.formatted, 'Could not save');
    });
  });

  group('About screen privacy copy', () {
    Future<void> pumpAbout(WidgetTester tester, {required bool enabled}) =>
        tester.pumpWidget(MaterialApp(
          home: Scaffold(body: AboutScreen(crashReporting: enabled)),
        ));

    testWidgets('promises no network calls when crash reporting is off',
        (tester) async {
      await pumpAbout(tester, enabled: false);
      expect(find.textContaining('no account, analytics or network calls'),
          findsOneWidget);
      expect(find.textContaining('crash report'), findsNothing);
    });

    testWidgets('discloses crash reports when they are on', (tester) async {
      await pumpAbout(tester, enabled: true);
      expect(find.textContaining('network calls'), findsNothing);
      expect(
        find.textContaining('sends a crash report to Sentry'),
        findsOneWidget,
      );
      expect(find.textContaining('never your invoice'), findsOneWidget);
    });
  });
}
