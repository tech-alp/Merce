# Merce Design Tokens

This workspace converts reviewed DTCG token sources into Merce runtime manifest JSON files. Merce runtime does not require Node or Style Dictionary.

The current source files use DTCG-style `$value` / `$type` metadata and are
processed by Style Dictionary. They are not yet strict DTCG 2025.10 source:
colors are authored as hex strings, dimensions are authored as bare numbers,
and generated font fields use one Qt-loadable family name instead of CSS font
stacks. The generated runtime manifests are intentionally Qt-friendly Merce
manifests, not public DTCG interchange files.

## Scope

- Source tokens live under `tools/design-tokens/tokens/`.
- Style Dictionary resolves core, theme, and variant layers in deterministic order.
- Generated manifests live under `generated/themes/` and are committed or packaged for Qt consumers.
- Figma import files live under `generated/figma/` and are generated from the same sources as a separate interchange output.
- Runtime QML and C++ APIs continue to use `Theme`; generated token objects are not public QML API.

## Theme Registry

`tools/design-tokens/themes.json` declares the sparse theme set. A single-manifest theme uses `path`. A variant theme uses `defaultVariant` and `variants`, and may also declare `basePath` for a resolved default manifest that loaders apply before the active variant.

`generated/themes/index.json` is authoritative for physical manifest paths; in short, index.json is authoritative. Phase 3 loaders should read paths from the index instead of deriving paths from theme or variant names.

## Reference Themes

`apple`, `claude`, `airbnb`, and `linear` are reference themes converted from public `DESIGN.md` files into reviewed DTCG source tokens. They intentionally map only into Merce runtime sections (`colors`, `spacing`, `radius`, and `typography`). Component-level guidance, imagery rules, shadows, and motion notes from the source `DESIGN.md` files are not emitted into runtime manifests.

Typography manifests must use one Qt-loadable family name per field. Proprietary font family names are not proof that files are licensed or packaged. Licensed runtime font files should be handled through Merce font asset metadata rather than generic typography tokens.

## Manifest Shape

Generated manifests use shallow semantic sections aligned with the C++ runtime:

- `schemaVersion`
- `theme`
- optional `variant`
- `colors`
- `spacing`
- `radius`
- `typography`

Generated manifests do not expose raw DTCG paths or compatibility sections from the old QML facade. Compatibility aliases should be derived inside the runtime layer when needed.

## Figma DTCG Export

`npm run build:figma` writes strict Figma-compatible DTCG JSON files under
`generated/figma/`. This output is intended for Figma Variables import and
exports only Merce's semantic public token surface:

- `color.text.*`
- `color.background.*`
- `color.border.*`
- `color.action.*`
- `color.status.*`
- `color.surface.*`
- `spacing.*`
- `radius.*`
- `typography.*`

The Figma output intentionally omits raw palette scales and Merce runtime
metadata. Variant-backed themes export one file per real variant; `basePath`
manifests are not exported as Figma modes. Single-manifest themes export one
file.

Generated Figma tokens include `com.figma.scopes` metadata so variables appear
only in relevant picker contexts where Figma honors scope extensions. Text colors
are scoped to text fills, background/surface colors to frame and shape fills,
border colors to strokes, spacing to gaps, radius to corner radius, and
typography fields to their matching text controls.

## Phase 3 Runtime Support

Phase 3 runtime apply validates and applies these manifest-backed sections:

- `colors`
- `spacing`
- `radius`
- `typography`

`motion`, `iconography`, `zIndex`, `breakpoints`, and `shadows` remain construction defaults in Phase 3. They are still typed runtime objects, but this phase does not expand the generated token taxonomy to make those sections manifest-backed.

## Commands

Run these commands from `tools/design-tokens`:

```bash
npm install
npm run build
npm run build:figma
npm run validate
npm run validate:figma
npm run check
```

`npm run build` writes `generated/themes/index.json` plus every manifest declared by `themes.json`.

`npm run build:figma` writes `generated/figma/index.json` plus Figma DTCG files
for every importable theme or variant.

`npm run validate` checks schema version, theme identity, required semantic sections, and required runtime fields.

`npm run validate:figma` checks the generated Figma DTCG files for supported
token types, Figma-compatible color/dimension values, safe names, and matching
token names/types across variant mode files.

`npm run check` rebuilds runtime manifests and Figma DTCG files, then fails if
the generated files differ from what is already present.
