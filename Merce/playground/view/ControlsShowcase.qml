import QtQuick
import Merce.Core
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.controls"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    property bool checkboxValue: true
    property bool radioValue: true
    property bool switchValue: true

    component SectionTitle: ThemedText {
        type: "h4"
        textColor: Theme.colors.text.primary
        wrap: "word"
    }

    component DemoSection: Surface {
        required property string title
        default property alias content: sectionContent.data

        width: page.width
        height: sectionColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: types["default"]
        radiusValue: Theme.radius.large

        Column {
            id: sectionColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.xl
            }
            spacing: Theme.spacing.lg

            SectionTitle {
                width: parent.width
                text: title
            }

            Flow {
                id: sectionContent
                width: parent.width
                spacing: Theme.spacing.md
            }
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        DemoSection {
            title: "Buttons"

            MButton { text: "Primary"; variant: "primary" }
            MButton { text: "Secondary"; variant: "secondary" }
            MButton { text: "Outline"; variant: "outline" }
            MButton { text: "Ghost"; variant: "ghost" }
            MButton { text: "Destructive"; variant: "destructive" }
            MButton { text: "Disabled"; isDisabled: true }
            MButton { text: "Loading"; isLoading: true }
            MButton { text: "With icon"; icon: "material:check" }
        }

        DemoSection {
            title: "Button sizes"

            MButton { text: "Small"; size: "small" }
            MButton { text: "Medium"; size: "medium" }
            MButton { text: "Large"; size: "large" }
        }

        DemoSection {
            title: "Inputs"

            MInput {
                width: 300
                placeholder: "Email"
                text: "theme@merce.local"
                inputType: "email"
                icon: "material:mail"
            }

            MInput {
                width: 300
                placeholder: "Success"
                text: "Valid value"
                validationState: MInput.Success
                trailingIcon: "material:check_circle"
            }

            MInput {
                width: 300
                placeholder: "Error"
                text: "invalid"
                validationState: MInput.Error
                trailingIcon: "material:error"
            }
        }

        DemoSection {
            title: "Icons"

            AppIcon {
                name: "material:palette"
                size: Theme.icons.large
                color: Theme.colors.action.primary
            }

            AppIcon {
                name: "status:check"
                size: Theme.icons.large
                color: Theme.colors.status.success
            }

            AppIcon {
                name: "material:wallet"
                size: Theme.icons.large
                color: Theme.colors.text.primary
            }

            AppIcon {
                name: "material:dark_mode"
                size: Theme.icons.large
                color: Theme.colors.text.primary
            }
        }

        DemoSection {
            title: "Selection"

            MCheckbox {
                label: "Checkbox"
                checked: root.checkboxValue
                onToggled: function(checked) { root.checkboxValue = checked }
            }

            MRadio {
                label: "Radio"
                checked: root.radioValue
                onToggled: function(checked) { root.radioValue = checked }
            }

            MSwitch {
                label: "Switch"
                checked: root.switchValue
                onToggled: function(checked) { root.switchValue = checked }
            }

            MSelect {
                width: 300
                selectedValue: "runtime"
                options: [
                    { "value": "runtime", "label": "Runtime theme" },
                    { "value": "gallery", "label": "Gallery proof" },
                    { "value": "export", "label": "Export evidence" }
                ]
            }
        }
    }
}
