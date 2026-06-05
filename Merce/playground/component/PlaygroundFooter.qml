import QtQuick
import Merce.Core
import Merce.Foundation

Rectangle {
    id: root

    property string activePage: ""
    property string activeTheme: ""
    property int stackDepth: 0

    color: Theme.colors.background.surface

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 1
        color: Theme.colors.border.base
    }

    Row {
        anchors {
            left: parent.left
            leftMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacing.lg

        ThemedText {
            type: "caption"
            text: root.activePage
            textColor: Theme.colors.text.primary
        }

        ThemedText {
            type: "caption"
            text: root.activeTheme
            textColor: Theme.colors.text.secondary
        }
    }

    ThemedText {
        anchors {
            right: parent.right
            rightMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        type: "caption"
        text: "Stack " + root.stackDepth
        textColor: Theme.colors.text.tertiary
    }
}
