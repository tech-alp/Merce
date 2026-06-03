---
phase: 03-manifest-registry-and-loader
plan: 03
subsystem: build
tags: [cmake, qt-resources, generated-themes, manifests]
requires:
  - phase: 03-manifest-registry-and-loader
    provides: basePath-aware generated theme index and generated manifest artifacts
provides:
  - MerceCore-owned generated theme manifest resource packaging
  - configure-time validation for index-listed generated manifests
  - canonical built-in resource path :/merce/themes/index.json
affects: [manifest-loader, runtime-apply, qfile-resource-loading]
tech-stack:
  added: []
  patterns: [target-owned-qt-resource-packaging, index-authoritative-cmake-validation]
key-files:
  created:
    - .planning/phases/03-manifest-registry-and-loader/03-03-SUMMARY.md
  modified:
    - Core/CMakeLists.txt
key-decisions:
  - "MerceCore owns generated theme manifest resources under the fixed /merce/themes prefix."
  - "CMake reads generated/themes/index.json as the authority for basePath, path, and variants manifest files."
patterns-established:
  - "Generated manifest packaging uses qt_add_resources with BASE generated/themes and PREFIX /merce/themes."
  - "Normal configure consumes committed generated files and does not invoke npm or merce_tokens."
requirements-completed: [MANIFEST-01, MANIFEST-02, MANIFEST-05]
duration: 24 min
completed: 2026-06-03
---

# Phase 03 Plan 03: MerceCore Qt Resource Packaging Summary

**MerceCore packages generated theme manifests under `:/merce/themes` with configure-time validation from the generated index**

## Performance

- **Duration:** 24 min
- **Started:** 2026-06-03T19:00:00Z
- **Completed:** 2026-06-03T19:24:28Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- Added CMake configure-time validation for `generated/themes/index.json`.
- Collected manifest files declared by `basePath`, single-theme `path`, and `variants` entries.
- Added clear `message(FATAL_ERROR ...)` failures for missing generated artifacts.
- Packaged the verified generated files into `MerceCore` with `qt_add_resources` under `PREFIX "/merce/themes"` and `BASE "${MERCE_THEME_MANIFEST_DIR}"`.
- Verified generated aliases include `:/merce/themes/index.json`, `merce.default.json`, `merce.light.json`, `merce.dark.json`, and `stripe.json`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Extract And Verify Index-Listed Generated Files In CMake** - `03ce15c` (`build`)
2. **Task 2: Attach Theme Manifests To MerceCore Resources** - `79c15bc` (`build`)

## Files Created/Modified

- `Core/CMakeLists.txt` - Reads the generated theme index, validates listed manifests, and attaches them to `MerceCore` resources.
- `.planning/phases/03-manifest-registry-and-loader/03-03-SUMMARY.md` - Records execution outcome and verification.

## Decisions Made

- Used CMake's `string(JSON ...)` support instead of ad hoc regex parsing.
- Kept generated artifacts committed and consumed directly; normal configure/build does not run Node, npm, or the token build target.
- Added path containment checks for manifest entries so CMake does not package absolute, resource-prefixed, or parent-directory paths from the generated index.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Rejected unsafe manifest paths during CMake validation**
- **Found during:** Task 1 (Extract And Verify Index-Listed Generated Files In CMake)
- **Issue:** The plan required missing-file validation, but a malformed generated index could still point outside the generated theme directory.
- **Fix:** Added configure-time rejection for empty paths, absolute paths, `:/...` resource paths, and `../` escapes before file existence checks.
- **Files modified:** `Core/CMakeLists.txt`
- **Verification:** `cmake -S . -B build -DBUILD_TESTING=ON -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` passed.
- **Committed in:** `03ce15c`

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** The fix strengthens the planned resource aliasing mitigation without expanding runtime scope or adding dependencies.

## Issues Encountered

- `gsd-tools query init.execute-phase 03-manifest-registry-and-loader` resolved an unrelated parent SCS planning project, so execution followed the explicit user-provided plan path under `Merce/.planning`.
- Git post-commit hook warned that Git LFS is configured but `git-lfs` is not available in PATH. The hook did not fail and commits completed.

## Verification

- `cmake -S . -B build -DBUILD_TESTING=ON -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` - passed.
- `cmake --build build --target MerceCore` - passed; output included `Running rcc for resource merce_theme_manifests`.
- `cmake --build build --target MercePlayground` - passed.
- `rg -n "file\\(READ|basePath|variants|message\\(FATAL_ERROR|qt_add_resources\\(MerceCore|PREFIX \"/merce/themes\"" Core/CMakeLists.txt` - passed.
- `rg -n "index\\.json|merce\\.default\\.json|merce\\.light\\.json|merce\\.dark\\.json|stripe\\.json" build/Core/.qt/rcc/qrc_merce_theme_manifests.cpp` - passed and showed `:/merce/themes/...` aliases.
- Stub scan on `Core/CMakeLists.txt` - no stubs found.

## Known Stubs

None.

## Threat Flags

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 3 Plan 04 can now load built-in manifests from `:/merce/themes/index.json` through `QFile` without relying on developer filesystem paths or consumer-owned resources.

## Self-Check: PASSED

- Found `Core/CMakeLists.txt`.
- Found `generated/themes/index.json`.
- Found `generated/themes/merce.default.json`.
- Found `generated/themes/merce.light.json`.
- Found `generated/themes/merce.dark.json`.
- Found `generated/themes/stripe.json`.
- Found task commit `03ce15c`.
- Found task commit `79c15bc`.

---
*Phase: 03-manifest-registry-and-loader*
*Completed: 2026-06-03*
