---
phase: 03-manifest-registry-and-loader
plan: 02
subsystem: token-tooling
tags: [style-dictionary, manifest-registry, basepath, generated-themes]
requires:
  - phase: 02-token-build-pipeline
    provides: generated runtime manifests and sparse theme registry tooling
  - phase: 03-manifest-registry-and-loader
    provides: main-repo test harness for future loader validation
provides:
  - basePath-aware generated theme index
  - resolved Merce base manifest artifact
  - generated artifact validation coverage for basePath manifests
  - documented Phase 3 manifest-backed section boundary
affects: [manifest-loader, resource-packaging, runtime-apply]
tech-stack:
  added: []
  patterns: [base-manifest-entry, basepath-index-metadata, section-support-boundary]
key-files:
  created:
    - generated/themes/merce.default.json
  modified:
    - tools/design-tokens/themes.json
    - tools/design-tokens/src/theme-registry.mjs
    - tools/design-tokens/src/validate-manifest.mjs
    - generated/themes/index.json
    - tools/design-tokens/README.md
key-decisions:
  - "Merce declares basePath as merce.default.json while light and dark remain variant manifests."
  - "The base manifest is generated from core plus Merce theme sources and intentionally has no variant identity."
  - "Phase 3 runtime apply is limited to palette, spacing, radius, and typography; motion, iconography, zIndex, breakpoints, and shadows remain construction defaults."
patterns-established:
  - "Variant-backed themes may emit an additional base manifest entry before variant entries."
  - "Directory validation must validate basePath manifests as single-manifest theme outputs."
requirements-completed: [MANIFEST-01, MANIFEST-02, MANIFEST-04]
duration: 18 min
completed: 2026-06-03
---

# Phase 03 Plan 02: Generated Index BasePath And Merce Base Manifest Summary

**basePath-aware generated registry with resolved Merce base manifest artifacts for loader overlay**

## Performance

- **Duration:** 18 min
- **Started:** 2026-06-03T18:58:00Z
- **Completed:** 2026-06-03T19:16:04Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added `basePath: "merce.default.json"` to the Merce theme registry source.
- Updated `themeEntries(registry)` to emit a variantsiz Merce base manifest entry from core plus theme sources, while keeping light/dark variant entries intact.
- Updated `generatedIndex(registry)` so Merce index metadata includes `displayName`, `basePath`, `defaultVariant`, and `variants`; Stripe keeps single-manifest `path` semantics.
- Regenerated `generated/themes/index.json` and created `generated/themes/merce.default.json`.
- Documented the Phase 3 supported-section boundary in `tools/design-tokens/README.md`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Emit basePath From The Generated Registry** - `bf9e83c` (`feat`)
2. **Task 2: Regenerate Artifacts And Document Supported Sections** - `c3eabef` (`feat`)

## Files Created/Modified

- `tools/design-tokens/themes.json` - Adds Merce `basePath` registry metadata.
- `tools/design-tokens/src/theme-registry.mjs` - Emits optional base manifest entries and preserves `basePath` in generated index metadata.
- `tools/design-tokens/src/validate-manifest.mjs` - Validates `basePath` manifests during generated directory validation.
- `generated/themes/index.json` - Adds `themes.merce.basePath` while preserving Stripe `path`.
- `generated/themes/merce.default.json` - Resolved Merce base manifest with schemaVersion 1, theme `merce`, and no `variant` field.
- `tools/design-tokens/README.md` - Documents `basePath` and the Phase 3 manifest-backed section boundary.

## Decisions Made

- Kept Style Dictionary as the build-time resolver; no runtime DTCG alias/reference resolution was introduced.
- Generated `merce.default.json` from core plus Merce theme sources only, so the loader can overlay active variants section-by-section later.
- Expanded build-time validation to include `basePath` artifacts so `npm run validate` covers the new generated file.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Validated basePath manifests in directory validation**
- **Found during:** Task 1 (Emit basePath From The Generated Registry)
- **Issue:** `npm run validate` walked variant and single `path` manifests, but would not validate a new `basePath` artifact from `generated/themes/index.json`.
- **Fix:** Added `entry.basePath` validation as a single-manifest theme output with no variant identity.
- **Files modified:** `tools/design-tokens/src/validate-manifest.mjs`
- **Verification:** `npm run validate`, `npm run check`, and direct `node tools/design-tokens/src/validate-manifest.mjs generated/themes/merce.default.json` all passed.
- **Committed in:** `bf9e83c`

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Validation now covers the new artifact declared by the generated index. No runtime or dependency scope was expanded.

## Issues Encountered

- Shell startup printed permission warnings for `/Users/techalp/.cache/oh-my-zsh` and `.zcompdump` cleanup. Token commands still completed successfully.
- Style Dictionary printed token collision warnings while generating known override layers. The commands returned success and `npm run check` confirmed committed artifacts match generated output.
- Git post-commit hook warned that Git LFS is configured but `git-lfs` is not available in PATH. The hook did not fail and commits completed.

## Verification

- `npm run build` from `tools/design-tokens` - passed.
- `node tools/design-tokens/src/validate-manifest.mjs generated/themes/merce.default.json` - passed.
- `npm run validate` from `tools/design-tokens` - passed.
- `npm run check` from `tools/design-tokens` - passed.
- `test -f generated/themes/merce.default.json` - passed.
- `rg -n '"basePath": "merce.default.json"|"path": "stripe.json"' generated/themes/index.json` - passed.
- `rg -n '"variant"' generated/themes/merce.default.json generated/themes/merce.light.json generated/themes/merce.dark.json` - showed variants only in light/dark manifests.
- Stub scan on modified files - no UI/data-source stubs found; only local empty accumulator initializers in JS validation/generator code matched the generic pattern.

## Known Stubs

None.

## Threat Flags

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 3 resource packaging can now package `generated/themes/index.json`, `generated/themes/merce.default.json`, `generated/themes/merce.light.json`, `generated/themes/merce.dark.json`, and `generated/themes/stripe.json` under `:/merce/themes/`.

## Self-Check: PASSED

- Found `generated/themes/index.json`.
- Found `generated/themes/merce.default.json`.
- Found `tools/design-tokens/themes.json`.
- Found `tools/design-tokens/src/theme-registry.mjs`.
- Found `tools/design-tokens/src/validate-manifest.mjs`.
- Found `tools/design-tokens/README.md`.
- Found task commit `bf9e83c`.
- Found task commit `c3eabef`.

---
*Phase: 03-manifest-registry-and-loader*
*Completed: 2026-06-03*
