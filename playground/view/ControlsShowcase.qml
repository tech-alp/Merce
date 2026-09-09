import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.controls"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    property int checkboxState: Qt.PartiallyChecked
    property bool radioValue: true
    property bool switchValue: true

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.content.primary
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

            MButton {
                objectName: "merce.playground.controls.button.primary"
                text: "Primary"
            }
            MButton {
                objectName: "merce.playground.controls.button.secondary"
                text: "Secondary"
                variant: MButton.Secondary
            }
            MButton {
                objectName: "merce.playground.controls.button.outline"
                text: "Outline"
                variant: MButton.Outline
            }
            MButton {
                objectName: "merce.playground.controls.button.ghost"
                text: "Ghost"
                variant: MButton.Ghost
            }
            MButton {
                objectName: "merce.playground.controls.button.destructive"
                text: "Destructive"
                variant: MButton.Destructive
            }
            MButton {
                objectName: "merce.playground.controls.button.disabled"
                text: "Disabled"
                enabled: false
            }
            MButton {
                objectName: "merce.playground.controls.button.loading"
                text: "Loading"
                loading: true
                enabled: false
            }
            MButton {
                objectName: "merce.playground.controls.button.materialIcon"
                text: "Material icon"
                iconName: "material:save"
                iconPosition: MButton.IconLeft
            }
            MButton {
                objectName: "merce.playground.controls.button.topIcon"
                text: "Top icon"
                iconName: "material:arrow_upward"
                iconPosition: MButton.IconTop
            }
            MButton {
                objectName: "merce.playground.controls.button.rightIcon"
                text: "Right icon"
                iconName: "material:arrow_forward"
                iconPosition: MButton.IconRight
            }
        }

        DemoSection {
            title: "Button sizes"

            MButton {
                objectName: "merce.playground.controls.button.small"
                text: "Small"
                size: MButton.Small
            }
            MButton {
                objectName: "merce.playground.controls.button.medium"
                text: "Medium"
            }
            MButton {
                objectName: "merce.playground.controls.button.large"
                text: "Large"
                size: MButton.Large
            }
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
                variant: MBadge.Primary
                icon: "material:palette"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.success"
                text: "Live"
                variant: MBadge.Success
                icon: "material:check_circle"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.warning"
                text: "Beta"
                variant: MBadge.Warning
            }

            MBadge {
                objectName: "merce.playground.controls.badge.error"
                text: "Error"
                variant: MBadge.Error
                icon: "material:error"
            }

            MBadge {
                objectName: "merce.playground.controls.badge.info"
                text: "Info"
                variant: MBadge.Info
            }

            MBadge {
                objectName: "merce.playground.controls.badge.small"
                text: "Small"
                size: MBadge.Small
            }
        }

        DemoSection {
            title: "Inputs"

            SK.TextField {
                objectName: "merce.playground.controls.input.email"
                width: 300
                placeholderText: "Email"
                text: "theme@merce.local"
                inputMethodHints: Qt.ImhEmailCharactersOnly
                leftPadding: Theme.spacing.xl2
                validator: RegularExpressionValidator {
                    regularExpression: /.+@.+\..+/
                }

                AppIcon {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.spacing.md
                        verticalCenter: parent.verticalCenter
                    }
                    name: "material:mail"
                    size: Theme.icons.medium
                    color: Theme.colors.content.tertiary
                }
            }

            SK.TextField {
                objectName: "merce.playground.controls.input.success"
                width: 300
                placeholderText: "Success"
                text: "Valid value"
                rightPadding: Theme.spacing.xl2
                SK.StyleVariation.variations: ["success"]

                AppIcon {
                    anchors {
                        right: parent.right
                        rightMargin: Theme.spacing.md
                        verticalCenter: parent.verticalCenter
                    }
                    name: "material:check_circle"
                    size: Theme.icons.medium
                    color: Theme.colors.status.success.content
                }
            }

            SK.TextField {
                objectName: "merce.playground.controls.input.error"
                width: 300
                placeholderText: "Error"
                text: "invalid"
                rightPadding: Theme.spacing.xl2
                SK.StyleVariation.variations: ["error"]

                AppIcon {
                    anchors {
                        right: parent.right
                        rightMargin: Theme.spacing.md
                        verticalCenter: parent.verticalCenter
                    }
                    name: "material:error"
                    size: Theme.icons.medium
                    color: Theme.colors.status.error.content
                }
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
                color: Theme.colors.status.success.content
            }

            AppIcon {
                name: "material:wallet"
                size: Theme.icons.large
                color: Theme.colors.content.primary
            }

            AppIcon {
                name: "material:dark_mode"
                size: Theme.icons.large
                color: Theme.colors.content.primary
            }
        }

        DemoSection {
            title: "Selection"

            SK.CheckBox {
                objectName: "merce.playground.controls.selection.checkbox"
                text: "Checkbox"
                tristate: true
                checkState: root.checkboxState
                nextCheckState: function() {
                    return checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked
                }
                SK.StyleVariation.variations: checkState === Qt.PartiallyChecked ? ["indeterminate"] : []
                onCheckStateChanged: root.checkboxState = checkState
            }

            SK.RadioButton {
                objectName: "merce.playground.controls.selection.radio"
                text: "Radio"
                checked: root.radioValue
                onToggled: root.radioValue = checked
            }

            SK.Switch {
                objectName: "merce.playground.controls.selection.switch"
                text: "Switch"
                checked: root.switchValue
                onToggled: root.switchValue = checked
            }

            SK.ComboBox {
                objectName: "merce.playground.controls.selection.combo"
                width: 300
                currentValue: "runtime"
                model: [
                    { "value": "runtime", "label": "Runtime theme" },
                    { "value": "gallery", "label": "Gallery proof" },
                    { "value": "export", "label": "Export evidence" }
                ]
                textRole: "label"
                valueRole: "value"
            }
        }
    }
}
