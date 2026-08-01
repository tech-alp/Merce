import QtQuick
import Merce.Theme
import Merce.Foundation

Item {
    id: root

    enum Variant {
        Neutral,
        Primary,
        Success,
        Warning,
        Error,
        Info
    }

    enum Size {
        Small,
        Medium
    }

    property string text: ""
    property int variant: MBadge.Neutral
    property int size: MBadge.Medium
    property string icon: ""

    readonly property var colors: Theme.colors

    readonly property bool compact: root.size === MBadge.Small
    readonly property real badgeHeight: root.compact ? 24 : 28
    readonly property real horizontalPadding: root.compact ? Theme.spacing.xs : Theme.spacing.sm
    readonly property real contentGap: root.compact ? Theme.spacing.xxs : Theme.spacing.xs
    readonly property int labelType: root.compact ? AppLabel.Caption : AppLabel.BodySmall
    readonly property color badgeBackgroundColor: backgroundFor(variant)
    readonly property color badgeForegroundColor: foregroundFor(variant)
    readonly property color badgeBorderColor: borderFor(variant)

    implicitWidth: contentRow.implicitWidth + root.horizontalPadding * 2
    implicitHeight: root.badgeHeight
    width: implicitWidth
    height: implicitHeight

    Accessible.role: Accessible.StaticText
    Accessible.name: root.text

    function backgroundFor(value) {
        switch (value) {
        case MBadge.Primary:
            return Qt.alpha(root.colors.action.primary.container, 0.12)
        case MBadge.Success:
            return root.colors.status.success.container
        case MBadge.Warning:
            return root.colors.status.warning.container
        case MBadge.Error:
            return root.colors.status.error.container
        case MBadge.Info:
            return root.colors.status.info.container
        default:
            return root.colors.status.neutral.container
        }
    }

    function foregroundFor(value) {
        switch (value) {
        case MBadge.Primary:
            return root.colors.action.primary.container
        case MBadge.Success:
            return root.colors.status.success.content
        case MBadge.Warning:
            return root.colors.status.warning.content
        case MBadge.Error:
            return root.colors.status.error.content
        case MBadge.Info:
            return root.colors.status.info.content
        default:
            return root.colors.status.neutral.content
        }
    }

    function borderFor(value) {
        switch (value) {
        case MBadge.Primary:
            return root.colors.action.primary.outline
        case MBadge.Success:
            return root.colors.status.success.outline
        case MBadge.Warning:
            return root.colors.status.warning.outline
        case MBadge.Error:
            return root.colors.status.error.outline
        case MBadge.Info:
            return root.colors.status.info.outline
        default:
            return root.colors.status.neutral.outline
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.badge
        color: root.badgeBackgroundColor
        border.width: Theme.size.outline.hairline
        border.color: root.badgeBorderColor
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.contentGap

        AppIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: Theme.icons.small
            color: root.badgeForegroundColor
            visible: root.icon !== ""
        }

        AppLabel {
            anchors.verticalCenter: parent.verticalCenter
            textType: root.labelType
            text: root.text
            color: root.badgeForegroundColor
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }
}
