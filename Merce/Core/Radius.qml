pragma Singleton
import QtQuick

/**
 * Merce Border Radius System
 * Consistent corner rounding across components
 */
QtObject {
    readonly property int none: 0
    readonly property int small: 4       // 4px - Subtle rounding
    readonly property int medium: 8      // 8px - Standard rounding
    readonly property int large: 12      // 12px - Rounded
    readonly property int xlarge: 16     // 16px - Very rounded
    readonly property int xxlarge: 24    // 24px - Pill-like
    readonly property int full: 9999     // Fully circular

    // Component-specific radius
    readonly property int button: large
    readonly property int input: medium
    readonly property int card: xlarge
    readonly property int badge: full
    readonly property int dialog: xxlarge
    readonly property int tooltip: small
}
