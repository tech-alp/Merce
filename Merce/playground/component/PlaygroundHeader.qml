import QtQuick
import Merce.Core
import Merce.Foundation
import Merce.Controls

Rectangle {
    id: root

    property string pageTitle: ""
    property var themeOptions: []
    property var modeOptions: []

    signal themeSelected(var value)
    signal modeSelected(var value)

    color: Theme.palette.backgroundBase

    ThemedText {
        id: titleText
        anchors {
            left: parent.left
            leftMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        width: Math.max(160, parent.width - selectorRow.width - Theme.spacing.xl * 3)
        type: "h3"
        text: root.pageTitle
        textColor: Theme.palette.textPrimary
        wrap: "word"
    }

    Row {
        id: selectorRow
        anchors {
            right: parent.right
            rightMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacing.sm

        MSelect {
            objectName: "merce.playground.header.themeSelect"
            width: 230
            selectedValue: Theme.activeBrand
            options: root.themeOptions
            onSelected: function(value) {
                root.themeSelected(value)
            }
        }

        MSelect {
            objectName: "merce.playground.header.modeSelect"
            width: 150
            visible: root.modeOptions.length > 0
            selectedValue: Theme.activeMode
            options: root.modeOptions
            onSelected: function(value) {
                root.modeSelected(value)
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
        color: Theme.palette.borderBase
    }
}
