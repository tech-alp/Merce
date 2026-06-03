---
phase: 03-manifest-registry-and-loader
plan: 01
subsystem: testing
tags: [qt6, qtest, ctest, cmake, manifest-loader]
requires:
  - phase: 02-token-build-pipeline
    provides: generated runtime manifests and authoritative sparse theme index
provides:
  - BUILD_TESTING-gated main-repo CTest activation
  - Core QTest helper for fast C++ tests
  - Concrete tst_merce_test_harness target registered with CTest
affects: [manifest-registry, runtime-loader, verification-gallery]
tech-stack:
  added: [Qt6::Test]
  patterns: [build-testing-gate, core-qtest-helper, ctest-registration]
key-files:
  created:
    - tests/CMakeLists.txt
    - tests/Core/CMakeLists.txt
    - tests/Core/tst_merce_test_harness.cpp
  modified:
    - CMakeLists.txt
key-decisions:
  - "Qt6::Test is required only when BUILD_TESTING is enabled."
  - "The Core test route uses a reusable merce_add_qtest helper that registers matching CTest names."
  - "The tests subtree is added only when its CMake entrypoint exists, keeping the initial BUILD_TESTING gate independently configurable during staged execution."
patterns-established:
  - "Use merce_add_qtest(target source) for Core QTest executables."
  - "Register CTest entries with the same name as the Qt test executable."
requirements-completed: [MANIFEST-03, MANIFEST-04, MANIFEST-05]
duration: 34 min
completed: 2026-06-03
---

# Phase 03 Plan 01: Main-Repo Test Harness Summary

**BUILD_TESTING-gated Qt Test and CTest harness for future manifest registry and loader validation**

## Performance

- **Duration:** 34 min
- **Started:** 2026-06-03T18:35:00Z
- **Completed:** 2026-06-03T19:09:23Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added top-level CTest integration without changing normal runtime dependencies.
- Required `Qt6::Test` only inside the `BUILD_TESTING` path.
- Added a `tests/` subtree with a Core-specific `merce_add_qtest(target source)` helper.
- Added `tst_merce_test_harness` as a concrete QTest sanity target registered through CTest.

## Task Commits

Each task was committed atomically:

1. **Task 1: Gate Main-Repo Tests Behind BUILD_TESTING** - `fc421bc` (`build`)
2. **Task 2: Add Core QTest Harness Target** - `d9a649d` (`test`)

## Files Created/Modified

- `CMakeLists.txt` - Adds `include(CTest)`, BUILD_TESTING-gated `Qt6::Test`, and test subtree activation.
- `tests/CMakeLists.txt` - Main test subtree entrypoint.
- `tests/Core/CMakeLists.txt` - Defines `merce_add_qtest` and registers `tst_merce_test_harness`.
- `tests/Core/tst_merce_test_harness.cpp` - Minimal QTest target proving the helper and CTest route.

## Decisions Made

- Kept `MERCE_ENABLE_TOKEN_BUILD` untouched and default `OFF`; enabling tests does not trigger npm or Style Dictionary.
- Kept the first QTest independent from manifest loader symbols so later loader implementation can add negative tests incrementally.
- Registered CTest names to match target names for simple `ctest -R` filtering.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Guarded staged test subtree activation**
- **Found during:** Task 1 (Gate Main-Repo Tests Behind BUILD_TESTING)
- **Issue:** `add_subdirectory(tests)` failed during Task 1 verification because Task 2 had not created `tests/CMakeLists.txt` yet.
- **Fix:** Kept `add_subdirectory(tests)` BUILD_TESTING-gated and additionally guarded it with a `tests/CMakeLists.txt` existence check. Once Task 2 creates the entrypoint, the same configure path activates the tests.
- **Files modified:** `CMakeLists.txt`
- **Verification:** `cmake -S . -B build -DBUILD_TESTING=ON -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` passed before and after adding the test subtree.
- **Committed in:** `fc421bc`

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** No runtime scope change. The guard keeps staged execution verifiable while the final plan state still activates the test subtree when BUILD_TESTING is enabled.

## Issues Encountered

- Git post-commit hook warned that Git LFS is configured but `git-lfs` is not available in PATH. The hook did not fail and both commits completed.

## Verification

- `cmake -S . -B build -DBUILD_TESTING=ON -DBUILD_MERCE_PLAYGROUND=ON -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.11.1/macos` - passed.
- `cmake --build build --target tst_merce_test_harness` - passed.
- `ctest --test-dir build -R tst_merce_test_harness --output-on-failure` - passed.
- `git diff --check -- tests/CMakeLists.txt tests/Core/CMakeLists.txt tests/Core/tst_merce_test_harness.cpp` - passed.
- Stub scan for the modified plan files - no matches.

## Known Stubs

None.

## Threat Flags

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 3 can now add manifest registry and loader negative tests under `tests/Core` before wiring loader behavior into `MerceCore`.

## Self-Check: PASSED

- Found `CMakeLists.txt`.
- Found `tests/CMakeLists.txt`.
- Found `tests/Core/CMakeLists.txt`.
- Found `tests/Core/tst_merce_test_harness.cpp`.
- Found task commit `fc421bc`.
- Found task commit `d9a649d`.

---
*Phase: 03-manifest-registry-and-loader*
*Completed: 2026-06-03*
