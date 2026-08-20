import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Notifications

Item {
    id: root

    property string dialogStateText: qsTr("No dialog action yet")

    objectName: "merce.playground.showcase.feedback"
    implicitHeight: page.implicitHeight
    height: implicitHeight

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    function showDialog(requestId, variant, title, message) {
        return NotificationCenter.ask({
            owner: root,
            requestId: requestId,
            title: title,
            message: message,
            confirmText: qsTr("Confirm"),
            cancelText: qsTr("Cancel"),
            showCancel: true,
            variant: variant,
            onAccepted: function() {
                root.dialogStateText = qsTr("%1: confirmed").arg(title)
            },
            onCancelled: function() {
                root.dialogStateText = qsTr("%1: cancelled").arg(title)
            },
            onRefused: function(activeRequestId) {
                root.dialogStateText = qsTr("Dialog is busy: %1").arg(activeRequestId)
            }
        })
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            width: parent.width
            height: toastColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: toastColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: "Toasts"
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.info"
                        text: qsTr("Info")
                        SK.StyleVariation.variations: ["outline"]
                        onClicked: NotificationCenter.notify(
                                       NotificationCenter.Info,
                                       qsTr("Informational toast"), "", 4000)
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.success"
                        text: qsTr("Success")
                        onClicked: NotificationCenter.notify(
                                       NotificationCenter.Success,
                                       qsTr("Success toast"), "", 4000)
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.warning"
                        text: qsTr("Warning")
                        SK.StyleVariation.variations: ["secondary"]
                        onClicked: NotificationCenter.notify(
                                       NotificationCenter.Warning,
                                       qsTr("Warning toast"), "", 4000)
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.error"
                        text: qsTr("Error")
                        SK.StyleVariation.variations: ["destructive"]
                        onClicked: NotificationCenter.notify(
                                       NotificationCenter.Error,
                                       qsTr("Error toast"), "", 4000)
                    }
                }
            }
        }

        Surface {
            width: parent.width
            height: dialogColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: dialogColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                SectionTitle {
                    width: parent.width
                    text: "Dialogs"
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.md

                    SK.Button {
                        objectName: "merce.playground.feedback.dialog.default"
                        text: "Default dialog"
                        onClicked: root.showDialog(
                                       "feedback-default",
                                       MDialog.Default,
                                       qsTr("Dialog sample"),
                                       qsTr("This dialog uses the active Merce theme tokens."))
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.dialog.warning"
                        text: "Warning dialog"
                        SK.StyleVariation.variations: ["secondary"]
                        onClicked: root.showDialog(
                                       "feedback-warning",
                                       MDialog.Warning,
                                       qsTr("Warning"),
                                       qsTr("Review the current theme state before continuing."))
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.dialog.destructive"
                        text: "Destructive dialog"
                        SK.StyleVariation.variations: ["destructive"]
                        onClicked: root.showDialog(
                                       "feedback-destructive",
                                       MDialog.Destructive,
                                       qsTr("Destructive action"),
                                       qsTr("This state uses the destructive semantic color."))
                    }
                }

                AppLabel {
                    objectName: "merce.playground.feedback.dialog.state"
                    width: parent.width
                    text: root.dialogStateText
                    textType: AppLabel.Body
                    color: Theme.colors.content.secondary
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
