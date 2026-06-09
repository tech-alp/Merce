import QtQuick
import QtQuick.Layouts
import Merce.Theme
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

        AppLabel {
            textType: AppLabel.Caption
            text: root.activePage
            color: Theme.colors.text.primary
        }

        AppLabel {
            textType: AppLabel.Caption
            text: root.activeTheme
            color: Theme.colors.text.secondary
        }
    }

    AppLabel {
        anchors {
            right: parent.right
            rightMargin: Theme.spacing.xl
            verticalCenter: parent.verticalCenter
        }
        textType: AppLabel.Caption
        text: "Stack " + root.stackDepth
        color: Theme.colors.text.tertiary
    }
}
