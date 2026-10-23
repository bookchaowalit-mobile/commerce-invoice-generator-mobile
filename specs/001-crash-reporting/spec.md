# 001 — Crash reporting and a release build artifact

| Field | Value |
|---|---|
| Status | implemented on `main` (2026-10-23) |
| Commits | `7d379d6` (CI), `67907b0` (Sentry), `11d6954` (docs), `6395bb8` (sentry_flutter 9.30.1) |
| CI evidence | run 39907615105 on `6395bb8`: all jobs green, artifact `invoice-generator-android-6395bb8…` uploaded |
| Owner / AI maker | bookchaowalit / Claude Code (b-tier-b) |
| Related | [PRODUCT.md](../../PRODUCT.md), [KPI plan](../../docs/measurement/KPI-PLAN.md) |

## Problem

The app had no way to learn that it crashed, and CI produced only a debug APK, so there was no release-mode
build to inspect. Any crash reporting must keep the app's privacy promise: invoices contain client names and
amounts, and none of that may leave the device.

## Outcome

1. A build made with `--dart-define=SENTRY_DSN=...` sends **errors only** to Sentry (org `personal-yu0`, project
   `commerce-invoice-generator-mobile`), with user, request, breadcrumbs, extra data, device name and exception
   messages removed. Without a DSN (every local, test and debug build) Sentry is not initialised at all.
2. The About screen tells the truth in both cases: "no account, analytics or network calls" without a DSN, a crash
   report disclosure with one.
3. On every push to `main`, CI builds a debug APK and a release app bundle with the DSN from the `SENTRY_DSN`
   secret, and uploads both as the workflow artifact `invoice-generator-android-<sha>` with SHA-256 in the summary.
   The release bundle is **unsigned** (no upload keystore exists); a CI-only Gradle property allows that, and a
   release build without it still fails closed (checked in CI).
4. The shared security workflow (gitleaks, Semgrep, OSV-Scanner on `pubspec.lock`, Trivy) runs on every push and PR.

## Acceptance criteria and tests

| # | Criterion | Test |
|---|---|---|
| A1 | No DSN (empty or blank) means crash reporting is off | `test/crash_reporting_test.dart` "crashReportingEnabled is off without a DSN" |
| A2 | A DSN turns it on | "is on with a DSN" |
| A3 | Options: no default PII, no tracing, no screenshots or view hierarchy, scrub hooks set | "sends errors only, with no default PII and no tracing" |
| A4 | Every breadcrumb is dropped | "drops every breadcrumb before it is recorded" |
| A5 | User, request, breadcrumbs, extra and server name are stripped | "strips user, request, breadcrumbs, extra and server name" |
| A6 | Exception type kept, exception value (may quote typed text) dropped | "keeps the exception type but drops its value…" |
| A7 | About copy without DSN promises no network calls | widget test "promises no network calls when crash reporting is off" |
| A8 | About copy with DSN discloses Sentry crash reports | widget test "discloses crash reports when they are on" |
| A9 | Unsigned release still fails without the CI flag | CI step "Verify Android release signing fails closed without credentials" |
| A10 | Release bundle + debug APK uploaded with SHA-256 | CI job "Android builds (main only)" |

## Red-first evidence (ADR-0004)

The tests were written before `lib/observability/crash_reporting.dart` existed. Running them on a copy of the
committed tree plus the new test (Flutter 3.47.5, 2026-10-23) failed to compile:

```text
test/crash_reporting_test.dart:3:8: Error: Error when reading 'lib/observability/crash_reporting.dart': No such file or directory
test/crash_reporting_test.dart:10:14: Error: Method not found: 'crashReportingEnabled'.
```

After the implementation: `flutter analyze` "No issues found", `flutter test` "+32: All tests passed!".

## UI sign-off

The change touches only the About privacy text. Checked in Flutter web builds of this commit (with and without a
dummy DSN, `example.invalid`, so nothing was sent) at 375, 768 and 1440 px wide, Invoice and About tabs:

- Without DSN: About shows "no account, analytics or network calls"; Invoice screen unchanged.
- With DSN: About shows the crash report disclosure, wraps cleanly at 375 px, no clipping or overlap at any width.
- Pre-existing, not changed here: at 1440 px the text spans the full width (the app is phone-first; no max width).

Screenshots: `~/work/b-tier-b/shots/commerce-invoice-generator-mobile-sentry/` (owner machine). Signed off by
Claude Code (AI reviewer), 2026-10-23. Not yet run on an Android device or emulator.

## Dependency note

`sentry_flutter` 10.x declares Android minSdk 26 and broke the manifest merge (app minSdk 24, run 39906161126).
Pinned to `^9.30.1` (minSdk 21) so the supported device range is unchanged; same choice as
`productivity-habit-tracker-mobile`. Moving to 10.x needs a decision to drop Android 7.x.

## Out of scope

- Product analytics (D4 chose PostHog free tier; no key yet), PDF export, share sheet, store release, signing.
- Native (Kotlin/NDK) crash capture and ANR reporting: off so every event passes through the Dart scrubber.

## Deploy state

No live URL and nothing in a store. The deliverable is the CI artifact on `main`; the release bundle is unsigned
and cannot be installed or uploaded until an upload keystore exists (owner action).
