# Effects in Merce

Merce connects a reusable visual effect to the theme, control states and build
system that a QML application already uses. The first effect is a **sheen**:
a single diagonal sweep across a button when the pointer enters it.

The supported consumption path is ordinary QML and CMake. Applications do not
need an AI account, an editor plugin, JavaScript packages or a runtime shader
compiler. AI can help contributors author and verify the source files.

## Use an effect

Link `Merce::StyleEffects` and `Merce::Controls` in a source or installed-package
consumer, then select the extended style on a StyleKit application window:

```qml
import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Controls
import Merce.Style.Effects

SK.ApplicationWindow {
    width: 640
    height: 360
    visible: true

    SK.StyleKit.style: MerceEffectsStyle {
        id: applicationStyle
        effectPolicy.enabled: true
        effectPolicy.reducedMotion: false
    }

    MButton {
        anchors.centerIn: parent
        text: qsTr("Continue")
        variant: MButton.Secondary
        extraVariations: ["sheen"]
    }
}
```

Raw `Qt.labs.StyleKit.Button` also works with
`SK.StyleVariation.variations: ["sheen"]`. Both normal and `flat: true` buttons
are covered. The variation does not target check boxes, radio buttons or every
`AbstractButton` subtype. It changes only the background delegate: existing
button content, loading presentation, actions and keyboard focus remain owned
by the control.

`MerceStyle` remains available independently. Selecting `MerceEffectsStyle`
does not apply a sheen to every button; each caller chooses its variations.
Qt 6.11 uses one active StyleKit style for the application; the adapter follows
that active style's policy rather than introducing per-window style scopes.
See the [sheen reference](effects/sheen.md) for the primitive and lifecycle.

## Where the code belongs

| Path | Responsibility |
|---|---|
| `Effects/MSheen.qml` | Property-driven rendering primitive; no interaction or animation |
| `Effects/shaders/sheen.frag` | Canonical GLSL source |
| `Effects/CMakeLists.txt` | Qt ShaderTools build and qrc packaging |
| `Style/Effects/MerceEffectsStyle.qml` | Registers the named StyleKit variation |
| `Style/Effects/SheenBackground.qml` | Resolves theme/state/geometry and owns sweep lifetime |
| `Style/Effects/EffectPolicy.qml` | Explicit application preferences |
| `playground/view/EffectsShowcase.qml` | Real consumer examples and a static scrubber |
| `tests/Effects/` | Fallback, composition, interaction, lifecycle and pixel checks |
| `skills/merce-effects/` | Provider-independent contribution workflow |

Do not put interaction handlers into a drawing primitive. A future card, badge
or panel adapter can reuse a primitive while keeping its own state and policy.
Prefer existing QML drawing or Qt Quick Effects when they solve the request.
Custom GLSL is useful when it provides a visual result that those tools do not
express simply.

## Build and distribution

The baseline remains CMake 3.30, C++20 and Qt 6.11. Source builds now also require
the matching **Qt ShaderTools** tools. `qt_add_shaders` bakes the fragment shader
and embeds it at:

```text
qrc:/qt/qml/Merce/Effects/shaders/sheen.frag.qsb
```

Generated `.qsb` files stay in the build directory. The absolute resource URL
works after installation as well as in a source build. The installed CMake
package does not add ShaderTools as a consumer dependency; it distributes the
already-baked resource with Merce.Effects.

`MERCE_BUILD_STYLE_EFFECTS` defaults to `ON`. Setting it to `OFF` removes the
adapter target, its QML module, tests and playground page. `MSheen` still belongs
to `Merce.Effects`, so turning the adapter off does not remove the ShaderTools
source-build requirement. Notifications and token generation remain separate
options.

The `.qsb` contains shader variants for Qt's supported graphics APIs, but baking
is not proof that an effect behaves identically on every device. The initial
pixel gate exercises OpenGL RHI through Mesa; other APIs and target hardware
need their own verification before a product promises support or performance.
Qt Quick's software renderer retains the normal StyledItem background without
creating or animating MSheen.

## Author with AI

Use [the repository skill](../skills/merce-effects/SKILL.md) with an assistant
that can read/edit the repo and run Qt tooling. A useful request is concrete:

> Add a subtle one-shot light sweep to secondary buttons. Preserve the loading
> state, rounded corners and keyboard focus. Respect the application's motion
> preference. Show it in the real playground and verify source/package usage.

The assistant should first select an existing primitive or decide whether a
new shader is warranted. It then defines bounded parameters, chooses semantic
theme inputs, writes canonical QML/GLSL, integrates the build, and collects
evidence from the actual Qt components. A reviewer can inspect the resulting
code, screenshots and test results in a normal PR. The
[effect contract](../skills/merce-effects/references/effect-contract.md) records
the questions that each contribution must answer.

This milestone ships that workflow and a complete reference effect. It does
not ship a prompt-to-shader service, a node editor, an AI runtime or an automated
visual quality judge. Generated code still needs compilation, behavior tests
and visual review. An image mockup is a design reference, not evidence that a
Qt shader renders correctly.

## Qt Quick Effect Maker and external shader examples

[Qt Quick Effect Maker](https://doc.qt.io/qt-6.11/qtquickeffectmaker-index.html)
can be an optional authoring tool. Its editable `.qep` project and exported
QML/shader assets are distinct artifacts. A contributor using it should retain
the authoring source, commit the reviewed exported sources appropriate to the
effect, and register resources in CMake. The application should consume the
exported effect without requiring the editor. There is no automatic `.qep`
import/export pipeline in Merce today; sheen is handwritten QML/GLSL.

Web shader collections, including
[shader-effects-inc/shaders](https://github.com/shader-effects-inc/shaders),
can provide visual references. A browser component or its renderer is not a
drop-in QML component. Any port must adapt uniforms, alpha handling, coordinates,
resources and state/lifetime to Qt, and preserve the original license and
attribution when reusing source. This sheen adds no dependency on that project.

## Verify a contribution

For the ordinary software-backed regression suite:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 2
cmake --build build --target MerceEffects_qmllint MerceStyleEffects_qmllint
ctest --test-dir build --output-on-failure
```

The two rendering cases explicitly skip when no shader-capable renderer is
active. To require those cases on a Linux host with Xvfb and Mesa OpenGL:

```sh
cmake -S . -B build -DMERCE_TEST_EFFECTS_RENDERING=ON
xvfb-run -a env QT_QPA_PLATFORM=xcb QT_QUICK_BACKEND=rhi \
  QSG_RHI_BACKEND=opengl LIBGL_ALWAYS_SOFTWARE=1 \
  ctest --test-dir build -R '^tst_merce_effects_rendering$' --output-on-failure
```

This separate CTest fails if it falls back to the software renderer. On a
desktop, use the appropriate working RHI backend instead of Xvfb/Mesa. Check
alpha blending, independent corners, narrow sizes and finite sweep interruption.

For playground changes, use the existing full-build instructions in the
[README](../README.md), run `MercePlayground_qmllint`, then run
`skills/merce-playground-verification/scripts/run-gates.sh` with the default
`MERCE_TEST_EFFECTS_RENDERING=OFF`; the separate graphics gate covers pixels.
Inspect the Effects page in at least two brands, light and dark, and desktop
and compact layouts. Source and installed-package consumers must also load the
adapter and its qrc shader without source-directory resource paths.

Primary Qt references: [ShaderEffect](https://doc.qt.io/qt-6.11/qml-qtquick-shadereffect.html),
[ShaderTools CMake integration](https://doc.qt.io/qt-6.11/qtshadertools-build.html),
[StyledItem](https://doc.qt.io/qt-6.11/qml-qt-labs-stylekit-styleditem.html), and
[GraphicsInfo](https://doc.qt.io/qt-6.11/qml-qtquick-graphicsinfo.html).
