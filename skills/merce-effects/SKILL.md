---
name: merce-effects
description: Author, adapt, review, or verify Qt Quick shader effects and StyleKit variations in the Merce repository. Use for requests such as adding a sheen to a button, creating a theme-aware material for a component, porting a web shader to QML, or preparing an effect contribution with fallback and rendering evidence.
---

# Merce Effects

Treat AI as a development assistant. Deliver ordinary reviewed QML/GLSL sources,
CMake integration, examples and verification; add no AI provider to the runtime.

## Establish the contract

1. Read the repository's `AGENTS.md`, `docs/effects.md`, and the affected
   control/style before editing. Use `.agents/skills/qt-qml/SKILL.md` for QML
   conventions and `skills/merce-playground-verification/SKILL.md` for gates.
2. Inspect `Effects/` and `Style/Effects/` for reusable primitives or adapters.
   Prefer tokens, StyleKit properties, ordinary QML or Qt Quick Effects when
   they suffice. Do not create a shader merely because the request says
   “polished”, “glass” or “modern”.
3. Fill the contribution contract in
   [references/effect-contract.md](references/effect-contract.md). Resolve
   material ambiguities; make routine implementation choices from repo context.
4. For imported source, identify its license and required attribution before
   copying it. A screenshot/reference does not make a browser shader QML-ready.

## Implement

- Keep rendering in `Effects/M<Name>.qml` and
  `Effects/shaders/<name>.frag`. Reuse `MSheen` when only its parameters differ.
- Bind semantic colors, resolved corners, state and animation lifetime in a
  `Style/Effects/` adapter. Preserve the host's layout, text, loading, focus and
  input. Do not add a MouseArea to a decorative effect or replace MButton behavior.
- Keep the StyleKit delegate factory **Unbound and free of outer-ID captures**
  on Qt 6.11. StyleKit creates it in the control's context. Resolve the active
  style's typed policy inside the separate delegate QML file, as
  `SheenBackground.qml` does. Its own Bound pragma and Loader are appropriate.
- Treat StyleKit's active style as application-global in Qt 6.11; do not promise
  independent window policies. Keep EffectPolicy preferences explicit.
- Use finite animations unless the design requires ambient motion. Stop and
  release work on exit, press, disable, hidden/zero-sized surfaces and motion
  policy changes. Avoid replay when merely recovering from an interruption.
- Compile Vulkan-compatible GLSL with `qt_add_shaders`. Match ShaderEffect's
  uniform layout, premultiplied color, `qt_Opacity`, logical geometry and DPR.
  Bound numeric inputs and guard zero dimensions.
- Use a stable qrc URL and leave generated qsb files in the build directory.
  Do not introduce a runtime shader compiler or a source-directory file path.
- Keep a usable fallback and avoid creating a ShaderEffect on software,
  unknown, null or unsupported renderers.
- Add the real component to the playground and update navigation/probes/exports.
  Preserve an adapter-OFF build; do not leave unconditional optional imports.

## Verify and deliver

Run commands from the repository root using its supported Qt kit.

1. Build the changed targets and run meaningful regression checks with CTest.
   Cover opt-in/normal appearance, two brands in light/dark, variant/size/loading
   composition and mouse/keyboard semantics.
2. Run `MerceEffects_qmllint`, `MerceStyleEffects_qmllint` and, for playground
   changes, `MercePlayground_qmllint`.
3. Run the existing playground gates with the rendering-test option OFF. Follow
   `docs/effects.md` to run the separate required RHI rendering CTest.
   Software CTest success or qsb compilation does not prove shader pixels.
4. Inspect actual shader output, alpha, independent corners, finite animation
   and interruptions. Inspect compact/desktop layouts and theme variants.
   Report unavailable APIs/hardware honestly; do not label mockups as captures.
5. Verify source and installed-package consumers, including the resource URL
   after installation. Configure `MERCE_BUILD_STYLE_EFFECTS=OFF` and verify the
   ordinary controls/playground still load.
6. Update the effect reference, README and CHANGELOG. Describe the problem,
   resulting behavior, evidence and remaining limits in the requested PR.
   Follow the user's authorization for branch publication and PR creation.

Keep provider/editor tooling optional. If using Qt Quick Effect Maker, retain
the editable .qep and reviewed exported sources; document that authoring route
instead of inventing a Merce .qep importer.
