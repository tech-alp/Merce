# Theme Colors Canonicalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `Theme.palette` with semantic-only `Theme.colors`, remove raw color scales from the public QML API, and align source tokens/runtime manifests around `color.*` -> `colors.*`.

**Architecture:** DTCG-style source tokens keep raw/base scales under `color.palette.*` and semantic aliases under `color.text.*`, `color.background.*`, `color.border.*`, `color.action.*`, and `color.status.*`. Generated runtime manifests become Qt-friendly nested `colors` manifests. QML consumes only semantic `Theme.colors.*` groups; raw values remain source/mapping/debug-only.

**Tech Stack:** Qt 6, C++17, QML singletons, Style Dictionary v5, Node 22 token tooling, QtTest, MercePlayground offscreen probes.

---

## File Structure

- Rename: `Core/Theme/MercePalette.h` -> `Core/Theme/MerceColors.h`
  - Owns semantic runtime color objects.
  - Exposes `text`, `background`, `border`, `action`, `status`, and `surface`.
  - Does not expose `raw`, `product`, or flat aliases like `textPrimary`.
- Modify: `Core/Theme/MerceTheme.h`
  - Remove `palette` property and `paletteChanged`.
  - Keep only `Q_PROPERTY(MerceColors *colors READ colors CONSTANT FINAL)`.
- Modify: `Core/Theme/MerceTheme.cpp`
  - Construct `MerceColors`.
  - Apply manifest section `colors`.
- Modify: `Core/Theme/MerceThemeManifestLoader.cpp`
  - Replace top-level `palette` section validation with nested `colors`.
  - Reject legacy top-level `palette` and `colors.raw`.
- Modify: `tools/design-tokens/src/merce-manifest-format.mjs`
  - Rename source taxonomy from `palette.*` to `color.*`.
  - Emit nested runtime `colors` object.
- Modify: `tools/design-tokens/src/validate-manifest.mjs`
  - Validate nested `colors`.
  - Reject top-level `palette`, `colors.raw`, raw DTCG leftovers, and unresolved token references.
- Rename: `tools/design-tokens/tokens/core/palette.json` -> `tools/design-tokens/tokens/core/color.json`
  - Root group becomes `color`.
  - Raw/base colors live under `color.palette.*`.
  - Semantic aliases live under `color.text.*`, `color.background.*`, `color.border.*`, `color.action.*`, `color.status.*`, `color.surface.*`.
- Modify: `tools/design-tokens/themes.json`
  - Replace `tokens/core/palette.json` with `tokens/core/color.json`.
- Modify: `tools/design-tokens/tokens/themes/**`
  - Rewrite references from `{palette.raw.*}` / `{palette.semantic.*}` to `{color.palette.*}` / semantic `color.*` paths.
- Regenerate: `generated/themes/*.json`
  - Generated manifests use top-level `colors`, not `palette`.
- Modify: `Foundation/*.qml`, `Controls/*.qml`, `Icons/*.qml`, `playground/**/*.qml`
  - Replace all `Theme.palette.*` usages with `Theme.colors.*`.
  - Replace raw runtime usages with semantic roles.
- Modify: `tests/Core/tst_merce_theme_manifest_loader.cpp`
  - Test nested `colors` manifest shape and legacy rejection.
- Modify: `tests/Core/tst_merce_theme_runtime_switch.cpp`
  - Test that `palette` is absent, `colors` is canonical, and stable object pointers still hold.
- Modify docs:
  - `tools/design-tokens/README.md`
  - `skills/merce-design-md-to-dtcg/references/merce-theme-contract.md`
  - `docs/superpowers/specs/2026-06-05-runtime-theme-sources-design.md`

---

### Task 1: Lock The New Colors Contract With Failing Tests

**Files:**
- Modify: `tests/Core/tst_merce_theme_manifest_loader.cpp`
- Modify: `tests/Core/tst_merce_theme_runtime_switch.cpp`

- [ ] **Step 1: Add nested colors helpers to manifest loader test**

In `tests/Core/tst_merce_theme_manifest_loader.cpp`, add this helper next to `objectFromPairs(...)`:

```cpp
QJsonObject colorsSection()
{
    return {
        { QStringLiteral("text"), QJsonObject{
            { QStringLiteral("primary"), QStringLiteral("#111111") },
            { QStringLiteral("secondary"), QStringLiteral("#222222") },
            { QStringLiteral("tertiary"), QStringLiteral("#333333") },
            { QStringLiteral("inverse"), QStringLiteral("#ffffff") },
            { QStringLiteral("disabled"), QStringLiteral("#aaaaaa") },
            { QStringLiteral("link"), QStringLiteral("#0000ff") },
            { QStringLiteral("linkHover"), QStringLiteral("#000099") },
        } },
        { QStringLiteral("background"), QJsonObject{
            { QStringLiteral("base"), QStringLiteral("#fafafa") },
            { QStringLiteral("surface"), QStringLiteral("#ffffff") },
            { QStringLiteral("elevated"), QStringLiteral("#ffffff") },
            { QStringLiteral("hover"), QStringLiteral("#eeeeee") },
            { QStringLiteral("pressed"), QStringLiteral("#dddddd") },
            { QStringLiteral("tinted"), QStringLiteral("#f0f0f0") },
            { QStringLiteral("overlay"), QStringLiteral("#000000") },
        } },
        { QStringLiteral("border"), QJsonObject{
            { QStringLiteral("base"), QStringLiteral("#cccccc") },
            { QStringLiteral("strong"), QStringLiteral("#999999") },
            { QStringLiteral("focus"), QStringLiteral("#777777") },
            { QStringLiteral("error"), QStringLiteral("#ff0000") },
            { QStringLiteral("success"), QStringLiteral("#00ff00") },
        } },
        { QStringLiteral("action"), QJsonObject{
            { QStringLiteral("primary"), QStringLiteral("#444444") },
            { QStringLiteral("primaryHover"), QStringLiteral("#333333") },
            { QStringLiteral("primaryPressed"), QStringLiteral("#222222") },
            { QStringLiteral("primarySubtle"), QStringLiteral("#555555") },
            { QStringLiteral("secondary"), QStringLiteral("#666666") },
            { QStringLiteral("secondaryHover"), QStringLiteral("#555555") },
            { QStringLiteral("secondaryPressed"), QStringLiteral("#444444") },
            { QStringLiteral("disabled"), QStringLiteral("#aaaaaa") },
        } },
        { QStringLiteral("status"), QJsonObject{
            { QStringLiteral("success"), QStringLiteral("#00ff00") },
            { QStringLiteral("successSubtle"), QStringLiteral("#ccffcc") },
            { QStringLiteral("warning"), QStringLiteral("#ffff00") },
            { QStringLiteral("warningSubtle"), QStringLiteral("#ffffcc") },
            { QStringLiteral("error"), QStringLiteral("#ff0000") },
            { QStringLiteral("errorSubtle"), QStringLiteral("#ffcccc") },
            { QStringLiteral("info"), QStringLiteral("#0000ff") },
            { QStringLiteral("infoSubtle"), QStringLiteral("#ccccff") },
        } },
        { QStringLiteral("surface"), QJsonObject{
            { QStringLiteral("base"), QStringLiteral("#ffffff") },
            { QStringLiteral("tinted"), QStringLiteral("#f0f0f0") },
            { QStringLiteral("raised"), QStringLiteral("#ffffff") },
        } },
    };
}
```

- [ ] **Step 2: Change `fullManifest(...)` to emit `colors`**

In the same test file, replace the current `manifest.insert("palette", ...)` block with:

```cpp
manifest.insert(QStringLiteral("colors"), colorsSection());
```

- [ ] **Step 3: Update test declarations**

In the `private slots:` list, replace:

```cpp
void topLevelColorsCompatibilitySectionIsRejected();
```

with:

```cpp
void topLevelPaletteSectionIsRejected();
void rawRuntimeColorsSectionIsRejected();
```

- [ ] **Step 4: Add legacy rejection tests**

Replace the implementation of `topLevelColorsCompatibilitySectionIsRejected()` with:

```cpp
void tst_merce_theme_manifest_loader::topLevelPaletteSectionIsRejected()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QJsonObject manifest = fullManifest(QStringLiteral("merce"), QStringLiteral("light"));
    manifest.insert(QStringLiteral("palette"), QJsonObject{
        { QStringLiteral("textPrimary"), QStringLiteral("#111111") },
    });

    QVERIFY(writeJson(pathIn(dir, QStringLiteral("merce.light.json")), manifest));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), indexForDefaultMerce(QStringLiteral("merce.light.json"))));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("manifest must not contain a top-level palette section")));
}

void tst_merce_theme_manifest_loader::rawRuntimeColorsSectionIsRejected()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QJsonObject manifest = fullManifest(QStringLiteral("merce"), QStringLiteral("light"));
    QJsonObject colors = manifest.value(QStringLiteral("colors")).toObject();
    colors.insert(QStringLiteral("raw"), QJsonObject{
        { QStringLiteral("gray50"), QStringLiteral("#fafafa") },
    });
    manifest.insert(QStringLiteral("colors"), colors);

    QVERIFY(writeJson(pathIn(dir, QStringLiteral("merce.light.json")), manifest));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), indexForDefaultMerce(QStringLiteral("merce.light.json"))));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("runtime colors must not expose raw color scales")));
}
```

- [ ] **Step 5: Update generated resource loader assertion**

In `generatedResourceIndexLoads()`, replace:

```cpp
QVERIFY(result.finalManifest.contains(QStringLiteral("palette")));
```

with:

```cpp
QVERIFY(result.finalManifest.contains(QStringLiteral("colors")));
QVERIFY(!result.finalManifest.contains(QStringLiteral("palette")));
```

- [ ] **Step 6: Add runtime meta-object failure expectations**

In `tests/Core/tst_merce_theme_runtime_switch.cpp`, update `defaultStateIsMerceLight()`:

```cpp
void tst_merce_theme_runtime_switch::defaultStateIsMerceLight()
{
    MerceTheme theme;

    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#FAF8F6")));
    QCOMPARE(theme.metaObject()->indexOfProperty("palette"), -1);
}
```

- [ ] **Step 7: Run tests to verify they fail**

Run:

```bash
cmake --build build --target tst_merce_theme_manifest_loader tst_merce_theme_runtime_switch
ctest --test-dir build --output-on-failure -R 'tst_merce_theme_(manifest_loader|runtime_switch)'
```

Expected: build or tests fail because `MerceTheme::palette()`, top-level `palette` validation, and `colors` nested manifest support have not been updated yet.

- [ ] **Step 8: Commit failing tests**

```bash
git add tests/Core/tst_merce_theme_manifest_loader.cpp tests/Core/tst_merce_theme_runtime_switch.cpp
git commit -m "test(theme): lock semantic colors contract"
```

---

### Task 2: Generate Nested `colors` Manifests From `color.*` Source Tokens

**Files:**
- Rename: `tools/design-tokens/tokens/core/palette.json` -> `tools/design-tokens/tokens/core/color.json`
- Modify: `tools/design-tokens/themes.json`
- Modify: `tools/design-tokens/src/merce-manifest-format.mjs`
- Modify: `tools/design-tokens/src/validate-manifest.mjs`
- Modify: `tools/design-tokens/tokens/themes/**`
- Regenerate: `generated/themes/*.json`

- [ ] **Step 1: Rename the core color source file**

Run:

```bash
mv tools/design-tokens/tokens/core/palette.json tools/design-tokens/tokens/core/color.json
```

- [ ] **Step 2: Change the core source root group**

In `tools/design-tokens/tokens/core/color.json`, replace the top-level key:

```json
"palette": {
```

with:

```json
"color": {
```

Then rename the nested semantic group from:

```json
"semantic": {
```

to:

```json
"text": {
```

Do not leave all semantic colors under `text`; Step 3 moves them into purpose groups.

- [ ] **Step 3: Normalize semantic groups in `color.json`**

Shape `tools/design-tokens/tokens/core/color.json` so it has this source structure:

```json
{
  "color": {
    "palette": {
      "primary": { "$type": "color", "$value": "#C4785A" },
      "primaryLight": { "$type": "color", "$value": "#E8B5A3" },
      "primaryDark": { "$type": "color", "$value": "#9A4F34" },
      "secondary": { "$type": "color", "$value": "#2D4A3E" },
      "secondaryLight": { "$type": "color", "$value": "#4A6B5D" },
      "secondaryDark": { "$type": "color", "$value": "#1A2C24" },
      "success": { "$type": "color", "$value": "#4A7C59" },
      "successLight": { "$type": "color", "$value": "#A8D4B8" },
      "warning": { "$type": "color", "$value": "#D4A854" },
      "warningLight": { "$type": "color", "$value": "#F0D9A8" },
      "error": { "$type": "color", "$value": "#C45A5A" },
      "errorLight": { "$type": "color", "$value": "#E8A8A8" },
      "info": { "$type": "color", "$value": "#5A8FC4" },
      "infoLight": { "$type": "color", "$value": "#A8CCE8" },
      "gray50": { "$type": "color", "$value": "#FAF8F6" },
      "gray100": { "$type": "color", "$value": "#F5F0EB" },
      "gray200": { "$type": "color", "$value": "#E8DFD5" },
      "gray300": { "$type": "color", "$value": "#D4C4B5" },
      "gray400": { "$type": "color", "$value": "#B8A494" },
      "gray500": { "$type": "color", "$value": "#9A8472" },
      "gray600": { "$type": "color", "$value": "#7A6556" },
      "gray700": { "$type": "color", "$value": "#5C4A3D" },
      "gray800": { "$type": "color", "$value": "#3D2F26" },
      "gray900": { "$type": "color", "$value": "#1F1510" },
      "white": { "$type": "color", "$value": "#FFFFFF" }
    },
    "text": {
      "primary": { "$type": "color", "$value": "{color.palette.gray900}" },
      "secondary": { "$type": "color", "$value": "{color.palette.gray700}" },
      "tertiary": { "$type": "color", "$value": "{color.palette.gray500}" },
      "inverse": { "$type": "color", "$value": "{color.palette.gray50}" },
      "disabled": { "$type": "color", "$value": "{color.palette.gray400}" },
      "link": { "$type": "color", "$value": "{color.palette.primary}" },
      "linkHover": { "$type": "color", "$value": "{color.palette.primaryDark}" }
    },
    "background": {
      "base": { "$type": "color", "$value": "{color.palette.gray50}" },
      "surface": { "$type": "color", "$value": "{color.palette.white}" },
      "elevated": { "$type": "color", "$value": "{color.palette.white}" },
      "hover": { "$type": "color", "$value": "{color.palette.gray100}" },
      "pressed": { "$type": "color", "$value": "{color.palette.gray200}" },
      "tinted": { "$type": "color", "$value": "{color.palette.gray100}" },
      "overlay": { "$type": "color", "$value": "#000000" }
    },
    "action": {
      "primary": { "$type": "color", "$value": "{color.palette.primary}" },
      "primaryHover": { "$type": "color", "$value": "{color.palette.primaryDark}" },
      "primaryPressed": { "$type": "color", "$value": "{color.palette.primaryDark}" },
      "primarySubtle": { "$type": "color", "$value": "{color.palette.primaryLight}" },
      "secondary": { "$type": "color", "$value": "{color.palette.secondary}" },
      "secondaryHover": { "$type": "color", "$value": "{color.palette.secondaryDark}" },
      "secondaryPressed": { "$type": "color", "$value": "{color.palette.secondaryDark}" },
      "disabled": { "$type": "color", "$value": "{color.palette.gray400}" }
    },
    "border": {
      "base": { "$type": "color", "$value": "{color.palette.gray200}" },
      "strong": { "$type": "color", "$value": "{color.palette.gray300}" },
      "focus": { "$type": "color", "$value": "{color.palette.primary}" },
      "error": { "$type": "color", "$value": "{color.palette.error}" },
      "success": { "$type": "color", "$value": "{color.palette.success}" }
    },
    "status": {
      "success": { "$type": "color", "$value": "{color.palette.success}" },
      "successSubtle": { "$type": "color", "$value": "{color.palette.successLight}" },
      "warning": { "$type": "color", "$value": "{color.palette.warning}" },
      "warningSubtle": { "$type": "color", "$value": "{color.palette.warningLight}" },
      "error": { "$type": "color", "$value": "{color.palette.error}" },
      "errorSubtle": { "$type": "color", "$value": "{color.palette.errorLight}" },
      "info": { "$type": "color", "$value": "{color.palette.info}" },
      "infoSubtle": { "$type": "color", "$value": "{color.palette.infoLight}" }
    },
    "surface": {
      "base": { "$type": "color", "$value": "{color.background.surface}" },
      "tinted": { "$type": "color", "$value": "{color.background.tinted}" },
      "raised": { "$type": "color", "$value": "{color.background.elevated}" }
    }
  }
}
```

- [ ] **Step 4: Update token registry core file**

In `tools/design-tokens/themes.json`, replace:

```json
"tokens/core/palette.json"
```

with:

```json
"tokens/core/color.json"
```

- [ ] **Step 5: Rewrite theme token references**

Run a careful search:

```bash
rg -n "palette\\." tools/design-tokens/tokens
```

For each match:

- Replace `{palette.raw.X}` with `{color.palette.X}`.
- Replace `{palette.semantic.textPrimary}` with `{color.text.primary}`.
- Replace `{palette.semantic.textSecondary}` with `{color.text.secondary}`.
- Replace `{palette.semantic.textTertiary}` with `{color.text.tertiary}`.
- Replace `{palette.semantic.textInverse}` with `{color.text.inverse}`.
- Replace `{palette.semantic.link}` with `{color.text.link}`.
- Replace `{palette.semantic.backgroundBase}` with `{color.background.base}`.
- Replace `{palette.semantic.backgroundSurface}` with `{color.background.surface}`.
- Replace `{palette.semantic.backgroundElevated}` with `{color.background.elevated}`.
- Replace `{palette.semantic.backgroundHover}` with `{color.background.hover}`.
- Replace `{palette.semantic.backgroundPressed}` with `{color.background.pressed}`.
- Replace `{palette.semantic.actionPrimary}` with `{color.action.primary}`.
- Replace `{palette.semantic.actionPrimaryLight}` with `{color.action.primarySubtle}`.
- Replace `{palette.semantic.actionPrimaryDark}` with `{color.action.primaryPressed}`.
- Replace `{palette.semantic.actionSecondary}` with `{color.action.secondary}`.
- Replace `{palette.semantic.borderBase}` with `{color.border.base}`.
- Replace `{palette.semantic.borderStrong}` with `{color.border.strong}`.
- Replace `{palette.semantic.borderFocus}` with `{color.border.focus}`.
- Replace `{palette.semantic.statusError}` with `{color.status.error}`.
- Replace `{palette.semantic.statusSuccess}` with `{color.status.success}`.
- Replace `{palette.semantic.statusWarning}` with `{color.status.warning}`.
- Replace `{palette.semantic.statusInfo}` with `{color.status.info}`.
- Replace `{palette.semantic.surfaceBase}` with `{color.surface.base}`.
- Replace `{palette.semantic.surfaceTinted}` with `{color.surface.tinted}`.

Run again until no matches remain:

```bash
rg -n "palette\\." tools/design-tokens/tokens
```

Expected: no output.

- [ ] **Step 6: Update manifest formatter to nested `colors`**

In `tools/design-tokens/src/merce-manifest-format.mjs`, replace the current `palette` entry in `FIELD_MAP` with:

```js
export const COLOR_FIELD_MAP = {
  text: [
    ['primary', 'color.text.primary'],
    ['secondary', 'color.text.secondary'],
    ['tertiary', 'color.text.tertiary'],
    ['inverse', 'color.text.inverse'],
    ['disabled', 'color.text.disabled'],
    ['link', 'color.text.link'],
    ['linkHover', 'color.text.linkHover'],
  ],
  background: [
    ['base', 'color.background.base'],
    ['surface', 'color.background.surface'],
    ['elevated', 'color.background.elevated'],
    ['hover', 'color.background.hover'],
    ['pressed', 'color.background.pressed'],
    ['tinted', 'color.background.tinted'],
    ['overlay', 'color.background.overlay'],
  ],
  border: [
    ['base', 'color.border.base'],
    ['strong', 'color.border.strong'],
    ['focus', 'color.border.focus'],
    ['error', 'color.border.error'],
    ['success', 'color.border.success'],
  ],
  action: [
    ['primary', 'color.action.primary'],
    ['primaryHover', 'color.action.primaryHover'],
    ['primaryPressed', 'color.action.primaryPressed'],
    ['primarySubtle', 'color.action.primarySubtle'],
    ['secondary', 'color.action.secondary'],
    ['secondaryHover', 'color.action.secondaryHover'],
    ['secondaryPressed', 'color.action.secondaryPressed'],
    ['disabled', 'color.action.disabled'],
  ],
  status: [
    ['success', 'color.status.success'],
    ['successSubtle', 'color.status.successSubtle'],
    ['warning', 'color.status.warning'],
    ['warningSubtle', 'color.status.warningSubtle'],
    ['error', 'color.status.error'],
    ['errorSubtle', 'color.status.errorSubtle'],
    ['info', 'color.status.info'],
    ['infoSubtle', 'color.status.infoSubtle'],
  ],
  surface: [
    ['base', 'color.surface.base'],
    ['tinted', 'color.surface.tinted'],
    ['raised', 'color.surface.raised'],
  ],
};

export const FIELD_MAP = {
  spacing: [
```

Then, in `formatMerceManifest(...)`, insert nested colors before the remaining section loop:

```js
  manifest.colors = Object.fromEntries(
    Object.entries(COLOR_FIELD_MAP).map(([groupName, fields]) => [
      groupName,
      Object.fromEntries(
        fields.map(([name, tokenPath]) => [name, requiredValue(tokenValues, tokenPath)]),
      ),
    ]),
  );
```

Keep the existing loop for `spacing`, `radius`, and `typography`.

- [ ] **Step 7: Update manifest validator**

In `tools/design-tokens/src/validate-manifest.mjs`:

- Replace required section `palette` with `colors`.
- Add nested color validation equivalent to this shape:

```js
const COLOR_FIELDS = {
  text: ['primary', 'secondary', 'tertiary', 'inverse', 'disabled', 'link', 'linkHover'],
  background: ['base', 'surface', 'elevated', 'hover', 'pressed', 'tinted', 'overlay'],
  border: ['base', 'strong', 'focus', 'error', 'success'],
  action: ['primary', 'primaryHover', 'primaryPressed', 'primarySubtle', 'secondary', 'secondaryHover', 'secondaryPressed', 'disabled'],
  status: ['success', 'successSubtle', 'warning', 'warningSubtle', 'error', 'errorSubtle', 'info', 'infoSubtle'],
  surface: ['base', 'tinted', 'raised'],
};
```

- Validate each nested value with the same color validation currently used for `palette.*`.
- Reject `manifest.palette`.
- Reject `manifest.colors.raw`.

- [ ] **Step 8: Build tokens**

Run:

```bash
cd tools/design-tokens
npm run build
npm run validate
npm run check
```

Expected: all commands pass and generated manifests contain top-level `colors`.

- [ ] **Step 9: Commit token taxonomy and manifest generation**

```bash
git add tools/design-tokens generated/themes
git commit -m "refactor(tokens)!: emit semantic colors manifests"
```

---

### Task 3: Replace `MercePalette` With Semantic `MerceColors`

**Files:**
- Rename: `Core/Theme/MercePalette.h` -> `Core/Theme/MerceColors.h`
- Modify: `Core/Theme/MerceTheme.h`
- Modify: `Core/Theme/MerceTheme.cpp`
- Modify: `Core/CMakeLists.txt` if it lists the header explicitly.

- [ ] **Step 1: Rename the header**

Run:

```bash
mv Core/Theme/MercePalette.h Core/Theme/MerceColors.h
```

- [ ] **Step 2: Rename classes and remove public raw/product/flat aliases**

In `Core/Theme/MerceColors.h`:

- Rename `MercePaletteAction` -> `MerceColorsAction`.
- Rename `MercePaletteText` -> `MerceColorsText`.
- Rename `MercePaletteBackground` -> `MerceColorsBackground`.
- Rename `MercePaletteBorder` -> `MerceColorsBorder`.
- Rename `MercePaletteStatus` -> `MerceColorsStatus`.
- Rename `MercePaletteSurface` -> `MerceColorsSurface`.
- Rename `MercePalette` -> `MerceColors`.
- Delete `MercePaletteRaw`.
- Delete `MercePaletteProduct`.
- Delete flat properties from the root object:
  - `textPrimary`
  - `textInverse`
  - `backgroundBase`
  - `backgroundSurface`
  - `actionPrimary`
  - `actionSecondary`
  - `borderBase`
  - `statusSuccess`
  - `statusError`

The root `MerceColors` object should expose only:

```cpp
Q_PROPERTY(MerceColorsAction *action READ action CONSTANT FINAL)
Q_PROPERTY(MerceColorsText *text READ text CONSTANT FINAL)
Q_PROPERTY(MerceColorsBackground *background READ background CONSTANT FINAL)
Q_PROPERTY(MerceColorsBorder *border READ border CONSTANT FINAL)
Q_PROPERTY(MerceColorsStatus *status READ status CONSTANT FINAL)
Q_PROPERTY(MerceColorsSurface *surface READ surface CONSTANT FINAL)
```

- [ ] **Step 3: Update `MerceColorsAction` API**

Make `MerceColorsAction` expose this public surface:

```cpp
Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
Q_PROPERTY(QColor primaryHover READ primaryHover NOTIFY changed FINAL)
Q_PROPERTY(QColor primaryPressed READ primaryPressed NOTIFY changed FINAL)
Q_PROPERTY(QColor primarySubtle READ primarySubtle NOTIFY changed FINAL)
Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
Q_PROPERTY(QColor secondaryHover READ secondaryHover NOTIFY changed FINAL)
Q_PROPERTY(QColor secondaryPressed READ secondaryPressed NOTIFY changed FINAL)
Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
```

Replace old `primaryLight`, `primaryDark`, `secondaryLight`, and `secondaryDark` public names with the new names. If helper methods are still needed, keep `base(...)` and `light(...)` internal-compatible only if no public QML code consumes them; otherwise replace call sites.

- [ ] **Step 4: Update `MerceColorsText` API**

Expose:

```cpp
Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
Q_PROPERTY(QColor secondary READ secondary NOTIFY changed FINAL)
Q_PROPERTY(QColor tertiary READ tertiary NOTIFY changed FINAL)
Q_PROPERTY(QColor inverse READ inverse NOTIFY changed FINAL)
Q_PROPERTY(QColor disabled READ disabled NOTIFY changed FINAL)
Q_PROPERTY(QColor link READ link NOTIFY changed FINAL)
Q_PROPERTY(QColor linkHover READ linkHover NOTIFY changed FINAL)
```

Ensure `disabled()` returns the loaded manifest value, not a hard-coded fallback.

- [ ] **Step 5: Update `MerceColorsStatus` API**

Expose:

```cpp
Q_PROPERTY(QColor success READ success NOTIFY changed FINAL)
Q_PROPERTY(QColor successSubtle READ successSubtle NOTIFY changed FINAL)
Q_PROPERTY(QColor warning READ warning NOTIFY changed FINAL)
Q_PROPERTY(QColor warningSubtle READ warningSubtle NOTIFY changed FINAL)
Q_PROPERTY(QColor error READ error NOTIFY changed FINAL)
Q_PROPERTY(QColor errorSubtle READ errorSubtle NOTIFY changed FINAL)
Q_PROPERTY(QColor info READ info NOTIFY changed FINAL)
Q_PROPERTY(QColor infoSubtle READ infoSubtle NOTIFY changed FINAL)
```

Ensure subtle values come from the manifest.

- [ ] **Step 6: Update `applyManifestSection(...)` to read nested colors**

The root apply method should read nested objects:

```cpp
void applyManifestSection(const QJsonObject &section)
{
    const QJsonObject text = section.value(QStringLiteral("text")).toObject();
    const QJsonObject background = section.value(QStringLiteral("background")).toObject();
    const QJsonObject border = section.value(QStringLiteral("border")).toObject();
    const QJsonObject action = section.value(QStringLiteral("action")).toObject();
    const QJsonObject status = section.value(QStringLiteral("status")).toObject();
    const QJsonObject surface = section.value(QStringLiteral("surface")).toObject();

    m_text->applyValues(
        color(text, QStringLiteral("primary")),
        color(text, QStringLiteral("secondary")),
        color(text, QStringLiteral("tertiary")),
        color(text, QStringLiteral("inverse")),
        color(text, QStringLiteral("disabled")),
        color(text, QStringLiteral("link")),
        color(text, QStringLiteral("linkHover")));

    m_background->applyValues(
        color(background, QStringLiteral("base")),
        color(background, QStringLiteral("surface")),
        color(background, QStringLiteral("elevated")),
        color(background, QStringLiteral("hover")),
        color(background, QStringLiteral("pressed")),
        color(background, QStringLiteral("tinted")),
        color(background, QStringLiteral("overlay")));

    m_border->applyValues(
        color(border, QStringLiteral("base")),
        color(border, QStringLiteral("strong")),
        color(border, QStringLiteral("focus")),
        color(border, QStringLiteral("error")),
        color(border, QStringLiteral("success")));

    m_action->applyValues(
        color(action, QStringLiteral("primary")),
        color(action, QStringLiteral("primaryHover")),
        color(action, QStringLiteral("primaryPressed")),
        color(action, QStringLiteral("primarySubtle")),
        color(action, QStringLiteral("secondary")),
        color(action, QStringLiteral("secondaryHover")),
        color(action, QStringLiteral("secondaryPressed")),
        color(action, QStringLiteral("disabled")));

    m_status->applyValues(
        color(status, QStringLiteral("success")),
        color(status, QStringLiteral("successSubtle")),
        color(status, QStringLiteral("warning")),
        color(status, QStringLiteral("warningSubtle")),
        color(status, QStringLiteral("error")),
        color(status, QStringLiteral("errorSubtle")),
        color(status, QStringLiteral("info")),
        color(status, QStringLiteral("infoSubtle")));

    m_surface->applyValues(
        color(surface, QStringLiteral("base")),
        color(surface, QStringLiteral("tinted")),
        color(surface, QStringLiteral("raised")));

    emit changed();
}
```

- [ ] **Step 7: Update `MerceTheme.h`**

Replace:

```cpp
#include "MercePalette.h"
Q_PROPERTY(MercePalette *palette READ palette CONSTANT FINAL)
Q_PROPERTY(MercePalette *colors READ colors CONSTANT FINAL)
MercePalette *palette() const { return m_palette; }
MercePalette *colors() const { return m_palette; }
void paletteChanged();
MercePalette *m_palette = nullptr;
```

with:

```cpp
#include "MerceColors.h"
Q_PROPERTY(MerceColors *colors READ colors CONSTANT FINAL)
MerceColors *colors() const { return m_colors; }
void colorsChanged();
MerceColors *m_colors = nullptr;
```

Do not keep a `palette` property or accessor.

- [ ] **Step 8: Update `MerceTheme.cpp`**

Replace construction and apply calls:

```cpp
m_colors(new MerceColors(this))
```

and:

```cpp
m_colors->applyManifestSection(manifest.value(QStringLiteral("colors")).toObject());
```

- [ ] **Step 9: Build to expose remaining compile errors**

Run:

```bash
cmake --build build --target MerceCore
```

Expected: initial compile failures may point to includes/tests still using `MercePalette` or `palette`.

- [ ] **Step 10: Commit C++ runtime color object rename**

```bash
git add Core/Theme Core/CMakeLists.txt
git commit -m "refactor(theme)!: replace palette with semantic colors"
```

---

### Task 4: Update Manifest Loader Validation For Nested Colors

**Files:**
- Modify: `Core/Theme/MerceThemeManifestLoader.cpp`

- [ ] **Step 1: Replace supported section name**

In `supportedSections()`, replace:

```cpp
QStringLiteral("palette"),
```

with:

```cpp
QStringLiteral("colors"),
```

- [ ] **Step 2: Replace flat palette fields with nested color field map**

Replace `paletteFields()` with:

```cpp
QHash<QString, QStringList> colorFields()
{
    return {
        { QStringLiteral("text"), {
            QStringLiteral("primary"),
            QStringLiteral("secondary"),
            QStringLiteral("tertiary"),
            QStringLiteral("inverse"),
            QStringLiteral("disabled"),
            QStringLiteral("link"),
            QStringLiteral("linkHover"),
        } },
        { QStringLiteral("background"), {
            QStringLiteral("base"),
            QStringLiteral("surface"),
            QStringLiteral("elevated"),
            QStringLiteral("hover"),
            QStringLiteral("pressed"),
            QStringLiteral("tinted"),
            QStringLiteral("overlay"),
        } },
        { QStringLiteral("border"), {
            QStringLiteral("base"),
            QStringLiteral("strong"),
            QStringLiteral("focus"),
            QStringLiteral("error"),
            QStringLiteral("success"),
        } },
        { QStringLiteral("action"), {
            QStringLiteral("primary"),
            QStringLiteral("primaryHover"),
            QStringLiteral("primaryPressed"),
            QStringLiteral("primarySubtle"),
            QStringLiteral("secondary"),
            QStringLiteral("secondaryHover"),
            QStringLiteral("secondaryPressed"),
            QStringLiteral("disabled"),
        } },
        { QStringLiteral("status"), {
            QStringLiteral("success"),
            QStringLiteral("successSubtle"),
            QStringLiteral("warning"),
            QStringLiteral("warningSubtle"),
            QStringLiteral("error"),
            QStringLiteral("errorSubtle"),
            QStringLiteral("info"),
            QStringLiteral("infoSubtle"),
        } },
        { QStringLiteral("surface"), {
            QStringLiteral("base"),
            QStringLiteral("tinted"),
            QStringLiteral("raised"),
        } },
    };
}
```

Add `#include <QHash>` if needed.

- [ ] **Step 3: Update compatibility rejection**

Replace `validateNoCompatibilitySections(...)` with:

```cpp
QStringList validateNoCompatibilitySections(const QJsonObject &manifest)
{
    QStringList errors;
    if (manifest.contains(QStringLiteral("palette")))
        errors.append(QStringLiteral("manifest must not contain a top-level palette section"));
    if (manifest.contains(QStringLiteral("colors"))
        && manifest.value(QStringLiteral("colors")).toObject().contains(QStringLiteral("raw"))) {
        errors.append(QStringLiteral("runtime colors must not expose raw color scales"));
    }
    return errors;
}
```

- [ ] **Step 4: Add nested color validation**

Add:

```cpp
QStringList validateColorsSection(const QJsonObject &manifest)
{
    QStringList errors;
    const QJsonValue sectionValue = manifest.value(QStringLiteral("colors"));
    if (!sectionValue.isObject()) {
        errors.append(QStringLiteral("missing required field: colors"));
        return errors;
    }

    const QJsonObject colors = sectionValue.toObject();
    if (colors.contains(QStringLiteral("raw")))
        errors.append(QStringLiteral("runtime colors must not expose raw color scales"));

    const QHash<QString, QStringList> groups = colorFields();
    for (auto it = groups.cbegin(); it != groups.cend(); ++it) {
        const QString groupName = it.key();
        const QJsonValue groupValue = colors.value(groupName);
        if (!groupValue.isObject()) {
            errors.append(QStringLiteral("missing required runtime field: colors.%1").arg(groupName));
            continue;
        }

        const QJsonObject group = groupValue.toObject();
        for (const QString &field : it.value())
            requireColor(group, QStringLiteral("colors.%1").arg(groupName), field, &errors);
    }

    return errors;
}
```

Change `requireColor(...)` signature to:

```cpp
void requireColor(const QJsonObject &object, const QString &section, const QString &field, QStringList *errors)
{
    const QJsonValue value = object.value(field);
    if (!value.isString() || !QColor(value.toString()).isValid()) {
        errors->append(QStringLiteral("runtime field %1.%2 must be a valid color string").arg(section, field));
    }
}
```

- [ ] **Step 5: Update `validateSection(...)`**

At the top of `validateSection(...)`, add:

```cpp
if (section == QStringLiteral("colors"))
    return validateColorsSection(manifest);
```

Remove the old `section == "palette"` branch.

- [ ] **Step 6: Run manifest tests**

Run:

```bash
cmake --build build --target tst_merce_theme_manifest_loader
ctest --test-dir build --output-on-failure -R tst_merce_theme_manifest_loader
```

Expected: `tst_merce_theme_manifest_loader` passes.

- [ ] **Step 7: Commit loader validation**

```bash
git add Core/Theme/MerceThemeManifestLoader.cpp tests/Core/tst_merce_theme_manifest_loader.cpp
git commit -m "refactor(theme)!: validate nested colors manifests"
```

---

### Task 5: Update QML Consumers To `Theme.colors`

**Files:**
- Modify: `Foundation/*.qml`
- Modify: `Controls/*.qml`
- Modify: `Icons/**/*.qml`
- Modify: `playground/**/*.qml`

- [ ] **Step 1: Replace old palette and flat color usages**

Run:

```bash
rg -n "Theme\\.palette|Theme\\.colors\\.[A-Z_a-z0-9]+\\b" Foundation Controls Icons playground --glob '*.qml'
```

Use this mapping:

- `Theme.palette.textPrimary` -> `Theme.colors.text.primary`
- `Theme.palette.text.secondary` -> `Theme.colors.text.secondary`
- `Theme.palette.text.tertiary` -> `Theme.colors.text.tertiary`
- `Theme.palette.text.inverse` -> `Theme.colors.text.inverse`
- `Theme.palette.backgroundBase` -> `Theme.colors.background.base`
- `Theme.palette.backgroundSurface` -> `Theme.colors.background.surface`
- `Theme.palette.background.base` -> `Theme.colors.background.base`
- `Theme.palette.background.hover` -> `Theme.colors.background.hover`
- `Theme.palette.background.elevated` -> `Theme.colors.background.elevated`
- `Theme.palette.borderBase` -> `Theme.colors.border.base`
- `Theme.palette.border.focus` -> `Theme.colors.border.focus`
- `Theme.palette.actionPrimary` -> `Theme.colors.action.primary`
- `Theme.palette.action.primaryDark` -> `Theme.colors.action.primaryPressed`
- `Theme.palette.action.light("primary")` -> `Theme.colors.action.primarySubtle`
- `Theme.palette.actionSecondary` -> `Theme.colors.action.secondary`
- `Theme.palette.statusError` -> `Theme.colors.status.error`
- `Theme.palette.status.success` -> `Theme.colors.status.success`
- `Theme.palette.status.warning` -> `Theme.colors.status.warning`
- `Theme.palette.status.error` -> `Theme.colors.status.error`
- `Theme.palette.status.info` -> `Theme.colors.status.info`
- `Theme.colors.text.primary` stays unchanged.
- `Theme.colors.background.surface` stays unchanged.
- `Theme.colors.action.primary` stays unchanged.

- [ ] **Step 2: Remove raw runtime usages**

Replace the two known raw usages in `playground/view/TypographyShowcase.qml`:

```qml
readonly property color darkPreviewTextColor: Theme.palette.raw.gray50
```

with:

```qml
readonly property color darkPreviewTextColor: Theme.colors.text.inverse
```

Replace:

```qml
color: dark ? Theme.palette.raw.secondaryDark : Theme.palette.backgroundSurface
border.color: dark ? Theme.palette.raw.secondaryLight : root.dividerColor
```

with:

```qml
color: dark ? Theme.colors.background.elevated : Theme.colors.background.surface
border.color: dark ? Theme.colors.border.strong : root.dividerColor
```

- [ ] **Step 3: Verify no forbidden public API remains**

Run:

```bash
rg -n "Theme\\.palette|Theme\\.colors\\.raw|Theme\\.colors\\.textPrimary|Theme\\.colors\\.backgroundBase|Theme\\.colors\\.actionPrimary|Theme\\.colors\\.borderBase|Theme\\.colors\\.statusError" Foundation Controls Icons playground tests Core --glob '!build/**'
```

Expected: no output.

- [ ] **Step 4: Build playground**

Run:

```bash
cmake --build build --target MercePlayground
```

Expected: build succeeds.

- [ ] **Step 5: Commit QML consumer migration**

```bash
git add Foundation Controls Icons playground
git commit -m "refactor(qml)!: consume semantic Theme.colors"
```

---

### Task 6: Update Runtime Switch Tests And Probes

**Files:**
- Modify: `tests/Core/tst_merce_theme_runtime_switch.cpp`
- Modify: `playground/probe/ThemeProbe.qml`
- Modify: `playground/probe/ThemeSwitchProbe.qml`
- Modify: `playground/probe/ThemeGalleryProbe.qml`
- Modify: `playground/probe/PlaygroundProbe.qml` if it references old labels.

- [ ] **Step 1: Update runtime switch pointers**

In `tests/Core/tst_merce_theme_runtime_switch.cpp`, replace all `MercePalette *palette` pointer checks with `MerceColors *colors`. The pointer section should look like:

```cpp
MerceTheme theme;
MerceColors *colors = theme.colors();
MerceSpacing *spacing = theme.spacing();
MerceRadius *radius = theme.radius();
MerceTypography *typography = theme.typography();
```

Remove any call to `theme.palette()`.

- [ ] **Step 2: Update runtime color value assertions**

Use nested colors:

```cpp
QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#FAF8F6")));
QCOMPARE(theme.colors()->action()->primary(), QColor(QStringLiteral("#C4785A")));
```

For all reference theme assertions, replace:

```cpp
theme.palette()->backgroundBase()
theme.palette()->actionPrimary()
```

with:

```cpp
theme.colors()->background()->base()
theme.colors()->action()->primary()
```

- [ ] **Step 3: Update meta-object contract assertions**

In `metaObjectContractKeepsStablePointersAndValueNotifySignals()`, assert:

```cpp
QCOMPARE(themeMetaObject->indexOfProperty("palette"), -1);
QVERIFY(propertyByName(themeMetaObject, "colors").isConstant());
```

Do not assert `palette` compatibility.

- [ ] **Step 4: Update QML probes**

Use these replacements:

- `Theme.palette.backgroundBase` -> `Theme.colors.background.base`
- `Theme.palette.textPrimary` -> `Theme.colors.text.primary`
- `Theme.palette.actionPrimary` -> `Theme.colors.action.primary`
- `Theme.palette.borderBase` -> `Theme.colors.border.base`
- `Theme.palette.status.success` -> `Theme.colors.status.success`
- `Theme.palette.backgroundSurface` -> `Theme.colors.background.surface`

- [ ] **Step 5: Run runtime tests and probes**

Run:

```bash
cmake --build build --target tst_merce_theme_runtime_switch MercePlayground
ctest --test-dir build --output-on-failure -R tst_merce_theme_runtime_switch
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-probe
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-switch-probe
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-gallery-probe
```

Expected: all pass.

- [ ] **Step 6: Commit tests and probes**

```bash
git add tests/Core playground/probe
git commit -m "test(theme): verify colors-only runtime contract"
```

---

### Task 7: Update Playground Labels And Documentation

**Files:**
- Modify: `playground/view/PaletteShowcase.qml`
- Modify: `playground/view/ThemeGallery.qml`
- Modify: `docs/theme-gallery.md`
- Modify: `tools/design-tokens/README.md`
- Modify: `tools/design-tokens/prompts/design-md-to-dtcg.md`
- Modify: `skills/merce-design-md-to-dtcg/SKILL.md`
- Modify: `skills/merce-design-md-to-dtcg/references/merce-theme-contract.md`
- Modify: `docs/superpowers/specs/2026-06-05-runtime-theme-sources-design.md`

- [ ] **Step 1: Rename playground page wording**

In `playground/view/PaletteShowcase.qml`, keep the file name for now if route wiring depends on it, but update display text from `Palette` to `Colors` and labels from flat names to semantic names:

```qml
ColorTile { label: "colors.background.base"; swatchColor: Theme.colors.background.base }
ColorTile { label: "colors.background.surface"; swatchColor: Theme.colors.background.surface }
ColorTile { label: "colors.text.primary"; swatchColor: Theme.colors.text.primary }
ColorTile { label: "colors.action.primary"; swatchColor: Theme.colors.action.primary }
ColorTile { label: "colors.border.base"; swatchColor: Theme.colors.border.base }
ColorTile { label: "colors.status.error"; swatchColor: Theme.colors.status.error }
```

- [ ] **Step 2: Update theme gallery token labels**

In `playground/view/ThemeGallery.qml`, replace labels like:

```qml
TokenSwatch { label: "backgroundBase"; swatchColor: Theme.palette.backgroundBase }
```

with:

```qml
TokenSwatch { label: "colors.background.base"; swatchColor: Theme.colors.background.base }
```

- [ ] **Step 3: Update token docs**

In `tools/design-tokens/README.md`, update the manifest shape list to:

```markdown
- `colors`
- `spacing`
- `radius`
- `typography`
```

Add:

```markdown
Raw color scales remain source-only under `color.palette.*`. QML consumers use semantic runtime roles under `Theme.colors.*`; generated manifests must not expose `colors.raw`.
```

- [ ] **Step 4: Update skill docs**

In `skills/merce-design-md-to-dtcg/references/merce-theme-contract.md`, replace mapping examples from `palette.semantic.*` to `color.*` semantic paths. Example:

```markdown
- Main text -> `color.text.primary`
- Page canvas -> `color.background.base`
- Card/surface -> `color.background.surface`, `color.surface.base`
- Brand accent -> `color.palette.primary`, `color.action.primary`, `color.text.link`, `color.border.focus`
```

- [ ] **Step 5: Run doc/source scans**

Run:

```bash
rg -n "Theme\\.palette|palette semantic|palette\\.semantic|palette\\.raw|generated manifests.*palette|`palette`" docs skills tools/design-tokens playground --glob '!tools/design-tokens/node_modules/**'
```

Expected: matches are either historical notes in old planning files or source-token examples explicitly explaining old-to-new migration. There should be no current instruction telling new work to use `Theme.palette`.

- [ ] **Step 6: Commit docs and labels**

```bash
git add docs skills tools/design-tokens playground/view/PaletteShowcase.qml playground/view/ThemeGallery.qml
git commit -m "docs(theme): document semantic colors taxonomy"
```

---

### Task 8: Final Verification

**Files:**
- No new files unless verification uncovers issues.

- [ ] **Step 1: Run token pipeline**

```bash
cd tools/design-tokens
npm run build
npm run validate
npm run check
```

Expected: all pass.

- [ ] **Step 2: Build core tests and playground**

```bash
cmake --build build --target MerceCore tst_merce_theme_manifest_loader tst_merce_theme_runtime_switch MercePlayground
```

Expected: build succeeds.

- [ ] **Step 3: Run Qt tests**

```bash
ctest --test-dir build --output-on-failure -R 'tst_merce_theme_(manifest_loader|runtime_switch)'
```

Expected: both tests pass.

- [ ] **Step 4: Run offscreen playground probes**

```bash
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-probe
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-switch-probe
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --playground-probe
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --smoke-test
QT_QPA_PLATFORM=offscreen build/playground/MercePlayground --theme-gallery-probe
```

Expected: all probes pass. Existing non-blocking font alias warnings are acceptable only if probes pass.

- [ ] **Step 5: Run forbidden API scan**

```bash
rg -n "Theme\\.palette|Q_PROPERTY\\(MerceColors \\*palette|MercePalette|\\\"palette\\\"|colors\\.raw" Core Foundation Controls Icons playground tests tools/design-tokens generated/themes docs skills --glob '!tools/design-tokens/node_modules/**'
```

Expected:

- No `Theme.palette`.
- No `MercePalette`.
- No generated runtime top-level `"palette"`.
- No public `colors.raw`.
- Source-token docs may mention `color.palette.*` as source-only raw scale.

- [ ] **Step 6: Commit final verification fixes**

If verification required fixes:

```bash
git add <fixed-files>
git commit -m "fix(theme): complete colors canonicalization"
```

If no fixes were needed, do not create an empty commit.

---

## Self-Review

**Spec coverage:** This plan covers the approved semantic colors decision, removes `Theme.palette`, removes raw runtime colors, migrates source token naming toward `color.*`, updates generated manifests to `colors`, updates runtime C++/QML consumers, and verifies through Qt tests plus offscreen probes.

**Intentional deferrals:** This plan does not implement external theme source loading, runtime font asset loading, `Theme.availableThemes` dynamic reload, `elevation` rename, `sizing` extraction, or Font Awesome/provider changes. Those belong in the next implementation plan after colors are canonical.

**No compatibility:** The plan deliberately removes `Theme.palette` and top-level runtime `palette`. Existing app code must migrate to `Theme.colors.*`.
