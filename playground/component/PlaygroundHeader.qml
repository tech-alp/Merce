import QtQuick
import Qt.labs.StyleKit
import Merce.Theme
import Merce.Foundation

Rectangle {
    id: root

    property string pageTitle: ""
    property var themeOptions: []
    property var modeOptions: []

    signal themeSelected(var value)
    signal modeSelected(var value)

    color: Theme.colors.surface.canvas

    AppLabel {
        id: titleText
        anchors {
            left: parent.left
            leftMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        width: Math.max(160, parent.width - selectorRow.width - Theme.spacing.xl * 3)
        textType: AppLabel.H3
        text: root.pageTitle
        color: Theme.colors.content.primary
        wrapMode: Text.WordWrap
    }

    Row {
        id: selectorRow
        anchors {
            right: parent.right
            rightMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacing.sm

        ComboBox {
            objectName: "merce.playground.header.themeSelect"
            width: 230
            StyleVariation.variations: ["small"]
            model: root.themeOptions
            textRole: "label"
            valueRole: "value"
            currentValue: Theme.activeBrand
            onActivated: {
                root.themeSelected(currentValue)
            }
        }

        ComboBox {
            objectName: "merce.playground.header.modeSelect"
            width: 150
            StyleVariation.variations: ["small"]
            visible: root.modeOptions.length > 0
            model: root.modeOptions
            textRole: "label"
            valueRole: "value"
            currentValue: Theme.activeMode
            onActivated: {
                root.modeSelected(currentValue)
            }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Theme.colors.outline.subtle
    }
}
