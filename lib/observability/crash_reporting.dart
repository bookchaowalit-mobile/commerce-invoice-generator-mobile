import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry DSN, injected at build time with `--dart-define=SENTRY_DSN=...`.
///
/// Only the CI release build passes it. Every other build (local runs, tests,
/// the debug APK) has an empty DSN, so crash reporting stays off and the app
/// makes no network calls.
const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// Whether this build reports crashes at all.
bool crashReportingEnabled(String dsn) => dsn.trim().isNotEmpty;

/// Errors only, scrubbed: no default PII, no tracing or sessions, no
/// breadcrumbs, screenshots or view hierarchy. Native crash and ANR capture is
/// off so every event passes through [scrubEvent].
void configureCrashReporting(SentryFlutterOptions options,
    {required String dsn}) {
  options
    ..dsn = dsn
    ..sendDefaultPii = false
    ..tracesSampleRate = null
    ..tracesSampler = null
    ..enableAutoPerformanceTracing = false
    ..enableUserInteractionTracing = false
    ..enableAutoSessionTracking = false
    ..enableNativeCrashHandling = false
    ..anrEnabled = false
    ..attachScreenshot = false
    ..attachViewHierarchy = false
    ..enableUserInteractionBreadcrumbs = false
    ..enableAutoNativeBreadcrumbs = false
    ..enablePrintBreadcrumbs = false
    ..recordHttpBreadcrumbs = false
    ..maxBreadcrumbs = 0
    ..beforeBreadcrumb = _dropBreadcrumb
    ..beforeSend = scrubEvent;
}

Breadcrumb? _dropBreadcrumb(Breadcrumb? breadcrumb, Hint hint) => null;

/// Removes anything that could identify the user or quote what they typed.
///
/// Exception values are dropped too: a [FormatException] message, for
/// example, can contain the text being parsed (client names, amounts). The
/// exception type and stack trace are kept, which is enough to find the bug.
SentryEvent? scrubEvent(SentryEvent event, Hint hint) {
  event
    ..user = null
    ..request = null
    ..breadcrumbs = null
    ..serverName = null;
  // ignore: deprecated_member_use
  event.extra = null;
  event.contexts.device?.name = null;
  for (final exception in event.exceptions ?? const <SentryException>[]) {
    exception.value = null;
  }
  return event;
}
