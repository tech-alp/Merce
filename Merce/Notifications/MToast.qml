import QtQuick
import Merce.Core
import Merce.Foundation

/**
 * MToast - Non-intrusive notification component
 * Auto-dismissing toast messages for feedback
 */
Item {
    id: root

    // ====================================================================
    // TOAST PROPERTIES
    // ====================================================================
    property string title: ""
    property string message: ""
    property string variant: "info"  // success, warning, error, info

    // Duration (ms), 0 for manual dismiss
    property int duration: 4000

    // Position
    property string position: "bottom"  // top, bottom, top-left, top-right, bottom-left, bottom-right

    // Actions
    property string actionText: ""
    signal actionClicked()

    // Close handling
    signal closeRequested()
    signal dismissed()

    // ====================================================================
    // INTERNAL STATE
    // ====================================================================
    property bool isVisible: false

    // Variant configuration
    readonly property var variantConfig: {
        "success": {
            "icon": "\ue87b",  // Checkmark
            "color": Theme.colors.status.success,
            "bgColor": Theme.colors.status.successLight
        },
        "warning": {
            "icon": "\ue002",  // Warning
            "color": Theme.colors.status.warning,
            "bgColor": Theme.colors.status.warningLight
        },
        "error": {
            "icon": "\ue87e",  // Error/close
            "color": Theme.colors.status.error,
            "bgColor": Theme.colors.status.errorLight
        },
        "info": {
            "icon": "\ue88e",  // Info
            "color": Theme.colors.status.info,
            "bgColor": Theme.colors.status.infoLight
        }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    width: parent ? Math.min(parent.width - Theme.spacing.xl, 400) : 400
    height: contentColumn.height + Theme.spacing.lg
    anchors {
        horizontalCenter: position === "top" || position === "bottom" ? parent.horizontalCenter : undefined
        verticalCenter: undefined
    }

    // Positioning based on position property
    x: {
        if (position === "top-left" || position === "bottom-left") return Theme.spacing.xl
        if (position === "top-right" || position === "bottom-right") return parent.width - width - Theme.spacing.xl
        return (parent.width - width) / 2
    }
    y: {
        if (position.startsWith("top")) return Theme.spacing.xl
        if (position.startsWith("bottom")) return parent.height - height - Theme.spacing.xl
        return Theme.spacing.xl
    }

    // Z-index (above other content)
    z: Theme.zIndex.notification

    // ====================================================================
    // APPEARANCE
    // ====================================================================
    opacity: isVisible ? 1.0 : 0.0
    scale: isVisible ? 1.0 : 0.95

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.durationNormal
            easing: Theme.motion.easingOut
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.motion.durationNormal
            easing: Theme.motion.easingOut
        }
    }

    // Background surface
    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.large
        color: variantConfig[variant].bgColor
        border.width: 1
        border.color: variantConfig[variant].color
    }

    // Content
    Row {
        id: contentRow
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacing.md
        }
        spacing: Theme.spacing.md

        // Icon
        Text {
            id: icon
            text: variantConfig[root.variant].icon
            font.family: "Material Symbols Outlined"
            font.pixelSize: Theme.icons.medium
            color: variantConfig[root.variant].color
            anchors.verticalCenter: parent.verticalCenter
        }

        // Content column
        Column {
            id: contentColumn
            width: parent.width - icon.width - parent.spacing - (actionButton.visible ? actionButton.width + Theme.spacing.sm : 0)
            spacing: Theme.spacing.xxs

            // Title
            Text {
                id: titleText
                text: root.title
                font.family: Theme.typography.fontBody
                font.pixelSize: Theme.typography.sizeSmall
                font.weight: Theme.typography.weightSemibold
                color: Theme.colors.text.primary
                visible: root.title !== ""
                width: parent.width
                wrapMode: Text.WordWrap
            }

            // Message
            Text {
                id: messageText
                text: root.message
                font.family: Theme.typography.fontBody
                font.pixelSize: Theme.typography.sizeSmall
                color: Theme.colors.text.secondary
                visible: root.message !== ""
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        // Action button
        MButton {
            id: actionButton
            text: root.actionText
            variant: "ghost"
            size: "small"
            visible: root.actionText !== ""
            onClicked: {
                root.actionClicked()
                dismiss()
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        // Close button
        MouseArea {
            id: closeButton
            width: Theme.spacing.touchTargetCompact
            height: Theme.spacing.touchTargetCompact
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Theme.radius.small
                color: parent.containsMouse ? Theme.colors.background.pressed : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.motion.durationFast
                        easing: Theme.motion.easingOut
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "\ue87e"
                font.family: "Material Symbols Outlined"
                font.pixelSize: Theme.icons.small
                color: Theme.colors.text.tertiary
            }

            onClicked: dismiss()
            hoverEnabled: true
        }
    }

    // ====================================================================
    // AUTO-DISMISS TIMER
    // ====================================================================
    Timer {
        id: dismissTimer
        interval: root.duration
        onTriggered: dismiss()
    }

    // ====================================================================
    // PUBLIC METHODS
    // ====================================================================
    function show() {
        isVisible = true
        if (duration > 0) {
            dismissTimer.restart()
        }
    }

    function dismiss() {
        isVisible = false
        dismissTimer.stop()
        dismissedDelayTimer.restart()
    }

    Timer {
        id: dismissedDelayTimer
        interval: Theme.motion.durationNormal + 50
        onTriggered: root.dismissed()
    }

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.AlertMessage
    Accessible.name: title + (title !== "" && message !== "" ? ". " : "") + message
    Accessible.visible: isVisible
}
