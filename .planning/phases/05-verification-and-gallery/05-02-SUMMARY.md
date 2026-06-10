---
phase: 05-verification-and-gallery
plan: "02"
subsystem: ui
tags: [qt, qml, playground, theme-gallery, verification]
requires:
  - phase: 04-runtime-brand-mode-switching
    provides: Theme.setTheme public brand/mode switching API
  - phase: 05-verification-and-gallery
    provides: canonical ThemeProbe values from plan 05-01
provides:
  - verification-oriented ThemeGallery component with stable objectName anchors
  - offscreen theme gallery probe route for startup, Merce dark, and Stripe states
  - representative component sample observations for runtime theme consumption
affects: [playground, controls, verification, visual-evidence, phase-05]
tech-stack:
  added: []
  patterns: [separate gallery component, offscreen QML probe route, stable objectName selectors]
key-files:
  created:
    - playground/ThemeGallery.qml
    - playground/ThemeGalleryProbe.qml
  modified:
    - playground/Main.qml
    - playground/main.cpp
    - playground/CMakeLists.txt
    - Controls/MButton.qml
key-decisions:
  - "ThemeGallery stays separate from Main.qml and exposes stable gallery-prefixed anchors."
  - "Gallery/probe use canonical Theme.palette naming while existing non-touched component aliases remain outside this plan."
  - "MButton color bindings were narrowed to direct Theme.palette properties so runtime theme switches are observable by the gallery probe."
patterns-established:
  - "Focused gallery probes wait for animated control color bindings before reading sample observations."
  - "Representative component probes compare sample-observed colors against the active Theme.palette after each runtime switch."
requirements-completed: [VERIFY-02, VERIFY-04]
duration: 31min
completed: 2026-06-04
---

# Phase 05 Plan 02: Gallery And Probe Summary

**Verification gallery with offscreen component-consumption proof for Merce light, Merce dark, and Stripe**

## Performance

- **Duration:** 31 min
- **Started:** 2026-06-04T10:28:00Z
- **Completed:** 2026-06-04T10:59:21Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added `ThemeGallery.qml` as a compact, verification-oriented gallery with active theme, palette, typography, spacing/radius, component samples, and export status sections.
- Integrated the gallery from `Main.qml` without moving gallery implementation into the playground shell.
- Added `ThemeGalleryProbe.qml` and `--theme-gallery-probe` route to verify required anchors and representative sample colors after startup, `merce/dark`, and `stripe`.
- Registered new QML files in `playground/CMakeLists.txt`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Create verification-oriented ThemeGallery** - `62981c7` (`feat(05-02): add theme gallery surface`)
2. **Task 2: Integrate gallery and add offscreen gallery probe route** - `86e7cca` (`feat(05-02): add gallery probe route`)

## Files Created/Modified

- `playground/ThemeGallery.qml` - Gallery UI with stable `merce.playground.gallery.*` anchors.
- `playground/ThemeGalleryProbe.qml` - Offscreen probe for gallery anchors and representative runtime theme observations.
- `playground/Main.qml` - Integrates `ThemeGallery`.
- `playground/main.cpp` - Adds `--theme-gallery-probe` route.
- `playground/CMakeLists.txt` - Registers gallery QML files.
- `Controls/MButton.qml` - Auto-fixed runtime theme color binding for button samples.

## Decisions Made

- Kept qmlagent optional; no qmlagent dependency or CI gate was added.
- Kept the gallery compact and section-based, using existing Merce QML components.
- Used a short wait in `ThemeGalleryProbe.qml` after theme switches so animated color bindings settle before assertions.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] MButton action colors did not refresh through invokable alias access**
- **Found during:** Task 2 (Integrate gallery and add offscreen gallery probe route)
- **Issue:** `MButton.backgroundColor` used `Theme.colors.action.base(variant)`, which did not re-evaluate for the Stripe runtime switch in the gallery probe.
- **Fix:** Switched `MButton` action/accent/background bindings to direct `Theme.palette` property reads for primary, secondary, destructive, and hover states.
- **Files modified:** `Controls/MButton.qml`
- **Verification:** `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-gallery-probe` passed and logged `theme-gallery-probe ok`.
- **Committed in:** `86e7cca`

---

**Total deviations:** 1 auto-fixed (blocking verification gap).
**Impact on plan:** Narrow component fix required for VERIFY-02; no new API or dependency was introduced.

## Issues Encountered

- Offscreen runs warn that `DM Sans` is missing locally; this is an environment font alias warning and did not fail the build/probe.
- Git post-commit hook reported `git-lfs` was not available in PATH, but both commits completed successfully.

## Verification

- `cmake --build build --target MercePlayground` - passed
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test` - passed
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-gallery-probe` - passed, logged `theme-gallery-probe ok`
- `rg -n "objectName: \"merce\\.playground\\.gallery\"|merce\\.playground\\.gallery\\.activeTheme|merce\\.playground\\.gallery\\.palette|merce\\.playground\\.gallery\\.typography|merce\\.playground\\.gallery\\.spacingRadius|merce\\.playground\\.gallery\\.components|merce\\.playground\\.gallery\\.exportStatus" playground/ThemeGallery.qml` - passed
- `rg -n "Theme\\.palette|Theme\\.iconography|Theme\\.breakpoints|Theme\\.setTheme\\(\"merce\", \"light\"\\)|Theme\\.setTheme\\(\"merce\", \"dark\"\\)|Theme\\.setTheme\\(\"stripe\"\\)" playground/ThemeGallery.qml` - passed
- `rg -n "Theme\\.(colors|icons|breakpoint)\\b" playground/ThemeGallery.qml playground/ThemeGalleryProbe.qml` - no matches
- `rg -n "Spix|QQuickStyle|setStyle\\(|qtquickcontrols2\\.conf|Qt6::QuickControls2" playground/Main.qml playground/main.cpp playground/CMakeLists.txt playground/ThemeGallery.qml playground/ThemeGalleryProbe.qml` - no matches

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

05-03 can add deterministic export artifacts and documentation on top of the gallery route, stable objectName anchors, and passing offscreen gallery probe.

---
*Phase: 05-verification-and-gallery*
*Completed: 2026-06-04*
