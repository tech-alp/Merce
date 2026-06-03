import QtQuick
import Merce.Core
import Merce.Foundation
import Merce.Controls
import Merce.Notifications

Window {
    id: root
    objectName: "merce.playground.window"

    width: 1100
    height: 760
    visible: true
    color: Theme.colors.background.base
    title: "Merce Playground"

    property bool checkboxValue: true
    property bool radioValue: true
    property bool switchValue: true

    Flickable {
        objectName: "merce.playground.flickable"
        anchors.fill: parent
        contentWidth: width
        contentHeight: page.implicitHeight + Theme.spacing.xl2 * 2
        clip: true

        Column {
            id: page
            objectName: "merce.playground.page"
            width: Math.min(parent.width - Theme.spacing.xl2 * 2, 980)
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.spacing.xl2
            spacing: Theme.spacing.xl

            MText {
                objectName: "merce.playground.title"
                width: parent.width
                type: "h1"
                text: "Merce Playground"
            }

            MText {
                objectName: "merce.playground.subtitle"
                width: parent.width
                type: "bodyLarge"
                text: "Bu ekran Merce QML modüllerini QtQuick.Controls gibi import ederek çalıştırır."
                textColor: Theme.colors.text.secondary
                wrap: "word"
            }

            MSurface {
                objectName: "merce.playground.controlsSurface"
                width: parent.width
                height: controlsColumn.implicitHeight + Theme.spacing.xl2
                surfaceType: types["default"]
                radiusValue: Theme.radius.large

                Column {
                    id: controlsColumn
                    objectName: "merce.playground.controlsColumn"
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacing.xl
                    }
                    spacing: Theme.spacing.lg

                    MText {
                        objectName: "merce.playground.controlsTitle"
                        type: "h3"
                        text: "Controls"
                    }

                    Row {
                        objectName: "merce.playground.buttonRow"
                        spacing: Theme.spacing.md

                        MButton {
                            objectName: "merce.playground.primaryButton"
                            text: "Primary"
                            variant: "primary"
                            onClicked: toast.show()
                        }

                        MButton {
                            objectName: "merce.playground.secondaryButton"
                            text: "Secondary"
                            variant: "secondary"
                        }

                        MButton {
                            objectName: "merce.playground.outlineButton"
                            text: "Outline"
                            variant: "outline"
                        }

                        MButton {
                            objectName: "merce.playground.destructiveButton"
                            text: "Destructive"
                            variant: "destructive"
                            onClicked: dialog.isOpen = true
                        }
                    }

                    MInput {
                        objectName: "merce.playground.emailInput"
                        width: 360
                        placeholder: "Email"
                        inputType: "email"
                    }

                    Row {
                        objectName: "merce.playground.toggleRow"
                        spacing: Theme.spacing.xl

                        MCheckbox {
                            objectName: "merce.playground.checkbox"
                            label: "Checkbox"
                            checked: root.checkboxValue
                            onToggled: (checked) => root.checkboxValue = checked
                        }

                        MRadio {
                            objectName: "merce.playground.radio"
                            label: "Radio"
                            checked: root.radioValue
                            onToggled: (checked) => root.radioValue = checked
                        }

                        MSwitch {
                            objectName: "merce.playground.switch"
                            label: "Switch"
                            checked: root.switchValue
                            onToggled: (checked) => root.switchValue = checked
                        }
                    }

                    MSelect {
                        objectName: "merce.playground.select"
                        width: 360
                        options: [
                            { "value": "new", "label": "New arrivals" },
                            { "value": "sale", "label": "Sale items" },
                            { "value": "popular", "label": "Popular products" }
                        ]
                    }
                }
            }
        }
    }

    MToast {
        id: toast
        objectName: "merce.playground.toast"
        title: "Merce"
        message: "Toast component imported from Merce.Notifications."
        variant: "success"
    }

    MDialog {
        id: dialog
        objectName: "merce.playground.dialog"
        title: "Playground dialog"
        message: "MDialog is loaded from Merce.Notifications and uses Merce.Controls internally."
        confirmText: "OK"
        showCancel: false
        onConfirmed: isOpen = false
    }
}
