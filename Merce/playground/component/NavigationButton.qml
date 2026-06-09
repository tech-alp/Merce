import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Merce.Theme
import Merce.Foundation

T.Button {
    id: root

    property bool current: false

    readonly property color contentColor: root.current ? Theme.colors.action.primary
                                                       : Theme.colors.text.secondary
    readonly property color transparentHoverBackground: Qt.rgba(Theme.colors.background.hover.r,
                                                                Theme.colors.background.hover.g,
                                                                Theme.colors.background.hover.b,
                                                                0)
    readonly property color transparentFocusBorder: Qt.rgba(Theme.colors.border.focus.r,
                                                            Theme.colors.border.focus.g,
                                                            Theme.colors.border.focus.b,
                                                            0)
    readonly property color containerColor: {
        if (!root.enabled)
            return root.transparentHoverBackground
        if (root.current)
            return Theme.colors.background.hover
        if (root.pressed)
            return Theme.colors.background.pressed
        if (root.hovered || root.visualFocus)
            return Theme.colors.background.hover
        return root.transparentHoverBackground
    }
    readonly property color outlineColor: root.visualFocus ? Theme.colors.border.focus : root.transparentFocusBorder
    readonly property int outlineWidth: root.visualFocus ? 2 : 0
    readonly property real iconSize: Theme.icons.small

    checkable: false
    implicitHeight: Theme.spacing.touchTargetCompact
    implicitWidth: Math.max(Theme.spacing.touchTargetCompact, contentItem.implicitWidth + leftPadding + rightPadding)
    leftPadding: Theme.spacing.md
    rightPadding: Theme.spacing.md
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: root.enabled
    focusPolicy: Qt.StrongFocus
    Accessible.role: Accessible.Button
    Accessible.name: root.text

    contentItem: RowLayout {
        spacing: Theme.spacing.sm

        AppIcon {
            name: root.icon.name.length > 0 ? root.icon.name : "material:circle"
            size: root.iconSize
            color: root.enabled ? root.contentColor : Theme.colors.text.disabled
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
        }

        AppLabel {
            text: root.text
            textType: AppLabel.Button
            color: root.enabled ? root.contentColor : Theme.colors.text.disabled
            wrapMode: Text.NoWrap
            maximumLineCount: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    background: Rectangle {
        radius: Theme.radius.medium
        color: root.containerColor
        border.width: root.outlineWidth
        border.color: root.outlineColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.motion.durationFast
                easing: Theme.motion.easingOut
            }
        }
    }
}
