# Merce Theme Contract Reference

## Files To Inspect

- `tools/design-tokens/src/merce-manifest-format.mjs`: runtime field map. Generated manifests must satisfy this map.
- `tools/design-tokens/src/validate-manifest.mjs`: validator behavior and rejected shapes.
- `tools/design-tokens/tokens/core/*.json`: default values inherited by every theme.
- `Core/CMakeLists.txt`: Qt resource packaging for `generated/themes`.
- `tests/Core/tst_merce_theme_runtime_switch.cpp`: runtime switch coverage.

## Source Token Shape

Use DTCG keys:

```json
{
  "color": {
    "palette": {
      "primary": { "$type": "color", "$value": "#FF385C" }
    },
    "action": {
      "primary": { "$type": "color", "$value": "{color.palette.primary}" }
    }
  },
  "radius": {
    "button": { "$type": "dimension", "$value": "{radius.medium}" }
  }
}
```

Theme sources may override only the values that differ from core. Still, for reference themes, prefer explicit overrides for visually important palette, spacing, radius, and typography fields so generated output is reviewable.

## DTCG Naming And Taxonomy

DTCG standardizes JSON token structure, reserved `$...` properties, token types,
references, groups, and extensions. It does not standardize Merce's top-level
group names.

Rules to preserve:

- Token and group names must not begin with `$`.
- Token and group names must not contain `{`, `}`, or `.`.
- Token names are case-sensitive, but avoid names that differ only by case
  because generated outputs can collide.
- Groups are arbitrary organization containers. Do not infer token type from a
  group name such as `color`, `palette`, or `typography`.
- Every token must have an explicit `$type`, inherit `$type` from a parent group,
  or resolve its type through a typed alias.
- Source token paths are internal build input. Generated runtime sections remain
  the public Merce contract.
- Raw/base color scales belong to source tokens and mapping/debug surfaces.
  Public QML components must consume semantic roles such as
  `Theme.colors.text.primary`, not raw source paths such as `color.palette.gray50`.

Current Merce sources use DTCG-style `$value` / `$type` metadata and generate
Qt-friendly runtime manifests. They are not strict DTCG 2025.10 source yet:

- Strict color tokens use color objects with `colorSpace`, `components`, and
  optional `alpha` / `hex`; current sources mostly use hex strings.
- Strict dimension tokens use `{ "value": number, "unit": "px" | "rem" }`;
  current sources mostly use bare numbers.
- Strict `fontFamily` stacks should be arrays of family names; Merce runtime
  currently accepts only one Qt-loadable family name per generated font field.

When adding a small reference theme, follow the current Merce source taxonomy
unless the task is explicitly a token-taxonomy migration. When planning a
long-lived external-theme workflow, prefer a stabilization pass toward:

- `color.palette.*` for raw/base colors.
- `color.text.*`, `color.background.*`, `color.border.*`, `color.action.*`,
  `color.status.*` for semantic color aliases.
- `spacing.*` or `space.*` for spacing dimensions.
- `radius.*` for radius dimensions.
- `font.family.*`, `font.weight.*`, `font.size.*` for typography primitives.
- `lineHeight.*` and `letterSpacing.*` for type metrics.
- Optional `typeStyle.*` composite typography tokens for complete text styles.

The generated runtime manifest emits Merce's current `colors`, `spacing`,
`radius`, and `typography` sections after source normalization. Keep only
semantic color roles public.

## Runtime Fields

The generated manifest currently emits these sections only:

- `colors`
- `spacing`
- `radius`
- `typography`

Do not emit raw DTCG keys, unresolved `{token.references}`, components, shadows, motion, iconography, z-index, or breakpoints into runtime manifests unless the runtime field map has been extended first.

## DESIGN.md Mapping

Map from DESIGN.md frontmatter or prose into Merce fields:

- Brand accent -> `color.palette.primary`, `color.action.primary`, `color.text.link`, `color.border.focus`
- Primary active/hover -> `color.action.primaryPressed`, `color.action.primaryHover`
- Light or on-dark accent -> `color.action.primarySubtle` or `color.text.linkHover`
- Main text -> `color.text.primary`
- Secondary text -> `color.text.secondary`
- Muted text -> `color.text.tertiary` or `color.text.disabled`
- Page canvas -> `color.background.base`
- Card/surface -> `color.background.surface`, `color.surface.base`
- Soft band/hover -> `color.background.hover`, `color.surface.tinted`
- Border/hairline -> `color.border.base`, `color.border.strong`
- Status tokens -> `color.status.error`, `color.status.success`, `color.status.warning`, `color.status.info` when present; otherwise core defaults are acceptable.
- Button/input/card radius -> `radius.button`, `radius.input`, `radius.card`
- Section spacing -> `spacing.sectionGap`
- Page/content padding -> `spacing.pagePadding`
- Touch target -> `spacing.touchTarget`
- Display/body/mono font families -> `typography.displayFont`, `bodyFont`, `monoFont`
- Font sizes -> Merce scale fields `sizeXSmall` through `size7XLarge`
- Font weights -> `weightRegular`, `weightMedium`, `weightSemibold`, `weightBold`
- Line-height/tracking -> `leading*` and `tracking*`

For proprietary fonts, do not add font files without an explicit licensing
decision. Runtime typography fields must still use a single Qt-loadable family
name, not a comma-separated CSS fallback stack.

If licensed runtime font files are provided, handle them as Merce font asset
metadata instead of generic DTCG typography tokens. A theme may need metadata
like:

```json
{
  "fonts": [
    {
      "family": "MyBrand Sans",
      "source": "fonts/MyBrandSans-Regular.ttf",
      "weight": 400,
      "style": "normal",
      "required": true
    }
  ]
}
```

The font family token and the runtime font asset declaration serve different
purposes:

- `typography.bodyFont` says which family the design wants.
- `fonts[*].source` says how Merce can load that family at runtime.

## Registry Patterns

Single reference theme:

```json
"airbnb": {
  "displayName": "Airbnb Reference",
  "source": ["tokens/themes/airbnb/theme.json"],
  "path": "airbnb.json"
}
```

Variant theme:

```json
"brand": {
  "displayName": "Brand",
  "source": ["tokens/themes/brand/theme.json"],
  "basePath": "brand.default.json",
  "defaultVariant": "light",
  "variants": {
    "light": "brand.light.json",
    "dark": "brand.dark.json"
  },
  "variantSources": {
    "light": ["tokens/themes/brand/variants/light.json"],
    "dark": ["tokens/themes/brand/variants/dark.json"]
  }
}
```

Avoid inventing a rigid variant matrix. Use sparse themes when the DESIGN.md source has one mode.

## Required Verification

Run:

```bash
cd tools/design-tokens
npm run build
npm run validate
npm run check
```

Then run at least:

```bash
cmake --build build --target MerceCore
QT_QPA_PLATFORM=offscreen build/tests/Core/tst_merce_theme_runtime_switch
```

If the developer uses a nested Qt Creator build directory, also build and run that equivalent target.

For new runtime-visible themes, add/adjust tests so `Theme.setTheme("<theme>")` verifies:

- `activeBrand`
- empty `activeMode` for single-manifest themes
- one brand-specific semantic color value
- one shape/spacing/typography value when useful
- stable `Theme` child object pointers
- `availableThemes` registry exposure

## Common Failures

`theme manifest ':/merce/themes/<theme>.json' could not be opened`

- The generated index lists the theme, but the current Qt resource binary does not contain the manifest.
- Rebuild/reconfigure `MerceCore`.
- Check `Core/.qt/rcc/merce_theme_manifests.qrc` in the active build dir.
- `Core/CMakeLists.txt` should depend on `generated/themes/index.json` and listed manifest files via `CMAKE_CONFIGURE_DEPENDS`.

Generated manifest sections are empty or wrong:

- Inspect actual Style Dictionary v5 token output.
- Use `token.path` or `token.key` and DTCG-aware `resolveReferences(..., { usesDtcg: true })`.
- Do not assume older Style Dictionary token metadata.

Validator rejects raw `$value` or unresolved source token data:

- You wrote or copied runtime manifest JSON instead of DTCG source.
- Move source tokens under `tools/design-tokens/tokens/themes/<theme>/theme.json` and regenerate.

`npm` network errors:

- Do not change runtime architecture to avoid Node.
- Use existing lockfile/dependencies if installed.
- If install/download is required, request escalation rather than silently skipping validation.
