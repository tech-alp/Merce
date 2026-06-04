# Merce Design Tokens

This workspace converts reviewed DTCG token sources into Merce runtime manifest JSON files. Merce runtime does not require Node or Style Dictionary.

## Scope

- Source tokens live under `tools/design-tokens/tokens/`.
- Style Dictionary resolves core, theme, and variant layers in deterministic order.
- Generated manifests live under `generated/themes/` and are committed or packaged for Qt consumers.
- Runtime QML and C++ APIs continue to use `Theme`; generated token objects are not public QML API.

## Theme Registry

`tools/design-tokens/themes.json` declares the sparse theme set. A single-manifest theme uses `path`. A variant theme uses `defaultVariant` and `variants`, and may also declare `basePath` for a resolved default manifest that loaders apply before the active variant.

`generated/themes/index.json` is authoritative for physical manifest paths; in short, index.json is authoritative. Phase 3 loaders should read paths from the index instead of deriving paths from theme or variant names.

## Reference Themes

`apple`, `claude`, and `airbnb` are reference themes converted from public VoltAgent `awesome-design-md` `DESIGN.md` files into reviewed DTCG source tokens. They intentionally map only into Merce runtime sections (`palette`, `spacing`, `radius`, and `typography`). Component-level guidance, imagery rules, shadows, and motion notes from the source `DESIGN.md` files are not emitted into runtime manifests.

Proprietary font family names are preserved as font stack preferences, but no third-party font files are vendored by this workspace.

## Manifest Shape

Generated manifests use shallow semantic sections aligned with the C++ runtime:

- `schemaVersion`
- `theme`
- optional `variant`
- `palette`
- `spacing`
- `radius`
- `typography`

Generated manifests do not expose raw DTCG paths or compatibility sections from the old QML facade. Compatibility aliases should be derived inside the runtime layer when needed.

## Phase 3 Runtime Support

Phase 3 runtime apply validates and applies these manifest-backed sections:

- `palette`
- `spacing`
- `radius`
- `typography`

`motion`, `iconography`, `zIndex`, `breakpoints`, and `shadows` remain construction defaults in Phase 3. They are still typed runtime objects, but this phase does not expand the generated token taxonomy to make those sections manifest-backed.

## Commands

Run these commands from `tools/design-tokens`:

```bash
npm install
npm run build
npm run validate
npm run check
```

`npm run build` writes `generated/themes/index.json` plus every manifest declared by `themes.json`.

`npm run validate` checks schema version, theme identity, required semantic sections, and required runtime fields.

`npm run check` rebuilds the manifests and fails if the generated files differ from what is already present.
