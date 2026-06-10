import QtQuick
import Merce.Theme
import Merce.Foundation
import QtQuick.Effects

/**
 * MSwitch - Toggle switch component
 * Touch-optimized toggle with animated thumb
 */
BaseControl {
    id: root

    // ====================================================================
    // REQUIRED PROPERTIES
    // ====================================================================
    controlType: "switch"

    // ====================================================================
    // SWITCH PROPERTIES
    // ====================================================================
    property bool checked: false
    property string label: ""
    property string size: "medium"  // small, medium
    property string labelPosition: "right"  // left, right

    // ====================================================================
    // SIGNALS
    // ====================================================================
    signal toggled(bool checked)

    // ====================================================================
    // OVERRIDDEN PROPERTIES
    // ====================================================================
    property color accentColor: Theme.colors.action.primary
    property color backgroundColor: "transparent"

    // ====================================================================
    // SIZE CONFIG
    // ====================================================================
    readonly property var sizeConfig: {
        "small": {
            "trackWidth": 44,
            "trackHeight": 24,
            "thumbSize": 20,
            "fontSize": Theme.typography.sizeSmall
        },
        "medium": {
            "trackWidth": 52,
            "trackHeight": 28,
            "thumbSize": 24,
            "fontSize": Theme.typography.sizeMedium
        }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    property int contentWidth: switchTrack.width + (label !== "" ? textMetrics.width + Theme.spacing.sm : 0)
    property int contentHeight: Math.max(switchTrack.height, textMetrics.height)

    // ====================================================================
    // VISUAL STATES
    // ====================================================================
    readonly property color trackColor: {
        if (root.isDisabled) return Theme.colors.background.hover
        if (root.checked) return root.accentColor
        return Theme.colors.border.base
    }

    readonly property color thumbColor: {
        if (root.isDisabled) return Theme.colors.text.disabled
        return Theme.colors.background.surface
    }

    // Thumb position (animated)
    readonly property real thumbPosition: {
        if (root.labelPosition === "left") {
            return root.checked ? 0 : switchTrack.width - root.sizeConfig[root.size].thumbSize - 2
        } else {
            return root.checked ? switchTrack.width - root.sizeConfig[root.size].thumbSize - 2 : 0
        }
    }

    // ====================================================================
    // SWITCH TRACK VISUAL
    // ====================================================================
    Rectangle {
        id: switchTrack
        width: root.sizeConfig[root.size].trackWidth
        height: root.sizeConfig[root.size].trackHeight
        radius: height / 2
        color: root.trackColor

        // Switch thumb
        Rectangle {
            id: switchThumb
            width: root.sizeConfig[root.size].thumbSize
            height: root.sizeConfig[root.size].thumbSize
            radius: width / 2
            color: root.thumbColor

            // Shadow for thumb
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 0.3
                shadowOpacity: 0.5
            }

            x: root.thumbPosition
            y: (parent.height - height) / 2

            // Animate thumb position
            Behavior on x {
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

        // Animation for track color
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
        id: switchLabel
        text: root.label
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: root.sizeConfig[root.size].fontSize
        color: root.isDisabled ? Theme.colors.text.disabled : Theme.colors.text.primary

        anchors {
            left: root.labelPosition === "right" ? switchTrack.right : undefined
            right: root.labelPosition === "left" ? switchTrack.left : undefined
            leftMargin: root.labelPosition === "right" ? Theme.spacing.sm : 0
            rightMargin: root.labelPosition === "left" ? Theme.spacing.sm : 0
            verticalCenter: switchTrack.verticalCenter
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
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.CheckBox
    Accessible.name: root.label
    Accessible.onPressAction: if (!root.isDisabled) clickArea.clicked()
}
