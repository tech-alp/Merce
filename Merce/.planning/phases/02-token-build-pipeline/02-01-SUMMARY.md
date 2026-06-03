---
phase: 02-token-build-pipeline
plan: 01
subsystem: tooling
tags: [dtcg, style-dictionary, tokens, manifest, cmake]
requires:
  - phase: 01-theme-runtime-contract
    provides: typed C++ Theme runtime contract and shallow semantic API shape
provides:
  - DTCG token source workspace under tools/design-tokens
  - Style Dictionary v5 manifest build pipeline
  - Sparse generated theme index and runtime manifests
  - Manifest validation and deterministic generated-output check scripts
  - Optional default-off CMake token build target
affects: [manifest-registry, runtime-loader, theme-switching, verification-gallery]
tech-stack:
  added: [style-dictionary-v5, node-tooling]
  patterns: [dtcg-source-tokens, sparse-theme-registry, generated-runtime-manifests]
key-files:
  created:
    - tools/design-tokens/package.json
    - tools/design-tokens/build.mjs
    - tools/design-tokens/src/theme-registry.mjs
    - tools/design-tokens/src/merce-manifest-format.mjs
    - tools/design-tokens/src/validate-manifest.mjs
    - tools/design-tokens/src/check-generated.mjs
    - tools/design-tokens/themes.json
    - generated/themes/index.json
    - generated/themes/merce.light.json
    - generated/themes/merce.dark.json
    - generated/themes/stripe.json
  modified:
    - CMakeLists.txt
    - .gitignore
key-decisions:
  - "Use generated/themes/index.json as the authoritative physical manifest path registry."
  - "Keep Style Dictionary and npm under tools/design-tokens as build/developer tooling only."
  - "Emit shallow Merce runtime manifest sections and avoid generated QML token APIs."
patterns-established:
  - "Theme entries use sparse registry semantics: single themes use path, variant themes use defaultVariant plus variants."
  - "Generated manifest checks validate schemaVersion, required semantic fields, and absence of raw DTCG output."
requirements-completed: [TOKENS-01, TOKENS-02, TOKENS-03, TOKENS-04, TOKENS-05]
duration: 55 min
completed: 2026-06-03
---

# Phase 2 Plan 1: Style Dictionary Token Build Pipeline Summary

**DTCG token sources and Style Dictionary v5 tooling now generate validated Merce runtime manifests with sparse theme and variant support**

## Performance

- **Duration:** 55 min
- **Started:** 2026-06-03T16:33:00Z
- **Completed:** 2026-06-03T17:28:32Z
- **Tasks:** 6
- **Files modified:** 24

## Accomplishments

- Added a bounded npm workspace under `tools/design-tokens` with Style Dictionary v5 locked by `package-lock.json`.
- Added DTCG core, Merce light/dark, and Stripe single-manifest source tokens using `$value` and `$type`.
- Implemented a Style Dictionary build that emits `generated/themes/index.json`, `merce.light.json`, `merce.dark.json`, and `stripe.json`.
- Added manifest validation and deterministic generated-output checking with no extra schema dependency.
- Added `MERCE_ENABLE_TOKEN_BUILD`, default `OFF`, so normal Qt configure/build does not require Node.
- Documented sparse theme registry semantics and the AI-assisted `DESIGN.md` to DTCG candidate workflow.

## Task Commits

1. **Task 1: Create bounded token tooling workspace** - `9769145` (`chore`)
2. **Task 2: Add DTCG token sources and sparse theme registry** - `69ee669` (`feat`)
3. **Task 3: Implement Style Dictionary build and Merce manifest formatter** - `0b2eb89` (`feat`)
4. **Task 4: Add manifest validation and deterministic output checks** - `5eea5ea` (`feat`)
5. **Task 5: Add optional CMake token build target** - `97d27bb` (`chore`)
6. **Task 6: Document manifest contract and AI-assisted fixture workflow** - `a407a0a` (`docs`)

## Files Created/Modified

- `tools/design-tokens/package.json` - npm scripts and Style Dictionary v5 dependency.
- `tools/design-tokens/package-lock.json` - reproducible dependency lockfile.
- `tools/design-tokens/themes.json` - sparse theme registry with Merce variants and Stripe single-manifest theme.
- `tools/design-tokens/tokens/` - DTCG source tokens for palette, spacing, radius, typography, and theme overrides.
- `tools/design-tokens/build.mjs` - Style Dictionary build entrypoint.
- `tools/design-tokens/src/theme-registry.mjs` - registry loading and generated index formatting.
- `tools/design-tokens/src/merce-manifest-format.mjs` - Merce runtime manifest formatter.
- `tools/design-tokens/src/validate-manifest.mjs` - manifest validator.
- `tools/design-tokens/src/check-generated.mjs` - deterministic generated-output checker.
- `generated/themes/*.json` - committed generated manifest artifacts.
- `CMakeLists.txt` - optional `merce_tokens` custom target.
- `tools/design-tokens/README.md` - manifest/tooling documentation.
- `tools/design-tokens/prompts/design-md-to-dtcg.md` - AI-assisted fixture prompt.
- `.gitignore` - excludes local token workspace `node_modules`.

## Decisions Made

- `generated/themes/index.json` is the authoritative path registry; Phase 3 should not derive physical file names from `theme` and `variant`.
- Single-manifest themes do not receive a fabricated variant. `stripe.json` has `theme: "stripe"` and no `variant`.
- Generated manifests use shallow semantic runtime fields like `palette.textPrimary`, `spacing.md`, `radius.button`, and `typography.bodyFont`.
- The validator stays dependency-free for now because the required schema is small and explicit.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added root ignore for token workspace dependencies**
- **Found during:** Task 1
- **Issue:** `npm install` created `tools/design-tokens/node_modules`, and the repo had no root `.gitignore`.
- **Fix:** Added `.gitignore` entry for `tools/design-tokens/node_modules/`.
- **Files modified:** `.gitignore`
- **Verification:** `git status --short` no longer lists `node_modules`.
- **Committed in:** `9769145`

---

**Total deviations:** 1 auto-fixed.
**Impact on plan:** No scope creep. The change prevents vendoring local npm dependencies while preserving the required committed lockfile.

## Issues Encountered

- Initial sandboxed `npm install` failed with DNS resolution for `registry.npmjs.org`; reran with approved network access and generated `package-lock.json`.
- Fresh `build-tokens` configure initially could not find Qt6 because the new build directory had no `CMAKE_PREFIX_PATH`; reran with `/Users/techalp/Qt/6.11.1/macos` from the existing build cache.
- Style Dictionary reports token collision warnings during build because theme and variant source files intentionally override core token paths. The explicit source order is core first, theme second, variant last.

## Verification

- `cd tools/design-tokens && npm install` - passed after approved registry access.
- `cd tools/design-tokens && npm run build` - passed.
- `cd tools/design-tokens && npm run validate` - passed.
- `cd tools/design-tokens && npm run check` - passed.
- `node tools/design-tokens/src/validate-manifest.mjs generated/themes/stripe.json` - passed.
- Validator negative checks for missing `schemaVersion` and missing `palette.textPrimary` - passed.
- `cmake -S . -B build -DMERCE_ENABLE_TOKEN_BUILD=OFF` - passed.
- `cmake --build build --target MercePlayground` - passed.
- `cmake -S . -B build-tokens -DMERCE_ENABLE_TOKEN_BUILD=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` - passed.
- `cmake --build build-tokens --target merce_tokens` - passed.
- `git diff --check` - passed.
- `rg -n '"defaultMode"|"colors"' generated/themes tools/design-tokens/themes.json` - no matches.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 3 can consume `generated/themes/index.json` as the authoritative registry and package the generated manifests into Qt resources. The C++ loader should validate `schemaVersion`, required manifest sections, known theme/variant entries, and fallback behavior without re-parsing raw DTCG token sources.

---
*Phase: 02-token-build-pipeline*
*Completed: 2026-06-03*
