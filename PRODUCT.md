# Invoice Generator Mobile

**Tier:** Mobile release candidate (not store-released)  
**Stack:** Flutter + `pubspec.lock`  
**CI:** fail-closed analyze/test via `.github/workflows/build.yml` (BD-020)

## Status

Portfolio mobile RC. Run `flutter test` and Solo Empire `mobile_release_gate.py`
before any release claim. Offline-first demo story preferred over fake backend
metrics.

## RC decision (2026-10-16, BOO-215)

**Build-out: stays in the mobile RC set.** The owner chose build-out over
demotion on 2026-10-16. The local invoice flow already exists and is tested:
line items, discount and tax in integer cents, a draft saved with
`shared_preferences`, and plain-text copy export, covered by unit and widget
tests in fail-closed CI. Recorded in the RC gate audit
(`bookchaowalit/knowledge-base:archive/repository-catalog-audits/BOOK-DEV-MOBILE-RC-GATE-2026-08-11.md`).

Still open before any release claim: a device or emulator run, PDF or
share-sheet export, and store publication.
