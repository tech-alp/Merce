import QtQuick
import Merce.Theme
import Merce.Foundation

/**
 * MRadio - Radio button component
 * Touch-optimized radio button with dot indicator
 */
BaseControl {
    id: root

    // ====================================================================
    // REQUIRED PROPERTIES
    // ====================================================================
    controlType: "radio"

    // ====================================================================
    // RADIO PROPERTIES
    // ====================================================================
    property bool checked: false
    property string label: ""
    property string size: "medium"  // small, medium
    property string labelPosition: "right"  // left, right
    property string group: ""  // For mutual exclusion (optional, app-level handling)

    // ====================================================================
    // SIGNALS
    // ====================================================================
    signal toggled(bool checked)

    // ====================================================================
    // OVERRIDDEN PROPERTIES
    // ====================================================================
    override property color accentColor: Theme.colors.action.primary
    override property color backgroundColor: "transparent"

    // ====================================================================
    // SIZE CONFIG
    // ====================================================================
    readonly property var sizeConfig: {
        "small": {
            "circleSize": 20,
            "dotSize": 10,
            "fontSize": Theme.typography.sizeSmall
        },
        "medium": {
            "circleSize": 24,
            "dotSize": 12,
            "fontSize": Theme.typography.sizeMedium
        }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    override property int contentWidth: radioCircle.width + (label !== "" ? textMetrics.width + Theme.spacing.sm : 0)
    override property int contentHeight: Math.max(radioCircle.height, textMetrics.height)

    // ====================================================================
    // VISUAL STATES
    // ====================================================================
    readonly property color circleBorderColor: {
        if (root.isDisabled) return Theme.colors.border.base
        if (root.isFocused) return Theme.colors.border.focus
        if (root.isHovered) return Theme.colors.border.strong
        return Theme.colors.border.base
    }

    readonly property color circleBackgroundColor: {
        if (root.isDisabled && root.checked) return Theme.colors.background.hover
        return "transparent"
    }

    readonly property color dotColor: {
        if (root.isDisabled) return Theme.colors.text.disabled
        return root.accentColor
    }

    // ====================================================================
    // RADIO CIRCLE VISUAL
    // ====================================================================
    Rectangle {
        id: radioCircle
        width: root.sizeConfig[root.size].circleSize
        height: root.sizeConfig[root.size].circleSize
        radius: width / 2
        color: root.circleBackgroundColor
        border.width: 2
        border.color: root.circleBorderColor

        // Inner dot (when checked)
        Rectangle {
            width: root.sizeConfig[root.size].dotSize
            height: root.sizeConfig[root.size].dotSize
            anchors.centerIn: parent
            radius: width / 2
            color: root.dotColor
            visible: root.checked

            // Scale animation for dot appearance
            scale: root.checked ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motion.durationFast
                    easing: Theme.motion.easingOut
                }
            }
        }

        // Focus ring
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 2
            border.color: Theme.colors.border.focus
            opacity: root.isFocused ? 1.0 : 0.0
        }

        // Animation for border color
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }

        // Animation for background color
        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    // ====================================================================
    // LABEL
    // ====================================================================
    Text {
        id: radioLabel
        text: root.label
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: root.sizeConfig[root.size].fontSize
        color: root.isDisabled ? Theme.colors.text.disabled : Theme.colors.text.primary

        anchors {
            left: root.labelPosition === "right" ? radioCircle.right : undefined
            right: root.labelPosition === "left" ? radioCircle.left : undefined
            leftMargin: root.labelPosition === "right" ? Theme.spacing.sm : 0
            rightMargin: root.labelPosition === "left" ? Theme.spacing.sm : 0
            verticalCenter: radioCircle.verticalCenter
        }
        visible: root.label !== ""
    }

    // ====================================================================
    // TEXT METRICS
    // ====================================================================
    TextMetrics {
        id: textMetrics
        text: root.label
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: root.sizeConfig[root.size].fontSize
    }

    // ====================================================================
    // CLICK HANDLING
    // ====================================================================
    MouseArea {
        id: clickArea
        anchors.fill: parent
        cursorShape: root.isDisabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.isDisabled
        hoverEnabled: true

        onClicked: {
            root.checked = true
            root.toggled(root.checked)
        }
    }

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.RadioButton
    Accessible.name: root.label
    Accessible.onPressAction: if (!root.isDisabled) clickArea.clicked()
}
