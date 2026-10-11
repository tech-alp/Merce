# StyleKit Sheen Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan
> task by task, with a fresh whole-branch review after integration.

**Goal:** Ship a reusable sheen shader, a StyleKit variation, a real playground
page and a documented AI-assisted contribution path in one reviewable PR.

**Architecture:** Keep drawing in Merce.Effects and place state/theme binding in
the new opt-in Merce.Style.Effects module. The existing MButton consumes the
new variation without behavioral changes. Build qsb resources with ShaderTools.

**Tech Stack:** Qt 6.11+, QML, Vulkan-compatible GLSL, C++20, CMake 3.30+, Qt Test.

**Spec:** ../specs/2026-10-11-stylekit-sheen-design.md

## Global Constraints

- Keep CMake 3.30, C++20, and Qt 6.11 as the explicit baseline.
- Optional modules stay isolated; no token-manifest or MButton refactor.
- ShaderTools is build-time tooling; no runtime QShaderBaker or AI dependency.
- No automatic OS motion preference claim and no universal GPU performance claim.
- Preserve both source-tree and installed-package usage and immutable CI action pins.

## Review Focus

- Loading/variant/size combinations must retain their existing colors and layout.
- A hover interrupted by visibility, press or policy changes must release its shader.
- Asymmetric or oversized radii and narrow/zero-size items must not draw outside
  their rounded surface or produce invalid arithmetic.
- A package consumer must load qsb from resources without source-directory files.
- Turning the adapter OFF must leave a usable base build and playground.

## Task 1: Effect and StyleKit integration

**Files:** Effects/MSheen.qml, Effects/shaders/sheen.frag, Effects/CMakeLists.txt,
Style/Effects/{CMakeLists.txt,MerceEffectsStyle.qml,SheenBackground.qml,EffectPolicy.qml},
CMakeLists.txt, tests/Effects/*, tests/CMakeLists.txt.

**Interfaces:** Produce MSheen's property API and
MerceEffectsStyle.effectPolicy { enabled, reducedMotion }; consume existing
MButton.extraVariations and Merce Theme/StyleKit state.

- Add a Qt Test probe that requests the new style and verifies the sheen
  background and packaged shader. Run before implementation: expect failure
  because Merce.Style.Effects is not available.
- Add the primitive and shader; register qsb in MerceEffects.
- Add policy, background delegate and the sheen StyleVariation. Implement
  one finite hover sweep and conditional shader creation.
- Verify fallback, themes, variant/size/loading, focus/click behavior, parameter
  bounds and animation interruptions. Add direct rendering checks for a graphics
  backend instead of relying on the default software test environment.
- Run `cmake --build build --parallel 2` and
  `ctest --test-dir build --output-on-failure`; expect the new and existing tests
  to pass. Preserve actual evidence and environment limitations in the ledger.

## Task 2: Consumer packaging and playground

**Files:** cmake/InstallMerce.cmake, MerceConfig.cmake,
tests/{source-consumer,package-consumer}/*, playground/CMakeLists.txt,
playground/view/{Main.qml,EffectsShowcase.qml,PlaygroundPagesExport.qml},
relevant playground navigation/probe files.

**Interfaces:** Consume Merce::StyleEffects and MerceEffectsStyle; expose the
Effects page through the existing navigation/theme selection. The OFF build
has neither adapter imports nor adapter-only pages.

- Extend consumer checks first; expect missing StyleEffects target/resource
  before the packaging changes.
- Install/export the module and alias; use the qrc shader URL in installed
  QML. Build and run both consumer paths.
- Add the real Effects page, finite interactive controls and scrubbable
  primitive; wire navigation, lint and page export conditionally.
- Configure an OFF build and verify existing modules/playground still load.
- Run the complete playground verification gates and collect visual evidence.

## Task 3: Usage, AI authoring contract and PR

**Files:** README.md, CHANGELOG.md, docs/effects.md, docs/effects/sheen.md,
skills/merce-effects/SKILL.md and references/effect-contract.md.

**Interfaces:** Document only the implemented API; make the skill refer to real
commands, source locations, build resources and existing verification tooling.

- Document use, policy controls, dependencies, limits, and canonical shader
  sources. Explain QQEM exports without inventing an automatic exporter.
- Add the small provider-independent authoring skill and validate its links
  and code examples against the implementation.
- Run module/playground lint, the full relevant suite, consumer verification
  and `git diff --check`. Have a fresh reviewer inspect the whole branch.
- Resolve material findings, commit focused changes, publish the feature
  branch and open the requested PR. Report actual checks and any missing native
  hardware validation; do not merge.

## Execution record

Qt 6.11.1 verification covers all eight CTests, the full playground gates,
source and installed-package consumers, and a clean adapter-OFF playground.
The separate OpenGL/Mesa CTest checks real pixels and finite sweep lifetime;
WebAssembly builds also verify static QML plugins. Qt installations explicitly
include the ShaderTools addon for native and cross builds.

Independent review resolved a timing-dependent visibility recovery assertion.
Inspection of the first OpenGL screenshots revealed that a dark text tint
made the band resemble a shadow, so the adapter and showcase use the primitive's
neutral white highlight. The reusable primitive still exposes its color input.

[PR #10](https://github.com/tech-alp/Merce/pull/10) records the current CI results
and the `merce-effects-opengl` screenshot artifact used for visual review.
