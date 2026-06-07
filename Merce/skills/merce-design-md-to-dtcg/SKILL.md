---
name: merce-design-md-to-dtcg
description: Convert public or local DESIGN.md design-system references into reviewed Merce DTCG source token themes and integrate them into the Merce Qt/QML app. Use when adding reference themes from VoltAgent awesome-design-md, Google Stitch DESIGN.md files, or similar markdown design-system docs into tools/design-tokens, generated/themes, CMake resources, playground, or runtime theme switching tests.
---

# Merce DESIGN.md to DTCG

Use this skill to add a DESIGN.md-inspired reference theme to Merce without bypassing the existing token pipeline or public `Merce.Core.Theme` contract.

## Workflow

1. Inspect the current Merce token contract before editing:
   - `tools/design-tokens/README.md`
   - `tools/design-tokens/themes.json`
   - `tools/design-tokens/src/merce-manifest-format.mjs`
   - `docs/superpowers/specs/2026-06-05-runtime-theme-sources-design.md`
   - Existing theme sources under `tools/design-tokens/tokens/themes/`

2. Fetch or read the source `DESIGN.md`.
   - Prefer raw markdown URLs for GitHub sources.
   - Treat AI/markdown extraction as a reviewed source candidate, not canonical runtime JSON.
   - Do not vendor proprietary fonts or brand assets unless explicitly requested and licensed.

3. Convert only Merce-supported runtime sections into DTCG source tokens:
   - `colors`
   - `spacing`
   - `radius`
   - `typography`
   - Keep component recipes, imagery rules, motion, shadows, and layout prose out of generated manifests unless Merce runtime support already exists.
   - Treat these section names as Merce's source/runtime taxonomy, not as DTCG-mandated group names.
   - Use explicit `$type` metadata; do not rely on group names to imply type.
   - Use a single Qt-loadable font family name in typography tokens, not CSS font stacks. Keep font files/assets as separate licensed Merce asset metadata when explicit font files are provided.

4. Add a source theme under:
   - `tools/design-tokens/tokens/themes/<theme>/theme.json`
   - If licensed runtime font files are part of the theme, add their metadata through the Merce font asset workflow instead of embedding binary assets or file paths as generic typography tokens.

5. Register the theme in:
   - `tools/design-tokens/themes.json`
   - Use a single `path` for single-manifest reference themes.
   - Use `variants` only when the source truly has explicit modes.

6. Build and validate from `tools/design-tokens`:

```bash
npm run build
npm run validate
npm run check
```

7. Verify Qt resource packaging and runtime load:

```bash
cmake --build build --target MerceCore
QT_QPA_PLATFORM=offscreen build/tests/Core/tst_merce_theme_runtime_switch
```

If the active build dir is different, run the same targets there too.

## Guardrails

- Never hand-edit `generated/themes/*.json` as the source of truth; generate them from DTCG sources.
- Keep `generated/themes/index.json` authoritative for manifest paths.
- Keep runtime code reading packaged resources from `:/merce/themes/index.json`.
- Preserve the current public QML contract (`Theme.colors.*`, `Theme.spacing.*`, `Theme.radius.*`, `Theme.typography.*`) unless the task is explicitly an API migration.
- Do not expose source token paths such as `palette.semantic.textPrimary` or future `color.text.primary` as public QML API.
- Do not treat third-party font names as proof that the font files are licensed or available at runtime.
- Keep changes scoped to token source, registry, generated manifest output, resource packaging, and focused runtime tests.
- Avoid adding new third-party dependencies.

## Detailed Reference

Read `references/merce-theme-contract.md` when you need exact field mapping rules, common failure handling, or examples for tests and verification.
