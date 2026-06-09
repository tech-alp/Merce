---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: Ready to execute
last_updated: "2026-06-04T10:44:43.333Z"
progress:
  total_phases: 5
  completed_phases: 4
  total_plans: 12
  completed_plans: 9
  percent: 80
---

# State: Merce Theme Runtime

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-06-04)

**Core value:** QML application and component authors can use a stable, typed `Theme` API while brands and modes are driven from validated token manifests.
**Current focus:** Phase 05 — verification-and-gallery

## Status

Phase 4 is complete. MerceTheme now exposes runtime brand/mode switching through `Theme.setTheme(brand, mode)`, reports active brand/mode state, preserves stable Theme object pointers, and has QtTest plus offscreen QML probe coverage.

## Phase Status

| Phase | Name | Status | Plans |
|-------|------|--------|-------|
| 1 | Theme Runtime Contract | Complete | 1/1 |
| 2 | Token Build Pipeline | Complete | 1/1 |
| 3 | Manifest Registry And Loader | Complete | 5/5 |
| 4 | Runtime Brand/Mode Switching | Complete | 2/2 |
| 5 | Verification And Gallery | Planned | 3/3 |

## Decisions

- 2026-06-03: Use C++ as the theme runtime direction because it improves type safety, public/private type control, runtime switching, and QML tooling behavior.
- 2026-06-03: Keep DTCG as source format and Style Dictionary v5 as build-time resolver/converter.
- 2026-06-03: Use `:/merce/themes/{brand}/{mode}.json` plus `:/merce/themes/index.json` for multi-brand resources.
- 2026-06-03: `Theme` is exported from C++ as `Merce.Core/Theme`; `Theme.colors` remains a compatibility alias to the preferred `Theme.palette` API.
- 2026-06-03: Supporting theme objects are anonymous QML types and should be reached through `Theme`, not created by consumers.
- 2026-06-03: Treat `generated/themes/index.json` as the authoritative physical manifest path registry; loaders should not derive paths from theme and variant names.
- 2026-06-03: Merce generated index entries may include `basePath` for a resolved base manifest that loaders apply before the active variant.
- 2026-06-03: Phase 3 manifest-backed apply is constrained to palette, spacing, radius, and typography; motion, iconography, zIndex, breakpoints, and shadows remain construction defaults.
- 2026-06-03: MerceCore owns generated theme manifest resources under `:/merce/themes`; CMake reads `generated/themes/index.json` for `basePath`, `path`, and `variants`.
- 2026-06-03: MerceTheme applies the validated default manifest during construction and leaves construction defaults intact on default load failure.
- 2026-06-03: ThemeProbe verifies typography through existing `Theme.typography.fontBody` to preserve the Phase 1 public API.
- [Phase 04]: Expose Theme runtime switching with public brand/mode terminology while delegating registry lookup to MerceThemeManifestLoader. — Preserves the stable QML API and avoids deriving manifest paths from caller input.
- [Phase 04]: Phase 04 Plan 02 verifies runtime switching through public brand/mode API only, with no generated-token public API or QML-visible diagnostics. — Keeps Phase 4 scoped to test/probe verification and preserves the public Theme contract.

## Last Activity

- 2026-06-03: Initialized GSD planning artifacts manually because `gsd-sdk` was not available in PATH.
- 2026-06-03: Planned Phase 1 in GSD 1.2 format at `.planning/phases/01-theme-runtime-contract/01-PLAN.md`.
- 2026-06-03: Executed Phase 1, committed `328ca3f`, and wrote `.planning/phases/01-theme-runtime-contract/01-SUMMARY.md`.
- 2026-06-03: Executed Phase 2, committed token build pipeline tasks through `a407a0a`, and wrote `.planning/phases/02-token-build-pipeline/02-01-SUMMARY.md`.
- 2026-06-03: Executed Phase 3 Plan 01, committed test harness tasks through `d9a649d`, and wrote `.planning/phases/03-manifest-registry-and-loader/03-01-SUMMARY.md`.
- 2026-06-03: Executed Phase 3 Plan 02, committed generated registry tasks through `c3eabef`, and wrote `.planning/phases/03-manifest-registry-and-loader/03-02-SUMMARY.md`.
- 2026-06-03: Executed Phase 3 Plan 03, committed resource packaging tasks through `79c15bc`, and wrote `.planning/phases/03-manifest-registry-and-loader/03-03-SUMMARY.md`.
- 2026-06-03: Executed Phase 3 Plan 04, committed manifest registry/loader tests through `27280d5`, and wrote `.planning/phases/03-manifest-registry-and-loader/03-04-SUMMARY.md`.
- 2026-06-03: Executed Phase 3 Plan 05, committed default manifest apply and probe verification through `c22b0e8`, and wrote `.planning/phases/03-manifest-registry-and-loader/03-05-SUMMARY.md`.
- 2026-06-04: Planned Phase 4 with 2 executable plans for runtime switch API and verification/probe coverage.
- 2026-06-04: Executed Phase 4, committed runtime switching and verification tasks through `b59f3d9`, wrote `04-VERIFICATION.md`, and advanced to Phase 5 planning.
- 2026-06-04: Planned Phase 5 with 3 executable plans for verification hardening, gallery UI/probes, and visual evidence documentation.

## Performance Metrics

| Phase | Plan | Duration | Notes |
|-------|------|----------|-------|
| Phase 01 P01 | 29 min | 6 tasks | 46 files |
| Phase 02 P01 | 55 min | 6 tasks | 24 files |
| Phase 03 P01 | 34 min | 2 tasks | 4 files |
| Phase 03 P02 | 18 min | 2 tasks | 6 files |
| Phase 03 P03 | 24 min | 2 tasks | 1 file |
| Phase 03 P04 | 6 min | 3 tasks | 8 files |
| Phase 03 P05 | 9 min | 3 tasks | 6 files |
| Phase 04 P01 | 6 min | 2 tasks | 3 files |
| Phase 04 P02 | 8 min | 2 tasks | 6 files |
