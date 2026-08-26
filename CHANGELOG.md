# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/tech-alp/Merce/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/tech-alp/Merce/releases/tag/v1.0.0
