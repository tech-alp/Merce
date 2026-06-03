# Roadmap: Merce Theme Runtime

**Created:** 2026-06-03
**Granularity:** Standard
**Mode:** Internal project, open-source friendly

## Overview

This roadmap phases Merce's theme work from current QML token facade toward a typed C++ theme runtime backed by DTCG token sources and Style Dictionary v5 generated Merce manifests.

| # | Phase | Goal | Requirements | UI hint |
|---|-------|------|--------------|---------|
| 1 | Theme Runtime Contract | 1/1 | Complete    | 2026-06-03 |
| 2 | Token Build Pipeline | 1/1 | Complete    | 2026-06-03 |
| 3 | Manifest Registry And Loader | 5/5 | Complete    | 2026-06-03 |
| 4 | Runtime Brand/Mode Switching | Implement `Theme.setTheme(brand, mode)` and binding-safe value updates | RUNTIME-01..RUNTIME-04 | yes |
| 5 | Verification And Gallery | Prove the runtime through tests, probes, smoke checks, and playground theme gallery | VERIFY-01..VERIFY-04 | yes |

## Phase Details

### Phase 1: Theme Runtime Contract

**Goal:** Establish the public C++-registered `Theme` singleton and typed sub-object API without rewriting every component at once.

**Requirements:** THEME-01, THEME-02, THEME-03, THEME-04, THEME-05

**Success criteria:**

1. `Theme` is registered into the Merce QML module from C++.
2. Supporting objects such as palette, spacing, radius, and typography are exposed through typed read-only properties.
3. Supporting objects are not directly creatable by QML consumers.
4. API naming is shallow enough for QML tooling, e.g. `Theme.palette.textPrimary`.
5. Existing component usage can be migrated incrementally without breaking the public module import shape.

**Notes:**

- This phase may keep the old QML `Theme.qml` temporarily as a compatibility adapter if needed.
- Do not expose raw generated token data to components.

**Plans:**

- Wave 1: `01-PLAN.md` - C++ Theme Runtime Contract. Complete: `01-SUMMARY.md` (2026-06-03).

**Cross-cutting constraints:**

- Preserve current `Theme` import shape while moving runtime ownership to C++.
- Keep generated/token source details out of component-facing API.
- Add `NOTIFY` support now so runtime switching can build on the same contract later.

### Phase 2: Token Build Pipeline

**Goal:** Add DTCG token sources and Style Dictionary v5 tooling that emits resolved Merce runtime manifests.

**Requirements:** TOKENS-01, TOKENS-02, TOKENS-03, TOKENS-04, TOKENS-05

**Success criteria:**

1. Core, brand, and theme/mode token layers are represented as DTCG JSON.
2. Style Dictionary v5 resolves aliases and layer overrides deterministically.
3. Output is a versioned Merce manifest, not public QML.
4. Consumers do not need Node or Style Dictionary at runtime.
5. The generated manifest format is documented.

**Plans:**

1/1 plans complete. Wave 1: `02-01-PLAN.md` - Style Dictionary Token Build Pipeline. Complete: `02-01-SUMMARY.md` (2026-06-03).

### Phase 3: Manifest Registry And Loader

**Goal:** Package generated manifests under `:/merce/themes/` and load them through a safe C++ registry using `index.json` as the authoritative path registry.

**Requirements:** MANIFEST-01, MANIFEST-02, MANIFEST-03, MANIFEST-04, MANIFEST-05

**Success criteria:**

1. `:/merce/themes/index.json` defines defaults, available themes, optional variants, display names, and manifest paths.
2. Resource paths are read from `index.json`, not derived from brand and variant names.
3. Loader validates schema version and required sections before applying.
4. Unknown theme or variant inputs are rejected with clear logs.
5. Loader falls back to a known default theme when manifest loading fails.

**Plans:**

5/5 plans complete

- [x] `03-01-PLAN.md` - Main-repo test harness for manifest loader validation. Complete: `03-01-SUMMARY.md` (2026-06-03).
- [x] `03-02-PLAN.md` - Generated index basePath and Merce base manifest artifacts. Complete: `03-02-SUMMARY.md` (2026-06-03).
- [x] `03-03-PLAN.md` - MerceCore Qt resource packaging for generated manifests. Complete: `03-03-SUMMARY.md` (2026-06-03).
- [x] `03-04-PLAN.md` - Safe C++ registry/loader with validation, overlay, fallback, and tests. Complete: `03-04-SUMMARY.md` (2026-06-03).
- [x] `03-05-PLAN.md` - Default manifest apply to typed Theme runtime and probe verification. Complete: `03-05-SUMMARY.md` (2026-06-03).

### Phase 4: Runtime Brand/Mode Switching

**Goal:** Allow runtime switching between registered brand/mode manifests while keeping QML bindings correct.

**Requirements:** RUNTIME-01, RUNTIME-02, RUNTIME-03, RUNTIME-04

**Success criteria:**

1. QML can call `Theme.setTheme("brand-a", "dark")`.
2. `Theme.activeBrand` and `Theme.activeMode` are queryable.
3. Palette/spacing/radius/typography bindings update through `NOTIFY` signals.
4. Switching does not attempt to change Qt Quick Controls style families at runtime.

### Phase 5: Verification And Gallery

**Goal:** Make the theme runtime observable, testable, and easy to validate through playground and automated checks.

**Requirements:** VERIFY-01, VERIFY-02, VERIFY-03, VERIFY-04

**Success criteria:**

1. Theme probe verifies a known palette, spacing, and radius value from the C++ runtime.
2. Smoke test verifies representative controls consume the runtime.
3. Manifest validation test covers bad schema, missing fields, unknown brand/mode, and fallback.
4. Playground includes a visual theme gallery for key token groups and component states.

## Roadmap Rules

- Keep `Theme` as the only intended theme entrypoint for consumers.
- Keep raw DTCG paths and generated manifest details internal.
- Avoid broad component rewrites until Phase 1 and Phase 3 contracts are stable.
- Treat runtime switching as Merce semantic theme switching, not Qt Quick Controls style switching.

---
*Roadmap created: 2026-06-03*
