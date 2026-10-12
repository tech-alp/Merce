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
    readonly property bool compact: width < 960
    implicitHeight: compact ? titleText.implicitHeight + selectorRow.height + 32
                            : Math.max(76, selectorRow.height + 24, titleText.implicitHeight + 24)

    AppLabel {
        id: titleText
        objectName: "merce.playground.header.title"
        anchors {
            left: parent.left
            leftMargin: Theme.spacing.xl
            top: root.compact ? parent.top : undefined
            topMargin: 8
            verticalCenter: root.compact ? undefined : parent.verticalCenter
        }
        width: root.compact ? parent.width - Theme.spacing.xl * 2 : Math.max(160, parent.width - selectorRow.width - Theme.spacing.xl * 3)
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
            bottom: root.compact ? parent.bottom : undefined
            bottomMargin: 12
            verticalCenter: root.compact ? undefined : parent.verticalCenter
        }
        spacing: Theme.spacing.sm

        ProfileSelector {
            objectName: "merce.playground.header.profileSelect"
            width: 190
            StyleVariation.variations: ["small"]
        }

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
