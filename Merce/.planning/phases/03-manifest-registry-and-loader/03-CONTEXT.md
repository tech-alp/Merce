# Phase 3: Manifest Registry And Loader - Context

**Gathered:** 2026-06-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Package generated Merce theme manifests into Qt resources and load them through a safe C++ registry/loader. This phase owns `:/merce/themes/index.json`, resource packaging, registry normalization, manifest overlay, validation, default fallback, and applying the default resolved manifest to the existing typed `Theme` runtime.

This phase does not expose public QML theme switching. `Theme.setTheme(theme, variant)` and user-driven runtime switching remain Phase 4.

</domain>

<decisions>
## Implementation Decisions

### Registry Contract
- **D-01:** Keep `generated/themes/index.json` as the generated artifact and package it at runtime as `:/merce/themes/index.json`.
- **D-02:** Treat `index.json` as the authoritative physical path registry. C++ loaders must read manifest paths from the index and must not derive resource paths from theme or variant names.
- **D-03:** Manifest paths in `index.json` should be relative file names resolved against the resource directory containing `index.json`, e.g. `merce.light.json` resolves to `:/merce/themes/merce.light.json`.
- **D-04:** Reject path escape and non-resource indirection in v1: no absolute filesystem paths, no `../`, and no arbitrary `:/...` manifest paths inside the index.
- **D-05:** C++ should normalize the raw index into an internal registry view such as `{theme, displayName, optional variant, manifestPath}` so single-manifest themes and variant themes flow through the same loader path.
- **D-06:** The generated index schema should support an optional per-theme `basePath`, e.g. `basePath: "merce.default.json"`. The current generated index does not have this yet; Phase 3 planning should include the bounded generator/index update needed for it.

### Loader And Apply Boundary
- **D-07:** Phase 3 should implement loader plus default apply. The C++ loader reads the registry, resolves the default theme/variant, validates the resolved manifest, and applies it to the existing `MerceTheme` typed sub-objects.
- **D-08:** Do not expose public `Theme.setTheme(...)` in Phase 3. Public theme selection and binding-safe runtime switching belong to Phase 4.
- **D-09:** Existing hardcoded C++ theme values should become fallback construction/default data only where needed for implementation safety; the intended Phase 3 runtime source is the resolved resource manifest.

### Base Manifest Overlay
- **D-10:** A theme may declare a base/default manifest via `basePath`. For Merce, the intended shape is `merce.default.json` plus variant manifests such as `merce.light.json` and `merce.dark.json`.
- **D-11:** Base manifests are resolved runtime manifests, not raw DTCG references. Do not implement JSON reference resolution such as `{default.spacing}` in the C++ loader.
- **D-12:** Loader order is base first, active manifest second. The active single/variant manifest overlays the base manifest.
- **D-13:** Overlay is section-level, not field-level. If the active manifest contains `palette`, that whole section wins and must be complete. If it omits `palette`, the base section is used. Field-by-field fallback is intentionally rejected because it can hide bad generated output.
- **D-14:** Base manifests should be able to carry the full baseline for typed runtime sections, including `palette`, `spacing`, `radius`, `typography`, and the runtime support sections that were previously hardcoded such as `motion`, `iconography`, `zIndex`, `breakpoints`, and `shadows`, where Phase 3 chooses to load them.

### Validation And Fallback
- **D-15:** Validate in two stages: first validate `index.json`, then validate the final manifest produced by base plus active overlay.
- **D-16:** Use strict final validation. The final overlay result must have the supported schema version, expected theme identity, expected variant identity when present, and all required sections/fields for the sections Phase 3 supports.
- **D-17:** If a requested or active theme/variant fails to load or validate, fall back to the known registry default theme and default variant.
- **D-18:** If the registry default theme itself fails to load or validate, the loader should fail clearly and log the errors. Do not silently continue with an incomplete theme.
- **D-19:** Loader internals should return a structured result, e.g. `ok`, `theme`, `variant`, `usedFallback`, and `errors`, and should also log failures with `qWarning`.
- **D-20:** Do not add QML-visible error/status properties in Phase 3. Public diagnostics can be considered later if Phase 4 or Phase 5 needs them.

### Resource Packaging
- **D-21:** Package generated theme manifests into the `MerceCore` target because `Theme` runtime ownership is already in `MerceCore`.
- **D-22:** Use a fixed Qt resource prefix `/merce/themes`, producing the canonical runtime path `:/merce/themes/index.json`.
- **D-23:** Consuming applications should not need to add their own theme resource target for the built-in Merce manifests.
- **D-24:** Fail fast if required generated manifest artifacts are missing. If `generated/themes/index.json` or files listed by the index are absent, CMake configure/build should report a clear error.
- **D-25:** Do not auto-run `npm run build` from the normal Qt configure/build path. Node and Style Dictionary remain build/developer tooling, not a normal runtime or consumer build dependency.

### the agent's Discretion
- Exact C++ class names, file split, helper structs, and test names may follow existing `Core/Theme` and CMake conventions.
- The planner may decide whether base/default manifest generation is implemented by extending the existing token registry generator or by a small bounded manifest packaging step, as long as the runtime contract above is preserved.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Planning Scope
- `.planning/PROJECT.md` - project context, active requirements, constraints, and key decisions for Merce Theme Runtime.
- `.planning/REQUIREMENTS.md` - Phase 3 requirements `MANIFEST-01` through `MANIFEST-05`.
- `.planning/ROADMAP.md` - Phase 3 boundary and success criteria.
- `.planning/phases/01-theme-runtime-contract/01-CONTEXT.md` - locked public `Theme` API and C++ runtime decisions.
- `.planning/phases/02-token-build-pipeline/02-CONTEXT.md` - locked sparse theme/variant, generated manifest, and authoritative index decisions.

### Generated Theme Artifacts
- `generated/themes/index.json` - current generated registry artifact; Phase 3 should package this as `:/merce/themes/index.json` and extend it for `basePath`.
- `generated/themes/merce.light.json` - current Merce light manifest fixture.
- `generated/themes/merce.dark.json` - current Merce dark manifest fixture.
- `generated/themes/stripe.json` - current single-manifest theme fixture.

### Token Tooling
- `tools/design-tokens/README.md` - documents generated artifact ownership and current index behavior.
- `tools/design-tokens/themes.json` - source registry for generated themes; likely place to add `basePath` declarations.
- `tools/design-tokens/build.mjs` - writes `generated/themes/index.json` and manifest files.
- `tools/design-tokens/src/theme-registry.mjs` - current generated index and theme entry logic.
- `tools/design-tokens/src/validate-manifest.mjs` - current manifest validation rules.
- `tools/design-tokens/src/merce-manifest-format.mjs` - current manifest section mapping.

### Theme Runtime
- `Core/Theme/MerceTheme.h` - public `Theme` singleton and typed sub-object properties.
- `Core/Theme/MerceTheme.cpp` - current singleton construction and integration point for default loading.
- `Core/Theme/MercePalette.h` - current palette property shape and compatibility groups.
- `Core/Theme/MerceSpacing.h` - current spacing properties.
- `Core/Theme/MerceRadius.h` - current radius properties.
- `Core/Theme/MerceTypography.h` - current typography properties and presets.
- `Core/CMakeLists.txt` - `MerceCore` target where theme sources and resource packaging should connect.
- `CMakeLists.txt` - top-level optional token build target and normal Qt build constraints.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Core/Theme/MerceTheme.h`: already exposes `Theme.palette`, `Theme.colors`, `Theme.spacing`, `Theme.radius`, `Theme.typography`, `Theme.motion`, `Theme.icons`, `Theme.zIndex`, `Theme.breakpoints`, and `Theme.shadows`.
- `Core/Theme/MercePalette.h`, `MerceSpacing.h`, `MerceRadius.h`, and `MerceTypography.h`: define the property names that generated manifests must feed first.
- `tools/design-tokens/src/validate-manifest.mjs`: has build-time validation rules that Phase 3 can mirror or align with for runtime validation.
- `playground/ThemeProbe.qml`: can later verify that runtime values come from the packaged manifest, but broad gallery work belongs to Phase 5.

### Established Patterns
- Component-facing theme access stays behind `Theme`; components must not consume raw DTCG paths, generated manifest paths, or token implementation files.
- Style Dictionary and Node stay build-time only. Normal Qt runtime and consumer builds should use committed/packaged generated artifacts.
- Sparse themes are allowed. A theme can be single-manifest or variant-backed; loaders must not assume a cartesian brand x light/dark matrix.

### Integration Points
- `Core/CMakeLists.txt`: add generated theme resource packaging to `MerceCore` with prefix `/merce/themes`.
- `Core/Theme`: add the C++ registry/loader and wire default apply into `MerceTheme` construction or an equivalent initialization point.
- `tools/design-tokens/themes.json` and `src/theme-registry.mjs`: add `basePath` support so generated `index.json` can declare base/default manifests explicitly.

</code_context>

<specifics>
## Specific Ideas

- Intended runtime registry path: `:/merce/themes/index.json`.
- Intended repo artifact path: `generated/themes/index.json`.
- Candidate index shape:
  ```json
  {
    "schemaVersion": 1,
    "defaultTheme": "merce",
    "themes": {
      "merce": {
        "displayName": "Merce",
        "basePath": "merce.default.json",
        "defaultVariant": "light",
        "variants": {
          "light": "merce.light.json",
          "dark": "merce.dark.json"
        }
      }
    }
  }
  ```
- Candidate resolution: `merce.default.json` loads first, then `merce.light.json` overlays it by whole section.
- Candidate final fallback: if requested or active theme load fails, load registry default `merce` + `light`; if that fails, return failure and log.

</specifics>

<deferred>
## Deferred Ideas

- Public `Theme.setTheme(theme, variant)` and `Theme.activeTheme`/`Theme.activeVariant` belong to Phase 4.
- QML-visible loader diagnostics such as `Theme.lastError` or `Theme.usedFallback` can be reconsidered in Phase 4 or Phase 5 if needed.
- External filesystem theme loading and app-registered manifests remain v2/backlog capabilities.

</deferred>

---

*Phase: 03-manifest-registry-and-loader*
*Context gathered: 2026-06-03*
