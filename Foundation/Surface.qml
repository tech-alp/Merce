import QtQuick
import Merce.Theme

/**
 * Surface - Theme-aware surface primitive
 * Applies Merce surface colors, borders, radius, and state tokens
 */
Rectangle {
    id: root

    enum SurfaceType {
        Default,
        Tinted,
        Raised
    }

    enum VisualState {
        Normal,
        Hovered,
        Pressed
    }

    // Required properties
    required property int surfaceType

    // Customizable properties
    virtual property color backgroundColor: Theme.colors.surface.container
    virtual property color borderColor: Theme.colors.outline.subtle
    virtual property int borderWidth: 1
    virtual property int radiusValue: Theme.radius.medium

    // Final properties (system standards - cannot be overridden)
    final property int minTouchArea: Theme.spacing.touchTarget

    // Internal state
    property bool isHovered: false
    property bool isPressed: false
    readonly property int visualState: root.isPressed ? Surface.Pressed :
                                       root.isHovered ? Surface.Hovered :
                                       Surface.Normal

    // Apply properties
    color: visualStyle.backgroundColor
    radius: radiusValue
    border.width: borderWidth
    border.color: visualStyle.borderColor

    // Shadow for raised surfaces
    property var shadow: visualStyle.shadow

    QtObject {
        id: visualStyle

        property color backgroundColor: {
            if (root.surfaceType === Surface.Tinted) return Theme.colors.surface.containerTinted
            if (root.surfaceType === Surface.Raised) return Theme.colors.surface.containerRaised
            return root.backgroundColor
        }
        property color borderColor: root.borderColor
        property var shadow: root.surfaceType === Surface.Raised ? Theme.shadows.card : Theme.shadows.none
    }

    StateGroup {
        states: [
            State {
                when: root.visualState === Surface.Hovered
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.outline.focus
                }
            },
            State {
                when: root.visualState === Surface.Pressed
                PropertyChanges {
                    visualStyle.borderColor: Theme.colors.outline.strong
                }
            }
        ]
    }

    // Animation
    Behavior on color { ColorAnimation { duration: Theme.motion.durationFast; easing: Theme.motion.easingOut } }
    Behavior on border.color { ColorAnimation { duration: Theme.motion.durationFast; easing: Theme.motion.easingOut } }
}
