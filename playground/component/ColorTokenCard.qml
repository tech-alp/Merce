import QtQuick
import Qt.labs.StyleKit
import QtQuick.Effects
import Merce.Theme
import Merce.Foundation
import Merce.Controls

FocusScope {
    id: root

    property string tokenPath: ""
    property string usage: ""
    property color selectedColor: "#E4572E"
    property bool editable: true
    property bool compact: false

    signal colorEdited(color value)

    readonly property string hexValue: toHex(selectedColor)
    readonly property bool narrow: width < 240
    readonly property bool editorOpen: pickerPopup.visible

    objectName: "merce.playground.colorTokenCard." + tokenPath
    width: parent ? parent.width : 280
    implicitWidth: 280
    implicitHeight: card.height
    activeFocusOnTab: editable

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
        if (!editable)
            return
        pickerPopup.open()
    }

    function closeEditor() {
        pickerPopup.close()
    }

    Surface {
        id: card

        width: parent.width
        height: root.compact ? 136 : 184
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large
        backgroundColor: Theme.colors.surface.container
        borderWidth: root.activeFocus ? 2 : 1
        borderColor: root.activeFocus ? Theme.colors.outline.focus
                                      : root.editable && cardHover.hovered ? Theme.colors.outline.strong : Theme.colors.outline.subtle

        layer.enabled: root.editable
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.colors.surface.shadow
            shadowBlur: 0.7
            shadowOpacity: root.editable && (cardHover.hovered || pickerPopup.visible) ? 0.35 : 0.22
        }

        Rectangle {
            id: swatch

            anchors {
                left: parent.left
                right: root.compact ? undefined : parent.right
                top: parent.top
                bottom: root.compact ? parent.bottom : undefined
            }
            width: root.compact ? 80 : parent.width
            height: root.compact ? parent.height : 92
            topLeftRadius: parent.radius - 1
            topRightRadius: root.compact ? 0 : parent.radius - 1
            bottomLeftRadius: root.compact ? parent.radius - 1 : 0
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
                visible: root.editable

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
                top: root.compact ? parent.top : swatch.bottom
                bottom: parent.bottom
                margins: Theme.spacing.md
            }
            anchors.leftMargin: root.compact ? swatch.width + Theme.spacing.md : Theme.spacing.md
            spacing: Theme.spacing.xxs

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.tokenPath
                color: Theme.colors.content.primary
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.usage
                color: Theme.colors.content.secondary
                wrapMode: Text.WordWrap
                maximumLineCount: root.compact || root.narrow ? 1 : 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            AppLabel {
                width: parent.width
                textType: AppLabel.Caption
                text: root.hexValue
                color: Theme.colors.content.secondary
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontMono)
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
        }

        HoverHandler {
            id: cardHover
            enabled: root.editable
        }

        TapHandler {
            enabled: root.editable
            onTapped: root.openEditor()
        }
    }

    Popup {
        id: pickerPopup

        popupType: Popup.Item
        y: root.height + Theme.spacing.xs
        width: Math.max(root.width, 340)
        padding: Theme.spacing.md
        modal: false
        dim: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        z: Theme.zIndex.dropdown

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
                    size: MButton.Small
                    onClicked: pickerPopup.close()
                }
            }
        }
    }
}
