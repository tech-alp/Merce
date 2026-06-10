import QtQuick
import Merce.Theme

/**
 * BaseControl - Base primitive for interactive controls
 * Provides common properties and behaviors
 */
Item {
    id: root

    // ====================================================================
    // REQUIRED PROPERTIES
    // ====================================================================
    required property string controlType

    // ====================================================================
    // VIRTUAL PROPERTIES (Can be overridden by child components)
    // ====================================================================
    property color accentColor: Theme.colors.action.primary
    property color accentHoverColor: Theme.colors.action.primaryHover
    property color backgroundColor: "transparent"
    property int radiusValue: Theme.radius.button

    // State colors
    property color disabledColor: Theme.colors.text.disabled
    property color disabledBackground: Theme.colors.background.hover

    // ====================================================================
    // FINAL PROPERTIES (System standards - cannot be overridden)
    // ====================================================================
    property int touchTarget: Theme.spacing.touchTarget
    property int touchTargetCompact: Theme.spacing.touchTargetCompact

    // ====================================================================
    // STATE PROPERTIES
    // ====================================================================
    property bool isHovered: false
    property bool isPressed: false
    property bool isFocused: false
    property bool isDisabled: false

    // ====================================================================
    // INTERACTION PROPERTIES
    // ====================================================================
    signal clicked(variant mouse)
    signal pressed(variant mouse)
    signal released(variant mouse)
    signal hoveredChanged(bool hovered)

    // Cursor
    property int cursorShape: isDisabled ? Qt.ArrowCursor : Qt.PointingHandCursor

    // ====================================================================
    // DIMENSIONS (enforce touch targets)
    // ====================================================================
    implicitWidth: Math.max(contentWidth, touchTarget)
    implicitHeight: Math.max(contentHeight, touchTarget)

    property int contentWidth: 120
    property int contentHeight: Theme.spacing.xl

    // ====================================================================
    // VISUAL FEEDBACK
    // ====================================================================
    opacity: isDisabled ? 0.5 : 1.0

    scale: isPressed ? 0.98 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: Theme.motion.durationInstant
            easing: Theme.motion.easingOut
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.durationFast
            easing: Theme.motion.easingOut
        }
    }

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.Button
    Accessible.name: controlType
    Accessible.onPressAction: if (!isDisabled) clicked()

    // ====================================================================
    // MOUSE HANDLING
    // ====================================================================
    MouseArea {
        anchors.fill: parent
        cursorShape: root.cursorShape
        enabled: !root.isDisabled
        hoverEnabled: true

        onClicked: (mouse) => root.clicked(mouse)
        onPressed: (mouse) => {
            root.isPressed = true
            root.pressed(mouse)
        }
        onReleased: (mouse) => {
            root.isPressed = false
            root.released(mouse)
        }
        onEntered: {
            root.isHovered = true
            root.hoveredChanged(true)
        }
        onExited: {
            root.isHovered = false
            root.isPressed = false
            root.hoveredChanged(false)
        }
    }
}
