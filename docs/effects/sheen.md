# Sheen

## Button variation

Select `MerceEffectsStyle` from `Merce.Style.Effects`, then set
`MButton.extraVariations: ["sheen"]`. The equivalent raw StyleKit button uses
`StyleVariation.variations: ["sheen"]`.

The background remains a StyleKit `StyledItem`. Its resolved fill, border,
implicit dimensions, transforms and loading opacity remain in place. The
overlay takes its color from the button's resolved text color and is inset by
the border width, keeping the focus border clear. Corner radii are passed
individually, with the inset subtracted. MButton's variant, size and loading
variations retain their usual priority.

| Event or condition | Result |
|---|---|
| Hover enters an eligible button | One sweep using `Theme.motion.durationSlower` and `easingDefault` |
| Sweep finishes while hover remains | Shader instance is released; no loop |
| Hover exits or the button is pressed | Sweep stops and shader instance is released |
| Button becomes disabled, hidden or zero-sized | Sweep stops |
| Window becomes hidden or minimized | Sweep stops |
| `effectPolicy.enabled` becomes false | Sweep stops; normal background stays |
| `effectPolicy.reducedMotion` becomes true | Sweep stops; normal background stays |
| Unsupported, software, unknown or null renderer | Normal background; no shader instance or animation |
| Policy is restored or press is released while still hovered | Wait for the next hover entry |
| A hidden control or window reappears under the pointer | Qt may produce a new hover entry, which can start a new sweep |

The policy values are application settings and can be bound to the application's
preferences. Merce does not detect the operating system's motion preference in
this release. Touch-only use retains normal press feedback; sheen communicates
no essential state. Loading does not change the button's existing activation
semantics. Decorative items do not handle input or add accessible controls.
The adapter respects the control's `hoverEnabled` setting. Qt's platform
defaults can disable hover; applications can explicitly enable it on pointer
controls. Flat backgrounds are created lazily by StyleKit on their first hover.

## Primitive: `Merce.Effects.MSheen`

The primitive draws a procedural band. It does not capture another item,
allocate a source texture, animate itself or inspect application preferences.
Callers own its creation, visibility, progress and fallback.

| Property | Default | Meaning |
|---|---:|---|
| `color` | white | Tint, including alpha; Qt supplies a premultiplied color uniform |
| `progress` | 0 | Sweep position; shader clamps to 0–1, both endpoints are transparent |
| `intensity` | 0.28 | Opacity multiplier, clamped to 0–1 |
| `bandWidth` | 0.24 | Width relative to the surface; clamped to 0–1 with a one-logical-pixel minimum |
| `radius` | 0 | Default logical corner radius |
| `topLeftRadius`, `topRightRadius`, `bottomRightRadius`, `bottomLeftRadius` | `radius` | Independent overrides; clamped to 0 through half the shorter dimension |

Size follows the QML item's width and height. The shader guards empty dimensions
and uses screen device pixel ratio to soften the inside edge by approximately
one physical pixel. Use finite numeric inputs. Multiplying the premultiplied
color by coverage and `qt_Opacity` preserves normal source-over blending and
the QML item's inherited opacity.

For a static, shader-capable preview:

```qml
import QtQuick
import Merce.Effects
import Merce.Theme

Rectangle {
    id: surface
    width: 280
    height: 80
    radius: Theme.radius.large
    color: Theme.colors.action.primary.container

    MSheen {
        anchors.fill: parent
        color: Theme.colors.action.primary.content
        radius: surface.radius
        progress: 0.5
    }
}
```

Applications supporting software rendering should create a primitive through a
conditional Loader only when a supported RHI backend is available. The StyleKit
adapter handles that policy for buttons. See the real Effects playground page
for a conditional static preview that also supports manual scrubbing.

## Cost and limitations

Sheen uses one procedural fragment pass with no source capture or texture
sampling. The button adapter creates it only during a sweep. This is a design
bound, not a measured frame-time guarantee: large surfaces, many simultaneous
effects, overdraw and the target GPU still matter. Profile on the devices you
intend to support. This release does not implement background blur, glass,
multi-pass effects or automatic quality scaling.

Qt ShaderTools produces the backend shader variants at build time. The required
RHI test checks source-over alpha, item opacity, transparent endpoints, corner
masking and the sweep's finite lifetime. Software-backed tests check normal
button appearance, theme switching, variant/loading composition and input.
