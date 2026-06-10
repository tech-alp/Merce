---
name: merce-playground-verification
description: Run Merce-specific playground, theme runtime, CTest, offscreen QML probe, gallery export, and visual evidence verification. Use this skill in the Merce repo before commits or reviews that touch Theme, generated themes, Foundation icons/fonts, Controls, Notifications, playground QML, probe routes, or docs/assets/theme-gallery.
---

# Merce Playground Verification

Use this skill to verify that the Merce Qt/QML playground still proves real
consumer-style module usage and theme runtime behavior.

## Workflow

1. Inspect the current worktree first.
   - Do not stage, revert, or rewrite unrelated dirty files.
   - If `build/` is missing or points at a broken Qt install, report the
     limitation and use the active validated build directory instead.

2. For full verification, run:

```bash
skills/merce-playground-verification/scripts/run-gates.sh
```

Optional environment overrides:

```bash
MERCE_BUILD_DIR=build/Qt_6_11_1_for_macOS-Debug \
MERCE_GALLERY_DIR=docs/assets/theme-gallery \
skills/merce-playground-verification/scripts/run-gates.sh
```

3. For targeted verification, read `references/test-cases.md` and run only the
   cases relevant to the changed area.

4. Interpret expected logs correctly.
   - `QML debugging is enabled` is expected for `MercePlayground`.
   - `theme 'unknown' is not registered` is expected inside
     `--theme-switch-probe`.
   - Qt font alias warnings are non-fatal unless the task is typography/font
     quality.

5. Report results with:
   - commands run
   - pass/fail state
   - important probe markers
   - non-fatal warnings
   - any human-only checks left open

## Guardrails

- Use `QT_QPA_PLATFORM=offscreen` for headless playground probes.
- Do not replace the playground gates with the raw `qml` CLI.
- Keep qmlagent optional; it is an inspection/debug flow, not a CI gate.
- Do not add Spix, pixel-perfect visual diff, `QQuickStyle::setStyle`, or
  `qtquickcontrols2.conf` requirements unless explicitly requested.
- Keep token build tooling optional; `merce_tokens` must not become a default
  dependency of `MerceTheme`, `MercePlayground`, or `all`.

## Resources

- `references/test-cases.md` maps Merce test cases to commands, pass markers,
  and when to use them.
- `scripts/run-gates.sh` runs the full local verification sequence.
