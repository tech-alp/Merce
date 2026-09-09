import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Toastify

Item {
    id: root
    objectName: "merce.playground.showcase.typography"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int specimenCount: typeRows.length
    readonly property bool compactLayout: width < 760
    readonly property int panelSpacing: Theme.spacing.md
    readonly property int rightPanelWidth: compactLayout ? width : Math.min(320, Math.max(240, Math.round(width * 0.28)))
    readonly property int leftPanelWidth: compactLayout ? width : Math.max(0, width - rightPanelWidth - panelSpacing)
    readonly property int tableCompactThreshold: 620
    readonly property int usageCardPreferredWidth: 220
    readonly property color dividerColor: Theme.colors.outline.subtle
    readonly property color cardColor: Theme.colors.surface.container
    readonly property color mutedTextColor: Theme.colors.content.secondary
    readonly property color faintTextColor: Theme.colors.content.tertiary
    readonly property color accentColor: Theme.colors.action.primary.container
    readonly property bool darkPreviewAvailable: root.themeHasMode(Theme.activeBrand, "dark")

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
            "name": "Label",
            "type": "overline",
            "sample": "Label text example",
            "usage": "Labels, badges"
        },
        {
            "name": "Caption",
            "type": "caption",
            "sample": "Brief notes and secondary details.",
            "usage": "Captions, footnotes"
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

    function themeHasMode(brand, mode) {
        for (let i = 0; i < Theme.availableThemes.length; ++i) {
            const option = Theme.availableThemes[i]
            if (String(option.value) !== String(brand) || !option.modes)
                continue
            for (let j = 0; j < option.modes.length; ++j) {
                if (String(option.modes[j].value) === mode)
                    return true
            }
        }
        return false
    }

    function wrappedRowHeight(availableWidth, itemGap, widths, heights) {
        let totalHeight = 0
        let rowWidth = 0
        let rowHeight = 0

        for (let i = 0; i < widths.length; ++i) {
            const itemWidth = Math.min(availableWidth, Number(widths[i] || 0))
            const itemHeight = Number(heights[i] || 0)
            if (rowWidth > 0 && rowWidth + itemGap + itemWidth > availableWidth + 1) {
                totalHeight += rowHeight + itemGap
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += (rowWidth > 0 ? itemGap : 0) + itemWidth
            rowHeight = Math.max(rowHeight, itemHeight)
        }

        return totalHeight + rowHeight
    }

    function typeTableCompact(tableWidth) {
        return tableWidth < tableCompactThreshold
    }

    function typeStyleColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? Math.min(80, tableWidth * 0.24) : 96
    }

    function typeFamilyColumnWidth(tableWidth) {
        return 0
    }

    function typeSizeColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : 124
    }

    function typeWeightColumnWidth(tableWidth) {
        return typeTableCompact(tableWidth) ? 0 : 92
    }

    function typeLineColumnWidth(tableWidth) {
        return 0
    }

    function typeUsageColumnWidth(tableWidth) {
        return 0
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
        color: Theme.colors.content.primary
        font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
        font.pixelSize: Theme.typography.sizeMedium
        font.weight: Theme.typography.weightSemibold
        elide: Text.ElideRight
    }

    component OverviewMetric: Item {
        required property string iconName
        required property string label
        required property string value

        implicitWidth: 190
        implicitHeight: 54

        Row {
            anchors.fill: parent
            spacing: Theme.spacing.md

            Rectangle {
                width: 38
                height: 38
                anchors.verticalCenter: parent.verticalCenter
                radius: Theme.radius.medium
                color: Theme.colors.surface.containerTinted
                border.width: 1
                border.color: root.dividerColor

                AppIcon {
                    anchors.centerIn: parent
                    name: iconName
                    size: Theme.icons.small
                    color: root.accentColor
                }
            }

            Column {
                width: Math.max(0, parent.width - 38 - parent.spacing)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                MetaText {
                    width: parent.width
                    text: label
                    font.pixelSize: Theme.typography.sizeXSmall
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                }

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Body
                    text: value
                    color: Theme.colors.content.primary
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }
        }
    }

    component TypeRow: Item {
        property var entry: ({})
        property int rowIndex: 0

        objectName: "merce.playground.typography.row." + String(entry.type || "unknown")

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
        readonly property bool contentFits: preview.paintedHeight <= preview.height + 1

        readonly property int baseHeight: compact
                                                  ? (entry.type === "body" ? 90 : (entry.type === "display" ? 72 : 62))
                                                  : (entry.type === "body" ? 76 : (entry.type === "display" ? 62 : 50))

        implicitHeight: Math.max(baseHeight,
                                 Math.ceil(preview.implicitHeight)
                                 + (compact ? 28 : 0))

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
            color: Theme.colors.content.primary
        }

        Text {
            id: preview
            x: parent.styleWidth
            y: parent.compact ? 6 : 0
            width: parent.previewWidth
            height: parent.compact ? parent.height - 28 : parent.height
            text: root.previewText(entry)
            color: Theme.colors.content.primary
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
            visible: false
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth + parent.familyWidth
            width: parent.sizeWidth
            height: parent.height
            text: root.typeSize(entry.type) + "px / " + root.typeLineHeight(entry.type) + "px"
            visible: !parent.compact
            horizontalAlignment: Text.AlignHCenter
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth
            width: parent.weightWidth
            height: parent.height
            text: root.weightName(root.typeWeight(entry.type))
            visible: !parent.compact
            horizontalAlignment: Text.AlignHCenter
        }

        MetaText {
            x: parent.styleWidth + parent.previewWidth + parent.familyWidth + parent.sizeWidth + parent.weightWidth
            width: parent.lineWidth
            height: parent.height
            text: root.typeLineHeight(entry.type) + "px\n" + Math.round(root.typeLeading(entry.type) * 100) + "%"
            visible: false
            horizontalAlignment: Text.AlignHCenter
        }

        MetaText {
            x: parent.width - parent.usageWidth + Theme.spacing.sm
            width: parent.usageWidth - Theme.spacing.md
            height: parent.height
            text: entry.usage
            visible: false
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
                parent.styleWidth + parent.previewWidth
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
                        color: Theme.colors.content.primary
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
                        { "y": 66, "label": "X-Height", "color": Theme.colors.status.success.content },
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
                    color: Theme.colors.content.primary
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
                    color: Theme.colors.content.primary
                }
            }
        }
    }

    component PreviewCard: Item {
        implicitHeight: previewPanels.implicitHeight

        GridLayout {
            id: previewPanels

            width: parent.width
            height: implicitHeight
            columns: root.darkPreviewAvailable && width >= 560 ? 2 : 1
            columnSpacing: Theme.spacing.sm
            rowSpacing: Theme.spacing.sm

            PreviewPanel {
                id: lightPreview
                Layout.fillWidth: true
                dark: false
            }

            Loader {
                id: darkPreviewLoader
                objectName: "merce.playground.typography.darkPreviewLoader"

                active: root.darkPreviewAvailable
                visible: active
                Layout.fillWidth: active
                Layout.preferredHeight: active ? lightPreview.implicitHeight : 0

                sourceComponent: Component {
                    PreviewPanel {
                        width: darkPreviewLoader.width
                        dark: true
                    }
                }
            }
        }
    }

    component PreviewPanel: Rectangle {
        id: previewPanel

        required property bool dark
        readonly property bool matchesActiveMode: dark === (Theme.activeMode === "dark")
        readonly property color panelTextColor: matchesActiveMode
                                                     ? Theme.colors.content.primary
                                                     : Theme.colors.content.inverse
        readonly property color panelMutedColor: matchesActiveMode
                                                      ? Theme.colors.content.secondary
                                                      : Qt.alpha(panelTextColor, 0.72)

        implicitHeight: previewPanelContent.implicitHeight + Theme.spacing.md * 2
        radius: Theme.radius.medium
        color: matchesActiveMode ? Theme.colors.surface.container : Theme.colors.surface.inverse
        border.width: 1
        border.color: matchesActiveMode ? root.dividerColor : Qt.alpha(panelTextColor, 0.18)

        Column {
            id: previewPanelContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.sm

            Text {
                width: parent.width
                text: previewPanel.dark ? "Dark preview" : "Light preview"
                color: previewPanel.panelTextColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeXSmall
                font.weight: Theme.typography.weightSemibold
            }

            Text {
                width: parent.width
                text: "H2 Heading Example"
                color: previewPanel.panelTextColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Math.min(root.typeSize("h2"), 24)
                font.weight: Theme.typography.weightSemibold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: previewPanel.dark
                      ? "Body text example to show how type looks in the dark theme."
                      : "Body text example to show how type looks in the light theme."
                color: previewPanel.panelMutedColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeSmall
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: "LABEL EXAMPLE"
                color: root.accentColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeXSmall
                font.weight: Theme.typography.weightSemibold
                font.capitalization: Font.AllUppercase
            }

            Text {
                width: parent.width
                text: "Caption example"
                color: previewPanel.panelMutedColor
                font.family: FoundationFonts.resolveFamily(Theme.typography.fontBody)
                font.pixelSize: Theme.typography.sizeXSmall
            }
        }
    }

    component UsageCard: Surface {
        id: usageCard

        required property string title
        property int contentHeight: 112
        default property alias contentData: usageSlot.data

        objectName: "merce.playground.typography.usage." + title.toLowerCase().replace(/\s+/g, "-")

        surfaceType: Surface.Default
        backgroundColor: root.cardColor
        borderColor: root.dividerColor
        radiusValue: Theme.radius.medium
        implicitWidth: root.usageCardPreferredWidth
        implicitHeight: usageCardContent.implicitHeight + Theme.spacing.md * 2
        Layout.minimumWidth: Math.min(root.usageCardPreferredWidth, root.width)
        Layout.preferredWidth: Math.min(root.usageCardPreferredWidth, root.width)
        Layout.maximumWidth: root.width
        Layout.fillWidth: true
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
                color: Theme.colors.content.primary
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
                color: Theme.colors.content.primary
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

        Card {
            width: parent.width

            GridLayout {
                width: parent.width
                height: implicitHeight
                columns: root.width < 560 ? 1 : root.width < 900 ? 2 : 4
                columnSpacing: Theme.spacing.xl
                rowSpacing: Theme.spacing.md

                OverviewMetric {
                    Layout.fillWidth: true
                    iconName: "material:text_fields"
                    label: "Font family"
                    value: root.fontFamilyLabel("body")
                }

                OverviewMetric {
                    Layout.fillWidth: true
                    iconName: "material:format_align_left"
                    label: "Weight range"
                    value: "Regular – Bold"
                }

                OverviewMetric {
                    Layout.fillWidth: true
                    iconName: "material:format_size"
                    label: "Base size"
                    value: Theme.typography.sizeMedium + "px"
                }

                OverviewMetric {
                    Layout.fillWidth: true
                    iconName: "material:format_line_spacing"
                    label: "Base line-height"
                    value: root.typeLeading("body").toFixed(1) + " ("
                           + root.typeLineHeight("body") + "px)"
                }
            }
        }

        FlexboxLayout {
            id: panelLayout

            implicitWidth: root.width
            width: parent.width
            Layout.fillWidth: true
            Layout.preferredWidth: root.width
            Layout.maximumWidth: root.width
            Layout.preferredHeight: implicitHeight
            height: implicitHeight
            direction: FlexboxLayout.Column
            gap: root.panelSpacing
            alignItems: FlexboxLayout.AlignStart

            SectionTitle {
                Layout.minimumWidth: root.width
                Layout.preferredWidth: root.width
                Layout.maximumWidth: root.width
                text: "Type Scale"
            }

            Card {
                id: typeTable
                objectName: "merce.playground.typography.scale"
                Layout.minimumWidth: root.width
                Layout.preferredWidth: root.width
                Layout.maximumWidth: root.width
                FlexboxLayout {
                    width: parent.width
                    height: implicitHeight
                    direction: FlexboxLayout.Column
                    gap: 0
                    alignItems: FlexboxLayout.AlignStart

                    Row {
                        width: parent.width
                        height: 32
                        spacing: 0
                        Layout.fillWidth: true
                        Layout.preferredWidth: parent.width
                        Layout.maximumWidth: parent.width

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
                            text: "Token"
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
                            visible: false
                            horizontalAlignment: Text.AlignHCenter
                        }

                        HeaderText {
                            width: parent.sizeWidth
                            height: parent.height
                            text: "Size / Line height"
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
                            visible: false
                            horizontalAlignment: Text.AlignHCenter
                        }

                        HeaderText {
                            width: parent.usageWidth
                            height: parent.height
                            text: "Usage"
                            visible: false
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

                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width
                            Layout.maximumWidth: parent.width
                            entry: modelData
                            rowIndex: index
                        }
                    }
                }
            }

            PreviewCard {
                Layout.minimumWidth: root.width
                Layout.preferredWidth: root.width
                Layout.maximumWidth: root.width
                Layout.preferredHeight: implicitHeight
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

                objectName: "merce.playground.typography.usageCards"
                Layout.minimumWidth: root.width
                Layout.preferredWidth: root.width
                Layout.maximumWidth: root.width
                readonly property real cardWidth: Math.min(root.usageCardPreferredWidth,
                                                           width)
                height: root.wrappedRowHeight(width, gap,
                                              [cardWidth, cardWidth, cardWidth,
                                               cardWidth, cardWidth],
                                              [productUsage.implicitHeight,
                                               navigationUsage.implicitHeight,
                                               formUsage.implicitHeight,
                                               checkoutUsage.implicitHeight,
                                               toastUsage.implicitHeight])
                direction: FlexboxLayout.Row
                wrap: FlexboxLayout.Wrap
                gap: Theme.spacing.md
                alignItems: FlexboxLayout.AlignStart

                UsageCard {
                    id: productUsage
                    title: "Product Card"

                    Rectangle {
                        id: productImage
                        x: 0
                        y: 8
                        width: parent.width < 150 ? 44 : 54
                        height: parent.width < 150 ? 64 : 74
                        radius: Theme.radius.small
                        color: Theme.colors.surface.containerTinted
                        border.color: root.dividerColor

                        AppIcon {
                            anchors.centerIn: parent
                            name: "material:shopping_bag"
                            size: parent.width < 50 ? 30 : 38
                            color: Theme.colors.action.primary.container
                        }
                    }

                    Text {
                        x: productImage.width + Theme.spacing.sm
                        y: 10
                        width: parent.width - x
                        height: 32
                        text: "Urban Backpack"
                        color: Theme.colors.content.primary
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
                    id: navigationUsage
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
                    id: formUsage
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
                            color: Theme.colors.content.primary
                        }

                        SK.TextField {
                            text: "Input text"
                            readOnly: true
                            rightPadding: Theme.spacing.xl2
                            SK.StyleVariation.variations: ["error"]
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width
                            Layout.maximumWidth: parent.width

                            AppIcon {
                                anchors {
                                    right: parent.right
                                    rightMargin: Theme.spacing.md
                                    verticalCenter: parent.verticalCenter
                                }
                                name: "material:error"
                                size: Theme.icons.small
                                color: Theme.colors.status.error.content
                            }
                        }

                        AppLabel {
                            text: "Error message"
                            textType: AppLabel.Caption
                            color: Theme.colors.status.error.content
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width
                        }
                    }
                }

                UsageCard {
                    id: checkoutUsage
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
                                    color: Theme.colors.content.primary
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
                                color: Theme.colors.content.primary
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
                    id: toastUsage
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
