import QtQuick
import QtQuick.Layouts
import Merce.Theme
import Merce.Effects
import Merce.Controls
import Merce.Foundation

/**
 * MDialog - Modal dialog component
 * Overlay dialogs for important interactions and confirmations
 */
Item {
    id: root

    // ====================================================================
    // DIALOG PROPERTIES
    // ====================================================================
    property string title: ""
    property string message: ""

    // Buttons
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool showCancel: true

    // Variant
    property string variant: "default"  // default, destructive, warning

    // Size
    property string size: "medium"  // small, medium, large

    // State
    property bool isOpen: false

    // Callbacks
    signal confirmed()
    signal cancelled()
    signal dismissed()

    // ====================================================================
    // SIZE CONFIG
    // ====================================================================
    readonly property var sizeConfig: {
        "small": { "width": 320 },
        "medium": { "width": 480 },
        "large": { "width": 640 }
    }

    // ====================================================================
    // DIMENSIONS
    // ====================================================================
    anchors.fill: parent

    // ====================================================================
    // OVERLAY (BACKDROP)
    // ====================================================================
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: Theme.colors.background.overlay
        opacity: root.isOpen ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.durationNormal
                easing: Theme.motion.easingOut
            }
        }

        // Click outside to dismiss
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
            onClicked: dismiss()
        }
    }

    // ====================================================================
    // DIALOG CONTENT
    // ====================================================================
    Rectangle {
        id: dialogBox
        anchors.centerIn: parent
        width: sizeConfig[root.size].width
        height: dialogContent.height + header.height + buttonRow.height + Theme.spacing.xl2
        radius: Theme.radius.dialog
        color: Theme.colors.background.surface

        // Shadow
        layer.enabled: true
        layer.effect: ElevationEffect {
            elevation: 8
        }

        // Opacity and scale animation
        opacity: root.isOpen ? 1.0 : 0.0
        scale: root.isOpen ? 1.0 : 0.95

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

        // ====================================================================
        // HEADER
        // ====================================================================
        Rectangle {
            id: header
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: headerContent.height + Theme.spacing.md
            radius: Theme.radius.dialog
            color: Theme.colors.background.surface

            clip: true

            // Header content
            Row {
                id: headerContent
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.spacing.xl
                    rightMargin: Theme.spacing.md
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.spacing.md

                // Icon (for variant)
                AppIcon {
                    id: variantIcon
                    name: {
                        if (root.variant === "destructive") return "material:error"
                        if (root.variant === "warning") return "material:warning"
                        return ""
                    }
                    size: Theme.icons.large
                    color: {
                        if (root.variant === "destructive") return Theme.colors.status.error
                        if (root.variant === "warning") return Theme.colors.status.warning
                        return Theme.colors.text.primary
                    }
                    visible: root.variant !== "default"
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Title
                Text {
                    id: titleText
                    text: root.title
                    font.family: FoundationFonts.resolveFamily(Theme.typography.fontDisplay)
                    font.pixelSize: Theme.typography.size2XLarge
                    font.weight: Theme.typography.weightSemibold
                    color: Theme.colors.text.primary
                    visible: root.title !== ""
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Spacer
                Item { width: 1; height: 1; Layout.fillWidth: true }

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
                        color: parent.containsMouse ? Theme.colors.background.hover : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.durationFast
                                easing: Theme.motion.easingOut
                            }
                        }
                    }

                    AppIcon {
                        anchors.centerIn: parent
                        name: "material:close"
                        size: Theme.icons.small
                        color: Theme.colors.text.tertiary
                    }

                    onClicked: dismiss()
                    hoverEnabled: true
                }
            }
        }

        // Divider
        Rectangle {
            id: divider
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
            }
            height: 1
            color: Theme.colors.border.base
        }

        // ====================================================================
        // CONTENT
        // ====================================================================
        Column {
            id: dialogContent
            anchors {
                top: divider.bottom
                left: parent.left
                right: parent.right
                margins: Theme.spacing.xl
            }
            spacing: Theme.spacing.md

            // Message
            Text {
                id: messageText
                text: root.message
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeMedium
                color: Theme.colors.text.secondary
                width: parent.width
                wrapMode: Text.WordWrap
                lineHeight: Theme.typography.leadingNormal
                lineHeightMode: Text.ProportionalHeight
            }

            // Custom content slot (for future use)
            Item {
                id: customContent
                width: parent.width
                height: childrenRect.height
                visible: children.length > 0
            }
        }

        // ====================================================================
        // BUTTONS
        // ====================================================================
        Row {
            id: buttonRow
            anchors {
                top: dialogContent.bottom
                right: parent.right
                rightMargin: Theme.spacing.xl
                topMargin: Theme.spacing.xl
            }
            spacing: Theme.spacing.sm
            layoutDirection: Qt.RightToLeft

            // Cancel button
            MButton {
                text: root.cancelText
                variant: MButton.Outline
                visible: root.showCancel
                onClicked: {
                    root.cancelled()
                    dismiss()
                }
            }

            // Confirm button
            MButton {
                text: root.confirmText
                variant: root.variant === "destructive" ? MButton.Destructive : MButton.Primary
                onClicked: {
                    root.confirmed()
                    dismiss()
                }
            }
        }
    }

    // ====================================================================
    // PUBLIC METHODS
    // ====================================================================
    function open() {
        isOpen = true
    }

    function dismiss() {
        isOpen = false
        dismissedDelayTimer.restart()
    }

    Timer {
        id: dismissedDelayTimer
        interval: Theme.motion.durationNormal + 50
        onTriggered: root.dismissed()
    }

    // ====================================================================
    // KEYBOARD HANDLING
    // ====================================================================
    focus: root.isOpen
    Keys.onEscapePressed: dismiss()
    Keys.onEnterPressed: if (root.isOpen) root.confirmed()
    Keys.onReturnPressed: if (root.isOpen) root.confirmed()

    // ====================================================================
    // ACCESSIBILITY
    // ====================================================================
    Accessible.role: Accessible.Dialog
    Accessible.name: root.title + (root.title !== "" && root.message !== "" ? ": " : "") + root.message
}
