# Merce Theme Runtime

## What This Is

Merce is an internal Qt/QML design system that can also remain open-source friendly. This project evolves Merce from hand-authored QML token files into a token-driven, production-ready design system with a typed C++ theme runtime exposed to QML through a stable public API.

The design-token source stays DTCG-compatible JSON. Style Dictionary v5 resolves, merges, and validates token inputs, then emits a resolved Merce theme manifest consumed by C++ instead of generating public QML token files.

## Core Value

QML application and component authors can use a stable, typed `Theme` API while brands and modes are driven from validated token manifests.

## Requirements

### Validated

- [x] Preserve a stable public QML theme contract for Merce components. Validated in Phase 1 with C++ `Theme` singleton plus compatibility paths.
- [x] Move theme runtime ownership to typed C++ classes registered into QML. Validated in Phase 1 with `MerceTheme` and typed supporting objects.
- [x] Keep DTCG JSON as the design-token source format. Validated in Phase 2 with source files under `tools/design-tokens/tokens/`.
- [x] Use Style Dictionary v5 as a build-time resolver/converter, not as a runtime dependency. Validated in Phase 2 with the bounded `tools/design-tokens` workspace.
- [x] Generate versioned Merce runtime manifests without exposing public QML token files. Validated in Phase 2 with committed manifests under `generated/themes/`.

### Active

- [ ] Package generated theme manifests through Qt resources using `:/merce/themes/index.json` as the authoritative path registry.
- [ ] Keep component consumers unaware of raw DTCG paths, generated manifests, and internal token storage.
- [ ] Provide runtime theme switching for Merce components without changing Qt Quick Controls style families at runtime.
- [ ] Keep the system usable as an internal project while avoiding closed, app-specific assumptions that would block open-source use.

### Out of Scope

- Direct runtime parsing of raw DTCG JSON by C++ - this would duplicate Style Dictionary behavior for aliases, merge order, and transforms.
- Exposing generated token objects as public QML API - this would couple components to build output details.
- Changing Qt Quick Controls style family live at runtime - Merce runtime switching changes Merce semantic theme values, not `Material` to `Universal`.
- Full component-specific token matrix in the first pass - this would overfit before the runtime contract is proven.
- Mandatory Node dependency for Merce consumers - generated manifests should be committed or packaged so consuming Qt apps do not need Style Dictionary.

## Context

- The current repository already has `Merce.Core.Theme` as the durable public theme facade.
- Existing components consume `Theme.colors.*`, `Theme.spacing.*`, `Theme.typography.*`, and `Theme.radius.*`.
- Phase 1 replaced the public QML `Theme.qml` singleton with a C++ `MerceTheme` singleton while retaining compatibility paths.
- New code should prefer shallow paths such as `Theme.palette.textPrimary`; existing components can continue using `Theme.colors.*` during incremental migration.
- The current QML token files are separated and marked internal in CMake, but QML file visibility and tooling depth remain concerns.
- User preference: keep token implementations separate from the public theme facade and avoid exposing every token file directly.
- New architectural direction: keep DTCG as source, use Style Dictionary v5 to produce a resolved Merce runtime manifest, and implement typed theme objects in C++.
- Phase 2 added `generated/themes/index.json` as the authoritative manifest path registry; future loaders should not derive file paths from theme and variant names.
- QML intellisense can struggle with deep chained objects such as `Theme.colors.text.primary`; a shallower C++ API such as `Theme.palette.textPrimary` is preferred for the runtime layer.

## Constraints

- **Qt stack**: Qt 6 / QML / CMake - Merce remains a native Qt/QML design system.
- **Runtime dependency**: no Node or Style Dictionary at application runtime - all token processing is build-time.
- **API stability**: public QML contract must remain stable across token format and manifest changes.
- **Type safety**: theme values exposed to QML should use typed C++ properties such as `QColor`, `int`, `qreal`, and enums where useful.
- **Resource layout**: multi-brand manifests use `:/merce/themes/{brand}/{mode}.json` plus a registry index.
- **Scope control**: first implementation proves the runtime contract and one brand/light-dark flow before adding advanced token families.
- **Open-source friendliness**: avoid hardcoding private brand names, paths, or app-specific kiosk assumptions into core Merce APIs.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Use C++ as the theme runtime layer | Stronger type safety, better public/private control, runtime switching through `NOTIFY`, and less QML tooling friction | Validated in Phase 1 |
| Keep DTCG JSON as token source | Compatible with design-token tooling and future Figma/Tokens Studio workflows | - Pending |
| Use Style Dictionary v5 for build-time resolution | Avoid reimplementing alias resolution, merge order, and transforms in C++ | Validated in Phase 2 |
| Emit resolved Merce theme manifests, not public QML token files | Runtime manifest is simpler for C++ and keeps generated artifacts out of the component contract | Validated in Phase 2 |
| Use `index.json` as the authoritative manifest path registry | Supports sparse single-manifest and variant-backed themes without fabricated modes | Validated in Phase 2 |
| Prefer shallower QML API names | Improves intellisense and reduces brittle deep chaining | Validated in Phase 1 through `Theme.palette.*` aliases |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition**:
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone**:
1. Full review of all sections
2. Core Value check - still the right priority?
3. Audit Out of Scope - reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-03 after Phase 2 completion*
