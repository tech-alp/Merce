# Phase 05: Verification And Gallery - Pattern Map

**Mapped:** 2026-06-04
**Files analyzed:** 8
**Analogs found:** 7 / 8

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `playground/ThemeGallery.qml` | component | request-response | `playground/Main.qml` | role-match |
| `playground/Main.qml` | component | event-driven | `playground/Main.qml` | exact |
| `playground/ThemeProbe.qml` | component/probe | request-response | `playground/ThemeSwitchProbe.qml` | role-match |
| `playground/main.cpp` | route/config | request-response | `playground/main.cpp` | exact |
| `playground/CMakeLists.txt` | config | build-registration | `playground/CMakeLists.txt` | exact |
| `tests/Core/tst_merce_theme_manifest_loader.cpp` | test | CRUD/validation | `tests/Core/tst_merce_theme_manifest_loader.cpp` | exact |
| `tools/qmlagent-probe.mjs` | utility | request-response | `tools/qmlagent-probe.mjs` | exact |
| README/docs visual evidence file, planner-chosen path | docs | file-I/O | none | no-analog |

## Pattern Assignments

### `playground/ThemeGallery.qml` (component, request-response)

**Analog:** `playground/Main.qml`

**Imports pattern** (lines 1-5):
```qml
import QtQuick
import Merce.Core
import Merce.Foundation
import Merce.Controls
import Merce.Notifications
```

**Root/objectName pattern** (lines 7-15):
```qml
Window {
    id: root
    objectName: "merce.playground.window"

    width: 1100
    height: 760
    visible: true
    color: Theme.colors.background.base
    title: "Merce Playground"
```

Copy the authored `objectName` style, but use Phase 5 names from UI-SPEC:
`merce.playground.gallery`, `.activeTheme`, `.palette`, `.typography`, `.spacingRadius`, `.components`, `.exportStatus`.
For new gallery code prefer canonical `Theme.palette`, `Theme.iconography`, and `Theme.breakpoints`; existing controls may still consume aliases internally.

**Scroll/page layout pattern** (lines 21-35):
```qml
Flickable {
    objectName: "merce.playground.flickable"
    anchors.fill: parent
    contentWidth: width
    contentHeight: page.implicitHeight + Theme.spacing.xl2 * 2
    clip: true

    Column {
        id: page
        objectName: "merce.playground.page"
        width: Math.min(parent.width - Theme.spacing.xl2 * 2, 980)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.spacing.xl2
        spacing: Theme.spacing.xl
```

Use the same bounded scroll surface instead of a landing page. Gallery sections should be full-width children inside the existing playground flow, not cards inside cards.

**Section surface pattern** (lines 52-68):
```qml
MSurface {
    objectName: "merce.playground.controlsSurface"
    width: parent.width
    height: controlsColumn.implicitHeight + Theme.spacing.xl2
    surfaceType: types["default"]
    radiusValue: Theme.radius.large

    Column {
        id: controlsColumn
        objectName: "merce.playground.controlsColumn"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacing.xl
        }
        spacing: Theme.spacing.lg
```

Use this pattern for palette, typography, spacing/radius, components, and export status sections.

**Component sample pattern** (lines 76-148):
```qml
Row {
    objectName: "merce.playground.buttonRow"
    spacing: Theme.spacing.md

    MButton {
        objectName: "merce.playground.primaryButton"
        text: "Primary"
        variant: "primary"
        onClicked: toast.show()
    }
}

MInput {
    objectName: "merce.playground.emailInput"
    width: 360
    placeholder: "Email"
    inputType: "email"
}
```

Reuse the same representative controls for gallery component states: `MButton`, `MText`, `MInput`, `MCheckbox`, `MRadio`, `MSwitch`, `MSelect`, `MToast`, and `MDialog`.

### `playground/Main.qml` (component, event-driven)

**Analog:** `playground/Main.qml`

**Integration pattern** (lines 28-35 and 52-55):
```qml
Column {
    id: page
    objectName: "merce.playground.page"
    width: Math.min(parent.width - Theme.spacing.xl2 * 2, 980)
    anchors.horizontalCenter: parent.horizontalCenter
    y: Theme.spacing.xl2
    spacing: Theme.spacing.xl

    MSurface {
        objectName: "merce.playground.controlsSurface"
        width: parent.width
```

Integrate `ThemeGallery { width: parent.width }` as a child of the existing `page` column. Keep `Main.qml` as the shell; do not move gallery section implementation into `Main.qml`.

**Notification/dialog support pattern** (lines 154-170):
```qml
MToast {
    id: toast
    objectName: "merce.playground.toast"
    title: "Merce"
    message: "Toast component imported from Merce.Notifications."
    variant: "success"
}

MDialog {
    id: dialog
    objectName: "merce.playground.dialog"
    title: "Playground dialog"
    message: "MDialog is loaded from Merce.Notifications and uses Merce.Controls internally."
    confirmText: "OK"
    showCancel: false
    onConfirmed: isOpen = false
}
```

If `ThemeGallery.qml` needs toast/dialog examples, either keep these existing top-level samples or add gallery-local examples with stable gallery-prefixed object names.

### `playground/ThemeProbe.qml` (component/probe, request-response)

**Analog:** `playground/ThemeSwitchProbe.qml`

**Imports and canonical binding pattern** (lines 1-7):
```qml
import QtQml
import QtQuick
import Merce.Core

QtObject {
    property color observedBackground: Theme.palette.backgroundBase
```

Use canonical `Theme.palette` for public value assertions. Keep probe output terse and machine-checkable.

**Failure helper pattern** (lines 8-11):
```qml
function fail(message, values) {
    console.error("theme-switch-probe failed", message, values)
    Qt.exit(1)
}
```

Apply the same helper to `ThemeProbe.qml` and any new `ThemeGalleryProbe.qml` so failures report the check name and observed values.

**Theme switch/assertion pattern** (lines 27-42, 44-55, 57-72):
```qml
if (!Theme.setTheme("merce", "dark")) {
    fail("dark switch returned false", [])
    return
}

if (String(observedBackground).toLowerCase() !== "#1f1510"
        || Theme.activeBrand !== "merce"
        || Theme.activeMode !== "dark"
        || Theme.palette !== palette
        || Theme.spacing !== spacing
        || Theme.radius !== radius
        || Theme.typography !== typography) {
    fail("dark switch state",
         [Theme.activeBrand, Theme.activeMode, String(observedBackground)])
    return
}
```

For `VERIFY-01`, update `ThemeProbe.qml` from compatibility assertions toward canonical `Theme.palette`, `Theme.iconography`, spacing, radius, typography, and explicit generated manifest values. Existing `ThemeProbe.qml` currently asserts light defaults and logs `theme-probe ok` at lines 5-36.

### `playground/main.cpp` (route/config, request-response)

**Analog:** `playground/main.cpp`

**Imports and engine error pattern** (lines 1-15):
```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
```

Keep this engine setup and object creation failure handling.

**CLI route pattern** (lines 17-23):
```cpp
const bool themeProbe = app.arguments().contains("--theme-probe");
const bool themeSwitchProbe = app.arguments().contains("--theme-switch-probe");
const char *component = themeSwitchProbe ? "ThemeSwitchProbe" : (themeProbe ? "ThemeProbe" : "Main");
engine.loadFromModule("Merce.Playground", component);

if (themeProbe || themeSwitchProbe || app.arguments().contains("--smoke-test")) {
    QTimer::singleShot(250, &app, &QCoreApplication::quit);
}
```

Extend this by adding explicit booleans for any Phase 5 route, e.g. `--theme-gallery-probe` and `--export-theme-gallery`. Keep flags deterministic and offscreen-friendly. If adding screenshot export in C++, follow the same argument-driven route style.

### `playground/CMakeLists.txt` (config, build-registration)

**Analog:** `playground/CMakeLists.txt`

**QML registration pattern** (lines 5-12):
```cmake
qt_add_qml_module(MercePlayground
    URI "Merce.Playground"
    VERSION 1.0
    QML_FILES
        Main.qml
        ThemeProbe.qml
        ThemeSwitchProbe.qml
)
```

Add `ThemeGallery.qml` and any focused gallery probe/export helper QML file under `QML_FILES`.

**Link/debug pattern** (lines 14-29):
```cmake
target_link_libraries(MercePlayground
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Qml
        MerceCore
        MerceCoreEffects
        MerceFoundation
        MerceControls
        MerceNotifications
)

target_compile_definitions(MercePlayground
    PRIVATE
        QT_QML_DEBUG
)
```

Preserve `QT_QML_DEBUG`; it is required for optional qmlagent inspection. Add Qt modules only if the chosen export path needs them.

### `tests/Core/tst_merce_theme_manifest_loader.cpp` (test, CRUD/validation)

**Analog:** `tests/Core/tst_merce_theme_manifest_loader.cpp`

**Imports/helpers pattern** (lines 1-19, 147-176):
```cpp
#include "MerceThemeManifestLoader.h"
#include "MerceThemeRegistry.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTemporaryDir>
#include <QtTest/QtTest>

bool writeJson(const QString &path, const QJsonObject &object)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    file.write(QJsonDocument(object).toJson(QJsonDocument::Compact));
    return true;
}
```

Use temporary JSON fixtures and the existing `fullManifest(...)`, `indexForDefaultMerce(...)`, `writeJson(...)`, `writeRaw(...)`, `containsError(...)`, and `pathIn(...)` helpers. Do not add public QML diagnostics for loader-only validation.

**Test registration pattern** (lines 181-199):
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
    void malformedJsonReportsParseError();
    void schemaVersionMismatchIsRejected();
    void topLevelColorsCompatibilitySectionIsRejected();
    void invalidRuntimeFieldValuesAreRejected();
    void activePaletteCannotBorrowMissingFieldsFromBase();
    void basePlusActiveSectionOverlaySucceeds();
    void requestedBadManifestFallsBackToRegistryDefault();
    void brokenDefaultReturnsFailure();
};
```

Add any `VERIFY-03` gaps as new private slots here unless readability degrades. Current coverage already includes invalid schema version, unknown brand/mode, fallback, and several missing-field paths.

**Unknown input pattern** (lines 211-227):
```cpp
const MerceThemeLoadResult result = MerceThemeManifestLoader().load(QStringLiteral("unknown"));

QVERIFY(!result.ok);
QVERIFY(!result.usedFallback);
QVERIFY(containsError(result.errors, QStringLiteral("theme 'unknown' is not registered")));
```

**Invalid schema pattern** (lines 262-275):
```cpp
QJsonObject manifest = fullManifest(QStringLiteral("merce"), QStringLiteral("light"));
manifest.insert(QStringLiteral("schemaVersion"), 2);
QVERIFY(writeJson(pathIn(dir, QStringLiteral("merce.light.json")), manifest));
QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), indexForDefaultMerce(QStringLiteral("merce.light.json"))));

const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

QVERIFY(!result.ok);
QVERIFY(containsError(result.errors, QStringLiteral("schemaVersion must be 1")));
```

**Missing field / section overlay pattern** (lines 337-373):
```cpp
QVERIFY(writeJson(pathIn(dir, QStringLiteral("base.json")), fullManifest(QStringLiteral("merce"))));

QJsonObject active;
active.insert(QStringLiteral("schemaVersion"), 1);
active.insert(QStringLiteral("theme"), QStringLiteral("merce"));
active.insert(QStringLiteral("variant"), QStringLiteral("light"));
active.insert(QStringLiteral("palette"), QJsonObject{
    { QStringLiteral("textPrimary"), QStringLiteral("#000000") },
});

const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

QVERIFY(!result.ok);
QVERIFY(containsError(result.errors, QStringLiteral("missing required runtime field: palette.textSecondary")));
QVERIFY(!containsError(result.errors, QStringLiteral("missing required runtime field: spacing.md")));
```

**Fallback pattern** (lines 417-453):
```cpp
const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).load(QStringLiteral("broken"));

QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
QVERIFY(result.usedFallback);
QCOMPARE(result.theme, QStringLiteral("merce"));
QCOMPARE(result.variant, QStringLiteral("light"));
QVERIFY(containsError(result.errors, QStringLiteral("schemaVersion must be 1")));
```

**CTest registration source:** `tests/Core/CMakeLists.txt` lines 1-25:
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
...
merce_add_qtest(tst_merce_theme_manifest_loader tst_merce_theme_manifest_loader.cpp)
```

Phase 5 should extend this existing test target by default, not create another target.

### `tools/qmlagent-probe.mjs` (utility, request-response)

**Analog:** `tools/qmlagent-probe.mjs`

**Process/request pattern** (lines 1-17, 50-73):
```javascript
#!/usr/bin/env node

import { spawn } from "node:child_process";

const repoRoot = new URL("..", import.meta.url).pathname.replace(/\/$/, "");
const mcpPath = `${repoRoot}/build/qmlagent/tools/qmlagent/qmlagent-mcp`;
const port = Number(process.argv[2] ?? "3771");

function request(method, params = {}) {
  const id = nextId++;
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
  ...
}

function tool(name, args = {}) {
  return request("tools/call", { name, arguments: args });
}
```

If planner adds gallery-specific optional inspection, reuse this JSON-RPC helper shape and keep qmlagent optional.

**ObjectName selector pattern** (lines 144-175):
```javascript
const root = await tool("qmlagent.ui_query", {
  selector: 'objectName="merce.playground.flickable"',
  verbosity: "summary",
  includeSource: true,
  properties: ["width", "height", "visible"],
});
const primaryButton = await tool("qmlagent.ui_query", {
  selector: 'objectName="merce.playground.primaryButton"',
  verbosity: "summary",
  includeSource: true,
  properties: ["width", "height", "visible", "enabled", "text"],
});
const diagnostics = await tool("qmlagent.diagnostics_analyze_tree", {
  maxIssues: 10,
  verbosity: "summary",
});
```

Update selectors to `merce.playground.gallery.*` for Phase 5 optional inspection. Prefer tree/diagnostics/state evidence before screenshots.

### README/docs visual evidence file (docs, file-I/O)

**Analog:** no exact analog in repo. `README.md` and `docs/` are absent; only `tools/design-tokens/README.md` and `external/qmlagent/README.md` exist.

Planner should first choose a concrete documentation target and artifact path. UI-SPEC suggests deterministic paths such as `docs/assets/theme-gallery/` or `playground/artifacts/theme-gallery/`. Keep the exact export command in the chosen doc file and make image output non-empty and reproducible.

## Shared Patterns

### Public Theme Entry Point

**Source:** `Core/Theme/MerceTheme.h` lines 22-35, 42-57
**Apply to:** `ThemeGallery.qml`, `ThemeProbe.qml`, gallery probe/export routes
```cpp
Q_PROPERTY(MercePalette *palette READ palette CONSTANT FINAL)
Q_PROPERTY(MercePalette *colors READ colors CONSTANT FINAL)
Q_PROPERTY(MerceSpacing *spacing READ spacing CONSTANT FINAL)
Q_PROPERTY(MerceRadius *radius READ radius CONSTANT FINAL)
Q_PROPERTY(MerceTypography *typography READ typography CONSTANT FINAL)
Q_PROPERTY(MerceIconography *icons READ icons NOTIFY iconsChanged FINAL)
Q_PROPERTY(MerceIconography *iconography READ iconography NOTIFY iconsChanged FINAL)
Q_PROPERTY(MerceBreakpoints *breakpoint READ breakpoint NOTIFY breakpointsChanged FINAL)
Q_PROPERTY(MerceBreakpoints *breakpoints READ breakpoints NOTIFY breakpointsChanged FINAL)
Q_PROPERTY(QString activeBrand READ activeBrand NOTIFY activeThemeChanged FINAL)
Q_PROPERTY(QString activeMode READ activeMode NOTIFY activeThemeChanged FINAL)

Q_INVOKABLE bool setTheme(const QString &brand, const QString &mode = QString());
```

Use canonical properties in new QML where possible: `palette`, `iconography`, `breakpoints`. Alias properties exist but are not long-term gallery/docs contract.

### Runtime Apply/Error Handling

**Source:** `Core/Theme/MerceTheme.cpp` lines 49-58, 61-72
**Apply to:** probes and gallery selectors
```cpp
bool MerceTheme::setTheme(const QString &brand, const QString &mode)
{
    const MerceThemeLoadResult theme = MerceThemeManifestLoader(m_manifestIndexPath).load(brand, mode);
    if (!theme.ok) {
        for (const QString &error : theme.errors)
            qCWarning(merceThemeLog) << "runtime theme switch failed:" << error;
        return false;
    }

    return applyLoadedTheme(theme);
}
```

QML selector controls must treat `false` as failure and preserve previous active state. Do not fabricate Stripe mode as `light`; empty `Theme.activeMode` displays as `default`.

### Generated Theme Fixtures

**Source:** `generated/themes/index.json` lines 1-18
**Apply to:** gallery selectors, probe expected values, export targets
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
    },
    "stripe": {
      "displayName": "Stripe Reference",
      "path": "stripe.json"
    }
  }
}
```

Expected visual/export states: `merce/light`, `merce/dark`, and `stripe` with empty mode.

### Existing Component Theme Consumption

**Source:** `Controls/MButton.qml` lines 38-50, 56-74, 101-145
**Apply to:** component smoke section in `ThemeGallery.qml`
```qml
override property color accentColor: {
    if (variant === "secondary") return Theme.colors.action.secondary
    if (variant === "outline") return Theme.colors.action.primary
    if (variant === "ghost") return Theme.colors.action.primary
    if (variant === "destructive") return Theme.colors.action.destructive
    return Theme.colors.action.primary
}

readonly property var sizeConfig: {
    "medium": {
        "height": Theme.spacing.touchTarget,
        "paddingH": Theme.spacing.xl,
        "fontSize": Theme.typography.sizeSmall,
        "iconSize": Theme.icons.medium
    }
}
```

**Source:** `Foundation/MText.qml` lines 12-24, 31-47
```qml
readonly property var types: {
    "h1": Theme.typography.h1,
    "h2": Theme.typography.h2,
    "h3": Theme.typography.h3,
    "body": Theme.typography.body,
    "bodyLarge": Theme.typography.bodyLarge
}

virtual property color textColor: Theme.colors.text.primary
font.family: types[type]?.family || Theme.typography.fontBody
font.pixelSize: types[type]?.size || Theme.typography.sizeMedium
font.weight: types[type]?.weight || Theme.typography.weightRegular
color: textColor
```

The gallery can prove component consumption by showing existing controls and switching active theme; it does not need a full component-state matrix.

### Verification Command Pattern

**Source:** existing Phase 3/4 verification and `playground/main.cpp`
**Apply to:** plan verification steps
```sh
ctest --test-dir build --output-on-failure
ctest --test-dir build -R tst_merce_theme_manifest_loader --output-on-failure
ctest --test-dir build -R tst_merce_theme_runtime_switch --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test
```

Add gallery-specific flags only after implementation defines exact names, for example `--theme-gallery-probe` and `--export-theme-gallery <output-dir>`.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| README/docs visual evidence file | docs | file-I/O | Repo root has no `README.md` and no `docs/` directory. Planner must choose the documentation target and deterministic artifact path before implementation. |

## Metadata

**Analog search scope:** `playground/`, `tests/Core/`, `Core/Theme/`, `Controls/`, `Foundation/`, `tools/`, `generated/themes/`, prior `.planning/phases/03-*` and `.planning/phases/04-*` artifacts.
**Files scanned:** 50+
**Pattern extraction date:** 2026-06-04
**Project skill directories:** `.codex/skills/` and `.agents/skills/` were absent in this checkout.
**Project instruction file:** `AGENTS.md` was absent on disk; user-provided AGENTS instructions were followed.
