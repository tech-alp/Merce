# Runtime Theme Sources Design

Date: 2026-06-05
Status: Draft for review

## Context

Merce currently ships a built-in theme registry from `:/merce/themes/index.json`.
`Merce.Core.Theme` exposes the stable runtime contract for QML consumers:
palette, spacing, radius, typography, iconography, active theme state, and
available themes.

The current registry and manifest loader support built-in JSON manifests only.
Typography values can name font families, but runtime theme packs cannot yet
provide the font files required by those families. `FoundationFonts.qml` loads
Merce's built-in fallback fonts and Material Symbols, so an external theme can
request a family name that is not actually available to Qt.

TVM needs to select site/customer themes at runtime without compiling a separate
application build for every site. The selected theme can be persisted by the
application. Merce should provide the runtime loading and validation boundary,
not marketplace, download, or installation logic.

## Goals

- Keep the built-in Merce registry as the always-available fallback source.
- Allow applications to add local filesystem theme registries at runtime.
- Allow theme packs to provide required typography font assets.
- Preserve the current active theme when reload, lookup, manifest validation, or
  required font loading fails.
- Make `Theme.availableThemes` dynamic so QML can react after registry reload.
- Keep Material Symbols as the built-in icon provider for Merce controls.
- Keep Font Awesome as an optional SVG icon module, not as a required theme
  dependency.

## Non-Goals

- No marketplace client in Merce Core.
- No theme download, install, signature verification, or update policy in Merce.
- No remote font URLs.
- No automatic filesystem watcher in the first implementation.
- No runtime icon pack marketplace.
- No hard dependency on Font Awesome for applications that only use Material
  Symbols.
- No guarantee that fonts can be fully unloaded from a running process.

## Public Runtime API

The `Theme` singleton remains the public QML entry point.

```qml
Theme.addThemeSource("/var/lib/tvm/themes/index.json")
Theme.clearThemeSources()
Theme.reloadThemes()
Theme.setTheme("customer-a", "dark")
```

Properties:

- `availableThemes`: dynamic `QVariantList` with a NOTIFY signal.
- `activeBrand`: unchanged.
- `activeMode`: unchanged.

Behavior:

- Built-in `:/merce/themes/index.json` is always loaded first.
- Application-provided sources are added after the built-in source.
- `clearThemeSources()` removes only application-provided sources; it never
  removes the built-in registry.
- `addThemeSource(...)` records a local source path; `reloadThemes()` performs
  the actual registry validation and publication.
- Initial implementation rejects duplicate theme ids across sources.
- `reloadThemes()` validates all registered sources and publishes the new
  available theme list only after the merged registry is valid.
- Failed reload keeps the previous registry and active theme.
- Failed `setTheme()` keeps the current active theme.
- Applications own selected-theme persistence and call `Theme.setTheme(...)` on
  startup.
- Applications may call `reloadThemes()` after installing or replacing a theme
  pack. Automatic change detection can be layered later by application code or a
  separate watcher.

## Theme Source Model

An external source is a local `index.json` with the same registry shape as the
built-in registry. Paths remain relative to the registry file.

Example:

```json
{
  "schemaVersion": 1,
  "defaultTheme": "customer-a",
  "themes": {
    "customer-a": {
      "displayName": "Customer A",
      "basePath": "customer-a.base.json",
      "defaultVariant": "light",
      "variants": {
        "light": "customer-a.light.json",
        "dark": "customer-a.dark.json"
      }
    }
  }
}
```

Path safety rules:

- No absolute paths.
- No `../` or `..\\`.
- No Qt resource paths for external sources.
- Manifest file names stay within the theme source directory.

## DTCG Source Taxonomy Decision

DTCG standardizes the token interchange format, not Merce's public runtime API.
The standard defines reserved properties such as `$value`, `$type`,
`$description`, `$extensions`, group/reference behavior, and token value types.
It does not require top-level names such as `palette`, `typography`, `spacing`,
or `radius`.

Important consequence:

- `palette`, `spacing`, `radius`, and `typography` are Merce runtime manifest
  sections.
- Source token groups are allowed to use those names, but they are not a DTCG
  naming standard.
- Tools must not infer a token's type from its group name. Every token must have
  an explicit `$type`, inherit `$type` from a parent group, or resolve it through
  a typed alias.
- Generated runtime manifests should remain a Merce-specific output format.
  Source DTCG paths must not become public QML API.

Current state:

- The existing token workspace uses DTCG-style `$value` / `$type` metadata.
- It intentionally generates Qt-friendly runtime manifests with simple color
  strings and numeric dimensions.
- It is not yet strict DTCG 2025.10 source, because strict 2025.10 represents
  colors as color objects, dimensions as `{ "value": number, "unit": "px" |
  "rem" }`, and font stacks as `fontFamily` arrays instead of comma-separated
  strings.

Recommended long-term source taxonomy:

- Use type-first, semantic groups in source tokens where possible:
  - `color.palette.*` for raw/base colors.
  - `color.text.*`, `color.background.*`, `color.border.*`, `color.action.*`,
    `color.status.*` for semantic color aliases.
  - `space.*` or `spacing.*` for spacing dimensions.
  - `radius.*` for radius dimensions.
  - `font.family.*`, `font.weight.*`, `font.size.*` for typography primitives.
  - `lineHeight.*` and `letterSpacing.*` for unitless/spacing typography
    values.
  - Optional `typeStyle.*` composite `typography` tokens for complete text
    styles if Merce later wants role-level typography tokens.
- Keep the generated Merce runtime manifest mapped to the existing
  `palette.*`, `spacing.*`, `radius.*`, and `typography.*` sections until a
  deliberate runtime contract migration is planned.
- Before adding many external themes, add a token-taxonomy stabilization pass so
  the source shape does not become expensive to migrate later.

Recommended public QML color surface:

- Prefer `Theme.colors` over `Theme.palette` for the public runtime API.
- Do not expose raw color scales such as `gray50`, `brand500`, `neutral100`, or
  `slate900` as stable public QML API. Raw scales differ too much between design
  systems.
- Keep raw/base color scales in source tokens and mapping/debug surfaces only.
- QML components should consume semantic color roles:
  - `Theme.colors.text.primary`
  - `Theme.colors.text.secondary`
  - `Theme.colors.text.tertiary`
  - `Theme.colors.text.inverse`
  - `Theme.colors.text.disabled`
  - `Theme.colors.text.link`
  - `Theme.colors.background.base`
  - `Theme.colors.background.surface`
  - `Theme.colors.background.elevated`
  - `Theme.colors.background.hover`
  - `Theme.colors.background.pressed`
  - `Theme.colors.background.tinted`
  - `Theme.colors.border.base`
  - `Theme.colors.border.strong`
  - `Theme.colors.border.focus`
  - `Theme.colors.border.error`
  - `Theme.colors.border.success`
  - `Theme.colors.action.primary`
  - `Theme.colors.action.primaryHover`
  - `Theme.colors.action.primaryPressed`
  - `Theme.colors.action.secondary`
  - `Theme.colors.action.disabled`
  - `Theme.colors.status.success`
  - `Theme.colors.status.warning`
  - `Theme.colors.status.error`
  - `Theme.colors.status.info`

With no compatibility requirement, the implementation should remove
`Theme.palette` instead of keeping it as an alias.

Font asset metadata is not a DTCG token value. DTCG 2025.10 lists asset/file
tokens only as a possible future area, not a normative type. Therefore Merce
should keep runtime font asset declarations as Merce-specific metadata that is
generated into the runtime manifest `fonts` section. If source tokens need to
carry hints, use them only as optional metadata and keep the required runtime
asset declaration explicit.

## Font Asset Model

Theme manifests may declare typography font assets.

Example:

```json
{
  "schemaVersion": 1,
  "theme": "customer-a",
  "variant": "light",
  "fonts": [
    {
      "family": "MyBrand Sans",
      "source": "fonts/MyBrandSans-Regular.ttf",
      "weight": 400,
      "style": "normal",
      "required": true
    },
    {
      "family": "MyBrand Sans",
      "source": "fonts/MyBrandSans-Bold.ttf",
      "weight": 700,
      "style": "normal",
      "required": true
    }
  ],
  "typography": {
    "displayFont": "MyBrand Sans",
    "bodyFont": "MyBrand Sans",
    "monoFont": "Roboto Mono",
    "displayFontFallback": "Inter",
    "bodyFontFallback": "Inter"
  }
}
```

Rules:

- `fonts` is optional.
- `fonts` is a top-level manifest section and participates in base/variant
  merge. Base theme fonts are inherited by variants unless the variant replaces
  the `fonts` section.
- `source` is relative to the manifest file directory.
- First implementation supports `.ttf` and `.otf`.
- `required: true` means theme application fails if the font cannot be loaded.
- Failed required font loading preserves the current active theme.
- Optional font loading failures are logged and the typography fallback remains
  available.
- Loaded application fonts may remain loaded for the process lifetime.

Implementation boundary:

- Font loading should live in C++ using `QFontDatabase::addApplicationFont()`.
- Foundation keeps built-in fallback font loading.
- A small runtime font registry should map requested family names to loaded Qt
  family names when needed.
- `FoundationFonts.resolveFamily(...)` should remain the QML fallback resolver,
  but it should not be the only place that knows about runtime theme fonts.

## Icon Provider Boundary

Typography fonts and icon providers are separate concerns.

Built-in:

- Material Symbols remains part of Foundation because Merce controls need a
  small always-available UI icon set.

Optional:

- Font Awesome remains under `Merce.Icons.FontAwesome`.
- Font Awesome SVG data is not loaded by `Merce.Core.Theme`.
- Applications that do not import or link `Merce.Icons.FontAwesome` should not
  depend on Font Awesome assets.

Playground:

- Playground lists the icon providers that are available to the playground
  target.
- Playground may show Material Symbols and Font Awesome together, but it should
  not own production icon or font loading behavior.

## Failure Semantics

Runtime theme loading should be transactional:

1. Load and validate the registry.
2. Resolve manifest paths.
3. Load and merge base/variant manifests.
4. Validate runtime token sections.
5. Load required fonts.
6. Apply token sections and active theme state.
7. Emit change notifications.

If any required step fails before step 6, the current live theme remains
unchanged.

## Expected Tests

- Built-in registry still loads by default.
- `availableThemes` updates after adding a valid external source and reloading.
- Invalid external registry does not replace the existing registry.
- Duplicate external theme id is rejected.
- External manifest path traversal is rejected.
- Required missing font rejects theme application.
- Optional missing font logs but does not reject theme application.
- External `.ttf` or `.otf` font can be loaded and used by typography tokens.
- Font Awesome remains optional for a consumer that imports only `Merce.Core`,
  `Merce.Foundation`, and `Merce.Controls`.
- Playground icon page continues to show built-in Material Symbols and optional
  Font Awesome providers when linked.

## Open Decisions

- Whether to expose font load diagnostics in QML or keep them as logs only.
- Whether to add checksums to theme font declarations now or leave integrity to
  the application marketplace layer.
- Whether future icon packs should use a theme manifest section or a separate
  icon-provider registration API.
