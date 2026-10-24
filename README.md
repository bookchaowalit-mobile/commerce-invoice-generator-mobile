# Invoice Generator — Mobile

Build an invoice from line items with tax and discount, then copy a plain-text version.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Features

- Line items with quantity and unit price
- Discount percentage and tax rate applied in integer cents
- Plain-text invoice preview you can copy

The invoice being edited (header, rates and line items) is saved on this
device with `shared_preferences` and restored on launch; "Start a new
invoice" clears it. There is no account, backend or analytics.

Crash reporting (Sentry, errors only, scrubbed of user data and exception
messages) is compiled in only when the build passes
`--dart-define=SENTRY_DSN=...`, which only the CI release bundle does. Every
other build makes no network calls. See `lib/observability/crash_reporting.dart`.

## Status

Mobile release candidate (build-out decided 2026-10-16; see
[PRODUCT.md](PRODUCT.md#rc-decision-2026-10-16-boo-215)). Not store-released and
not yet verified on a device.

## Tech Stack

- **Framework:** Flutter (CI pinned to 3.47.5) + Material 3
- **Language:** Dart
- **State:** `StatefulWidget` / `setState`; the core logic is pure Dart in
  `lib/logic/` and unit-tested without widgets
- **Persistence:** `shared_preferences` behind a small `DraftRepository`
  interface in `lib/data/` (in-memory implementation for tests)

## Develop and verify

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

CI (`.github/workflows/build.yml`) runs the same format/analyze/test checks,
checks that an unsigned release build still fails, and runs the shared
security scan (gitleaks, Semgrep, OSV-Scanner, Trivy). On pushes to `main` it
uploads a workflow artifact with a debug APK and an **unsigned** release app
bundle (SHA-256 in the run summary). The unsigned bundle is not for any store.

## Build

```bash
# Android
flutter build apk --debug
```

Release builds (`flutter build apk --release` / `appbundle`) fail on purpose
until signing is configured; they never fall back to the debug key. CI alone
sets the Gradle property `allowUnsignedRelease=true` to produce an unsigned
bundle for inspection; that bundle cannot be installed or uploaded. To sign,
create an upload keystore outside the repo and add the ignored
`android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Never commit `key.properties` or keystores (both are git-ignored).
The upload keystore and passwords are in Infisical `/android`; see
[docs/RELEASE-SIGNING.md](docs/RELEASE-SIGNING.md).

## Related

- **Frontend:** [bookchaowalit-website/commerce-invoice-generator-web](https://github.com/bookchaowalit-website/commerce-invoice-generator-web)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
