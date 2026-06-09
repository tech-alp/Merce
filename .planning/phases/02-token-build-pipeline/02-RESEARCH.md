# Phase 2: Token Build Pipeline - Research

**Date:** 2026-06-03
**Phase:** 02-token-build-pipeline
**Question:** What do we need to know to plan a DTCG + Style Dictionary v5 token pipeline for Merce?

## Findings

### Style Dictionary v5 Constraints

- Style Dictionary v5 requires Node.js 22.0.0 or newer. The token tooling workspace should declare this with `engines.node >=22.0.0` and Merce runtime should not depend on Node.
- Style Dictionary supports DTCG-style tokens using `$value`, `$type`, and `$description`; Merce token sources should use one token format consistently rather than mixing legacy `value/type` and DTCG `$value/$type`.
- v5 is stricter about token references. References should point to real design token leaves, not arbitrary groups or nested non-token properties.
- Custom output is a normal Style Dictionary use case. `registerFormat` can produce a string and `buildAllPlatforms()` can write it to disk, which fits a generated Merce manifest JSON format.

Sources:
- Style Dictionary v5 migration: https://styledictionary.com/versions/v5/migration/
- Style Dictionary formats/custom formats: https://styledictionary.com/reference/hooks/formats/
- Style Dictionary config: https://styledictionary.com/reference/config/
- Style Dictionary API: https://styledictionary.com/reference/api/
- Style Dictionary tokens and DTCG docs: https://styledictionary.com/info/tokens/

### Merce Pipeline Shape

- The pipeline should treat DTCG files as source and generated Merce manifests as build artifacts.
- The generated manifest should be runtime-shaped, not raw DTCG-shaped. This preserves the Phase 1 decision that `Theme` is the public contract and avoids exposing raw token paths to QML.
- The current Phase 1 C++ runtime exposes typed values such as `Theme.palette.textPrimary`, `Theme.spacing.md`, `Theme.radius.button`, and `Theme.typography.bodyFont`. Those names are the right target for the manifest formatter.
- Do not emit compatibility paths such as `colors.background.base` into manifest JSON. The C++ runtime can derive compatibility aliases later.

### Sparse Theme/Variant Model

- The previous "brand x mode" wording should not force every design system to support light/dark variants.
- Use a declared sparse theme set:
  - Single-manifest themes produce `generated/themes/{theme}.json`.
  - Variant themes produce `generated/themes/{theme}.{variant}.json`.
  - `generated/themes/index.json` is the authoritative mapping from theme/variant names to physical files.
- `defaultVariant` exists only for themes that actually have variants. A single-manifest theme such as `stripe` should not be called `light` by default.

### External DESIGN.md References

- `VoltAgent/awesome-design-md` is a curated collection of `DESIGN.md` files for many public design systems. The README says each file captures sections such as visual theme, color palette roles, typography rules, component styling, spacing/layout principles, depth/elevation, and responsive behavior.
- These documents can seed DTCG source tokens through AI-assisted extraction.
- AI output should not be canonical final manifest output. AI may produce DTCG source candidates, then Style Dictionary produces the final resolved Merce manifests.

Source:
- https://github.com/VoltAgent/awesome-design-md

## Planning Recommendations

1. Add `tools/design-tokens` as a bounded Node/npm tooling workspace with Style Dictionary as the only required third-party runtime dependency for that workspace.
2. Declare Node `>=22.0.0` in `tools/design-tokens/package.json`.
3. Store DTCG sources under `tools/design-tokens/tokens/`.
4. Store the declared sparse theme registry in a small JSON config, separate from DTCG token sources.
5. Generate manifests under `generated/themes/` so Phase 3 can package them into Qt resources later.
6. Add local validation without adding another third-party dependency unless implementation proves schema validation is too large to maintain.
7. Add deterministic output verification with a `--check` mode that fails if generated files differ from the committed output.
8. Keep CMake integration optional and default-off so Qt consumers do not need Node.

## Risks

- **Node dependency leak:** Avoid making normal CMake configure/build require Node. Use an optional target only.
- **AI nondeterminism:** Keep AI-generated DTCG as reviewed source, not generated build output.
- **Schema drift:** Version the manifest and validate required fields in Phase 2.
- **Path drift:** Let `index.json` define physical paths so Phase 3 does not hardcode a `{brand}/{mode}.json` assumption.
- **Scope creep:** Do not implement C++ manifest loading or runtime theme switching in Phase 2.

## RESEARCH COMPLETE

