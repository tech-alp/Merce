import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit
import Merce.Foundation
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
    /** Material Symbols name, for example "material:save". */
    property string iconName: ""
    property bool loading: false
    property bool isLoading: root.loading
    property bool fullWidth: false
    property var extraVariations: []

    readonly property bool effectiveLoading: root.loading || root.isLoading
    readonly property var styleVariations: variationNames()

    // Type scales with the box. This belongs in the size StyleVariation next to
    // the height it pairs with, but StyleKit variations expose no font group at
    // all, so the size property that already exists here drives it instead.
    font.pixelSize: root.fontSizeFor(root.size)
    focusPolicy: Qt.TabFocus

    Layout.fillWidth: root.fullWidth
    StyleVariation.variations: root.styleVariations


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

    // Kiosk guidance puts button labels with headings and instructions: at least
    // 4mm tall on screen. On the cart profile sizeMedium is the first step that
    // clears that, so Medium and Large both do; Small sits one step below and is
    // for secondary actions where the label is not the thing being aimed at.
    function fontSizeFor(value) {
        switch (value) {
        case MButton.Small:
            return Theme.typography.sizeSmall
        case MButton.Large:
            return Theme.typography.sizeLarge
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

    // StyleKit's own contentItem resolves icons through Qt's icon theme. MButton
    // deliberately bypasses that path: iconName is a bundled Material Symbol
    // consumed by AppIcon, so rendering does not depend on platform icon themes.
    //
    // The plate, the padding and every state colour still come from the style;
    // only the content is ours. The colour is read back through a StyleReader
    // rather than recomputed, so hover, press, focus and disabled stay in one
    // place instead of being reimplemented here as they were before StyleKit.
    contentItem: Item {
        // The row below always builds icon then label. Asking for the icon on
        // the right flips the row rather than reordering it, so one layout
        // serves both and the icon keeps its spacing and alignment either way.
        readonly property bool mirrored: root.iconPosition === MButton.IconRight

        LayoutMirroring.enabled: mirrored
        LayoutMirroring.childrenInherit: true

        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        // Same lookup StyleKit runs for the label it would have built itself:
        // same control type, same variations, same interaction state. Whatever
        // the outline/ghost/destructive variation says the label should be, the
        // icon and the text both get.
        StyleReader {
            id: contentStyle

            controlType: StyleReader.Button
            StyleVariation.variations: root.styleVariations
            enabled: root.enabled
            focused: root.visualFocus
            hovered: root.hovered
            pressed: root.down
            checked: root.checked
            highlighted: root.highlighted
        }

        GridLayout {
            id: contentRow

            readonly property bool stacked: root.iconPosition === MButton.IconTop
            readonly property bool showIcon: root.iconPosition !== MButton.IconNone
                                             && root.iconName.length > 0
            readonly property bool showText: root.iconPosition !== MButton.IconOnly
                                             && root.text.length > 0

            // Centred at its natural width, clamped to the plate. Without the
            // clamp the row keeps its implicit width and a button narrower than
            // its label spills content outside the background instead of eliding.
            anchors.centerIn: parent
            width: Math.min(implicitWidth, parent.width)
            flow: stacked ? GridLayout.TopToBottom : GridLayout.LeftToRight
            rowSpacing: root.spacing
            columnSpacing: root.spacing

            // The spinner takes the leading icon's place rather than being
            // anchored to the button: the row reserves its width, so the label
            // moves aside instead of being drawn under it.
            LoadingIndicator {
                objectName: "loadingIndicator"
                visible: root.effectiveLoading
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: root.iconSizeFor(root.size)
                Layout.preferredHeight: root.iconSizeFor(root.size)
                size: root.iconSizeFor(root.size)
                color: root.icon.color
                running: root.effectiveLoading && root.visible
            }

            AppIcon {
                objectName: "buttonIcon"
                visible: contentRow.showIcon && !root.effectiveLoading
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: root.iconSizeFor(root.size)
                Layout.preferredHeight: root.iconSizeFor(root.size)
                name: root.iconName
                size: root.iconSizeFor(root.size)
                color: contentStyle.text.color
            }

            Text {
                objectName: "buttonLabel"
                visible: contentRow.showText
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                text: root.text
                color: contentStyle.text.color
                font: root.font
                elide: Text.ElideRight
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // The glyph tracks the label: both scale with size, so a large button does
    // not end up with a small-button icon beside big type.
    function iconSizeFor(value) {
        switch (value) {
        case MButton.Small:
            return Theme.icons.small
        case MButton.Large:
            return Theme.icons.large
        default:
            return Theme.icons.medium
        }
    }

}
