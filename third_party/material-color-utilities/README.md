# Material Color Utilities C++ subset

Vendored from Google's
[`material-foundation/material-color-utilities`](https://github.com/material-foundation/material-color-utilities)
at commit `ec7c4da3e0774264275377cd6b7687474bad577a` (2026-07-27).

Only the dependency-free C++ sources required for HCT tonal derivation and contrast are
included:

- `cpp/utils/`
- `cpp/cam/`
- `cpp/palettes/`
- `cpp/contrast/`

Upstream test files and all other feature directories are intentionally excluded. The
vendored source is licensed under Apache-2.0; see `LICENSE`.

## Local portability patch

Upstream `cpp/utils/utils.cc` uses Abseil only to format `HexFromArgb()`. Merce replaces
that call with C++17 `std::to_chars`, preserving Abseil's lowercase, no-padding output
while keeping this subset dependency-free.
