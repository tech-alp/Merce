import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Merce.Theme
import Merce.Foundation

T.Button {
    id: root

    property bool current: false

    readonly property color contentColor: root.current ? Theme.colors.action.primary.container
                                                       : Theme.colors.content.secondary
    readonly property color transparentContainer: Qt.rgba(Theme.colors.surface.container.r,
                                                          Theme.colors.surface.container.g,
                                                          Theme.colors.surface.container.b,
                                                          0)
    readonly property color transparentFocusOutline: Qt.rgba(Theme.colors.outline.focus.r,
                                                             Theme.colors.outline.focus.g,
                                                             Theme.colors.outline.focus.b,
                                                            0)
    readonly property color containerColor: {
        if (!root.enabled)
            return root.transparentContainer
        if (root.current)
            return root.stateLayer(Theme.state.layer.selected)
        if (root.pressed)
            return root.stateLayer(Theme.state.layer.pressed)
        if (root.visualFocus)
            return root.stateLayer(Theme.state.layer.focus)
        if (root.hovered)
            return root.stateLayer(Theme.state.layer.hover)
        return root.transparentContainer
    }
    readonly property color outlineColor: root.visualFocus ? Theme.colors.outline.focus : root.transparentFocusOutline
    readonly property int outlineWidth: root.visualFocus ? 2 : 0
    readonly property real iconSize: Theme.icons.small

    function stateLayer(opacity) {
        return Qt.tint(Theme.colors.surface.container,
                       Qt.alpha(Theme.colors.content.primary, opacity))
    }

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
            color: root.enabled ? root.contentColor : Theme.colors.content.disabled
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
        }

        AppLabel {
            text: root.text
            textType: AppLabel.Button
            color: root.enabled ? root.contentColor : Theme.colors.content.disabled
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
