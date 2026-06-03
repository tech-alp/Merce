# Requirements: Merce Theme Runtime

**Defined:** 2026-06-03
**Core Value:** QML application and component authors can use a stable, typed `Theme` API while brands and modes are driven from validated token manifests.

## v1 Requirements

### Theme Runtime

- [x] **THEME-01**: QML components can access a registered `Theme` singleton from the Merce module.
- [x] **THEME-02**: `Theme` exposes typed C++ sub-objects for palette, spacing, radius, typography, motion, iconography, z-index, and breakpoints.
- [x] **THEME-03**: Internal supporting theme classes are not directly creatable by QML consumers.
- [x] **THEME-04**: The public QML API avoids unnecessary deep nesting and supports names such as `Theme.palette.textPrimary`.
- [x] **THEME-05**: Theme value changes emit `NOTIFY` signals so QML bindings update during runtime mode changes.

### Token Pipeline

- [x] **TOKENS-01**: DTCG JSON is the source format for Merce design tokens.
- [x] **TOKENS-02**: Style Dictionary v5 resolves core, brand, and mode token layers in deterministic order.
- [x] **TOKENS-03**: Style Dictionary emits resolved Merce theme manifests instead of public QML token files.
- [x] **TOKENS-04**: The generated manifest schema is versioned and independent from raw DTCG token paths.
- [x] **TOKENS-05**: Generated manifests are committed or packaged so Merce consumers do not need Node at runtime.

### Manifest And Resources

- [ ] **MANIFEST-01**: Theme manifests are available through resource paths listed by `:/merce/themes/index.json`.
- [ ] **MANIFEST-02**: `:/merce/themes/index.json` lists available themes, optional variants, defaults, display names, and manifest paths.
- [ ] **MANIFEST-03**: The C++ loader rejects unknown themes or variants that are not registered in `index.json`.
- [ ] **MANIFEST-04**: The C++ loader validates schema version and required fields before applying a theme.
- [ ] **MANIFEST-05**: Loader errors are logged clearly and fall back to a known default theme.

### Runtime Switching

- [ ] **RUNTIME-01**: QML can request `Theme.setTheme(brand, mode)` for registered themes.
- [ ] **RUNTIME-02**: Switching from light to dark updates Merce component bindings without recreating the whole UI.
- [ ] **RUNTIME-03**: Runtime switching affects Merce semantic values only and does not attempt to change Qt Quick Controls style family on the fly.
- [ ] **RUNTIME-04**: The active brand and mode are queryable from QML.

### Verification And Tooling

- [ ] **VERIFY-01**: A theme probe verifies public theme values load from the C++ runtime.
- [ ] **VERIFY-02**: A smoke test verifies core Merce components consume the C++ theme runtime.
- [ ] **VERIFY-03**: A manifest validation test covers missing fields, invalid schema version, unknown brand, and fallback behavior.
- [ ] **VERIFY-04**: Playground includes a theme gallery for palette, typography, spacing, radius, and common control states.

## v2 Requirements

### Advanced Tokens

- **ADV-01**: Composite typography presets can be generated from DTCG typography tokens.
- **ADV-02**: Shadow/elevation tokens can be represented in a typed runtime structure.
- **ADV-03**: Component-specific tokens can be introduced after semantic runtime contract is stable.

### External Customization

- **EXT-01**: Applications can load an external theme manifest path in addition to resources.
- **EXT-02**: Applications can register additional brand manifests at startup.
- **EXT-03**: A CLI/tooling command can validate Merce theme manifests outside the application.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Direct raw DTCG parsing in C++ | Duplicates Style Dictionary alias, merge, and transform behavior |
| Generated QML token files as public API | Couples components to build output details |
| Live Qt Quick Controls style family switch | Not needed for Merce semantic theme runtime and conflicts with Qt style selection constraints |
| Full component-token matrix in Phase 1 | Too much surface before the runtime contract is proven |
| Kiosk-specific shell module | Merce is positioned as a QML design system; kiosk can be a later optional package |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| THEME-01 | Phase 1 | Complete |
| THEME-02 | Phase 1 | Complete |
| THEME-03 | Phase 1 | Complete |
| THEME-04 | Phase 1 | Complete |
| THEME-05 | Phase 1 | Complete |
| TOKENS-01 | Phase 2 | Complete |
| TOKENS-02 | Phase 2 | Complete |
| TOKENS-03 | Phase 2 | Complete |
| TOKENS-04 | Phase 2 | Complete |
| TOKENS-05 | Phase 2 | Complete |
| MANIFEST-01 | Phase 3 | Pending |
| MANIFEST-02 | Phase 3 | Pending |
| MANIFEST-03 | Phase 3 | Pending |
| MANIFEST-04 | Phase 3 | Pending |
| MANIFEST-05 | Phase 3 | Pending |
| RUNTIME-01 | Phase 4 | Pending |
| RUNTIME-02 | Phase 4 | Pending |
| RUNTIME-03 | Phase 4 | Pending |
| RUNTIME-04 | Phase 4 | Pending |
| VERIFY-01 | Phase 5 | Pending |
| VERIFY-02 | Phase 5 | Pending |
| VERIFY-03 | Phase 5 | Pending |
| VERIFY-04 | Phase 5 | Pending |
| ADV-01 | v2 Backlog | Pending |
| ADV-02 | v2 Backlog | Pending |
| ADV-03 | v2 Backlog | Pending |
| EXT-01 | v2 Backlog | Pending |
| EXT-02 | v2 Backlog | Pending |
| EXT-03 | v2 Backlog | Pending |

**Coverage:**

- v1 requirements: 23 total
- Mapped to phases: 23
- Unmapped: 0

---
*Requirements defined: 2026-06-03*
*Last updated: 2026-06-03 after initialization*
