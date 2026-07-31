import QtQuick
import QtQuick.Layouts
import Merce.Theme
import Merce.Foundation
import Merce.Controls
import Toastify

Item {
    id: root
    objectName: "merce.playground.showcase.typography"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int specimenCount: 10
    readonly property bool compactLayout: width < 760
    readonly property int panelSpacing: Theme.spacing.md
    readonly property int rightPanelWidth: compactLayout ? width : Math.min(320, Math.max(240, Math.round(width * 0.28)))
    readonly property int leftPanelWidth: compactLayout ? width : Math.max(0, width - rightPanelWidth - panelSpacing)
    readonly property int tableCompactThreshold: 560
    readonly property int usageCardMinWidth: 156
    readonly property int usageCardPreferredWidth: 220
    readonly property color dividerColor: Theme.colors.border.base
    readonly property color cardColor: Theme.colors.surface.base
    readonly property color mutedTextColor: Theme.colors.text.secondary
    readonly property color faintTextColor: Theme.colors.text.tertiary
    readonly property color accentColor: Theme.colors.action.primary
    readonly property color darkPreviewTextColor: Theme.colors.text.inverse
    readonly property color darkPreviewMutedColor: Qt.rgba(darkPreviewTextColor.r, darkPreviewTextColor.g, darkPreviewTextColor.b, 0.72)

    MerceToastifyStyleProvider {
        id: toastStyle
    }

    readonly property var typeRows: [
        {
            "name": "Display",
            "type": "display",
            "sample": "Merce Design System",
            "usage": "Hero titles, major headings"
        },
        {
            "name": "H1",
            "type": "h1",
            "sample": "Beautiful products for everyday life",
            "usage": "Page titles, sections"
        },
        {
            "name": "H2",
            "type": "h2",
            "sample": "Designed to work, built to last",
            "usage": "Section titles, cards"
        },
        {
            "name": "H3",
            "type": "h3",
            "sample": "Everything you need in one system",
            "usage": "Subsection titles"
        },
        {
            "name": "H4",
            "type": "h4",
            "sample": "A robust foundation for Qt/QML applications",
            "usage": "Small section titles"
        },
        {
            "name": "Body",
            "type": "body",
            "sample": "Merce provides a comprehensive set of design tokens and components to help you build consistent interfaces.",
            "usage": "Paragraphs, long content"
        },
        {
            "name": "Body Small",
            "type": "bodySmall",
            "sample": "Use body small for supporting information that needs slightly less emphasis.",
            "usage": "Secondary text, helper copy"
        },
        {
            "name": "Code",
            "type": "code",
            "sample": "const theme = Theme.colors.background.base",
            "usage": "Code, technical values"
        },
        {
            "name": "Caption",
            "type": "caption",
            "sample": "Orders are usually delivered within 2-4 business days.",
            "usage": "Captions, footnotes"
        },
        {
            "name": "Overline",
            "type": "overline",
            "sample": "New collection",
            "usage": "Labels, badges"
        },
        {
            "name": "Price",
            "type": "price",
            "sample": "$129.99",
            "usage": "Prices, key numbers"
        }
    ]

    function typeSpec(typeName) {
        if (typeName === "code") {
            return {
                "family": Theme.typography.fontMono,
                "size": Theme.typography.sizeSmall,
                "weight": Theme.typography.weightMedium,
                "leading": Theme.typography.leadingRelaxed,
                "uppercase": false
            }
        }

        const spec = Theme.typography[typeName]
        return spec || Theme.typography.body
    }

    function primaryFontFamily(family) {
        const families = String(family || "").split(",")
        for (let i = 0; i < families.length; ++i) {
            const candidate = families[i].trim().replace(/^['"]|['"]$/g, "")
            if (candidate.length > 0)
                return candidate
        }
        return Theme.typography.fontBody
    }

    function fontFamilyLabel(typeName) {
        const family = primaryFontFamily(typeSpec(typeName).family || Theme.typography.fontBody)
        if (family === "-apple-system"
                || family === "BlinkMacSystemFont"
                || family === "system-ui")
            return "System"
        if (family === "sans-serif")
            return "Sans"
        if (family === "serif")
            return "Serif"
        return family
    }

    function resolvedFamily(typeName) {
        return FoundationFonts.resolveFamily(primaryFontFamily(typeSpec(typeName).family || Theme.typography.fontBody))
    }

    function typeSize(typeName) {
        return Math.round(Number(typeSpec(typeName).size || Theme.typography.sizeMedium))
    }

    function typeWeight(typeName) {
        return Math.round(Number(typeSpec(typeName).weight || Theme.typography.weightRegular))
    }

    function typeLeading(typeName) {
        return Number(typeSpec(typeName).leading || Theme.typography.leadingNormal)
    }

    function typeLineHeight(typeName) {
        return Math.round(typeSize(typeName) * typeLeading(typeName))
    }

    function weightName(weight) {
        if (weight >= 700)
            return "Bold"
        if (weight >= 600)
            return "SemiBold"
        if (weight >= 500)
            return "Medium"
        return "Regular"
    }

    function previewText(entry) {
        const value = String(entry.sample || "")
        return typeSpec(entry.type).uppercase ? value.toUpperCase() : value
    }

    function typeTableCompact(tableWidth) {
        return tableWidth < tableCompactThreshold
    }

    function typeStyleColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? Math.max(58, Math.min(76, Math.round(tableWidth * 0.28))) : 78
    }

    function typeFamilyColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : 58
    }

    function typeSizeColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : 48
    }

    function typeWeightColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : 58
    }

    function typeLineColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : 58
    }

    function typeUsageColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : (tableWidth < 680 ? 92 : 108)
    }

    function typeFixedColumnWidth(tableWidth) {
        return typeStyleColumnWidth(tableWidth)
                + typeFamilyColumnWidth(tableWidth)
                + typeSizeColumnWidth(tableWidth)
                + typeWeightColumnWidth(tableWidth)
                + typeLineColumnWidth(tableWidth)
                + typeUsageColumnWidth(tableWidth)
    }

    function typePreviewColumnWidth(tableWidth) {
        return Math.max(0, tableWidth - typeFixedColumnWidth(tableWidth))
    }

    function typeTableFits(tableWidth) {
        return typeFixedColumnWidth(tableWidth) <= tableWidth
    }

    component Card: Surface {
        default property alias contentData: cardContent.data

        surfaceType: Surface.Default
        backgroundColor: root.cardColor
        borderColor: root.dividerColor
        radiusValue: Theme.radius.large
        implicitHeight: cardContent.childrenRect.height + Theme.spacing.md * 2

        Item {
            id: cardContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
        }
    }

    component HeaderText: Text {
        color: root.mutedTextColor
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: Theme.typography.sizeSmall
        font.weight: Theme.typography.weightSemibold
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component MetaText: Text {
        color: root.mutedTextColor
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: Theme.typography.sizeSmall
        lineHeightMode: Text.FixedHeight
        lineHeight: Theme.typography.sizeSmall * Theme.typography.leadingSnug
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }

    component SectionTitle: Text {
        color: Theme.colors.text.primary
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: Theme.typography.sizeMedium
        font.weight: Theme.typography.weightSemibold
        elide: Text.ElideRight
    }

    component TypeRow: Item {
        property var entry: ({})
        property int rowIndex: 0

        readonly property bool compact: root.typeTableCompact(width)
        readonly property int styleWidth: root.typeStyleColumnWidth(width)
        readonly property int familyWidth: root.typeFamilyColumnWidth(width)
        readonly property int sizeWidth: root.typeSizeColumnWidth(width)
        readonly property int weightWidth: root.typeWeightColumnWidth(width)
        readonly property int lineWidth: root.typeLineColumnWidth(width)
        readonly property int usageWidth: root.typeUsageColumnWidth(width)
        readonly property int fixedWidth: styleWidth + familyWidth + sizeWidth + weightWidth + lineWidth + usageWidth
        readonly property int previewWidth: root.typePreviewColumnWidth(width)
        readonly property int sampleSize: Math.min(root.typeSize(entry.type), entry.type === "display" ? (compact ? 30 : 34) : (compact ? 22 : 24))

        width: parent ? parent.width : 0
        height: compact ? (entry.type === "body" ? 90 : (entry.type === "display" ? 72 : 62)) : (entry.type === "body" ? 76 : (entry.type === "display" ? 62 : 50))

        Rectangle {
            anchors.fill: parent
            color: rowIndex % 2 === 0 ? "transparent" : Qt.rgba(0, 0, 0, 0.012)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 7
            height: 7
            radius: 4
            color: root.accentColor
            visible: rowIndex === 0
        }

        HeaderText {
            id: styleText
            x: 14
            width: parent.styleWidth - x
            height: parent.compact ? parent.height - 22 : parent.height
            text: entry.name
            color: Theme.colors.text.primary
        }

        Text {
            id: preview
            x: parent.styleWidth
            y: parent.compact ? 6 : 0
            width: parent.previewWidth
            height: parent.compact ? parent.height - 28 : parent.height
            text: root.previewText(entry)
            color: Theme.colors.text.primary
            font.family: root.resolvedFamily(entry.type)
            font.pixelSize: parent.sampleSize
            font.weight: root.typeWeight(entry.type)
            font.capitalization: root.typeSpec(entry.type).uppercase ? Font.AllUppercase : Font.MixedCase
            lineHeightMode: Text.FixedHeight
            lineHeight: Math.round(parent.sampleSize * root.typeLeading(entry.type))
            wrapMode: entry.type === "body" ? Text.WordWrap : Text.NoWrap
            elide: entry.type === "body" ? Text.ElideNone : Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth
            width: parent.familyWidth
            height: parent.height
            text: root.fontFamilyLabel(entry.type)
            visible: !parent.compact
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth + parent.familyWidth
            width: parent.sizeWidth
            height: parent.height
            text: root.typeSize(entry.type) + "px"
            visible: !parent.compact
            horizontalAlignment: Text.AlignHCenter
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth
            width: parent.weightWidth
            height: parent.height
            text: root.typeWeight(entry.type) + "\n" + root.weightName(root.typeWeight(entry.type))
            visible: !parent.compact
            horizontalAlignment: Text.AlignHCenter
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth + parent.weightWidth
            width: parent.lineWidth
            height: parent.height
            text: root.typeLineHeight(entry.type) + "px\n" + Math.round(root.typeLeading(entry.type) * 100) + "%"
            visible: !parent.compact
            horizontalAlignment: Text.AlignHCenter
        }

        MetaText {
            x: parent.width - parent.usageWidth + Theme.spacing.sm
            width: parent.usageWidth - Theme.spacing.md
            height: parent.height
            text: entry.usage
            visible: !parent.compact
            font.pixelSize: Theme.typography.sizeXSmall
        }

        MetaText {
            x: parent.styleWidth
            y: parent.height - 24
            width: Math.max(0, parent.width - x - Theme.spacing.sm)
            height: 20
            text: root.fontFamilyLabel(entry.type) + " - "
                  + root.typeSize(entry.type) + "px / "
                  + root.typeLineHeight(entry.type) + "px - "
                  + root.weightName(root.typeWeight(entry.type))
            visible: parent.compact
            elide: Text.ElideRight
            font.pixelSize: Theme.typography.sizeXSmall
        }

        Repeater {
            model: parent.compact ? [] : [
                parent.styleWidth,
                parent.styleWidth + parent.previewWidth,
                parent.styleWidth + parent.previewWidth + parent.familyWidth,
                parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth,
                parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth + parent.weightWidth,
                parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth + parent.weightWidth + parent.lineWidth
            ]

            Rectangle {
                required property var modelData

                x: modelData
                y: 0
                width: 1
                height: parent.height
                color: root.dividerColor
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: root.dividerColor
        }
    }

    component TypeScaleCard: Card {
        FlexboxLayout {
            width: parent.width
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.md
            alignItems: FlexboxLayout.AlignStart

            SectionTitle {
                width: parent.width
                text: "Type Scale"
            }

            Repeater {
                model: 9

                FlexboxLayout {
                    required property int index

                    readonly property var entry: root.typeRows[index]

                    width: parent.width
                    height: 20
                    direction: FlexboxLayout.Row
                    gap: Theme.spacing.sm
                    alignItems: FlexboxLayout.AlignCenter

                    MetaText {
                        width: 72
                        height: parent.height
                        text: parent.entry.name
                        color: Theme.colors.text.primary
                        font.pixelSize: Theme.typography.sizeXSmall
                    }

                    MetaText {
                        width: 34
                        height: parent.height
                        text: root.typeSize(parent.entry.type)
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Theme.typography.sizeXSmall
                    }

                    Rectangle {
                        width: Math.max(4, Math.max(0, parent.width - 118) * root.typeSize(parent.entry.type) / Math.max(1, root.typeSize("display")))
                        height: 7
                        radius: 0
                        color: root.accentColor
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.dividerColor
            }

            FlexboxLayout {
                width: parent.width
                height: 18
                direction: FlexboxLayout.Row
                gap: 0
                alignItems: FlexboxLayout.AlignCenter

                Repeater {
                    model: [0, 20, 40, 60, 80]

                    MetaText {
                        required property var modelData

                        width: parent.width / 5
                        height: parent.height
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Theme.typography.sizeXSmall
                    }
                }
            }
        }
    }

    component BaselineCard: Card {
        FlexboxLayout {
            width: parent.width
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.md
            alignItems: FlexboxLayout.AlignStart

            SectionTitle {
                width: parent.width
                text: "Baseline & Line Height"
            }

            Item {
                width: parent.width
                height: 132

                Repeater {
                    model: [
                        { "y": 18, "label": "Ascender", "color": root.faintTextColor },
                        { "y": 40, "label": "Cap Height", "color": root.accentColor },
                        { "y": 66, "label": "X-Height", "color": Theme.colors.status.success.foreground },
                        { "y": 98, "label": "Baseline", "color": root.accentColor },
                        { "y": 120, "label": "Descender", "color": root.faintTextColor }
                    ]

                    Rectangle {
                        required property var modelData

                        x: 0
                        y: modelData.y
                        width: Math.max(0, parent.width - 78)
                        height: 1
                        color: modelData.color
                        opacity: modelData.label === "Baseline" ? 1 : 0.55
                    }
                }

                Text {
                    x: 18
                    y: 18
                    text: "Ag"
                    color: Theme.colors.text.primary
                    font.family: FoundationFonts.resolveFamily(Theme.typography.fontDisplay)
                    font.pixelSize: 84
                    font.weight: Theme.typography.weightRegular
                }

                Repeater {
                    model: [
                        { "y": 9, "label": "Ascender" },
                        { "y": 31, "label": "Cap Height" },
                        { "y": 57, "label": "X-Height" },
                        { "y": 89, "label": "Baseline" },
                        { "y": 111, "label": "Descender" }
                    ]

                    MetaText {
                        required property var modelData

                        x: Math.max(0, parent.width - 74)
                        y: modelData.y
                        width: Math.min(74, parent.width)
                        height: 18
                        text: modelData.label
                        font.pixelSize: 10
                    }
                }
            }

            FlexboxLayout {
                height: implicitHeight
                direction: FlexboxLayout.Row
                gap: Theme.spacing.sm
                alignItems: FlexboxLayout.AlignCenter

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: root.accentColor
                }

                MetaText {
                    text: "Body - " + root.typeSize("body") + "px / " + root.typeLineHeight("body") + "px / " + Math.round(root.typeLeading("body") * 100) + "%"
                    color: Theme.colors.text.primary
                }
            }
        }
    }

    component PreviewCard: Card {
        FlexboxLayout {
            width: parent.width
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.md
            alignItems: FlexboxLayout.AlignStart

            FlexboxLayout {
                width: parent.width
                height: implicitHeight
                direction: FlexboxLayout.Row
                gap: Theme.spacing.sm
                alignItems: FlexboxLayout.AlignCenter

                SectionTitle {
                    width: Math.max(0, parent.width - modeButtons.width)
                    text: "Light / Dark Preview"
                }

                FlexboxLayout {
                    id: modeButtons
                    height: implicitHeight
                    direction: FlexboxLayout.Row
                    gap: Theme.spacing.xs
                    alignItems: FlexboxLayout.AlignCenter

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: Theme.colors.background.base
                        border.color: root.dividerColor

                        AppIcon {
                            anchors.centerIn: parent
                            name: "material:light_mode"
                            size: Theme.icons.small
                            color: root.mutedTextColor
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: Theme.colors.background.base
                        border.color: root.dividerColor

                        AppIcon {
                            anchors.centerIn: parent
                            name: "material:dark_mode"
                            size: Theme.icons.small
                            color: root.mutedTextColor
                        }
                    }
                }
            }

            FlexboxLayout {
                id: previewPanels

                width: parent.width
                height: implicitHeight
                direction: FlexboxLayout.Row
                wrap: FlexboxLayout.Wrap
                gap: Theme.spacing.sm
                alignItems: FlexboxLayout.AlignStart

                PreviewPanel {
                    Layout.minimumWidth: Math.min(240, previewPanels.width)
                    Layout.preferredWidth: previewPanels.width < 560 ? previewPanels.width : (previewPanels.width - Theme.spacing.sm) / 2
                    Layout.maximumWidth: previewPanels.width
                    dark: false
                }

                PreviewPanel {
                    Layout.minimumWidth: Math.min(240, previewPanels.width)
                    Layout.preferredWidth: previewPanels.width < 560 ? previewPanels.width : (previewPanels.width - Theme.spacing.sm) / 2
                    Layout.maximumWidth: previewPanels.width
                    dark: true
                }
            }
        }
    }

    component PreviewPanel: Rectangle {
        required property bool dark

        implicitHeight: previewPanelContent.implicitHeight + Theme.spacing.md * 2
        radius: Theme.radius.medium
        color: dark ? Theme.colors.action.secondaryPressed : Theme.colors.surface.base
        border.color: dark ? Theme.colors.action.secondaryHover : root.dividerColor

        FlexboxLayout {
            id: previewPanelContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.sm
            alignItems: FlexboxLayout.AlignStart

            Text {
                width: parent.width
                text: "Product Title"
                color: dark ? root.darkPreviewTextColor : Theme.colors.text.primary
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeMedium
                font.weight: Theme.typography.weightSemibold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: "$129.99"
                color: root.accentColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeMedium
                font.weight: Theme.typography.weightBold
            }

            Text {
                width: parent.width
                text: "Short description of the product that explains the key benefits."
                color: dark ? root.darkPreviewMutedColor : root.mutedTextColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeXSmall
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 4 }

            Text {
                text: "Email address"
                color: dark ? root.darkPreviewTextColor : Theme.colors.text.primary
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeXSmall
                font.weight: Theme.typography.weightMedium
            }

            MInput {
                text: "user@example.com"
                inputType: "email"
                isReadOnly: true
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                Layout.maximumWidth: parent.width
            }

            MButton {
                text: "Checkout"
                variant: MButton.Primary
                size: MButton.Small
                fullWidth: true
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                Layout.maximumWidth: parent.width
            }
        }
    }

    component UsageCard: Surface {
        id: usageCard

        required property string title
        property int contentHeight: 112
        default property alias contentData: usageSlot.data

        surfaceType: Surface.Default
        backgroundColor: root.cardColor
        borderColor: root.dividerColor
        radiusValue: Theme.radius.medium
        implicitWidth: root.usageCardPreferredWidth
        implicitHeight: usageCardContent.implicitHeight + Theme.spacing.md * 2
        Layout.minimumWidth: Math.min(root.usageCardMinWidth, parent ? parent.width : root.usageCardMinWidth)
        Layout.preferredWidth: Math.min(root.usageCardPreferredWidth, parent ? parent.width : root.usageCardPreferredWidth)
        Layout.maximumWidth: parent ? parent.width : root.usageCardPreferredWidth
        Layout.preferredHeight: implicitHeight

        FlexboxLayout {
            id: usageCardContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.sm
            alignItems: FlexboxLayout.AlignStart

            AppLabel {
                text: title
                textType: AppLabel.Button
                color: Theme.colors.text.primary
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
            }

            Item {
                width: parent.width
                height: usageCard.contentHeight
                clip: true
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: usageCard.contentHeight

                Item {
                    id: usageSlot
                    anchors.fill: parent
                }
            }
        }
    }

    FlexboxLayout {
        id: page
        implicitWidth: root.width
        width: root.width
        height: implicitHeight
        direction: FlexboxLayout.Column
        gap: Theme.spacing.lg
        alignItems: FlexboxLayout.AlignStart

        FlexboxLayout {
            implicitWidth: root.width
            width: parent.width
            Layout.fillWidth: true
            Layout.preferredWidth: root.width
            Layout.maximumWidth: root.width
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.xs
            alignItems: FlexboxLayout.AlignStart

            Text {
                width: parent.width
                text: "Typography"
                color: Theme.colors.text.primary
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.size3XLarge
                font.weight: Theme.typography.weightBold
            }

            MetaText {
                width: parent.width
                text: "Type scale, tokens and real usage examples."
                color: root.mutedTextColor
            }
        }

        FlexboxLayout {
            id: panelLayout

            implicitWidth: root.width
            width: parent.width
            Layout.fillWidth: true
            Layout.preferredWidth: root.width
            Layout.maximumWidth: root.width
            height: implicitHeight
            direction: FlexboxLayout.Row
            wrap: FlexboxLayout.Wrap
            gap: root.panelSpacing
            alignItems: FlexboxLayout.AlignStart

            Card {
                id: typeTable
                objectName: "merce.playground.typography.scale"
                Layout.minimumWidth: root.compactLayout ? root.width : Math.min(root.tableCompactThreshold, root.width)
                Layout.preferredWidth: root.compactLayout ? root.width : root.leftPanelWidth
                Layout.maximumWidth: root.width
                FlexboxLayout {
                    width: parent.width
                    height: implicitHeight
                    direction: FlexboxLayout.Column
                    gap: 0
                    alignItems: FlexboxLayout.AlignStart

                    FlexboxLayout {
                        width: parent.width
                        height: 32
                        direction: FlexboxLayout.Row
                        gap: 0
                        alignItems: FlexboxLayout.AlignCenter

                        readonly property bool compact: root.typeTableCompact(width)
                        readonly property int styleWidth: root.typeStyleColumnWidth(width)
                        readonly property int familyWidth: root.typeFamilyColumnWidth(width)
                        readonly property int sizeWidth: root.typeSizeColumnWidth(width)
                        readonly property int weightWidth: root.typeWeightColumnWidth(width)
                        readonly property int lineWidth: root.typeLineColumnWidth(width)
                        readonly property int usageWidth: root.typeUsageColumnWidth(width)
                        readonly property int previewWidth: root.typePreviewColumnWidth(width)

                        HeaderText {
                            width: parent.styleWidth
                            height: parent.height
                            text: "Style"
                        }

                        HeaderText {
                            width: parent.previewWidth
                            height: parent.height
                            text: parent.compact ? "Preview / Specs" : "Preview"
                        }

                        HeaderText {
                            width: parent.familyWidth
                            height: parent.height
                            text: "Family"
                            visible: !parent.compact
                            horizontalAlignment: Text.AlignHCenter
                        }

                        HeaderText {
                            width: parent.sizeWidth
                            height: parent.height
                            text: "Size"
                            visible: !parent.compact
                            horizontalAlignment: Text.AlignHCenter
                        }

                        HeaderText {
                            width: parent.weightWidth
                            height: parent.height
                            text: "Weight"
                            visible: !parent.compact
                            horizontalAlignment: Text.AlignHCenter
                        }

                        HeaderText {
                            width: parent.lineWidth
                            height: parent.height
                            text: "Line"
                            visible: !parent.compact
                            horizontalAlignment: Text.AlignHCenter
                        }

                        HeaderText {
                            width: parent.usageWidth
                            height: parent.height
                            text: "Usage"
                            visible: !parent.compact
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.dividerColor
                    }

                    Repeater {
                        model: root.typeRows

                        TypeRow {
                            required property var modelData
                            required property int index

                            width: parent.width
                            Layout.preferredWidth: parent.width
                            Layout.maximumWidth: parent.width
                            entry: modelData
                            rowIndex: index
                        }
                    }
                }
            }

            FlexboxLayout {
                Layout.minimumWidth: Math.min(240, root.width)
                Layout.preferredWidth: root.compactLayout ? root.width : root.rightPanelWidth
                Layout.maximumWidth: root.width
                Layout.preferredHeight: implicitHeight
                height: implicitHeight
                direction: FlexboxLayout.Column
                gap: root.panelSpacing
                alignItems: FlexboxLayout.AlignStart

                TypeScaleCard {
                    width: parent.width
                }

                BaselineCard {
                    width: parent.width
                }

                PreviewCard {
                    width: parent.width
                }
            }
        }

        FlexboxLayout {
            implicitWidth: root.width
            width: parent.width
            Layout.fillWidth: true
            Layout.preferredWidth: root.width
            Layout.maximumWidth: root.width
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: Theme.spacing.md
            alignItems: FlexboxLayout.AlignStart

            SectionTitle {
                width: parent.width
                text: "Usage Examples"
            }

            FlexboxLayout {
                id: usageCards

                width: parent.width
                height: implicitHeight
                direction: FlexboxLayout.Row
                wrap: FlexboxLayout.Wrap
                gap: Theme.spacing.md
                alignItems: FlexboxLayout.AlignStart

                UsageCard {
                    title: "Product Card"

                    Rectangle {
                        id: productImage
                        x: 0
                        y: 8
                        width: parent.width < 150 ? 44 : 54
                        height: parent.width < 150 ? 64 : 74
                        radius: Theme.radius.small
                        color: Theme.colors.surface.hover
                        border.color: root.dividerColor

                        AppIcon {
                            anchors.centerIn: parent
                            name: "material:shopping_bag"
                            size: parent.width < 50 ? 30 : 38
                            color: Theme.colors.action.primary
                        }
                    }

                    Text {
                        x: productImage.width + Theme.spacing.sm
                        y: 10
                        width: parent.width - x
                        height: 32
                        text: "Urban Backpack"
                        color: Theme.colors.text.primary
                        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                        font.pixelSize: Theme.typography.sizeSmall
                        font.weight: Theme.typography.weightSemibold
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        x: productImage.width + Theme.spacing.sm
                        y: 44
                        width: parent.width - x
                        text: "$129.99"
                        color: root.accentColor
                        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                        font.pixelSize: Theme.typography.sizeSmall
                        font.weight: Theme.typography.weightBold
                    }

                    Text {
                        x: productImage.width + Theme.spacing.sm
                        y: 68
                        width: parent.width - x
                        height: 40
                        text: "Durable materials and smart storage."
                        color: root.mutedTextColor
                        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                        font.pixelSize: Theme.typography.sizeXSmall
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                UsageCard {
                    title: "Navigation"
                    contentHeight: Theme.spacing.touchTargetCompact * 4 + Theme.spacing.xxs * 3

                    FlexboxLayout {
                        anchors.fill: parent
                        direction: FlexboxLayout.Column
                        gap: Theme.spacing.xxs
                        alignItems: FlexboxLayout.AlignStart

                        Repeater {
                            model: [
                                { "icon": "material:home", "label": "Home", "active": true },
                                { "icon": "material:storefront", "label": "Shop", "active": false },
                                { "icon": "material:category", "label": "Categories", "active": false },
                                { "icon": "material:person", "label": "Profile", "active": false }
                            ]

                            NavigationButton {
                                required property var modelData

                                text: modelData.label
                                icon.name: modelData.icon
                                current: modelData.active
                                Layout.fillWidth: true
                                Layout.preferredWidth: parent.width
                                Layout.maximumWidth: parent.width
                            }
                        }
                    }
                }

                UsageCard {
                    title: "Form Example"
                    contentHeight: 128

                    FlexboxLayout {
                        anchors.fill: parent
                        direction: FlexboxLayout.Column
                        gap: Theme.spacing.xs
                        alignItems: FlexboxLayout.AlignStart

                        AppLabel {
                            text: "Label"
                            textType: AppLabel.Caption
                            color: Theme.colors.text.primary
                        }

                        MInput {
                            text: "Input text"
                            isReadOnly: true
                            validationState: MInput.Error
                            trailingIcon: "material:error"
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width
                            Layout.maximumWidth: parent.width
                        }

                        AppLabel {
                            text: "Error message"
                            textType: AppLabel.Caption
                            color: Theme.colors.status.error.foreground
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width
                        }
                    }
                }

                UsageCard {
                    title: "Checkout Summary"

                    FlexboxLayout {
                        width: parent.width
                        height: implicitHeight
                        direction: FlexboxLayout.Column
                        gap: Theme.spacing.sm
                        alignItems: FlexboxLayout.AlignStart

                        Repeater {
                            model: [
                                { "label": "Subtotal", "value": "$129.99" },
                                { "label": "Shipping", "value": "$9.99" },
                                { "label": "Tax", "value": "$11.70" }
                            ]

                            FlexboxLayout {
                                required property var modelData

                                width: parent.width
                                height: implicitHeight
                                direction: FlexboxLayout.Row
                                gap: 0
                                alignItems: FlexboxLayout.AlignCenter

                                Text {
                                    width: parent.width - valueText.width
                                    text: modelData.label
                                    color: root.mutedTextColor
                                    font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                                    font.pixelSize: Theme.typography.sizeXSmall
                                }

                                Text {
                                    id: valueText
                                    text: modelData.value
                                    color: Theme.colors.text.primary
                                    font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                                    font.pixelSize: Theme.typography.sizeXSmall
                                    font.weight: Theme.typography.weightMedium
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.dividerColor
                        }

                        FlexboxLayout {
                            width: parent.width
                            height: implicitHeight
                            direction: FlexboxLayout.Row
                            gap: 0
                            alignItems: FlexboxLayout.AlignCenter

                            Text {
                                width: parent.width - totalText.width
                                text: "Total"
                                color: Theme.colors.text.primary
                                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                                font.pixelSize: Theme.typography.sizeMedium
                                font.weight: Theme.typography.weightSemibold
                            }

                            Text {
                                id: totalText
                                text: "$151.68"
                                color: root.accentColor
                                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                                font.pixelSize: Theme.typography.sizeMedium
                                font.weight: Theme.typography.weightBold
                            }
                        }
                    }
                }

                UsageCard {
                    title: "Toast Message"
                    contentHeight: 92

                    ToastifyDelegate {
                        anchors.centerIn: parent
                        width: parent.width
                        minimumWidth: parent.width
                        preferredWidth: parent.width
                        maximumWidth: parent.width
                        message: "Item added to cart"
                        type: Toastify.Success
                        autoClose: 0
                        closeOnClick: false
                        hideProgressBar: true
                        styleProvider: toastStyle
                    }
                }
            }
        }
    }
}
