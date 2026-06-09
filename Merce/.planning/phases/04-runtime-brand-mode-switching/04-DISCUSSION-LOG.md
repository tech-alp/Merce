# Phase 4: Runtime Brand/Mode Switching - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-06-04T09:47:54+03:00
**Phase:** 04-runtime-brand-mode-switching
**Areas discussed:** Public API naming, Failed switch behavior, Binding invalidation, Phase 4 verification scope

---

## Public API Naming

| Option | Description | Selected |
|--------|-------------|----------|
| brand/mode public API | Match roadmap and QML consumer language: `Theme.setTheme("merce", "dark")`, `activeBrand`, `activeMode`. | yes |
| theme/variant public API | Match internal registry/index terminology from Phase 2 and Phase 3. | |
| both as aliases | Maximize compatibility but broaden public API surface. | |

**User's choice:** Use `brand/mode` as the public QML terminology.
**Notes:** Internal registry/loader may continue using `theme/variant`. User asked whether variant should be string or enum; decision is `QString`, not enum, because variants are data-driven by `index.json`. User also noted that C++20 must be treated as the repo baseline; top-level CMake confirms `CMAKE_CXX_STANDARD 20`.

---

## Failed Switch Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Keep current state | Return `false`, log clearly, and preserve current active theme when a request is invalid. | yes |
| Always apply default on error | Move to the registry default for every failure. | |
| Expose QML diagnostics properties | Add public `lastError` or `usedFallback` style diagnostics. | |

**User's choice:** Keep current state on failed switch.
**Notes:** Unknown brand/mode must not bounce the UI to default. If the existing loader returns a valid fallback result for a registered but broken manifest, implementation may apply that result and active state must reflect the actually applied fallback.

---

## Binding Invalidation

| Option | Description | Selected |
|--------|-------------|----------|
| Sub-object NOTIFY only | Keep sub-object pointers stable; update values and emit each sub-object's `changed()` signal. | yes |
| Sub-object NOTIFY plus top-level Theme NOTIFY | Also emit `Theme.paletteChanged()` etc. after every switch. | |
| Replace sub-object pointers | Create new theme sub-objects on every switch. | |

**User's choice:** Sub-object `NOTIFY` is sufficient; stable object pointers can be `CONSTANT`.
**Notes:** User challenged whether top-level `Theme` notify signals are needed. Review concluded the concern is valid: pointer properties should not signal value changes when the pointer itself does not change. Value invalidation should come from properties such as `Theme.palette.backgroundBase`, whose owning object emits `changed()`. Top-level object pointer properties such as `palette`, `colors`, `spacing`, `radius`, and `typography` may use `CONSTANT` when pointers are stable.

---

## Phase 4 Verification Scope

| Option | Description | Selected |
|--------|-------------|----------|
| C++ unit plus QML probe | Verify runtime API/state in QtTest and binding behavior in a focused QML probe. | yes |
| QML probe only | Faster but weaker for loader/state edge cases. | |
| C++ unit plus QML probe plus playground toggle | Adds early visual interaction but starts to overlap Phase 5 gallery scope. | |

**User's choice:** C++ QtTest plus focused QML probe.
**Notes:** Verification should prove successful `merce` dark/light switching, single-manifest `stripe` with empty mode, invalid request state preservation, active brand/mode queryability, and QML binding updates through `CONSTANT` object pointers plus sub-object `NOTIFY`.

---

## Spix Discussion

| Option | Description | Selected |
|--------|-------------|----------|
| Use Spix in Phase 4 | Add Spix as the main runtime switching test framework. | |
| Defer Spix to Phase 5 as optional | Keep Phase 4 dependency-light; evaluate Spix for gallery/UI automation later. | yes |
| Do not use Spix | Exclude Spix entirely. | |

**User's choice:** Defer Spix to Phase 5 as an optional candidate.
**Notes:** Spix is useful for QtQuick UI automation, RPC control, property reads, method invocation, and screenshots, but it adds AnyRPC and test-server integration. It fits Phase 5 playground/gallery validation better than Phase 4 runtime contract tests.

---

## the agent's Discretion

- Exact helper names and method split may follow existing `Core/Theme` style.
- Signal naming for active brand/mode may be one shared signal or separate signals if QML observability remains correct.
- The planner may choose whether to extend `ThemeProbe.qml` or add a new focused probe file.

## Deferred Ideas

- Evaluate Spix as an optional Phase 5 playground/gallery UI automation tool, gated behind an opt-in test option such as `MERCE_ENABLE_SPIX_TESTS=ON` if adopted.
- Playground visual theme gallery and screenshot automation remain Phase 5 scope.
