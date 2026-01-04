pragma Singleton
import QtQuick

/**
 * Merce Motion & Animation System
 * Consistent timing and easing for smooth interactions
 */
QtObject {
    // Duration tokens (milliseconds)
    readonly property int durationInstant: 100
    readonly property int durationFast: 150
    readonly property int durationNormal: 200
    readonly property int durationSlow: 300
    readonly property int durationSlower: 500
    readonly property int durationSlowest: 800

    // Easing functions (Qt compatible)
    readonly property string easingDefault: Easing.InOutQuad
    readonly property string easingIn: Easing.InQuad
    readonly property string easingOut: Easing.OutQuad
    readonly property string easingInOut: Easing.InOutQuad
    readonly property string easingEaseIn: Easing.InCubic
    readonly property string easingEaseOut: Easing.OutCubic
    readonly property string easingBounce: Easing.OutBounce

    // Spring animations (for physics-like feel)
    readonly property int springMass: 1
    readonly property int springStiffness: 200
    readonly property int springDamping: 20

    // Preset animation configurations
    readonly property var hover: {
        "duration": durationFast,
        "easing": easingOut
    }

    readonly property var press: {
        "duration": durationInstant,
        "easing": easingIn
    }

    readonly property var appear: {
        "duration": durationSlow,
        "easing": easingEaseOut
    }

    readonly property var enter: {
        "duration": durationNormal,
        "easing": easingEaseOut
    }

    readonly property var exit: {
        "duration": durationFast,
        "easing": easingIn
    }
}
