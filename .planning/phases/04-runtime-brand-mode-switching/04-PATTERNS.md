# Phase 04: Runtime Brand/Mode Switching - Pattern Map

**Mapped:** 2026-06-04  
**Files analyzed:** 5 target files  
**Analogs found:** 5 / 5

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `Core/Theme/MerceTheme.h` | provider | request-response | `Core/Theme/MerceTheme.h` | exact-existing |
| `Core/Theme/MerceTheme.cpp` | provider/service | request-response | `Core/Theme/MerceTheme.cpp`, `Core/Theme/MerceThemeManifestLoader.cpp` | exact-existing |
| `tests/Core/tst_merce_theme_runtime_switch.cpp` | test | request-response | `tests/Core/tst_merce_theme_manifest_loader.cpp` | role-match |
| `tests/Core/CMakeLists.txt` | config | build/test registration | `tests/Core/CMakeLists.txt` | exact-existing |
| `playground/ThemeProbe.qml` or `playground/ThemeSwitchProbe.qml` plus optional `playground/main.cpp` routing | component/test probe | event-driven | `playground/ThemeProbe.qml`, `playground/main.cpp` | exact-existing |

## Pattern Assignments

### `Core/Theme/MerceTheme.h` (provider, request-response)

**Analog:** `Core/Theme/MerceTheme.h`

**Imports pattern** (lines 3-14):
```cpp
#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "MerceBreakpoints.h"
#include "MerceIconography.h"
#include "MerceMotion.h"
#include "MercePalette.h"
#include "MerceRadius.h"
#include "MerceShadows.h"
#include "MerceSpacing.h"
#include "MerceTypography.h"
#include "MerceZIndex.h"
```

**QML singleton/property pattern** (lines 16-32):
```cpp
class MerceTheme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MercePalette *palette READ palette NOTIFY paletteChanged FINAL)
    Q_PROPERTY(MercePalette *colors READ colors NOTIFY paletteChanged FINAL)
    Q_PROPERTY(MerceSpacing *spacing READ spacing NOTIFY spacingChanged FINAL)
    Q_PROPERTY(MerceRadius *radius READ radius NOTIFY radiusChanged FINAL)
    Q_PROPERTY(MerceTypography *typography READ typography NOTIFY typographyChanged FINAL)
    QML_NAMED_ELEMENT(Theme)
    QML_SINGLETON
```

**Phase 4 target shape:** add `Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)`, `Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)`, and `Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString());`. Convert stable object pointer properties for `palette`, `colors`, `spacing`, `radius`, and `typography` to `CONSTANT FINAL` after confirming pointers are only allocated in the constructor.

**Getter/member pattern** (lines 37-48, 64-72):
```cpp
MercePalette *palette() const { return m_palette; }
MercePalette *colors() const { return m_palette; }
MerceSpacing *spacing() const { return m_spacing; }
MerceRadius *radius() const { return m_radius; }
MerceTypography *typography() const { return m_typography; }

MercePalette *m_palette = nullptr;
MerceSpacing *m_spacing = nullptr;
MerceRadius *m_radius = nullptr;
MerceTypography *m_typography = nullptr;
```

**Planner notes:**
- Keep public QML names as `brand` and `mode`; keep internal loader/registry names as `theme` and `variant`.
- Prefer one shared `activeThemeChanged()` signal unless implementation clarity requires separate `activeBrandChanged()` / `activeModeChanged()`.
- Do not expose `lastError` or `usedFallback` to QML in Phase 4.

---

### `Core/Theme/MerceTheme.cpp` (provider/service, request-response)

**Analogs:** `Core/Theme/MerceTheme.cpp`, `Core/Theme/MerceThemeManifestLoader.cpp`

**Imports/logging pattern** (`MerceTheme.cpp` lines 1-9):
```cpp
#include "MerceTheme.h"

#include "MerceThemeManifestLoader.h"

#include <QJsonObject>
#include <QJsonValue>
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(merceThemeLog, "merce.theme")
```

**Stable sub-object construction pattern** (`MerceTheme.cpp` lines 11-22):
```cpp
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
```

**Default load + apply pattern** (`MerceTheme.cpp` lines 23-39):
```cpp
const MerceThemeLoadResult theme = MerceThemeManifestLoader().loadDefault();
if (!theme.ok) {
    for (const QString &error : theme.errors)
        qCWarning(merceThemeLog) << "default manifest load failed:" << error;
    return;
}

const QJsonObject manifest = theme.finalManifest;
m_palette->applyManifestSection(manifest.value(QStringLiteral("palette")).toObject());
m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());
```

**Loader request/failure/fallback pattern** (`MerceThemeManifestLoader.cpp` lines 412-449):
```cpp
MerceThemeLoadResult MerceThemeManifestLoader::load(const QString &theme, const QString &variant) const
{
    const RegistryLoadResult registry = loadRegistry(m_indexPath);
    if (!registry.ok) {
        MerceThemeLoadResult result;
        result.theme = theme;
        result.variant = variant;
        result.errors = registry.errors;
        logErrors(QStringLiteral("theme registry load failed:"), result.errors);
        return result;
    }

    const MerceThemeRegistryLookupResult lookup = registry.registry.lookup(theme, variant);
    if (!lookup.ok) {
        MerceThemeLoadResult result;
        result.theme = theme;
        result.variant = variant;
        result.errors = lookup.errors;
        logErrors(QStringLiteral("requested theme lookup failed:"), result.errors);
        return result;
    }

    MerceThemeLoadResult requested = loadEntry(lookup.entry);
    if (requested.ok || isDefaultEntry(registry.registry, lookup.entry)) {
        if (!requested.ok)
            logErrors(QStringLiteral("requested theme load failed:"), requested.errors);
        return requested;
    }

    logErrors(QStringLiteral("requested theme load failed, falling back to default:"), requested.errors);
    MerceThemeLoadResult fallback = loadDefaultFromRegistry(registry.registry);
    if (fallback.ok) {
        fallback.usedFallback = true;
        fallback.errors = requested.errors;
        return fallback;
    }
```

**Phase 4 target shape:** factor the constructor apply block into a private helper, for example `bool applyLoadedTheme(const MerceThemeLoadResult &theme)`. `setTheme(brand, mode)` should call `MerceThemeManifestLoader().load(brand, mode)`, return `false` without mutation on `!ok`, apply supported sections on success, then update active state from `theme.theme` and `theme.variant` rather than the original request.

**Known risks:**
- Do not assign new objects to `m_palette`, `m_spacing`, `m_radius`, or `m_typography` outside the constructor.
- Do not emit top-level pointer notify signals as the value-update mechanism; sub-objects already emit `changed`.
- Do not add `QQuickStyle`, `Qt6::QuickControls2`, or `qtquickcontrols2.conf` changes.

---

### `tests/Core/tst_merce_theme_runtime_switch.cpp` (test, request-response)

**Analog:** `tests/Core/tst_merce_theme_manifest_loader.cpp`

**Imports/helper pattern** (lines 1-9):
```cpp
#include "MerceThemeManifestLoader.h"
#include "MerceThemeRegistry.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTemporaryDir>
#include <QtTest/QtTest>
```

**Private helper style** (lines 12-77, 145-181):
```cpp
namespace {

QJsonObject objectFromPairs(const QList<QPair<QString, QJsonValue>> &pairs)
{
    QJsonObject object;
    for (const auto &pair : pairs)
        object.insert(pair.first, pair.second);
    return object;
}

bool writeJson(const QString &path, const QJsonObject &object)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    file.write(QJsonDocument(object).toJson(QJsonDocument::Compact));
    return true;
}

QString pathIn(QTemporaryDir &dir, const QString &fileName)
{
    return QDir(dir.path()).filePath(fileName);
}

} // namespace
```

**QtTest class/slot pattern** (lines 183-198):
```cpp
class tst_merce_theme_manifest_loader : public QObject
{
    Q_OBJECT

private slots:
    void generatedResourceIndexLoads();
    void unknownThemeIsRejected();
    void unknownVariantIsRejected();
    void unsafeManifestPathsAreRejected_data();
    void unsafeManifestPathsAreRejected();
```

**Assertion style** (lines 203-210, 213-219, 447-453):
```cpp
const MerceThemeLoadResult result = MerceThemeManifestLoader().loadDefault();

QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
QCOMPARE(result.theme, QStringLiteral("merce"));
QCOMPARE(result.variant, QStringLiteral("light"));
QVERIFY(result.finalManifest.contains(QStringLiteral("palette")));

QVERIFY(!result.ok);
QVERIFY(!result.usedFallback);
QVERIFY(containsError(result.errors, QStringLiteral("theme 'unknown' is not registered")));

QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
QVERIFY(result.usedFallback);
QCOMPARE(result.theme, QStringLiteral("merce"));
QCOMPARE(result.variant, QStringLiteral("light"));
```

**Test main pattern** (lines 473-475):
```cpp
QTEST_MAIN(tst_merce_theme_manifest_loader)

#include "tst_merce_theme_manifest_loader.moc"
```

**Phase 4 test checklist:**
- Include `MerceTheme.h` and instantiate `MerceTheme theme;`.
- Assert default `activeBrand == "merce"` and `activeMode == "light"` after constructor default load.
- Assert `setTheme("merce", "dark") == true`, active state changes, `palette()->backgroundBase()` changes to dark, and `palette()` pointer remains identical.
- Assert `setTheme("merce", "light") == true` switches back.
- Assert `setTheme("stripe") == true`, `activeBrand == "stripe"`, and `activeMode == ""`.
- Assert unknown brand/mode return `false` and preserve previous active state and semantic values.
- Add fallback-active-state coverage only if `MerceTheme` has an internal/test-only index-path injection; otherwise keep fallback covered by loader tests.
- Optional meta-object test: `QMetaObject` / `QMetaProperty` can verify top-level pointer properties are `CONSTANT`.

---

### `tests/Core/CMakeLists.txt` (config, build/test registration)

**Analog:** `tests/Core/CMakeLists.txt`

**QTest target helper pattern** (lines 1-21):
```cmake
function(merce_add_qtest target source)
    qt_add_executable(${target}
        ${source}
    )

    target_link_libraries(${target}
        PRIVATE
            MerceCore
            Qt6::Core
            Qt6::Test
    )

    target_include_directories(${target}
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/../../Core/Theme"
    )

    add_test(NAME ${target}
        COMMAND ${target}
    )
endfunction()
```

**Registration pattern** (lines 23-24):
```cmake
merce_add_qtest(tst_merce_test_harness tst_merce_test_harness.cpp)
merce_add_qtest(tst_merce_theme_manifest_loader tst_merce_theme_manifest_loader.cpp)
```

**Phase 4 target shape:**
```cmake
merce_add_qtest(tst_merce_theme_runtime_switch tst_merce_theme_runtime_switch.cpp)
```

No new test dependency is needed.

---

### `playground/ThemeProbe.qml` or `playground/ThemeSwitchProbe.qml` (component/test probe, event-driven)

**Analogs:** `playground/ThemeProbe.qml`, `playground/main.cpp`

**QML import/object pattern** (`ThemeProbe.qml` lines 1-5):
```qml
import QtQml
import Merce.Core

QtObject {
    Component.onCompleted: {
```

**Probe assertion/failure pattern** (`ThemeProbe.qml` lines 6-27):
```qml
const backgroundBase = String(Theme.palette.backgroundBase).toLowerCase()
const compatibilityBase = String(Theme.colors.background.base).toLowerCase()
const bodyFont = String(Theme.typography.fontBody)

if (backgroundBase !== "#faf8f6"
        || compatibilityBase !== "#faf8f6"
        || Theme.spacing.md !== 16
        || Theme.radius.button !== 12
        || bodyFont !== "DM Sans"
        || Theme.icons.small !== 20
        || !Theme.palette.textPrimary
        || !Theme.colors.action.base("primary")) {
    console.error("theme-probe failed",
                  backgroundBase,
                  compatibilityBase,
                  Theme.spacing.md,
                  Theme.radius.button,
                  bodyFont,
                  Theme.icons.small)
    Qt.exit(1)
    return
}
```

**Probe success pattern** (`ThemeProbe.qml` lines 29-36):
```qml
console.log("theme-probe ok",
            Theme.palette.backgroundBase,
            Theme.colors.background.base,
            Theme.spacing.md,
            Theme.radius.button,
            bodyFont,
            Theme.icons.small)
Qt.quit()
```

**Playground routing pattern** (`playground/main.cpp` lines 11-21):
```cpp
QObject::connect(
    &engine,
    &QQmlApplicationEngine::objectCreationFailed,
    &app,
    []() { QCoreApplication::exit(-1); },
    Qt::QueuedConnection);

const bool themeProbe = app.arguments().contains("--theme-probe");
engine.loadFromModule("Merce.Playground", themeProbe ? "ThemeProbe" : "Main");

if (themeProbe || app.arguments().contains("--smoke-test")) {
    QTimer::singleShot(250, &app, &QCoreApplication::quit);
}
```

**Phase 4 target shape:**
- If extending `ThemeProbe.qml`, add bound properties at object scope:
  ```qml
  property var paletteObject: Theme.palette
  property var spacingObject: Theme.spacing
  property var radiusObject: Theme.radius
  property var typographyObject: Theme.typography
  property color observedBackground: Theme.palette.backgroundBase
  ```
- In `Component.onCompleted`, capture `before`, call `Theme.setTheme("merce", "dark")`, assert `observedBackground` becomes dark and object pointers are unchanged.
- If adding `ThemeSwitchProbe.qml`, update `main.cpp` routing with a new boolean such as `themeSwitchProbe` and load `ThemeSwitchProbe` for `--theme-switch-probe`.
- Keep probe terse: `theme-switch-probe ok` / `theme-switch-probe failed`.

## Shared Patterns

### Runtime Registry Safety

**Source:** `Core/Theme/MerceThemeRegistry.cpp` lines 193-224  
**Apply to:** `MerceTheme::setTheme(...)`
```cpp
MerceThemeRegistryLookupResult MerceThemeRegistry::lookup(const QString &theme, const QString &variant) const
{
    MerceThemeRegistryLookupResult result;

    bool foundTheme = false;
    QString effectiveVariant = variant;
    if (theme == m_defaultTheme && effectiveVariant.isEmpty())
        effectiveVariant = m_defaultVariant;

    for (const auto &entry : m_entries) {
        if (entry.theme != theme)
            continue;

        foundTheme = true;
        if (entry.variant == effectiveVariant) {
            result.ok = true;
            result.entry = entry;
            return result;
        }
    }
```

Use `MerceThemeManifestLoader::load(brand, mode)` instead of deriving resource paths from QML strings.

### Error Logging

**Source:** `Core/Theme/MerceTheme.cpp` lines 24-28 and `Core/Theme/MerceThemeManifestLoader.cpp` lines 370-374  
**Apply to:** `MerceTheme::setTheme(...)`
```cpp
if (!theme.ok) {
    for (const QString &error : theme.errors)
        qCWarning(merceThemeLog) << "default manifest load failed:" << error;
    return;
}

void logErrors(const QString &prefix, const QStringList &errors)
{
    for (const QString &error : errors)
        qCWarning(merceThemeLoaderLog) << prefix << error;
}
```

Use clear `qCWarning(merceThemeLog)` messages for failed runtime switch requests, then return `false`.

### Sub-Object Binding Updates

**Source:** `Core/Theme/MercePalette.h` lines 431-438, `Core/Theme/MerceSpacing.h` lines 10-30, `Core/Theme/MerceRadius.h` lines 10-22, `Core/Theme/MerceTypography.h` lines 11-39  
**Apply to:** `MerceTheme.cpp`, QML probe
```cpp
Q_PROPERTY(QColor backgroundBase READ backgroundBase NOTIFY changed FINAL)
Q_PROPERTY(int md READ md NOTIFY changed FINAL)
Q_PROPERTY(int button READ button NOTIFY changed FINAL)
Q_PROPERTY(QString fontBody READ fontBody NOTIFY changed FINAL)
```

Rely on sub-object `changed` signals emitted by `applyManifestSection(...)`; do not depend on top-level pointer notify signals for value binding invalidation.

### Supported Manifest Sections

**Source:** `Core/Theme/MerceThemeManifestLoader.cpp` lines 25-34 and `Core/Theme/MerceTheme.cpp` lines 31-34  
**Apply to:** `MerceTheme::applyLoadedTheme(...)`
```cpp
const QStringList supportedSections()
{
    return {
        QStringLiteral("palette"),
        QStringLiteral("spacing"),
        QStringLiteral("radius"),
        QStringLiteral("typography"),
    };
}

m_palette->applyManifestSection(manifest.value(QStringLiteral("palette")).toObject());
m_spacing->applyManifestSection(manifest.value(QStringLiteral("spacing")).toObject());
m_radius->applyManifestSection(manifest.value(QStringLiteral("radius")).toObject());
m_typography->applyManifestSection(manifest.value(QStringLiteral("typography")).toObject());
```

Phase 4 should not expand manifest-backed runtime application to motion, iconography, z-index, breakpoints, or shadows.

## No Analog Found

None. Every expected Phase 4 target has a direct or role-matched analog in the current codebase.

## Known Risks For Planner

| Risk | Mitigation |
|------|------------|
| `CONSTANT` applied before pointer stability is true | Confirm sub-objects are allocated only in `MerceTheme` constructor and never replaced. |
| Invalid switch mutates state before failure return | Treat load/apply as transactional; update `activeBrand`/`activeMode` only after successful apply. |
| Fallback reports requested broken brand | Use `MerceThemeLoadResult.theme` / `.variant` for active state. |
| Probe reads final value but does not prove binding update | Use object-scope bound property such as `observedBackground: Theme.palette.backgroundBase`, then assert it changes after `setTheme`. |
| Phase creep into gallery or Quick Controls style switching | Keep to QtTest + focused QML probe; do not add Spix, gallery, or style-family switching. |

## Metadata

**Analog search scope:** `Core/Theme`, `tests/Core`, `playground`  
**Files scanned:** 20+ focused theme/test/playground files via `rg --files` and targeted pattern search  
**Project instructions:** no root `AGENTS.md` file exists; user-provided AGENTS instructions applied. `.codex/skills` and `.agents/skills` are absent in this checkout.  
**Pattern extraction date:** 2026-06-04
