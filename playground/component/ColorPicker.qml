import QtQuick
import Merce.Theme
import Merce.Foundation

Item {
    id: root

    property string label: ""
    property color selectedColor: "#E4572E"
    property string usage: ""

    signal colorEdited(color value)

    readonly property string hexValue: toHex(selectedColor)
    property real hue: 0
    property real saturation: 1
    property real brightness: 1
    property bool syncing: false

    width: parent ? parent.width : 320
    height: contentColumn.implicitHeight

    function channel(value) {
        return Math.max(0, Math.min(255, Math.round(value * 255)))
    }

    function hexByte(value) {
        return channel(value).toString(16).padStart(2, "0").toUpperCase()
    }

    function toHex(value) {
        return "#" + hexByte(value.r) + hexByte(value.g) + hexByte(value.b)
    }

    function normalizeHex(value) {
        const text = String(value || "").trim()
        if (/^#[0-9a-fA-F]{6}$/.test(text))
            return text.toUpperCase()
        if (/^[0-9a-fA-F]{6}$/.test(text))
            return "#" + text.toUpperCase()
        return ""
    }

    function setFromHex(value) {
        const normalized = normalizeHex(value)
        if (normalized === "")
            return false

        selectedColor = normalized
        syncHsvFromColor()
        colorEdited(selectedColor)
        return true
    }

    function setFromHsv(nextHue, nextSaturation, nextBrightness) {
        syncing = true
        hue = Math.max(0, Math.min(1, nextHue))
        saturation = Math.max(0, Math.min(1, nextSaturation))
        brightness = Math.max(0, Math.min(1, nextBrightness))
        selectedColor = Qt.hsva(hue, saturation, brightness, 1)
        syncing = false
        colorEdited(selectedColor)
    }

    function syncHsvFromColor() {
        if (syncing)
            return

        const r = selectedColor.r
        const g = selectedColor.g
        const b = selectedColor.b
        const maxChannel = Math.max(r, g, b)
        const minChannel = Math.min(r, g, b)
        const delta = maxChannel - minChannel

        brightness = maxChannel
        saturation = maxChannel === 0 ? 0 : delta / maxChannel

        if (delta === 0) {
            hue = 0
        } else if (maxChannel === r) {
            hue = ((g - b) / delta + (g < b ? 6 : 0)) / 6
        } else if (maxChannel === g) {
            hue = ((b - r) / delta + 2) / 6
        } else {
            hue = ((r - g) / delta + 4) / 6
        }
    }

    onSelectedColorChanged: syncHsvFromColor()
    Component.onCompleted: syncHsvFromColor()

    Column {
        id: contentColumn
        width: parent.width
        spacing: Theme.spacing.sm

        Row {
            width: parent.width
            spacing: Theme.spacing.sm

            Rectangle {
                width: 36
                height: 36
                radius: Theme.radius.medium
                color: root.selectedColor
                border.width: 1
                border.color: Theme.colors.outline.subtle
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                width: parent.width - 36 - Theme.spacing.sm - hexBox.width - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.label
                    color: Theme.colors.content.primary
                    wrapMode: Text.WordWrap
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.usage
                    color: Theme.colors.content.secondary
                    visible: root.usage.length > 0
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                id: hexBox
                width: 96
                height: Theme.spacing.touchTargetCompact
                radius: Theme.radius.input
                color: Theme.colors.surface.container
                border.width: 1
                border.color: hexInput.activeFocus ? Theme.colors.outline.focus : Theme.colors.outline.subtle
                anchors.verticalCenter: parent.verticalCenter

                TextInput {
                    id: hexInput
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Theme.spacing.sm
                    }
                    text: root.hexValue
                    color: Theme.colors.content.primary
                    selectedTextColor: Theme.colors.content.inverse
                    selectionColor: Theme.colors.action.primary.container
                    font.family: FoundationFonts.resolveFamily(Theme.typography.fontMono)
                    font.pixelSize: Theme.typography.sizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    maximumLength: 7
                    selectByMouse: true
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhPreferUppercase

                    onEditingFinished: {
                        if (!root.setFromHex(text))
                            text = root.hexValue
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: 112

            Rectangle {
                id: colorPlane
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    right: hueTrack.left
                    rightMargin: Theme.spacing.sm
                }
                radius: Theme.radius.medium
                color: Qt.hsva(root.hue, 1, 1, 1)
                border.width: 1
                border.color: Theme.colors.outline.subtle

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: "#FFFFFFFF" }
                        GradientStop { position: 1; color: "#00FFFFFF" }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#00000000" }
                        GradientStop { position: 1; color: "#FF000000" }
                    }
                }

                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    x: Math.max(0, Math.min(parent.width - width, root.saturation * parent.width - width / 2))
                    y: Math.max(0, Math.min(parent.height - height, (1 - root.brightness) * parent.height - height / 2))
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.colors.content.inverse
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: updateColor(mouse.x, mouse.y)
                    onPositionChanged: if (pressed) updateColor(mouse.x, mouse.y)

                    function updateColor(x, y) {
                        root.setFromHsv(root.hue, x / width, 1 - y / height)
                    }
                }
            }

            Rectangle {
                id: hueTrack
                width: 22
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }
                radius: Theme.radius.full
                border.width: 1
                border.color: Theme.colors.outline.subtle
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#FF0000" }
                    GradientStop { position: 0.17; color: "#FFFF00" }
                    GradientStop { position: 0.33; color: "#00FF00" }
                    GradientStop { position: 0.50; color: "#00FFFF" }
                    GradientStop { position: 0.67; color: "#0000FF" }
                    GradientStop { position: 0.83; color: "#FF00FF" }
                    GradientStop { position: 1.00; color: "#FF0000" }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Math.max(0, Math.min(parent.height - height, root.hue * parent.height - height / 2))
                    width: parent.width + 6
                    height: 8
                    radius: 4
                    color: Theme.colors.surface.container
                    border.width: 1
                    border.color: Theme.colors.outline.strong
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: updateHue(mouse.y)
                    onPositionChanged: if (pressed) updateHue(mouse.y)

                    function updateHue(y) {
                        root.setFromHsv(y / height, root.saturation, root.brightness)
                    }
                }
            }
        }

        Flow {
            width: parent.width
            spacing: Theme.spacing.xs

            Repeater {
                model: ["#E4572E", "#1F5D3A", "#FAFAFA", "#1A1C1E", "#22A06B", "#F5A623", "#D64545", "#5A8FC4"]

                Rectangle {
                    required property string modelData

                    width: 26
                    height: 26
                    radius: Theme.radius.small
                    color: modelData
                    border.width: 1
                    border.color: Theme.colors.outline.subtle

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.setFromHex(parent.color)
                    }
                }
            }
        }
    }
}
