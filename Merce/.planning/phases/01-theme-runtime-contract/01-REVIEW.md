---
phase: 01-theme-runtime-contract
status: clean
reviewed_at: 2026-06-03T15:05:00Z
review_depth: standard
source_commit: 328ca3f
fix_commit: 80c6266
---

# Phase 1 Code Review

## Verdict

Status: clean after fixes.

The review found two source issues. Both were fixed in `80c6266` and re-verified.

## Findings

### Fixed: downstream package dependency missed Qt6::Gui

- **Severity:** blocker
- **Files:** `MerceConfig.cmake`, `Core/CMakeLists.txt`
- **Issue:** `MerceCore` publicly links `Qt6::Gui` because C++ theme properties expose `QColor`, but exported package config only found `Core Quick Qml`. Consumers using `find_package(Merce)` could miss the `Qt6::Gui` target.
- **Fix:** Added `Gui` to `find_dependency(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)`.
- **Commit:** `80c6266`

### Fixed: destructive action dark variants fell back to primary

- **Severity:** warning
- **Files:** `Core/Theme/MercePalette.h`, `Controls/MButton.qml`
- **Issue:** `MButton` calls `Theme.colors.action.base(variant + "Dark")`. `destructiveDark` was not handled and fell through to primary.
- **Fix:** Added `destructiveDark` and `errorDark` handling in `MercePaletteAction::base()`, returning the destructive color until a darker token is introduced.
- **Commit:** `80c6266`

## Confirmed Clean Areas

- C++ `Theme` registration does not collide with a remaining `Theme.qml`; `build/qml/Merce/Core/qmldir` lists raw token QML files as `internal` and does not list `Theme.qml`.
- `MerceCore.qmltypes` exports only `Merce.Core/Theme 1.0` as a singleton and non-creatable public entrypoint.
- Supporting C++ objects use `QML_ANONYMOUS`, so they are reachable through `Theme` but not creatable as public QML types.
- `NOTIFY` signal surface and `MerceTheme` parent ownership are acceptable for Phase 1 and support later runtime switching.

## Re-Verification

- `cmake --build build --target MercePlayground` - passed.
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe` - passed.
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test` - passed.
- `git diff --check` - passed.
