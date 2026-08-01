# Merce.Style token mapping

This document is the contract between the AlGit token vocabulary and
`Qt.labs.StyleKit`. `MerceStyle.qml` is the only place where brand/profile
tokens become StyleKit delegate values. Controls consume the resulting style;
they do not calculate theme colours themselves.

## State resolution

StyleKit state slots contain final colours. They do not composite a state
layer. `MerceStyle.qml` therefore resolves the AlGit state-layer model before
assigning each slot:

```qml
Qt.tint(container, Qt.alpha(content, Theme.state.layer.<state>))
```

The base `container` is opaque, so this source-over operation produces the
opaque colour StyleKit needs. It remains a live QML binding: a brand, mode or
profile switch re-evaluates the same `Style` object. Qt 6.11 repaints existing
controls for colour changes.

This composition belongs in `Merce.Style`, rather than in generated brand
manifests, because hover/focus/press are interaction policy, not additional
brand roles. It also does not belong in each control because that would
duplicate policy and recreate the retired hand-written state machines.

`MerceStyle` pins StyleKit's own `themeName` to `"Light"`. This does not select
Merce light mode: `Merce.Theme` remains the only brand/mode/profile authority.
The pin creates StyleKit's required empty theme even when the platform reports
an unknown color scheme (notably the offscreen test platform), and prevents a
second OS-driven theme axis from competing with Merce runtime context.

The six StyleKit slots have one shared meaning:

| StyleKit state | Resolved value |
|---|---|
| `hovered` | `container + content @ Theme.state.layer.hover` |
| `focused` | `container + content @ Theme.state.layer.focus`; border becomes `colors.outline.focus` with `size.outline.focus` width |
| `pressed` | `container + content @ Theme.state.layer.pressed` |
| `checked` | `container + content @ Theme.state.layer.selected` |
| `highlighted` | same selected layer as `checked` |
| `disabled` | background is `container + content @ disabled.containerOpacity`; text/foreground is then `disabled background + content @ disabled.contentOpacity` |

`checked` controls may additionally change semantic channels: checked
check/radio/switch indicators use `action.primary`, then `highlighted` applies
the selected layer. States unsupported by a concrete StyleKit implementation
remain defined by this policy but are never selected by that implementation.
StyleKit resolves simultaneous states through nested branches, so checkable
controls also define `disabled.checked`: the disabled composition is applied
to the checked semantic container/content pair. Defining only sibling
`disabled` and `checked` slots would leave a disabled checked control in its
active checked colours.

## Profile geometry and typography

Control geometry is profile-owned. No brand manifest may set it.

Profile values are live on `MerceStyle`, but Qt 6.11.1 does not propagate
every changed implicit-size property to an already-created control. The
runtime test records the concrete Switch failure as an expected failure:
`switchControl.background.implicitHeight` changes from cart to ops while the
existing Switch's `implicitBackgroundHeight` remains at cart. A hot profile
switch therefore requires recreating/reassigning the StyleKit style (or
recreating the affected controls) until Qt exposes a reliable reader reset.
Normal brand/mode colour switches do not require recreation.

| Profile | `control.small` | `control.medium` | `control.large` |
|---|---:|---:|---:|
| `cart` | 64 | 72 | 80 |
| `maintenance` | 48 | 56 | 64 |
| `ops` | 40 | 48 | 56 |

- Default interactive height: `size.control.medium`.
- `small`/`large` variations: `size.control.small`/`size.control.large`.
- Item delegate minimum height: `size.control.minimum`.
- Button radius: `radius.button`; input/select: `radius.input`; popup:
  `radius.dialog`; check/radio/decorative tracks use `radius.small` or
  `radius.full`.
- Normal border: `size.outline.hairline`; focus border:
  `size.outline.focus`. Borderless channels explicitly use `0`.
- Padding/spacing comes from the active profile's `spacing` tokens.
- Popup has no global padding because Qt 6.11 ComboBox fixes its popup height
  to the content implicit height without adding padding. Item delegates own
  the profile inset; standalone popups may override padding.
- Fonts use `typography.fontBody`, `sizeMedium`/`sizeSmall`,
  `weightRegular`/`weightSemibold`. `Font.MixedCase` is explicit; Merce.Style
  performs no automatic Turkish or other case conversion.
- State colour transitions use `motion.durationFast` and `motion.easingOut`.

## Bound controls

The tables name every rendered StyleKit delegate channel that Merce binds.
“None” is deliberate, not an omitted mapping.

### ApplicationWindow

| Channel | AlGit source |
|---|---|
| `background.color` | `colors.surface.canvas` |
| `background.border` | none; width `0` |
| `background.shadow` | none; disabled |
| `text` | not rendered by this StyleKit type |

### Button

| Variation | `background.color` | `text.color` | `background.border.color` |
|---|---|---|---|
| default | `action.primary.container` | `action.primary.content` | `action.primary.outline` |
| `secondary` | `action.secondary.container` | `action.secondary.content` | `action.secondary.outline` |
| `destructive` | `action.destructive.container` | `action.destructive.content` | `action.destructive.outline` |
| `outline` | `surface.container` | `action.primary.container` | `action.primary.outline` |
| `ghost` | transparent `surface.container` | `action.primary.container` | none; width `0` |

All five semantic variants resolve all six states using their row's container/content.
`loading` is a structural variation: it keeps the selected semantic variant,
reduces `background.opacity` to `0.72`, and resolves text through the disabled
content helper. It does not draw a spinner.
No button shadow is allowed: a static action surface is not a depth boundary.
StyleKit's native icon receives the resolved `text.color`.

### ComboBox

| Channel | AlGit source |
|---|---|
| `background.color` | `surface.container` |
| `text.color` | `content.primary` |
| `background.border.color` | `outline.subtle`; focus uses `outline.focus` |
| `indicator.image.color` | `content.secondary` |
| `indicator.color/border` | transparent/none; the native drop indicator remains |

All six states use `surface.container` + `content.primary`. The associated
popup, delegate and scroll indicator are separate mappings below.

### Popup

| Channel | AlGit source |
|---|---|
| `background.color` | `surface.floating` |
| `background.border.color` | `outline.subtle` |
| `background.shadow.color` | `surface.shadow` |
| shadow geometry/opacity | first layer of existing semantic `Theme.shadows.dropdown` |
| `text` | not rendered by Popup itself |

Only floating/transient surfaces may use this shadow. It is allowed by the
three depth limits because it communicates a real overlay boundary, is one
measured shadow on a popup (not per delegate), and does not blur a full
viewport. Disabled popup background follows the common disabled composition.

`surface.shadow` is the one new AlGit role. Promotion is justified now because
the same semantic colour has a second renderer: StyleKit popup shadows and
the surviving reusable elevation/preview renderers. Light and dark require
different resolved values, so a fixed literal or profile token is incorrect.

### ItemDelegate

| Channel | AlGit source |
|---|---|
| `background.color` | `surface.floating` |
| `text.color` | `content.primary` |
| `background.border` | none; width `0`, focus temporarily uses `outline.focus` |

All six states use `surface.floating` + `content.primary`. Delegates never cast
individual shadows.

### ScrollBar

| Channel | AlGit source |
|---|---|
| `background` | hidden |
| `indicator.foreground.color` | `outline.strong` |
| indicator border | none |

The thumb (StyleKit calls it `indicator.foreground`) resolves all six states
with `outline.strong` as container and `content.primary` as the layer colour.

### ScrollIndicator

| Channel | AlGit source |
|---|---|
| `background` | hidden |
| `indicator.foreground.color` | `outline.strong` |
| indicator border | none |

Qt 6.11 ComboBox uses `ScrollIndicator`, not `ScrollBar`, for its popup.
Horizontal thickness and the `vertical` state's width come from
`size.outline.strong * 2`. The thumb resolves the same six state slots as
ScrollBar; the current StyleKit implementation selects enabled, focused,
hovered and vertical.

### TextField

| Channel | AlGit source |
|---|---|
| `background.color` | `surface.container` |
| `text.color` | `content.primary` |
| `background.border.color` | `outline.subtle`; focus uses `outline.focus` |
| placeholder palette | `content.tertiary` |
| selection palette | `action.primary.container/content` |
| `success`/`warning`/`error` border | matching `status.<name>.outline` |

All six states use `surface.container` + `content.primary`. Validation
variations keep their semantic outline when focused and use focus border
width. StyleKit provides the native text-input keyboard and accessibility
contract.

### CheckBox

| Channel | AlGit source |
|---|---|
| outer `background` | hidden |
| `indicator.color` | `surface.container` |
| `indicator.border.color` | `outline.strong` |
| checked indicator/foreground | `action.primary.container/content` |
| `text.color` | `content.primary` |

The common six states apply to the indicator and label. The
`indeterminate` variation replaces StyleKit's checked image with a rounded
`action.primary.content` dash on `action.primary.container`; consumers pair it
with native `tristate`/`PartiallyChecked`. The variation repeats hover, focus,
press, checked/highlighted and disabled indicator branches because a variation
normal value otherwise outranks base-style state values in StyleKit's
property-by-property resolver.

### RadioButton

| Channel | AlGit source |
|---|---|
| outer `background` | hidden |
| `indicator.color` | `surface.container` |
| `indicator.border.color` | `outline.strong`; checked uses `action.primary.outline` |
| `indicator.foreground.color` | `action.primary.container` |
| `text.color` | `content.primary` |

All six states use the surface/content state policy; the checked dot remains
the primary action colour.

### Switch

| Channel | AlGit source |
|---|---|
| outer `background` | hidden |
| `indicator.color` (track) | `surface.containerSunken`; checked uses `action.primary.container` |
| `indicator.border.color` | `outline.subtle` |
| `handle.color` | `content.secondary`; checked uses `action.primary.content` |
| `text.color` | `content.primary` |

All six states apply to the active track/container pair. Disabled track,
handle and label each use the disabled composition. Track height is
`size.icon.medium`, handle size is `size.icon.small`, and the hidden
background supplies the outer `size.control.medium` height with zero vertical
padding. This keeps non-zero handle travel in the compact `ops` profile.

### ProgressBar

| Channel | AlGit source |
|---|---|
| outer `background` | hidden |
| `indicator.color` (track) | `surface.containerSunken` |
| `indicator.foreground.color` (progress) | `action.primary.container` |
| borders/text | none |

Only `disabled` is selected by the current StyleKit implementation; the other
five state slots follow the common policy but have no runtime selector here.

### Slider

| Channel | AlGit source |
|---|---|
| outer `background` | hidden |
| `indicator.color` (track) | `surface.containerSunken` |
| `indicator.foreground.color` (filled track) | `action.primary.container` |
| `handle.color` | `action.primary.container` |
| `handle.border.color` | `action.primary.outline`; focus uses `outline.focus` |
| text | not rendered |

All six states resolve on the handle. Disabled also resolves the filled track.

### Label

| Channel | AlGit source |
|---|---|
| `background` | hidden |
| `text.color` | `content.primary`; disabled uses `content.disabled` |
| text border/shadow | not rendered by StyleKit Label |

Label exposes only focused/enabled state to its StyleReader; hover, press,
check and highlight have no runtime selector.

## StyleKit channels with no AlGit role

| StyleKit channel | Decision |
|---|---|
| `gradient` on every delegate | left unset/`null`; DESIGN.md forbids gradients |
| arbitrary `image.source` and `image.fillMode` | StyleKit default asset; these are content/implementation choices, not semantic colour roles |
| unused `image.color` channels | StyleKit default; only combo/check/native icons map to an existing content role |
| `delegate` and `data` | left unset; no custom renderer is needed |
| `visible`, `scale`, `rotation`, `clip` | structural StyleKit defaults; visibility is changed only to suppress a delegate a concrete control does not render |
| per-corner radii | StyleKit default to the mapped common `radius` |
| delegate `opacity` | left at `1`; state opacity is pre-composited into colour, not applied to a whole delegate |
| text background/border/shadow | StyleKit controls render text directly and do not consume these delegate channels |
| non-popup shadow geometry | shadow disabled; no depth boundary |
| popup shadow opacity/scale/offset/blur/visible/delegate | opacity/offset/blur come from existing `Theme.shadows.dropdown`; scale remains `1`, visibility is structural, custom delegate stays unset |
| implicit/minimum widths and heights, alignment, margins | active profile tokens or structural values; no brand role added |
| unused QPalette roles (`base`, `button`, visited link, tooltip and 3D shade roles) | inherit StyleKit/system fallback; bound controls either use delegate colours or the explicitly mapped text/selection roles |
| `light`, `dark`, custom themes and fallback-style plumbing | no brand role; `themeName: "Light"` only bootstraps one StyleKit axis while `Merce.Theme` owns mode |

No role is promoted for a single unused channel. That follows the promotion
rule: the second real consumer, not a theoretical StyleKit property, triggers
promotion.

## AlGit roles with no StyleKit channel

The following roles are intentionally not consumed by `Merce.Style`:

- `identity.mark`: product identity/content, not a control delegate channel.
- `surface.containerRaised`, `surface.containerTinted`, `surface.scrim`,
  `surface.inverse`: page/card/modal composition remains in custom/application
  items.
- `content.inverse`: no bound StyleKit control is placed on the inverse
  surface by this module.
- `status.success|warning|error.container/content`: validation currently needs
  only the outline channel.
- all three channels of `status.info` and `status.neutral`: no bound control
  variation consumes them.
- radius `none`, `large`, `xlarge`, `xxlarge`, `card`, `badge`, `tooltip`:
  card/badge/tooltip remain custom/application surfaces.
- spacing tokens other than `xxs`, `xs`, `md`, `xl`, `xl2`: layout remains an
  application/Foundation responsibility.
- typography roles other than body/button family, size and weight primitives:
  headings, price, caption, mono and display roles are content hierarchy, not
  generic control chrome.
- icon sizes not selected by a concrete delegate remain available to custom
  items; StyleKit Button and ItemDelegate also hard-code native icon sizes.
- motion roles other than the shared fast colour transition: popup/layout and
  control-specific motion remains with the owning control. StyleKit Switch and
  ProgressBar currently contain internal hard-coded durations.

`MBadge` and `LoadingIndicator` therefore remain custom `Merce.Controls`
items and read the roles relevant to them directly from `Merce.Theme`.
