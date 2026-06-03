---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: ready_to_plan
last_updated: "2026-06-03T17:29:29.998Z"
progress:
  total_phases: 5
  completed_phases: 2
  total_plans: 2
  completed_plans: 2
  percent: 40
---

# State: Merce Theme Runtime

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-06-03)

**Core value:** QML application and component authors can use a stable, typed `Theme` API while brands and modes are driven from validated token manifests.
**Current focus:** Phase 3 — manifest registry and loader

## Status

Phase 2 is complete. DTCG token sources and Style Dictionary v5 tooling now generate validated Merce runtime manifests; Phase 3 is ready to package and load them through the generated index.

## Phase Status

| Phase | Name | Status | Plans |
|-------|------|--------|-------|
| 1 | Theme Runtime Contract | Complete | 1/1 |
| 2 | Token Build Pipeline | Complete | 1/1 |
| 3 | Manifest Registry And Loader | Not started | 0 |
| 4 | Runtime Brand/Mode Switching | Not started | 0 |
| 5 | Verification And Gallery | Not started | 0 |

## Decisions

- 2026-06-03: Use C++ as the theme runtime direction because it improves type safety, public/private type control, runtime switching, and QML tooling behavior.
- 2026-06-03: Keep DTCG as source format and Style Dictionary v5 as build-time resolver/converter.
- 2026-06-03: Use `:/merce/themes/{brand}/{mode}.json` plus `:/merce/themes/index.json` for multi-brand resources.
- 2026-06-03: `Theme` is exported from C++ as `Merce.Core/Theme`; `Theme.colors` remains a compatibility alias to the preferred `Theme.palette` API.
- 2026-06-03: Supporting theme objects are anonymous QML types and should be reached through `Theme`, not created by consumers.
- 2026-06-03: Treat `generated/themes/index.json` as the authoritative physical manifest path registry; loaders should not derive paths from theme and variant names.

## Last Activity

- 2026-06-03: Initialized GSD planning artifacts manually because `gsd-sdk` was not available in PATH.
- 2026-06-03: Planned Phase 1 in GSD 1.2 format at `.planning/phases/01-theme-runtime-contract/01-PLAN.md`.
- 2026-06-03: Executed Phase 1, committed `328ca3f`, and wrote `.planning/phases/01-theme-runtime-contract/01-SUMMARY.md`.
- 2026-06-03: Executed Phase 2, committed token build pipeline tasks through `a407a0a`, and wrote `.planning/phases/02-token-build-pipeline/02-01-SUMMARY.md`.

## Performance Metrics

| Phase | Plan | Duration | Notes |
|-------|------|----------|-------|
| Phase 01 P01 | 29 min | 6 tasks | 46 files |
| Phase 02 P01 | 55 min | 6 tasks | 24 files |
