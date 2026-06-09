# Phase 03: Manifest Registry And Loader - Research

**Researched:** 2026-06-03
**Domain:** Qt 6 C++ theme manifest resource packaging, registry loading, JSON validation, and typed runtime apply
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

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

### Deferred Ideas (OUT OF SCOPE)

- Public `Theme.setTheme(theme, variant)` and `Theme.activeTheme`/`Theme.activeVariant` belong to Phase 4.
- QML-visible loader diagnostics such as `Theme.lastError` or `Theme.usedFallback` can be reconsidered in Phase 4 or Phase 5 if needed.
- External filesystem theme loading and app-registered manifests remain v2/backlog capabilities.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MANIFEST-01 | Theme manifests are available through resource paths listed by `:/merce/themes/index.json`. | Package `generated/themes/*.json` into `MerceCore` with `qt_add_resources(... PREFIX "/merce/themes" BASE generated/themes FILES ...)`; Qt resources are readable by `QFile` using `:/...` paths. [VERIFIED: repo Core/CMakeLists.txt][CITED: doc.qt.io/qt-6/resources.html][CITED: doc.qt.io/qt-6/qt-add-resources.html] |
| MANIFEST-02 | `:/merce/themes/index.json` lists available themes, optional variants, defaults, display names, and manifest paths. | Current generated index already contains `schemaVersion`, `defaultTheme`, `themes`, `displayName`, `defaultVariant`, `variants`, and single-theme `path`; Phase 3 must add optional `basePath`. [VERIFIED: generated/themes/index.json][VERIFIED: tools/design-tokens/src/theme-registry.mjs] |
| MANIFEST-03 | The C++ loader rejects unknown themes or variants that are not registered in `index.json`. | Normalize index entries into an internal registry and resolve only by lookup; do not derive paths from input strings. [VERIFIED: 03-CONTEXT.md][VERIFIED: generated/themes/index.json] |
| MANIFEST-04 | The C++ loader validates schema version and required fields before applying a theme. | Mirror the build-time validator's required top-level fields and runtime fields for supported sections; parse via `QJsonDocument`/`QJsonObject` and collect structured errors. [VERIFIED: tools/design-tokens/src/validate-manifest.mjs][CITED: doc.qt.io/qt-6/qjsondocument.html][CITED: doc.qt.io/qt-6/qjsonobject.html] |
| MANIFEST-05 | Loader errors are logged clearly and fall back to a known default theme. | Use a structured loader result plus `qCWarning`/`qWarning`; fallback to registry default and fail clearly if the default cannot load. [VERIFIED: 03-CONTEXT.md][CITED: doc.qt.io/qt-6/qloggingcategory.html] |
</phase_requirements>

## Summary

Phase 3 should keep the existing public QML contract stable and move only the data source behind it: `Merce.Core.Theme` stays the singleton entrypoint, while `MerceCore` embeds generated manifests under `:/merce/themes/` and the C++ runtime reads `:/merce/themes/index.json` as the only physical path authority. [VERIFIED: Core/Theme/MerceTheme.h][VERIFIED: Core/CMakeLists.txt][VERIFIED: .planning/phases/03-manifest-registry-and-loader/03-CONTEXT.md]

The repo already has a generated sparse index and three generated manifest fixtures. The main gaps are resource packaging, optional `basePath` generation, C++ index normalization, strict final manifest validation, section-level base overlay, applying values into mutable typed theme objects, and focused tests/probes. [VERIFIED: generated/themes/index.json][VERIFIED: generated/themes/merce.light.json][VERIFIED: generated/themes/merce.dark.json][VERIFIED: generated/themes/stripe.json]

**Primary recommendation:** Implement a small internal `Core/Theme` C++ loader stack using Qt Core only: `QFile` + `QJsonDocument` + explicit validators + `qt_add_resources`; keep Node/Style Dictionary as optional build tooling and do not expose switching or diagnostics to QML in this phase. [CITED: doc.qt.io/qt-6/resources.html][CITED: doc.qt.io/qt-6/qjsondocument.html][VERIFIED: CMakeLists.txt]

## Project Constraints (from Provided Instructions)

- No root `AGENTS.md` exists; project-specific instructions were provided in the prompt for this run. [VERIFIED: find . -maxdepth 2 -name AGENTS.md]
- Answer and planning artifacts should respect Turkish communication, focused changes, Qt 6/QML/C++17-compatible implementation, modern target-based CMake, minimal dependencies, tokenized QML theme usage, clean/testable architecture, robust logs, and clear failure handling. [VERIFIED: user-provided project_instructions]
- The current top-level project sets `CMAKE_CXX_STANDARD 20`, but user preference is C++17-compatible solutions unless the project clearly uses newer standards; Phase 3 code should not require C++20-only APIs without a deliberate reason. [VERIFIED: CMakeLists.txt][VERIFIED: user-provided project_instructions]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Generated manifest packaging | Build / CMake | Qt Resource System | CMake should fail fast when generated artifacts are missing and embed them into `MerceCore`; runtime should only read `:/merce/themes/...`. [VERIFIED: Core/CMakeLists.txt][CITED: doc.qt.io/qt-6/qt-add-resources.html] |
| Manifest index authority | C++ Core Runtime | Generated token tooling | The generated `index.json` declares physical paths; C++ normalizes it into lookups and rejects unregistered input. [VERIFIED: generated/themes/index.json][VERIFIED: 03-CONTEXT.md] |
| JSON parsing and validation | C++ Core Runtime | Token validator for parity | Runtime uses Qt Core JSON APIs; build-time JS validator remains a reference for required field parity. [CITED: doc.qt.io/qt-6/qjsondocument.html][VERIFIED: tools/design-tokens/src/validate-manifest.mjs] |
| Default apply to `Theme` | C++ Core Runtime | QML consumers | `MerceTheme` owns typed sub-objects and QML sees only `Theme.palette`, `Theme.spacing`, `Theme.radius`, etc. [VERIFIED: Core/Theme/MerceTheme.h] |
| Public runtime switching | Deferred Phase 4 | QML API | `Theme.setTheme(...)`, active theme properties, and QML-visible diagnostics are explicitly out of Phase 3. [VERIFIED: 03-CONTEXT.md] |

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| Qt Core JSON (`QJsonDocument`, `QJsonObject`, `QJsonParseError`) | Qt 6.11.1 local build; docs checked against Qt 6.11.0 | Parse UTF-8 JSON, inspect objects, report parse offsets/errors. | Already linked via `Qt6::Core`; avoids a new JSON dependency. [VERIFIED: build/CMakeCache.txt][CITED: doc.qt.io/qt-6/qjsondocument.html][CITED: doc.qt.io/qt-6/qjsonparseerror.html] |
| Qt Resource System + `QFile` | Qt 6.11.1 local build; docs checked against Qt 6.11.0 | Embed generated manifests and read `:/merce/themes/index.json`. | Qt resources are the native mechanism for shipping always-needed files in Qt apps/libraries. [VERIFIED: build/CMakeCache.txt][CITED: doc.qt.io/qt-6/resources.html] |
| `qt_add_resources` | Qt 6.11.1 local build; docs checked against Qt 6.11.0 | Attach manifest JSON resources to `MerceCore`. | Target-based resource embedding matches current CMake target structure. [VERIFIED: Core/CMakeLists.txt][CITED: doc.qt.io/qt-6/qt-add-resources.html] |
| `QLoggingCategory` / `qCWarning` | Qt 6.11.1 local build; docs checked against Qt 6.11.0 | Categorized loader warnings/errors. | Qt-native logging with configurable categories and no external dependency. [CITED: doc.qt.io/qt-6/qloggingcategory.html] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| Style Dictionary workspace | `style-dictionary` `^5.0.0` in private token workspace | Generates committed manifests; not runtime. | Only when updating generated artifacts or adding `basePath`/base manifest generation. [VERIFIED: tools/design-tokens/package.json][VERIFIED: CMakeLists.txt] |
| Node / npm | Node v25.9.0, npm 11.12.1 locally | Optional token tooling execution. | Needed only for `MERCE_ENABLE_TOKEN_BUILD=ON` or manual `npm run build/validate/check`. [VERIFIED: command -v node/npm][VERIFIED: tools/design-tokens/README.md] |
| Existing `MercePlayground --theme-probe` | local executable target | Probe QML-visible theme values. | Update after default manifest apply to prove C++ values came from packaged resource. [VERIFIED: playground/main.cpp][VERIFIED: playground/ThemeProbe.qml] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Qt Core JSON | nlohmann/json or RapidJSON | Adds runtime dependency and packaging burden for a small schema already handled by Qt Core. Do not use in Phase 3. [CITED: doc.qt.io/qt-6/qjsondocument.html][ASSUMED] |
| `qt_add_resources` | Hand-authored `.qrc` file | `.qrc` is valid, but target-based `qt_add_resources` keeps this phase closer to existing target CMake and supports `PREFIX`, `BASE`, and `FILES` directly. [CITED: doc.qt.io/qt-6/qt-add-resources.html][VERIFIED: Core/CMakeLists.txt] |
| C++ path derivation | `:/merce/themes/${theme}.${variant}.json` | Violates locked sparse registry decision and breaks single-manifest themes like `stripe`. [VERIFIED: generated/themes/index.json][VERIFIED: 03-CONTEXT.md] |

**Installation:** no new runtime packages. [VERIFIED: research scope]

## Package Legitimacy Audit

No new package install is recommended for Phase 3. Existing `tools/design-tokens` npm dependency was introduced in Phase 2 and is not a Phase 3 runtime install. [VERIFIED: tools/design-tokens/package.json][VERIFIED: .planning/phases/02-token-build-pipeline/02-01-SUMMARY.md]

## Architecture Patterns

### System Architecture Diagram

```text
tools/design-tokens/themes.json
        |
        | npm run build (optional developer/tooling path only)
        v
generated/themes/index.json + *.json manifests
        |
        | CMake configure/build: verify files exist, embed as resources
        v
MerceCore resources at :/merce/themes/
        |
        | MerceTheme construction calls internal loader
        v
QFile(":/merce/themes/index.json")
        |
        v
Parse index -> validate schema/defaults/paths -> normalized registry
        |
        v
Resolve default theme/variant -> load optional basePath -> load active path
        |
        v
Section-level overlay -> strict final manifest validation
        |
        +--> failure on requested theme/variant -> log -> registry default fallback
        |
        +--> registry default failure -> log hard failure, keep construction fallback only if explicitly planned
        |
        v
Apply supported sections to MercePalette/MerceSpacing/MerceRadius/MerceTypography...
        |
        v
QML consumers continue using Merce.Core Theme
```

### Recommended Project Structure

```text
Core/
├── CMakeLists.txt                       # add MerceCore resource packaging and new C++ sources
└── Theme/
    ├── MerceThemeManifestLoader.h/.cpp  # QFile/QJsonDocument loading, validation, fallback orchestration
    ├── MerceThemeRegistry.h/.cpp        # normalized index entries and lookup rules
    ├── MerceThemeManifest.h             # plain structs/result types for parsed manifest data
    └── MerceTheme*.h                    # add setters/apply methods to existing typed objects

generated/themes/
├── index.json                           # packaged as :/merce/themes/index.json
├── merce.default.json                   # new base manifest if generator path chosen
├── merce.light.json
├── merce.dark.json
└── stripe.json

tools/design-tokens/
└── src/theme-registry.mjs               # add basePath emission if generator path chosen
```

### Pattern 1: Target-Owned Resource Packaging

**What:** Add a resource named uniquely for theme manifests to `MerceCore`, with `PREFIX "/merce/themes"` and `BASE "${CMAKE_SOURCE_DIR}/generated/themes"` so `generated/themes/index.json` becomes `:/merce/themes/index.json`. [CITED: doc.qt.io/qt-6/qt-add-resources.html][VERIFIED: Core/CMakeLists.txt]

**When to use:** Always for built-in Merce manifests in Phase 3. [VERIFIED: 03-CONTEXT.md]

**Example:**

```cmake
set(MERCE_THEME_MANIFEST_FILES
    "${CMAKE_SOURCE_DIR}/generated/themes/index.json"
    "${CMAKE_SOURCE_DIR}/generated/themes/merce.light.json"
    "${CMAKE_SOURCE_DIR}/generated/themes/merce.dark.json"
    "${CMAKE_SOURCE_DIR}/generated/themes/stripe.json"
)

foreach(file IN LISTS MERCE_THEME_MANIFEST_FILES)
    if(NOT EXISTS "${file}")
        message(FATAL_ERROR "Missing generated theme manifest: ${file}")
    endif()
endforeach()

qt_add_resources(MerceCore "merce_theme_manifests"
    PREFIX "/merce/themes"
    BASE "${CMAKE_SOURCE_DIR}/generated/themes"
    FILES ${MERCE_THEME_MANIFEST_FILES}
)
```

### Pattern 2: Parse, Normalize, Then Resolve

**What:** Keep JSON parsing separate from selection. First parse `index.json`; validate schema/defaults/path safety; normalize every single and variant entry into entries like `{theme, displayName, variant, manifestPath, basePath}`; then resolve requested/default input only by map lookup. [VERIFIED: 03-CONTEXT.md][VERIFIED: generated/themes/index.json]

**When to use:** Loader entrypoint and tests for unknown theme/variant rejection. [VERIFIED: .planning/REQUIREMENTS.md]

**Example:**

```cpp
// Source: Qt QJsonDocument/QJsonObject docs + Phase 3 context.
QJsonParseError parseError;
const auto document = QJsonDocument::fromJson(file.readAll(), &parseError);
if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
    errors << QStringLiteral("Invalid theme index JSON: %1 at byte %2")
                  .arg(parseError.errorString())
                  .arg(parseError.offset);
    return {};
}

const QJsonObject index = document.object();
if (index.value("schemaVersion").toInt() != 1) {
    errors << QStringLiteral("Theme index schemaVersion must be 1");
}
```

### Pattern 3: Section-Level Overlay

**What:** Overlay only complete top-level supported sections from active manifest over base manifest. If `palette` exists in active, the active `palette` must contain all required palette fields; do not fill missing palette fields from base. [VERIFIED: 03-CONTEXT.md]

**When to use:** `basePath` support for Merce default + light/dark variants. [VERIFIED: 03-CONTEXT.md]

**Example:**

```cpp
// Source: Phase 3 D-12/D-13.
QJsonObject merged = base;
for (const QString &section : supportedSections) {
    if (active.contains(section)) {
        merged.insert(section, active.value(section));
    }
}
```

### Pattern 4: Mutable Typed Runtime Objects

**What:** Existing typed objects currently return constants from getters. Phase 3 needs explicit private storage plus setters/apply methods so manifest values can become runtime data while keeping the same QML properties and `NOTIFY` signals. [VERIFIED: Core/Theme/MercePalette.h][VERIFIED: Core/Theme/MerceSpacing.h][VERIFIED: Core/Theme/MerceRadius.h][VERIFIED: Core/Theme/MerceTypography.h]

**When to use:** Applying default resolved manifest to `MerceTheme` construction. [VERIFIED: 03-CONTEXT.md]

**Implementation note:** Prefer `applyPalette(...)`, `applySpacing(...)`, etc. on typed objects or a narrow friend/internal applier over exposing setters to QML. [ASSUMED]

### Anti-Patterns to Avoid

- **Path derivation from names:** Breaks sparse theme registry and violates D-02. [VERIFIED: 03-CONTEXT.md]
- **Field-by-field fallback:** Hides invalid generated output; final supported sections must be complete. [VERIFIED: 03-CONTEXT.md]
- **Parsing raw DTCG in C++:** Duplicates Style Dictionary alias/merge/transform work. [VERIFIED: .planning/REQUIREMENTS.md][VERIFIED: tools/design-tokens/README.md]
- **Running `npm run build` from normal Qt configure/build:** Violates Phase 3 resource packaging decision; generated artifacts should already exist. [VERIFIED: CMakeLists.txt][VERIFIED: 03-CONTEXT.md]
- **QML-visible switching in Phase 3:** `Theme.setTheme(...)` and active properties are Phase 4. [VERIFIED: 03-CONTEXT.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON parser | Custom parser/string slicing | `QJsonDocument::fromJson`, `QJsonObject`, `QJsonParseError` | Qt Core already parses UTF-8 JSON and reports parse errors/offsets. [CITED: doc.qt.io/qt-6/qjsondocument.html][CITED: doc.qt.io/qt-6/qjsonparseerror.html] |
| Resource embedding | Manual runtime filesystem copying | `qt_add_resources` on `MerceCore` | Target-based Qt resources are available at runtime through `:/...` and avoid consumer app setup. [CITED: doc.qt.io/qt-6/resources.html][CITED: doc.qt.io/qt-6/qt-add-resources.html] |
| DTCG alias/reference resolution | C++ `{token.path}` resolver | Existing Style Dictionary pipeline | Phase 2 already resolves raw DTCG into runtime manifests; C++ consumes resolved output only. [VERIFIED: tools/design-tokens/src/merce-manifest-format.mjs][VERIFIED: 03-CONTEXT.md] |
| Theme switching API | Public `Theme.setTheme(...)` now | Internal default apply only | Switching and QML-visible active state are Phase 4. [VERIFIED: 03-CONTEXT.md] |
| Schema framework | New JSON schema dependency | Explicit validators aligned with existing JS validator | Current schema is small; existing build-time validator is dependency-free and explicit. [VERIFIED: tools/design-tokens/src/validate-manifest.mjs] |

**Key insight:** Phase 3 complexity is not parsing JSON; it is keeping registry authority, validation strictness, fallback behavior, and public `Theme` compatibility aligned. [VERIFIED: 03-CONTEXT.md][VERIFIED: Core/Theme/MerceTheme.h]

## Common Pitfalls

### Pitfall 1: Resource Alias Mismatch

**What goes wrong:** CMake embeds `generated/themes/index.json` as `:/merce/themes/generated/themes/index.json` or another unexpected path. [ASSUMED]
**Why it happens:** `qt_add_resources` uses the file path as the default runtime alias unless `BASE`/aliases are set correctly. [CITED: doc.qt.io/qt-6/qt-add-resources.html]
**How to avoid:** Use `BASE "${CMAKE_SOURCE_DIR}/generated/themes"` and verify `QFile::exists(":/merce/themes/index.json")`. [CITED: doc.qt.io/qt-6/resources.html]
**Warning signs:** Loader logs cannot open `:/merce/themes/index.json` even though files exist in the source tree. [ASSUMED]

### Pitfall 2: Treating Variant Themes and Single Themes Differently

**What goes wrong:** Loader has separate branches and tests for `merce.light` versus `stripe`, causing path derivation or fake variants. [VERIFIED: generated/themes/index.json]
**Why it happens:** Older roadmap wording mentioned `brand/mode` paths, but Phase 2 refined the model to sparse registry entries. [VERIFIED: .planning/phases/02-token-build-pipeline/02-CONTEXT.md]
**How to avoid:** Normalize index entries into one internal registry shape before loading. [VERIFIED: 03-CONTEXT.md]
**Warning signs:** Code concatenates theme and variant strings into filenames. [VERIFIED: 03-CONTEXT.md]

### Pitfall 3: Applying Invalid Partial Sections

**What goes wrong:** A manifest missing `palette.textPrimary` still appears to work because the runtime silently keeps an old value. [VERIFIED: tools/design-tokens/src/validate-manifest.mjs]
**Why it happens:** Field-by-field fallback mixes default construction values with manifest data. [VERIFIED: 03-CONTEXT.md]
**How to avoid:** Validate final overlay before applying; apply only after all supported required fields pass. [VERIFIED: 03-CONTEXT.md]
**Warning signs:** `Theme.palette.*` has mixed old/new values after a failed load. [ASSUMED]

### Pitfall 4: Support Sections Drift

**What goes wrong:** `Theme.motion`, `Theme.icons`, `Theme.zIndex`, `Theme.breakpoints`, and `Theme.shadows` remain hardcoded while `palette/spacing/radius/typography` load from manifests, creating unclear source-of-truth boundaries. [VERIFIED: Core/Theme/MerceMotion.h][VERIFIED: Core/Theme/MerceIconography.h][VERIFIED: Core/Theme/MerceZIndex.h][VERIFIED: Core/Theme/MerceBreakpoints.h][VERIFIED: Core/Theme/MerceShadows.h]
**Why it happens:** Current generated manifests do not include those support sections. [VERIFIED: generated/themes/merce.light.json]
**How to avoid:** Planner must choose explicitly: either extend base manifest generation for these sections now, or document Phase 3 support as `palette/spacing/radius/typography` with construction defaults for the rest. [VERIFIED: 03-CONTEXT.md]
**Warning signs:** Requirements/tests assume all typed objects are manifest-backed, but generated JSON lacks matching fields. [VERIFIED: generated/themes/merce.light.json]

### Pitfall 5: No Main-Repo Test Harness

**What goes wrong:** Loader/fallback behavior is only manually probed and regressions slip through. [VERIFIED: rg test infrastructure]
**Why it happens:** Main Merce targets have no `enable_testing()`/`add_test()` yet; only `external/qmlagent` has QTest/CTest patterns. [VERIFIED: rg -n enable_testing/add_test/QTest]
**How to avoid:** Add a small main-repo C++ test target or a loader test executable in Phase 3 planning; keep `MercePlayground --theme-probe` as QML smoke, not as the only validation. [ASSUMED]
**Warning signs:** MANIFEST-03/04/05 are verified only by successful app startup. [ASSUMED]

## Code Examples

### Safe Resource Path Resolver

```cpp
// Source: Phase 3 D-03/D-04; Qt resources docs.
QString resolveManifestPath(const QString &fileName, QStringList *errors)
{
    if (fileName.isEmpty() || fileName.startsWith('/') || fileName.startsWith(':')
        || fileName.contains("..") || fileName.contains('/')) {
        errors->append(QStringLiteral("Invalid manifest path in theme index: %1").arg(fileName));
        return {};
    }

    return QStringLiteral(":/merce/themes/%1").arg(fileName);
}
```

### Loader Result Shape

```cpp
// Source: Phase 3 D-19.
struct MerceThemeLoadResult
{
    bool ok = false;
    QString theme;
    QString variant;
    bool usedFallback = false;
    QStringList errors;
    QJsonObject manifest;
};
```

### Apply Boundary

```cpp
// Source: existing MerceTheme ownership + Phase 3 D-07/D-20.
MerceTheme::MerceTheme(QObject *parent)
    : QObject(parent),
      m_palette(new MercePalette(this)),
      m_spacing(new MerceSpacing(this)),
      m_radius(new MerceRadius(this)),
      m_typography(new MerceTypography(this)),
      m_motion(new MerceMotion(this)),
      m_icons(new MerceIconography(this)),
      m_zIndex(new MerceZIndex(this)),
      m_breakpoints(new MerceBreakpoints(this)),
      m_shadows(new MerceShadows(this))
{
    const auto result = MerceThemeManifestLoader::loadDefault();
    if (result.ok) {
        applyManifest(result.manifest);
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Public QML `Theme.qml` facade | C++ `MerceTheme` singleton registered as `Merce.Core/Theme` | Phase 1, 2026-06-03 | Loader should integrate into C++ construction/apply path, not recreate QML token singletons. [VERIFIED: .planning/phases/01-theme-runtime-contract/01-SUMMARY.md][VERIFIED: Core/Theme/MerceTheme.h] |
| Hardcoded runtime values in C++ getters | Manifest-backed values with hardcoded values only as construction/fallback safety | Phase 3 target state | Existing classes need private storage/apply methods. [VERIFIED: Core/Theme/*.h][VERIFIED: 03-CONTEXT.md] |
| Raw DTCG/token files as possible runtime source | Style Dictionary emits resolved runtime manifests | Phase 2, 2026-06-03 | C++ loader must not resolve DTCG references. [VERIFIED: .planning/phases/02-token-build-pipeline/02-01-SUMMARY.md][VERIFIED: tools/design-tokens/src/merce-manifest-format.mjs] |
| Path convention from brand/mode | Generated `index.json` as authoritative path registry | Phase 2/3 decisions, 2026-06-03 | Unknown names are rejected by registry lookup, not by failed file open after path concatenation. [VERIFIED: generated/themes/index.json][VERIFIED: 03-CONTEXT.md] |

**Deprecated/outdated:**
- Deriving `:/merce/themes/{brand}/{mode}.json` is outdated for this phase; sparse single-manifest themes make it invalid. [VERIFIED: generated/themes/index.json][VERIFIED: .planning/STATE.md]
- Adding generated QML token files as public API is out of scope; components stay behind `Theme`. [VERIFIED: .planning/REQUIREMENTS.md][VERIFIED: Core/Theme/MerceTheme.h]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | A small main-repo C++ test target is the best validation gap closer for loader behavior. | Common Pitfalls | Planner may choose a probe-only route and leave MANIFEST-03/04/05 under-tested. |
| A2 | New mutable apply methods should stay internal/private rather than QML-visible setters. | Architecture Patterns | Public API could expand accidentally if implementation exposes setters. |
| A3 | Resource alias mismatch is a likely implementation pitfall. | Common Pitfalls | If CMake behavior is configured differently, the warning is less relevant, but verification remains cheap. |

## Open Questions (RESOLVED)

1. **Support sections in Phase 3**
   - What we know: Context D-14 says base manifests should be able to carry `motion`, `iconography`, `zIndex`, `breakpoints`, and `shadows` where Phase 3 chooses to load them; generated manifests currently do not include these sections. [VERIFIED: 03-CONTEXT.md][VERIFIED: generated/themes/merce.light.json]
   - What's unclear: Whether Phase 3 must extend generator output for all typed sections now or limit strict runtime loading to `palette`, `spacing`, `radius`, and `typography`. [VERIFIED: Core/Theme/*.h]
   - RESOLVED: Phase 3 manifest-backed apply is limited to `palette`, `spacing`, `radius`, and `typography`. `motion`, `iconography`, `zIndex`, `breakpoints`, and `shadows` remain construction defaults and are explicitly not claimed as manifest-backed in this phase. [RESOLVED: 03-02-PLAN.md][RESOLVED: 03-05-PLAN.md]

2. **Test harness location**
   - What we know: Main Merce targets do not currently expose CTest/QTest tests; external qmlagent has test patterns but is a separate subtree. [VERIFIED: rg test infrastructure]
   - What's unclear: Whether Phase 3 should add a top-level `tests/` directory now or keep tests under `Core/tests/`. [ASSUMED]
   - RESOLVED: Add the smallest main-repo `tests/Core` QTest/CTest harness for registry/loader behavior, then keep `ThemeProbe.qml` as a QML smoke/probe for default manifest values. [RESOLVED: 03-01-PLAN.md][RESOLVED: 03-05-PLAN.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| CMake | Configure/build/resource packaging | yes | 4.3.1 | Existing generated build directory if configure is unchanged. [VERIFIED: cmake --version] |
| Qt 6 | MerceCore, JSON/resource/logging APIs | yes | 6.11.1 in `build/CMakeCache.txt` | Set `CMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos`. [VERIFIED: build/CMakeCache.txt] |
| Ninja | Optional build generator | yes | 1.13.2 | Current `build` uses Unix Makefiles. [VERIFIED: ninja --version][VERIFIED: build/CMakeCache.txt] |
| CTest | Optional test execution if Phase 3 adds tests | yes | 4.3.1 | Use direct executable/probe commands if no CTest integration is added. [VERIFIED: ctest --version] |
| Node | Token generator updates only | yes | v25.9.0 | Not needed for normal Qt build; use committed generated files. [VERIFIED: node --version][VERIFIED: CMakeLists.txt] |
| npm | Token generator updates only | yes | 11.12.1 | Not needed for normal Qt build; use committed generated files. [VERIFIED: npm --version][VERIFIED: CMakeLists.txt] |

**Missing dependencies with no fallback:** none found for research/planning. [VERIFIED: command probes]

**Missing dependencies with fallback:** no missing dependency found; Node/npm are available but should remain optional. [VERIFIED: command probes][VERIFIED: 03-CONTEXT.md]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | No auth/session surface in this phase. [VERIFIED: phase_description] |
| V3 Session Management | no | No session state in this phase. [VERIFIED: phase_description] |
| V4 Access Control | no | Built-in resources only; external theme registration is deferred. [VERIFIED: 03-CONTEXT.md] |
| V5 Input Validation | yes | Validate `index.json`, path strings, schema version, theme/variant identity, required fields, and section completeness. [VERIFIED: 03-CONTEXT.md][VERIFIED: tools/design-tokens/src/validate-manifest.mjs] |
| V6 Cryptography | no | No cryptographic operation in this phase. [VERIFIED: phase_description] |

### Known Threat Patterns for Qt Resource Manifest Loading

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Resource path traversal or unintended external path loading | Tampering | Reject absolute paths, `../`, arbitrary `:/...`, and path separators; resolve only relative filenames under `:/merce/themes/`. [VERIFIED: 03-CONTEXT.md] |
| Malformed JSON / unexpected schema | Tampering | Parse with `QJsonParseError`; require object document, schemaVersion 1, expected section types, and required fields. [CITED: doc.qt.io/qt-6/qjsondocument.html][CITED: doc.qt.io/qt-6/qjsonparseerror.html][VERIFIED: tools/design-tokens/src/validate-manifest.mjs] |
| Silent fallback masking broken default manifest | Reliability / Tampering | Log requested-load failures, fallback once to registry default, and fail clearly if default also fails. [VERIFIED: 03-CONTEXT.md] |
| Runtime dependency confusion | Supply Chain | Do not install or require Node/npm packages for normal Qt runtime/build; consume committed generated manifests. [VERIFIED: CMakeLists.txt][VERIFIED: 03-CONTEXT.md] |

## Sources

### Primary (HIGH confidence)

- `Core/CMakeLists.txt` - `MerceCore` target, theme source ownership, Qt links. [VERIFIED]
- `CMakeLists.txt` - Qt 6.11 requirement, optional default-off token build target. [VERIFIED]
- `Core/Theme/MerceTheme.h/.cpp` and `Core/Theme/Merce*.h` - public singleton and typed runtime object shape. [VERIFIED]
- `generated/themes/index.json`, `merce.light.json`, `merce.dark.json`, `stripe.json` - current generated registry and manifest fixtures. [VERIFIED]
- `tools/design-tokens/src/theme-registry.mjs`, `validate-manifest.mjs`, `merce-manifest-format.mjs` - generator/index/validator behavior. [VERIFIED]
- `.planning/phases/03-manifest-registry-and-loader/03-CONTEXT.md` - locked Phase 3 decisions. [VERIFIED]
- Qt docs: `https://doc.qt.io/qt-6/qjsondocument.html`, `qjsonobject.html`, `qjsonparseerror.html`, `resources.html`, `qt-add-resources.html`, `qloggingcategory.html`. [CITED]

### Secondary (MEDIUM confidence)

- `.planning/phases/01-theme-runtime-contract/01-SUMMARY.md` and `.planning/phases/02-token-build-pipeline/02-01-SUMMARY.md` - previous phase implementation history and verification notes. [VERIFIED]
- `playground/main.cpp` and `playground/ThemeProbe.qml` - current probe behavior. [VERIFIED]
- `build/CMakeCache.txt` and local command probes - environment availability. [VERIFIED]

### Tertiary (LOW confidence)

- Assumptions in `## Assumptions Log`; no unverified package names are recommended. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Qt Core/resource/logging APIs are official docs and already linked in repo. [CITED: Qt docs][VERIFIED: Core/CMakeLists.txt]
- Architecture: HIGH - Phase 3 context locks registry/resource/fallback boundaries and repo code confirms `MerceCore` ownership. [VERIFIED: 03-CONTEXT.md][VERIFIED: Core/Theme/MerceTheme.h]
- Pitfalls: MEDIUM - key pitfalls are based on repo decisions and current gaps; test-harness recommendation is partly assumed because planner may choose exact location. [VERIFIED][ASSUMED]

**Research date:** 2026-06-03
**Valid until:** 2026-07-03 for repo-local architecture; refresh Qt docs if Qt requirement changes from 6.11.x. [ASSUMED]
