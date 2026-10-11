# StyleKit sheen effect

## Goal

Deliver the first end-to-end effect discussed with the maintainer: a theme-aware
button sheen selected with `MButton.extraVariations: ["sheen"]`, shipped through
normal source and installed-package consumption. The maintainer authorized
implementation and a pull request on 2026-10-11.

## Boundaries

- Keep CMake 3.30, C++20, and Qt 6.11 as the explicit baseline.
- Preserve `MButton` behavior and the existing `MerceStyle` appearance.
- Extend `Merce.Effects`; add the opt-in `Merce.Style.Effects` QML module and
  matching `Merce::StyleEffects` CMake alias. Base controls and styles never
  import the adapter module.
- `MERCE_BUILD_STYLE_EFFECTS` defaults to ON so the installed package exposes
  the advertised adapter. OFF omits its target, QML files, examples and tests;
  the normal Merce controls still build. ShaderTools is a build-tool requirement
  for `Merce.Effects`, independent of this option.
- Do not change token manifests, notification behavior, or existing control
  interaction. Node, QQEM, AI providers and qmlagent remain optional tools.

## Interfaces and behavior

`Merce.Effects.MSheen` is a decorative ShaderEffect with color, progress (0..1),
intensity (0..1), bandWidth (relative width), radius and four corner overrides.
It uses logical item coordinates and device-pixel-ratio-aware antialiasing.
The shader uses premultiplied alpha, clamps dimensions/parameters, and needs no
source capture. It does not animate or handle input itself.

`Merce.Style.Effects.MerceEffectsStyle` extends `MerceStyle`. Its `sheen`
StyleVariation replaces only a button's background delegate. `SheenBackground`
extends `StyledItem`, preserving the resolved plate, border, sizing, opacity,
and transforms. It passes resolved geometry and opacity to MSheen. The neutral
white highlight brightens the theme-provided surface; it does not inherit a
dark text color that would turn the sheen into a shadow.

`EffectPolicy` exposes `enabled` (true) and `reducedMotion` (false).
`MerceEffectsStyle.effectPolicy` owns the policy instance. These are explicit
application settings; automatic OS preference detection is outside this change.

Hover starts one finite sweep using a Merce motion duration. It is stopped and
the shader is unloaded on hover exit, press, disable, hidden control/window,
disabled effects or reduced motion. Software/unknown/null renderers keep the
normal StyledItem without creating a ShaderEffect. Finishing a sweep does not
loop while hover stays true. Existing loading, click and keyboard-focus behavior
must continue to work. Decorative items are ignored by accessibility.

## Authoring and distribution

Handwritten QML/GLSL are canonical. `qt_add_shaders` builds the qsb into a stable
qrc path in MerceEffects; generated qsb files are not committed. Installed
consumers resolve that same resource after importing the module. Documentation
also explains QQEM's separate qep/export workflow without adding an editor or
runtime compiler. A repository skill guides selection, authoring and evidence
collection using the existing verification workflow.

## Playground and verification

Add an Effects page with normal/disabled/loading buttons, variant and geometry
examples, policy toggles, and a manually scrubbed primitive preview. Use the real
QML components and existing theme controls. When the adapter is disabled, omit
the Effects page and retain MerceStyle.

Tests must cover module/resource availability, software fallback, two brands in
light/dark, size/variant/loading preservation, clicks and keyboard focus. A
separate rendering test checks actual pixels, corner masking and finite sweep
lifetime when a suitable graphics backend is available. Report unavailable
rendering validation explicitly rather than equating software CTests with GPU
verification. Source and installed-package consumers cover the new alias,
module import and shader resource. Run the existing playground gates and a
fresh whole-branch review before finishing the PR.
