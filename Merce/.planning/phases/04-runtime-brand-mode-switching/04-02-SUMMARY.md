---
phase: 04-runtime-brand-mode-switching
plan: 02
subsystem: theme-runtime-verification
tags: [qt6, qml, qtest, ctest, runtime-theme-switch]
requires:
  - phase: 04-runtime-brand-mode-switching
    provides: Public Theme.setTheme API, activeBrand/activeMode state, and transactional runtime apply
provides:
  - C++ QtTest coverage for runtime theme switching semantics
  - Focused QML probe for binding-safe runtime switching
  - Source gate proof that Phase 4 avoids Spix and Quick Controls style-family switching
affects: [runtime-theme-switching, verification-gallery, qml-theme-contract]
tech-stack:
  added: []
  patterns: [qtest-runtime-switch-contract, qml-bound-value-probe, stable-theme-object-pointers]
key-files:
  created:
    - tests/Core/tst_merce_theme_runtime_switch.cpp
    - playground/ThemeSwitchProbe.qml
    - .planning/phases/04-runtime-brand-mode-switching/04-02-SUMMARY.md
  modified:
    - tests/Core/CMakeLists.txt
    - playground/CMakeLists.txt
    - playground/main.cpp
key-decisions:
  - "Verify runtime switching through public brand/mode API only; no generated-token public API or QML-visible diagnostics were added."
  - "Use a focused offscreen QML probe instead of a visible selector/gallery so Phase 4 remains dependency-light."
patterns-established:
  - "Runtime switch tests assert stable top-level Theme object pointers plus sub-object NOTIFY contracts."
  - "QML binding probes bind observed values before calling Theme.setTheme so one-shot reads cannot mask invalidation failures."
requirements-completed: [RUNTIME-01, RUNTIME-02, RUNTIME-03, RUNTIME-04]
duration: 8 min
completed: 2026-06-04
---

# Phase 04 Plan 02: Runtime Switch Verification Summary

**QtTest and offscreen QML probe coverage now prove Merce runtime brand/mode switching through the public Theme API**

## Performance

- **Duration:** 8 min
- **Started:** 2026-06-04T07:40:13Z
- **Completed:** 2026-06-04T07:47:51Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added `tst_merce_theme_runtime_switch` as a CTest target covering default state, Merce light/dark switching, Stripe empty mode, invalid preservation, fallback active state, bool returns, pointer stability, and meta-object CONSTANT/NOTIFY expectations.
- Added `ThemeSwitchProbe.qml` to prove a bound `observedBackground: Theme.palette.backgroundBase` updates after `Theme.setTheme("merce", "dark")` while stable Theme sub-object pointers remain unchanged.
- Added `MercePlayground --theme-switch-probe` without changing existing `--theme-probe` behavior or adding Spix, gallery UI, screenshot automation, or Quick Controls style switching.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add QtTest Coverage For Runtime Switching Semantics** - `ff1d3e2` (test)
2. **Task 2: Add Focused QML Binding Probe Route** - `b59f3d9` (test)

**Plan metadata:** skipped (`commit_docs` disabled)

## Files Created/Modified

- `tests/Core/tst_merce_theme_runtime_switch.cpp` - New QtTest suite for runtime switch API/state/pointer/meta contracts.
- `tests/Core/CMakeLists.txt` - Registers `tst_merce_theme_runtime_switch` with `merce_add_qtest`.
- `playground/ThemeSwitchProbe.qml` - New offscreen QML binding probe for runtime switching.
- `playground/CMakeLists.txt` - Packages `ThemeSwitchProbe.qml` in the playground QML module.
- `playground/main.cpp` - Adds `--theme-switch-probe` routing while preserving `--theme-probe`.

## Decisions Made

- Kept verification on the public `Theme.setTheme(brand, mode)` surface; no `lastError`, `usedFallback`, or generated-token API was exposed.
- Kept Phase 4 UI proof as a focused probe instead of a visible selector or gallery because Phase 5 owns gallery-level verification.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Added `QtQuick` import for QML color property support**
- **Found during:** Task 2 (Add Focused QML Binding Probe Route)
- **Issue:** `ThemeSwitchProbe.qml` used the required object-scope `property color observedBackground`, but the QML engine reported `color is not a type` with only `QtQml` imported.
- **Fix:** Added `import QtQuick` to the focused probe. This uses the existing playground Qt Quick runtime and does not introduce Qt Quick Controls style switching.
- **Files modified:** `playground/ThemeSwitchProbe.qml`
- **Verification:** `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe` passed and logged `theme-switch-probe ok`.
- **Committed in:** `b59f3d9`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The fix was required for probe correctness and did not expand Phase 4 scope.

## Issues Encountered

- Initial `cmake --build build --target tst_merce_theme_runtime_switch` failed because the existing build directory had not been reconfigured after adding the new CTest target. Running `cmake -S . -B build` refreshed the build graph, then the focused target built successfully.
- Git post-commit hook warned that Git LFS is configured but `git-lfs` is not available in PATH. The hook did not fail and both task commits completed.
- Some GSD state helpers are not compatible with this repository's current `STATE.md` schema: `state.advance-plan`, `state.update-progress`, and `state.record-session` reported missing fields. `roadmap.update-plan-progress`, `requirements.mark-complete`, `state.record-metric`, and `state.add-decision` completed or found requirements already complete.

## Verification

- `cmake -S . -B build` - passed.
- `cmake --build build --target tst_merce_theme_runtime_switch` - passed.
- `ctest --test-dir build -R tst_merce_theme_runtime_switch --output-on-failure` - passed.
- `cmake --build build --target MercePlayground` - passed.
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe` - passed with `theme-switch-probe ok stripe  #f6f9fc`.
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe` - passed with `theme-probe ok #faf8f6 #faf8f6 16 12 DM Sans 20`.
- `ctest --test-dir build --output-on-failure` - passed, 3/3 tests.
- `! rg -n "Spix|QQuickStyle|setStyle\\(|qtquickcontrols2\\.conf|Qt6::QuickControls2|Theme\\.lastError|Theme\\.usedFallback" playground Core/Theme CMakeLists.txt` - passed, no matches.
- `git diff --check -- tests/Core/CMakeLists.txt tests/Core/tst_merce_theme_runtime_switch.cpp playground/CMakeLists.txt playground/main.cpp playground/ThemeSwitchProbe.qml` - passed.

## Known Stubs

None. The empty string check in `ThemeSwitchProbe.qml` is intentional coverage for Stripe's single-manifest empty mode.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 4 runtime switching is now covered from C++ and QML. Phase 5 can build broader gallery or visual verification on top of the proven public switch API without adding runtime style-family switching.

## Self-Check: PASSED

- Found `tests/Core/tst_merce_theme_runtime_switch.cpp`.
- Found `playground/ThemeSwitchProbe.qml`.
- Found `.planning/phases/04-runtime-brand-mode-switching/04-02-SUMMARY.md`.
- Found task commit `ff1d3e2`.
- Found task commit `b59f3d9`.

---
*Phase: 04-runtime-brand-mode-switching*
*Completed: 2026-06-04*
