# Merce Design Tokens

This workspace resolves reviewed DTCG-shaped sources into the committed AlGit
runtime documents. It uses Node built-ins only; the device never runs Node.

## Contract

`themes.json` composes two independent registries:

- `brands`: colour documents keyed by `brandId` and `mode`
- `profiles`: spacing, radius, typography, and sizing documents keyed by
  `profileId`

`generated/themes/index.json` declares `defaultBrand`, `brands`,
`defaultProfile`, and `profiles`. Profile paths are safe filenames resolved
against the sibling `generated/profiles/` directory.

Colour manifests contain only:

- `kind: "resolved-theme"`
- `resolvedThemeSchemaVersion: 1`
- `brandId`
- `mode`
- `identity`
- `colors`
- `state` opacity roles for custom QML items

Profile manifests contain `profileSchemaVersion: 1`, `profileId`, and the
runtime metric sections. Brand colour and profile metrics are never one
three-part registry key.

The original exploration sources under `tokens/themes/` remain as seed-corpus
fixtures. Small `resolved.json` overlays preserve their seed identity while the
generated documents use the corrected semantic role vocabulary. Entries marked
`runtime: false` are generated and validated as fixtures but omitted from the
runtime `brands` registry.

## Commands

Run from `tools/design-tokens`:

```bash
npm run build
npm run validate
npm run check
```

`npm run build` writes the theme index, all registered resolved themes, and all
registered profiles.

`npm run validate` validates both registries, exact schema versions, safe
filenames, document identity, and the complete runtime field sets.

`npm run check` rebuilds only the in-scope theme/profile artifacts and fails if
committed JSON is stale. Figma, CSS, and Tailwind generation are outside this
work item.
