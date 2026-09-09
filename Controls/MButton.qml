import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit

Button {
    id: root

    enum Variant {
        Primary,
        Secondary,
        Outline,
        Ghost,
        Destructive
    }

    enum Size {
        Small,
        Medium,
        Large
    }

    enum IconPosition {
        IconNone,
        IconLeft,
        IconRight,
        IconTop,
        IconOnly
    }

    property int variant: MButton.Primary
    property int size: MButton.Medium
    property int iconPosition: MButton.IconLeft
    property string iconName: ""
    property url iconSource: ""
    property bool loading: false
    property bool isLoading: root.loading
    property bool fullWidth: false
    property var extraVariations: []

    readonly property bool effectiveLoading: root.loading || root.isLoading
    readonly property var styleVariations: variationNames()

    icon.name: root.iconName
    icon.source: root.iconSource
    display: displayFor(root.iconPosition)

    Layout.fillWidth: root.fullWidth
    StyleVariation.variations: root.styleVariations

    Binding {
        target: root.contentItem
        property: "mirrored"
        value: root.iconPosition === MButton.IconRight
    }

    LoadingIndicator {
        objectName: "loadingIndicator"
        anchors.left: root.iconPosition === MButton.IconOnly ? undefined : parent.left
        anchors.leftMargin: root.leftPadding
        anchors.horizontalCenter: root.iconPosition === MButton.IconOnly
                                  ? parent.horizontalCenter
                                  : undefined
        anchors.verticalCenter: parent.verticalCenter
        color: root.icon.color
        running: root.effectiveLoading && root.visible
        visible: root.effectiveLoading
    }

    function variationNames() {
        const names = []
        const variantName = variantNameFor(root.variant)
        const sizeName = sizeNameFor(root.size)

        if (variantName.length > 0)
            names.push(variantName)
        if (sizeName.length > 0)
            names.push(sizeName)
        if (root.effectiveLoading)
            names.push("loading")

        for (let i = 0; i < root.extraVariations.length; ++i) {
            const value = String(root.extraVariations[i] || "")
            if (value.length > 0)
                names.push(value)
        }

        return names
    }

    function variantNameFor(value) {
        switch (value) {
        case MButton.Secondary:
            return "secondary"
        case MButton.Outline:
            return "outline"
        case MButton.Ghost:
            return "ghost"
        case MButton.Destructive:
            return "destructive"
        default:
            return ""
        }
    }

    function sizeNameFor(value) {
        switch (value) {
        case MButton.Small:
            return "small"
        case MButton.Large:
            return "large"
        default:
            return ""
        }
    }

    function displayFor(value) {
        switch (value) {
        case MButton.IconNone:
            return AbstractButton.TextOnly
        case MButton.IconTop:
            return AbstractButton.TextUnderIcon
        case MButton.IconOnly:
            return AbstractButton.IconOnly
        default:
            return AbstractButton.TextBesideIcon
        }
    }
}
