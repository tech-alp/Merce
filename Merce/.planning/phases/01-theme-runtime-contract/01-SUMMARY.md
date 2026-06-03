---
phase: 01-theme-runtime-contract
plan: 01
subsystem: qt-qml-theme-runtime
tags: [qt6, qml, cmake, theme, design-system]
requires: []
provides:
  - C++ registered Merce.Core Theme singleton
  - Typed theme sub-objects for palette, spacing, radius, typography, motion, iconography, z-index, breakpoints, and shadows
  - Compatibility paths for existing Theme.colors, Theme.spacing, Theme.radius, Theme.typography, Theme.motion, Theme.icons, Theme.zIndex, Theme.breakpoint, and Theme.shadows usage
  - Executable playground theme probe
affects: [token-build-pipeline, manifest-loader, runtime-theme-switching, verification-gallery]
tech-stack:
  added: [Qt6::Gui, QML_SINGLETON, QML_ANONYMOUS]
  patterns: [cpp-qml-singleton-theme, typed-qobject-token-groups, compatibility-facade]
key-files:
  created:
    - Core/Theme/MerceTheme.h
    - Core/Theme/MerceTheme.cpp
    - Core/Theme/MercePalette.h
    - Core/Theme/MerceSpacing.h
    - Core/Theme/MerceRadius.h
    - Core/Theme/MerceTypography.h
    - Core/Theme/MerceMotion.h
    - Core/Theme/MerceIconography.h
    - Core/Theme/MerceZIndex.h
    - Core/Theme/MerceBreakpoints.h
    - Core/Theme/MerceShadows.h
    - playground/ThemeProbe.qml
  modified:
    - CMakeLists.txt
    - Core/CMakeLists.txt
key-decisions:
  - "Theme is now exported from C++ as the Merce.Core/Theme singleton; Theme.qml is removed from the public module."
  - "colors remains an alias to palette for incremental compatibility, while palette is the preferred shallow API."
  - "Supporting token objects are QML_ANONYMOUS and reachable only through Theme."
  - "Shadows are retained as a typed compatibility object because Foundation/MSurface already consumes Theme.shadows."
patterns-established:
  - "Runtime theme values live behind QObject properties with NOTIFY signals so later manifest/runtime switching can reuse the same API."
  - "QML token files can remain internal reference/default files, but the public singleton contract is C++ owned."
requirements-completed: [THEME-01, THEME-02, THEME-03, THEME-04, THEME-05]
duration: 29 min
completed: 2026-06-03
---

# Phase 1 Plan 1: C++ Theme Runtime Contract Summary

**C++ registered Merce theme singleton with typed token objects, shallow palette aliases, and retained QML compatibility paths**

## Performance

- **Duration:** 29 min
- **Started:** 2026-06-03T14:26:36Z
- **Completed:** 2026-06-03T14:55:18Z
- **Tasks:** 6/6 complete
- **Files modified:** 46 in production commit, including pre-existing uncommitted Merce module scaffold needed for the verified build

## Accomplishments

- Replaced the public QML-owned `Theme.qml` singleton with C++ `MerceTheme` exported as `Merce.Core/Theme 1.0`.
- Added typed QObject token groups for palette/colors, spacing, radius, typography, motion, icons, z-index, breakpoints, and shadows.
- Preserved existing component-facing compatibility paths such as `Theme.colors.background.base`, `Theme.spacing.md`, `Theme.radius.button`, `Theme.typography.body`, `Theme.icons.small`, and `Theme.shadows.card`.
- Added shallow new API paths including `Theme.palette.backgroundBase`, `Theme.palette.textPrimary`, `Theme.palette.actionPrimary`, `Theme.palette.borderBase`, and `Theme.palette.statusError`.
- Updated the executable playground probe to validate both the new shallow API and retained compatibility paths.

## Task Commits

1. **Task 1: Audit Current Theme Surface** - covered by implementation review; no code-only commit.
2. **Tasks 2-5: C++ runtime, registration, compatibility, probe, and build verification** - `328ca3f` (`feat(01-01)`)
3. **Code review fixes** - `80c6266` (`fix(01-01)`)
4. **Task 6: Runtime contract documentation** - this SUMMARY and tracking metadata commit.

## Files Created/Modified

- `Core/Theme/MerceTheme.h` / `Core/Theme/MerceTheme.cpp` - C++ QML singleton owner and public Theme entrypoint.
- `Core/Theme/MercePalette.h` - palette groups, compatibility `colors` object shape, and shallow semantic aliases.
- `MerceConfig.cmake` - exported package dependency list includes `Qt6::Gui` for downstream consumers.
- `Core/Theme/MerceSpacing.h`, `MerceRadius.h`, `MerceTypography.h`, `MerceMotion.h`, `MerceIconography.h`, `MerceZIndex.h`, `MerceBreakpoints.h` - typed token sub-objects.
- `Core/Theme/MerceShadows.h` - typed compatibility object for existing `Theme.shadows.*` consumers.
- `Core/CMakeLists.txt` - registers C++ theme sources in `MerceCore` and keeps raw QML token files internal.
- `Core/Theme.qml` - removed to avoid duplicate public `Theme` registration.
- `playground/ThemeProbe.qml` - verifies shallow and compatibility runtime values.

## Decisions Made

- Use `QML_NAMED_ELEMENT(Theme)` + `QML_SINGLETON` for the public singleton because Qt's type compiler then emits `Merce.Core/Theme 1.0` metadata and avoids a QML file singleton collision.
- Use `QML_ANONYMOUS` supporting objects so QML can inspect them as property types but consumers cannot instantiate them directly.
- Keep `Theme.colors` as an alias of `Theme.palette`; this avoids broad component rewrites in Phase 1 while giving new code a shallow `Theme.palette.*` path.
- Use `QVariantMap` for typography and motion presets in Phase 1 because existing QML components expect JS-object-like preset access.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added typed shadows compatibility**
- **Found during:** Task 1 audit / Task 2 implementation
- **Issue:** `Foundation/MSurface.qml` consumes `Theme.shadows.card` and `Theme.shadows.none`, but the plan's typed object list did not include a shadows class.
- **Fix:** Added `MerceShadows` and `Theme.shadows` so existing consumers keep working.
- **Files modified:** `Core/Theme/MerceShadows.h`, `Core/Theme/MerceTheme.h`, `Core/Theme/MerceTheme.cpp`, `Core/CMakeLists.txt`
- **Verification:** `cmake --build build --target MercePlayground`, `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test`
- **Committed in:** `328ca3f`

**2. [Rule 3 - Blocking] Added explicit Qt6::Gui linkage for QColor-based runtime values**
- **Found during:** Task 3 build verification
- **Issue:** C++ theme properties use `QColor`, which belongs to Qt Gui.
- **Fix:** Added `Gui` to the Qt package components and linked `MerceCore` against `Qt6::Gui`.
- **Files modified:** `CMakeLists.txt`, `Core/CMakeLists.txt`
- **Verification:** `cmake -S . -B build -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos`
- **Committed in:** `328ca3f`

---

**Total deviations:** 2 auto-fixed (1 missing critical compatibility object, 1 blocking build/link dependency)
**Impact on plan:** Both changes preserve the stated runtime contract and avoid breaking existing QML components. No generated token or manifest work was introduced.

## Verification

- `cmake -S . -B build -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` - passed.
- `cmake --build build --target MercePlayground` - passed.
- `./build/playground/MercePlayground --theme-probe` - passed with `theme-probe ok #faf8f6 #faf8f6 16 12 20`.
- `./build/playground/MercePlayground --smoke-test` - failed in this headless shell with `Cannot create window: no screens available`.
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test` - passed; emitted only a missing `DM Sans` font alias warning.
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe` - passed.
- `git diff --check` - passed.
- `rg -n "Theme\\.colors|Theme\\.palette|Theme\\.spacing|Theme\\.radius|Theme\\.typography" Core Controls Foundation playground -g '*.qml'` - reviewed after implementation.
- Code review found two issues and both were fixed in `80c6266`; see `01-REVIEW.md`.

## Issues Encountered

- Git post-commit hook warned that Git LFS is configured but `git-lfs` is not on PATH. The production commit still completed successfully.
- The working tree already contained uncommitted Merce module/playground source scaffold before this execution. To keep a clean checkout buildable, the production commit includes the derlenen Merce source surface needed by the verified build while leaving unrelated upper-directory, IDE, external, and tooling files uncommitted.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 2 can map Style Dictionary output to the C++ runtime properties from `Core/Theme/`. The target public API is now `Theme.palette.*` for new code, with retained compatibility through `Theme.colors.*` while component migration remains incremental.

---
*Phase: 01-theme-runtime-contract*
*Completed: 2026-06-03*
