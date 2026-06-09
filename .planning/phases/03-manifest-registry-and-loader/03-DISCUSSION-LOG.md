# Phase 3: Manifest Registry And Loader - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-06-03
**Phase:** 03-manifest-registry-and-loader
**Areas discussed:** index.json cozumleme sozlesmesi, Loader ve apply siniri, Validation ve fallback politikasi, Qt resource/CMake paketleme

---

## index.json cozumleme sozlesmesi

| Option | Description | Selected |
|--------|-------------|----------|
| Normalize C++ | index.json degismez; C++ registry single-manifest ve variant manifestleri ortak internal ref modeline cevirir. | yes |
| Raw index | Loader index yapisini oldugu gibi tasir; daha az donusum ama branch mantigi caller tarafina sizar. | |
| Flatten index | Generator flat index uretir; runtime basitlesir ama Phase 2 schema'sini tekrar genisletir. | |

**User's choice:** Normalize C++.
**Notes:** User asked how `index.json` is positioned. The decision was refined: repo artifact path is `generated/themes/index.json`; runtime resource path is `:/merce/themes/index.json`; manifest paths are relative file names resolved under `:/merce/themes`.

---

## Loader ve apply siniri

| Option | Description | Selected |
|--------|-------------|----------|
| Loader + default apply | C++ loader reads registry/index, validates the default manifest, and applies it to current `MerceTheme` typed objects. Public `Theme.setTheme(...)` stays Phase 4. | yes |
| Sadece parse/validate registry | Loader validates index and manifest files but does not apply values into `MerceTheme`. | |
| Loader + public theme secimi | Phase 3 also exposes public QML theme selection. | |

**User's choice:** Loader + default apply.
**Notes:** The first explanation raised a missing-section concern. User clarified that `merce.default.json` should handle the baseline sections, and `merce.light.json`, `merce.dark.json`, and other JSON files should override only sections they define.

### Base manifest overlay follow-up

| Option | Description | Selected |
|--------|-------------|----------|
| basePath + section-level overlay | index.json declares optional `basePath`; loader applies base first and active manifest second. Whole sections override. | yes |
| basePath + field-level fallback | Missing individual fields fallback to base. | |
| Default manifest outside Phase 3 | Do not add base/default manifest behavior in this phase. | |

**User's choice:** basePath + section-level overlay.
**Notes:** The discussion rejected runtime JSON references such as `{default.spacing}`. The intended model is overlay/fallback, not a C++ implementation of Style Dictionary reference resolution.

---

## Validation ve fallback politikasi

| Option | Description | Selected |
|--------|-------------|----------|
| Strict final validation + default fallback | Validate index, then validate final base+active overlay. Bad active theme falls back to registry default. Bad default fails clearly. | yes |
| Lenient validation | Missing fields are filled from hardcoded C++ defaults. | |
| Hard fail only | Any load/validation failure fails without fallback. | |

**User's choice:** Strict final validation + default fallback.
**Notes:** Final overlay must be complete for supported sections. Fallback should not hide invalid default manifests.

### Fallback result visibility follow-up

| Option | Description | Selected |
|--------|-------------|----------|
| Structured result + logs | Loader returns internal result fields such as ok, theme, variant, usedFallback, errors; failures are also logged with qWarning. | yes |
| Sadece qWarning logs | Only logs are produced. | |
| QML-visible errors | Add public QML properties like `Theme.lastError` or `Theme.usedFallback`. | |

**User's choice:** Structured result + logs.
**Notes:** No public QML error/status API should be added in Phase 3.

---

## Qt resource/CMake paketleme

| Option | Description | Selected |
|--------|-------------|----------|
| MerceCore resource, fixed prefix | generated/themes files are added as resources to `MerceCore` with prefix `/merce/themes`; runtime path is `:/merce/themes/index.json`. | yes |
| Ayri MerceThemeResources target | Theme resources live in a separate target linked by or used with `MerceCore`. | |
| Playground/app resource | Manifests are packaged only by the consuming app or playground. | |

**User's choice:** MerceCore resource, fixed prefix.
**Notes:** Built-in Merce consumers should not have to package the core manifests themselves.

### Missing generated artifacts follow-up

| Option | Description | Selected |
|--------|-------------|----------|
| Fail fast | Missing `generated/themes/index.json` or manifest files listed by index cause a clear CMake configure/build failure. | yes |
| Warn and continue | Missing artifacts only warn and runtime continues with hardcoded defaults. | |
| Auto-run token build | CMake runs `npm run build` if generated artifacts are absent. | |

**User's choice:** Fail fast.
**Notes:** Normal Qt build must not auto-run npm. Generated artifacts should be committed or packaged.

---

## the agent's Discretion

- Exact C++ file names, class names, helper structs, and test names may follow the local `Core/Theme` and CMake conventions.
- The planner may decide the smallest implementation route for producing `basePath` generated artifacts, provided Node remains outside the normal runtime/consumer path.

## Deferred Ideas

- Public runtime theme switching belongs to Phase 4.
- QML-visible loader diagnostics may be reconsidered in Phase 4 or Phase 5.
- External theme manifests and app-registered theme manifests remain v2/backlog capabilities.
