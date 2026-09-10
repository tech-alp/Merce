pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Merce.Theme as MerceRuntime

/**
 * MShadow - renders a Theme.shadows.* token as real elevation.
 *
 * The token is a list of shadow layers
 * ({ xOffset, yOffset, blur, spread, opacity }),
 * while RectangularShadow draws a single layer, so the token cannot be spent
 * directly and every call site ends up hand-writing blur/color/offset numbers.
 * This stacks one RectangularShadow per layer instead.
 *
 * Use it as a SIBLING of the surface, never a child: surfaces that clip (any
 * card with rounded corners and clipped content) clip a child shadow away, so
 * the shadow either vanishes or smudges the inner edge.
 *
 *   MShadow {
 *       anchors.fill: card
 *       layers: Theme.shadows.dialog
 *       surfaceRadius: card.radius
 *       surfaceColor: card.color
 *   }
 *   Rectangle { id: card; radius: Theme.radius.dialog; clip: true }
 *
 * Pass the token itself rather than a role name: Theme.shadows is a C++ type
 * with FINAL properties, so qmllint catches a misspelled role, which a string
 * lookup would swallow.
 */
Item {
    id: root

    /** A Theme.shadows.* token. Empty or unset renders nothing. */
    property var layers: []

    /** Corner radius of the surface being shadowed. */
    property real surfaceRadius: 0

    /** Fill colour of the surface. Used to derive the dark-mode highlight. */
    property color surfaceColor: MerceRuntime.Theme.colors.surface.containerRaised

    /**
     * Enables the subtle dual-shadow treatment intended for dark surfaces.
     * Disable it for light/inverse surfaces shown inside a dark theme.
     */
    property bool darkSurfaceTreatmentEnabled: MerceRuntime.Theme.activeMode === "dark"

    /**
     * Shadow hue. Layers carry geometry and opacity only, so the colour comes
     * from the theme and follows a light/dark switch on its own.
     */
    property color shadowColor: MerceRuntime.Theme.colors.surface.shadow

    /** Dark surfaces need stronger occlusion against their low-luminance canvas. */
    property real darkShadowOpacityScale: 1.6

    /** Surface-relative highlight inspired by Qt's NeumorphicPanel example. */
    property color highlightColor: Qt.lighter(root.surfaceColor, 1.25)
    property real highlightOpacity: 0.24

    readonly property var _highlightLayer: root.layers && root.layers.length > 0
                                           ? root.layers[0]
                                           : null
    readonly property real _shadowOpacityScale: root.darkSurfaceTreatmentEnabled
                                                ? root.darkShadowOpacityScale
                                                : 1.0
    readonly property real _highlightOffset: {
        if (!root._highlightLayer)
            return 0
        return Math.max(1, Math.min(6, Math.abs(root._highlightLayer.yOffset) * 0.4))
    }

    // Behind the surface it belongs to, whatever the declaration order is.
    z: -1

    Repeater {
        model: root.layers

        RectangularShadow {
            required property var modelData

            anchors.fill: parent
            blur: modelData.blur
            spread: modelData.spread
            offset.x: modelData.xOffset
            offset.y: modelData.yOffset
            color: Qt.alpha(root.shadowColor,
                            Math.min(1.0, modelData.opacity * root._shadowOpacityScale))
            radius: root.surfaceRadius
        }
    }

    RectangularShadow {
        anchors.fill: parent
        visible: root.darkSurfaceTreatmentEnabled && Boolean(root._highlightLayer)
        blur: root._highlightLayer ? root._highlightLayer.blur : 0
        spread: root._highlightLayer ? root._highlightLayer.spread : 0
        offset: Qt.vector2d(-root._highlightOffset, -root._highlightOffset)
        color: Qt.alpha(root.highlightColor, root.highlightOpacity)
        radius: root.surfaceRadius
    }
}
