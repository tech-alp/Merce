---
phase: 02-token-build-pipeline
status: passed
verified_at: 2026-06-03T17:31:00Z
requirements: [TOKENS-01, TOKENS-02, TOKENS-03, TOKENS-04, TOKENS-05]
score: 5/5
---

# Phase 2 Verification

## Verdict

Status: passed.

Phase 2 achieved the goal: Merce now has reviewed DTCG token sources, a bounded Style Dictionary v5 build pipeline, committed generated runtime manifests, validation checks, deterministic output checking, and a default-off CMake token target that does not affect normal Qt builds.

## Requirement Checks

| Requirement | Status | Evidence |
|-------------|--------|----------|
| TOKENS-01 | passed | DTCG source files exist under `tools/design-tokens/tokens/` and use `$value` / `$type`. |
| TOKENS-02 | passed | `tools/design-tokens/build.mjs` builds each entry with explicit source order from core, theme, then variant. |
| TOKENS-03 | passed | Style Dictionary emits Merce runtime manifest JSON under `generated/themes/`; no public QML generated token files were added. |
| TOKENS-04 | passed | Generated manifests include `schemaVersion: 1`, `theme`, optional `variant`, and semantic sections independent from raw DTCG token paths. |
| TOKENS-05 | passed | Generated manifests and `package-lock.json` are committed; normal CMake configure/build with `MERCE_ENABLE_TOKEN_BUILD=OFF` does not require Node. |

## Must-Have Checks

| Must-have | Status | Evidence |
|-----------|--------|----------|
| Node `>=22.0.0` declared | passed | `tools/design-tokens/package.json` has `engines.node = ">=22.0.0"`. |
| DTCG sources do not mix legacy source format | passed | `rg -n '"\\$value"|"\\$type"' tools/design-tokens/tokens` finds DTCG keys; no generated manifest depends on raw source paths. |
| Single-manifest themes have no fake mode | passed | `generated/themes/index.json` has `themes.stripe.path = "stripe.json"` and no `defaultMode`. |
| Merce light/dark variant manifests exist | passed | `generated/themes/merce.light.json` and `generated/themes/merce.dark.json` exist and validate. |
| Stripe single manifest exists | passed | `generated/themes/stripe.json` exists, validates, and has no `variant`. |
| Generated manifests use semantic sections | passed | Manifests contain `palette`, `spacing`, `radius`, and `typography`. |
| Generated manifests omit `colors` compatibility section | passed | `rg -n '"colors"' generated/themes` returns no matches. |
| Normal CMake build does not require Node | passed | `cmake -S . -B build -DMERCE_ENABLE_TOKEN_BUILD=OFF` and `cmake --build build --target MercePlayground` passed. |

## Automated Checks

- `cd tools/design-tokens && npm install` - passed after approved registry access.
- `cd tools/design-tokens && npm run build` - passed.
- `cd tools/design-tokens && npm run validate` - passed.
- `cd tools/design-tokens && npm run check` - passed.
- `node tools/design-tokens/src/validate-manifest.mjs generated/themes/stripe.json` - passed.
- Validator negative checks for missing `schemaVersion` and missing `palette.textPrimary` - passed.
- `cmake -S . -B build -DMERCE_ENABLE_TOKEN_BUILD=OFF` - passed.
- `cmake --build build --target MercePlayground` - passed.
- `cmake -S . -B build-tokens -DMERCE_ENABLE_TOKEN_BUILD=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` - passed.
- `cmake --build build-tokens --target merce_tokens` - passed.
- `env QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe` - passed.
- `env QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test` - passed with the known non-blocking `DM Sans` alias warning.
- `git diff --check` - passed.
- `rg -n '"defaultMode"|"colors"' generated/themes tools/design-tokens/themes.json` - no matches.
- `node /Users/techalp/.codex/get-shit-done/bin/gsd-tools.cjs query verify.schema-drift 02` - no schema drift.

## Code Review

`02-REVIEW.md` status is `clean`.

## Notes

- Style Dictionary emits token collision warnings because theme and variant layers intentionally override earlier token paths. The merge order is explicit and deterministic.
- Phase 3 should use `generated/themes/index.json` as the authoritative registry and should not derive manifest file names from theme and variant names.

## Human Verification

None required for this phase.
