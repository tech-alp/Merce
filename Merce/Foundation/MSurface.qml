import QtQuick
import Merce.Core

/**
 * MSurface - Base surface component
 * Provides common surface properties with optional customization
 */
Rectangle {
    id: root

    // Required properties
    required property int surfaceType

    // Surface types
    readonly property var types: {
        "default": 0,
        "tinted": 1,
        "raised": 2
    }

    // Customizable properties
    virtual property color backgroundColor: Theme.colors.background.surface
    virtual property color borderColor: Theme.colors.border.default
    virtual property int borderWidth: 1
    virtual property int radiusValue: Theme.radius.medium

    // Final properties (system standards - cannot be overridden)
    final property int minTouchArea: Theme.spacing.touchTarget

    // Internal state
    property bool isHovered: false
    property bool isPressed: false

    // Apply properties
    color: {
        if (surfaceType === types.tinted) return Theme.colors.background.tinted
        if (surfaceType === types.raised) return Theme.colors.background.elevated
        return backgroundColor
    }

    radius: radiusValue
    border.width: borderWidth
    border.color: isPressed ? Theme.colors.border.strong :
                isHovered ? Theme.colors.border.focus :
                borderColor

    // Shadow for raised surfaces
    property var shadow: surfaceType === types.raised ? Theme.shadows.card : Theme.shadows.none

    // Animation
    Behavior on color { ColorAnimation { duration: Theme.motion.durationFast; easing: Theme.motion.easingOut } }
    Behavior on border.color { ColorAnimation { duration: Theme.motion.durationFast; easing: Theme.motion.easingOut } }
}
