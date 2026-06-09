# Merce Playground Verification Test Cases

Use these cases from the Merce repo root unless a different build directory is
explicitly selected with `MERCE_BUILD_DIR`.

## Automated Gates

| Case | Command | Validates | Pass signal |
|---|---|---|---|
| Build playground | `cmake --build build --target MercePlayground` | QML modules, resources, playground executable | exit 0 |
| Build manifest tests | `cmake --build build --target tst_merce_theme_manifest_loader` | manifest loader test target still builds | exit 0 |
| Build runtime tests | `cmake --build build --target tst_merce_theme_runtime_switch` | runtime switch test target still builds | exit 0 |
| Run CTest | `ctest --test-dir build --output-on-failure` | Core runtime harness, manifest loader, runtime switch tests | all tests pass |
| Theme probe | `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-probe` | public `Theme.palette`, spacing, radius, typography, iconography, breakpoints, active state | `theme-probe ok` |
| Runtime switch probe | `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-switch-probe` | light to dark to reference theme switching and invalid request preservation | `theme-switch-probe ok` |
| Smoke route | `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --smoke-test` | basic app load in headless mode | exit 0 |
| Gallery probe | `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --theme-gallery-probe` | representative component consumption after theme switches | `theme-gallery-probe ok` |
| Playground probe | `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --playground-probe` | navigation shell, page switching, icon browser, and control page route | `playground-probe ok` |
| Gallery export | `QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground --export-theme-gallery docs/assets/theme-gallery` | deterministic visual evidence export | `theme-gallery-export ok` |

After gallery export, verify these files are non-empty:

```bash
test -s docs/assets/theme-gallery/merce-light.png
test -s docs/assets/theme-gallery/merce-dark.png
test -s docs/assets/theme-gallery/stripe-reference.png
```

## Targeted Selection

Run the full gate set when changes touch:

- `Theme/`
- `Core/`
- `Platform/`
- `generated/themes/`
- `tools/design-tokens/themes.json`
- `Foundation/` icon or font support
- `Controls/`
- `Notifications/`
- `playground/`
- `docs/assets/theme-gallery/`

For token-only changes, also run the design token workspace gates from
`tools/design-tokens` if Node dependencies are available:

```bash
npm run build
npm run validate
npm run check
```

## Human Or Optional Checks

Visual review is still human-facing:

- Open or inspect `docs/assets/theme-gallery/merce-light.png`.
- Open or inspect `docs/assets/theme-gallery/merce-dark.png`.
- Open or inspect `docs/assets/theme-gallery/stripe-reference.png`.
- Confirm they are readable, non-overlapping, and visibly distinct.

Optional qmlagent inspection:

```bash
QT_QPA_PLATFORM=offscreen ./build/playground/MercePlayground \
  -qmljsdebugger=port:3771,host:127.0.0.1,services:QmlAgent
node tools/qmlagent-probe.mjs 3771
```

Use qmlagent for selector/diagnostic inspection only; do not treat it as a
mandatory CI gate.
