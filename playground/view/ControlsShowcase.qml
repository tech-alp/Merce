import QtQuick
import Merce.Theme
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

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.text.primary
        wrapMode: Text.WordWrap
    }

    component DemoSection: Surface {
        required property string title
        default property alias content: sectionContent.data

        width: page.width
        height: sectionColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: Surface.Default
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

            MButton { text: "Primary"; variant: MButton.Primary }
            MButton { text: "Secondary"; variant: MButton.Secondary }
            MButton { text: "Outline"; variant: MButton.Outline }
            MButton { text: "Ghost"; variant: MButton.Ghost }
            MButton { text: "Destructive"; variant: MButton.Destructive }
            MButton { text: "Disabled"; enabled: false }
            MButton { text: "Loading"; isLoading: true }
            MButton { text: "With icon"; icon.name: "material:check" }
            MButton {
                text: "Top icon"
                icon.name: "material:dashboard"
                iconPosition: MButton.IconTop
            }
            MButton {
                text: "Right icon"
                icon.name: "material:dashboard"
                iconPosition: MButton.IconRight
            }
        }

        DemoSection {
            title: "Button sizes"

            MButton { text: "Small"; size: MButton.Small }
            MButton { text: "Medium"; size: MButton.Medium }
            MButton { text: "Large"; size: MButton.Large }
        }

        DemoSection {
            title: "Badges"

            MBadge {
                objectName: "merce.playground.controls.badge.neutral"
                text: "Neutral"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.primary"
                text: "Primary"
                variant: "primary"
                icon: "material:palette"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.success"
                text: "Live"
                variant: "success"
                icon: "material:check_circle"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.warning"
                text: "Beta"
                variant: "warning"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.error"
                text: "Error"
                variant: "error"
                icon: "material:error"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.info"
                text: "Info"
                variant: "info"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.small"
                text: "Small"
                size: "small"
            }
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
                color: Theme.colors.action.primary.container
            }

            AppIcon {
                name: "status:check"
                size: Theme.icons.large
                color: Theme.colors.status.success.foreground
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
