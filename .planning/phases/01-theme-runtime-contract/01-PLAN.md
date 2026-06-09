---
phase: 1
plan: 1
plan_name: Cpp Theme Runtime Contract
type: implementation
wave: 1
depends_on: []
files_modified:
  - Core/CMakeLists.txt
  - Core/Theme.qml
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
  - playground/ThemeProbe.qml
autonomous: false
requirements:
  - THEME-01
  - THEME-02
  - THEME-03
  - THEME-04
  - THEME-05
---

# Plan 01: C++ Theme Runtime Contract

<objective>
Replace the public QML-only `Theme` singleton with a C++-registered `Theme` singleton that exposes typed supporting objects, while preserving enough of the current QML surface for existing Merce components to keep working during incremental migration.
</objective>

<scope>
## In Scope

- Add the first C++ theme runtime classes under `Core/Theme/`.
- Register the public QML singleton as `Merce.Core.Theme`.
- Expose typed sub-objects for palette, spacing, radius, typography, motion, iconography, z-index, and breakpoints.
- Keep supporting classes non-creatable from consumer QML.
- Seed C++ values from the current QML token defaults.
- Add shallow semantic palette aliases such as `Theme.palette.textPrimary`.
- Preserve compatibility with existing component usage such as `Theme.colors.text.primary`, `Theme.spacing.md`, `Theme.radius.button`, and `Theme.typography.body`.
- Update the probe so Phase 1 proves values come through the C++ runtime.

## Out of Scope

- DTCG JSON source files.
- Style Dictionary v5 build pipeline.
- Resource manifest loading.
- Real multi-brand or light/dark switching.
- Broad component rewrite away from `Theme.colors.*`.
- Qt Quick Controls style family switching.
</scope>

<truths>
- D-01: Theme runtime moves to C++ for type safety and public API control.
- D-02: Supporting theme structures are exposed only through `Theme`.
- D-03: New public API should avoid unnecessary deep chains.
- D-04: Migration must be incremental because components already use `Theme`.
- D-05: Raw DTCG paths, generated manifests, and generated token objects stay internal.
- D-06: Runtime-updatable values need `NOTIFY` signals.
- D-07: Runtime changes affect Merce semantic values, not Qt Quick Controls style families.
</truths>

<tasks>
## Task 1 - Audit Current Theme Surface

type: inspect
files:
- `Core/Theme.qml`
- `Core/Palette.qml`
- `Core/Spacing.qml`
- `Core/Radius.qml`
- `Core/Typography.qml`
- `Core/Motion.qml`
- `Core/Iconography.qml`
- `Core/ZIndex.qml`
- `Core/Breakpoints.qml`
- `Controls/*.qml`
- `Foundation/*.qml`
- `playground/ThemeProbe.qml`
action:
- List the QML properties and helper functions that existing components rely on.
- Treat `Theme.colors.*`, `Theme.spacing.*`, `Theme.radius.*`, `Theme.typography.*`, `Theme.motion.*`, `Theme.icons.*`, `Theme.zIndex.*`, and `Theme.breakpoint.*` as the compatibility contract for Phase 1.
- Identify the minimum shallow aliases needed for the new API: start with `Theme.palette.textPrimary`, `Theme.palette.backgroundBase`, `Theme.palette.actionPrimary`, `Theme.palette.borderBase`, and `Theme.palette.statusError`.
verify:
- `rg -n "Theme\\." Core Controls Foundation playground -g '*.qml'` has been reviewed.
acceptance_criteria:
- The implementation does not remove a property currently consumed by `Controls`, `Foundation`, or `playground`.

## Task 2 - Add Typed C++ Theme Objects

type: implementation
files:
- `Core/Theme/MerceTheme.h`
- `Core/Theme/MerceTheme.cpp`
- `Core/Theme/MercePalette.h`
- `Core/Theme/MerceSpacing.h`
- `Core/Theme/MerceRadius.h`
- `Core/Theme/MerceTypography.h`
- `Core/Theme/MerceMotion.h`
- `Core/Theme/MerceIconography.h`
- `Core/Theme/MerceZIndex.h`
- `Core/Theme/MerceBreakpoints.h`
action:
- Implement `MerceTheme` as the singleton owner.
- Implement each supporting object as a `QObject`-based type with explicit `Q_PROPERTY` declarations.
- Use `QColor` for color values, `int` or `qreal` for numeric values, and `QString` for font families.
- Add `NOTIFY` signals to mutable runtime values even if Phase 1 seeds only static defaults.
- Use C++ defaults copied from the existing QML token files.
- Keep object ownership explicit: `MerceTheme` owns its sub-objects for the lifetime of the singleton.
verify:
- Headers compile under the project standard.
- Property names match the planned public and compatibility API.
acceptance_criteria:
- `MerceTheme` exposes `palette`, `colors`, `spacing`, `radius`, `typography`, `motion`, `icons`, `zIndex`, and `breakpoint`.
- `colors` may alias the palette compatibility object; `palette` is the preferred shallow API for new code.
- Every supporting object is reachable through `Theme` but is not independently created by consumer QML.

## Task 3 - Register `Theme` In The Merce QML Module

type: implementation
files:
- `Core/CMakeLists.txt`
- `Core/Theme.qml`
- `Core/Theme/MerceTheme.h`
- `Core/Theme/MerceTheme.cpp`
action:
- Add the C++ source and header files to the `MerceCore` QML module target.
- Register `MerceTheme` as the public QML singleton named `Theme`.
- Register supporting types as anonymous or uncreatable QML types.
- Remove or rename the public `Theme.qml` singleton so it does not collide with the C++ `Theme` registration.
- If a compatibility shim is needed, keep it internal and do not expose it as the public `Theme`.
verify:
- `Merce.Core` imports without duplicate `Theme` type registration.
- `Theme` resolves from C++ when loaded by the playground probe.
acceptance_criteria:
- QML consumers still import `Merce.Core` and access `Theme`.
- The module does not expose raw token QML files as public API.
- `Theme.qml` no longer owns the public singleton contract after this phase.

## Task 4 - Preserve Compatibility And Add Shallow API

type: implementation
files:
- `Core/Theme/MercePalette.h`
- `Core/Theme/MerceSpacing.h`
- `Core/Theme/MerceRadius.h`
- `Core/Theme/MerceTypography.h`
- `playground/ThemeProbe.qml`
action:
- Preserve current compatibility paths used by components:
  - `Theme.colors.action.primary`
  - `Theme.colors.action.base(variant)`
  - `Theme.colors.action.light(variant)`
  - `Theme.colors.text.primary`
  - `Theme.colors.background.base`
  - `Theme.colors.border.base`
  - `Theme.spacing.md`
  - `Theme.radius.button`
  - `Theme.typography.body`
  - `Theme.icons.small`
- Add shallow aliases for the new API:
  - `Theme.palette.textPrimary`
  - `Theme.palette.textInverse`
  - `Theme.palette.backgroundBase`
  - `Theme.palette.backgroundSurface`
  - `Theme.palette.actionPrimary`
  - `Theme.palette.actionSecondary`
  - `Theme.palette.borderBase`
  - `Theme.palette.statusError`
- For typography presets currently represented as QML JS objects, choose a Phase 1-compatible representation that QML can consume without rewriting `MText`. Prefer `QVariantMap` for presets in this phase; stronger typed preset objects can be refined later.
verify:
- Existing `MText` and `MButton` can still evaluate their bindings.
- `ThemeProbe.qml` verifies at least one compatibility path and one shallow alias path.
acceptance_criteria:
- Existing representative components do not need a broad rewrite in Phase 1.
- New code has a shallow `Theme.palette.*` path available.

## Task 5 - Update Probe And Build Verification

type: verification
files:
- `playground/ThemeProbe.qml`
- `playground/main.cpp`
action:
- Update `ThemeProbe.qml` to verify:
  - `Theme.palette.backgroundBase` has the expected default color.
  - `Theme.colors.background.base` still works as a compatibility path.
  - `Theme.spacing.md === 16`.
  - `Theme.radius.button === 12`.
  - `Theme.icons.small === 20`.
- Keep probe output concise and deterministic.
- Do not replace the existing executable-based verification path with the `qml` CLI.
verify:
- Configure/build the project with `BUILD_MERCE_PLAYGROUND=ON`.
- Run `MercePlayground --theme-probe`.
- Run `MercePlayground --smoke-test` if it is still available.
acceptance_criteria:
- Probe exits successfully.
- Smoke path does not fail due to QML import or duplicate type registration errors.

## Task 6 - Document Phase 1 Runtime Contract

type: docs
files:
- `.planning/phases/01-theme-runtime-contract/01-SUMMARY.md`
- Optional implementation note under project docs if a docs location already exists.
action:
- Capture the final public API shape after implementation.
- Record the compatibility paths intentionally retained.
- Record which token categories are implemented as typed objects and which remain compatibility-only.
- Record any known limitations deferred to Phase 2-4.
verify:
- Summary references `THEME-01` through `THEME-05`.
acceptance_criteria:
- Next phases can build the Style Dictionary manifest pipeline without guessing the runtime contract.
</tasks>

<verification>
## Required Verification Commands

Run the closest available commands for the local environment:

1. Configure:
   - `cmake -S . -B build -DBUILD_MERCE_PLAYGROUND=ON`
2. Build:
   - `cmake --build build --target MercePlayground`
3. Probe:
   - `./build/playground/MercePlayground --theme-probe`
4. Smoke:
   - `./build/playground/MercePlayground --smoke-test`
5. Static checks:
   - `git diff --check`
   - `rg -n "Theme\\.colors|Theme\\.palette|Theme\\.spacing|Theme\\.radius|Theme\\.typography" Core Controls Foundation playground -g '*.qml'`

If Qt 6.11 is not available in the current environment, record that limitation and still run `git diff --check`.
</verification>

<success_criteria>
- THEME-01: `Theme` is registered into `Merce.Core` from C++ and is importable from QML.
- THEME-02: `Theme` exposes typed sub-objects for palette/colors, spacing, radius, typography, motion, iconography, z-index, and breakpoints.
- THEME-03: Supporting theme objects cannot be created directly by QML consumers.
- THEME-04: New shallow semantic properties are available through `Theme.palette.*`.
- THEME-05: Runtime-updatable properties have `NOTIFY` signals.
- Existing representative paths used by `MButton`, `MText`, and `ThemeProbe` remain usable.
- Build/probe verification is run or a concrete Qt/tooling blocker is documented.
</success_criteria>

<handoff>
## Next Phase Input

Phase 2 should treat the C++ property names from this plan as the target manifest mapping surface. Style Dictionary must emit a resolved manifest that can populate these same semantic categories without exposing raw DTCG token paths to QML.
</handoff>
