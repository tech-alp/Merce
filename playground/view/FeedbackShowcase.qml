import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Notifications
import Toastify

Item {
    id: root
    objectName: "merce.playground.showcase.feedback"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.text.primary
        wrapMode: Text.WordWrap
    }

    MerceToastifyStyleProvider {
        id: toastStyle
    }

    Toastify {
        id: toastify
        objectName: "merce.playground.feedback.toastify"
        style: toastStyle
    }

    function showToast(type, message) {
        toastify.createMessage(message, {
            type: type,
            position: Toastify.BottomRightCorner,
            autoClose: 4000,
            closeOnClick: true,
            hideProgressBar: false
        })
    }

    MDialog {
        id: dialog
        objectName: "merce.playground.feedback.dialog"
        title: "Dialog sample"
        message: "This dialog uses the active Merce theme tokens."
        confirmText: "Confirm"
        cancelText: "Cancel"
        showCancel: true
        onConfirmed: isOpen = false
        onCancelled: isOpen = false
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
                        text: "Info"
                        SK.StyleVariation.variations: ["outline"]
                        onClicked: root.showToast(Toastify.Info, "Informational toast")
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.success"
                        text: "Success"
                        onClicked: root.showToast(Toastify.Success, "Success toast")
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.warning"
                        text: "Warning"
                        SK.StyleVariation.variations: ["secondary"]
                        onClicked: root.showToast(Toastify.Warning, "Warning toast")
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.toast.error"
                        text: "Error"
                        SK.StyleVariation.variations: ["destructive"]
                        onClicked: root.showToast(Toastify.Error, "Error toast")
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
                        onClicked: {
                            dialog.variant = MDialog.Default
                            dialog.title = "Dialog sample"
                            dialog.message = "This dialog uses the active Merce theme tokens."
                            dialog.isOpen = true
                        }
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.dialog.warning"
                        text: "Warning dialog"
                        SK.StyleVariation.variations: ["secondary"]
                        onClicked: {
                            dialog.variant = MDialog.Warning
                            dialog.title = "Warning"
                            dialog.message = "Review the current theme state before continuing."
                            dialog.isOpen = true
                        }
                    }

                    SK.Button {
                        objectName: "merce.playground.feedback.dialog.destructive"
                        text: "Destructive dialog"
                        SK.StyleVariation.variations: ["destructive"]
                        onClicked: {
                            dialog.variant = MDialog.Destructive
                            dialog.title = "Destructive action"
                            dialog.message = "This state uses the destructive semantic color."
                            dialog.isOpen = true
                        }
                    }
                }
            }
        }
    }
}
