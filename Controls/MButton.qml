import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit
import Merce.Theme

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

    readonly property var styleVariations: variationNames()

    icon.name: root.iconName
    icon.source: root.iconSource
    display: displayFor(root.iconPosition)

    // Type scales with the box. This belongs in the size StyleVariation next to
    // the height it pairs with, but StyleKit variations expose no font group at
    // all, so the size property that already exists here drives it instead.
    font.pixelSize: root.fontSizeFor(root.size)

    Layout.fillWidth: root.fullWidth
    LayoutMirroring.enabled: root.iconPosition === MButton.IconRight
    StyleVariation.variations: root.styleVariations

    function variationNames() {
        const names = []
        const variantName = variantNameFor(root.variant)
        const sizeName = sizeNameFor(root.size)

        if (variantName.length > 0)
            names.push(variantName)
        if (sizeName.length > 0)
            names.push(sizeName)
        if (root.loading || root.isLoading)
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

    // Kiosk guidance puts button labels with headings and instructions: at least
    // 4mm tall on screen. The cart panel is 800x1280 on 10.1", which is 5.88
    // px/mm, so 4mm is 24px and Large has to reach sizeXLarge to clear it.
    // Small and Medium sit below that bar and belong on secondary actions only.
    function fontSizeFor(value) {
        switch (value) {
        case MButton.Small:
            return Theme.typography.sizeSmall
        case MButton.Large:
            return Theme.typography.sizeXLarge
        default:
            return Theme.typography.sizeMedium
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
