# Phase 4: Runtime Brand/Mode Switching - Context

**Gathered:** 2026-06-04T09:47:54+03:00
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement public QML runtime switching for registered Merce theme manifests. This phase owns `Theme.setTheme(brand, mode)`, queryable active brand/mode state, binding-safe value updates, and focused verification that QML bindings update without recreating the UI.

This phase does not introduce Qt Quick Controls style-family switching, generated-token exposure, broad component rewrites, playground gallery work, or new UI automation dependencies.

</domain>

<decisions>
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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Planning Scope
- `.planning/PROJECT.md` - project context, constraints, and current C++ theme runtime direction.
- `.planning/REQUIREMENTS.md` - Phase 4 requirements `RUNTIME-01` through `RUNTIME-04`.
- `.planning/ROADMAP.md` - Phase 4 boundary and success criteria.
- `.planning/phases/01-theme-runtime-contract/01-CONTEXT.md` - locked public `Theme` singleton and typed runtime API decisions.
- `.planning/phases/02-token-build-pipeline/02-CONTEXT.md` - locked sparse theme/variant and manifest/index decisions.
- `.planning/phases/03-manifest-registry-and-loader/03-CONTEXT.md` - locked registry, loader, fallback, base overlay, and resource packaging decisions.

### Theme Runtime And Loader
- `CMakeLists.txt` - top-level C++20 baseline and Qt 6.11 setup.
- `Core/Theme/MerceTheme.h` - public `Theme` singleton properties and signals to update for Phase 4.
- `Core/Theme/MerceTheme.cpp` - current default manifest apply path; Phase 4 should factor this into reusable apply/switch behavior.
- `Core/Theme/MerceThemeManifestLoader.h` - existing `loadDefault()` and `load(theme, variant)` API.
- `Core/Theme/MerceThemeManifestLoader.cpp` - existing load, validation, fallback, and final manifest behavior.
- `Core/Theme/MerceThemeRegistry.h` - registry lookup structures and normalized theme/variant entries.
- `Core/Theme/MerceThemeRegistry.cpp` - current lookup behavior for default variants and single-manifest themes.
- `generated/themes/index.json` - authoritative registry showing `merce` variants and single-manifest `stripe`.

### Verification
- `playground/ThemeProbe.qml` - existing focused QML probe pattern.
- `tests/Core/tst_merce_theme_manifest_loader.cpp` - existing QtTest style and manifest loader edge-case coverage.

### External References
- `https://github.com/faaxm/spix` - optional UI automation library discussed for later gallery-level testing.
- `https://github.com/faaxm/spix/blob/master/docs/qtquick-guide.md` - Spix QtQuick integration notes.
- `https://github.com/faaxm/spix/blob/master/docs/rpc-api.md` - Spix RPC/property/method automation reference.
- `https://doc.qt.io/qt-6/properties.html` - Qt Property System semantics for `CONSTANT` and `NOTIFY`.
- `https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html` - QML binding dependency behavior.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MerceThemeManifestLoader::load(theme, variant)` already supports requested loads, unknown input rejection, and fallback for registered bad manifests.
- `MerceThemeRegistry::lookup(theme, variant)` already normalizes default variant behavior for the default theme and supports single-manifest entries with an empty variant.
- `MercePalette`, `MerceSpacing`, `MerceRadius`, and `MerceTypography` already expose value properties with `NOTIFY changed` and `applyManifestSection(...)` methods.
- `playground/ThemeProbe.qml` already imports `Merce.Core` and checks runtime theme values without loading the full playground UI.

### Established Patterns
- Component-facing theme access stays behind `Theme`; components do not consume raw DTCG paths, generated manifests, or registry internals.
- Generated manifests are packaged into `MerceCore` resources under `:/merce/themes`, and `index.json` remains the authoritative physical path registry.
- Style Dictionary and Node remain build-time tooling only; normal runtime switching must not depend on Node.
- Current Phase 3 apply support is palette, spacing, radius, and typography. Motion, iconography, z-index, breakpoints, and shadows remain construction defaults until a later phase expands manifest support.

### Integration Points
- Add public invokable/property API in `Core/Theme/MerceTheme.h`.
- Factor manifest application in `Core/Theme/MerceTheme.cpp` so construction default load and runtime switch share the same apply path.
- Add tests under `tests/Core` following the existing QtTest pattern.
- Extend or add a focused probe under `playground` to prove QML binding updates.

</code_context>

<specifics>
## Specific Ideas

- Candidate public API:
  ```cpp
  Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)
  Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)
  Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString());
  ```
- Candidate stable object properties:
  ```cpp
  Q_PROPERTY(MercePalette *palette READ palette CONSTANT FINAL)
  Q_PROPERTY(MercePalette *colors READ colors CONSTANT FINAL)
  Q_PROPERTY(MerceSpacing *spacing READ spacing CONSTANT FINAL)
  Q_PROPERTY(MerceRadius *radius READ radius CONSTANT FINAL)
  Q_PROPERTY(MerceTypography *typography READ typography CONSTANT FINAL)
  ```
- Candidate QML usage:
  ```qml
  Theme.setTheme("merce", "dark")
  Theme.setTheme("merce", "light")
  Theme.setTheme("stripe")
  ```
- For `stripe`, `Theme.activeBrand == "stripe"` and `Theme.activeMode == ""`.
- Invalid request example: after `Theme.setTheme("merce", "dark")`, `Theme.setTheme("unknown", "dark")` returns `false` and keeps `activeBrand`, `activeMode`, and bound values unchanged.

</specifics>

<deferred>
## Deferred Ideas

- Evaluate Spix as an optional Phase 5 playground/gallery UI automation tool, gated behind an opt-in test option such as `MERCE_ENABLE_SPIX_TESTS=ON` if adopted.
- Playground visual theme gallery and screenshot automation belong to Phase 5, not Phase 4.
- QML-visible diagnostics such as `Theme.lastError` or `Theme.usedFallback` can be reconsidered later if verification or consumer UX needs them.

</deferred>

---

*Phase: 04-runtime-brand-mode-switching*
*Context gathered: 2026-06-04T09:47:54+03:00*
