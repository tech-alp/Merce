pragma Singleton
import QtQuick

/**
 * Merce Shadow System
 * Elevation tokens for depth and hierarchy
 */
QtObject {
    // Shadow presets (as property arrays for BoxShadow)
    readonly property var none: []

    readonly property var small: [
        { xOffset: 0, yOffset: 1, blur: 2, color: "rgba(31, 21, 16, 0.04)" },
        { xOffset: 0, yOffset: 1, blur: 3, color: "rgba(31, 21, 16, 0.08)" }
    ]

    readonly property var medium: [
        { xOffset: 0, yOffset: 4, blur: 6, color: "rgba(31, 21, 16, 0.08)" },
        { xOffset: 0, yOffset: 2, blur: 4, color: "rgba(31, 21, 16, 0.04)" }
    ]

    readonly property var large: [
        { xOffset: 0, yOffset: 10, blur: 15, color: "rgba(31, 21, 16, 0.08)" },
        { xOffset: 0, yOffset: 4, blur: 6, color: "rgba(31, 21, 16, 0.04)" }
    ]

    readonly property var xlarge: [
        { xOffset: 0, yOffset: 20, blur: 25, color: "rgba(31, 21, 16, 0.08)" },
        { xOffset: 0, yOffset: 10, blur: 10, color: "rgba(31, 21, 16, 0.04)" }
    ]

    readonly property var xxlarge: [
        { xOffset: 0, yOffset: 25, blur: 50, color: "rgba(31, 21, 16, 0.15)" }
    ]

    // Component-specific shadows
    readonly property var button: small
    readonly property var card: medium
    readonly property var cardElevated: large
    readonly property var dialog: xxlarge
    readonly property var dropdown: xlarge
    readonly property var tooltip: medium

    // Shadow for interactive states
    readonly property var hover: medium
    readonly property var focus: medium
    readonly property var pressed: small
}
