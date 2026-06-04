import QtQuick
import Merce.Core
import Merce.Foundation

Item {
    id: root

    property string text: ""
    property string icon: "material:circle"
    property bool checked: false
    property color hoverColor: Theme.palette.background.hover

    signal clicked()

    height: Theme.spacing.touchTargetCompact
    opacity: enabled ? 1.0 : 0.45
    Accessible.role: Accessible.Button
    Accessible.name: root.text

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radius.medium
        color: {
            if (root.checked)
                return Theme.palette.action.light("primary")
            if (mouseArea.containsMouse)
                return root.hoverColor
            return "transparent"
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }

    Row {
        anchors {
            fill: parent
            leftMargin: Theme.spacing.md
            rightMargin: Theme.spacing.md
        }
        spacing: Theme.spacing.sm

        AppIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: Theme.icons.small
            color: root.checked ? Theme.palette.actionPrimary : Theme.palette.text.secondary
        }

        MText {
            width: parent.width - Theme.icons.small - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            type: "body"
            text: root.text
            textColor: root.checked ? Theme.palette.actionPrimary : Theme.palette.textPrimary
            wrap: "word"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
