---
title: "Invoice Generator Mobile — KPI and Instrumentation Plan"
status: draft
created: 2026-10-22
updated: 2026-10-23
description: "How Invoice Generator Mobile would be measured once it has users; today only Sentry error reports exist."
template: architecture-docs templates/sdlc/kpi-and-instrumentation-plan.md
---

# Invoice Generator Mobile — KPI and Instrumentation Plan

## Document control

| Field | Value |
|---|---|
| Project / product | bookchaowalit-mobile/commerce-invoice-generator-mobile (no live URL; not store-released) |
| Version / status | 0.1 / **draft** — definitions only; no analytics is live, no baselines |
| Metric owner | Owner (bookchaowalit) |
| AI maker | Claude Code (b-tier-b session, 2026-10-22) |
| AI reviewer | not yet reviewed |
| Charter objective | OBJ-01 below (portfolio RC; no charter document) |
| Analytics source of truth | none yet. Product analytics: owner decision **D4** (2026-10-23) chose the PostHog free tier, but no PostHog project or key exists yet, so nothing is sent. The only live signal is Sentry (org `personal-yu0`, project `commerce-invoice-generator-mobile`), errors only, and only from the CI release bundle, which is unsigned and not distributed |
| Dashboard | none |
| Next review | 2026-11-15 (Big Loop milestone M1) |

## KPI tree

```text
OBJ-01 Show a working offline invoice flow that a freelancer can finish without help
  └─ KPI-O-01 Invoice completion rate: invoices copied / invoices started
       ├─ KPI-L-01 Median line items per copied invoice
       ├─ KPI-L-02 Draft restore rate: launches that restore a saved draft / launches with a saved draft
       └─ KPI-G-01 Crash-affected launches: launches with a Sentry error / launches (must stay < 1%)
```

## KPI definitions

| KPI ID | Type | Formula | Unit | Min volume | Data source and event(s) | Baseline | Target | Alert | Cadence | Owner |
|---|---|---|---|---|---|---|---|---|---|---|
| KPI-O-01 | outcome | `invoice_copied` / `invoice_started` | % | ≥ 50 started | planned events | not yet measured (no users) | ≥ 60% within 30 days of a first public build | < 40% over 14 days | monthly | Owner |
| KPI-L-01 | leading | median `item_count` on `invoice_copied` | items | ≥ 30 copies | planned event | not yet measured | none set (descriptive) | — | monthly | Owner |
| KPI-L-02 | leading | `draft_restored` / launches with a saved draft | % | ≥ 50 launches | planned event | not yet measured | ≥ 99% | < 95% | monthly | Owner |
| KPI-G-01 | guardrail | launches with ≥ 1 Sentry error / launches | % | ≥ 200 launches | Sentry issues (live) ÷ `app_opened` (planned) | not yet measured; error count today: 0 (no distributed build) | < 1% | any new issue in a release | per release | Owner |

Below the minimum volume a rate is reported as "not measurable". Launch counts need `app_opened`, so KPI-G-01 is
only an error count until analytics exists (Sentry session tracking is deliberately off).

## Event and data specification

| Event | Trigger | Properties | Personal data? | Emitted by | Status |
|---|---|---|---|---|---|
| `app_opened` | app reaches the first frame | app_version | no | app | planned (D4: PostHog, no key yet) |
| `invoice_started` | first line item added to an empty invoice | — | no | app | planned (D4: PostHog, no key yet) |
| `invoice_copied` | user taps copy and the clipboard write succeeds | item_count, has_discount, has_tax | no | app | planned (D4: PostHog, no key yet) |
| `draft_restored` | launch restores a saved draft | item_count | no | app | planned (D4: PostHog, no key yet) |
| Sentry error event | uncaught Dart error in a build with `SENTRY_DSN` | exception type, stack trace, app/OS/device model | no: user, request, breadcrumbs, extra, device name and exception messages are stripped (`lib/observability/crash_reporting.dart`, tested) | app | implemented |

Privacy rules:

- Never send descriptions, client names, amounts or any typed text. Counts and booleans only.
- Adding any analytics event changes the app's promise ("no account or analytics" on the About screen) and needs
  the About copy and a privacy policy updated **before** the build ships.
- Sentry retention follows the Sentry project default; data region is Sentry's (US). No consent banner is needed for
  scrubbed crash reports under the current design; revisit with D4.

## Dashboards and alerts

| Dashboard / alert | KPIs | Location | Status |
|---|---|---|---|
| Sentry issues for `commerce-invoice-generator-mobile` | KPI-G-01 (count only) | Sentry org `personal-yu0` | live, no traffic |
| Product dashboard | KPI-O-01, L-01, L-02 | — | planned (D4) |

## Instrumentation verification (before G10)

| # | Check | Result |
|---|---|---|
| 1 | Events fire once per action | not applicable yet (no events) |
| 2 | Counts reconcile | not applicable |
| 3 | No PII in payloads | Sentry scrubber covered by `test/crash_reporting_test.dart` |
| 4 | Dashboard renders | Sentry project exists; no product dashboard |
| 5 | Alerts reach a channel | not set up |
| 6 | Baselines | waived — dated action: capture after the first distributed build, or by 2026-12-31 decide that this RC stays unmeasured |
| 7 | Consent | not applicable (no analytics) |

## Change history of definitions

| Date | KPI ID | Change | Reason | Approved by |
|---|---|---|---|---|
| 2026-10-22 | all | first draft | b-tier-b L3 work | pending owner |
| 2026-10-23 | all | D4 recorded as PostHog free tier (no key yet) | owner decision D4 | pending owner |
