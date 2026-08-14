import QtQuick
import QtQuick.Effects

/**
 * MShadow - renders a Theme.shadows.* token as real elevation.
 *
 * The token is a list of shadow layers ({ xOffset, yOffset, blur, color }),
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

    // Behind the surface it belongs to, whatever the declaration order is.
    z: -1

    Repeater {
        model: root.layers

        RectangularShadow {
            required property var modelData

            anchors.fill: parent
            blur: modelData.blur
            offset.x: modelData.xOffset
            offset.y: modelData.yOffset
            color: modelData.color
            radius: root.surfaceRadius
        }
    }
}
