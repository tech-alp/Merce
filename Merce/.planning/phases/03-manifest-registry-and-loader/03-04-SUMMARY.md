---
phase: 03-manifest-registry-and-loader
plan: 04
subsystem: runtime-loader
tags: [qt6, qjsondocument, qfile, qloggingcategory, qtest, manifest-loader]
requires:
  - phase: 03-manifest-registry-and-loader
    provides: MerceCore packaged generated manifests under :/merce/themes
provides:
  - Safe normalized C++ theme manifest registry
  - Internal manifest loader with section-level overlay and strict validation
  - Fallback handling for registered manifest load failures
  - QTest coverage for unknown input, path safety, validation, overlay, and fallback
affects: [runtime-apply, theme-switching, verification-gallery]
tech-stack:
  added: []
  patterns: [index-authoritative-registry, qt-core-json-loader, section-level-overlay, structured-load-result]
key-files:
  created:
    - Core/Theme/MerceThemeManifest.h
    - Core/Theme/MerceThemeRegistry.h
    - Core/Theme/MerceThemeRegistry.cpp
    - Core/Theme/MerceThemeManifestLoader.h
    - Core/Theme/MerceThemeManifestLoader.cpp
    - tests/Core/tst_merce_theme_manifest_loader.cpp
  modified:
    - Core/CMakeLists.txt
    - tests/Core/CMakeLists.txt
key-decisions:
  - "Unknown theme and variant inputs fail at registry lookup and are not converted into fallback path derivation."
  - "Only registered manifest load or validation failures fall back once to the registry default."
  - "The loader validates final overlay output for all supported palette, spacing, radius, and typography fields before use."
patterns-established:
  - "Use MerceThemeRegistry::fromJson to normalize generated index entries before any loader selection."
  - "Use MerceThemeManifestLoader for internal resource-backed load results; do not expose diagnostics through QML."
requirements-completed: [MANIFEST-02, MANIFEST-03, MANIFEST-04, MANIFEST-05]
duration: 6 min
completed: 2026-06-03
---

# Phase 03 Plan 04: Safe Manifest Registry And Loader Summary

**Qt Core manifest registry and loader that trusts only `index.json`, validates merged manifests, and tests failure/fallback behavior**

## Performance

- **Duration:** 6 min
- **Started:** 2026-06-03T19:28:15Z
- **Completed:** 2026-06-03T19:34:30Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Added `MerceThemeRegistry` to normalize generated `index.json` entries into safe lookup records.
- Added `MerceThemeManifestLoader` using `QFile`, `QJsonDocument`, `QJsonParseError`, `QJsonObject`, and `merce.theme.loader` logging.
- Implemented section-level base/active overlay with strict final validation for schema, identity, palette, spacing, radius, and typography.
- Added QTest coverage for resource loading, unknown theme/variant rejection, unsafe paths, malformed JSON, schema mismatch, overlay completeness, fallback success, and broken default failure.

## Task Commits

Each task was committed atomically:

1. **Task 1: Normalize index.json Into A Safe Registry** - `e4bef49` (feat)
2. **Task 2: Load, Overlay, Validate, And Fallback** - `14390ae` (feat)
3. **Task 3: Cover Registry And Loader Failure Modes With QTest** - `27280d5` (test)

## Files Created/Modified

- `Core/Theme/MerceThemeManifest.h` - Defines `MerceThemeLoadResult`.
- `Core/Theme/MerceThemeRegistry.h` - Declares normalized registry entry, lookup result, registry result, and registry API.
- `Core/Theme/MerceThemeRegistry.cpp` - Parses and validates generated index JSON without deriving paths from user input.
- `Core/Theme/MerceThemeManifestLoader.h` - Declares internal loader entrypoints `loadDefault()` and `load(theme, variant)`.
- `Core/Theme/MerceThemeManifestLoader.cpp` - Reads resource JSON, overlays base/active manifests, validates final manifest, logs failures, and falls back only for registered requested-load failures.
- `Core/CMakeLists.txt` - Adds registry and loader sources to `MERCE_CORE_THEME_SOURCES`.
- `tests/Core/CMakeLists.txt` - Registers `tst_merce_theme_manifest_loader` and links Core tests with `MerceCore`.
- `tests/Core/tst_merce_theme_manifest_loader.cpp` - Covers registry and loader success, rejection, validation, overlay, and fallback behavior.

## Decisions Made

- Unknown theme and variant requests return `ok=false` from registry resolution and do not fall back, preserving MANIFEST-03 rejection semantics.
- Fallback is reserved for registered manifest read/validation failures and sets `usedFallback=true` only when the registry default successfully loads.
- Path validation rejects empty, absolute, `../`, slash-separated, backslash-separated, and `:`-prefixed manifest paths before resolution.
- Loader internals remain C++/Qt Core only; no `Theme.setTheme`, active theme/variant properties, or QML diagnostic properties were added.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Linked Core QTest helper to MerceCore**
- **Found during:** Task 3 (Cover Registry And Loader Failure Modes With QTest)
- **Issue:** The existing `merce_add_qtest` helper linked only `Qt6::Core` and `Qt6::Test`, so the new loader test could not include or link internal MerceCore loader symbols cleanly.
- **Fix:** Added `MerceCore` linkage and the Core/Theme include path inside the helper, then registered `tst_merce_theme_manifest_loader`.
- **Files modified:** `tests/Core/CMakeLists.txt`
- **Verification:** `cmake --build build --target tst_merce_theme_manifest_loader` and `ctest --test-dir build -R tst_merce_theme_manifest_loader --output-on-failure` passed.
- **Committed in:** `27280d5`

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The test harness adjustment was required for the planned internal C++ tests and did not expand runtime API or add dependencies.

## Issues Encountered

- After adding the new test target, `cmake --build build --target tst_merce_theme_manifest_loader` initially had no rule until CMake was reconfigured. Re-running `cmake -S . -B build -DBUILD_TESTING=ON -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` resolved it.
- Git post-commit hook warned that Git LFS is configured but `git-lfs` is not available in PATH. The hook did not fail and commits completed.

## Verification

- `cmake --build build --target MerceCore` - passed.
- `cmake -S . -B build -DBUILD_TESTING=ON -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` - passed.
- `cmake --build build --target tst_merce_theme_manifest_loader` - passed.
- `ctest --test-dir build -R tst_merce_theme_manifest_loader --output-on-failure` - passed.
- `rg -n "setTheme|activeTheme|activeVariant|lastError|Q_PROPERTY\\(.*usedFallback|Q_INVOKABLE.*Theme" Core/Theme || true` - no matches.
- `git diff --check -- Core/CMakeLists.txt Core/Theme/MerceThemeManifest.h Core/Theme/MerceThemeRegistry.h Core/Theme/MerceThemeRegistry.cpp Core/Theme/MerceThemeManifestLoader.h Core/Theme/MerceThemeManifestLoader.cpp tests/Core/CMakeLists.txt tests/Core/tst_merce_theme_manifest_loader.cpp` - passed.

## Known Stubs

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 03-05 can apply the validated default manifest into the typed `MerceTheme` runtime without adding public runtime switching yet.

## Self-Check: PASSED

- Found `Core/Theme/MerceThemeManifest.h`.
- Found `Core/Theme/MerceThemeRegistry.h`.
- Found `Core/Theme/MerceThemeRegistry.cpp`.
- Found `Core/Theme/MerceThemeManifestLoader.h`.
- Found `Core/Theme/MerceThemeManifestLoader.cpp`.
- Found `tests/Core/tst_merce_theme_manifest_loader.cpp`.
- Found `tests/Core/CMakeLists.txt`.
- Found `Core/CMakeLists.txt`.
- Found task commit `e4bef49`.
- Found task commit `14390ae`.
- Found task commit `27280d5`.

---
*Phase: 03-manifest-registry-and-loader*
*Completed: 2026-06-03*
