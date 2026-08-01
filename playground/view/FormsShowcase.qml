pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root

    objectName: "merce.playground.showcase.forms"
    implicitHeight: page.implicitHeight
    height: implicitHeight

    property string deliveryOption: "standard"
    readonly property bool compactLayout: width < 720
    readonly property bool validationValid: validationEmail.acceptableInput
                                                   && validationPassword.text.length >= 8
                                                   && validationConfirm.text === validationPassword.text

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
    }

    component FieldBlock: Column {
        id: fieldBlock

        required property string label
        property string helperText: ""
        property color helperColor: Theme.colors.content.secondary
        default property alias content: controlSlot.data

        spacing: Theme.spacing.xs

        AppLabel {
            width: parent.width
            textType: AppLabel.BodySmall
            text: fieldBlock.label
            color: Theme.colors.content.secondary
        }
        Column {
            id: controlSlot
            width: parent.width
        }
        AppLabel {
            width: parent.width
            visible: fieldBlock.helperText.length > 0
            textType: AppLabel.Caption
            text: fieldBlock.helperText
            color: fieldBlock.helperColor
            wrapMode: Text.WordWrap
        }
    }

    component FormPanel: Surface {
        id: formPanel

        required property string title
        default property alias content: panelBody.data

        implicitHeight: panelColumn.implicitHeight + Theme.spacing.xl2
        height: implicitHeight
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: panelColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.xl
            }
            spacing: Theme.spacing.lg

            SectionTitle {
                width: parent.width
                text: formPanel.title
            }

            Column {
                id: panelBody
                width: parent.width
                spacing: Theme.spacing.md
            }
        }
    }

    Column {
        id: page

        width: root.width
        spacing: Theme.spacing.xl

        FormPanel {
            objectName: "merce.playground.forms.fieldStates"
            width: page.width
            title: "Field states"

            Flow {
                id: fieldStateFlow
                width: parent.width
                spacing: Theme.spacing.md

                FieldBlock {
                    width: root.compactLayout
                           ? fieldStateFlow.width
                           : (fieldStateFlow.width - fieldStateFlow.spacing) / 2
                    label: "Default"

                    SK.TextField {
                        objectName: "merce.playground.forms.field.default"
                        width: parent.width
                        placeholderText: "Enter text"
                    }
                }

                FieldBlock {
                    width: root.compactLayout
                           ? fieldStateFlow.width
                           : (fieldStateFlow.width - fieldStateFlow.spacing) / 2
                    label: "Focused"
                    helperText: "Keyboard focus uses outline.focus"

                    SK.TextField {
                        id: focusedField
                        objectName: "merce.playground.forms.field.focused"
                        width: parent.width
                        text: "Focused value"
                        Component.onCompleted: Qt.callLater(forceActiveFocus)
                    }
                }

                FieldBlock {
                    width: root.compactLayout
                           ? fieldStateFlow.width
                           : (fieldStateFlow.width - fieldStateFlow.spacing) / 2
                    label: "Error"
                    helperText: "This field is required"
                    helperColor: Theme.colors.status.error.content

                    SK.TextField {
                        objectName: "merce.playground.forms.field.error"
                        width: parent.width
                        text: "Invalid value"
                        SK.StyleVariation.variations: ["error"]
                    }
                }

                FieldBlock {
                    width: root.compactLayout
                           ? fieldStateFlow.width
                           : (fieldStateFlow.width - fieldStateFlow.spacing) / 2
                    label: "Disabled"

                    SK.TextField {
                        objectName: "merce.playground.forms.field.disabled"
                        width: parent.width
                        text: "Cannot edit"
                        enabled: false
                    }
                }
            }
        }

        Flow {
            id: formPanels
            width: page.width
            spacing: Theme.spacing.xl

            FormPanel {
                objectName: "merce.playground.forms.controls"
                width: root.compactLayout
                       ? formPanels.width
                       : (formPanels.width - formPanels.spacing) / 2
                title: "Form controls"

                FieldBlock {
                    width: parent.width
                    label: "Category"

                    SK.ComboBox {
                        objectName: "merce.playground.forms.combo"
                        width: parent.width
                        currentValue: "general"
                        model: [
                            { "value": "general", "label": "General" },
                            { "value": "account", "label": "Account" },
                            { "value": "billing", "label": "Billing" }
                        ]
                        textRole: "label"
                        valueRole: "value"
                    }
                }

                FieldBlock {
                    width: parent.width
                    label: "Notes"
                    helperText: notesField.length + " / 200"

                    SK.TextArea {
                        id: notesField
                        objectName: "merce.playground.forms.textArea"
                        width: parent.width
                        height: 104
                        placeholderText: "Add a short note"
                        wrapMode: TextEdit.Wrap
                    }
                }

                SK.CheckBox {
                    objectName: "merce.playground.forms.checkbox"
                    text: "Enable notifications"
                    checked: true
                }
                SK.CheckBox {
                    text: "Update automatically"
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.BodySmall
                    text: "Delivery"
                    color: Theme.colors.content.secondary
                }
                SK.RadioButton {
                    objectName: "merce.playground.forms.radio.standard"
                    text: "Standard"
                    checked: root.deliveryOption === "standard"
                    onClicked: root.deliveryOption = "standard"
                }
                SK.RadioButton {
                    objectName: "merce.playground.forms.radio.express"
                    text: "Express"
                    checked: root.deliveryOption === "express"
                    onClicked: root.deliveryOption = "express"
                }

                SK.Switch {
                    objectName: "merce.playground.forms.switch"
                    text: "Remember settings"
                    checked: true
                }
            }

            FormPanel {
                objectName: "merce.playground.forms.validation"
                width: root.compactLayout
                       ? formPanels.width
                       : (formPanels.width - formPanels.spacing) / 2
                title: "Validation example"

                FieldBlock {
                    width: parent.width
                    label: "Email"

                    SK.TextField {
                        id: validationEmail
                        objectName: "merce.playground.forms.validation.email"
                        width: parent.width
                        text: "user@example.com"
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /.+@.+\..+/
                        }
                        SK.StyleVariation.variations: acceptableInput ? ["success"] : ["error"]
                    }
                }

                FieldBlock {
                    width: parent.width
                    label: "Password"
                    helperText: "Minimum 8 characters"

                    SK.TextField {
                        id: validationPassword
                        objectName: "merce.playground.forms.validation.password"
                        width: parent.width
                        text: "merce1234"
                        echoMode: TextInput.Password
                        SK.StyleVariation.variations: text.length >= 8 ? ["success"] : ["error"]
                    }
                }

                FieldBlock {
                    width: parent.width
                    label: "Confirm password"
                    helperText: validationConfirm.text === validationPassword.text
                                ? "Passwords match"
                                : "Passwords do not match"
                    helperColor: validationConfirm.text === validationPassword.text
                                 ? Theme.colors.status.success.content
                                 : Theme.colors.status.error.content

                    SK.TextField {
                        id: validationConfirm
                        objectName: "merce.playground.forms.validation.confirm"
                        width: parent.width
                        text: "merce1234"
                        echoMode: TextInput.Password
                        SK.StyleVariation.variations: text === validationPassword.text
                                                      ? ["success"]
                                                      : ["error"]
                    }
                }

                Row {
                    anchors.right: parent.right
                    spacing: Theme.spacing.sm

                    MButton {
                        text: "Cancel"
                        variant: MButton.Ghost
                        size: MButton.Small
                        onClicked: {
                            validationEmail.clear()
                            validationPassword.clear()
                            validationConfirm.clear()
                        }
                    }
                    MButton {
                        objectName: "merce.playground.forms.validation.save"
                        text: "Save"
                        size: MButton.Small
                        enabled: root.validationValid
                    }
                }
            }
        }
    }
}
