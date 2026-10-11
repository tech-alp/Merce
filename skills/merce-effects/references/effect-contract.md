# Effect contribution contract

Use this as a review checklist in a design note or PR, not as a new runtime
manifest or an implied automatic validator. Keep answers specific to the effect.

| Question | What to record |
|---|---|
| Intent | Visible outcome and the user interaction that warrants it |
| Host | Supported controls/surfaces and the exact opt-in API |
| Reuse | Why existing tokens, QML drawing or Qt Quick Effects are insufficient |
| Parameters | Public names, types, finite ranges, defaults and units |
| Theme | Semantic color inputs and how state/brand/mode updates reach them |
| Geometry | Size/DPR behavior, corner ordering, border treatment and empty sizes |
| Lifetime | Trigger, duration, completion, interruption and recovery behavior |
| Preferences | How explicit effects/reduced-motion settings are supplied |
| Fallback | Usable output and zero idle animation on unsupported renderers |
| Cost | Passes, source captures, texture reads, affected area and measured device data |
| Packaging | Canonical sources, CMake target, qrc URL and installed usage |
| Provenance | Authored source or upstream source/license/attribution |
| Evidence | Qt version, backend, tests, actual captures and untested devices |

## Sheen reference

The existing implementation uses MSheen in Merce.Effects and a named `sheen`
variation in Merce.Style.Effects. It is one procedural pass, with no source
capture or texture reads. The adapter uses the active style's EffectPolicy,
the button's four corner radii and opacity, and Merce motion tokens. Its neutral
white highlight brightens the theme-provided surface. The primitive's color
property remains available for independently authored tinted effects.
It draws inside the resolved border and applies background opacity to the
overlay without applying it to the base plate a second time.

Only hover entry triggers a sweep. Completion, hover exit, press, disabled or
hidden state, empty dimensions, hidden/minimized window and policy changes
release the shader. Normal buttons, raw StyleKit buttons and flat buttons keep
their own input/content implementation. Parameter ranges and current limitations
are documented in `docs/effects/sheen.md`.

## Qt 6.11 delegate constraint

StyleKit's delegate container calls `beginCreate` with the control context.
A nested Bound component defined by a style is rejected in that different
context; Qt 6.11.1's release implementation then dereferences a null delegate.
An Unbound factory avoids that rejection, but outer style IDs are also absent
in the control context. Keep the factory capture-free and put typed active-style
policy lookup in the separate delegate type. Do not remove Bound everywhere:
the Loader inside SheenBackground correctly retains its component context.

StyleKit's attached API uses one active style for the application in Qt 6.11.
Reading `StyleKit.style` follows that active style; it does not establish local
style or motion-policy scopes per window.

The module-loading regression test exists to catch this real startup failure.
Do not delete it after a successful rendering preview. Native source evidence:
[delegate container](https://github.com/qt/qtdeclarative/blob/v6.11.1/src/labs/stylekit/impl/qqstylekitdelegatecontainer.cpp),
[object creation](https://github.com/qt/qtdeclarative/blob/v6.11.1/src/qml/qml/qqmlobjectcreator.cpp),
[Loader](https://github.com/qt/qtdeclarative/blob/v6.11.1/src/quick/items/qquickloader.cpp),
and [StyleKit attached API](https://github.com/qt/qtdeclarative/blob/v6.11.1/src/labs/stylekit/qqstylekit.cpp).
