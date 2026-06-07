import QtQuick
import Merce.Theme
import Merce.Foundation

Item {
    id: root

    property string text: ""
    property string variant: "neutral" // neutral, primary, success, warning, error, info
    property string size: "medium"     // small, medium
    property string icon: ""

    readonly property var sizeConfig: {
        "small": {
            "height": 24,
            "paddingH": Theme.spacing.xs,
            "gap": Theme.spacing.xxs,
            "textType": AppLabel.Caption,
            "iconSize": Theme.icons.small
        },
        "medium": {
            "height": 28,
            "paddingH": Theme.spacing.sm,
            "gap": Theme.spacing.xs,
            "textType": AppLabel.BodySmall,
            "iconSize": Theme.icons.small
        }
    }
    readonly property var currentSize: sizeConfig[size] || sizeConfig.medium
    readonly property color badgeBackgroundColor: backgroundFor(variant)
    readonly property color badgeForegroundColor: foregroundFor(variant)
    readonly property color badgeBorderColor: borderFor(variant)

    implicitWidth: contentRow.implicitWidth + currentSize.paddingH * 2
    implicitHeight: currentSize.height
    width: implicitWidth
    height: implicitHeight

    Accessible.role: Accessible.StaticText
    Accessible.name: root.text

    function backgroundFor(value) {
        if (value === "primary")
            return Theme.colors.action.primaryHover
        if (value === "success")
            return Theme.colors.status.successSubtle
        if (value === "warning")
            return Theme.colors.status.warningSubtle
        if (value === "error")
            return Theme.colors.status.errorSubtle
        if (value === "info")
            return Theme.colors.status.infoSubtle
        return Theme.colors.background.hover
    }

    function foregroundFor(value) {
        if (value === "primary")
            return Theme.colors.action.primaryPressed
        if (value === "success")
            return Theme.colors.status.success
        if (value === "warning")
            return Theme.colors.text.primary
        if (value === "error")
            return Theme.colors.status.error
        if (value === "info")
            return Theme.colors.status.info
        return Theme.colors.text.secondary
    }

    function borderFor(value) {
        if (value === "primary")
            return Theme.colors.action.primary
        if (value === "success")
            return Theme.colors.status.success
        if (value === "warning")
            return Theme.colors.status.warning
        if (value === "error")
            return Theme.colors.status.error
        if (value === "info")
            return Theme.colors.status.info
        return Theme.colors.border.base
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.badge
        color: root.badgeBackgroundColor
        border.width: 1
        border.color: root.badgeBorderColor
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.currentSize.gap

        AppIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: root.currentSize.iconSize
            color: root.badgeForegroundColor
            visible: root.icon !== ""
        }

        AppLabel {
            anchors.verticalCenter: parent.verticalCenter
            textType: root.currentSize.textType
            text: root.text
            color: root.badgeForegroundColor
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }
}
