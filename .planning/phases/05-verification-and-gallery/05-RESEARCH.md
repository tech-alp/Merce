# Phase 05: Verification And Gallery - Research

**Researched:** 2026-06-04
**Domain:** Qt 6/QML verification, Merce theme runtime probes, playground gallery, README visual evidence, optional qmlagent inspection
**Confidence:** HIGH

<user_constraints>
## User Constraints From CONTEXT.md

### Locked Decisions

- Mandatory verification stack is lightweight and deterministic: CTest, theme QtTests, `MercePlayground --theme-probe`, `--theme-switch-probe`, `--smoke-test`, and gallery build/offscreen run.
- Gallery must produce README-ready visual evidence. Pixel-perfect visual diff is not a required gate.
- qmlagent is an official optional inspect/debug verifier; Spix is not a Phase 5 dependency.
- Canonical theme API names should be favored during development: `Theme.palette`, `Theme.iconography`, and `Theme.breakpoints`. Compatibility aliases such as `Theme.colors`, `Theme.icons`, and `Theme.breakpoint` are not long-term requirements.
- Component smoke coverage should reuse and strengthen the existing playground set: `MButton`, `MText`, `MInput`, checkbox, radio, switch, select, toast, and dialog.
- `VERIFY-03` should extend `tests/Core/tst_merce_theme_manifest_loader.cpp` rather than creating a separate test file by default.
- Gallery should be a separate `ThemeGallery.qml` component/route integrated from `Main.qml`.

### Out Of Scope

- Spix dependency.
- Pixel-perfect visual regression testing.
- Full component-state matrix.
- New theme runtime API or raw generated-token public API.
- Qt Quick Controls style-family switching.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Requirement | Research Support |
|----|-------------|------------------|
| VERIFY-01 | A theme probe verifies public theme values load from the C++ runtime. | Existing `playground/ThemeProbe.qml` already verifies known palette/compatibility color, spacing, radius, typography, and icon values through `MercePlayground --theme-probe`. Phase 5 should update it toward canonical API assertions and make the expected manifest values explicit. [VERIFIED: playground/ThemeProbe.qml][VERIFIED: playground/main.cpp][VERIFIED: generated/themes/merce.light.json] |
| VERIFY-02 | A smoke test verifies core Merce components consume the C++ theme runtime. | Existing `playground/Main.qml` already uses representative controls with stable object names. Phase 5 should add `ThemeGallery.qml` component samples and prove values after startup/theme switch through offscreen smoke and optional qmlagent inspection. [VERIFIED: playground/Main.qml][VERIFIED: Controls/MButton.qml][VERIFIED: Foundation/MText.qml] |
| VERIFY-03 | Manifest validation test covers missing fields, invalid schema version, unknown brand, and fallback behavior. | Existing `tests/Core/tst_merce_theme_manifest_loader.cpp` covers most loader validation/fallback paths. Phase 5 should audit requirement wording against current cases and add missing-field/invalid-schema/unknown-brand-mode/fallback assertions only where gaps remain. [VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp][VERIFIED: tests/Core/tst_merce_theme_runtime_switch.cpp] |
| VERIFY-04 | Playground includes a theme gallery for palette, typography, spacing, radius, and common control states. | Add `playground/ThemeGallery.qml`, register it in `playground/CMakeLists.txt`, integrate it from `Main.qml`, and generate README-ready visual artifacts. `QQuickItemGrabResult::saveToFile()` is an official Qt path for saving item grab results from QML/C++ if an in-app capture route is chosen. [VERIFIED: playground/CMakeLists.txt][CITED: Qt docs qquickitemgrabresult.html] |

</phase_requirements>

## Summary

Phase 5 is a verification and evidence phase, not a new runtime architecture phase. The repo already has the core runtime, manifest loader, runtime switching API, QtTest harness, focused QML probes, and a consumer-style playground. The highest-value work is to convert those surfaces into a clean proof stack and a focused `ThemeGallery.qml` that can generate visual artifacts for README documentation. [VERIFIED: .planning/phases/05-verification-and-gallery/05-CONTEXT.md][VERIFIED: .planning/PROJECT.md]

**Primary recommendation:** implement Phase 5 as two or three bounded plans:

1. Verification hardening: audit and extend `ThemeProbe.qml`, `tst_merce_theme_manifest_loader.cpp`, and verification commands so `VERIFY-01` through `VERIFY-03` have direct evidence.
2. Gallery UI: add `ThemeGallery.qml`, integrate it into `Main.qml`, keep canonical API names visible, and reuse the existing component set.
3. Visual evidence/docs: add a reproducible screenshot/export path and README section, plus optional qmlagent inspection instructions.

## Current Verification Surface

| Surface | Current State | Phase 5 Use |
|---------|---------------|-------------|
| `tests/Core/CMakeLists.txt` | Provides `merce_add_qtest(...)` helper and registers existing Core tests. | Reuse for any new or extended test target. [VERIFIED: tests/Core/CMakeLists.txt] |
| `tests/Core/tst_merce_theme_manifest_loader.cpp` | Covers generated index load, unknown theme/variant rejection, unsafe paths, malformed JSON, schema mismatch, top-level `colors` rejection, invalid runtime fields, section overlay, fallback, and broken default. | Extend only for real `VERIFY-03` gaps. [VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| `tests/Core/tst_merce_theme_runtime_switch.cpp` | Covers runtime default state, light/dark/stripe switching, invalid preservation, fallback active state, bool returns, pointer stability, and meta-object contracts. | Reference for public runtime behavior; avoid duplicating in loader tests. [VERIFIED: tests/Core/tst_merce_theme_runtime_switch.cpp] |
| `playground/ThemeProbe.qml` | Verifies known values from the public `Theme` API and exits. | Update toward canonical API names and explicit expected manifest values. [VERIFIED: playground/ThemeProbe.qml] |
| `playground/ThemeSwitchProbe.qml` | Verifies runtime switch binding behavior and stable pointers. | Keep as a required probe in the mandatory stack. [VERIFIED: playground/ThemeSwitchProbe.qml] |
| `playground/Main.qml` | Consumer-style app with stable object names and representative components. | Integrate `ThemeGallery.qml` without turning `Main.qml` into the gallery implementation. [VERIFIED: playground/Main.qml] |
| `tools/qmlagent-probe.mjs` | Manual TCP qmlagent probe script targeting existing object names. | Update or add a Phase 5 gallery probe if optional qmlagent verification is documented. [VERIFIED: tools/qmlagent-probe.mjs] |

## Recommended Project Structure

```text
playground/
├── Main.qml                 # integrate ThemeGallery, keep shell readable
├── ThemeGallery.qml         # new gallery component/route
├── ThemeProbe.qml           # canonical public theme value probe
├── ThemeSwitchProbe.qml     # existing runtime switch probe
├── main.cpp                 # add route/capture flags only if needed
└── CMakeLists.txt           # register ThemeGallery.qml and any helper QML

tests/Core/
├── CMakeLists.txt
├── tst_merce_theme_manifest_loader.cpp
└── tst_merce_theme_runtime_switch.cpp

docs or repo root README:
└── README visual section + checked-in generated images, if that is the project convention
```

## Gallery Architecture

### Pattern 1: Dedicated `ThemeGallery.qml`

**What:** Create a dedicated gallery component that can be embedded in `Main.qml` and optionally loaded directly through a route/CLI flag.

**Why:** Keeps `Main.qml` as a playground shell and prevents the gallery from turning into a large mixed-purpose file. This matches the locked decision in `05-CONTEXT.md`.

**Recommended sections:**

| Section | Purpose | Example Data |
|---------|---------|--------------|
| Active theme | Show `Theme.activeBrand` and `Theme.activeMode`, or provide a small selector if useful. | `merce/light`, `merce/dark`, `stripe/""` |
| Palette | Show canonical `Theme.palette.*` swatches. | `backgroundBase`, `backgroundSurface`, `textPrimary`, `actionPrimary`, `borderFocus`, status colors |
| Typography | Show text samples from `Theme.typography.*`. | body/display font, sizes, weights, line heights |
| Spacing/radius | Visual scale bars and rounded rectangles. | `spacing.xs/md/xl`, `radius.small/button/card` |
| Components | Show existing representative component states. | MButton variants, MText, MInput, toggles, select, toast/dialog trigger |

**Object names:** Use stable anchors such as:

```text
merce.playground.gallery
merce.playground.gallery.palette
merce.playground.gallery.typography
merce.playground.gallery.spacingRadius
merce.playground.gallery.components
```

### Pattern 2: Canonical API Display

**What:** Gallery labels and probes should use canonical API names: `Theme.palette`, `Theme.iconography`, and `Theme.breakpoints`.

**Why:** User clarified backward compatibility is not required yet. Alias properties are not separate state; in `MerceTheme.h`, `colors()` returns `m_palette`, `icons()` and `iconography()` return `m_icons`, and singular/plural breakpoint aliases return `m_breakpoints`. [VERIFIED: Core/Theme/MerceTheme.h]

**Implementation implication:** If existing components still use `Theme.colors.*`, planner may include a focused migration for files touched by the gallery/smoke work, but should avoid broad unrelated rewrites.

## Visual Evidence Options

### Option A: In-App QML Grab

Qt exposes `QQuickItemGrabResult` as the result of `QQuickItem::grabToImage()`, and that result can be saved to a local file using `saveToFile(...)`. [CITED: Qt docs qquickitemgrabresult.html]

**Good fit when:** The gallery can expose a stable root item and save one or more named image files after layout settles.

**Trade-off:** Requires a small capture route/timer or helper object so the app knows where to write images.

### Option B: qmlagent Screenshot Fallback

qmlagent provides structured evidence first and screenshot capture as fallback. Its docs explicitly recommend writing PNG files to disk or scaling/region-cropping screenshots to avoid base64 payload bloat. [VERIFIED: external/qmlagent/README.md][VERIFIED: external/qmlagent/skills/qmlagent-runtime/SKILL.md]

**Good fit when:** The gallery is already running with `QT_QML_DEBUG` and the goal is manual/optional inspect/debug evidence.

**Trade-off:** qmlagent remains optional and should not be mandatory CI.

### Option C: QQuickWindow Full Window Grab

`QQuickWindow` provides `grabWindow()` for grabbing the rendered window image. [CITED: Qt docs qquickwindow.html]

**Good fit when:** A C++ helper is simpler than QML item-level grabs and whole-window README shots are acceptable.

**Trade-off:** Whole-window grabs may include extra chrome/layout and are less targeted than item-level gallery captures.

**Recommendation:** Prefer in-app item/window export for reproducible README artifacts, and document qmlagent screenshot as optional inspection fallback.

## qmlagent Optional Verification Path

qmlagent is already present under `external/qmlagent` and the playground target is built with `QT_QML_DEBUG`, which is required for qmlagent attachment. [VERIFIED: external/qmlagent/README.md][VERIFIED: playground/CMakeLists.txt]

Recommended optional flow:

```text
1. Build MercePlayground.
2. Launch with QML debugging enabled, e.g. -qmljsdebugger=port:<port>,host:127.0.0.1,services:QmlAgent.
3. Connect through qmlagent MCP or tools/qmlagent-probe.mjs.
4. Query stable object names under merce.playground.gallery.*.
5. Inspect diagnostics tree.
6. Capture screenshot only as visual fallback or README support.
```

**Important constraints:**

- Prefer stable `objectName` selectors, not session-local node IDs. [VERIFIED: external/qmlagent/README.md]
- Use `qmlagent.ui_query`, `ui_get_tree`, diagnostics, logs, and input/workflow evidence before screenshots. [VERIFIED: external/qmlagent/skills/qmlagent-runtime/SKILL.md]
- Do not make qmlagent a required CI gate in Phase 5. [VERIFIED: 05-CONTEXT.md]

## Manifest Validation Gaps To Audit

Current loader tests already cover much of `VERIFY-03`. The planner should audit exact coverage before adding tests.

| Requirement Wording | Current Likely Coverage | Research Recommendation |
|---------------------|-------------------------|-------------------------|
| Bad schema / invalid schema version | `schemaVersionMismatchIsRejected()` exists. | Keep or rename/assert clearly if needed. [VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Missing fields | `brokenDefaultReturnsFailure()` and `activePaletteCannotBorrowMissingFieldsFromBase()` exist. | Add targeted cases only if required fields outside palette/default failure are not explicit enough. |
| Unknown brand/mode | `unknownThemeIsRejected()` and `unknownVariantIsRejected()` exist at loader/registry level; runtime public invalid behavior exists in `tst_merce_theme_runtime_switch.cpp`. | Avoid duplicate QML coverage unless planner finds an observable gap. |
| Fallback behavior | `requestedBadManifestFallsBackToRegistryDefault()` exists; runtime active fallback exists in Phase 4 test. | Ensure errors and `usedFallback` expectations are explicit enough. |
| Compatibility `colors` section rejection | `topLevelColorsCompatibilitySectionIsRejected()` exists. | Keep because canonical manifest should not carry compatibility-only paths. |

## Verification Commands

Recommended mandatory command set for the plan:

```sh
cmake --build build --target tst_merce_theme_manifest_loader
cmake --build build --target tst_merce_theme_runtime_switch
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test
```

Add gallery-specific commands once the implementation defines them, for example:

```sh
cmake --build build --target MercePlayground
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-gallery-probe
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --export-theme-gallery <output-dir>
```

The exact flag names are planner discretion. The plan must specify concrete flag names before execution.

## Risks And Mitigations

| Risk | Why It Matters | Mitigation |
|------|----------------|------------|
| Gallery grows into a broad component matrix | Bloats Phase 5 and hides verification goal. | Keep `ThemeGallery.qml` focused on token families plus representative existing components. |
| README screenshot path becomes manual-only | Hard to reproduce or verify later. | Add exact export command and checked-in output path if repository convention allows. |
| qmlagent becomes a hard dependency | Adds setup fragility and conflicts with locked decision. | Document as optional inspect/debug path only. |
| Alias cleanup becomes broad refactor | Could destabilize existing components. | Only touch files needed for gallery/probe/smoke or leave cleanup to a later scoped task. |
| Offscreen rendering differs from visible rendering | Headless proof may miss visual/layout issues. | Keep README visual artifacts and optional qmlagent/screenshot path as human-review evidence. |
| Existing loader test is overextended | Large test file can become hard to maintain. | Add cases to existing file first; split only if readability degrades. |

## Open Questions (RESOLVED)

- **Should Phase 5 require Spix?** Resolved: no, Spix is deferred.
- **Should qmlagent be mandatory?** Resolved: no, qmlagent is official optional inspect/debug verification.
- **Should visual diff be mandatory?** Resolved: no, README-ready visual artifacts are required but pixel-perfect diff is deferred.
- **Should compatibility aliases be preserved?** Resolved: no long-term compatibility requirement exists yet; favor canonical API names.
- **Should gallery live inside `Main.qml`?** Resolved: no, create `ThemeGallery.qml` and integrate it from `Main.qml`.

## Research Complete

This research is ready for planning. The planner should produce executable tasks that preserve the locked Phase 5 boundary, keep verification deterministic, and make visual gallery evidence reproducible.

