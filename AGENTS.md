# Repository Guidelines

## Architecture Boundaries

Merce is a Qt 6.11+ theme, StyleKit mapping, and feedback runtime, not a general-purpose control library. Prefer this order for new UI needs: semantic token, `Merce.Style` mapping, StyleKit variation, Foundation primitive, then a custom control only when behavior differs. Keep the CMake 3.30, C++20, and Qt 6.11 baseline explicit.

Optional modules must stay isolated. `MERCE_BUILD_NOTIFICATIONS=OFF` must avoid fetching QtToastify. `BUILD_MERCE_PLAYGROUND=OFF` must avoid building the demo. `Merce.Notifications` remains source-only; installed packages contain the core design-system modules and optional Font Awesome module.

## Project Layout

- `Theme/`, `Style/`, `Foundation/`, `Effects/`, `Controls/`, and `Platform/` contain public QML modules.
- `Notifications/` contains the optional QtToastify-backed feedback layer.
- `playground/` is a real full-feature consumer, not a mock UI.
- `tools/design-tokens/tokens/` is the token source; generated manifests and fonts under `generated/` are committed outputs.
- `tests/` contains Qt Test coverage plus source and installed-package consumers.

## Build and Verification

```bash
cmake -S . -B build -G Ninja -DMERCE_BUILD_TESTS=ON
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

Full playground changes require notifications, Font Awesome, and `BUILD_MERCE_PLAYGROUND=ON`. Run `skills/merce-playground-verification/scripts/run-gates.sh` before committing Theme, Foundation, Controls, Notifications, or playground changes. Use `QT_QPA_PLATFORM=offscreen` in headless environments.

For token changes, run `npm --prefix tools/design-tokens ci`, then `build`, `validate`, and `check`. Never hand-edit generated manifests.

## CI and WebAssembly

Keep GitHub Actions pinned to immutable SHAs with version comments. `scripts/build_wasm.sh` builds the actual `MercePlayground`, disables install generation with standard `CMAKE_SKIP_INSTALL_RULES`, validates required static QML plugins, and assembles `build-wasm/site/`; do not commit generated WASM output. Pages publishes only after the WASM artifact passes. Keep `QT_QML_DEBUG` Debug-only. Express QML dependencies through CMake targets and module metadata, not manual import-path workarounds.

## Git and Reviews

Use focused Conventional Commits, such as `ci(wasm): deploy Merce playground`. Update `CHANGELOG.md` for user-visible behavior. Pull requests should state the problem, solution, trade-offs, verification commands, and include screenshots for visual changes. Preserve unrelated worktree changes.
