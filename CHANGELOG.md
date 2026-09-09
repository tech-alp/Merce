# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- WebAssembly playground build and GitHub Pages deployment at the public live
  demo URL
- Core CI coverage for Ubuntu and macOS, plus QML lint validation for the full
  playground build
- Deterministic playground page exports at desktop and compact audit widths

### Changed

- Pinned GitHub Actions to immutable revisions and updated the optional
  QtToastify source dependency to the v2.0.0 release tag
- Limited QML debugging to Debug builds instead of public Pages artifacts

### Fixed

- Prevented responsive playground headers from overlapping content and kept
  read-only Theme Builder color cards visible in page exports
- Captured playground pages on the semantic canvas color instead of a
  transparent black background

## [1.1.0] - 2026-08-27

### Added

- Merce StyleKit mappings for `SpinBox` and `TextArea`, including token-driven
  interaction states and runtime theme switching

### Changed

- Widened the StyleKit `Switch` track using the medium control-size token
- Filled checked `outline` buttons with the primary action colors while keeping
  the selected appearance during keyboard focus
- Updated the bundled Material Symbols Rounded font and codepoint metadata
- Limited install/package rules to standalone Merce builds so FetchContent
  consumers do not inherit Merce installation targets

### Fixed

- Removed duplicated horizontal content padding from StyleKit `SpinBox`
  layouts so compact values remain visible between the indicators
- Kept button focus keyboard-only so pointer activation does not leave a stale
  focus outline

## [1.0.0] - 2026-08-26

### Added

- Qt 6.11+ QML design-system modules for theme, foundation, style, effects,
  controls, platform capabilities, icons, and notifications
- Semantic design-token runtime with brand, mode, and profile switching
- Qt.labs.StyleKit integration and reusable Merce controls
- Optional Font Awesome and QtToastify-backed notification modules
- Design-token generation, validation, runtime tests, probes, and playground
- CMake install package and source-integration targets

### Changed

- Notifications and the playground are opt-in to keep the default dependency
  surface minimal
- Linear reference theme uses the bundled OFL-licensed JetBrains Mono font

[Unreleased]: https://github.com/tech-alp/Merce/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/tech-alp/Merce/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/tech-alp/Merce/releases/tag/v1.0.0
