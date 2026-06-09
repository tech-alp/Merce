# Phase 04: Runtime Brand/Mode Switching - Research

**Researched:** 2026-06-04
**Domain:** Qt 6 C++/QML runtime theme switching, QObject property binding, manifest-backed design-system state
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

## Implementation Decisions

### Public QML API
- **D-01:** Use public QML terminology `brand` and `mode`: `Theme.setTheme(brand, mode)`, `Theme.activeBrand`, and `Theme.activeMode`.
- **D-02:** Keep internal registry/loader terminology as `theme` and `variant` where already established. The public API maps `brand -> theme` and `mode -> variant`.
- **D-03:** Use `QString` for `brand` and `mode`. Do not use an enum for mode/variant because variants are data-driven by `index.json` and may include values beyond `light` and `dark`.
- **D-04:** `mode` is optional. Single-manifest themes use an empty mode, e.g. `Theme.setTheme("stripe")` and `Theme.activeMode == ""`.
- **D-05:** Phase 4 planning and implementation should use the repository's current C++20 baseline from top-level `CMakeLists.txt`, not a C++17 assumption.

### Switch Failure Behavior
- **D-06:** `Theme.setTheme(...)` should return `bool`.
- **D-07:** Unknown brand or unknown mode requests return `false`, log clearly, and leave the current active theme state and applied values unchanged.
- **D-08:** If the loader returns a valid fallback result for a registered but broken manifest, `Theme.setTheme(...)` may apply the returned fallback result. Active state must reflect the actual applied result, not the originally requested broken theme.
- **D-09:** Do not add QML-visible diagnostics such as `lastError` or `usedFallback` in Phase 4 unless implementation needs a minimal internal hook for tests. Public diagnostics can be reconsidered later.

### Binding-Safe Updates
- **D-10:** Keep theme sub-object pointers stable for the lifetime of the `Theme` singleton. Do not replace `MercePalette`, `MerceSpacing`, `MerceRadius`, or `MerceTypography` objects during switching.
- **D-11:** Runtime switching updates values inside the stable sub-objects through `applyManifestSection(...)`.
- **D-12:** QML binding invalidation comes from sub-object value notify signals, e.g. `MercePalette::changed`, `MerceSpacing::changed`, `MerceRadius::changed`, and `MerceTypography::changed`.
- **D-13:** Top-level `Theme` object pointer properties such as `palette`, `colors`, `spacing`, `radius`, and `typography` should be `CONSTANT` when the implementation confirms their pointers never change.
- **D-14:** Do not rely on top-level `Theme.paletteChanged`, `Theme.spacingChanged`, `Theme.radiusChanged`, or `Theme.typographyChanged` for runtime value updates. If those signals are removed or no longer emitted for value changes, value binding correctness should still hold through the sub-object properties.

### Verification Scope
- **D-15:** Phase 4 verification should use C++ QtTest unit coverage plus a focused QML probe.
- **D-16:** C++ tests should cover successful `merce` light/dark switching, single-manifest theme selection with empty mode, active brand/mode updates, `bool` return behavior, and invalid request state preservation.
- **D-17:** QML probe coverage should prove that `Theme.setTheme("merce", "dark")` updates a bound QML value such as `Theme.palette.backgroundBase` through stable `CONSTANT` object pointers and sub-object `NOTIFY changed` signals.
- **D-18:** Do not introduce Spix as a required Phase 4 dependency. Keep Phase 4 dependency-light and use existing Qt/QML test patterns.

### the agent's Discretion

- Exact C++ helper names, private method split, and whether `activeBrandChanged`/`activeModeChanged` are separate signals or a shared `activeThemeChanged` signal may follow the existing `Core/Theme` style, as long as QML can observe both active properties correctly.
- The planner may decide whether to add a new probe QML file or extend `playground/ThemeProbe.qml`, as long as Phase 4 does not become a gallery implementation.

### Deferred Ideas (OUT OF SCOPE)

- Evaluate Spix as an optional Phase 5 playground/gallery UI automation tool, gated behind an opt-in test option such as `MERCE_ENABLE_SPIX_TESTS=ON` if adopted.
- Playground visual theme gallery and screenshot automation belong to Phase 5, not Phase 4.
- QML-visible diagnostics such as `Theme.lastError` or `Theme.usedFallback` can be reconsidered later if verification or consumer UX needs them.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RUNTIME-01 | QML can request `Theme.setTheme(brand, mode)` for registered themes. | Add `Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString())` to `MerceTheme`; delegate to existing `MerceThemeManifestLoader::load(theme, variant)`. [VERIFIED: 04-CONTEXT.md][VERIFIED: Core/Theme/MerceThemeManifestLoader.h][VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp] |
| RUNTIME-02 | Switching from light to dark updates Merce component bindings without recreating the whole UI. | Keep `MercePalette`, `MerceSpacing`, `MerceRadius`, and `MerceTypography` pointers stable and update their values through existing `applyManifestSection(...)` methods that emit `changed`. [VERIFIED: 04-CONTEXT.md][VERIFIED: Core/Theme/MercePalette.h][VERIFIED: Core/Theme/MerceSpacing.h][VERIFIED: Core/Theme/MerceRadius.h][VERIFIED: Core/Theme/MerceTypography.h][CITED: Qt docs qtqml-syntax-propertybinding.html] |
| RUNTIME-03 | Runtime switching affects Merce semantic values only and does not attempt to change Qt Quick Controls style family on the fly. | Do not add `QQuickStyle` or `Qt6::QuickControls2`; Qt documents that style must be configured before loading QML that imports Qt Quick Controls and cannot be changed after QML types are registered. [VERIFIED: 04-CONTEXT.md][CITED: Qt docs qquickstyle.html] |
| RUNTIME-04 | The active brand and mode are queryable from QML. | Add `Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)` and `Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)` or separate notify signals; state must be updated only after an applied manifest succeeds. [VERIFIED: 04-CONTEXT.md][VERIFIED: Core/Theme/MerceTheme.h][CITED: Qt docs properties.html] |
</phase_requirements>

## Summary

Phase 4 should be a focused extension of the Phase 3 runtime, not a new theme subsystem. The repo already has packaged generated manifests, a strict registry/loader, fallback semantics, and manifest-backed `applyManifestSection(...)` methods for palette, spacing, radius, and typography. [VERIFIED: Core/CMakeLists.txt][VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp][VERIFIED: Core/Theme/MerceTheme.cpp][VERIFIED: .planning/phases/03-manifest-registry-and-loader/03-05-SUMMARY.md]

The main implementation work is to move the one-shot constructor apply path in `MerceTheme.cpp` into a reusable private apply helper, expose `Theme.setTheme(brand, mode)`, track `activeBrand`/`activeMode`, and verify that QML bindings update through sub-object value `NOTIFY` signals while top-level object pointer properties remain stable. [VERIFIED: 04-CONTEXT.md][VERIFIED: Core/Theme/MerceTheme.h][VERIFIED: Core/Theme/MerceTheme.cpp][CITED: Qt docs properties.html][CITED: Qt docs qtqml-syntax-propertybinding.html]

**Primary recommendation:** implement `setTheme()` in `MerceTheme` only, reuse `MerceThemeManifestLoader::load()`, keep object-pointer properties `CONSTANT`, update active state from `MerceThemeLoadResult.theme/variant`, and add one C++ QtTest plus one focused QML probe assertion path. [VERIFIED: 04-CONTEXT.md][VERIFIED: tests/Core/CMakeLists.txt][VERIFIED: playground/ThemeProbe.qml]

## Project Constraints (from AGENTS.md)

- No root `AGENTS.md` exists in the repository; the project instructions were provided in the user prompt and are treated as authoritative for this research. [VERIFIED: command `test -f AGENTS.md` returned no file][VERIFIED: user-provided AGENTS instructions]
- Use Turkish, be direct and practical, keep changes minimal, and inspect existing structure before editing. [VERIFIED: user-provided AGENTS instructions]
- Prefer Qt 6 / QML patterns, separate UI/domain/services/infrastructure, keep dependencies minimal, and do not introduce third-party dependencies without a clear reason. [VERIFIED: user-provided AGENTS instructions]
- Top-level `CMakeLists.txt` sets `CMAKE_CXX_STANDARD 20`; Phase 4 should follow the repo baseline rather than assuming C++17. [VERIFIED: CMakeLists.txt][VERIFIED: 04-CONTEXT.md D-05]
- Project skill directories `.codex/skills/` and `.agents/skills/` are absent in this checkout; no additional project skill rules apply. [VERIFIED: find .codex/skills][VERIFIED: find .agents/skills]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Public runtime switch API | C++ Core Runtime / QML singleton | QML caller | `Theme` is a C++ `QML_SINGLETON`; QML should call the public API, while registry terminology stays internal. [VERIFIED: Core/Theme/MerceTheme.h][VERIFIED: 04-CONTEXT.md] |
| Manifest resolution and fallback | C++ Core Runtime | Generated manifest registry | `MerceThemeManifestLoader::load(theme, variant)` already rejects unknown input and falls back only for registered broken manifests. [VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Applied theme state | C++ Core Runtime | QML observation | Active brand/mode must reflect the actually applied load result, including fallback. [VERIFIED: 04-CONTEXT.md D-08][VERIFIED: Core/Theme/MerceThemeManifest.h] |
| Binding invalidation | QObject sub-objects | QML engine | Top-level pointers remain stable; sub-object properties emit `changed` and QML bindings re-evaluate dependencies. [VERIFIED: Core/Theme/MercePalette.h][CITED: Qt docs properties.html][CITED: Qt docs qtqml-syntax-propertybinding.html] |
| Qt Quick Controls style family | Application startup only | Not Phase 4 | Qt Quick Controls style selection cannot be changed after QML Controls types are registered; Phase 4 must not touch it. [CITED: Qt docs qquickstyle.html][VERIFIED: REQUIREMENTS.md RUNTIME-03] |

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| Qt 6 Core/Qml/Quick | Required 6.11 by CMake; local build uses Qt 6.11 artifacts under `build/Qt_6_11_1_for_macOS-Debug`. | C++ singleton, QObject properties, QML bindings, manifest runtime. | Existing Merce stack; no new runtime dependency. [VERIFIED: CMakeLists.txt][VERIFIED: build tree] |
| Qt Property System | Qt docs 6.11.0 checked | `Q_PROPERTY`, `CONSTANT`, `NOTIFY`, `FINAL`, QML-readable state. | Defines correct binding surface for stable object pointers and mutable values. [CITED: Qt docs properties.html] |
| QML property binding engine | Qt docs 6.11.0 checked | Re-evaluate bindings when referenced dependencies change. | Binding correctness depends on sub-object value notify signals, not top-level pointer notify. [CITED: Qt docs qtqml-syntax-propertybinding.html] |
| Existing `MerceThemeManifestLoader` | Repo implementation | Loads default/requested theme, validates manifests, exposes fallback result. | Reuse Phase 3 loader; do not duplicate registry/validation logic. [VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp] |
| QtTest / CTest | CTest 4.3.1 local; Qt Test required by CMake | Fast C++ unit coverage for API/state semantics. | Existing `merce_add_qtest` pattern already passes. [VERIFIED: tests/Core/CMakeLists.txt][VERIFIED: ctest --test-dir build --output-on-failure] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| `MercePlayground --theme-probe` | Existing local target | Focused QML probe for public binding behavior. | Extend/add a probe for `Theme.setTheme()` binding updates. [VERIFIED: playground/main.cpp][VERIFIED: playground/ThemeProbe.qml] |
| Node/npm token tooling | Node v25.9.0, npm 11.12.1 available | Optional manifest generation only. | Not required for Phase 4 unless regenerating manifests; existing manifests are already committed/packaged. [VERIFIED: node --version][VERIFIED: npm --version][VERIFIED: CMakeLists.txt] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Reusing `MerceThemeManifestLoader::load()` | Re-parse `index.json` inside `MerceTheme` | Duplicates fallback and validation logic already tested in Phase 3. [VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Stable sub-object updates | Replace `MercePalette`/`MerceSpacing` pointers on switch | Breaks the locked pointer-stability decision and makes `CONSTANT` invalid. [VERIFIED: 04-CONTEXT.md D-10/D-13][CITED: Qt docs properties.html] |
| Qt Quick Controls style switching | `QQuickStyle::setStyle()` from `setTheme()` | Qt documents style must be configured before loading QML Controls and cannot be changed after registration. [CITED: Qt docs qquickstyle.html] |
| Spix UI automation | Add Spix for Phase 4 verification | Explicitly out of scope; current QtTest plus QML probe is enough. [VERIFIED: 04-CONTEXT.md D-18] |

**Installation:** no new package install is recommended. [VERIFIED: research scope][VERIFIED: 04-CONTEXT.md D-18]

## Package Legitimacy Audit

No new external packages are recommended or required for Phase 4. Existing Node/npm tooling remains build-time token tooling and is not a Phase 4 install. [VERIFIED: CMakeLists.txt][VERIFIED: tools/design-tokens/package.json][VERIFIED: 04-CONTEXT.md D-18]

## Architecture Patterns

### System Architecture Diagram

```text
QML caller
  |
  | Theme.setTheme(brand, mode = "")
  v
MerceTheme public API
  |
  | map brand->theme, mode->variant (names only; no path derivation)
  v
MerceThemeManifestLoader::load(theme, variant)
  |
  +--> unknown theme/variant -> ok=false, usedFallback=false, errors
  |
  +--> registered manifest ok -> ok=true, theme/variant requested or registry-effective
  |
  +--> registered manifest broken -> try registry default fallback
             |
             +--> fallback ok -> ok=true, usedFallback=true, theme/variant = actual fallback
             +--> fallback failed -> ok=false
  |
  v
MerceTheme::applyLoadedTheme(result)
  |
  +--> ok=false: log, return false, preserve active state and values
  |
  +--> ok=true: apply palette/spacing/radius/typography sections
               update activeBrand/activeMode from result.theme/result.variant
               emit active notify if changed
  |
  v
Stable QObject sub-objects emit changed()
  |
  v
Existing QML bindings re-evaluate without UI recreation
```

### Recommended Project Structure

```text
Core/Theme/
├── MerceTheme.h                       # add activeBrand/activeMode and setTheme()
├── MerceTheme.cpp                     # factor apply helper, update state semantics
├── MerceThemeManifest.h               # existing load result already carries theme/variant/usedFallback
├── MerceThemeManifestLoader.*         # reuse loadDefault()/load(); no public QML terms needed
└── MerceThemeRegistry.*               # no change expected unless tests expose lookup semantics gap

tests/Core/
├── CMakeLists.txt                     # add new merce_add_qtest target
└── tst_merce_theme_runtime_switch.cpp # API/state/pointer/value tests

playground/
├── ThemeProbe.qml                     # extend, or
└── ThemeSwitchProbe.qml               # focused QML binding probe
```

### Pattern 1: Reusable Apply Helper in `MerceTheme`

**What:** Factor constructor logic into a private helper such as `bool applyLoadedTheme(const MerceThemeLoadResult &result, bool updateActiveState)`. The helper should apply only `palette`, `spacing`, `radius`, and `typography` sections because those are the Phase 3 supported manifest-backed sections. [VERIFIED: Core/Theme/MerceTheme.cpp][VERIFIED: .planning/phases/03-manifest-registry-and-loader/03-05-SUMMARY.md]

**When to use:** Constructor default load and runtime `setTheme()` should share it. [VERIFIED: Core/Theme/MerceTheme.cpp][VERIFIED: 04-CONTEXT.md D-11]

**Example:**

```cpp
// Source: repo pattern in Core/Theme/MerceTheme.cpp + Phase 04 context
bool MerceTheme::applyLoadedTheme(const MerceThemeLoadResult &theme)
{
    if (!theme.ok)
        return false;

    const QJsonObject manifest = theme.finalManifest;
    m_palette->applyManifestSection(manifest.value(QStringLiteral("palette")).toObject());
    m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
    m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
    m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());

    setActiveThemeState(theme.theme, theme.variant);
    return true;
}
```

### Pattern 2: `CONSTANT` Pointer Properties + Sub-Object `NOTIFY`

**What:** Make top-level object pointer properties `CONSTANT` only when the pointer identity truly never changes. Keep value properties such as `MercePalette::backgroundBase` and `MerceSpacing::md` with `NOTIFY changed`. [VERIFIED: 04-CONTEXT.md D-10/D-13][VERIFIED: Core/Theme/MercePalette.h][CITED: Qt docs properties.html]

**When to use:** Use for `Theme.palette`, `Theme.colors`, `Theme.spacing`, `Theme.radius`, and `Theme.typography`. The current code also keeps motion/icons/zIndex/breakpoints/shadows pointers stable, but Phase 4 switching does not apply manifest values to those sections. [VERIFIED: Core/Theme/MerceTheme.h][VERIFIED: .planning/phases/03-manifest-registry-and-loader/03-05-SUMMARY.md]

**Why:** Qt says a `CONSTANT` property must return the same value for a given object instance and cannot have `WRITE` or `NOTIFY`; QML binding dependencies are re-evaluated when values referenced in the binding change. [CITED: Qt docs properties.html][CITED: Qt docs qtqml-syntax-propertybinding.html]

### Pattern 3: Actual-Applied Active State

**What:** Set `activeBrand` and `activeMode` from `MerceThemeLoadResult.theme` and `.variant` after successful apply, not from the original request strings. [VERIFIED: 04-CONTEXT.md D-08][VERIFIED: Core/Theme/MerceThemeManifest.h]

**When to use:** Required for registered broken manifests where loader returns a fallback result. Existing tests already show fallback result carries `theme="merce"` and `variant="light"`. [VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp]

### Anti-Patterns to Avoid

- **Replacing theme sub-objects:** breaks pointer stability and invalidates the `CONSTANT` contract. [VERIFIED: 04-CONTEXT.md D-10/D-13][CITED: Qt docs properties.html]
- **Emitting top-level pointer notify as the binding mechanism:** Phase 4 explicitly says value binding correctness must come from sub-object `changed` signals. [VERIFIED: 04-CONTEXT.md D-12/D-14]
- **Updating active state before apply succeeds:** invalid requests must preserve active state and values. [VERIFIED: 04-CONTEXT.md D-07]
- **Using requested state after fallback:** fallback active state must reflect the applied fallback result. [VERIFIED: 04-CONTEXT.md D-08]
- **Changing Qt Quick Controls style family in `setTheme()`:** Qt Quick Controls style cannot be changed after controls QML types are registered. [CITED: Qt docs qquickstyle.html]

## Existing Code Paths To Read And Modify

| Area | Read | Modify | Planning Notes |
|------|------|--------|----------------|
| `MerceTheme` public API | `Core/Theme/MerceTheme.h`, `Core/Theme/MerceTheme.cpp` | Yes | Add active properties, `setTheme`, private apply/state helpers, and likely convert stable pointer properties to `CONSTANT`. [VERIFIED: Core/Theme/MerceTheme.h][VERIFIED: Core/Theme/MerceTheme.cpp] |
| Loader | `Core/Theme/MerceThemeManifestLoader.h/.cpp`, `Core/Theme/MerceThemeManifest.h` | Probably no | Reuse `loadDefault()` and `load(theme, variant)`; result already includes `theme`, `variant`, `usedFallback`, `errors`, and `finalManifest`. [VERIFIED: Core/Theme/MerceThemeManifestLoader.h][VERIFIED: Core/Theme/MerceThemeManifest.h] |
| Registry | `Core/Theme/MerceThemeRegistry.h/.cpp` | Probably no | Current lookup maps default theme with empty variant to default variant, and single-manifest `stripe` keeps empty variant. [VERIFIED: Core/Theme/MerceThemeRegistry.cpp][VERIFIED: generated/themes/index.json] |
| Generated registry/manifests | `generated/themes/index.json`, `merce.light.json`, `merce.dark.json`, `stripe.json`, `merce.default.json` | No expected | Use values for tests: light background `#FAF8F6`, dark background `#1F1510`, Stripe background `#F6F9FC`, Stripe active mode empty. [VERIFIED: generated/themes/merce.light.json][VERIFIED: generated/themes/merce.dark.json][VERIFIED: generated/themes/stripe.json] |
| CMake/test harness | `tests/Core/CMakeLists.txt`, `tests/CMakeLists.txt`, `CMakeLists.txt` | Yes for new test target | Use `merce_add_qtest`; top-level already enables `BUILD_TESTING` and finds Qt Test. [VERIFIED: tests/Core/CMakeLists.txt][VERIFIED: CMakeLists.txt] |
| QML probe | `playground/ThemeProbe.qml`, `playground/main.cpp`, `playground/CMakeLists.txt` | Yes | Extend existing `--theme-probe` or add `ThemeSwitchProbe.qml`; `main.cpp` currently selects only `ThemeProbe` for `--theme-probe`, so adding a second probe needs argument routing. [VERIFIED: playground/ThemeProbe.qml][VERIFIED: playground/main.cpp][VERIFIED: playground/CMakeLists.txt] |

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON registry/theme loading | Custom string parser or path derivation | Existing `MerceThemeManifestLoader` and `MerceThemeRegistry` | Already validates schema, paths, fallback, and unknown requests. [VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp][VERIFIED: Core/Theme/MerceThemeRegistry.cpp] |
| QML binding invalidation | Manual QML refresh hooks or UI recreation | QObject `NOTIFY` signals on sub-object value properties | QML binding engine tracks dependencies in binding expressions. [CITED: Qt docs qtqml-syntax-propertybinding.html] |
| Runtime style family changes | `QQuickStyle::setStyle()` inside `Theme.setTheme()` | Merce semantic value switching only | Qt style must be configured before Controls QML is loaded. [CITED: Qt docs qquickstyle.html] |
| UI automation dependency | Spix or gallery automation | Existing QtTest plus offscreen QML probe | Phase context explicitly excludes Spix/gallery work. [VERIFIED: 04-CONTEXT.md D-15/D-18] |

**Key insight:** Phase 4 should change state inside the existing `Theme` singleton, not change the composition of the QML scene, the Qt Quick Controls style, or the generated manifest registry. [VERIFIED: ROADMAP.md][VERIFIED: 04-CONTEXT.md]

## API / State Update Strategy

| Scenario | Loader Result | `setTheme` Return | Apply Values? | Active State |
|----------|---------------|-------------------|---------------|--------------|
| `Theme.setTheme("merce", "dark")` | `ok=true`, `theme=merce`, `variant=dark` | `true` | Yes | `activeBrand="merce"`, `activeMode="dark"` [VERIFIED: generated/themes/index.json][VERIFIED: generated/themes/merce.dark.json] |
| `Theme.setTheme("merce", "light")` | `ok=true`, `theme=merce`, `variant=light` | `true` | Yes | `activeBrand="merce"`, `activeMode="light"` [VERIFIED: generated/themes/index.json][VERIFIED: generated/themes/merce.light.json] |
| `Theme.setTheme("stripe")` | `ok=true`, `theme=stripe`, `variant=""` | `true` | Yes | `activeBrand="stripe"`, `activeMode=""` [VERIFIED: 04-CONTEXT.md D-04][VERIFIED: generated/themes/index.json][VERIFIED: generated/themes/stripe.json] |
| Unknown brand | `ok=false`, `usedFallback=false` | `false` | No | Preserve previous active state and values. [VERIFIED: 04-CONTEXT.md D-07][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Unknown mode for registered brand | `ok=false`, `usedFallback=false` | `false` | No | Preserve previous active state and values. [VERIFIED: 04-CONTEXT.md D-07][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Registered broken manifest with valid fallback | `ok=true`, `usedFallback=true`, `theme/variant=fallback` | `true` | Yes | Reflect fallback `theme/variant`, not request. [VERIFIED: 04-CONTEXT.md D-08][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |

Recommended state flow: load first, return false immediately on `!ok`, apply supported sections, then update active state and emit active notify only if `activeBrand` or `activeMode` changed. [VERIFIED: 04-CONTEXT.md][CITED: Qt docs properties.html]

## Common Pitfalls

### Pitfall 1: `CONSTANT` Misuse
**What goes wrong:** Marking a pointer property `CONSTANT` while replacing the pointed object later makes the meta-object contract false. [CITED: Qt docs properties.html]  
**Why it happens:** Confusing stable pointer identity with mutable value state. [VERIFIED: 04-CONTEXT.md D-10/D-13]  
**How to avoid:** Allocate sub-objects once in the constructor and never replace them; mutate their stored values only. [VERIFIED: Core/Theme/MerceTheme.cpp]  
**Warning signs:** `new MercePalette` or assignment to `m_palette` outside constructor. [VERIFIED: Core/Theme/MerceTheme.cpp]

### Pitfall 2: Active State Drift On Failure
**What goes wrong:** `activeBrand` changes to an invalid request even though applied values were preserved. [VERIFIED: 04-CONTEXT.md D-07]  
**Why it happens:** Updating state before checking loader/apply success. [VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp]  
**How to avoid:** Treat loader result as a transaction: no state mutation until final `ok` and value apply succeed. [VERIFIED: 04-CONTEXT.md D-07/D-08]  
**Warning signs:** Tests pass `setTheme("unknown") == false` but do not compare previous active state and previous palette value. [VERIFIED: 04-CONTEXT.md D-16]

### Pitfall 3: Fallback State Uses Request, Not Result
**What goes wrong:** A broken registered theme applies fallback values but reports the broken brand as active. [VERIFIED: 04-CONTEXT.md D-08]  
**Why it happens:** `setTheme()` copies request strings instead of `MerceThemeLoadResult.theme/variant`. [VERIFIED: Core/Theme/MerceThemeManifest.h]  
**How to avoid:** Always update active state from loader result after apply. [VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp]

### Pitfall 4: QML Probe Uses One-Shot Reads Only
**What goes wrong:** Probe verifies final value but not binding invalidation. [VERIFIED: playground/ThemeProbe.qml]  
**Why it happens:** Existing `ThemeProbe.qml` reads values in `Component.onCompleted`; Phase 4 needs a bound property plus signal/binding update assertion. [VERIFIED: playground/ThemeProbe.qml][VERIFIED: 04-CONTEXT.md D-17]  
**How to avoid:** Add a `property color observedBackground: Theme.palette.backgroundBase`, capture it before/after `Theme.setTheme("merce", "dark")`, and verify it changes without replacing `Theme.palette`. [CITED: Qt docs qtqml-syntax-propertybinding.html]

### Pitfall 5: Accidental Qt Quick Controls Style Scope Creep
**What goes wrong:** Planner adds QuickControls2 style switching or Material/Universal theme work. [VERIFIED: REQUIREMENTS.md RUNTIME-03]  
**Why it happens:** Brand/mode names are confused with Qt Quick Controls style families. [VERIFIED: PROJECT.md]  
**How to avoid:** Do not link `Qt6::QuickControls2`, include `QQuickStyle`, or edit `qtquickcontrols2.conf` in Phase 4. [CITED: Qt docs qquickstyle.html]

## Code Examples

### Public API Shape

```cpp
// Source: Phase 04 context + Qt Property System docs
Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)
Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)
Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString());
```

### Stable Pointer Property Shape

```cpp
// Source: Phase 04 context + Qt Property System docs
Q_PROPERTY(MercePalette *palette READ palette CONSTANT FINAL)
Q_PROPERTY(MercePalette *colors READ colors CONSTANT FINAL)
Q_PROPERTY(MerceSpacing *spacing READ spacing CONSTANT FINAL)
Q_PROPERTY(MerceRadius *radius READ radius CONSTANT FINAL)
Q_PROPERTY(MerceTypography *typography READ typography CONSTANT FINAL)
```

### Focused QML Binding Probe Pattern

```qml
// Source: Qt QML property binding docs + existing playground/ThemeProbe.qml
import QtQml
import Merce.Core

QtObject {
    property var paletteObject: Theme.palette
    property color observedBackground: Theme.palette.backgroundBase

    Component.onCompleted: {
        const before = String(observedBackground).toLowerCase()
        if (!Theme.setTheme("merce", "dark"))
            Qt.exit(1)

        const after = String(observedBackground).toLowerCase()
        if (paletteObject !== Theme.palette
                || before !== "#faf8f6"
                || after !== "#1f1510"
                || Theme.activeBrand !== "merce"
                || Theme.activeMode !== "dark") {
            Qt.exit(1)
            return
        }
        Qt.quit()
    }
}
```

## Test Strategy

### C++ QtTest Assertions

| Test | Assertions | Source |
|------|------------|--------|
| Default active state | New `MerceTheme` applies default `merce/light`; `activeBrand=="merce"`, `activeMode=="light"`, `palette()->backgroundBase()=="#FAF8F6"`. | [VERIFIED: generated/themes/index.json][VERIFIED: generated/themes/merce.light.json] |
| Switch to dark | `setTheme("merce", "dark") == true`; active state is `merce/dark`; palette background becomes `#1F1510`; `palette()` pointer before/after is identical. | [VERIFIED: generated/themes/merce.dark.json][VERIFIED: 04-CONTEXT.md D-10/D-16] |
| Switch back to light | `setTheme("merce", "light") == true`; value returns to `#FAF8F6`; spacing/radius/typography values remain valid. | [VERIFIED: generated/themes/merce.light.json] |
| Single-manifest theme | `setTheme("stripe") == true`; `activeBrand=="stripe"`; `activeMode==""`; background `#F6F9FC`; `radius()->button()==8`. | [VERIFIED: generated/themes/index.json][VERIFIED: generated/themes/stripe.json][VERIFIED: 04-CONTEXT.md D-04] |
| Unknown brand preservation | After dark, `setTheme("unknown", "dark") == false`; active state remains `merce/dark`; palette remains `#1F1510`. | [VERIFIED: 04-CONTEXT.md D-07] |
| Unknown mode preservation | After dark, `setTheme("merce", "unknown") == false`; active state and values unchanged. | [VERIFIED: 04-CONTEXT.md D-07][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Fallback active semantics | With a temp index containing a registered broken theme and valid default, `setTheme("broken") == true`; active state is fallback `merce/light`. | [VERIFIED: 04-CONTEXT.md D-08][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp] |
| Meta-object contract | `QMetaProperty("palette").isConstant()` is true after conversion; value properties like `MercePalette::backgroundBase` have notify. | [CITED: Qt docs qmetaproperty.html][VERIFIED: 04-CONTEXT.md D-13] |

Use a new target such as `tst_merce_theme_runtime_switch` added through `merce_add_qtest(...)`. [VERIFIED: tests/Core/CMakeLists.txt]

### QML Probe Assertions

| Probe Step | Assertion |
|------------|-----------|
| Capture pointer | `const paletteObject = Theme.palette` or `property var paletteObject: Theme.palette`; pointer stays equal after switch. [VERIFIED: 04-CONTEXT.md D-10] |
| Bound value before switch | Bound `observedBackground: Theme.palette.backgroundBase` starts as `#faf8f6`. [VERIFIED: generated/themes/merce.light.json] |
| Runtime call | `Theme.setTheme("merce", "dark") === true`. [VERIFIED: 04-CONTEXT.md D-01/D-06] |
| Binding update | `observedBackground` becomes `#1f1510` without recreating UI. [VERIFIED: generated/themes/merce.dark.json][CITED: Qt docs qtqml-syntax-propertybinding.html] |
| Active state | `Theme.activeBrand === "merce"` and `Theme.activeMode === "dark"`. [VERIFIED: 04-CONTEXT.md D-01/D-17] |
| Invalid preservation | Optional focused probe can call invalid switch after dark and assert value/state unchanged. [VERIFIED: 04-CONTEXT.md D-07] |

Existing verification commands that currently pass:

```bash
ctest --test-dir build --output-on-failure
env QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-probe
```

[VERIFIED: command output 2026-06-04]

## Recommended Plan Slicing

1. **API and apply helper:** add active properties, `setTheme`, stable `CONSTANT` pointer properties, and reusable apply/state helper in `MerceTheme`. [VERIFIED: Core/Theme/MerceTheme.h][VERIFIED: Core/Theme/MerceTheme.cpp]
2. **C++ tests:** add `tst_merce_theme_runtime_switch.cpp` covering success, single-manifest mode, invalid preservation, pointer stability, and fallback active semantics. [VERIFIED: tests/Core/CMakeLists.txt][VERIFIED: 04-CONTEXT.md D-16]
3. **QML probe:** extend `ThemeProbe.qml` or add a focused switch probe and route it in `playground/main.cpp`. [VERIFIED: playground/ThemeProbe.qml][VERIFIED: playground/main.cpp][VERIFIED: 04-CONTEXT.md D-17]
4. **Verification pass:** run CTest and offscreen probe; do not add Spix, gallery, or style-family work. [VERIFIED: 04-CONTEXT.md D-15/D-18][CITED: Qt docs qquickstyle.html]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| One-shot default manifest apply in constructor | Reusable apply path for constructor and runtime switch | Phase 4 planned from Phase 3 default apply | Prevents duplicate apply logic and makes state semantics testable. [VERIFIED: Core/Theme/MerceTheme.cpp][VERIFIED: .planning/phases/03-manifest-registry-and-loader/03-05-SUMMARY.md] |
| Top-level pointer `NOTIFY` as value-change signal | Stable pointer `CONSTANT`, sub-object value `NOTIFY changed` | Phase 4 decision | Matches Qt property semantics and preserves QML bindings. [VERIFIED: 04-CONTEXT.md D-12/D-14][CITED: Qt docs properties.html] |
| Qt Quick Controls style as theme | Merce semantic token runtime only | Requirement RUNTIME-03 | Keeps runtime switching inside Merce values and avoids unsupported style-family changes. [VERIFIED: REQUIREMENTS.md][CITED: Qt docs qquickstyle.html] |

**Deprecated/outdated for this phase:**
- Adding `Theme.activeTheme`/`activeVariant` as public names: public API is locked to `activeBrand`/`activeMode`. [VERIFIED: 04-CONTEXT.md D-01/D-02]
- Field-by-field fallback between base and active manifests: Phase 3 locked section-level overlay and strict validation. [VERIFIED: .planning/phases/03-manifest-registry-and-loader/03-CONTEXT.md]
- Spix/gallery verification: deferred to Phase 5. [VERIFIED: 04-CONTEXT.md D-18]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|

**If this table is empty:** All claims in this research were verified from repo evidence, phase context, command output, or cited Qt documentation.

## Open Questions (Resolved)

1. **Should `mode` default to `"light"` for single-manifest brands?**
   - Resolution: No. Phase context locks single-manifest themes to empty mode; `Theme.setTheme("stripe")` should produce `activeMode == ""`. [VERIFIED: 04-CONTEXT.md D-04][VERIFIED: generated/themes/index.json]
2. **Should active state show the requested broken brand when fallback is applied?**
   - Resolution: No. Active state must reflect the actual applied fallback result. [VERIFIED: 04-CONTEXT.md D-08][VERIFIED: tests/Core/tst_merce_theme_manifest_loader.cpp]
3. **Can top-level pointer properties be `CONSTANT` while sub-values change?**
   - Resolution: Yes, if the pointer value itself stays constant; mutable values must be exposed as separate sub-object properties with `NOTIFY`. [VERIFIED: 04-CONTEXT.md D-10/D-13][CITED: Qt docs properties.html][CITED: Qt docs qtqml-syntax-propertybinding.html]
4. **Should Phase 4 verify with Spix or a gallery?**
   - Resolution: No. Phase 4 uses QtTest plus focused QML probe; Spix/gallery are deferred. [VERIFIED: 04-CONTEXT.md D-15/D-18]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| CMake / CTest | Build and test execution | Yes | 4.3.1 | None needed. [VERIFIED: cmake --version][VERIFIED: ctest --version] |
| Qt 6 | Merce runtime, QtTest, QML probe | Yes | Required 6.11; build tree has Qt 6.11.1 profile | None needed. [VERIFIED: CMakeLists.txt][VERIFIED: build tree] |
| Existing CTest build | C++ test verification | Yes | 2 current tests passing | Reconfigure/build if stale. [VERIFIED: ctest --test-dir build --output-on-failure] |
| `MercePlayground` | QML probe | Yes | Existing executable under `build/playground/MercePlayground` | Use `build/Qt_6_11_1_for_macOS-Debug/playground/MercePlayground` if alternate build profile is needed. [VERIFIED: find build MercePlayground][VERIFIED: probe command output] |
| Node/npm | Optional token regeneration | Yes | Node v25.9.0, npm 11.12.1 | Not required for Phase 4 unless token files are regenerated. [VERIFIED: node --version][VERIFIED: npm --version] |

**Missing dependencies with no fallback:** none found. [VERIFIED: environment audit]

**Missing dependencies with fallback:** none found. [VERIFIED: environment audit]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | No auth surface in Phase 4. [VERIFIED: phase scope] |
| V3 Session Management | no | No session surface in Phase 4. [VERIFIED: phase scope] |
| V4 Access Control | no | Public API only selects registered manifests already constrained by registry lookup. [VERIFIED: Core/Theme/MerceThemeRegistry.cpp] |
| V5 Input Validation | yes | Accept only registry-registered brand/mode strings through `MerceThemeManifestLoader::load`; preserve state on unknown input. [VERIFIED: Core/Theme/MerceThemeManifestLoader.cpp][VERIFIED: 04-CONTEXT.md D-07] |
| V6 Cryptography | no | No cryptographic behavior in Phase 4. [VERIFIED: phase scope] |

### Known Threat Patterns for Qt/QML Theme Runtime

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Path traversal through brand/mode | Tampering | Do not derive paths from user strings; use existing registry lookup and safe paths. [VERIFIED: Core/Theme/MerceThemeRegistry.cpp] |
| State confusion after failed switch | Tampering / Reliability | Treat switch as transactional; do not mutate active state or values on unknown input. [VERIFIED: 04-CONTEXT.md D-07] |
| Runtime dependency injection | Tampering | Do not add Node/Style Dictionary runtime dependency or external manifest loading in Phase 4. [VERIFIED: PROJECT.md][VERIFIED: REQUIREMENTS.md Out of Scope] |

## Validation Architecture

Skipped because `.planning/config.json` explicitly sets `workflow.nyquist_validation` to `false`. Phase 4 still has concrete verification recommendations in the Test Strategy section. [VERIFIED: .planning/config.json]

## Sources

### Primary (HIGH confidence)
- `.planning/phases/04-runtime-brand-mode-switching/04-CONTEXT.md` - locked Phase 4 decisions, scope, and verification boundary.
- `.planning/REQUIREMENTS.md` - RUNTIME-01 through RUNTIME-04.
- `.planning/ROADMAP.md` - Phase 4 goal and success criteria.
- `.planning/PROJECT.md` - project constraints and runtime direction.
- `Core/Theme/MerceTheme.h`, `Core/Theme/MerceTheme.cpp` - current singleton and default apply path.
- `Core/Theme/MerceThemeManifestLoader.*`, `Core/Theme/MerceThemeRegistry.*`, `Core/Theme/MerceThemeManifest.h` - loader, registry, result semantics.
- `Core/Theme/MercePalette.h`, `MerceSpacing.h`, `MerceRadius.h`, `MerceTypography.h` - sub-object properties, `changed` signals, apply methods.
- `generated/themes/index.json`, `merce.light.json`, `merce.dark.json`, `stripe.json`, `merce.default.json` - deterministic test values and sparse theme model.
- `tests/Core/CMakeLists.txt`, `playground/ThemeProbe.qml`, `playground/main.cpp` - established verification patterns.
- Qt docs via `mcp__qt_docs`: `properties.html`, `qtqml-syntax-propertybinding.html`, `qquickstyle.html`, `qml-singleton.html`, `qmetaproperty.html`.

### Secondary (MEDIUM confidence)
- `.planning/phases/03-manifest-registry-and-loader/03-CONTEXT.md` and `03-05-SUMMARY.md` - previous phase boundary and completion evidence.
- Local command outputs on 2026-06-04: `ctest --test-dir build --output-on-failure` and `env QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-probe`.

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - existing Qt/CMake/CTest stack verified locally; no new packages recommended.
- Architecture: HIGH - Phase 4 decisions are explicit and align with current `Core/Theme` code paths.
- Binding semantics: HIGH - verified against Qt 6.11 property and QML binding documentation.
- Pitfalls: HIGH - derived from Phase 4 decisions, Phase 3 implementation, and Qt docs.

**Research date:** 2026-06-04
**Valid until:** 2026-07-04 for repo-local planning; re-check Qt docs if upgrading beyond Qt 6.11 or changing Quick Controls style strategy.
