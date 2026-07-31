import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Effects
import Merce.Theme
import Merce.Foundation
import Merce.Controls

FocusScope {
    id: root

    property string tokenPath: ""
    property string usage: ""
    property color selectedColor: "#E4572E"

    signal colorEdited(color value)

    readonly property string hexValue: toHex(selectedColor)
    readonly property bool narrow: width < 240
    readonly property bool editorOpen: pickerPopup.visible

    objectName: "merce.playground.colorTokenCard." + tokenPath
    width: parent ? parent.width : 280
    implicitWidth: 280
    implicitHeight: card.height
    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: qsTr("Edit %1").arg(tokenPath)
    Keys.onReturnPressed: openEditor()
    Keys.onEnterPressed: openEditor()
    Keys.onSpacePressed: openEditor()

    function channel(value) {
        return Math.max(0, Math.min(255, Math.round(value * 255)))
    }

    function hexByte(value) {
        return channel(value).toString(16).padStart(2, "0").toUpperCase()
    }

    function toHex(value) {
        const text = String(value || "").trim()
        if (/^#[0-9a-fA-F]{6}$/.test(text))
            return text.toUpperCase()
        return "#" + hexByte(value.r) + hexByte(value.g) + hexByte(value.b)
    }

    function openEditor() {
        pickerPopup.open()
    }

    function closeEditor() {
        pickerPopup.close()
    }

    Surface {
        id: card

        width: parent.width
        height: 184
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large
        backgroundColor: Theme.colors.surface.base
        borderWidth: root.activeFocus ? 2 : 1
        borderColor: root.activeFocus ? Theme.colors.border.focus
                                      : cardHover.hovered ? Theme.colors.border.strong : Theme.colors.border.base

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#26000000"
            shadowBlur: 0.7
            shadowOpacity: cardHover.hovered || pickerPopup.visible ? 0.35 : 0.22
        }

        Rectangle {
            id: swatch

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 92
            topLeftRadius: parent.radius - 1
            topRightRadius: parent.radius - 1
            bottomLeftRadius: 0
            bottomRightRadius: 0
            color: root.selectedColor

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: Theme.spacing.sm
                }
                width: Theme.spacing.touchTargetCompact
                height: Theme.spacing.touchTargetCompact
                radius: Theme.radius.full
                color: "#CCFFFFFF"
                border.width: 1
                border.color: "#66FFFFFF"

                AppIcon {
                    anchors.centerIn: parent
                    name: "material:edit"
                    size: Theme.icons.small
                    color: "#4B3A2F"
                }
            }
        }

        Column {
            anchors {
                left: parent.left
                right: parent.right
                top: swatch.bottom
                bottom: parent.bottom
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.xxs

            AppLabel {
                width: parent.width
                textType: AppLabel.Body
                text: root.tokenPath
                color: Theme.colors.text.primary
                wrapMode: Text.WordWrap
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.usage
                color: Theme.colors.text.secondary
                wrapMode: Text.WordWrap
                maximumLineCount: root.narrow ? 1 : 2
                elide: Text.ElideRight
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.hexValue
                color: Theme.colors.text.secondary
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontMono)
                elide: Text.ElideRight
            }
        }

        HoverHandler {
            id: cardHover
        }

        TapHandler {
            onTapped: root.openEditor()
        }
    }

    Basic.Popup {
        id: pickerPopup

        popupType: Basic.Popup.Item
        y: root.height + Theme.spacing.xs
        width: Math.max(root.width, 340)
        padding: Theme.spacing.md
        modal: false
        dim: false
        focus: true
        closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent
        z: Theme.zIndex.dropdown

        background: Rectangle {
            radius: Theme.radius.large
            color: Theme.colors.surface.base
            border.width: 1
            border.color: Theme.colors.border.base

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowBlur: 1.0
                shadowOpacity: 0.32
            }
        }

        contentItem: Column {
            spacing: Theme.spacing.md

            ColorPicker {
                width: pickerPopup.width - pickerPopup.leftPadding - pickerPopup.rightPadding
                label: root.tokenPath
                usage: root.usage
                selectedColor: root.selectedColor
                onColorEdited: function(value) {
                    root.colorEdited(value)
                }
            }

            Row {
                width: parent.width

                Item {
                    width: Math.max(0, parent.width - doneButton.width)
                    height: doneButton.height
                }

                MButton {
                    id: doneButton

                    text: qsTr("Done")
                    icon.name: "material:check"
                    size: MButton.Small
                    onClicked: pickerPopup.close()
                }
            }
        }
    }
}
