pragma Singleton
import QtQuick

/**
 * Merce Theme Singleton
 * Main entry point for all design tokens
 *
 * Usage:
 *   import Merce.Core
 *
 *   Theme.colors.action.primary
 *   Theme.spacing.md
 *   Theme.typography.body.size
 *   Theme.motion.durationNormal
 */
QtObject {
    id: root

    // Import all token singletons
    readonly property Palette palette: Palette {}
    readonly property Spacing spacing: Spacing {}
    readonly property Typography typography: Typography {}
    readonly property Radius radius: Radius {}
    readonly property Shadows shadows: Shadows {}
    readonly property Motion motion: Motion {}

    // Convenience alias for colors
    readonly property var colors: palette

    // Icon sizes (commonly used)
    readonly property QtObject icons: QtObject {
        readonly property int xSmall: 16
        readonly property int small: 20
        readonly property int medium: 24
        readonly property int large: 32
        readonly property int xLarge: 48
    }

    // Z-index layers
    readonly property QtObject zIndex: QtObject {
        readonly property int dropdown: 1000
        readonly property int sticky: 1100
        readonly property int overlay: 1200
        readonly property int modal: 1300
        readonly property int popover: 1400
        readonly property int tooltip: 1500
        readonly property int notification: 1600
    }

    // Breakpoints (for responsive design)
    readonly property QtObject breakpoint: QtObject {
        readonly property int small: 640
        readonly property int medium: 768
        readonly property int large: 1024
        readonly property int xLarge: 1280
        readonly property int xxLarge: 1536
    }
}
