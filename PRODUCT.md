# Invoice Generator Mobile

**Tier:** Mobile release candidate (not store-released)  
**Stack:** Flutter 3.47.5 + Dart, Material 3, `shared_preferences`, `pubspec.lock`  
**CI:** `.github/workflows/build.yml`: format, analyze, test, the release-signing negative check, the shared
security scan, and on `main` a debug APK plus an unsigned release app bundle uploaded as a workflow artifact

## What it is and who it is for

A single-screen Android app for a freelancer or small shop that needs a quick invoice: add line items, apply a
discount and tax, and copy a plain-text invoice to paste into a chat or email. It is a portfolio piece showing an
offline-first Flutter app with tested money arithmetic, not a billing system.

## What works today

- Line items with description, quantity and unit price; discount percentage and tax rate, all computed in integer
  cents (`lib/logic/invoice.dart`). Input such as `7,5` is rejected rather than read as 75.
- Plain-text preview and copy to clipboard.
- The draft (header, rates, items) is saved on the device with `shared_preferences` and restored on launch;
  "Start a new invoice" clears it.
- Crash reporting with Sentry, **errors only**, in builds made with a `SENTRY_DSN` (only the CI release bundle).
  User, request, breadcrumbs, extra data, device name and exception messages are removed before sending; no
  tracing, sessions, screenshots or native crash capture. When it is on, the About screen says so. Every other
  build makes no network calls.
- 32 unit and widget tests (`test/`), including the Sentry scrubbing and the About privacy copy.

## What does not work yet

- No PDF export or Android share sheet; copy-to-clipboard only.
- One invoice at a time: no saved invoice list, clients or numbering history.
- No account, backend, sync or analytics.
- Not run on a real device or emulator for this version; no Maestro flow yet.
- Not in any store. The CI release bundle is **unsigned** (no upload keystore exists yet) and cannot be installed or
  uploaded; the installable CI build is the debug APK.

## Where it runs

- No live URL. The deliverable is the CI workflow artifact `invoice-generator-android-<sha>` on `main`
  (debug APK + unsigned release AAB, SHA-256 in the run summary).
- The web version is a separate repository, `bookchaowalit-website/commerce-invoice-generator-web`.

## RC decision (2026-10-16, BOO-215)

**Build-out: stays in the mobile RC set.** The owner chose build-out over
demotion on 2026-10-16. The local invoice flow already exists and is tested:
line items, discount and tax in integer cents, a draft saved with
`shared_preferences`, and plain-text copy export, covered by unit and widget
tests in fail-closed CI. Recorded in the RC gate audit
(`bookchaowalit/knowledge-base:archive/repository-catalog-audits/BOOK-DEV-MOBILE-RC-GATE-2026-08-11.md`).

Still open before any release claim: a device or emulator run, PDF or
share-sheet export, an upload keystore, and store publication.

## Measurement and specs

- KPI plan: [docs/measurement/KPI-PLAN.md](docs/measurement/KPI-PLAN.md) (draft; Sentry is the only live signal).
- Specs: [specs/](specs/).
