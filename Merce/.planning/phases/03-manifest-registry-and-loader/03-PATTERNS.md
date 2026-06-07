# Phase 03: Manifest Registry And Loader - Pattern Map

**Mapped:** 2026-06-03
**Files analyzed:** 16 new/modified file groups
**Analogs found:** 14 / 16

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `Core/CMakeLists.txt` | config | file-I/O | `Core/CMakeLists.txt` + top-level `CMakeLists.txt` | exact |
| `Core/Theme/MerceThemeManifestLoader.h` | service | file-I/O | `external/qmlagent/src/plugins/qmltooling/qmldbg_agent/qqmlagentprotocol.cpp` | data-flow-match |
| `Core/Theme/MerceThemeManifestLoader.cpp` | service | file-I/O | `external/qmlagent/src/plugins/qmltooling/qmldbg_agent/qqmlagentprotocol.cpp` | data-flow-match |
| `Core/Theme/MerceThemeRegistry.h` | model | transform | `tools/design-tokens/src/theme-registry.mjs` | role-match |
| `Core/Theme/MerceThemeRegistry.cpp` | service | transform | `tools/design-tokens/src/theme-registry.mjs` | role-match |
| `Core/Theme/MerceThemeManifest.h` | model | transform | `tools/design-tokens/src/merce-manifest-format.mjs` | role-match |
| `Core/Theme/MerceTheme.cpp` | provider | request-response | `Core/Theme/MerceTheme.cpp` | exact |
| `Core/Theme/MerceTheme.h` | provider | request-response | `Core/Theme/MerceTheme.h` | exact |
| `Core/Theme/MercePalette.h` | model | transform | `Core/Theme/MercePalette.h` | exact |
| `Core/Theme/MerceSpacing.h` | model | transform | `Core/Theme/MerceSpacing.h` | exact |
| `Core/Theme/MerceRadius.h` | model | transform | `Core/Theme/MerceRadius.h` | exact |
| `Core/Theme/MerceTypography.h` | model | transform | `Core/Theme/MerceTypography.h` | exact |
| `tools/design-tokens/themes.json` | config | transform | `tools/design-tokens/themes.json` | exact |
| `tools/design-tokens/src/theme-registry.mjs` | utility | transform | `tools/design-tokens/src/theme-registry.mjs` | exact |
| `tools/design-tokens/src/merce-manifest-format.mjs` | utility | transform | `tools/design-tokens/src/merce-manifest-format.mjs` | exact |
| `tests/Core/tst_merce_theme_manifest_loader.cpp` or equivalent | test | file-I/O | `external/qmlagent/tests/auto/qmlagent/tst_qmlagentprotocol.cpp` | partial |

## Pattern Assignments

### `Core/CMakeLists.txt` (config, file-I/O)

**Analog:** `Core/CMakeLists.txt` and root `CMakeLists.txt`

**Target source grouping pattern** (`Core/CMakeLists.txt` lines 13-25):
```cmake
set(MERCE_CORE_THEME_SOURCES
    Theme/MerceTheme.cpp
    Theme/MerceTheme.h
    Theme/MercePalette.h
    Theme/MerceSpacing.h
    Theme/MerceRadius.h
    Theme/MerceTypography.h
    Theme/MerceMotion.h
    Theme/MerceIconography.h
    Theme/MerceZIndex.h
    Theme/MerceBreakpoints.h
    Theme/MerceShadows.h
)
```

**QML module ownership pattern** (`Core/CMakeLists.txt` lines 33-47):
```cmake
qt_add_qml_module(MerceCore
    URI "Merce.Core"
    VERSION 1.0
    SOURCES
        ${MERCE_CORE_THEME_SOURCES}
    QML_FILES
        ${MERCE_CORE_TOKEN_QML_FILES}
)

target_link_libraries(MerceCore
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
)
```

**Fail-fast optional tooling boundary** (`CMakeLists.txt` lines 8-23):
```cmake
option(MERCE_ENABLE_TOKEN_BUILD "Enable the Style Dictionary token manifest build target" OFF)

if(MERCE_ENABLE_TOKEN_BUILD)
    find_program(NPM_EXECUTABLE npm)
    if(NOT NPM_EXECUTABLE)
        message(FATAL_ERROR "MERCE_ENABLE_TOKEN_BUILD=ON requires npm, but npm was not found.")
    endif()

    add_custom_target(merce_tokens
        COMMAND "${NPM_EXECUTABLE}" run build
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tools/design-tokens"
        COMMENT "Generating Merce theme manifests"
        VERBATIM
    )
endif()
```

**Apply to Phase 3:** keep resource packaging in `MerceCore`; add new loader sources to `MERCE_CORE_THEME_SOURCES`; add a generated-manifest file list with `if(NOT EXISTS ...) message(FATAL_ERROR ...)`; use `qt_add_resources(MerceCore ... PREFIX "/merce/themes" BASE "${CMAKE_SOURCE_DIR}/generated/themes" FILES ...)`. Do not auto-run npm from normal configure/build.

---

### `Core/Theme/MerceThemeManifestLoader.h/.cpp` (service, file-I/O)

**Analog:** `external/qmlagent/src/plugins/qmltooling/qmldbg_agent/qqmlagentprotocol.cpp`

**Imports pattern** (lines 4-7):
```cpp
#include "qqmlagentprotocol_p.h"

#include <QtCore/qjsondocument.h>
#include <QtCore/qjsonvalue.h>
```

**JSON parse and validation pattern** (lines 27-39):
```cpp
QJsonParseError parseError;
const QJsonDocument document = QJsonDocument::fromJson(message, &parseError);
if (parseError.error != QJsonParseError::NoError) {
    request.errorCode = -32700;
    request.errorMessage = QStringLiteral("Parse error");
    return request;
}

if (!document.isObject()) {
    request.errorCode = -32600;
    request.errorMessage = QStringLiteral("Invalid request");
    return request;
}
```

**Structured result pattern** (lines 13-24):
```cpp
Request request;

if (message.size() > MaxInboundMessageBytes) {
    request.errorCode = -32000;
    request.errorMessage = QStringLiteral("QmlAgent request payload is too large");
    request.errorData = {
        { QStringLiteral("actualBytes"), message.size() },
        { QStringLiteral("maxBytes"), MaxInboundMessageBytes },
        { QStringLiteral("hint"),
          QStringLiteral("Send a smaller JSON-RPC request; use selectors, projection fields, and bounded params.") },
    };
    return request;
}
```

**Apply to Phase 3:** use `QFile` + `QJsonDocument::fromJson` + `QJsonParseError`; return a loader result with `ok`, `theme`, optional `variant`, `usedFallback`, `errors`, and final `QJsonObject manifest`. Prefer early returns with structured errors. Log failures with `qWarning` or `QLoggingCategory`, but do not expose QML-visible diagnostics.

---

### `Core/Theme/MerceThemeRegistry.h/.cpp` (model/service, transform)

**Analog:** `tools/design-tokens/src/theme-registry.mjs`

**Index validation pattern** (lines 4-24):
```javascript
export async function loadThemeRegistry(registryPath = new URL('../themes.json', import.meta.url)) {
  const raw = await readFile(registryPath, 'utf8');
  const registry = JSON.parse(raw);

  if (registry.schemaVersion !== 1) {
    throw new Error('themes.json schemaVersion must be 1');
  }

  if (!registry.defaultTheme) {
    throw new Error('themes.json must declare defaultTheme');
  }

  if (!registry.themes || typeof registry.themes !== 'object') {
    throw new Error('themes.json must declare a themes object');
  }

  return registry;
}
```

**Sparse theme normalization pattern** (lines 35-64):
```javascript
return Object.entries(registry.themes).flatMap(([themeName, theme]) => {
  const themeSources = theme.source ?? [];

  if (theme.variants) {
    return Object.entries(theme.variants).map(([variantName, destination]) => {
      return {
        theme: themeName,
        displayName: theme.displayName ?? themeName,
        variant: variantName,
        path: destination,
        source: [...coreSources, ...themeSources, ...variantSources],
      };
    });
  }

  if (!theme.path) {
    throw new Error(`Theme '${themeName}' must declare path or variants`);
  }

  return [{
    theme: themeName,
    displayName: theme.displayName ?? themeName,
    path: theme.path,
    source: [...coreSources, ...themeSources],
  }];
});
```

**Current generated index shape** (`generated/themes/index.json` lines 1-18):
```json
{
  "schemaVersion": 1,
  "defaultTheme": "merce",
  "themes": {
    "merce": {
      "displayName": "Merce",
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

**Apply to Phase 3:** normalize both single-manifest and variant-backed themes into one internal entry shape. Read manifest paths only from index entries. Reject empty paths, absolute paths, `../`, path separators, and arbitrary `:/...` values inside the index.

---

### `Core/Theme/MerceThemeManifest.h` (model, transform)

**Analog:** `tools/design-tokens/src/merce-manifest-format.mjs`

**Supported section field-map pattern** (lines 3-28, 29-66, 67-97):
```javascript
const FIELD_MAP = {
  palette: [
    ['textPrimary', 'palette.semantic.textPrimary'],
    ['textSecondary', 'palette.semantic.textSecondary'],
    ['textTertiary', 'palette.semantic.textTertiary'],
    ['textInverse', 'palette.semantic.textInverse'],
    ['link', 'palette.semantic.link'],
    ['backgroundBase', 'palette.semantic.backgroundBase'],
    ['backgroundSurface', 'palette.semantic.backgroundSurface'],
    ['backgroundElevated', 'palette.semantic.backgroundElevated'],
    ['backgroundHover', 'palette.semantic.backgroundHover'],
    ['backgroundPressed', 'palette.semantic.backgroundPressed'],
    ['actionPrimary', 'palette.semantic.actionPrimary'],
    ['actionPrimaryLight', 'palette.semantic.actionPrimaryLight'],
    ['actionPrimaryDark', 'palette.semantic.actionPrimaryDark'],
    ['actionSecondary', 'palette.semantic.actionSecondary'],
    ['borderBase', 'palette.semantic.borderBase'],
    ['borderStrong', 'palette.semantic.borderStrong'],
    ['borderFocus', 'palette.semantic.borderFocus'],
    ['statusError', 'palette.semantic.statusError'],
    ['statusSuccess', 'palette.semantic.statusSuccess'],
    ['statusWarning', 'palette.semantic.statusWarning'],
    ['statusInfo', 'palette.semantic.statusInfo'],
    ['surfaceBase', 'palette.semantic.surfaceBase'],
    ['surfaceTinted', 'palette.semantic.surfaceTinted'],
  ],
  spacing: [
    'base',
    'none',
    'xxs',
    'xs',
    'sm',
    'md',
    'lg',
    'xl',
    'xl2',
    'xl3',
    'xl4',
    'xl5',
    'xl6',
    'componentGap',
    'sectionGap',
    'pagePadding',
    'touchTarget',
    'touchTargetCompact',
    'gridGap',
    'stackGap',
    'inlineGap',
  ].map((name) => [name, `spacing.${name}`]),
  radius: [
    'none',
    'small',
    'medium',
    'large',
    'xlarge',
    'xxlarge',
    'full',
    'button',
    'input',
    'card',
    'badge',
    'dialog',
    'tooltip',
  ].map((name) => [name, `radius.${name}`]),
  typography: [
    'displayFont',
    'bodyFont',
    'monoFont',
    'displayFontFallback',
    'bodyFontFallback',
    'sizeXSmall',
    'sizeSmall',
    'sizeMedium',
    'sizeLarge',
    'sizeXLarge',
    'size2XLarge',
    'size3XLarge',
    'size4XLarge',
    'size5XLarge',
    'size6XLarge',
    'size7XLarge',
    'weightRegular',
    'weightMedium',
    'weightSemibold',
    'weightBold',
    'leadingTight',
    'leadingSnug',
    'leadingNormal',
    'leadingRelaxed',
    'trackingTight',
    'trackingNormal',
    'trackingWide',
    'trackingWider',
    'trackingWidest',
  ].map((name) => [name, `typography.${name}`]),
};
```

**Manifest identity pattern** (lines 108-121):
```javascript
const manifest = {
  schemaVersion: 1,
  theme: options.theme,
};

if (options.variant) {
  manifest.variant = options.variant;
}

for (const [section, fields] of Object.entries(FIELD_MAP)) {
  manifest[section] = Object.fromEntries(
    fields.map(([name, tokenPath]) => [name, requiredValue(tokenValues, tokenPath)]),
  );
}
```

**Apply to Phase 3:** keep C++ manifest structs plain and internal. Required fields should mirror generated runtime field names first: `palette`, `spacing`, `radius`, `typography`. Add support sections only if generator output is extended in the same phase.

---

### `Core/Theme/MerceTheme.h/.cpp` (provider, request-response)

**Analog:** `Core/Theme/MerceTheme.h/.cpp`

**Public singleton contract pattern** (`Core/Theme/MerceTheme.h` lines 16-35):
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

public:
    explicit MerceTheme(QObject *parent = nullptr);
```

**Typed ownership pattern** (`Core/Theme/MerceTheme.cpp` lines 3-15):
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
{
}
```

**Apply to Phase 3:** wire default manifest loading after typed children are constructed. Do not add public `Theme.setTheme`, active theme properties, or QML-visible error state in this phase. If apply methods emit child `changed()` signals, emit parent section signals only when needed for existing QML bindings.

---

### `Core/Theme/MercePalette.h` (model, transform)

**Analog:** `Core/Theme/MercePalette.h`

**Compatibility grouping pattern** (lines 328-347):
```cpp
class MercePalette : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MercePaletteRaw *raw READ raw CONSTANT FINAL)
    Q_PROPERTY(MercePaletteAction *action READ action CONSTANT FINAL)
    Q_PROPERTY(MercePaletteProduct *product READ product CONSTANT FINAL)
    Q_PROPERTY(MercePaletteText *text READ text CONSTANT FINAL)
    Q_PROPERTY(MercePaletteBackground *background READ background CONSTANT FINAL)
    Q_PROPERTY(MercePaletteBorder *border READ border CONSTANT FINAL)
    Q_PROPERTY(MercePaletteStatus *status READ status CONSTANT FINAL)
    Q_PROPERTY(MercePaletteSurface *surface READ surface CONSTANT FINAL)
    Q_PROPERTY(QColor textPrimary READ textPrimary NOTIFY changed FINAL)
    Q_PROPERTY(QColor textInverse READ textInverse NOTIFY changed FINAL)
    Q_PROPERTY(QColor backgroundBase READ backgroundBase NOTIFY changed FINAL)
    Q_PROPERTY(QColor backgroundSurface READ backgroundSurface NOTIFY changed FINAL)
    Q_PROPERTY(QColor actionPrimary READ actionPrimary NOTIFY changed FINAL)
    Q_PROPERTY(QColor actionSecondary READ actionSecondary NOTIFY changed FINAL)
    Q_PROPERTY(QColor borderBase READ borderBase NOTIFY changed FINAL)
    Q_PROPERTY(QColor statusError READ statusError NOTIFY changed FINAL)
    QML_ANONYMOUS
```

**Derived compatibility accessors** (lines 372-379):
```cpp
QColor textPrimary() const { return m_text->primary(); }
QColor textInverse() const { return m_text->inverse(); }
QColor backgroundBase() const { return m_background->base(); }
QColor backgroundSurface() const { return m_background->surface(); }
QColor actionPrimary() const { return m_action->primary(); }
QColor actionSecondary() const { return m_action->secondary(); }
QColor borderBase() const { return m_border->base(); }
QColor statusError() const { return m_status->error(); }
```

**Apply to Phase 3:** preserve nested compatibility objects (`raw`, `action`, `text`, `background`, etc.). Convert hardcoded getter constants to private storage or a narrow internal apply API. Keep QML-facing properties unchanged.

---

### `Core/Theme/MerceSpacing.h` and `Core/Theme/MerceRadius.h` (model, transform)

**Analogs:** `Core/Theme/MerceSpacing.h`, `Core/Theme/MerceRadius.h`

**Spacing property shape** (`Core/Theme/MerceSpacing.h` lines 6-30):
```cpp
class MerceSpacing : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int base READ base NOTIFY changed FINAL)
    Q_PROPERTY(int none READ none NOTIFY changed FINAL)
    Q_PROPERTY(int xxs READ xxs NOTIFY changed FINAL)
    Q_PROPERTY(int xs READ xs NOTIFY changed FINAL)
    Q_PROPERTY(int sm READ sm NOTIFY changed FINAL)
    Q_PROPERTY(int md READ md NOTIFY changed FINAL)
    Q_PROPERTY(int lg READ lg NOTIFY changed FINAL)
    Q_PROPERTY(int xl READ xl NOTIFY changed FINAL)
    Q_PROPERTY(int touchTarget READ touchTarget NOTIFY changed FINAL)
    Q_PROPERTY(int touchTargetCompact READ touchTargetCompact NOTIFY changed FINAL)
    QML_ANONYMOUS
```

**Spacing fallback values** (`Core/Theme/MerceSpacing.h` lines 35-55):
```cpp
int base() const { return 8; }
int none() const { return 0; }
int xxs() const { return 4; }
int xs() const { return 8; }
int sm() const { return 12; }
int md() const { return 16; }
int touchTarget() const { return 44; }
int touchTargetCompact() const { return 36; }
int gridGap() const { return 16; }
int stackGap() const { return 12; }
int inlineGap() const { return 8; }
```

**Radius property and derived token pattern** (`Core/Theme/MerceRadius.h` lines 6-42):
```cpp
class MerceRadius : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int none READ none NOTIFY changed FINAL)
    Q_PROPERTY(int small READ small NOTIFY changed FINAL)
    Q_PROPERTY(int medium READ medium NOTIFY changed FINAL)
    Q_PROPERTY(int large READ large NOTIFY changed FINAL)
    Q_PROPERTY(int xlarge READ xlarge NOTIFY changed FINAL)
    Q_PROPERTY(int xxlarge READ xxlarge NOTIFY changed FINAL)
    Q_PROPERTY(int full READ full NOTIFY changed FINAL)
    Q_PROPERTY(int button READ button NOTIFY changed FINAL)
    Q_PROPERTY(int input READ input NOTIFY changed FINAL)
    Q_PROPERTY(int card READ card NOTIFY changed FINAL)
    Q_PROPERTY(int badge READ badge NOTIFY changed FINAL)
    Q_PROPERTY(int dialog READ dialog NOTIFY changed FINAL)
    Q_PROPERTY(int tooltip READ tooltip NOTIFY changed FINAL)
    QML_ANONYMOUS
```

**Apply to Phase 3:** preserve property names and current defaults as construction fallback data. Manifest apply should update stored values and emit `changed()` after successful whole-section validation.

---

### `Core/Theme/MerceTypography.h` (model, transform)

**Analog:** `Core/Theme/MerceTypography.h`

**Typography property shape** (lines 7-51):
```cpp
class MerceTypography : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fontDisplay READ fontDisplay NOTIFY changed FINAL)
    Q_PROPERTY(QString fontBody READ fontBody NOTIFY changed FINAL)
    Q_PROPERTY(QString fontMono READ fontMono NOTIFY changed FINAL)
    Q_PROPERTY(QString fontDisplayFallback READ fontDisplayFallback NOTIFY changed FINAL)
    Q_PROPERTY(QString fontBodyFallback READ fontBodyFallback NOTIFY changed FINAL)
    Q_PROPERTY(int sizeXSmall READ sizeXSmall NOTIFY changed FINAL)
    Q_PROPERTY(int sizeSmall READ sizeSmall NOTIFY changed FINAL)
    Q_PROPERTY(int sizeMedium READ sizeMedium NOTIFY changed FINAL)
    Q_PROPERTY(int weightRegular READ weightRegular NOTIFY changed FINAL)
    Q_PROPERTY(qreal leadingTight READ leadingTight NOTIFY changed FINAL)
    Q_PROPERTY(qreal trackingNormal READ trackingNormal NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap body READ body NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap button READ button NOTIFY changed FINAL)
    Q_PROPERTY(QVariantMap price READ price NOTIFY changed FINAL)
    QML_ANONYMOUS
```

**Preset construction pattern** (lines 86-114):
```cpp
QVariantMap display() const { return preset(fontDisplay(), size5XLarge(), weightBold(), leadingTight(), trackingTight()); }
QVariantMap h1() const { return preset(fontDisplay(), size4XLarge(), weightSemibold(), leadingTight(), trackingTight()); }
QVariantMap body() const { return preset(fontBody(), sizeMedium(), weightRegular(), leadingNormal(), trackingNormal()); }
QVariantMap button() const { return preset(fontBody(), sizeSmall(), weightSemibold(), leadingTight(), trackingNormal()); }
QVariantMap price() const { return preset(fontBody(), size2XLarge(), weightBold(), leadingTight(), trackingTight()); }

static QVariantMap preset(const QString &family, int size, int weight, qreal leading, qreal tracking, bool uppercase = false)
{
    QVariantMap map;
    map.insert(QStringLiteral("family"), family);
    map.insert(QStringLiteral("size"), size);
    map.insert(QStringLiteral("weight"), weight);
    map.insert(QStringLiteral("leading"), leading);
    map.insert(QStringLiteral("tracking"), tracking);
    if (uppercase)
        map.insert(QStringLiteral("uppercase"), true);
    return map;
}
```

**Apply to Phase 3:** load primitive typography fields from manifest; keep preset methods derived from current getters/storage so QML preset maps stay compatible.

---

### `tools/design-tokens/themes.json` and `tools/design-tokens/src/theme-registry.mjs` (config/utility, transform)

**Analog:** existing same files

**Current registry input shape** (`tools/design-tokens/themes.json` lines 10-37):
```json
"themes": {
  "merce": {
    "displayName": "Merce",
    "source": [
      "tokens/themes/merce/theme.json"
    ],
    "defaultVariant": "light",
    "variants": {
      "light": "merce.light.json",
      "dark": "merce.dark.json"
    },
    "variantSources": {
      "light": [
        "tokens/themes/merce/variants/light.json"
      ],
      "dark": [
        "tokens/themes/merce/variants/dark.json"
      ]
    }
  },
  "stripe": {
    "displayName": "Stripe Reference",
    "source": [
      "tokens/themes/stripe/theme.json"
    ],
    "path": "stripe.json"
  }
}
```

**Generated index emission pattern** (`tools/design-tokens/src/theme-registry.mjs` lines 67-90):
```javascript
export function generatedIndex(registry) {
  const themes = Object.fromEntries(
    Object.entries(registry.themes).map(([themeName, theme]) => {
      if (theme.variants) {
        return [themeName, {
          displayName: theme.displayName ?? themeName,
          defaultVariant: theme.defaultVariant,
          variants: theme.variants,
        }];
      }

      return [themeName, {
        displayName: theme.displayName ?? themeName,
        path: theme.path,
      }];
    }),
  );

  return {
    schemaVersion: registry.schemaVersion,
    defaultTheme: registry.defaultTheme,
    themes,
  };
}
```

**Build/write/validate loop** (`tools/design-tokens/build.mjs` lines 22-57):
```javascript
await mkdir(GENERATED_DIR, { recursive: true });

const registry = await loadThemeRegistry();
const index = generatedIndex(registry);
await writeFile(path.join(GENERATED_DIR, 'index.json'), `${JSON.stringify(index, null, 2)}\n`);

for (const entry of themeEntries(registry)) {
  const sd = new StyleDictionary({
    source: entry.source.map((sourcePath) => resolveRegistryPath(sourcePath, TOOL_ROOT)),
    platforms: {
      merce: {
        buildPath: `${GENERATED_DIR}/`,
        files: [{
          destination: entry.path,
          format: FORMAT_NAME,
          options: {
            theme: entry.theme,
            variant: entry.variant,
          },
        }],
      },
    },
  });

  await sd.buildAllPlatforms();
  await validateManifestFile(path.join(GENERATED_DIR, entry.path), {
    theme: entry.theme,
    variant: entry.variant,
  });
}
```

**Apply to Phase 3:** add optional per-theme `basePath` to registry input and generated index output. If generating `merce.default.json`, add an entry path and validation path without changing normal CMake to run npm.

---

### `tests/Core/tst_merce_theme_manifest_loader.cpp` or equivalent (test, file-I/O)

**Analog:** `external/qmlagent/tests/auto/qmlagent/CMakeLists.txt` and `tst_qmlagentprotocol.cpp`

**QTest executable pattern** (`external/qmlagent/tests/auto/qmlagent/CMakeLists.txt` lines 22-44):
```cmake
qt_add_executable(tst_qmlagentprotocol
    tst_qmlagentprotocol.cpp
    ${PROJECT_SOURCE_DIR}/src/plugins/qmltooling/qmldbg_agent/qqmlagentprotocol.cpp
    ${PROJECT_SOURCE_DIR}/tools/qmlagent/qmlagentmcpprotocol.cpp
)

target_include_directories(tst_qmlagentprotocol PRIVATE
    ${PROJECT_SOURCE_DIR}/src/plugins/qmltooling/qmldbg_agent
    ${PROJECT_SOURCE_DIR}/tools/qmlagent
)

target_link_libraries(tst_qmlagentprotocol PRIVATE
    Qt6::Core
    Qt6::Test
)

add_test(NAME qmlagentprotocol
    COMMAND tst_qmlagentprotocol
)
```

**QTest class and negative validation pattern** (`external/qmlagent/tests/auto/qmlagent/tst_qmlagentprotocol.cpp` lines 12-28, 46-53):
```cpp
class tst_QQmlAgentProtocol : public QObject
{
    Q_OBJECT

private slots:
    void parsesValidRequest();
    void rejectsMalformedJsonAsParseError();
    void rejectsOversizedRequest();
    void rejectsNonObjectJsonAsInvalidRequest();
    void rejectsInvalidParams();
    void formatsResponse();
    void formatsError();
    void formatsEvent();
};

void tst_QQmlAgentProtocol::rejectsMalformedJsonAsParseError()
{
    const auto request = QQmlAgentProtocol::parseRequest("{");

    QVERIFY(!request.valid);
    QCOMPARE(request.errorCode, -32700);
    QCOMPARE(request.errorMessage, QStringLiteral("Parse error"));
}
```

**QML smoke probe pattern** (`playground/ThemeProbe.qml` lines 4-32):
```qml
QtObject {
    Component.onCompleted: {
        const backgroundBase = String(Theme.palette.backgroundBase).toLowerCase()
        const compatibilityBase = String(Theme.colors.background.base).toLowerCase()

        if (backgroundBase !== "#faf8f6"
                || compatibilityBase !== "#faf8f6"
                || Theme.spacing.md !== 16
                || Theme.radius.button !== 12
                || Theme.icons.small !== 20
                || !Theme.palette.textPrimary
                || !Theme.colors.action.base("primary")) {
            console.error("theme-probe failed",
                          backgroundBase,
                          compatibilityBase,
                          Theme.spacing.md,
                          Theme.radius.button,
                          Theme.icons.small)
            Qt.exit(1)
            return
        }

        console.log("theme-probe ok",
                    Theme.palette.backgroundBase,
                    Theme.colors.background.base,
                    Theme.spacing.md,
                    Theme.radius.button,
                    Theme.icons.small)
        Qt.quit()
    }
}
```

**Apply to Phase 3:** add focused tests for malformed index JSON, unsafe paths, unknown theme/variant rejection, base+active section overlay, strict final validation, requested fallback, and default failure. Keep `ThemeProbe.qml` as smoke verification that public QML values still resolve through `Theme`.

## Shared Patterns

### Public QML Contract Boundary

**Source:** `Core/Theme/MerceTheme.h` lines 16-35
**Apply to:** `MerceTheme` integration and all typed theme object changes
```cpp
Q_PROPERTY(MercePalette *palette READ palette NOTIFY paletteChanged FINAL)
Q_PROPERTY(MercePalette *colors READ colors NOTIFY paletteChanged FINAL)
Q_PROPERTY(MerceSpacing *spacing READ spacing NOTIFY spacingChanged FINAL)
Q_PROPERTY(MerceRadius *radius READ radius NOTIFY radiusChanged FINAL)
Q_PROPERTY(MerceTypography *typography READ typography NOTIFY typographyChanged FINAL)
QML_NAMED_ELEMENT(Theme)
QML_SINGLETON
```

Do not add public switching API or public diagnostics in Phase 3.

### JSON Error Handling

**Source:** `external/qmlagent/src/plugins/qmltooling/qmldbg_agent/qqmlagentprotocol.cpp` lines 27-39
**Apply to:** manifest index parser, manifest parser, tests
```cpp
QJsonParseError parseError;
const QJsonDocument document = QJsonDocument::fromJson(message, &parseError);
if (parseError.error != QJsonParseError::NoError) {
    request.errorCode = -32700;
    request.errorMessage = QStringLiteral("Parse error");
    return request;
}

if (!document.isObject()) {
    request.errorCode = -32600;
    request.errorMessage = QStringLiteral("Invalid request");
    return request;
}
```

### Runtime Manifest Validation

**Source:** `tools/design-tokens/src/validate-manifest.mjs` lines 5-22, 24-67
**Apply to:** C++ final manifest validator
```javascript
const REQUIRED_TOP_LEVEL = [
  'schemaVersion',
  'theme',
  'palette',
  'spacing',
  'radius',
  'typography',
];

const REQUIRED_FIELDS = [
  'palette.textPrimary',
  'palette.backgroundBase',
  'palette.actionPrimary',
  'spacing.md',
  'spacing.touchTarget',
  'radius.button',
  'typography.bodyFont',
];

export function validateManifest(manifest, context = {}) {
  const errors = [];

  for (const field of REQUIRED_TOP_LEVEL) {
    if (!hasPath(manifest, field)) {
      errors.push(`missing required field: ${field}`);
    }
  }

  if (manifest.schemaVersion !== 1) {
    errors.push('schemaVersion must be 1');
  }

  if (context.theme && manifest.theme !== context.theme) {
    errors.push(`theme must be '${context.theme}'`);
  }

  if (context.variant && manifest.variant !== context.variant) {
    errors.push(`variant must be '${context.variant}'`);
  }

  return {
    ok: errors.length === 0,
    errors,
  };
}
```

### Resource and Tooling Boundary

**Source:** `CMakeLists.txt` lines 8-23 and `Core/CMakeLists.txt` lines 33-47
**Apply to:** manifest resource packaging
```cmake
option(MERCE_ENABLE_TOKEN_BUILD "Enable the Style Dictionary token manifest build target" OFF)

qt_add_qml_module(MerceCore
    URI "Merce.Core"
    VERSION 1.0
    SOURCES
        ${MERCE_CORE_THEME_SOURCES}
    QML_FILES
        ${MERCE_CORE_TOKEN_QML_FILES}
)
```

Generated artifacts are consumed by CMake; Node/Style Dictionary remains optional tooling and must not be invoked by normal `MerceCore` configure/build.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `Core/Theme/MerceThemeManifestLoader.h/.cpp` | service | file-I/O | No existing main-repo Qt resource JSON loader exists; use Qt JSON parse pattern from `external/qmlagent` plus Phase 3 requirements. |
| `Core/Theme/MerceThemeRegistry.h/.cpp` | model/service | transform | No existing C++ sparse registry normalizer exists; use JS generator registry shape as semantic analog. |

## Metadata

**Analog search scope:** `Core/`, `tools/design-tokens/`, `generated/themes/`, `playground/`, `external/qmlagent/tests/auto/`, `external/qmlagent/src/plugins/qmltooling/`
**Files scanned:** 40+ excluding `tools/design-tokens/node_modules` and `build`
**Pattern extraction date:** 2026-06-03
**Dirty worktree note:** Existing unrelated dirty entries were observed; only this `03-PATTERNS.md` file was written for pattern mapping.
