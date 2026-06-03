# Phase 1: Theme Runtime Contract - Context

**Gathered:** 2026-06-03
**Status:** Ready for planning
**Source:** Discussion-driven GSD initialization

<domain>
## Phase Boundary

Introduce a typed C++ theme runtime contract for Merce and expose it to QML as the public `Theme` singleton. This phase is about API shape, registration, and compatibility strategy. It does not need to finish DTCG token conversion, manifest generation, or full runtime switching.

</domain>

<decisions>
## Implementation Decisions

### Runtime Ownership
- D-01: Theme runtime should move to C++ for type safety and better control over public QML API surface.
- D-02: Supporting theme structures should not be QML-creatable by consumers; expose them only through `Theme`.
- D-03: QML public API should avoid deep chains such as `Theme.colors.text.primary` where possible; prefer shallow semantic properties such as `Theme.palette.textPrimary`.

### Compatibility
- D-04: Existing Merce components already use the current `Theme` facade; migration should be incremental.
- D-05: Do not expose raw DTCG paths, generated manifests, or generated token objects to component authors.

### Runtime Behavior
- D-06: Theme values that can change at runtime need `NOTIFY` signals.
- D-07: Runtime theme changes should update Merce semantic values, not switch Qt Quick Controls style family.

### the agent's Discretion
- Exact C++ class names and file layout may be chosen to match existing CMake/module conventions.
- Whether `Theme.qml` stays temporarily as a compatibility shim is an implementation decision, as long as the public import contract remains stable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing Merce Theme Contract
- `Core/Theme.qml` - current public QML singleton facade.
- `Core/CMakeLists.txt` - current QML module registration and internal token file handling.
- `Core/Palette.qml` - current color API shape and helper behavior.
- `Core/Spacing.qml` - current spacing token names.
- `Core/Typography.qml` - current typography token and preset names.
- `Controls/MButton.qml` - representative component consuming `Theme`.
- `Foundation/MText.qml` - representative typography component consuming `Theme`.
- `playground/ThemeProbe.qml` - current runtime probe pattern.

### Planning References
- `.planning/PROJECT.md` - project context and decisions.
- `.planning/REQUIREMENTS.md` - phase requirements.
- `.planning/ROADMAP.md` - phase scope and success criteria.

</canonical_refs>

<specifics>
## Specific Ideas

- Candidate public API:
  - `Theme.palette.textPrimary`
  - `Theme.palette.backgroundBase`
  - `Theme.palette.actionPrimary`
  - `Theme.spacing.md`
  - `Theme.radius.button`
  - `Theme.typography.bodyFont`
  - `Theme.typography.bodySize`
- Candidate C++ macro direction:
  - `QML_SINGLETON` and `QML_NAMED_ELEMENT(Theme)` for the public singleton.
  - `QML_ANONYMOUS` or `QML_UNCREATABLE` for supporting types.
- First phase should prove the registration and one or two representative components before broad migration.

</specifics>

<deferred>
## Deferred Ideas

- DTCG token source migration is Phase 2.
- `:/merce/themes/{brand}/{mode}.json` registry and loader are Phase 3.
- Full runtime brand/mode switching is Phase 4.
- Playground theme gallery is Phase 5.

</deferred>

---
*Phase: 01-theme-runtime-contract*
*Context gathered: 2026-06-03 via discussion*
