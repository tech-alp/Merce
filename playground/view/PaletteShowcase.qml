import QtQuick
import Qt.labs.StyleKit as SK
import Merce.Theme
import Merce.Foundation
import Merce.Controls

Item {
    id: root
    objectName: "merce.playground.showcase.palette"

    implicitHeight: page.implicitHeight
    height: implicitHeight

    readonly property int wideBreakpoint: 1180
    readonly property int mediumBreakpoint: 760
    readonly property real cardGap: Theme.spacing.md

    function colorLabel(value) {
        const red = Math.round(value.r * 255)
        const green = Math.round(value.g * 255)
        const blue = Math.round(value.b * 255)
        return "#" + hexByte(red) + hexByte(green) + hexByte(blue)
    }

    function contrastRatio(foreground, background) {
        const foregroundLuminance = relativeLuminance(foreground)
        const backgroundLuminance = relativeLuminance(background)
        const lighter = Math.max(foregroundLuminance, backgroundLuminance)
        const darker = Math.min(foregroundLuminance, backgroundLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    function contrastThreshold(kind) {
        if (kind === "largeText" || kind === "nonText")
            return 3
        return 4.5
    }

    function gradeFor(ratio, kind) {
        if (kind === "nonText")
            return ratio >= 3 ? "AA" : "Fail"
        if (ratio >= 7)
            return "AAA"
        if (ratio >= contrastThreshold(kind))
            return "AA"
        return "Fail"
    }

    function categoryCardWidth() {
        const columns = root.width >= root.wideBreakpoint ? 3 : root.width >= root.mediumBreakpoint ? 2 : 1
        return Math.floor((page.width - root.cardGap * (columns - 1)) / columns)
    }

    function metricCardWidth() {
        const columns = root.width >= root.wideBreakpoint ? 4 : root.width >= root.mediumBreakpoint ? 2 : 1
        return Math.floor((page.width - root.cardGap * (columns - 1)) / columns)
    }

    function previewCardWidth() {
        const columns = root.width >= root.wideBreakpoint ? 4 : root.width >= root.mediumBreakpoint ? 2 : 1
        return Math.floor((page.width - root.cardGap * (columns - 1)) / columns)
    }

    function hexByte(value) {
        return Math.max(0, Math.min(255, value)).toString(16).padStart(2, "0").toUpperCase()
    }

    function linearChannel(channel) {
        return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4)
    }

    function relativeLuminance(value) {
        return 0.2126 * linearChannel(value.r)
                + 0.7152 * linearChannel(value.g)
                + 0.0722 * linearChannel(value.b)
    }

    component SectionTitle: AppLabel {
        textType: AppLabel.H4
        color: Theme.colors.text.primary
        wrapMode: Text.WordWrap
    }

    component SectionCaption: AppLabel {
        textType: AppLabel.Caption
        color: Theme.colors.text.secondary
        wrapMode: Text.WordWrap
    }

    component ColorSwatch: Rectangle {
        required property color swatchColor

        width: 44
        height: 44
        radius: Theme.radius.medium
        color: swatchColor
        border.width: 1
        border.color: Theme.colors.border.base
    }

    component ContrastBadge: Rectangle {
        required property color foregroundColor
        required property color backgroundColor
        property string kind: "text"

        readonly property real ratio: root.contrastRatio(foregroundColor, backgroundColor)
        readonly property string grade: root.gradeFor(ratio, kind)

        implicitWidth: badgeText.implicitWidth + Theme.spacing.sm
        implicitHeight: 26
        radius: Theme.radius.full
        color: grade === "Fail" ? Theme.colors.status.error.background : Theme.colors.status.success.background
        border.width: 1
        border.color: grade === "Fail" ? Theme.colors.status.error.border : Theme.colors.status.success.border

        AppLabel {
            id: badgeText
            anchors.centerIn: parent
            textType: AppLabel.Caption
            text: parent.grade + " " + parent.ratio.toFixed(2)
            color: parent.grade === "Fail" ? Theme.colors.status.error.foreground : Theme.colors.status.success.foreground
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }

    component TokenRow: Item {
        required property string label
        required property color swatchColor
        property string usage: ""
        property bool showContrast: false
        property color contrastForeground: Theme.colors.text.primary
        property color contrastBackground: swatchColor
        property string contrastKind: "text"

        width: parent ? parent.width : 320
        height: Math.max(58, tokenRow.implicitHeight)

        Row {
            id: tokenRow
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: Theme.spacing.sm

            ColorSwatch {
                swatchColor: parent.parent.swatchColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                width: Math.max(120, parent.width - 44 - Theme.spacing.sm - valueColumn.width - Theme.spacing.sm)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: label
                    color: Theme.colors.text.primary
                    wrapMode: Text.WordWrap
                }

                SectionCaption {
                    width: parent.width
                    text: usage
                    visible: usage.length > 0
                }
            }

            Column {
                id: valueColumn
                width: Math.max(84, contrastBadge.visible ? contrastBadge.implicitWidth : 84)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xxs

                AppLabel {
                    width: parent.width
                    textType: AppLabel.Caption
                    text: root.colorLabel(swatchColor)
                    color: Theme.colors.text.secondary
                    horizontalAlignment: Text.AlignRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }

                ContrastBadge {
                    id: contrastBadge
                    anchors.right: parent.right
                    visible: showContrast
                    foregroundColor: contrastForeground
                    backgroundColor: contrastBackground
                    kind: contrastKind
                }
            }
        }
    }

    component TokenGroup: Surface {
        required property string title
        property string subtitle: ""
        default property alias content: tokenColumn.data

        width: root.categoryCardWidth()
        height: tokenColumn.implicitHeight + Theme.spacing.xl2
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: tokenColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.lg
            }
            spacing: Theme.spacing.md

            Column {
                width: parent.width
                spacing: Theme.spacing.xxs

                SectionTitle {
                    width: parent.width
                    text: title
                }

                SectionCaption {
                    width: parent.width
                    text: subtitle
                    visible: subtitle.length > 0
                }
            }
        }
    }

    component MetricCard: Surface {
        required property string label
        required property color foregroundColor
        required property color sampleBackgroundColor
        property string kind: "text"

        width: root.metricCardWidth()
        height: metricColumn.implicitHeight + Theme.spacing.lg
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: metricColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.sm

            Row {
                width: parent.width
                spacing: Theme.spacing.sm

                Rectangle {
                    width: 48
                    height: 36
                    radius: Theme.radius.medium
                    color: sampleBackgroundColor
                    border.width: 1
                    border.color: Theme.colors.border.base

                    AppLabel {
                        anchors.centerIn: parent
                        textType: AppLabel.Caption
                        text: kind === "nonText" ? "" : "Aa"
                        color: foregroundColor
                        wrapMode: Text.NoWrap
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 22
                        height: 2
                        radius: 1
                        color: foregroundColor
                        visible: kind === "nonText"
                    }
                }

                Column {
                    width: parent.width - 48 - Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.xxs

                    AppLabel {
                        width: parent.width
                        textType: AppLabel.Caption
                        text: label
                        color: Theme.colors.text.primary
                        wrapMode: Text.WordWrap
                    }

                    SectionCaption {
                        width: parent.width
                        text: kind === "nonText" ? "WCAG 1.4.11" : "WCAG 1.4.3"
                    }
                }
            }

            ContrastBadge {
                foregroundColor: parent.parent.foregroundColor
                backgroundColor: parent.parent.sampleBackgroundColor
                kind: parent.parent.kind
            }
        }
    }

    component InputPreview: Rectangle {
        property string text: ""
        property bool focused: false

        width: parent ? parent.width : 240
        height: Theme.spacing.touchTarget
        radius: Theme.radius.input
        color: Theme.colors.surface.base
        border.width: focused ? 2 : 1
        border.color: focused ? Theme.colors.border.focus : Theme.colors.border.base

        AppLabel {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Theme.spacing.md
                rightMargin: Theme.spacing.md
            }
            textType: AppLabel.Body
            text: parent.text
            color: Theme.colors.text.primary
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }

    component PreviewCard: Surface {
        required property string title
        default property alias content: previewContent.data

        width: root.previewCardWidth()
        height: previewContent.implicitHeight + Theme.spacing.xl2
        surfaceType: Surface.Default
        radiusValue: Theme.radius.large

        Column {
            id: previewContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacing.lg
            }
            spacing: Theme.spacing.md

            SectionTitle {
                width: parent.width
                text: title
            }
        }
    }

    component AlertPreview: Rectangle {
        required property string label
        required property string iconName
        required property color accentColor
        required property color fillColor

        width: parent ? parent.width : 240
        height: 44
        radius: Theme.radius.medium
        color: fillColor
        border.width: 1
        border.color: accentColor

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: Theme.spacing.md
            }
            spacing: Theme.spacing.sm

            AppIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: iconName
                size: Theme.icons.small
                color: accentColor
            }

            AppLabel {
                width: parent.width - Theme.icons.small - Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                textType: AppLabel.Caption
                text: label
                color: accentColor
                wrapMode: Text.WordWrap
            }
        }
    }

    Column {
        id: page
        width: root.width
        spacing: Theme.spacing.xl

        Surface {
            width: parent.width
            height: headerColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: headerColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.sm

                Row {
                    width: parent.width
                    spacing: Theme.spacing.md

                    AppIcon {
                        name: "material:palette"
                        size: Theme.icons.large
                        color: Theme.colors.action.primary.container
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - Theme.icons.large - Theme.spacing.md
                        spacing: Theme.spacing.xxs

                        AppLabel {
                            width: parent.width
                            textType: AppLabel.H2
                            text: "Colors"
                            color: Theme.colors.text.primary
                            wrapMode: Text.WordWrap
                        }

                        SectionCaption {
                            width: parent.width
                            text: "Semantic color tokens used across Merce components and patterns."
                        }
                    }
                }

                Row {
                    spacing: Theme.spacing.sm

                    MBadge {
                        text: Theme.activeBrand
                        variant: MBadge.Primary
                        size: MBadge.Small
                    }

                    MBadge {
                        text: Theme.activeMode === "" ? "default mode" : Theme.activeMode + " mode"
                        variant: MBadge.Neutral
                        size: MBadge.Small
                    }
                }
            }
        }

        Flow {
            width: parent.width
            spacing: root.cardGap

            TokenGroup {
                title: "Action"
                subtitle: "Brand and interactive states"

                TokenRow {
                    label: "colors.action.primary"
                    swatchColor: Theme.colors.action.primary.container
                    usage: "Primary button background"
                    showContrast: true
                    contrastForeground: Theme.colors.text.inverse
                }
                TokenRow { label: "colors.action.primaryHover"; swatchColor: Theme.colors.action.primaryHover; usage: "Primary hover state" }
                TokenRow { label: "colors.action.primaryPressed"; swatchColor: Theme.colors.action.primaryPressed; usage: "Pressed or selected state" }
                TokenRow { label: "colors.action.primarySubtle"; swatchColor: Theme.colors.action.primarySubtle; usage: "Subtle brand surface" }
                TokenRow {
                    label: "colors.action.secondary"
                    swatchColor: Theme.colors.action.secondary.container
                    usage: "Secondary button background"
                    showContrast: true
                    contrastForeground: Theme.colors.text.inverse
                }
                TokenRow { label: "colors.action.secondaryHover"; swatchColor: Theme.colors.action.secondaryHover; usage: "Secondary hover state" }
                TokenRow { label: "colors.action.secondaryPressed"; swatchColor: Theme.colors.action.secondaryPressed; usage: "Secondary pressed state" }
                TokenRow { label: "colors.action.disabled"; swatchColor: Theme.colors.action.disabled; usage: "Disabled action fill" }
            }

            TokenGroup {
                title: "Background & Surface"
                subtitle: "Page, panel, and container fills"

                TokenRow {
                    label: "colors.background.base"
                    swatchColor: Theme.colors.background.base
                    usage: "Application background"
                    showContrast: true
                    contrastForeground: Theme.colors.text.primary
                }
                TokenRow { label: "colors.background.subtle"; swatchColor: Theme.colors.background.subtle; usage: "Subtle page band" }
                TokenRow { label: "colors.surface.base"; swatchColor: Theme.colors.surface.base; usage: "Default panel fill" }
                TokenRow { label: "colors.surface.raised"; swatchColor: Theme.colors.surface.raised; usage: "Raised container fill" }
                TokenRow { label: "colors.surface.hover"; swatchColor: Theme.colors.surface.hover; usage: "Hover state fill" }
                TokenRow { label: "colors.surface.pressed"; swatchColor: Theme.colors.surface.pressed; usage: "Pressed state fill" }
                TokenRow { label: "colors.surface.tinted"; swatchColor: Theme.colors.surface.tinted; usage: "Soft tinted fill" }
                TokenRow { label: "colors.surface.disabled"; swatchColor: Theme.colors.surface.disabled; usage: "Disabled container fill" }
            }

            TokenGroup {
                title: "Text"
                subtitle: "Content hierarchy and links"

                TokenRow {
                    label: "colors.text.primary"
                    swatchColor: Theme.colors.text.primary
                    usage: "Primary content"
                    showContrast: true
                    contrastForeground: Theme.colors.text.primary
                    contrastBackground: Theme.colors.background.base
                }
                TokenRow {
                    label: "colors.text.secondary"
                    swatchColor: Theme.colors.text.secondary
                    usage: "Secondary content"
                    showContrast: true
                    contrastForeground: Theme.colors.text.secondary
                    contrastBackground: Theme.colors.background.base
                }
                TokenRow { label: "colors.text.tertiary"; swatchColor: Theme.colors.text.tertiary; usage: "Muted labels" }
                TokenRow {
                    label: "colors.text.inverse"
                    swatchColor: Theme.colors.text.inverse
                    usage: "Text on dark or brand fills"
                    showContrast: true
                    contrastForeground: Theme.colors.text.inverse
                    contrastBackground: Theme.colors.action.primary.container
                }
                TokenRow { label: "colors.text.disabled"; swatchColor: Theme.colors.text.disabled; usage: "Disabled content" }
                TokenRow { label: "colors.text.link"; swatchColor: Theme.colors.text.link; usage: "Links" }
                TokenRow { label: "colors.text.linkHover"; swatchColor: Theme.colors.text.linkHover; usage: "Link hover state" }
            }

            TokenGroup {
                title: "Border"
                subtitle: "Dividers, focus, and validation outlines"

                TokenRow { label: "colors.border.base"; swatchColor: Theme.colors.border.base; usage: "Default divider" }
                TokenRow { label: "colors.border.strong"; swatchColor: Theme.colors.border.strong; usage: "Hover or emphasized border" }
                TokenRow {
                    label: "colors.border.focus"
                    swatchColor: Theme.colors.border.focus
                    usage: "Focus ring"
                    showContrast: true
                    contrastForeground: Theme.colors.border.focus
                    contrastBackground: Theme.colors.surface.base
                    contrastKind: "nonText"
                }
                TokenRow { label: "colors.border.disabled"; swatchColor: Theme.colors.border.disabled; usage: "Disabled border" }
            }

            TokenGroup {
                title: "Status"
                subtitle: "Feedback and state colors"

                TokenRow {
                    label: "colors.status.success.foreground"
                    swatchColor: Theme.colors.status.success.foreground
                    usage: "Success foreground or icon"
                    showContrast: true
                    contrastForeground: Theme.colors.status.success.foreground
                    contrastBackground: Theme.colors.status.success.background
                    contrastKind: "nonText"
                }
                TokenRow { label: "colors.status.success.background"; swatchColor: Theme.colors.status.success.background; usage: "Success alert fill" }
                TokenRow { label: "colors.status.success.border"; swatchColor: Theme.colors.status.success.border; usage: "Success outline" }
                TokenRow { label: "colors.status.success.strong"; swatchColor: Theme.colors.status.success.strong; usage: "Success solid fill" }
                TokenRow {
                    label: "colors.status.warning.foreground"
                    swatchColor: Theme.colors.status.warning.foreground
                    usage: "Warning foreground or icon"
                    showContrast: true
                    contrastForeground: Theme.colors.status.warning.foreground
                    contrastBackground: Theme.colors.status.warning.background
                    contrastKind: "nonText"
                }
                TokenRow { label: "colors.status.warning.background"; swatchColor: Theme.colors.status.warning.background; usage: "Warning alert fill" }
                TokenRow { label: "colors.status.warning.border"; swatchColor: Theme.colors.status.warning.border; usage: "Warning outline" }
                TokenRow { label: "colors.status.warning.strong"; swatchColor: Theme.colors.status.warning.strong; usage: "Warning solid fill" }
                TokenRow {
                    label: "colors.status.error.foreground"
                    swatchColor: Theme.colors.status.error.foreground
                    usage: "Error foreground or icon"
                    showContrast: true
                    contrastForeground: Theme.colors.status.error.foreground
                    contrastBackground: Theme.colors.status.error.background
                    contrastKind: "nonText"
                }
                TokenRow { label: "colors.status.error.background"; swatchColor: Theme.colors.status.error.background; usage: "Error alert fill" }
                TokenRow { label: "colors.status.error.border"; swatchColor: Theme.colors.status.error.border; usage: "Error outline" }
                TokenRow { label: "colors.status.error.strong"; swatchColor: Theme.colors.status.error.strong; usage: "Error solid fill" }
                TokenRow { label: "colors.status.info.foreground"; swatchColor: Theme.colors.status.info.foreground; usage: "Information foreground or icon" }
                TokenRow { label: "colors.status.info.background"; swatchColor: Theme.colors.status.info.background; usage: "Information alert fill" }
                TokenRow { label: "colors.status.info.border"; swatchColor: Theme.colors.status.info.border; usage: "Information outline" }
                TokenRow { label: "colors.status.info.strong"; swatchColor: Theme.colors.status.info.strong; usage: "Information solid fill" }
            }
        }

        Surface {
            width: parent.width
            height: previewColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: previewColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                Column {
                    width: parent.width
                    spacing: Theme.spacing.xxs

                    SectionTitle {
                        width: parent.width
                        text: "Component Previews"
                    }

                    SectionCaption {
                        width: parent.width
                        text: "Representative component states using the active semantic color tokens."
                    }
                }

                Flow {
                    width: parent.width
                    spacing: root.cardGap

                    PreviewCard {
                        title: "Buttons"

                        SK.Button {
                            width: parent.width
                            text: "Primary Button"
                        }

                        SK.Button {
                            width: parent.width
                            text: "Secondary Button"
                            SK.StyleVariation.variations: ["secondary"]
                        }

                        SK.Button {
                            width: parent.width
                            text: "Outline Button"
                            SK.StyleVariation.variations: ["outline"]
                        }
                    }

                    PreviewCard {
                        title: "Inputs"

                        InputPreview { text: "Default input" }

                        InputPreview { text: "Focused input"; focused: true }

                        SK.TextField {
                            width: parent.width
                            text: "Error input"
                            readOnly: true
                            rightPadding: Theme.spacing.xl2
                            SK.StyleVariation.variations: ["error"]

                            AppIcon {
                                anchors {
                                    right: parent.right
                                    rightMargin: Theme.spacing.md
                                    verticalCenter: parent.verticalCenter
                                }
                                name: "material:error"
                                size: Theme.icons.small
                                color: Theme.colors.status.error.foreground
                            }
                        }
                    }

                    PreviewCard {
                        title: "Alerts"

                        AlertPreview {
                            label: "Success message"
                            iconName: "material:check_circle"
                            accentColor: Theme.colors.status.success.foreground
                            fillColor: Theme.colors.status.success.background
                        }

                        AlertPreview {
                            label: "Warning message"
                            iconName: "material:warning"
                            accentColor: Theme.colors.status.warning.foreground
                            fillColor: Theme.colors.status.warning.background
                        }

                        AlertPreview {
                            label: "Error message"
                            iconName: "material:error"
                            accentColor: Theme.colors.status.error.foreground
                            fillColor: Theme.colors.status.error.background
                        }
                    }

                    PreviewCard {
                        title: "Badges"

                        Flow {
                            width: parent.width
                            spacing: Theme.spacing.sm

                            MBadge { text: "Primary"; variant: MBadge.Primary }
                            MBadge { text: "Success"; variant: MBadge.Success }
                            MBadge { text: "Warning"; variant: MBadge.Warning }
                            MBadge { text: "Error"; variant: MBadge.Error }
                            MBadge { text: "Info"; variant: MBadge.Info }
                            MBadge { text: "Neutral"; variant: MBadge.Neutral }
                        }
                    }
                }
            }
        }

        Surface {
            width: parent.width
            height: accessibilityColumn.implicitHeight + Theme.spacing.xl2
            surfaceType: Surface.Default
            radiusValue: Theme.radius.large

            Column {
                id: accessibilityColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Theme.spacing.xl
                }
                spacing: Theme.spacing.lg

                Row {
                    width: parent.width
                    spacing: Theme.spacing.md

                    Column {
                        width: parent.width - wcagBadge.width - Theme.spacing.md
                        spacing: Theme.spacing.xxs

                        SectionTitle {
                            width: parent.width
                            text: "Accessibility"
                        }

                        SectionCaption {
                            width: parent.width
                            text: "WCAG 2.2 AA is the baseline; AAA is shown when a text pair reaches enhanced contrast."
                        }
                    }

                    MBadge {
                        id: wcagBadge
                        anchors.verticalCenter: parent.verticalCenter
                        text: "WCAG 2.2"
                        variant: MBadge.Success
                        size: MBadge.Small
                    }
                }

                Flow {
                    width: parent.width
                    spacing: root.cardGap

                    MetricCard {
                        label: "Primary text on page"
                        foregroundColor: Theme.colors.text.primary
                        sampleBackgroundColor: Theme.colors.background.base
                    }

                    MetricCard {
                        label: "Secondary text on page"
                        foregroundColor: Theme.colors.text.secondary
                        sampleBackgroundColor: Theme.colors.background.base
                    }

                    MetricCard {
                        label: "Inverse text on primary"
                        foregroundColor: Theme.colors.text.inverse
                        sampleBackgroundColor: Theme.colors.action.primary.container
                    }

                    MetricCard {
                        label: "Inverse text on secondary"
                        foregroundColor: Theme.colors.text.inverse
                        sampleBackgroundColor: Theme.colors.action.secondary.container
                    }

                    MetricCard {
                        label: "Focus ring on surface"
                        foregroundColor: Theme.colors.border.focus
                        sampleBackgroundColor: Theme.colors.surface.base
                        kind: "nonText"
                    }

                    MetricCard {
                        label: "Error icon on soft fill"
                        foregroundColor: Theme.colors.status.error.foreground
                        sampleBackgroundColor: Theme.colors.status.error.background
                        kind: "nonText"
                    }

                    MetricCard {
                        label: "Success icon on soft fill"
                        foregroundColor: Theme.colors.status.success.foreground
                        sampleBackgroundColor: Theme.colors.status.success.background
                        kind: "nonText"
                    }

                    MetricCard {
                        label: "Warning icon on soft fill"
                        foregroundColor: Theme.colors.status.warning.foreground
                        sampleBackgroundColor: Theme.colors.status.warning.background
                        kind: "nonText"
                    }
                }
            }
        }
    }
}
