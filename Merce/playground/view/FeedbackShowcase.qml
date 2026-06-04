import QtQuick
import Merce.Core
import Merce.Foundation
import Merce.Controls
import Merce.Notifications

Item {
    id: root
    objectName: "merce.playground.showcase.feedback"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    component SectionTitle: MText {
        type: "h4"
        textColor: Theme.palette.textPrimary
        wrap: "word"
    }

    MToast {
        id: toast
        objectName: "merce.playground.feedback.toast"
        title: "Merce"
        message: "Theme-aware notification sample."
        variant: "info"
        position: "bottom-right"
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

        MSurface {
            width: parent.width
            height: toastColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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

                    MButton {
                        text: "Info"
                        variant: "outline"
                        onClicked: {
                            toast.variant = "info"
                            toast.message = "Informational toast"
                            toast.show()
                        }
                    }

                    MButton {
                        text: "Success"
                        variant: "primary"
                        onClicked: {
                            toast.variant = "success"
                            toast.message = "Success toast"
                            toast.show()
                        }
                    }

                    MButton {
                        text: "Warning"
                        variant: "secondary"
                        onClicked: {
                            toast.variant = "warning"
                            toast.message = "Warning toast"
                            toast.show()
                        }
                    }

                    MButton {
                        text: "Error"
                        variant: "destructive"
                        onClicked: {
                            toast.variant = "error"
                            toast.message = "Error toast"
                            toast.show()
                        }
                    }
                }
            }
        }

        MSurface {
            width: parent.width
            height: dialogColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: types["default"]
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

                    MButton {
                        text: "Default dialog"
                        variant: "primary"
                        onClicked: {
                            dialog.variant = "default"
                            dialog.title = "Dialog sample"
                            dialog.message = "This dialog uses the active Merce theme tokens."
                            dialog.isOpen = true
                        }
                    }

                    MButton {
                        text: "Warning dialog"
                        variant: "secondary"
                        onClicked: {
                            dialog.variant = "warning"
                            dialog.title = "Warning"
                            dialog.message = "Review the current theme state before continuing."
                            dialog.isOpen = true
                        }
                    }

                    MButton {
                        text: "Destructive dialog"
                        variant: "destructive"
                        onClicked: {
                            dialog.variant = "destructive"
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
