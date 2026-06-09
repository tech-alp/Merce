# Phase 05: Verification And Gallery - Context

**Gathered:** 2026-06-04T11:50:57+03:00
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the Merce theme runtime observable and easy to validate through automated checks, focused QML probes, optional qmlagent inspection, and a playground gallery that produces README-ready visual evidence.

This phase owns verification hardening for public `Theme` values, representative component smoke coverage, manifest validation coverage gaps, and the visual theme gallery. It does not introduce a new theme runtime API, raw generated-token public API, Spix dependency, Qt Quick Controls style-family switching, or a full component-state matrix.

</domain>

<decisions>
## Implementation Decisions

### Verification Proof Stack
- **D-01:** Use a lightweight but solid mandatory verification stack: CTest, existing/new theme QtTests, `MercePlayground --theme-probe`, `MercePlayground --theme-switch-probe`, `MercePlayground --smoke-test`, and a gallery build/offscreen run.
- **D-02:** The gallery must produce visual evidence that can be shared from a README. README-ready screenshots or exported images are required as product evidence, but pixel-perfect visual diff is not a mandatory Phase 5 gate.
- **D-03:** Mandatory gates stay deterministic and local: QtTest/CTest plus offscreen playground probe/smoke/gallery execution. qmlagent inspection is official but optional.

### Public Theme API Naming
- **D-04:** Do not treat compatibility aliases such as `Theme.colors`, `Theme.icons`, or `Theme.breakpoint` as long-term public-contract requirements. This project is still in development and is not yet versioned/shipped.
- **D-05:** Phase 5 should favor canonical API names in gallery/probe/docs: `Theme.palette`, `Theme.iconography`, and `Theme.breakpoints`.
- **D-06:** The gallery must not present aliases such as `colors` vs `palette` or `icons` vs `iconography` as separate token families. If alias cleanup is needed, planners may include a narrowly scoped task, but not a broad compatibility migration.

### Component Smoke Coverage
- **D-07:** Use the existing playground component set and strengthen state/theme-switch proof instead of building a full component matrix.
- **D-08:** Representative runtime consumers are `MButton` variants, `MText`, `MInput`, checkbox, radio, switch, select, toast, and dialog.
- **D-09:** Component smoke proof should show that representative controls consume the active runtime theme after startup and after at least one theme switch.

### Manifest Validation Boundary
- **D-10:** Extend `tests/Core/tst_merce_theme_manifest_loader.cpp` for `VERIFY-03` rather than creating a separate validation test file by default.
- **D-11:** Keep manifest validation focused at the C++ loader level for bad schema, missing fields, unknown brand/mode registry rejection, and fallback behavior.
- **D-12:** Only split a new focused validation test if the existing loader test becomes hard to read. Public invalid/unknown runtime behavior already has Phase 4 coverage and should not be duplicated unnecessarily.

### Playground Gallery Shape
- **D-13:** Create a separate `ThemeGallery.qml` component/route and integrate it from `Main.qml`; do not turn `Main.qml` into a large gallery file.
- **D-14:** The gallery should include active brand/mode readout or selector, palette swatches, typography samples, spacing/radius scale, existing component state examples, and stable `objectName` anchors for screenshots and qmlagent inspection.
- **D-15:** Gallery layout should stay practical and verification-oriented. Avoid marketing-page structure, explanatory tutorial copy, broad decorative sections, or a full component-state matrix.

### Automation Dependency Policy
- **D-16:** Make qmlagent an official optional inspect/debug verification path for gallery anchors and diagnostics.
- **D-17:** Do not introduce Spix as a Phase 5 dependency.
- **D-18:** qmlagent should be documented as an inspection/debug workflow, not a required CI gate. Mandatory Phase 5 gates remain QtTest/CTest, offscreen playground probe/smoke/gallery runs, and README visual artifacts.

### the agent's Discretion
- Exact gallery layout details, screenshot script naming, README section placement, and whether the active brand/mode selector is interactive or read-only may follow existing playground patterns as long as the decisions above are preserved.
- The planner may choose whether screenshot export is implemented by a small script, CMake/custom target, or documented manual command, as long as the generated visual evidence is reproducible and README-ready.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Planning Scope
- `.planning/PROJECT.md` - current Merce Theme Runtime direction, constraints, and Phase 4 completion context.
- `.planning/REQUIREMENTS.md` - Phase 5 requirements `VERIFY-01` through `VERIFY-04`.
- `.planning/ROADMAP.md` - Phase 5 boundary and success criteria.
- `.planning/phases/03-manifest-registry-and-loader/03-CONTEXT.md` - locked registry, loader, fallback, base overlay, and resource packaging decisions.
- `.planning/phases/04-runtime-brand-mode-switching/04-CONTEXT.md` - locked runtime switching API, active state, invalid request, fallback, and verification-scope decisions.
- `.planning/phases/04-runtime-brand-mode-switching/04-UI-SPEC.md` - prior UI/probe constraints and Phase 5 gallery deferral.

### Theme Runtime And Tests
- `Core/Theme/MerceTheme.h` - public `Theme` singleton, canonical properties, alias properties, and active brand/mode API.
- `Core/Theme/MerceTheme.cpp` - current manifest apply path and runtime theme switching integration.
- `tests/Core/tst_merce_theme_manifest_loader.cpp` - existing loader validation and fallback QtTest surface to extend for `VERIFY-03`.
- `tests/Core/tst_merce_theme_runtime_switch.cpp` - existing runtime switch, invalid request, fallback active state, and pointer-stability coverage.
- `tests/Core/CMakeLists.txt` - `merce_add_qtest(...)` helper and CTest registration pattern.

### Playground And Visual Evidence
- `playground/Main.qml` - existing consumer-style playground surface and component smoke examples.
- `playground/ThemeGallery.qml` - planned gallery component/route for Phase 5.
- `playground/ThemeProbe.qml` - existing public theme value probe.
- `playground/ThemeSwitchProbe.qml` - existing runtime switch QML probe.
- `playground/main.cpp` - CLI probe/smoke routing.
- `playground/CMakeLists.txt` - `MercePlayground` QML module registration.
- `Controls/MButton.qml` - representative control consuming theme palette, spacing, radius, typography, icons, and motion.
- `Foundation/MText.qml` - representative typography component consuming theme typography and color values.

### Generated Theme Fixtures
- `generated/themes/index.json` - current built-in theme registry with `merce` light/dark and single-manifest `stripe`.
- `generated/themes/merce.light.json` - Merce light manifest values used by probes/gallery.
- `generated/themes/merce.dark.json` - Merce dark manifest values used by probes/gallery.
- `generated/themes/stripe.json` - single-manifest reference theme used to prove empty-mode behavior and visual contrast.

### Optional Inspection Tooling
- `tools/qmlagent-probe.mjs` - existing project script surface for qmlagent probing.
- `external/qmlagent/README.md` - qmlagent usage reference if the planner needs to document optional inspection.
- `external/qmlagent/skills/qmlagent-runtime/SKILL.md` - qmlagent runtime interaction guidance if optional inspection is planned.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MercePlayground` already imports `Merce.Core`, `Merce.Foundation`, `Merce.Controls`, and `Merce.Notifications`; it is the right consumer-style verification shell.
- `playground/ThemeProbe.qml` already verifies public theme values for palette, compatibility color access, spacing, radius, typography, and icons.
- `playground/ThemeSwitchProbe.qml` already verifies default state, Merce dark switch, invalid request preservation, Stripe empty mode, and stable object pointers.
- `tests/Core/tst_merce_theme_manifest_loader.cpp` already covers generated resource index load, unknown theme/variant rejection, unsafe paths, malformed JSON, schema mismatch, top-level `colors` rejection, invalid runtime fields, section overlay, fallback, and broken default failure.
- `tests/Core/tst_merce_theme_runtime_switch.cpp` already covers runtime switch behavior and should be reused as the boundary for public API invalid/fallback behavior.
- `playground/Main.qml` already has stable `objectName` values for the window, flickable, page, controls surface, primary/secondary/outline/destructive buttons, input, toggles, select, toast, and dialog.

### Established Patterns
- Component-facing theme access stays behind `Theme`; components should not consume raw DTCG paths, generated manifest paths, or token implementation files.
- Public runtime terminology is `brand` and `mode`; internal loader/registry terminology may remain `theme` and `variant`.
- Runtime switching is Merce semantic theme switching, not Qt Quick Controls style-family switching.
- Normal runtime and consumer builds must not depend on Node, Style Dictionary, or new visual automation dependencies.
- Headless verification should use `QT_QPA_PLATFORM=offscreen` for playground probe/smoke/gallery execution.

### Integration Points
- Add `ThemeGallery.qml` to `playground/CMakeLists.txt` `QML_FILES`.
- Integrate `ThemeGallery.qml` from `playground/Main.qml` without turning `Main.qml` into a large gallery implementation file.
- Extend `playground/main.cpp` only if a focused gallery route/probe flag is useful for offscreen run or screenshot generation.
- Extend `tests/Core/tst_merce_theme_manifest_loader.cpp` for remaining `VERIFY-03` gaps.
- Update README or a gallery-specific doc with generated visual artifacts and the exact commands that produced them.

</code_context>

<specifics>
## Specific Ideas

- Mandatory verification command family should include:
  - `ctest --test-dir build --output-on-failure`
  - `ctest --test-dir build -R tst_merce_theme_manifest_loader --output-on-failure`
  - `ctest --test-dir build -R tst_merce_theme_runtime_switch --output-on-failure`
  - `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe`
  - `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe`
  - `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test`
- Candidate gallery sections: active brand/mode, palette swatches, typography samples, spacing/radius scale, and component states for the existing playground component set.
- Candidate screenshot anchors should use stable object names such as `merce.playground.gallery`, `merce.playground.gallery.palette`, `merce.playground.gallery.typography`, `merce.playground.gallery.spacingRadius`, and `merce.playground.gallery.components`.
- README visual evidence should show at least Merce light, Merce dark, and Stripe Reference output if practical.
- If alias cleanup is planned, prefer moving component/gallery usage toward `Theme.palette`, `Theme.iconography`, and `Theme.breakpoints` while avoiding unrelated broad rewrites.

</specifics>

<deferred>
## Deferred Ideas

- Spix may be reconsidered in a later phase as an opt-in UI automation dependency if qmlagent and offscreen screenshot workflows are insufficient.
- Pixel-perfect visual regression testing is deferred; Phase 5 requires reproducible visual artifacts but not visual diff gates.
- A full component-state matrix is deferred until the design system has broader component-token coverage.

</deferred>

---

*Phase: 05-verification-and-gallery*
*Context gathered: 2026-06-04T11:50:57+03:00*
