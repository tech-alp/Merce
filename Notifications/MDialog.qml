import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Foundation
import Merce.Theme

SK.Popup {
    id: root

    enum Variant {
        Default,
        Warning,
        Destructive
    }

    enum Size {
        Small,
        Medium,
        Large
    }

    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property bool showCancel: true
    property int variant: MDialog.Default
    property int size: MDialog.Medium
    property bool isOpen: false

    signal confirmed()
    signal cancelled()
    signal dismissed()

    parent: QQC.Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(dialogWidth(root.size), parent ? parent.width - Theme.spacing.xl2 : dialogWidth(root.size))
    implicitHeight: dialogContent.implicitHeight + Theme.spacing.xl * 2
    modal: true
    dim: true
    focus: true
    closePolicy: SK.Popup.CloseOnEscape | SK.Popup.CloseOnPressOutside

    onIsOpenChanged: {
        if (root.isOpen && !root.opened)
            root.open()
        else if (!root.isOpen && root.opened)
            root.close()
    }
    onOpened: root.isOpen = true
    onClosed: {
        root.isOpen = false
        root.dismissed()
    }

    function dialogWidth(value) {
        switch (value) {
        case MDialog.Small:
            return 320
        case MDialog.Large:
            return 640
        default:
            return 480
        }
    }

    function confirm() {
        root.confirmed()
        root.close()
    }

    function cancel() {
        root.cancelled()
        root.close()
    }

    function dismiss() {
        root.close()
    }

    Shortcut {
        sequences: [StandardKey.InsertParagraphSeparator, StandardKey.InsertLineSeparator]
        enabled: root.opened
        onActivated: root.confirm()
    }

    ColumnLayout {
        id: dialogContent

        objectName: root.objectName + ".content"
        x: Theme.spacing.xl
        y: Theme.spacing.xl
        width: Math.max(0, root.width - Theme.spacing.xl * 2)
        spacing: Theme.spacing.lg
        Accessible.role: Accessible.Dialog
        Accessible.name: root.title + (root.title !== "" && root.message !== "" ? ": " : "") + root.message

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.md

            AppIcon {
                visible: root.variant !== MDialog.Default
                name: root.variant === MDialog.Destructive ? "material:error" : "material:warning"
                size: Theme.icons.large
                color: root.variant === MDialog.Destructive
                    ? Theme.colors.status.error.content
                    : Theme.colors.status.warning.content
            }

            AppLabel {
                Layout.fillWidth: true
                text: root.title
                textType: AppLabel.H3
                wrapMode: Text.WordWrap
                color: Theme.colors.content.primary
            }

            SK.ToolButton {
                objectName: root.objectName + ".close"
                Layout.preferredWidth: Theme.spacing.touchTargetCompact
                Layout.preferredHeight: Theme.spacing.touchTargetCompact
                text: "\u00d7"
                Accessible.name: "Close"
                onClicked: root.dismiss()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Theme.size.outline.hairline
            color: Theme.colors.outline.subtle
        }

        AppLabel {
            Layout.fillWidth: true
            text: root.message
            textType: AppLabel.Body
            wrapMode: Text.WordWrap
            color: Theme.colors.content.secondary
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.sm

            Item {
                Layout.fillWidth: true
            }

            SK.Button {
                objectName: root.objectName + ".cancel"
                visible: root.showCancel
                text: root.cancelText
                SK.StyleVariation.variations: ["outline"]
                onClicked: root.cancel()
            }

            SK.Button {
                objectName: root.objectName + ".confirm"
                text: root.confirmText
                SK.StyleVariation.variations: root.variant === MDialog.Destructive
                    ? ["destructive"]
                    : []
                onClicked: root.confirm()
            }
        }
    }
}
