---
phase: 04-runtime-brand-mode-switching
reviewed: 2026-06-04T07:55:03Z
depth: standard
files_reviewed: 7
files_reviewed_list:
  - Core/Theme/MerceTheme.h
  - Core/Theme/MerceTheme.cpp
  - tests/Core/CMakeLists.txt
  - tests/Core/tst_merce_theme_runtime_switch.cpp
  - playground/CMakeLists.txt
  - playground/main.cpp
  - playground/ThemeSwitchProbe.qml
findings:
  critical: 0
  warning: 2
  info: 0
  total: 2
status: issues_found
---

# Phase 04: Code Review Report

**Reviewed:** 2026-06-04T07:55:03Z
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

Phase 04 runtime brand/mode switching files were reviewed for correctness, Qt/QML binding behavior, edge cases, maintainability, and build/runtime regressions. The new QTest target and QML probe build and pass, but the implementation still has two runtime contract risks around notification behavior that can break existing consumers or expose mixed theme state during a live switch.

Verification run during review:

- `cmake --build build --target tst_merce_theme_runtime_switch` passed
- `cmake --build build --target MercePlayground` passed
- `ctest --test-dir build -R tst_merce_theme_runtime_switch --output-on-failure` passed
- `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe` passed

## Narrative Findings (AI reviewer)

## Warnings

### WR-01: Compatibility theme signals are now dead after runtime switches

**File:** `Core/Theme/MerceTheme.h:60`

**Issue:** `paletteChanged`, `spacingChanged`, `radiusChanged`, and `typographyChanged` are still public signals, but Phase 04 changed the corresponding properties to `CONSTANT` and removed all emits from `MerceTheme::applyLoadedTheme()`. Existing C++ callers or QML `Connections` that already listened to these public signals will still compile, but they will silently stop receiving updates when `setTheme()` succeeds. That is a behavioral regression hidden by the new tests because they only assert sub-object `changed` signals exist, not that the old public compatibility signals remain meaningful.

**Fix:** Either remove these signals intentionally and update all public API documentation/consumers, or keep backward compatibility by emitting them after a successful switch, once the whole theme state has been applied.

```cpp
bool MerceTheme::applyLoadedTheme(const MerceThemeLoadResult &result)
{
    if (!result.ok)
        return false;

    const QJsonObject manifest = result.finalManifest;
    m_palette->applyManifestSection(manifest.value(QStringLiteral("palette")).toObject());
    m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
    m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
    m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());
    setActiveThemeState(result.theme, result.variant);

    emit paletteChanged();
    emit spacingChanged();
    emit radiusChanged();
    emit typographyChanged();
    return true;
}
```

### WR-02: Runtime switch notifications expose partially applied theme state

**File:** `Core/Theme/MerceTheme.cpp:67`

**Issue:** `applyLoadedTheme()` applies palette, spacing, radius, and typography sequentially. Each `applyManifestSection()` emits its own `changed()` signal immediately, before the remaining sections and `activeBrand`/`activeMode` are updated. During a live QML switch, bindings or signal handlers that depend on multiple theme categories can observe mixed state, for example new palette with old spacing/radius, or new token values while `Theme.activeMode` still reports the previous mode. This did not matter at construction time, but Phase 04 turns the same path into a runtime operation with active observers.

**Fix:** Make theme application a batched update: assign all section values first, update active state, then emit notifications. One practical shape is to add a silent/deferred notify mode to the token classes and flush signals only after the full manifest is applied.

```cpp
bool MerceTheme::applyLoadedTheme(const MerceThemeLoadResult &result)
{
    if (!result.ok)
        return false;

    const QJsonObject manifest = result.finalManifest;
    m_palette->applyManifestSection(manifest.value(QStringLiteral("palette")).toObject(), MerceNotifyMode::Deferred);
    m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject(), MerceNotifyMode::Deferred);
    m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject(), MerceNotifyMode::Deferred);
    m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject(), MerceNotifyMode::Deferred);

    setActiveThemeState(result.theme, result.variant);
    m_palette->notifyChanged();
    m_spacing->notifyChanged();
    m_radius->notifyChanged();
    m_typography->notifyChanged();
    return true;
}
```

---

_Reviewed: 2026-06-04T07:55:03Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
