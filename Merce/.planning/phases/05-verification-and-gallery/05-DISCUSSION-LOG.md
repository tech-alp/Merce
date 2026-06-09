# Phase 05: Verification And Gallery - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-04T11:50:57+03:00
**Phase:** 05-verification-and-gallery
**Areas discussed:** Verification proof stack, Component smoke coverage, Manifest validation boundary, Playground gallery shape, Automation dependency policy

---

## Verification Proof Stack

| Option | Description | Selected |
|--------|-------------|----------|
| Light but solid | CTest, theme QtTests, `--theme-probe`, `--theme-switch-probe`, `--smoke-test`, and gallery build/offscreen run are mandatory; qmlagent/screenshot are optional. | ✓ |
| Interactive validation mandatory | Add qmlagent inspect/click/diagnostics checks as required verification. | |
| Visual proof mandatory | Add screenshot or visual comparison as a required verification gate. | |
| Other | Freeform stack. | |

**User's choice:** Light but solid, with visual focus for gallery README evidence.
**Notes:** User said this can be option 1, but gallery visuals will be shared in a README, so the phase should proceed visually as well. Decision captured as deterministic mandatory tests plus README-ready visual artifacts, without mandatory pixel-perfect visual diff.

---

## Public Theme API Naming

| Option | Description | Selected |
|--------|-------------|----------|
| Carry forward compatibility aliases | Treat `colors`, `icons`, and singular aliases as compatibility requirements. | |
| Prefer canonical API during development | Since the project is not versioned/shipped yet, prefer canonical API names and avoid preserving aliases as contract. | ✓ |

**User's choice:** Prefer canonical API during development.
**Notes:** User clarified that backward compatibility is not required because there is no versioned application yet. `Theme.colors`, `Theme.icons`, and similar aliases should not be shown as separate token families or treated as long-term requirements.

---

## Component Smoke Coverage

| Option | Description | Selected |
|--------|-------------|----------|
| Existing playground set plus state expansion | Use `MButton`, `MText`, `MInput`, checkbox, radio, switch, select, toast, and dialog; strengthen states/theme-switch proof. | ✓ |
| Token-family gallery focused | Keep component smoke small and focus mostly on palette, typography, spacing, and radius panels. | |
| Full component state matrix | Cover normal/hover/pressed/disabled/focused/loading broadly across components. | |
| Other | Freeform scope. | |

**User's choice:** Existing playground set plus state expansion.
**Notes:** This keeps Phase 5 practical while proving representative runtime consumption.

---

## Manifest Validation Boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Extend existing loader QtTest | Add/clarify cases in `tests/Core/tst_merce_theme_manifest_loader.cpp`. | ✓ |
| Add separate focused validation test | Create a new test file such as `tst_merce_theme_validation.cpp`. | |
| Use C++ test plus QML probe | Test loader behavior in C++ and public behavior through QML. | |
| Other | Freeform test boundary. | |

**User's choice:** Extend existing loader QtTest.
**Notes:** Existing Phase 4 public API invalid/fallback behavior should not be duplicated unless a real gap remains.

---

## Playground Gallery Shape

| Option | Description | Selected |
|--------|-------------|----------|
| Separate `ThemeGallery.qml` route/component | Keep `Main.qml` clean and implement the gallery in a dedicated component/route. | ✓ |
| Expand `Main.qml` as one page | Add gallery sections directly into the existing playground file. | |
| Separate probe and gallery completely | Keep visual gallery and automation probe in separate files. | |
| Other | Freeform layout/route shape. | |

**User's choice:** Separate `ThemeGallery.qml` route/component.
**Notes:** Gallery should include active brand/mode, palette, typography, spacing/radius, representative component states, and stable `objectName` anchors for README screenshots.

---

## Automation Dependency Policy

| Option | Description | Selected |
|--------|-------------|----------|
| No dependency, existing tools only | Use QtTest, CTest, offscreen playground, and scripts only. | |
| Make qmlagent optional but official Phase 5 verifier | Document qmlagent as an optional inspect/debug workflow, not a required CI gate. | ✓ |
| Make Spix opt-in experimental gate | Add Spix behind an off-by-default option such as `MERCE_ENABLE_SPIX_TESTS=ON`. | |
| Other | Freeform dependency policy. | |

**User's choice:** Make qmlagent optional but official Phase 5 verifier.
**Notes:** Spix should not be introduced as a Phase 5 dependency. Mandatory gates remain deterministic local build/test/probe/smoke/gallery runs and README visual artifacts.

---

## the agent's Discretion

- Exact gallery layout details, screenshot script naming, README section placement, and whether the active brand/mode selector is interactive or read-only may follow existing playground patterns.
- The planner may choose the implementation shape for reproducible README-ready visual artifacts.

## Deferred Ideas

- Spix as opt-in UI automation dependency.
- Pixel-perfect visual regression gates.
- Full component-state matrix.
